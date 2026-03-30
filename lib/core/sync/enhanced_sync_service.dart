import 'dart:async';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/supabase/supabase_service.dart';
import 'package:mawlid_al_dhaki/core/supabase/sync_conflict.dart';

/// Sync status enumeration
enum SyncStatus {
  idle,
  syncing,
  localToCloud,
  cloudToLocal,
  detectingConflicts,
  resolvingConflicts,
  completed,
  failed,
}

/// Sync progress information
class SyncProgress {
  final SyncStatus status;
  final String? currentTable;
  final int processedRecords;
  final int totalRecords;
  final String? error;
  final DateTime? startedAt;
  final Duration? elapsed;

  SyncProgress({
    required this.status,
    this.currentTable,
    this.processedRecords = 0,
    this.totalRecords = 0,
    this.error,
    this.startedAt,
    this.elapsed,
  });

  double get progress => totalRecords > 0 ? processedRecords / totalRecords : 0;

  SyncProgress copyWith({
    SyncStatus? status,
    String? currentTable,
    int? processedRecords,
    int? totalRecords,
    String? error,
    DateTime? startedAt,
    Duration? elapsed,
  }) {
    return SyncProgress(
      status: status ?? this.status,
      currentTable: currentTable ?? this.currentTable,
      processedRecords: processedRecords ?? this.processedRecords,
      totalRecords: totalRecords ?? this.totalRecords,
      error: error ?? this.error,
      startedAt: startedAt ?? this.startedAt,
      elapsed: elapsed ?? this.elapsed,
    );
  }
}

/// Enhanced synchronization service with retry logic and real-time status updates
class EnhancedSyncService {
  final AppDatabase _localDatabase;
  final SupabaseService _supabaseService;

  // Sync configuration
  static const int MAX_RETRY_ATTEMPTS = 3;
  static const Duration RETRY_DELAY = Duration(seconds: 5);

  // Streams for real-time status updates
  final _syncProgressController = StreamController<SyncProgress>.broadcast();
  Stream<SyncProgress> get syncProgressStream => _syncProgressController.stream;

  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  // Current sync state
  SyncProgress _currentProgress = SyncProgress(status: SyncStatus.idle);
  bool _isSyncing = false;
  DateTime? _lastSuccessfulSync;
  int _retryCount = 0;

  // Getters
  bool get isSyncing => _isSyncing;
  DateTime? get lastSuccessfulSync => _lastSuccessfulSync;
  int get retryCount => _retryCount;
  SyncProgress get currentProgress => _currentProgress;

  EnhancedSyncService({
    required AppDatabase database,
    required SupabaseService supabaseService,
  })  : _localDatabase = database,
        _supabaseService = supabaseService;

  /// Update sync progress
  void _updateProgress(SyncProgress progress) {
    _currentProgress = progress;
    _syncProgressController.add(progress);
    _syncStatusController.add(progress.status);
  }

  /// Main sync function with retry logic
  Future<void> sync() async {
    if (_isSyncing) {
      print('Sync already in progress, skipping...');
      return;
    }

    _isSyncing = true;
    _retryCount = 0;
    final startTime = DateTime.now();

    _updateProgress(SyncProgress(
      status: SyncStatus.syncing,
      startedAt: startTime,
    ));

    try {
      await _executeSyncWithRetry();
      
      _lastSuccessfulSync = DateTime.now();
      _updateProgress(_currentProgress.copyWith(
        status: SyncStatus.completed,
        elapsed: DateTime.now().difference(startTime),
      ));
      
      print('Bidirectional sync completed successfully.');
    } catch (e) {
      _updateProgress(_currentProgress.copyWith(
        status: SyncStatus.failed,
        error: e.toString(),
        elapsed: DateTime.now().difference(startTime),
      ));
      rethrow;
    } finally {
      _isSyncing = false;
    }
  }

  /// Execute sync with retry logic
  Future<void> _executeSyncWithRetry() async {
    while (_retryCount < MAX_RETRY_ATTEMPTS) {
      try {
        if (_retryCount > 0) {
          print('Retry attempt $_retryCount of $MAX_RETRY_ATTEMPTS...');
          _updateProgress(_currentProgress.copyWith(
            error: 'Retrying... (attempt ${_retryCount + 1})',
          ));
          await Future.delayed(RETRY_DELAY);
        }

        await _performSync();
        return; // Success, exit retry loop
      } catch (e) {
        _retryCount++;
        if (_retryCount >= MAX_RETRY_ATTEMPTS) {
          print('Max retry attempts reached. Sync failed: $e');
          _updateProgress(_currentProgress.copyWith(
            status: SyncStatus.failed,
            error: 'Sync failed after $MAX_RETRY_ATTEMPTS attempts: $e',
          ));
          rethrow;
        }
        print('Sync attempt failed: $e. Retrying...');
      }
    }
  }

  /// Runs the same pipeline as [SupabaseService.syncBidirectional] with UI progress hints.
  Future<void> _performSync() async {
    await _supabaseService.syncBidirectional(
      onPhase: (phase) {
        switch (phase) {
          case SyncPipelinePhase.localToCloud:
            _updateProgress(_currentProgress.copyWith(
              status: SyncStatus.localToCloud,
              currentTable: 'رفع التغييرات إلى السحابة...',
            ));
            break;
          case SyncPipelinePhase.cloudToLocal:
            _updateProgress(_currentProgress.copyWith(
              status: SyncStatus.cloudToLocal,
              currentTable: 'استيراد من السحابة...',
            ));
            break;
          case SyncPipelinePhase.conflictsDetecting:
            _updateProgress(_currentProgress.copyWith(
              status: SyncStatus.detectingConflicts,
              currentTable: 'كشف التعارضات...',
            ));
            break;
          case SyncPipelinePhase.conflictsResolving:
            _updateProgress(_currentProgress.copyWith(
              status: SyncStatus.resolvingConflicts,
              currentTable: 'حل التعارضات...',
            ));
            break;
        }
      },
    );

    _updateProgress(_currentProgress.copyWith(
      status: SyncStatus.completed,
      currentTable: 'اكتملت المزامنة',
    ));
  }

  /// Get sync statistics
  Future<SyncStatistics> getSyncStatistics() async {
    final dirtySubscribers = await _localDatabase.subscribersDao.getDirtySubscribers();
    final dirtyCabinets = await _localDatabase.cabinetsDao.getDirtyCabinets();
    final dirtyPayments = await _localDatabase.paymentsDao.getDirtyPayments();
    final dirtyWorkers = await _localDatabase.workersDao.getDirtyWorkers();

    return SyncStatistics(
      pendingSubscribers: dirtySubscribers.length,
      pendingCabinets: dirtyCabinets.length,
      pendingPayments: dirtyPayments.length,
      pendingWorkers: dirtyWorkers.length,
      totalPending: dirtySubscribers.length + dirtyCabinets.length + dirtyPayments.length + dirtyWorkers.length,
      lastSuccessfulSync: _lastSuccessfulSync,
      isCurrentlySyncing: _isSyncing,
    );
  }

  /// Cancel ongoing sync
  void cancelSync() {
    if (_isSyncing) {
      print('Cancelling sync...');
      _isSyncing = false;
      _updateProgress(_currentProgress.copyWith(
        status: SyncStatus.idle,
        currentTable: 'Sync cancelled',
      ));
    }
  }

  /// Dispose resources
  void dispose() {
    _syncProgressController.close();
    _syncStatusController.close();
  }
}

/// Sync statistics data class
class SyncStatistics {
  final int pendingSubscribers;
  final int pendingCabinets;
  final int pendingPayments;
  final int pendingWorkers;
  final int totalPending;
  final DateTime? lastSuccessfulSync;
  final bool isCurrentlySyncing;

  SyncStatistics({
    required this.pendingSubscribers,
    required this.pendingCabinets,
    required this.pendingPayments,
    required this.pendingWorkers,
    required this.totalPending,
    this.lastSuccessfulSync,
    required this.isCurrentlySyncing,
  });
}
