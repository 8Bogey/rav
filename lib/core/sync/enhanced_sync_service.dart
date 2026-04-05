import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mawlid_al_dhaki/core/convex/convex_config.dart';
import 'package:mawlid_al_dhaki/core/sync/convex_sync_processor.dart';
import 'package:mawlid_al_dhaki/core/sync/convex_down_sync_service.dart';
import 'package:mawlid_al_dhaki/features/auth/providers/auth_provider.dart';

/// Network connectivity state
enum NetworkState {
  online,
  offline,
  syncing,
}

/// Sync status for UI display
class SyncStatus {
  final NetworkState networkState;
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final int pendingChanges;
  final String? errorMessage;

  SyncStatus({
    required this.networkState,
    this.isSyncing = false,
    this.lastSyncTime,
    this.pendingChanges = 0,
    this.errorMessage,
  });

  factory SyncStatus.initial() =>
      SyncStatus(networkState: NetworkState.offline);

  SyncStatus copyWith({
    NetworkState? networkState,
    bool? isSyncing,
    DateTime? lastSyncTime,
    int? pendingChanges,
    String? errorMessage,
  }) {
    return SyncStatus(
      networkState: networkState ?? this.networkState,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      pendingChanges: pendingChanges ?? this.pendingChanges,
      errorMessage: errorMessage,
    );
  }
}

/// Enhanced sync service that coordinates upload + download with network monitoring.
///
/// Responsibilities:
/// - Monitor network connectivity
/// - Coordinate up-sync (local → cloud) via ConvexSyncProcessor
/// - Coordinate down-sync (cloud → local) via ConvexDownSyncService
/// - Provide sync status for UI
class EnhancedSyncService {
  final ConvexSyncProcessor _syncProcessor;
  final ConvexDownSyncService _downSyncService;

  final _statusController = StreamController<SyncStatus>.broadcast();
  Timer? _networkCheckTimer;
  NetworkState _currentState = NetworkState.offline;
  bool _isSyncing = false;

  EnhancedSyncService({
    required ConvexSyncProcessor syncProcessor,
    required ConvexDownSyncService downSyncService,
  })  : _syncProcessor = syncProcessor,
        _downSyncService = downSyncService;

  /// Stream of sync status updates
  Stream<SyncStatus> get statusStream => _statusController.stream;

  /// Current sync status
  SyncStatus get currentStatus => SyncStatus(
        networkState: _currentState,
        isSyncing: _isSyncing,
        lastSyncTime: _lastSyncTime,
        pendingChanges: _pendingChanges,
        errorMessage: _lastError,
      );

  DateTime? _lastSyncTime;
  int _pendingChanges = 0;
  String? _lastError;

  /// Start the enhanced sync service
  void start() {
    // Start network monitoring
    _startNetworkMonitoring();
    debugPrint('EnhancedSyncService: Started');
  }

  /// Stop the service
  void stop() {
    _networkCheckTimer?.cancel();
    _syncProcessor.stop();
    debugPrint('EnhancedSyncService: Stopped');
  }

  /// Start periodic network connectivity check
  void _startNetworkMonitoring() {
    _networkCheckTimer?.cancel();
    _networkCheckTimer =
        Timer.periodic(const Duration(seconds: 30), (_) => _checkNetwork());
    // Check immediately
    _checkNetwork();
  }

  /// Check network connectivity
  Future<void> _checkNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (_currentState != NetworkState.online) {
          _currentState = NetworkState.online;
          _updateStatus();
          debugPrint('EnhancedSyncService: Network online');

          // Trigger sync when coming back online
          await syncAll();
        }
      }
    } on SocketException catch (_) {
      if (_currentState != NetworkState.offline) {
        _currentState = NetworkState.offline;
        _updateStatus();
        debugPrint('EnhancedSyncService: Network offline');
      }
    } catch (e) {
      debugPrint('EnhancedSyncService: Network check error: $e');
    }
  }

  /// Perform full sync (upload + download)
  Future<void> syncAll() async {
    if (_isSyncing) return;
    if (!AppConvexConfig.isInitialized) return;

    // Check auth
    if (!AppConvexConfig.isAuthenticated) {
      return;
    }

    _isSyncing = true;
    _currentState = NetworkState.syncing;
    _updateStatus();

    try {
      // Step 1: Upload local changes to cloud
      await _syncProcessor.processOutbox();

      // Step 2: Download cloud changes to local
      await _downSyncService.syncFromCloud();

      _lastSyncTime = DateTime.now();
      _lastError = null;
      debugPrint('EnhancedSyncService: Full sync completed');
    } catch (e) {
      _lastError = e.toString();
      debugPrint('EnhancedSyncService: Sync error: $e');
    } finally {
      _isSyncing = false;
      _currentState = NetworkState.online;
      _updateStatus();
    }
  }

  /// Trigger upload-only sync
  Future<void> syncUp() async {
    if (_isSyncing) return;
    if (!AppConvexConfig.isInitialized) return;

    _isSyncing = true;
    _updateStatus();

    try {
      await _syncProcessor.processOutbox();
      _lastSyncTime = DateTime.now();
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isSyncing = false;
      _updateStatus();
    }
  }

  /// Trigger download-only sync
  Future<void> syncDown() async {
    if (_isSyncing) return;
    if (!AppConvexConfig.isInitialized) return;

    _isSyncing = true;
    _updateStatus();

    try {
      await _downSyncService.syncFromCloud();
      _lastSyncTime = DateTime.now();
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isSyncing = false;
      _updateStatus();
    }
  }

  /// Update pending changes count
  void updatePendingCount(int count) {
    _pendingChanges = count;
    _updateStatus();
  }

  /// Update status and emit to stream
  void _updateStatus() {
    _statusController.add(currentStatus);
  }

  /// Dispose resources
  void dispose() {
    stop();
    _statusController.close();
  }
}
