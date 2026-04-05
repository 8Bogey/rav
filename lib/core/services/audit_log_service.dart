import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/database/daos/audit_log_dao.dart';
import 'package:mawlid_al_dhaki/core/services/base_service.dart';
import 'package:mawlid_al_dhaki/core/services/outbox_service.dart';

class AuditLogService extends BaseService {
  late AuditLogDao _dao;
  late final OutboxService _outbox;
  final String ownerId; // Add ownerId field
  static const uuid = Uuid(); // UUID generator

  AuditLogService(AppDatabase database, {required this.ownerId})
      : super(database) {
    _dao = AuditLogDao(database);
    _outbox = OutboxService(database);
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
    final id = uuid.v4();
    final now = DateTime.now();
    final companion = AuditLogTableCompanion(
      id: Value(id), // Generate UUID
      ownerId: Value(ownerId), // Add ownerId
      user: Value(entry.user),
      action: Value(entry.action),
      target: Value(entry.target),
      details: Value(entry.details),
      type: Value(entry.type),
      timestamp: Value(entry.timestamp),
      version: const Value(1),
      inTrash: const Value(false),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    // Add to outbox for Convex sync
    _outbox.addEntry(
      targetTable: 'auditLog',
      operationType: 'create',
      documentId: id,
      payload: {
        'id': id,
        'ownerId': ownerId,
        'user': entry.user,
        'action': entry.action,
        'target': entry.target,
        'details': entry.details,
        'type': entry.type,
        'timestamp': entry.timestamp.millisecondsSinceEpoch,
        'version': 1,
        'inTrash': false,
        'updatedAt': now.millisecondsSinceEpoch,
        'createdAt': now.millisecondsSinceEpoch,
      },
    );

    return _dao.addAuditLogEntry(companion);
  }

  // Update an audit log entry
  Future<bool> updateAuditLogEntry(AuditLogEntry entry) {
    final companion = entry
        .toCompanion(false)
        .copyWith(ownerId: Value(ownerId)); // Add ownerId
    return _dao.updateAuditLogEntry(companion);
  }

  // Delete an audit log entry (soft delete)
  Future<int> deleteAuditLogEntry(String id) {
    return _dao.deleteAuditLogEntry(id);
  }
}
