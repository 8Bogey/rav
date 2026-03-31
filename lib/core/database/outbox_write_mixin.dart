/**
 * Outbox Write Helper Mixin
 * 
 * Provides methods to write to both the main table and Outbox table
 * in a single database transaction.
 * 
 * Following MINIMAX_IMPLEMENTATION_GUIDE.md patterns.
 */

import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';

/// Mixin to add outbox write capability to DAOs
mixin OutboxWriteMixin<T extends DatabaseAccessor<AppDatabase>> on DatabaseAccessor<AppDatabase> {
  
  /// Write to main table and queue to outbox in single transaction
  Future<void> writeWithOutbox({
    required String tableName,
    required Insertable<dynamic> data,
    required String operationType,
  }) async {
    await transaction(() async {
      // 1. Write to main table
      switch (tableName) {
        case 'subscribers':
          await into((this as dynamic).db.subscribersTable).insertOnConflictUpdate(data);
          break;
        case 'cabinets':
          await into((this as dynamic).db.cabinetsTable).insertOnConflictUpdate(data);
          break;
        case 'payments':
          await into((this as dynamic).db.paymentsTable).insertOnConflictUpdate(data);
          break;
        case 'workers':
          await into((this as dynamic).db.workersTable).insertOnConflictUpdate(data);
          break;
        case 'auditLog':
          await into((this as dynamic).db.auditLogTable).insertOnConflictUpdate(data);
          break;
        case 'generatorSettings':
          await into((this as dynamic).db.generatorSettingsTable).insertOnConflictUpdate(data);
          break;
        case 'whatsappTemplates':
          await into((this as dynamic).db.whatsappTemplatesTable).insertOnConflictUpdate(data);
          break;
      }
      
      // 2. Extract ID and ownerId from data
      final dataMap = data.toColumns();
      final id = dataMap['id'] as String? ?? '';
      final ownerId = dataMap['ownerId'] as String? ?? '';
      
      // 3. Queue to outbox
      final outboxEntry = OutboxTableCompanion.insert(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        targetTable: tableName,
        operationType: operationType,
        documentId: id,
        payload: jsonEncode(dataMap),
        status: const Value('pending'),
        createdAt: DateTime.now(),
      );
      
      await into((this as dynamic).db.outboxTable).insert(outboxEntry);
    });
  }
  
  /// Soft delete with outbox in single transaction
  Future<void> softDeleteWithOutbox({
    required String tableName,
    required String id,
    required String ownerId,
  }) async {
    await transaction(() async {
      // 1. Soft delete from main table
      switch (tableName) {
        case 'subscribers':
          await (update((this as dynamic).db.subscribersTable)
            ..where((t) => t.id.equals(id)))
              .write(SubscribersTableCompanion(
                isDeleted: const Value(true),
                updatedAt: Value(DateTime.now()),
              ));
          break;
        case 'cabinets':
          await (update((this as dynamic).db.cabinetsTable)
            ..where((t) => t.id.equals(id)))
              .write(CabinetsTableCompanion(
                isDeleted: const Value(true),
                updatedAt: Value(DateTime.now()),
              ));
          break;
        case 'payments':
          await (update((this as dynamic).db.paymentsTable)
            ..where((t) => t.id.equals(id)))
              .write(PaymentsTableCompanion(
                isDeleted: const Value(true),
                updatedAt: Value(DateTime.now()),
              ));
          break;
        case 'workers':
          await (update((this as dynamic).db.workersTable)
            ..where((t) => t.id.equals(id)))
              .write(WorkersTableCompanion(
                isDeleted: const Value(true),
                updatedAt: Value(DateTime.now()),
              ));
          break;
        case 'auditLog':
          await (update((this as dynamic).db.auditLogTable)
            ..where((t) => t.id.equals(id)))
              .write(AuditLogTableCompanion(
                isDeleted: const Value(true),
                updatedAt: Value(DateTime.now()),
              ));
          break;
        case 'generatorSettings':
          await (update((this as dynamic).db.generatorSettingsTable)
            ..where((t) => t.id.equals(id)))
              .write(GeneratorSettingsTableCompanion(
                isDeleted: const Value(true),
                updatedAt: Value(DateTime.now()),
              ));
          break;
        case 'whatsappTemplates':
          await (update((this as dynamic).db.whatsappTemplatesTable)
            ..where((t) => t.id.equals(id)))
              .write(WhatsappTemplatesTableCompanion(
                isDeleted: const Value(true),
                updatedAt: Value(DateTime.now()),
              ));
          break;
      }
      
      // 2. Queue delete to outbox
      final outboxEntry = OutboxTableCompanion.insert(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        targetTable: tableName,
        operationType: 'delete',
        documentId: id,
        payload: jsonEncode({'id': id, 'ownerId': ownerId}),
        status: const Value('pending'),
        createdAt: DateTime.now(),
      );
      
      await into((this as dynamic).db.outboxTable).insert(outboxEntry);
    });
  }
}