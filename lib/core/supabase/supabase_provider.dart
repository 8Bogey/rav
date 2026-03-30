import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/database/database_provider.dart';
import 'sync_conflict.dart';
import 'supabase_service.dart';

/// Provider for Supabase service
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  final database = ref.watch(databaseProvider);
  return SupabaseService(database: database);
});

/// State for sync operations
class SyncState {
  final bool isSyncing;
  final String? errorMessage;
  final DateTime? lastSyncTime;
  final int lastConflictCount;
  final int manualConflictAttentionCount;
  final String? lastConflictSummaryAr;

  const SyncState({
    this.isSyncing = false,
    this.errorMessage,
    this.lastSyncTime,
    this.lastConflictCount = 0,
    this.manualConflictAttentionCount = 0,
    this.lastConflictSummaryAr,
  });

  SyncState copyWith({
    bool? isSyncing,
    String? errorMessage,
    DateTime? lastSyncTime,
    int? lastConflictCount,
    int? manualConflictAttentionCount,
    String? lastConflictSummaryAr,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      errorMessage: errorMessage,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastConflictCount: lastConflictCount ?? this.lastConflictCount,
      manualConflictAttentionCount:
          manualConflictAttentionCount ?? this.manualConflictAttentionCount,
      lastConflictSummaryAr: lastConflictSummaryAr ?? this.lastConflictSummaryAr,
    );
  }
}

/// Notifier for managing sync state
class SyncNotifier extends StateNotifier<SyncState> {
  final Ref _ref;

  SyncNotifier(this._ref) : super(const SyncState());

  /// Sync local data to cloud
  Future<void> syncToCloud() async {
    state = state.copyWith(isSyncing: true, errorMessage: null);

    try {
      final supabaseService = _ref.read(supabaseServiceProvider);
      await supabaseService.syncLocalToCloud();
      
      state = state.copyWith(
        isSyncing: false,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Sync cloud data to local
  Future<void> syncFromCloud() async {
    state = state.copyWith(isSyncing: true, errorMessage: null);

    try {
      final supabaseService = _ref.read(supabaseServiceProvider);
      await supabaseService.syncCloudToLocal();
      
      state = state.copyWith(
        isSyncing: false,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Perform bidirectional sync
  Future<void> syncBothDirections() async {
    state = state.copyWith(isSyncing: true, errorMessage: null);

    try {
      final supabaseService = _ref.read(supabaseServiceProvider);
      await supabaseService.syncBidirectional();

      final conflicts = supabaseService.lastSyncConflicts;
      final manual = conflicts.where((c) {
        return c.recommendedResolutionStrategy ==
                ConflictResolutionStrategy.manualResolution ||
            c.conflictType == ConflictType.businessRuleViolation;
      }).length;

      state = state.copyWith(
        isSyncing: false,
        lastSyncTime: DateTime.now(),
        lastConflictCount: conflicts.length,
        manualConflictAttentionCount: manual,
        lastConflictSummaryAr: summarizeSyncConflictsAr(conflicts),
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }
}

/// Provider for sync state
final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier(ref);
});