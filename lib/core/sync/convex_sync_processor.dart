import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/convex/convex_config.dart';
import 'package:mawlid_al_dhaki/core/auth/auth0_service.dart';
import 'package:mawlid_al_dhaki/core/sync/convex_down_sync_service.dart';
import 'package:mawlid_al_dhaki/core/services/event_service.dart';

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

/// Processor for syncing local Drift events to Convex Cloud.
/// Implements event-sourced Local-First architecture with Last-Write-Wins conflict resolution.
/// Also supports legacy outbox-based sync for backward compatibility during migration.
class ConvexSyncProcessor {
  final AppDatabase database;
  late final EventService _eventService;
  
  // Default conflict resolution strategy
  static ConflictResolutionStrategy defaultStrategy = ConflictResolutionStrategy.lastWriteWins;
  
  bool _isProcessing = false;
  Timer? _syncTimer;
  
  // Down-sync service for pulling from cloud
  late final ConvexDownSyncService _downSyncService;

  ConvexSyncProcessor(this.database) {
    _downSyncService = ConvexDownSyncService(database);
    _eventService = EventService(database);
  }

  /// Check if sync should proceed.
  /// Allow sync if Convex is initialized and user is authenticated.
  bool get _canSync {
    final initialized = AppConvexConfig.isInitialized;
    final authenticated = AppConvexConfig.isAuthenticated;
    debugPrint('[Sync] _canSync: initialized=$initialized, authenticated=$authenticated');
    return initialized && authenticated;
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

  /// Manually trigger sync processing.
  /// Processes both event-based sync (primary) and legacy outbox sync (backward compatibility).
  Future<void> processOutbox() async {
    if (_isProcessing) return;
    if (!_canSync) {
      debugPrint('ConvexSyncProcessor: Skipping - not initialized or demo mode not allowed');
      return;
    }
    
    _isProcessing = true;
    try {
      // First: Push local events to cloud (up-sync) - PRIMARY METHOD
      await _processEvents();
      
      // Also process legacy outbox entries for backward compatibility
      await _processLegacyOutbox();
      
      // Second: Pull changes from cloud (down-sync)
      // This keeps local in sync with cloud changes from other devices
      await _downSyncService.syncFromCloud();
      
    } catch (e) {
      debugPrint('ConvexSyncProcessor Error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  /// Process pending events and sync to Convex using the event-sourced approach.
  Future<void> _processEvents() async {
    final pendingEvents = await _eventService.getPendingEvents();
    
    if (pendingEvents.isEmpty) {
      debugPrint('[EventSync] No pending events');
      return;
    }
    
    debugPrint('[EventSync] Processing ${pendingEvents.length} pending events');
    
    for (final event in pendingEvents) {
      try {
        await _syncEvent(event);
      } catch (e) {
        debugPrint('[EventSync] Error syncing event ${event.id}: $e');
        await _eventService.markEventFailed(event.id, e.toString());
      }
    }
  }

  /// Sync a single event to Convex.
  Future<void> _syncEvent(EventEntry event) async {
    final payload = jsonDecode(event.payload) as Map<String, dynamic>;
    
    debugPrint('[EventSync] Syncing event: ${event.eventType} for ${event.entityType}/${event.entityId}');
    
    // Call the Convex recordEvent mutation
    final result = await AppConvexConfig.mutation('mutations/events:recordEvent', {
      'ownerId': _getCurrentOwnerId(),
      'eventType': event.eventType,
      'entityType': event.entityType,
      'entityId': event.entityId,
      'payload': jsonEncode(payload),
      'version': event.version,
      'occurredAt': event.occurredAt.millisecondsSinceEpoch,
      'recordedBy': _getCurrentOwnerId(),
    });
    
    if (result['success'] == true) {
      await _eventService.markEventSynced(event.id);
      debugPrint('[EventSync] Event synced: ${event.id}');
    } else {
      throw Exception(result['reason'] ?? 'Failed to sync event');
    }
  }

  /// Process legacy outbox entries for backward compatibility.
  Future<void> _processLegacyOutbox() async {
    final pendingEntries = await (database.select(database.outboxTable)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();

    if (pendingEntries.isEmpty) {
      return;
    }
    
    debugPrint('[LegacyOutbox] Processing ${pendingEntries.length} legacy outbox entries');
    
    for (final entry in pendingEntries) {
      try {
        await _syncLegacyEntry(entry);
      } catch (e) {
        debugPrint('[LegacyOutbox] Error syncing entry ${entry.id}: $e');
        final retryCount = entry.retryCount + 1;
        final status = retryCount > 5 ? 'failed' : 'pending';
        await database.update(database.outboxTable).replace(
          entry.copyWith(
            status: status,
            retryCount: retryCount,
            lastError: Value(e.toString()),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    }
  }

  /// Sync a legacy outbox entry (backward compatibility).
  Future<void> _syncLegacyEntry(OutboxEntry entry) async {
    // Mark as syncing
    await database.update(database.outboxTable).replace(
      entry.copyWith(status: 'syncing', updatedAt: Value(DateTime.now())),
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
    
    debugPrint('[LegacyOutbox] Calling mutation=$mutationName');
    
    // Execute Convex mutation via HTTP
    final result = await AppConvexConfig.mutation(mutationName, resolvedPayload);
    
    if (result['success'] == true) {
      // Mark as synced
      await database.update(database.outboxTable).replace(
        entry.copyWith(
          status: 'synced',
          syncedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );
      debugPrint('[LegacyOutbox] Synced ${entry.targetTable} id: ${entry.documentId}');
    } else {
      throw Exception(result['reason'] ?? 'Convex mutation failed');
    }
  }

  /// Check for conflicts before syncing
  Future<ConflictResult> _checkConflict(
    String tableName,
    String documentId,
    int localVersion,
  ) async {
    try {
      // Query cloud for the document's version using correct Convex path format
      // Path format: modulePath:functionName (e.g., queries/subscribers:getSubscriberById)
      final queryName = _getQueryName(tableName, 'ById');
      if (queryName == null) {
        return ConflictResult(
          hasConflict: false,
          localVersion: localVersion,
          cloudVersion: 0,
          strategy: defaultStrategy,
        );
      }
      final cloudData = await AppConvexConfig.query(queryName, {
        'ownerId': _getCurrentOwnerId(),
        'id': documentId,
      });
      
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
      
      debugPrint('[Sync] Calling mutation=$mutationName with payload: $resolvedPayload');
      
      // Execute Convex mutation via HTTP
      final result = await AppConvexConfig.mutation(mutationName, resolvedPayload);
      
      debugPrint('[Sync] Mutation result: $result');
      
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

  /// Get the full Convex query path (module:function)
  String? _getQueryName(String table, String suffix) {
    // Map table names to their Convex query module and function names
    final queryMappings = {
      'subscribers': 'queries/subscribers:getSubscriber$suffix',
      'cabinets': 'queries/cabinets:getCabinet$suffix',
      'payments': 'queries/payments:getPayment$suffix',
      'workers': 'queries/workers:getWorker$suffix',
      'auditLog': 'queries/auditLog:getAuditLog$suffix',
      'whatsappTemplates': 'queries/whatsappTemplates:getWhatsappTemplate$suffix',
      'generatorSettings': 'queries/generatorSettings:getGeneratorSetting$suffix',
    };
    return queryMappings[table];
  }

  String _getMutationName(String table, String operation) {
    // Map table names to their Convex mutation module and function names
    // Path format: mutations/moduleName:functionName
    final mutationModuleMappings = {
      'subscribers': 'mutations/subscribers',
      'cabinets': 'mutations/cabinets',
      'payments': 'mutations/payments',
      'workers': 'mutations/workers',
      'auditLog': 'mutations/auditLog',
      'whatsappTemplates': 'mutations/whatsappTemplates',
      'generatorSettings': 'mutations/generatorSettings',
    };
    
    final singular = _toSingular(table);
    final module = mutationModuleMappings[table] ?? 'mutations/$table';
    
    // For delete operations, use delete mutation
    if (operation == 'delete') {
      return '$module:delete$singular';
    }
    
    // For create/update, use save mutation
    return '$module:save$singular';
  }
  
  String _toSingular(String table) {
    // Handle special cases with proper capitalization
    final singularMappings = {
      'cabinets': 'Cabinet',
      'subscribers': 'Subscriber',
      'payments': 'Payment',
      'workers': 'Worker',
      'auditLog': 'AuditLog',
      'whatsappTemplates': 'WhatsappTemplate',
      'generatorSettings': 'GeneratorSetting',
    };
    return singularMappings[table] ?? table;
  }
  
  /// Get current owner ID from Auth0 user
  String _getCurrentOwnerId() {
    final auth = Auth0Service.instance;
    final userId = auth.userId;
    if (userId != null && userId.isNotEmpty) {
      return userId;
    }
    return 'demo-user';
  }
}
