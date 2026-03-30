import 'package:drift/drift.dart';
import '../app_database.dart';

part 'audit_log_dao.g.dart';

@DriftAccessor(tables: [AuditLogTable])
class AuditLogDao extends DatabaseAccessor<AppDatabase>
    with _$AuditLogDaoMixin {
  AuditLogDao(super.db);

  // Get all audit log entries
  Future<List<AuditLogEntry>> getAllAuditLogEntries() => select(auditLogTable).get();

  // Get audit log entry by ID
  Future<AuditLogEntry?> getAuditLogEntryById(int id) async {
    return await (select(auditLogTable)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  // Add a new audit log entry
  Future<int> addAuditLogEntry(Insertable<AuditLogEntry> entry) {
    return into(auditLogTable).insert(entry);
  }

  // Update an audit log entry
  Future<bool> updateAuditLogEntry(Insertable<AuditLogEntry> entry) {
    return update(auditLogTable).replace(entry);
  }

  // Delete an audit log entry
  Future<int> deleteAuditLogEntry(int id) {
    return (delete(auditLogTable)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Get dirty audit log entries (those with dirtyFlag = true)
  Future<List<AuditLogEntry>> getDirtyAuditLogEntries() {
    return (select(auditLogTable)..where((tbl) => tbl.dirtyFlag.equals(true))).get();
  }
  
  // Update sync status for an audit log entry
  Future<int> updateSyncStatus(int id, String status) {
    return (update(auditLogTable)..where((tbl) => tbl.id.equals(id)))
        .write(AuditLogTableCompanion(syncStatus: Value(status)));
  }
  
  // Mark an audit log entry as dirty (needing sync)
  Future<int> markRecordAsDirty(int id) {
    return (update(auditLogTable)..where((tbl) => tbl.id.equals(id)))
        .write(const AuditLogTableCompanion(
          dirtyFlag: Value(true),
          lastModified: Value.absent(), // This will use the default timestamp
        ));
  }
  
  // Clear dirty flag for an audit log entry
  Future<int> clearDirtyFlag(int id) {
    return (update(auditLogTable)..where((tbl) => tbl.id.equals(id)))
        .write(const AuditLogTableCompanion(dirtyFlag: Value(false)));
  }
  
  // Mark an audit log entry for manual conflict resolution
  Future<int> markConflictForManualResolution(int id) {
    return (update(auditLogTable)..where((tbl) => tbl.id.equals(id)))
        .write(AuditLogTableCompanion(
          conflictResolutionStrategy: Value('manual'),
          conflictDetectedAt: Value(DateTime.now()),
        ));
  }
  
  // Update conflict resolution information
  Future<int> updateConflictResolution(int id, {
    String? conflictResolutionStrategy,
    DateTime? conflictResolvedAt,
    String? conflictOrigin,
  }) {
    return (update(auditLogTable)..where((tbl) => tbl.id.equals(id)))
        .write(AuditLogTableCompanion(
          conflictResolutionStrategy: Value(conflictResolutionStrategy),
          conflictResolvedAt: Value(conflictResolvedAt),
          conflictOrigin: Value(conflictOrigin),
        ));
  }
  
  // Mark record as deleted locally
  Future<int> markDeletedLocally(int id) {
    return (update(auditLogTable)..where((tbl) => tbl.id.equals(id)))
        .write(AuditLogTableCompanion(
          deletedLocally: Value(true),
          dirtyFlag: Value(true),
          lastModified: Value(DateTime.now()),
        ));
  }
  
  // Undelete a record
  Future<int> undeleteRecord(int id) {
    return (update(auditLogTable)..where((tbl) => tbl.id.equals(id)))
        .write(AuditLogTableCompanion(
          deletedLocally: Value(false),
          dirtyFlag: Value(true),
          lastModified: Value(DateTime.now()),
        ));
  }
  
  // Update sync error information
  Future<int> updateSyncError(int id, String errorMessage) {
    return (update(auditLogTable)..where((tbl) => tbl.id.equals(id)))
        .write(AuditLogTableCompanion(
          lastSyncError: Value(errorMessage),
          syncRetryCount: Value.absent(), // Increment retry count in service layer
        ));
  }
  
  // Increment sync retry count
  Future<int> incrementSyncRetryCount(int id) {
    return (update(auditLogTable)..where((tbl) => tbl.id.equals(id)))
        .write(const AuditLogTableCompanion(
          syncRetryCount: Value.absent(), // This will need to be handled in service layer
        ));
  }
}