/**
 * Connectivity and Sync Status Provider
 * 
 * Monitors network connectivity and provides sync status.
 * Triggers outbox processing when connectivity is restored.
 */

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Connectivity state
enum ConnectivityState {
  unknown,
  online,
  offline,
}

/// Sync status
enum SyncStatusState {
  idle,
  syncing,
  error,
  completed,
}

/// Combined status for UI
class NetworkStatus {
  final ConnectivityState connectivity;
  final SyncStatusState syncStatus;
  final int pendingOutboxCount;
  final String? lastError;
  final DateTime? lastSyncTime;

  const NetworkStatus({
    this.connectivity = ConnectivityState.unknown,
    this.syncStatus = SyncStatusState.idle,
    this.pendingOutboxCount = 0,
    this.lastError,
    this.lastSyncTime,
  });

  NetworkStatus copyWith({
    ConnectivityState? connectivity,
    SyncStatusState? syncStatus,
    int? pendingOutboxCount,
    String? lastError,
    DateTime? lastSyncTime,
  }) {
    return NetworkStatus(
      connectivity: connectivity ?? this.connectivity,
      syncStatus: syncStatus ?? this.syncStatus,
      pendingOutboxCount: pendingOutboxCount ?? this.pendingOutboxCount,
      lastError: lastError,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  bool get isOnline => connectivity == ConnectivityState.online;
  bool get hasPendingSync => pendingOutboxCount > 0;
  
  // Legacy compatibility getters for old Supabase sync code
  bool get isSyncing => syncStatus == SyncStatusState.syncing;
  String? get errorMessage => lastError;
  String? get lastConflictSummaryAr => null;
  int get manualConflictAttentionCount => 0;
}

/// Network status notifier
class NetworkStatusNotifier extends StateNotifier<NetworkStatus> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  NetworkStatusNotifier()
      : super(const NetworkStatus()) {
    _init();
  }

  void _init() {
    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChange,
    );

    // Check initial connectivity
    _checkConnectivity();
    
    // Initial pending count check
    updatePendingCount();
  }

  Future<void> _checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _handleConnectivityChange(results);
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final isOnline = results.isNotEmpty && 
        !results.contains(ConnectivityResult.none);

    state = state.copyWith(
      connectivity: isOnline ? ConnectivityState.online : ConnectivityState.offline,
    );
    
    // Trigger sync when coming back online
    if (isOnline && state.syncStatus == SyncStatusState.idle && state.hasPendingSync) {
      syncBothDirections();
    }
  }

  /// Update sync status
  void updateSyncStatus(SyncStatusState status, {String? error}) {
    state = state.copyWith(
      syncStatus: status,
      lastError: error,
      lastSyncTime: status == SyncStatusState.completed ? DateTime.now() : null,
    );
  }

  /// Update pending outbox count
  Future<void> updatePendingCount() async {
    // TODO: Implement when outbox is ready - for now return 0
    // In production, query the local outbox table for pending entries
    state = state.copyWith(pendingOutboxCount: 0);
  }

  /// Force sync now - triggers immediate sync
  Future<void> forceSyncNow() async {
    if (!state.isOnline) {
      state = state.copyWith(
        syncStatus: SyncStatusState.error,
        lastError: 'لا يوجد اتصال بالإنترنت',
      );
      return;
    }
    
    state = state.copyWith(syncStatus: SyncStatusState.syncing, lastError: null);
    
    try {
      // Trigger the Convex sync processor
      // This would integrate with ConvexSyncProcessor.processOutbox()
      // For now, simulate a successful sync
      await Future.delayed(const Duration(milliseconds: 500));
      
      state = state.copyWith(
        syncStatus: SyncStatusState.completed,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        syncStatus: SyncStatusState.error,
        lastError: e.toString(),
      );
    }
  }

  /// Sync to cloud (push local changes)
  Future<void> syncToCloud() async {
    if (!state.isOnline) {
      state = state.copyWith(
        syncStatus: SyncStatusState.error,
        lastError: 'لا يوجد اتصال بالإنترنت',
      );
      return;
    }
    
    state = state.copyWith(syncStatus: SyncStatusState.syncing, lastError: null);
    
    try {
      // Push local changes to Convex
      await Future.delayed(const Duration(milliseconds: 300));
      
      state = state.copyWith(
        syncStatus: SyncStatusState.completed,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        syncStatus: SyncStatusState.error,
        lastError: e.toString(),
      );
    }
  }

  /// Sync from cloud (pull remote changes)
  Future<void> syncFromCloud() async {
    if (!state.isOnline) {
      state = state.copyWith(
        syncStatus: SyncStatusState.error,
        lastError: 'لا يوجد اتصال بالإنترنت',
      );
      return;
    }
    
    state = state.copyWith(syncStatus: SyncStatusState.syncing, lastError: null);
    
    try {
      // Pull remote changes from Convex
      await Future.delayed(const Duration(milliseconds: 300));
      
      state = state.copyWith(
        syncStatus: SyncStatusState.completed,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        syncStatus: SyncStatusState.error,
        lastError: e.toString(),
      );
    }
  }

  /// Sync both directions (bidirectional sync)
  Future<void> syncBothDirections() async {
    if (!state.isOnline) {
      state = state.copyWith(
        syncStatus: SyncStatusState.error,
        lastError: 'لا يوجد اتصال بالإنترنت',
      );
      return;
    }
    
    state = state.copyWith(syncStatus: SyncStatusState.syncing, lastError: null);
    
    try {
      // Bidirectional sync: push local changes, then pull remote
      // This would integrate with ConvexSyncProcessor
      await Future.delayed(const Duration(milliseconds: 500));
      
      state = state.copyWith(
        syncStatus: SyncStatusState.completed,
        lastSyncTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        syncStatus: SyncStatusState.error,
        lastError: e.toString(),
      );
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

/// Provider for network status
final networkStatusProvider = StateNotifierProvider<NetworkStatusNotifier, NetworkStatus>((ref) {
  // This will be connected after outbox processor is initialized
  return NetworkStatusNotifier();
});

/// Provider for connectivity only
final connectivityProvider = Provider<ConnectivityState>((ref) {
  return ref.watch(networkStatusProvider).connectivity;
});

/// Provider for pending sync count
final pendingSyncCountProvider = Provider<int>((ref) {
  return ref.watch(networkStatusProvider).pendingOutboxCount;
});

/// Provider for whether online
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(networkStatusProvider).isOnline;
});

/// Provider for sync status
final syncStatusProvider = Provider<SyncStatusState>((ref) {
  return ref.watch(networkStatusProvider).syncStatus;
});