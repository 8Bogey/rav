import 'package:drift/drift.dart';
import '../app_database.dart';

part 'audit_log_dao.g.dart';

@DriftAccessor(tables: [AuditLogTable])
class AuditLogDao extends DatabaseAccessor<AppDatabase>
    with _$AuditLogDaoMixin {
  AuditLogDao(super.db);

  // Get all active audit log entries - uses composite index (by_ownerId_inTrash)
  Future<List<AuditLogEntry>> getAllAuditLogEntries({required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);

    return (select(auditLogTable)
          ..where((t) => t.ownerId.equals(ownerId) & t.inTrash.equals(false)))
        .get();
  }

  // Watch all active audit log entries - uses composite index (by_ownerId_inTrash)
  Stream<List<AuditLogEntry>> watchAllAuditLogEntries(
      {required String ownerId}) {
    if (ownerId.isEmpty) return Stream.value([]);

    return (select(auditLogTable)
          ..where((t) => t.ownerId.equals(ownerId) & t.inTrash.equals(false)))
        .watch();
  }

  // Get audit log entry by ID (UUID) - REQUIRES ownerId
  Future<AuditLogEntry?> getAuditLogEntryById(String id,
      {required String ownerId}) async {
    if (ownerId.isEmpty) return null;

    return await (select(auditLogTable)
          ..where((tbl) => tbl.id.equals(id))
          ..where((tbl) => tbl.ownerId.equals(ownerId)))
        .getSingleOrNull();
  }

  // Get audit log entries by user - uses composite index (by_ownerId_user)
  Future<List<AuditLogEntry>> getAuditLogsByUser(String user,
      {required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);

    return (select(auditLogTable)
          ..where((t) => t.ownerId.equals(ownerId) & t.user.equals(user)))
        .get();
  }

  // Get audit log entries by target - uses composite index (by_ownerId_target)
  Future<List<AuditLogEntry>> getAuditLogsByTarget(String target,
      {required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);

    return (select(auditLogTable)
          ..where((t) => t.ownerId.equals(ownerId) & t.target.equals(target)))
        .get();
  }

  // Get audit log entries by action type - uses composite index (by_ownerId_action)
  Future<List<AuditLogEntry>> getAuditLogsByAction(String action,
      {required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);

    return (select(auditLogTable)
          ..where((t) => t.ownerId.equals(ownerId) & t.action.equals(action)))
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
      inTrash: Value(true),
    ));
  }

  // Hard delete
  Future<int> hardDeleteAuditLogEntry(String id) {
    return (delete(auditLogTable)..where((tbl) => tbl.id.equals(id))).go();
  }

  // NOTE: dirtyFlag, lastSyncedAt, syncStatus, cloudId, deletedLocally,
  // permissionsMask, lastModified fields removed from schema.
  // Sync-related DAO methods (getDirtyAuditLogEntries, markRecordAsDirty,
  // clearDirtyFlag, updateLastSyncedAt) have been removed.

  // Get audit log entries by date range - uses composite index prefix
  Future<List<AuditLogEntry>> getAuditLogsByDateRange(
      DateTime start, DateTime end,
      {required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);

    return (select(auditLogTable)
          ..where((t) =>
              t.ownerId.equals(ownerId) &
              t.timestamp.isBiggerOrEqualValue(start) &
              t.timestamp.isSmallerOrEqualValue(end)))
        .get();
  }

  // Count audit log entries - REQUIRES ownerId
  Future<int> countAuditLogEntries(
      {required String ownerId, DateTime? startDate, DateTime? endDate}) async {
    if (ownerId.isEmpty) return 0;

    var query = selectOnly(auditLogTable)
      ..addColumns([auditLogTable.id.count()])
      ..where(auditLogTable.ownerId.equals(ownerId))
      ..where(auditLogTable.inTrash.equals(false));

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
