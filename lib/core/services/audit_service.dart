import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/database_provider.dart';
import '../database/app_database.dart';
import '../auth/auth_provider.dart';

/// Audit action types
enum AuditAction {
  create,
  update,
  delete,
  login,
  logout,
  payment,
  cutConnection,
  restoreConnection,
  export,
  import,
  settingsChange,
}

/// Extension to convert AuditAction to string and get labels
extension AuditActionExtension on AuditAction {
  String get value {
    switch (this) {
      case AuditAction.create:
        return 'create';
      case AuditAction.update:
        return 'update';
      case AuditAction.delete:
        return 'delete';
      case AuditAction.login:
        return 'login';
      case AuditAction.logout:
        return 'logout';
      case AuditAction.payment:
        return 'payment';
      case AuditAction.cutConnection:
        return 'cut_connection';
      case AuditAction.restoreConnection:
        return 'restore_connection';
      case AuditAction.export:
        return 'export';
      case AuditAction.import:
        return 'import';
      case AuditAction.settingsChange:
        return 'settings_change';
    }
  }

  String get arabicLabel {
    switch (this) {
      case AuditAction.create:
        return 'إنشاء';
      case AuditAction.update:
        return 'تحديث';
      case AuditAction.delete:
        return 'حذف';
      case AuditAction.login:
        return 'تسجيل دخول';
      case AuditAction.logout:
        return 'تسجيل خروج';
      case AuditAction.payment:
        return 'دفعة';
      case AuditAction.cutConnection:
        return 'قطع اتصال';
      case AuditAction.restoreConnection:
        return 'إعادة اتصال';
      case AuditAction.export:
        return 'تصدير';
      case AuditAction.import:
        return 'استيراد';
      case AuditAction.settingsChange:
        return 'تغيير إعدادات';
    }
  }

  /// Get icon for the action
  String get iconName {
    switch (this) {
      case AuditAction.create:
        return 'add_circle';
      case AuditAction.update:
        return 'edit';
      case AuditAction.delete:
        return 'delete';
      case AuditAction.login:
        return 'login';
      case AuditAction.logout:
        return 'logout';
      case AuditAction.payment:
        return 'payment';
      case AuditAction.cutConnection:
        return 'link_off';
      case AuditAction.restoreConnection:
        return 'link';
      case AuditAction.export:
        return 'upload_file';
      case AuditAction.import:
        return 'download';
      case AuditAction.settingsChange:
        return 'settings';
    }
  }
}

/// Centralized audit logging service
///
/// This service provides a simple interface for logging audit events
/// throughout the application. It automatically captures the current user
/// and timestamp.
///
/// Usage:
/// ```dart
/// final auditService = ref.read(auditServiceProvider);
/// await auditService.logCreate('مشترك', 'أحمد محمد');
/// await auditService.logPayment('دفعة 15000 دينار');
/// ```
class AuditService {
  final Ref _ref;

  AuditService(this._ref);

  /// Get the current authenticated user's name
  /// Note: AuthState doesn't store user info yet, so we use a default
  String get _currentUser {
    final authState = _ref.read(authStateProvider);
    return authState.isAuthenticated ? 'المستخدم' : 'النظام';
  }

  /// Get current ownerId from auth state
  String? _getCurrentOwnerId() {
    try {
      return _ref.read(currentUserIdProvider);
    } catch (e) {
      return null;
    }
  }

  /// Log an audit entry
  Future<String> log({
    required AuditAction action,
    required String target,
    String? details,
    String? type,
    String? ownerId, // Add ownerId parameter
  }) async {
    try {
      final dao = _ref.read(auditLogDaoProvider);
      
      // Get ownerId from auth if not provided
      final ownerIdToUse = ownerId ?? _getCurrentOwnerId() ?? '';
      final id = const Uuid().v4();
      
      // Create the audit log entry with UUID and ownerId
      final companion = AuditLogTableCompanion(
        id: Value(id),
        ownerId: Value(ownerIdToUse),
        user: Value(_currentUser),
        action: Value(action.value),
        target: Value(target),
        details: Value(details ?? ''),
        type: Value(type ?? 'user'),
      );
      
      return await dao.addAuditLogEntry(companion);
    } catch (e) {
      // Log error but don't throw - audit logging shouldn't break operations
      print('AuditService: Failed to log entry: $e');
      return '-1'; // Return string instead of int for error case
    }
  }

  // ============================================================
  // Convenience methods for common actions
  // ============================================================

  /// Log a create action
  Future<String> logCreate(String entityType, String entityName,
      {String? details}) {
    return log(
      action: AuditAction.create,
      target: '$entityType: $entityName',
      details: details,
    );
  }

  /// Log an update action
  Future<String> logUpdate(String entityType, String entityName,
      {String? details}) {
    return log(
      action: AuditAction.update,
      target: '$entityType: $entityName',
      details: details,
    );
  }

  /// Log a delete action
  Future<String> logDelete(String entityType, String entityName,
      {String? details}) {
    return log(
      action: AuditAction.delete,
      target: '$entityType: $entityName',
      details: details,
    );
  }

  /// Log a payment action
  Future<String> logPayment(String details) {
    return log(
      action: AuditAction.payment,
      target: 'دفعة',
      details: details,
    );
  }

  /// Log a cut connection action
  Future<String> logCutConnection(String subscriberName, {String? reason}) {
    return log(
      action: AuditAction.cutConnection,
      target: 'مشترك: $subscriberName',
      details: reason,
    );
  }

  /// Log a restore connection action
  Future<String> logRestoreConnection(String subscriberName) {
    return log(
      action: AuditAction.restoreConnection,
      target: 'مشترك: $subscriberName',
    );
  }

  /// Log a login action
  Future<String> logLogin(String userName) {
    return log(
      action: AuditAction.login,
      target: 'مستخدم: $userName',
    );
  }

  /// Log a logout action
  Future<String> logLogout(String userName) {
    return log(
      action: AuditAction.logout,
      target: 'مستخدم: $userName',
    );
  }

  /// Log an export action
  Future<String> logExport(String exportType, {String? details}) {
    return log(
      action: AuditAction.export,
      target: 'تصدير: $exportType',
      details: details,
    );
  }

  /// Log an import action
  Future<String> logImport(String importType, {String? details}) {
    return log(
      action: AuditAction.import,
      target: 'استيراد: $importType',
      details: details,
    );
  }

  /// Log a settings change
  Future<String> logSettingsChange(String settingName,
      {String? oldValue, String? newValue}) {
    final details = (oldValue != null && newValue != null)
        ? 'من "$oldValue" إلى "$newValue"'
        : null;
    return log(
      action: AuditAction.settingsChange,
      target: 'إعداد: $settingName',
      details: details,
    );
  }

  // ============================================================
  // Query methods
  // ============================================================

  /// Get recent audit entries
  Future<List<AuditLogEntry>> getRecentEntries({int count = 10}) async {
    try {
      final dao = _ref.read(auditLogDaoProvider);
      final ownerId = _getCurrentOwnerId() ?? '';
      final entries = await dao.getAllAuditLogEntries(ownerId: ownerId);
      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return entries.take(count).toList();
    } catch (e) {
      print('AuditService: Failed to get recent entries: $e');
      return [];
    }
  }

  /// Get entries by action type
  Future<List<AuditLogEntry>> getEntriesByAction(AuditAction action) async {
    try {
      final dao = _ref.read(auditLogDaoProvider);
      final ownerId = _getCurrentOwnerId() ?? '';
      final entries = await dao.getAllAuditLogEntries(ownerId: ownerId);
      return entries.where((e) => e.action == action.value).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      print('AuditService: Failed to get entries by action: $e');
      return [];
    }
  }

  /// Get entries by user
  Future<List<AuditLogEntry>> getEntriesByUser(String userName) async {
    try {
      final dao = _ref.read(auditLogDaoProvider);
      final ownerId = _getCurrentOwnerId() ?? '';
      final entries = await dao.getAllAuditLogEntries(ownerId: ownerId);
      return entries.where((e) => e.user == userName).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      print('AuditService: Failed to get entries by user: $e');
      return [];
    }
  }

  /// Get entries within a date range
  Future<List<AuditLogEntry>> getEntriesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final dao = _ref.read(auditLogDaoProvider);
      final ownerId = _getCurrentOwnerId() ?? '';
      final entries = await dao.getAllAuditLogEntries(ownerId: ownerId);
      return entries
          .where((e) => e.timestamp.isAfter(start) && e.timestamp.isBefore(end))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      print('AuditService: Failed to get entries by date range: $e');
      return [];
    }
  }

  /// Clean up old audit entries
  Future<int> cleanupOldEntries({int daysOld = 90}) async {
    try {
      final dao = _ref.read(auditLogDaoProvider);
      final ownerId = _getCurrentOwnerId() ?? '';
      final entries = await dao.getAllAuditLogEntries(ownerId: ownerId);
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));

      int deletedCount = 0;
      for (var entry in entries) {
        if (entry.timestamp.isBefore(cutoffDate)) {
          await dao.deleteAuditLogEntry(entry.id);
          deletedCount++;
        }
      }
      return deletedCount;
    } catch (e) {
      print('AuditService: Failed to cleanup old entries: $e');
      return 0;
    }
  }
}

/// Provider for AuditService
final auditServiceProvider = Provider<AuditService>((ref) {
  return AuditService(ref);
});
