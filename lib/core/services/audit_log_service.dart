import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/database/daos/audit_log_dao.dart';
import 'package:mawlid_al_dhaki/core/services/base_service.dart';

class AuditLogService extends BaseService {
  late AuditLogDao _dao;
  final String ownerId; // Add ownerId field
  static const uuid = Uuid(); // UUID generator

  AuditLogService(AppDatabase database, {required this.ownerId}) : super(database) {
    _dao = AuditLogDao(database);
  }

  // Get all audit log entries
  Future<List<AuditLogEntry>> getAllAuditLogEntries() {
    return _dao.getAllAuditLogEntries(ownerId: ownerId);
  }

  // Get audit log entry by ID
  Future<AuditLogEntry?> getAuditLogEntryById(String id) {
    return _dao.getAuditLogEntryById(id, ownerId: ownerId);
  }

  // Add a new audit log entry
  Future<String> addAuditLogEntry(AuditLogEntry entry) {
    // For inserts, generate a UUID and add ownerId
    final companion = AuditLogTableCompanion(
      id: Value(uuid.v4()), // Generate UUID
      ownerId: Value(ownerId), // Add ownerId
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
    final companion = entry.toCompanion(false).copyWith(ownerId: Value(ownerId)); // Add ownerId
    return _dao.updateAuditLogEntry(companion);
  }

  // Delete an audit log entry (soft delete)
  Future<int> deleteAuditLogEntry(String id) {
    return _dao.deleteAuditLogEntry(id);
  }

  // Get dirty audit log entries (those with dirtyFlag = true)
  Future<List<AuditLogEntry>> getDirtyAuditLogEntries() {
    return _dao.getDirtyAuditLogEntries(ownerId: ownerId);
  }
  
  // Mark record as dirty
  Future<int> markRecordAsDirty(String id) {
    return _dao.markRecordAsDirty(id);
  }
  
  // Clear dirty flag
  Future<int> clearDirtyFlag(String id) {
    return _dao.clearDirtyFlag(id);
  }
}