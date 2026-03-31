/**
 * Outbox Processor - Write Path for Local-First Sync
 * 
 * Reads pending entries from Drift OutboxTable in FIFO order.
 * For each entry:
 * 1. Send mutation to Convex via client.mutation()
 * 2. Mark as 'synced' on success
 * 3. Increment retryCount on failure
 * 
 * Follows MINIMAX_IMPLEMENTATION_GUIDE.md patterns.
 */

import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:mawlid_al_dhaki/core/convex/convex_config.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';

/// Status values for outbox entries
class OutboxStatus {
  static const String pending = 'pending';
  static const String syncing = 'syncing';
  static const String failed = 'failed';
  static const String synced = 'synced';
}

/// Result of processing an outbox entry
class OutboxProcessResult {
  final bool success;
  final String? error;
  final String? convexResponse;

  const OutboxProcessResult({
    required this.success,
    this.error,
    this.convexResponse,
  });
}

/// Processor for handling offline writes
class OutboxProcessor {
  final AppDatabase _database;
  final ConvexConfig _convexConfig;
  
  Timer? _periodicTimer;
  bool _isProcessing = false;
  int _maxRetries = 3;
  Duration _retryDelay = const Duration(seconds: 5);
  
  /// Stream controller for processing status updates
  final _statusController = StreamController<OutboxStatusUpdate>.broadcast();
  Stream<OutboxStatusUpdate> get statusStream => _statusController.stream;

  OutboxProcessor({
    required AppDatabase database,
    ConvexConfig? convexConfig,
  })  : _database = database,
        _convexConfig = convexConfig ?? ConvexConfig;

  /// Start periodic processing
  void startPeriodicProcessing({
    Duration interval = const Duration(seconds: 30),
  }) {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(interval, (_) => processPendingEntries());
    debugPrint('OutboxProcessor: Started periodic processing (interval: $interval)');
    
    // Also process immediately
    processPendingEntries();
  }

  /// Stop periodic processing
  void stopPeriodicProcessing() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    debugPrint('OutboxProcessor: Stopped periodic processing');
  }

  /// Process all pending outbox entries
  Future<void> processPendingEntries() async {
    if (_isProcessing) {
      debugPrint('OutboxProcessor: Already processing, skipping');
      return;
    }

    if (!_convexConfig.isInitialized) {
      debugPrint('OutboxProcessor: Convex not initialized, skipping');
      return;
    }

    _isProcessing = true;
    
    try {
      // Get pending entries ordered by createdAt (FIFO)
      final pendingEntries = await _getPendingEntries();
      
      if (pendingEntries.isEmpty) {
        debugPrint('OutboxProcessor: No pending entries to process');
        _statusController.add(OutboxStatusUpdate(
          status: OutboxStatusUpdateType.idle,
          processedCount: 0,
        ));
        return;
      }

      debugPrint('OutboxProcessor: Processing ${pendingEntries.length} pending entries');
      
      int successCount = 0;
      int failureCount = 0;

      for (final entry in pendingEntries) {
        final result = await _processEntry(entry);
        
        if (result.success) {
          successCount++;
        } else {
          failureCount++;
        }

        // Emit progress update
        _statusController.add(OutboxStatusUpdate(
          status: OutboxStatusUpdateType.processing,
          currentEntryId: entry.id,
          processedCount: successCount + failureCount,
          totalCount: pendingEntries.length,
        ));
      }

      _statusController.add(OutboxStatusUpdate(
        status: OutboxStatusUpdateType.completed,
        processedCount: pendingEntries.length,
        successCount: successCount,
        failureCount: failureCount,
      ));

      debugPrint('OutboxProcessor: Completed - Success: $successCount, Failures: $failureCount');
    } catch (e) {
      debugPrint('OutboxProcessor: Error processing entries: $e');
      _statusController.add(OutboxStatusUpdate(
        status: OutboxStatusUpdateType.error,
        error: e.toString(),
      ));
    } finally {
      _isProcessing = false;
    }
  }

  /// Get pending entries from the outbox
  Future<List<OutboxEntry>> _getPendingEntries() async {
    final query = _database.select(_database.outboxTable)
      ..where((t) => t.status.equals(OutboxStatus.pending) | t.status.equals(OutboxStatus.failed))
      ..where((t) => t.retryCount.isSmallerThan(_maxRetries))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);

    return query.get();
  }

  /// Process a single outbox entry
  Future<OutboxProcessResult> _processEntry(OutboxEntry entry) async {
    debugPrint('OutboxProcessor: Processing entry ${entry.id} (${entry.operationType} on ${entry.targetTable})');

    try {
      // Mark as syncing
      await _updateEntryStatus(
        entry.id,
        OutboxStatus.syncing,
        lastError: null,
      );

      // Parse the payload
      final payload = jsonDecode(entry.payload);
      
      // Call the appropriate mutation based on table and operation
      final result = await _sendToConvex(
        table: entry.targetTable,
        operation: entry.operationType,
        documentId: entry.documentId,
        payload: payload,
      );

      if (result.success) {
        // Mark as synced
        await _updateEntryStatus(
          entry.id,
          OutboxStatus.synced,
          lastError: null,
        );
        
        debugPrint('OutboxProcessor: Successfully synced entry ${entry.id}');
        return OutboxProcessResult(success: true, convexResponse: result.response);
      } else {
        // Mark as failed
        await _updateEntryStatus(
          entry.id,
          OutboxStatus.failed,
          retryCount: entry.retryCount + 1,
          lastError: result.error,
        );
        
        debugPrint('OutboxProcessor: Failed to sync entry ${entry.id}: ${result.error}');
        return OutboxProcessResult(success: false, error: result.error);
      }
    } catch (e) {
      // Mark as failed
      await _updateEntryStatus(
        entry.id,
        OutboxStatus.failed,
        retryCount: entry.retryCount + 1,
        lastError: e.toString(),
      );

      debugPrint('OutboxProcessor: Exception processing entry ${entry.id}: $e');
      return OutboxProcessResult(success: false, error: e.toString());
    }
  }

  /// Send mutation to Convex based on table and operation
  Future<_ConvexResult> _sendToConvex({
    required String table,
    required String operation,
    required String documentId,
    required Map<String, dynamic> payload,
  }) async {
    final client = _convexConfig.client;
    final ownerId = payload['ownerId'] as String?;

    if (ownerId == null) {
      return _ConvexResult(success: false, error: 'Missing ownerId in payload');
    }

    try {
      // Map table names to mutation names
      final mutationMap = {
        'subscribers': operation == 'delete' ? 'deleteSubscriber' : 'saveSubscriber',
        'cabinets': operation == 'delete' ? 'deleteCabinet' : 'saveCabinet',
        'payments': operation == 'delete' ? 'deletePayment' : 'savePayment',
        'workers': operation == 'delete' ? 'deleteWorker' : 'saveWorker',
        'auditLog': operation == 'delete' ? 'deleteAuditLog' : 'saveAuditLog',
        'generatorSettings': operation == 'delete' ? 'deleteGeneratorSettings' : 'saveGeneratorSettings',
        'whatsappTemplates': operation == 'delete' ? 'deleteWhatsappTemplate' : 'saveWhatsappTemplate',
      };

      final mutationName = mutationMap[table];
      if (mutationName == null) {
        return _ConvexResult(success: false, error: 'Unknown table: $table');
      }

      // Build mutation arguments
      final args = {
        if (operation != 'create') 'id': documentId,
        if (operation == 'delete') ...{
          'id': documentId,
          'version': payload['version'] ?? 0,
          'ownerId': ownerId,
        } else ...{
          ...payload,
          if (operation == 'create') 'id': null,
        },
      };

      // Execute mutation
      final response = await client.mutation(mutationName, args);
      
      // Check response for success
      if (response is Map) {
        final success = response['success'] as bool? ?? false;
        if (!success) {
          return _ConvexResult(
            success: false,
            error: response['reason'] ?? 'Mutation failed',
          );
        }
      }

      return _ConvexResult(success: true, response: response?.toString());
    } catch (e) {
      return _ConvexResult(success: false, error: e.toString());
    }
  }

  /// Update an outbox entry's status
  Future<void> _updateEntryStatus(
    String id,
    String status, {
    int? retryCount,
    String? lastError,
  }) async {
    await (_database.update(_database.outboxTable)
      ..where((t) => t.id.equals(id)))
        .write(OutboxTableCompanion(
          status: Value(status),
          retryCount: retryCount != null ? Value(retryCount) : const Value.absent(),
          lastError: Value(lastError),
          syncedAt: status == OutboxStatus.synced ? Value(DateTime.now()) : const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Manually queue an entry for sync (used by DAOs)
  Future<void> queueForSync({
    required String targetTable,
    required String operationType,
    required String documentId,
    required Map<String, dynamic> payload,
  }) async {
    final entry = OutboxTableCompanion.insert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      targetTable: targetTable,
      operationType: operationType,
      documentId: documentId,
      payload: jsonEncode(payload),
      status: const Value(OutboxStatus.pending),
      createdAt: DateTime.now(),
    );

    await _database.into(_database.outboxTable).insert(entry);
    debugPrint('OutboxProcessor: Queued $operationType on $targetTable:$documentId');
  }

  /// Get count of pending entries
  Future<int> getPendingCount() async {
    final query = _database.select(_database.outboxTable)
      ..where((t) => t.status.equals(OutboxStatus.pending) | t.status.equals(OutboxStatus.failed));
    
    final entries = await query.get();
    return entries.where((e) => e.retryCount < _maxRetries).length;
  }

  /// Get all outbox entries (for debugging)
  Future<List<OutboxEntry>> getAllEntries() async {
    return _database.select(_database.outboxTable).get();
  }

  /// Clear all synced entries (cleanup)
  Future<int> clearSyncedEntries() async {
    final synced = await (_database.delete(_database.outboxTable)
      ..where((t) => t.status.equals(OutboxStatus.synced)))
        .go();
    
    debugPrint('OutboxProcessor: Cleared $synced synced entries');
    return synced;
  }

  /// Dispose resources
  void dispose() {
    stopPeriodicProcessing();
    _statusController.close();
    debugPrint('OutboxProcessor: Disposed');
  }
}

/// Helper class for Convex result
class _ConvexResult {
  final bool success;
  final String? error;
  final String? response;

  const _ConvexResult({
    required this.success,
    this.error,
    this.response,
  });
}

/// Status update types
enum OutboxStatusUpdateType {
  idle,
  processing,
  completed,
  error,
}

/// Status update for stream
class OutboxStatusUpdate {
  final OutboxStatusUpdateType status;
  final String? currentEntryId;
  final int processedCount;
  final int? totalCount;
  final int? successCount;
  final int? failureCount;
  final String? error;

  const OutboxStatusUpdate({
    required this.status,
    this.currentEntryId,
    this.processedCount = 0,
    this.totalCount,
    this.successCount,
    this.failureCount,
    this.error,
  });
}