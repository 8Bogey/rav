import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/service_providers.dart';
import '../../../core/models/worker_permissions.dart';
import 'package:mawlid_al_dhaki/features/auth/providers/auth_provider.dart';

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
  String _ownerId = '';

  WorkersNotifier(this._ref) : super(const WorkersState()) {
    _service = _ref.read(workersServiceProvider);
    _ownerId = _ref.read(currentUserIdProvider) ?? '';
    loadWorkers();
  }

  /// Load all workers from database
  Future<void> loadWorkers() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final workers = await _service.getAllWorkers(ownerId: _ownerId);

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
  Future<String> addWorker({
    required String name,
    required String phone,
    String permissions = '{"canCollect":true,"canView":true,"canEdit":false}',
    double todayCollected = 0,
    double monthTotal = 0,
  }) async {
    try {
      final now = DateTime.now();
      final worker = Worker(
        id: '',
        ownerId: _ownerId,
        name: name,
        phone: phone,
        permissions: permissions,
        todayCollected: todayCollected,
        monthTotal: monthTotal,
        version: 1,
        inTrash: false,
        trashMovedAt: null,
        updatedAt: now,
        createdAt: now,
      );

      final id = await _service.addWorker(
        worker,
        ownerId: _ownerId,
        workerPermissions: WorkerPermissions.collector(),
      );

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
      await _service.updateWorker(worker, ownerId: _ownerId);
      await loadWorkers();
    } catch (e) {
      state = state.copyWith(error: 'فشل تحديث العامل: $e');
      rethrow;
    }
  }

  /// Update worker permissions
  Future<void> updatePermissions(
      String workerId, WorkerPermissions permissions) async {
    try {
      final worker = await getWorkerById(workerId);
      if (worker != null) {
        await updateWorker(worker.copyWith(
          permissions: jsonEncode(permissions.toJson()),
        ));
      }
    } catch (e) {
      state = state.copyWith(error: 'فشل تحديث الصلاحيات: $e');
    }
  }

  /// Delete a worker
  Future<void> deleteWorker(String id) async {
    try {
      await _service.deleteWorker(id, ownerId: _ownerId);
      await loadWorkers();
    } catch (e) {
      state = state.copyWith(error: 'فشل حذف العامل: $e');
      rethrow;
    }
  }

  /// Get worker by ID
  Future<Worker?> getWorkerById(String id) async {
    return await _service.getWorkerById(id, ownerId: _ownerId);
  }
}

/// Provider for workers state
final workersProvider =
    StateNotifierProvider<WorkersNotifier, WorkersState>((ref) {
  return WorkersNotifier(ref);
});

/// Provider for a single worker by ID
final workerByIdProvider =
    FutureProvider.family<Worker?, String>((ref, id) async {
  final service = ref.watch(workersServiceProvider);
  final ownerId = ref.watch(currentUserIdProvider) ?? '';
  return await service.getWorkerById(id, ownerId: ownerId);
});

/// Provider for total workers count
final workersCountProvider = Provider<int>((ref) {
  return ref.watch(workersProvider).workers.length;
});
