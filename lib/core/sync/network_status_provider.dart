/**
 * Connectivity and Sync Status Provider
 * 
 * Monitors network connectivity and provides sync status.
 * Triggers outbox processing when connectivity is restored.
 */

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
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
    // TODO: Implement when outbox is ready
    state = state.copyWith(pendingOutboxCount: 0);
  }

  /// Force sync now
  Future<void> forceSyncNow() async {
    // TODO: Implement when outbox is ready
    state = state.copyWith(syncStatus: SyncStatusState.completed);
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