import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/service_providers.dart';

/// Worker permissions model
class WorkerPermissions {
  final bool collection;
  final bool addSubscriber;
  final bool editData;
  final bool viewReports;
  final bool manageWorkers;
  final bool settings;

  const WorkerPermissions({
    this.collection = false,
    this.addSubscriber = false,
    this.editData = false,
    this.viewReports = false,
    this.manageWorkers = false,
    this.settings = false,
  });

  factory WorkerPermissions.fromJson(Map<String, dynamic> json) {
    return WorkerPermissions(
      collection: json['collection'] ?? false,
      addSubscriber: json['addSubscriber'] ?? false,
      editData: json['editData'] ?? false,
      viewReports: json['viewReports'] ?? false,
      manageWorkers: json['manageWorkers'] ?? false,
      settings: json['settings'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'collection': collection,
        'addSubscriber': addSubscriber,
        'editData': editData,
        'viewReports': viewReports,
        'manageWorkers': manageWorkers,
        'settings': settings,
      };

  String toJsonString() => jsonEncode(toJson());

  WorkerPermissions copyWith({
    bool? collection,
    bool? addSubscriber,
    bool? editData,
    bool? viewReports,
    bool? manageWorkers,
    bool? settings,
  }) {
    return WorkerPermissions(
      collection: collection ?? this.collection,
      addSubscriber: addSubscriber ?? this.addSubscriber,
      editData: editData ?? this.editData,
      viewReports: viewReports ?? this.viewReports,
      manageWorkers: manageWorkers ?? this.manageWorkers,
      settings: settings ?? this.settings,
    );
  }
}

/// State for workers list
class WorkersState {
  final List<Worker> workers;
  final bool isLoading;
  final String? error;

  const WorkersState({
    this.workers = const [],
    this.isLoading = false,
    this.error,
  });

  WorkersState copyWith({
    List<Worker>? workers,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return WorkersState(
      workers: workers ?? this.workers,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Notifier for managing workers state
/// 
/// This notifier now uses WorkersService instead of directly accessing DAOs
/// to provide a consistent service layer for all database operations.
class WorkersNotifier extends StateNotifier<WorkersState> {
  final Ref _ref;
  late WorkersService _service;

  WorkersNotifier(this._ref) : super(const WorkersState()) {
    _service = _ref.read(workersServiceProvider);
    loadWorkers();
  }

  /// Load all workers from database
  Future<void> loadWorkers() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final workers = await _service.getAllWorkers();

      state = state.copyWith(
        workers: workers,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'فشل تحميل العمال: $e',
      );
    }
  }

  /// Add a new worker
  Future<int> addWorker({
    required String name,
    required String phone,
    String permissions = '{"canCollect":true,"canView":true,"canEdit":false}',
    double todayCollected = 0,
    double monthTotal = 0,
  }) async {
    try {
      final worker = Worker(
        id: 0, // Will be auto-generated
        name: name,
        phone: phone,
        permissions: permissions,
        todayCollected: todayCollected,
        monthTotal: monthTotal,
      );
      
      final id = await _service.addWorker(worker);

      await loadWorkers();
      return id;
    } catch (e) {
      state = state.copyWith(error: 'فشل إضافة العامل: $e');
      rethrow;
    }
  }

  /// Update an existing worker
  Future<void> updateWorker(Worker worker) async {
    try {
      await _service.updateWorker(worker);
      await loadWorkers();
    } catch (e) {
      state = state.copyWith(error: 'فشل تحديث العامل: $e');
      rethrow;
    }
  }

  /// Update worker permissions
  Future<void> updatePermissions(
      int workerId, WorkerPermissions permissions) async {
    try {
      final worker = await getWorkerById(workerId);
      if (worker != null) {
        await updateWorker(worker.copyWith(
          permissions: permissions.toJsonString(),
        ));
      }
    } catch (e) {
      state = state.copyWith(error: 'فشل تحديث الصلاحيات: $e');
      rethrow;
    }
  }

  /// Update worker collection stats
  Future<void> updateCollectionStats(int workerId, double amount) async {
    try {
      final worker = await getWorkerById(workerId);
      if (worker != null) {
        await updateWorker(worker.copyWith(
          todayCollected: worker.todayCollected + amount,
          monthTotal: worker.monthTotal + amount,
        ));
      }
    } catch (e) {
      // Silently fail - stats update shouldn't break payment
      print('Failed to update worker stats: $e');
    }
  }

  /// Delete a worker
  Future<void> deleteWorker(int id) async {
    try {
      await _service.deleteWorker(id);
      await loadWorkers();
    } catch (e) {
      state = state.copyWith(error: 'فشل حذف العامل: $e');
      rethrow;
    }
  }

  /// Get worker by ID
  Future<Worker?> getWorkerById(int id) async {
    return await _service.getWorkerById(id);
  }

  /// Get worker by name
  Future<Worker?> getWorkerByName(String name) async {
    return await _service.getWorkerByName(name);
  }

  /// Parse permissions from worker
  WorkerPermissions parsePermissions(Worker worker) {
    try {
      final json = jsonDecode(worker.permissions) as Map<String, dynamic>;
      return WorkerPermissions.fromJson(json);
    } catch (e) {
      return const WorkerPermissions();
    }
  }
}

/// Provider for workers state
final workersProvider =
    StateNotifierProvider<WorkersNotifier, WorkersState>((ref) {
  return WorkersNotifier(ref);
});

/// Provider for a single worker by ID
final workerByIdProvider = FutureProvider.family<Worker?, int>((ref, id) async {
  final service = ref.watch(workersServiceProvider);
  return await service.getWorkerById(id);
});

/// Provider for worker permissions
final workerPermissionsProvider =
    Provider.family<WorkerPermissions, int>((ref, workerId) {
  final workers = ref.watch(workersProvider).workers;
  final worker = workers.where((w) => w.id == workerId).firstOrNull;

  if (worker == null) {
    return const WorkerPermissions();
  }

  try {
    final json = jsonDecode(worker.permissions) as Map<String, dynamic>;
    return WorkerPermissions.fromJson(json);
  } catch (e) {
    return const WorkerPermissions();
  }
});
