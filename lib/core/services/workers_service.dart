import 'package:drift/drift.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/database/daos/workers_dao.dart';
import 'package:mawlid_al_dhaki/core/services/base_service.dart';
import 'package:uuid/uuid.dart';

class WorkersService extends BaseService {
  WorkersService(super.database);

  WorkersDao get _dao => database.workersDao;
  static const _uuid = Uuid();

  // Get all workers
  Future<List<Worker>> getAllWorkers({required String ownerId}) {
    return _dao.getAllWorkers(ownerId: ownerId);
  }

  // Get worker by ID
  Future<Worker?> getWorkerById(String id, {required String ownerId}) {
    return _dao.getWorkerById(id, ownerId: ownerId);
  }

  // Get worker by name
  Future<Worker?> getWorkerByName(String name, {required String ownerId}) {
    return _dao.getWorkerByName(name, ownerId: ownerId);
  }

  // Add a new worker
  Future<String> addWorker(Worker worker, {required String ownerId}) {
    final id = _uuid.v4();
    final companion = WorkersTableCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      name: Value(worker.name),
      phone: Value(worker.phone),
      permissions: Value(worker.permissions),
      todayCollected: Value(worker.todayCollected),
      monthTotal: Value(worker.monthTotal),
      version: const Value(1),
      isDeleted: const Value(false),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );
    return _dao.addWorker(companion);
  }

  // Update a worker
  Future<bool> updateWorker(Worker worker, {required String ownerId}) {
    final companion = worker.toCompanion(false).copyWith(
      ownerId: Value(ownerId),
      updatedAt: Value(DateTime.now()),
    );
    return _dao.updateWorker(companion);
  }

  // Soft delete a worker
  Future<bool> deleteWorker(String id, {required String ownerId}) {
    final companion = WorkersTableCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      isDeleted: const Value(true),
      updatedAt: Value(DateTime.now()),
    );
    return _dao.updateWorker(companion);
  }

  // Watch all workers (reactive stream)
  Stream<List<Worker>> watchWorkers({required String ownerId}) {
    return _dao.watchAllWorkers(ownerId: ownerId);
  }
}