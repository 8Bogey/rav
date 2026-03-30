import 'dart:async';
import 'package:mawlid_al_dhaki/core/sync/enhanced_sync_service.dart';

/// Represents a queued sync operation
class SyncQueueItem {
  final String id;
  final SyncOperationType operationType;
  final String tableName;
  final int? recordId;
  final Map<String, dynamic>? data;
  final DateTime queuedAt;
  final int priority;
  final int retryCount;

  SyncQueueItem({
    required this.id,
    required this.operationType,
    required this.tableName,
    this.recordId,
    this.data,
    required this.queuedAt,
    this.priority = 0,
    this.retryCount = 0,
  });

  SyncQueueItem copyWith({
    int? retryCount,
  }) {
    return SyncQueueItem(
      id: id,
      operationType: operationType,
      tableName: tableName,
      recordId: recordId,
      data: data,
      queuedAt: queuedAt,
      priority: priority,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

/// Types of sync operations
enum SyncOperationType {
  create,
  update,
  delete,
  fetch,
}

/// Status of the sync queue
enum SyncQueueStatus {
  idle,
  processing,
  paused,
  error,
}

/// Service for managing sync operation queue
class SyncQueueService {
  final EnhancedSyncService _syncService;
  
  final List<SyncQueueItem> _queue = [];
  final _queueController = StreamController<List<SyncQueueItem>>.broadcast();
  
  SyncQueueStatus _status = SyncQueueStatus.idle;
  bool _isPaused = false;
  Timer? _processTimer;
  
  static const int MAX_RETRY = 3;
  static const Duration PROCESS_INTERVAL = Duration(seconds: 5);

  /// Stream of queue changes
  Stream<List<SyncQueueItem>> get queueStream => _queueController.stream;
  
  /// Current queue status
  SyncQueueStatus get status => _status;
  
  /// Current queue length
  int get queueLength => _queue.length;
  
  /// Whether queue is paused
  bool get isPaused => _isPaused;

  SyncQueueService(this._syncService) {
    _startProcessing();
  }

  /// Add an item to the sync queue
  void enqueue(SyncQueueItem item) {
    _queue.add(item);
    _sortQueue();
    _queueController.add(List.from(_queue));
    print('Added to sync queue: ${item.operationType.name} on ${item.tableName}');
  }

  /// Add multiple items to the queue
  void enqueueBatch(List<SyncQueueItem> items) {
    _queue.addAll(items);
    _sortQueue();
    _queueController.add(List.from(_queue));
    print('Added ${items.length} items to sync queue');
  }

  /// Remove an item from the queue
  void dequeue(String id) {
    _queue.removeWhere((item) => item.id == id);
    _queueController.add(List.from(_queue));
  }

  /// Clear the entire queue
  void clearQueue() {
    _queue.clear();
    _queueController.add(List.from(_queue));
  }

  /// Pause queue processing
  void pause() {
    _isPaused = true;
    _status = SyncQueueStatus.paused;
    print('Sync queue paused');
  }

  /// Resume queue processing
  void resume() {
    _isPaused = false;
    _status = SyncQueueStatus.idle;
    print('Sync queue resumed');
  }

  /// Sort queue by priority (higher first) then by time
  void _sortQueue() {
    _queue.sort((a, b) {
      // Higher priority first
      if (a.priority != b.priority) {
        return b.priority.compareTo(a.priority);
      }
      // Earlier queued first
      return a.queuedAt.compareTo(b.queuedAt);
    });
  }

  /// Start automatic queue processing
  void _startProcessing() {
    _processTimer?.cancel();
    _processTimer = Timer.periodic(PROCESS_INTERVAL, (_) {
      if (!_isPaused && _queue.isNotEmpty) {
        _processNext();
      }
    });
  }

  /// Process the next item in the queue
  Future<void> _processNext() async {
    if (_queue.isEmpty) return;

    _status = SyncQueueStatus.processing;
    final item = _queue.first;

    try {
      print('Processing sync queue item: ${item.operationType.name} on ${item.tableName}');
      
      await _processItem(item);
      
      // Success - remove from queue
      dequeue(item.id);
      print('Successfully processed: ${item.id}');
    } catch (e) {
      print('Error processing queue item ${item.id}: $e');
      
      // Handle retry
      if (item.retryCount < MAX_RETRY) {
        // Update retry count and move to end of queue
        final index = _queue.indexWhere((i) => i.id == item.id);
        if (index != -1) {
          _queue[index] = item.copyWith(retryCount: item.retryCount + 1);
          _sortQueue();
        }
      } else {
        // Max retries exceeded - remove and log
        print('Max retries exceeded for ${item.id}, removing from queue');
        dequeue(item.id);
      }
    }

    if (_queue.isEmpty) {
      _status = SyncQueueStatus.idle;
    }
  }

  /// Process a single queue item
  Future<void> _processItem(SyncQueueItem item) async {
    switch (item.operationType) {
      case SyncOperationType.create:
      case SyncOperationType.update:
        // These are handled by the sync service
        await _syncService.sync();
        break;
      case SyncOperationType.delete:
        // Handle delete operation
        break;
      case SyncOperationType.fetch:
        // Handle fetch operation
        await _syncService.sync();
        break;
    }
  }

  /// Queue a create operation
  void queueCreate(String tableName, Map<String, dynamic> data, {int priority = 0}) {
    enqueue(SyncQueueItem(
      id: 'create_${DateTime.now().millisecondsSinceEpoch}',
      operationType: SyncOperationType.create,
      tableName: tableName,
      data: data,
      queuedAt: DateTime.now(),
      priority: priority,
    ));
  }

  /// Queue an update operation
  void queueUpdate(String tableName, int recordId, Map<String, dynamic> data, {int priority = 0}) {
    enqueue(SyncQueueItem(
      id: 'update_${DateTime.now().millisecondsSinceEpoch}',
      operationType: SyncOperationType.update,
      tableName: tableName,
      recordId: recordId,
      data: data,
      queuedAt: DateTime.now(),
      priority: priority,
    ));
  }

  /// Queue a delete operation
  void queueDelete(String tableName, int recordId, {int priority = 0}) {
    enqueue(SyncQueueItem(
      id: 'delete_${DateTime.now().millisecondsSinceEpoch}',
      operationType: SyncOperationType.delete,
      tableName: tableName,
      recordId: recordId,
      queuedAt: DateTime.now(),
      priority: priority,
    ));
  }

  /// Queue a fetch operation
  void queueFetch(String tableName, {int priority = 0}) {
    enqueue(SyncQueueItem(
      id: 'fetch_${DateTime.now().millisecondsSinceEpoch}',
      operationType: SyncOperationType.fetch,
      tableName: tableName,
      queuedAt: DateTime.now(),
      priority: priority,
    ));
  }

  /// Force process all queued items now
  Future<void> processNow() async {
    while (_queue.isNotEmpty) {
      await _processNext();
    }
  }

  /// Get queue statistics
  Map<String, dynamic> getStatistics() {
    return {
      'status': _status.name,
      'isPaused': _isPaused,
      'totalItems': _queue.length,
      'byType': {
        'create': _queue.where((i) => i.operationType == SyncOperationType.create).length,
        'update': _queue.where((i) => i.operationType == SyncOperationType.update).length,
        'delete': _queue.where((i) => i.operationType == SyncOperationType.delete).length,
        'fetch': _queue.where((i) => i.operationType == SyncOperationType.fetch).length,
      },
      'byTable': _queue.groupBy((i) => i.tableName).map(
        (key, value) => MapEntry(key, value.length),
      ),
    };
  }

  /// Dispose resources
  void dispose() {
    _processTimer?.cancel();
    _queueController.close();
  }
}

/// Extension for grouping list items
extension GroupByExtension<T> on List<T> {
  Map<K, List<T>> groupBy<K>(K Function(T) keyFunction) {
    final map = <K, List<T>>{};
    for (final item in this) {
      final key = keyFunction(item);
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }
}
