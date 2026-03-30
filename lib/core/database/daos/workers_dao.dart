import 'package:drift/drift.dart';
import '../app_database.dart';

part 'workers_dao.g.dart';

@DriftAccessor(tables: [WorkersTable])
class WorkersDao extends DatabaseAccessor<AppDatabase>
    with _$WorkersDaoMixin {
  WorkersDao(super.db);

  // Get all workers
  Future<List<Worker>> getAllWorkers() => select(workersTable).get();

  // Get worker by ID
  Future<Worker?> getWorkerById(int id) async {
    return await (select(workersTable)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  // Get worker by name
  Future<Worker?> getWorkerByName(String name) async {
    return await (select(workersTable)..where((tbl) => tbl.name.equals(name))).getSingleOrNull();
  }

  // Add a new worker
  Future<int> addWorker(Insertable<Worker> worker) {
    return into(workersTable).insert(worker);
  }

  // Update a worker
  Future<bool> updateWorker(Insertable<Worker> worker) {
    return update(workersTable).replace(worker);
  }

  // Delete a worker
  Future<int> deleteWorker(int id) {
    return (delete(workersTable)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Get dirty workers (those with dirtyFlag = true)
  Future<List<Worker>> getDirtyWorkers() {
    return (select(workersTable)..where((tbl) => tbl.dirtyFlag.equals(true))).get();
  }
  
  // Update sync status for a worker
  Future<int> updateSyncStatus(int id, String status) {
    return (update(workersTable)..where((tbl) => tbl.id.equals(id)))
        .write(WorkersTableCompanion(syncStatus: Value(status)));
  }
  
  // Mark a worker record as dirty (needing sync)
  Future<int> markRecordAsDirty(int id) {
    return (update(workersTable)..where((tbl) => tbl.id.equals(id)))
        .write(const WorkersTableCompanion(
          dirtyFlag: Value(true),
          lastModified: Value.absent(), // This will use the default timestamp
        ));
  }
  
  // Clear dirty flag for a worker record
  Future<int> clearDirtyFlag(int id) {
    return (update(workersTable)..where((tbl) => tbl.id.equals(id)))
        .write(const WorkersTableCompanion(dirtyFlag: Value(false)));
  }
  
  // Mark a worker record for manual conflict resolution
  Future<int> markConflictForManualResolution(int id) {
    return (update(workersTable)..where((tbl) => tbl.id.equals(id)))
        .write(WorkersTableCompanion(
          conflictResolutionStrategy: Value('manual'),
          conflictDetectedAt: Value(DateTime.now()),
        ));
  }
  
  // Update conflict resolution information
  Future<int> updateConflictResolution(int id, {
    String? conflictResolutionStrategy,
    DateTime? conflictResolvedAt,
    String? conflictOrigin,
  }) {
    return (update(workersTable)..where((tbl) => tbl.id.equals(id)))
        .write(WorkersTableCompanion(
          conflictResolutionStrategy: Value(conflictResolutionStrategy),
          conflictResolvedAt: Value(conflictResolvedAt),
          conflictOrigin: Value(conflictOrigin),
        ));
  }
  
  // Mark record as deleted locally
  Future<int> markDeletedLocally(int id) {
    return (update(workersTable)..where((tbl) => tbl.id.equals(id)))
        .write(WorkersTableCompanion(
          deletedLocally: Value(true),
          dirtyFlag: Value(true),
          lastModified: Value(DateTime.now()),
        ));
  }
  
  // Undelete a record
  Future<int> undeleteRecord(int id) {
    return (update(workersTable)..where((tbl) => tbl.id.equals(id)))
        .write(WorkersTableCompanion(
          deletedLocally: Value(false),
          dirtyFlag: Value(true),
          lastModified: Value(DateTime.now()),
        ));
  }
  
  // Update sync error information
  Future<int> updateSyncError(int id, String errorMessage) {
    return (update(workersTable)..where((tbl) => tbl.id.equals(id)))
        .write(WorkersTableCompanion(
          lastSyncError: Value(errorMessage),
          syncRetryCount: Value.absent(), // Increment retry count in service layer
        ));
  }
  
  // Increment sync retry count
  Future<int> incrementSyncRetryCount(int id) {
    return (update(workersTable)..where((tbl) => tbl.id.equals(id)))
        .write(const WorkersTableCompanion(
          syncRetryCount: Value.absent(), // This will need to be handled in service layer
        ));
  }
}