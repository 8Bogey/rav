import 'package:drift/drift.dart';
import '../app_database.dart';

part 'audit_log_dao.g.dart';

@DriftAccessor(tables: [AuditLogTable])
class AuditLogDao extends DatabaseAccessor<AppDatabase>
    with _$AuditLogDaoMixin {
  AuditLogDao(super.db);

  // Get all active audit log entries - REQUIRES ownerId
  Future<List<AuditLogEntry>> getAllAuditLogEntries({required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);
    
    return (select(auditLogTable)
      ..where((tbl) => tbl.ownerId.equals(ownerId))
      ..where((tbl) => tbl.isDeleted.equals(false)))
        .get();
  }

  // Watch all active audit log entries - REQUIRES ownerId
  Stream<List<AuditLogEntry>> watchAllAuditLogEntries({required String ownerId}) {
    if (ownerId.isEmpty) return Stream.value([]);
    
    return (select(auditLogTable)
      ..where((tbl) => tbl.ownerId.equals(ownerId))
      ..where((tbl) => tbl.isDeleted.equals(false)))
        .watch();
  }

  // Get audit log entry by ID (UUID) - REQUIRES ownerId
  Future<AuditLogEntry?> getAuditLogEntryById(String id, {required String ownerId}) async {
    if (ownerId.isEmpty) return null;
    
    return await (select(auditLogTable)
      ..where((tbl) => tbl.id.equals(id))
      ..where((tbl) => tbl.ownerId.equals(ownerId)))
        .getSingleOrNull();
  }

  // Get audit log entries by user - REQUIRES ownerId
  Future<List<AuditLogEntry>> getAuditLogByUser(String user, {required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);
    
    return (select(auditLogTable)
      ..where((tbl) => tbl.ownerId.equals(ownerId))
      ..where((tbl) => tbl.user.equals(user)))
        .get();
  }

  // Get audit log entries by target - REQUIRES ownerId
  Future<List<AuditLogEntry>> getAuditLogByTarget(String target, {required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);
    
    return (select(auditLogTable)
      ..where((tbl) => tbl.ownerId.equals(ownerId))
      ..where((tbl) => tbl.target.equals(target)))
        .get();
  }

  // Get audit log entries by action type - REQUIRES ownerId
  Future<List<AuditLogEntry>> getAuditLogByAction(String action, {required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);
    
    return (select(auditLogTable)
      ..where((tbl) => tbl.ownerId.equals(ownerId))
      ..where((tbl) => tbl.action.equals(action)))
        .get();
  }

  // Add a new audit log entry
  Future<String> addAuditLogEntry(Insertable<AuditLogEntry> entry) async {
    return await into(auditLogTable).insert(entry).then((_) {
      final comp = entry as AuditLogTableCompanion;
      return comp.id.value;
    });
  }

  // Insert audit log entry and return ID
  Future<String> insertAuditLogEntry(Insertable<AuditLogEntry> entry) async {
    return await into(auditLogTable).insert(entry).then((_) {
      final comp = entry as AuditLogTableCompanion;
      return comp.id.value;
    });
  }

  // Update an audit log entry
  Future<bool> updateAuditLogEntry(Insertable<AuditLogEntry> entry) {
    return update(auditLogTable).replace(entry);
  }

  // Soft delete an audit log entry
  Future<int> deleteAuditLogEntry(String id) {
    return (update(auditLogTable)..where((tbl) => tbl.id.equals(id)))
        .write(const AuditLogTableCompanion(
          isDeleted: Value(true),
        ));
  }

  // Hard delete
  Future<int> hardDeleteAuditLogEntry(String id) {
    return (delete(auditLogTable)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Get dirty audit log entries - REQUIRES ownerId
  Future<List<AuditLogEntry>> getDirtyAuditLogEntries({required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);
    
    return (select(auditLogTable)
      ..where((tbl) => tbl.ownerId.equals(ownerId))
      ..where((tbl) => tbl.dirtyFlag.equals(true)))
        .get();
  }

  // Mark an audit log entry as dirty
  Future<int> markRecordAsDirty(String id) {
    return (update(auditLogTable)..where((tbl) => tbl.id.equals(id)))
        .write(AuditLogTableCompanion(
          dirtyFlag: const Value(true),
          updatedAt: Value(DateTime.now()),
        ));
  }

  // Clear dirty flag
  Future<int> clearDirtyFlag(String id) {
    return (update(auditLogTable)..where((tbl) => tbl.id.equals(id)))
        .write(const AuditLogTableCompanion(dirtyFlag: Value(false)));
  }

  // Update last synced timestamp
  Future<int> updateLastSyncedAt(String id) {
    return (update(auditLogTable)..where((tbl) => tbl.id.equals(id)))
        .write(AuditLogTableCompanion(
          lastSyncedAt: Value(DateTime.now()),
        ));
  }
  
  // Get audit log entries by date range - REQUIRES ownerId
  Future<List<AuditLogEntry>> getAuditLogByDateRange(DateTime start, DateTime end, {required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);
    
    return (select(auditLogTable)
      ..where((tbl) => tbl.ownerId.equals(ownerId))
      ..where((tbl) => tbl.timestamp.isBiggerOrEqualValue(start))
      ..where((tbl) => tbl.timestamp.isSmallerOrEqualValue(end)))
        .get();
  }
  
  // Count audit log entries - REQUIRES ownerId
  Future<int> countAuditLogEntries({required String ownerId, DateTime? startDate, DateTime? endDate}) async {
    if (ownerId.isEmpty) return 0;
    
    var query = selectOnly(auditLogTable)
      ..addColumns([auditLogTable.id.count()])
      ..where(auditLogTable.ownerId.equals(ownerId))
      ..where(auditLogTable.isDeleted.equals(false));
    
    if (startDate != null) {
      query.where(auditLogTable.timestamp.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where(auditLogTable.timestamp.isSmallerOrEqualValue(endDate));
    }
    
    final result = await query.getSingle();
    return result.read(auditLogTable.id.count()) ?? 0;
  }
}