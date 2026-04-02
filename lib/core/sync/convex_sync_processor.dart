import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/convex/convex_config.dart';
import 'package:mawlid_al_dhaki/features/auth/providers/auth_provider.dart';

/// Processor for syncing local Drift Outbox entries to Convex Cloud.
/// Implements Local-First: write locally, sync in background.
class ConvexSyncProcessor {
  final AppDatabase database;
  
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

  /// Sync a single entry to Convex.
  Future<void> _syncEntry(OutboxEntry entry) async {
    try {
      // Mark as syncing
      await database.update(database.outboxTable).replace(
        entry.copyWith(status: 'syncing', updatedAt: Value(DateTime.now()))
      );

      final Map<String, dynamic> payload = jsonDecode(entry.payload);
      final String mutationName = _getMutationName(entry.targetTable, entry.operationType);
      
      // Execute Convex mutation via HTTP
      final result = await AppConvexConfig.mutation(mutationName, payload);
      
      if (result['success'] == true) {
        // Mark as synced
        await database.update(database.outboxTable).replace(
          entry.copyWith(
            status: 'synced', 
            syncedAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now())
          )
        );
        debugPrint('ConvexSyncProcessor: Synced ${entry.targetTable} id: ${entry.documentId}');
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
