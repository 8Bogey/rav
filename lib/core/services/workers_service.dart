import 'package:drift/drift.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/database/daos/workers_dao.dart';
import 'package:mawlid_al_dhaki/core/services/base_service.dart';

class WorkersService extends BaseService {
  late WorkersDao _dao;

  WorkersService(AppDatabase database) : super(database) {
    _dao = WorkersDao(database);
  }

  // Get all workers
  Future<List<Worker>> getAllWorkers() {
    return _dao.getAllWorkers();
  }

  // Get worker by ID
  Future<Worker?> getWorkerById(int id) {
    return _dao.getWorkerById(id);
  }

  // Get worker by name
  Future<Worker?> getWorkerByName(String name) {
    return _dao.getWorkerByName(name);
  }

  // Add a new worker
  Future<int> addWorker(Worker worker) {
    // For inserts, we want to let the database auto-generate the ID
    final companion = WorkersTableCompanion(
      name: Value(worker.name),
      phone: Value(worker.phone),
      permissions: Value(worker.permissions),
      todayCollected: Value(worker.todayCollected),
      monthTotal: Value(worker.monthTotal),
    );
    return _dao.addWorker(companion);
  }

  // Update a worker
  Future<bool> updateWorker(Worker worker) {
    final companion = worker.toCompanion(false);
    final success = _dao.updateWorker(companion);
    
    // Mark the record as dirty so it gets synced to Android app
    if (worker.id > 0) {
      _dao.markRecordAsDirty(worker.id);
    }
    
    return success;
  }

  // Delete a worker
  Future<int> deleteWorker(int id) {
    return _dao.deleteWorker(id);
  }

  // Get dirty workers (those with dirtyFlag = true)
  Future<List<Worker>> getDirtyWorkers() {
    return _dao.getDirtyWorkers();
  }
  
  // Mark a worker record for manual conflict resolution
  Future<int> markConflictForManualResolution(int id) {
    return _dao.markConflictForManualResolution(id);
  }
  
  // Update conflict resolution information
  Future<int> updateConflictResolution(int id, {
    String? conflictResolutionStrategy,
    DateTime? conflictResolvedAt,
    String? conflictOrigin,
  }) {
    return _dao.updateConflictResolution(
      id,
      conflictResolutionStrategy: conflictResolutionStrategy,
      conflictResolvedAt: conflictResolvedAt,
      conflictOrigin: conflictOrigin,
    );
  }
  
  // Mark record as deleted locally
  Future<int> markDeletedLocally(int id) {
    return _dao.markDeletedLocally(id);
  }
  
  // Undelete a record
  Future<int> undeleteRecord(int id) {
    return _dao.undeleteRecord(id);
  }
  
  // Update sync error information
  Future<int> updateSyncError(int id, String errorMessage) {
    return _dao.updateSyncError(id, errorMessage);
  }
  
  // Increment sync retry count
  Future<int> incrementSyncRetryCount(int id) {
    return _dao.incrementSyncRetryCount(id);
  }
  
  // Update sync status
  Future<int> updateSyncStatus(int id, String status) {
    return _dao.updateSyncStatus(id, status);
  }
  
  // Mark record as dirty
  Future<int> markRecordAsDirty(int id) {
    return _dao.markRecordAsDirty(id);
  }
  
  // Clear dirty flag
  Future<int> clearDirtyFlag(int id) {
    return _dao.clearDirtyFlag(id);
  }
}