import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:uuid/uuid.dart';

/// Service for managing the outbox table and syncing to Convex
class OutboxService {
  final AppDatabase database;
  static const _uuid = Uuid();

  OutboxService(this.database);

  /// Add an entry to the outbox for sync to Convex
  Future<void> addEntry({
    required String targetTable,
    required String operationType, // 'create', 'update', 'delete'
    required String documentId,
    required Map<String, dynamic> payload,
  }) async {
    final entry = OutboxTableCompanion(
      id: Value(_uuid.v4()),
      targetTable: Value(targetTable),
      operationType: Value(operationType),
      documentId: Value(documentId),
      payload: Value(jsonEncode(payload)),
      status: const Value('pending'),
      retryCount: const Value(0),
      createdAt: Value(DateTime.now()),
    );

    await database.into(database.outboxTable).insert(entry);
    debugPrint('[Outbox] Added entry: $targetTable/$operationType for document: $documentId');
  }

  /// Get all pending outbox entries
  Future<List<OutboxEntry>> getPendingEntries() async {
    return (database.select(database.outboxTable)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Get count of pending entries
  Future<int> getPendingCount() async {
    final entries = await getPendingEntries();
    return entries.length;
  }

  /// Mark an entry as synced
  Future<void> markSynced(String id) async {
    await (database.update(database.outboxTable)..where((t) => t.id.equals(id)))
        .write(OutboxTableCompanion(
      status: const Value('synced'),
      syncedAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Mark an entry as failed
  Future<void> markFailed(String id, String error, int retryCount) async {
    final status = retryCount > 5 ? 'failed' : 'pending';
    await (database.update(database.outboxTable)..where((t) => t.id.equals(id)))
        .write(OutboxTableCompanion(
      status: Value(status),
      retryCount: Value(retryCount),
      lastError: Value(error),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Mark an entry as syncing
  Future<void> markSyncing(String id) async {
    await (database.update(database.outboxTable)..where((t) => t.id.equals(id)))
        .write(OutboxTableCompanion(
      status: const Value('syncing'),
      updatedAt: Value(DateTime.now()),
    ));
  }
}