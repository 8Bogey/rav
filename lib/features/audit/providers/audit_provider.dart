import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/service_providers.dart';

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

/// Extension to convert AuditAction to string
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
}

/// State for audit log
class AuditLogState {
  final List<AuditLogEntry> entries;
  final bool isLoading;
  final String? error;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final String? filterAction;
  final String? filterUser;

  const AuditLogState({
    this.entries = const [],
    this.isLoading = false,
    this.error,
    this.filterStartDate,
    this.filterEndDate,
    this.filterAction,
    this.filterUser,
  });

  AuditLogState copyWith({
    List<AuditLogEntry>? entries,
    bool? isLoading,
    String? error,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    String? filterAction,
    String? filterUser,
    bool clearError = false,
    bool clearFilters = false,
  }) {
    return AuditLogState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      filterStartDate:
          clearFilters ? null : (filterStartDate ?? this.filterStartDate),
      filterEndDate:
          clearFilters ? null : (filterEndDate ?? this.filterEndDate),
      filterAction: clearFilters ? null : (filterAction ?? this.filterAction),
      filterUser: clearFilters ? null : (filterUser ?? this.filterUser),
    );
  }
}

/// Notifier for managing audit log state
/// 
/// This notifier now uses AuditLogService instead of directly accessing DAOs
/// to provide a consistent service layer for all database operations.
class AuditLogNotifier extends StateNotifier<AuditLogState> {
  final Ref _ref;
  late AuditLogService _service;

  AuditLogNotifier(this._ref) : super(const AuditLogState()) {
    _service = _ref.read(auditLogServiceProvider);
    loadAuditLog();
  }

  /// Load all audit log entries from database
  Future<void> loadAuditLog() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      var entries = await _service.getAllAuditLogEntries();

      // Apply filters
      if (state.filterStartDate != null) {
        entries = entries
            .where((e) => e.timestamp.isAfter(state.filterStartDate!))
            .toList();
      }

      if (state.filterEndDate != null) {
        entries = entries
            .where((e) => e.timestamp.isBefore(state.filterEndDate!))
            .toList();
      }

      if (state.filterAction != null) {
        entries = entries.where((e) => e.action == state.filterAction).toList();
      }

      if (state.filterUser != null) {
        entries =
            entries.where((e) => e.user.contains(state.filterUser!)).toList();
      }

      // Sort by timestamp (newest first)
      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      state = state.copyWith(
        entries: entries,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'فشل تحميل سجل التدقيق: $e',
      );
    }
  }

  /// Filter by date range
  Future<void> filterByDateRange(DateTime? start, DateTime? end) async {
    state = state.copyWith(filterStartDate: start, filterEndDate: end);
    await loadAuditLog();
  }

  /// Filter by action
  Future<void> filterByAction(String? action) async {
    state = state.copyWith(filterAction: action);
    await loadAuditLog();
  }

  /// Filter by user
  Future<void> filterByUser(String? user) async {
    state = state.copyWith(filterUser: user);
    await loadAuditLog();
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    state = state.copyWith(clearFilters: true);
    await loadAuditLog();
  }

  /// Log an action
  Future<int> logAction({
    required String user,
    required AuditAction action,
    required String target,
    String? details,
    String? type,
  }) async {
    try {
      final entry = AuditLogEntry(
        id: 0, // Will be auto-generated
        user: user,
        action: action.value,
        target: target,
        details: details ?? '',
        type: type ?? 'user',
        timestamp: DateTime.now(),
      );
      
      final id = await _service.addAuditLogEntry(entry);

      // Refresh the list
      await loadAuditLog();

      return id;
    } catch (e) {
      print('Failed to log audit entry: $e');
      rethrow;
    }
  }

  /// Get recent activities (last N entries)
  Future<List<AuditLogEntry>> getRecentActivities({int count = 10}) async {
    final entries = await _service.getAllAuditLogEntries();
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries.take(count).toList();
  }

  /// Delete old audit log entries (cleanup)
  Future<void> deleteOldEntries({int daysOld = 90}) async {
    try {
      final entries = await _service.getAllAuditLogEntries();
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));

      for (var entry in entries) {
        if (entry.timestamp.isBefore(cutoffDate)) {
          await _service.deleteAuditLogEntry(entry.id);
        }
      }

      await loadAuditLog();
    } catch (e) {
      state = state.copyWith(error: 'فشل حذف السجلات القديمة: $e');
    }
  }
}

/// Provider for audit log state
final auditLogProvider =
    StateNotifierProvider<AuditLogNotifier, AuditLogState>((ref) {
  return AuditLogNotifier(ref);
});

/// Provider for recent activities
final recentActivitiesProvider =
    FutureProvider<List<AuditLogEntry>>((ref) async {
  final notifier = ref.read(auditLogProvider.notifier);
  return await notifier.getRecentActivities();
});
