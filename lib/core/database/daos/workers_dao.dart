import 'package:drift/drift.dart';
import '../app_database.dart';

part 'workers_dao.g.dart';

@DriftAccessor(tables: [WorkersTable])
class WorkersDao extends DatabaseAccessor<AppDatabase> with _$WorkersDaoMixin {
  WorkersDao(super.db);

  // Get all active workers - uses composite index (by_ownerId_inTrash)
  Future<List<Worker>> getAllWorkers({required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);

    return (select(workersTable)
          ..where((t) => t.ownerId.equals(ownerId) & t.inTrash.equals(false)))
        .get();
  }

  // Watch all active workers - uses composite index (by_ownerId_inTrash)
  Stream<List<Worker>> watchAllWorkers({required String ownerId}) {
    if (ownerId.isEmpty) return Stream.value([]);

    return (select(workersTable)
          ..where((t) => t.ownerId.equals(ownerId) & t.inTrash.equals(false)))
        .watch();
  }

  // Get worker by ID (UUID) - REQUIRES ownerId
  Future<Worker?> getWorkerById(String id, {required String ownerId}) async {
    if (ownerId.isEmpty) return null;

    return await (select(workersTable)
          ..where((tbl) => tbl.id.equals(id))
          ..where((tbl) => tbl.ownerId.equals(ownerId)))
        .getSingleOrNull();
  }

  // Get worker by name - uses composite index (by_ownerId_name_inTrash)
  Future<Worker?> getWorkerByName(String name,
      {required String ownerId}) async {
    if (ownerId.isEmpty) return null;

    return (select(workersTable)
          ..where((t) =>
              t.ownerId.equals(ownerId) &
              t.name.equals(name) &
              t.inTrash.equals(false)))
        .getSingleOrNull();
  }

  // Get worker by phone - uses composite index (by_ownerId_phone_inTrash)
  Future<Worker?> getWorkerByPhone(String phone,
      {required String ownerId}) async {
    if (ownerId.isEmpty) return null;

    return (select(workersTable)
          ..where((t) =>
              t.ownerId.equals(ownerId) &
              t.phone.equals(phone) &
              t.inTrash.equals(false)))
        .getSingleOrNull();
  }

  // Add a new worker
  Future<String> addWorker(Insertable<Worker> worker) async {
    return await into(workersTable).insert(worker).then((_) {
      final comp = worker as WorkersTableCompanion;
      return comp.id.value;
    });
  }

  // Insert worker and return ID
  Future<String> insertWorker(Insertable<Worker> worker) async {
    return await into(workersTable).insert(worker).then((_) {
      final comp = worker as WorkersTableCompanion;
      return comp.id.value;
    });
  }

  // Update a worker
  Future<bool> updateWorker(Insertable<Worker> worker) {
    // Use write() for partial updates instead of replace() which requires all fields
    final comp = worker as WorkersTableCompanion;
    return (update(workersTable)..where((tbl) => tbl.id.equals(comp.id.value)))
        .write(worker)
        .then((rows) => rows > 0);
  }

  // Soft delete a worker
  Future<int> deleteWorker(String id) {
    return (update(workersTable)..where((tbl) => tbl.id.equals(id)))
        .write(WorkersTableCompanion(
      inTrash: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));
  }

  // Hard delete
  Future<int> hardDeleteWorker(String id) {
    return (delete(workersTable)..where((tbl) => tbl.id.equals(id))).go();
  }

  // NOTE: dirtyFlag, lastSyncedAt, syncStatus, cloudId, deletedLocally,
  // permissionsMask, lastModified fields removed from schema.
  // Sync-related DAO methods (getDirtyWorkers, markRecordAsDirty,
  // clearDirtyFlag, updateLastSyncedAt) have been removed.

  // Get workers with collection stats - REQUIRES ownerId
  Future<Map<String, dynamic>> getWorkerStats(String id,
      {required String ownerId}) async {
    final worker = await getWorkerById(id, ownerId: ownerId);
    if (worker == null) return {};

    return {
      'todayCollected': worker.todayCollected,
      'monthTotal': worker.monthTotal,
      'permissions': worker.permissions,
    };
  }

  // Update worker's collection stats
  Future<int> updateCollectionStats(String id,
      {double? todayCollected, double? monthTotal}) {
    return (update(workersTable)..where((tbl) => tbl.id.equals(id)))
        .write(WorkersTableCompanion(
      todayCollected:
          todayCollected != null ? Value(todayCollected) : const Value.absent(),
      monthTotal: monthTotal != null ? Value(monthTotal) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    ));
  }

  // Reset daily collection
  Future<int> resetDailyCollection(String id) {
    return (update(workersTable)..where((tbl) => tbl.id.equals(id)))
        .write(const WorkersTableCompanion(
      todayCollected: Value(0.0),
    ));
  }

  // Count workers - REQUIRES ownerId
  Future<int> countWorkers({required String ownerId}) async {
    if (ownerId.isEmpty) return 0;

    final query = selectOnly(workersTable)
      ..addColumns([workersTable.id.count()])
      ..where(workersTable.ownerId.equals(ownerId))
      ..where(workersTable.inTrash.equals(false));

    final result = await query.getSingle();
    return result.read(workersTable.id.count()) ?? 0;
  }
}
