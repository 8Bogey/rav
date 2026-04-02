import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/convex/convex_config.dart';
import 'package:mawlid_al_dhaki/features/auth/providers/auth_provider.dart';

/// Conflict resolution strategies
enum ConflictResolutionStrategy {
  /// Last-Write-Wins: newest timestamp wins
  lastWriteWins,
  
  /// Local wins: always prefer local changes
  localWins,
  
  /// Cloud wins: always prefer cloud changes  
  cloudWins,
  
  /// Merge: attempt to merge changes (field-level)
  merge,
}

/// Conflict detection result
class ConflictResult {
  final bool hasConflict;
  final int localVersion;
  final int cloudVersion;
  final Map<String, dynamic>? cloudData;
  final ConflictResolutionStrategy strategy;
  
  ConflictResult({
    required this.hasConflict,
    required this.localVersion,
    required this.cloudVersion,
    this.cloudData,
    required this.strategy,
  });
}

/// Processor for syncing local Drift Outbox entries to Convex Cloud.
/// Implements Local-First with Last-Write-Wins conflict resolution.
class ConvexSyncProcessor {
  final AppDatabase database;
  
  // Default conflict resolution strategy
  static ConflictResolutionStrategy defaultStrategy = ConflictResolutionStrategy.lastWriteWins;
  
  bool _isProcessing = false;
  Timer? _syncTimer;

  ConvexSyncProcessor(this.database);

  /// Check if sync should proceed.
  /// In demo mode (kDemoAuthLogin=true), allow sync if Convex is initialized.
  /// In production, require real authentication.
  bool get _canSync {
    if (!AppConvexConfig.isInitialized) return false;
    
    // In demo mode, allow sync even without real auth token
    if (kDemoAuthLogin) return true;
    
    // Production: require real authentication
    return AppConvexConfig.isAuthenticated;
  }

  /// Start the background sync loop.
  void start() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 10), (_) => processOutbox());
    debugPrint('ConvexSyncProcessor: Started background loop');
  }

  /// Stop the background sync loop.
  void stop() {
    _syncTimer?.cancel();
    _syncTimer = null;
    debugPrint('ConvexSyncProcessor: Stopped');
  }

  /// Manually trigger an outbox processing run.
  Future<void> processOutbox() async {
    if (_isProcessing) return;
    if (!_canSync) {
      debugPrint('ConvexSyncProcessor: Skipping - not initialized or demo mode not allowed');
      return;
    }
    
    _isProcessing = true;
    try {
      final pendingEntries = await (database.select(database.outboxTable)
            ..where((t) => t.status.equals('pending'))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

      if (pendingEntries.isEmpty) return;
      
      debugPrint('ConvexSyncProcessor: Processing ${pendingEntries.length} pending entries');

      for (final entry in pendingEntries) {
        await _syncEntry(entry);
      }
    } catch (e) {
      debugPrint('ConvexSyncProcessor Error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  /// Check for conflicts before syncing
  Future<ConflictResult> _checkConflict(
    String tableName, 
    String documentId,
    int localVersion,
  ) async {
    try {
      // Query cloud for the document's version
      final queryName = 'get${_toSingular(tableName)}';
      final cloudData = await AppConvexConfig.query(queryName, {'id': documentId});
      
      if (cloudData == null) {
        // No cloud version exists - no conflict
        return ConflictResult(
          hasConflict: false,
          localVersion: localVersion,
          cloudVersion: 0,
          strategy: defaultStrategy,
        );
      }
      
      final cloudVersion = (cloudData['version'] as int?) ?? 0;
      final hasConflict = cloudVersion > localVersion;
      
      return ConflictResult(
        hasConflict: hasConflict,
        localVersion: localVersion,
        cloudVersion: cloudVersion,
        cloudData: Map<String, dynamic>.from(cloudData),
        strategy: defaultStrategy,
      );
    } catch (e) {
      // If we can't check, assume no conflict (optimistic)
      return ConflictResult(
        hasConflict: false,
        localVersion: localVersion,
        cloudVersion: 0,
        strategy: defaultStrategy,
      );
    }
  }

  /// Resolve conflict based on strategy
  Future<Map<String, dynamic>> _resolveConflict(
    Map<String, dynamic> localData,
    ConflictResult conflict,
  ) async {
    switch (conflict.strategy) {
      case ConflictResolutionStrategy.localWins:
        // Use local data as-is
        return localData;
        
      case ConflictResolutionStrategy.cloudWins:
        // Return cloud data (already have it)
        return conflict.cloudData ?? localData;
        
      case ConflictResolutionStrategy.lastWriteWins:
        // Compare timestamps - newer wins
        final localUpdated = (localData['updatedAt'] as int?) ?? 0;
        final cloudUpdated = (conflict.cloudData?['updatedAt'] as int?) ?? 0;
        
        if (cloudUpdated > localUpdated) {
          return conflict.cloudData ?? localData;
        } else {
          return localData;
        }
        
      case ConflictResolutionStrategy.merge:
        // Field-level merge: keep newer values for each field
        return _mergeData(localData, conflict.cloudData ?? {});
    }
  }

  /// Merge two data objects field-by-field, keeping newer values
  Map<String, dynamic> _mergeData(
    Map<String, dynamic> local, 
    Map<String, dynamic> cloud,
  ) {
    final merged = <String, dynamic>{};
    final allKeys = {...local.keys, ...cloud.keys};
    
    for (final key in allKeys) {
      final localValue = local[key];
      final cloudValue = cloud[key];
      
      // Skip metadata fields
      if (key == 'version' || key == 'updatedAt' || key == 'createdAt') {
        // Keep higher version
        merged[key] = ((localValue as int?) ?? 0) > ((cloudValue as int?) ?? 0) 
            ? localValue 
            : cloudValue;
        continue;
      }
      
      // For data fields, prefer non-null values or newer timestamp wins
      if (localValue != null && cloudValue != null) {
        final localTime = (local['updatedAt'] as int?) ?? 0;
        final cloudTime = (cloud['updatedAt'] as int?) ?? 0;
        merged[key] = localTime > cloudTime ? localValue : cloudValue;
      } else if (localValue != null) {
        merged[key] = localValue;
      } else {
        merged[key] = cloudValue;
      }
    }
    
    return merged;
  }

  /// Sync a single entry to Convex with conflict resolution.
  Future<void> _syncEntry(OutboxEntry entry) async {
    try {
      // Mark as syncing
      await database.update(database.outboxTable).replace(
        entry.copyWith(status: 'syncing', updatedAt: Value(DateTime.now()))
      );

      final Map<String, dynamic> payload = jsonDecode(entry.payload);
      final String documentId = entry.documentId;
      final int localVersion = (payload['version'] as int?) ?? 1;
      
      // Check for conflicts with cloud
      final conflict = await _checkConflict(
        entry.targetTable, 
        documentId, 
        localVersion,
      );
      
      // Resolve conflict if needed
      final resolvedPayload = conflict.hasConflict
          ? await _resolveConflict(payload, conflict)
          : payload;
      
      // Increment version for the write
      resolvedPayload['version'] = conflict.hasConflict
          ? conflict.cloudVersion + 1
          : localVersion;
      
      final String mutationName = _getMutationName(entry.targetTable, entry.operationType);
      
      // Execute Convex mutation via HTTP
      final result = await AppConvexConfig.mutation(mutationName, resolvedPayload);
      
      if (result['success'] == true) {
        // Mark as synced
        await database.update(database.outboxTable).replace(
          entry.copyWith(
            status: 'synced', 
            syncedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now())
          )
        );
        debugPrint('ConvexSyncProcessor: Synced ${entry.targetTable} id: ${entry.documentId} (version ${resolvedPayload['version']})');
      } else {
        throw Exception(result['reason'] ?? 'Convex mutation failed');
      }
    } catch (e) {
      debugPrint('ConvexSyncProcessor Entry Error: $e');
      final retryCount = entry.retryCount + 1;
      final status = retryCount > 5 ? 'failed' : 'pending';
      
      await database.update(database.outboxTable).replace(
        entry.copyWith(
          status: status, 
          retryCount: retryCount,
          lastError: Value(e.toString()),
          updatedAt: Value(DateTime.now())
        )
      );
    }
  }

  String _getMutationName(String table, String operation) {
    // Handle special table names
    final tableMappings = {
      'subscribers': 'Subscriber',
      'payments': 'Payment',
      'cabinets': 'Cabinet',
      'workers': 'Worker',
      'auditLog': 'AuditLog',
      'whatsappTemplates': 'WhatsappTemplate',
      'generatorSettings': 'GeneratorSetting',
    };
    
    // For delete operations, use delete mutation
    if (operation == 'delete') {
      final singular = tableMappings[table] ?? _toSingular(table);
      return 'delete$singular';
    }
    
    // For create/update, use save mutation
    final singular = tableMappings[table] ?? _toSingular(table);
    return 'save$singular';
  }
  
  String _toSingular(String table) {
    if (table.endsWith('s')) {
      return table[0].toUpperCase() + table.substring(1, table.length - 1);
    }
    return table[0].toUpperCase() + table.substring(1);
  }
}
