import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:convex_flutter/convex_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/convex/convex_config.dart';

/// Processor for syncing local Drift Outbox entries to Convex Cloud.
/// Implements Local-First: write locally, sync in background.
class ConvexSyncProcessor {
  final AppDatabase database;
  final ConvexClient client = AppConvexConfig.client;
  
  bool _isProcessing = false;
  Timer? _syncTimer;

  ConvexSyncProcessor(this.database);

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
    if (_isProcessing || !AppConvexConfig.isAuthenticated) return;
    
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
      
      // Execute Convex mutation
      // NOTE: ownerId is injected by the withTenantMutation wrapper on server side.
      final result = await client.mutation(
        name: mutationName, 
        args: payload,
      );

      final decodedResult = jsonDecode(result);
      
      if (decodedResult['success'] == true) {
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
        throw Exception(decodedResult['reason'] ?? 'Convex mutation failed');
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
    // Maps table + op to Convex mutation name (e.g., 'subscribers' + 'create' -> 'saveSubscriber')
    // All our Convex mutations follow the 'save[Object]' pattern.
    if (table.endsWith('s')) {
      final singular = table.substring(0, table.length - 1);
      final capitalized = singular[0].toUpperCase() + singular.substring(1);
      return 'save$capitalized';
    }
    return 'save${table[0].toUpperCase() + table.substring(1)}';
  }
}
