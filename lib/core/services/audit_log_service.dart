import 'package:drift/drift.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/database/daos/audit_log_dao.dart';
import 'package:mawlid_al_dhaki/core/services/base_service.dart';

class AuditLogService extends BaseService {
  late AuditLogDao _dao;

  AuditLogService(AppDatabase database) : super(database) {
    _dao = AuditLogDao(database);
  }

  // Get all audit log entries
  Future<List<AuditLogEntry>> getAllAuditLogEntries() {
    return _dao.getAllAuditLogEntries();
  }

  // Get audit log entry by ID
  Future<AuditLogEntry?> getAuditLogEntryById(int id) {
    return _dao.getAuditLogEntryById(id);
  }

  // Add a new audit log entry
  Future<int> addAuditLogEntry(AuditLogEntry entry) {
    // For inserts, we want to let the database auto-generate the ID
    final companion = AuditLogTableCompanion(
      user: Value(entry.user),
      action: Value(entry.action),
      target: Value(entry.target),
      details: Value(entry.details),
      type: Value(entry.type),
      timestamp: Value(entry.timestamp),
    );
    return _dao.addAuditLogEntry(companion);
  }

  // Update an audit log entry
  Future<bool> updateAuditLogEntry(AuditLogEntry entry) {
    final companion = entry.toCompanion(false);
    return _dao.updateAuditLogEntry(companion);
  }

  // Delete an audit log entry
  Future<int> deleteAuditLogEntry(int id) {
    return _dao.deleteAuditLogEntry(id);
  }

  // Get dirty audit log entries (those with dirtyFlag = true)
  Future<List<AuditLogEntry>> getDirtyAuditLogEntries() {
    return _dao.getDirtyAuditLogEntries();
  }
  
  // Mark an audit log entry for manual conflict resolution
  Future<int> markConflictForManualResolution(int id) {
    return _dao.markConflictForManualResolution(id);
  }
  
  // Update conflict resolution information
  Future<int> updateConflictResolution(int id, {
    String? conflictResolutionStrategy,
    DateTime? conflictResolvedAt,
    String? conflictOrigin,
  }) {
    return _dao.updateConflictResolution(
      id,
      conflictResolutionStrategy: conflictResolutionStrategy,
      conflictResolvedAt: conflictResolvedAt,
      conflictOrigin: conflictOrigin,
    );
  }
  
  // Mark record as deleted locally
  Future<int> markDeletedLocally(int id) {
    return _dao.markDeletedLocally(id);
  }
  
  // Undelete a record
  Future<int> undeleteRecord(int id) {
    return _dao.undeleteRecord(id);
  }
  
  // Update sync error information
  Future<int> updateSyncError(int id, String errorMessage) {
    return _dao.updateSyncError(id, errorMessage);
  }
  
  // Increment sync retry count
  Future<int> incrementSyncRetryCount(int id) {
    return _dao.incrementSyncRetryCount(id);
  }
  
  // Update sync status
  Future<int> updateSyncStatus(int id, String status) {
    return _dao.updateSyncStatus(id, status);
  }
  
  // Mark record as dirty
  Future<int> markRecordAsDirty(int id) {
    return _dao.markRecordAsDirty(id);
  }
  
  // Clear dirty flag
  Future<int> clearDirtyFlag(int id) {
    return _dao.clearDirtyFlag(id);
  }
}