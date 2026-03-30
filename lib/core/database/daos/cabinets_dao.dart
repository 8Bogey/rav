import 'package:drift/drift.dart';
import '../app_database.dart';

part 'cabinets_dao.g.dart';

@DriftAccessor(tables: [CabinetsTable])
class CabinetsDao extends DatabaseAccessor<AppDatabase>
    with _$CabinetsDaoMixin {
  CabinetsDao(super.db);

  // Get all cabinets
  Future<List<Cabinet>> getAllCabinets() => select(cabinetsTable).get();

  // Get cabinet by ID
  Future<Cabinet?> getCabinetById(int id) async {
    return await (select(cabinetsTable)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  // Get cabinet by name
  Future<Cabinet?> getCabinetByName(String name) async {
    return await (select(cabinetsTable)..where((tbl) => tbl.name.equals(name))).getSingleOrNull();
  }

  // Add a new cabinet
  Future<int> addCabinet(Insertable<Cabinet> cabinet) {
    return into(cabinetsTable).insert(cabinet);
  }

  // Update a cabinet
  Future<bool> updateCabinet(Insertable<Cabinet> cabinet) {
    return update(cabinetsTable).replace(cabinet);
  }

  // Delete a cabinet
  Future<int> deleteCabinet(int id) {
    return (delete(cabinetsTable)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Get dirty cabinets (those with dirtyFlag = true)
  Future<List<Cabinet>> getDirtyCabinets() {
    return (select(cabinetsTable)..where((tbl) => tbl.dirtyFlag.equals(true))).get();
  }
  
  // Update sync status for a cabinet
  Future<int> updateSyncStatus(int id, String status) {
    return (update(cabinetsTable)..where((tbl) => tbl.id.equals(id)))
        .write(CabinetsTableCompanion(syncStatus: Value(status)));
  }
  
  // Mark a cabinet record as dirty (needing sync)
  Future<int> markRecordAsDirty(int id) {
    return (update(cabinetsTable)..where((tbl) => tbl.id.equals(id)))
        .write(const CabinetsTableCompanion(
          dirtyFlag: Value(true),
          lastModified: Value.absent(), // This will use the default timestamp
        ));
  }
  
  // Clear dirty flag for a cabinet record
  Future<int> clearDirtyFlag(int id) {
    return (update(cabinetsTable)..where((tbl) => tbl.id.equals(id)))
        .write(const CabinetsTableCompanion(dirtyFlag: Value(false)));
  }
  
  // Mark a cabinet record for manual conflict resolution
  Future<int> markConflictForManualResolution(int id) {
    return (update(cabinetsTable)..where((tbl) => tbl.id.equals(id)))
        .write(CabinetsTableCompanion(
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
    return (update(cabinetsTable)..where((tbl) => tbl.id.equals(id)))
        .write(CabinetsTableCompanion(
          conflictResolutionStrategy: Value(conflictResolutionStrategy),
          conflictResolvedAt: Value(conflictResolvedAt),
          conflictOrigin: Value(conflictOrigin),
        ));
  }
  
  // Mark record as deleted locally
  Future<int> markDeletedLocally(int id) {
    return (update(cabinetsTable)..where((tbl) => tbl.id.equals(id)))
        .write(CabinetsTableCompanion(
          deletedLocally: Value(true),
          dirtyFlag: Value(true),
          lastModified: Value(DateTime.now()),
        ));
  }
  
  // Undelete a record
  Future<int> undeleteRecord(int id) {
    return (update(cabinetsTable)..where((tbl) => tbl.id.equals(id)))
        .write(CabinetsTableCompanion(
          deletedLocally: Value(false),
          dirtyFlag: Value(true),
          lastModified: Value(DateTime.now()),
        ));
  }
  
  // Update sync error information
  Future<int> updateSyncError(int id, String errorMessage) {
    return (update(cabinetsTable)..where((tbl) => tbl.id.equals(id)))
        .write(CabinetsTableCompanion(
          lastSyncError: Value(errorMessage),
          syncRetryCount: Value.absent(), // Increment retry count in service layer
        ));
  }
  
  // Reset sync error and retry count after successful sync
  Future<int> resetSyncError(int id) {
    return (update(cabinetsTable)..where((tbl) => tbl.id.equals(id)))
        .write(const CabinetsTableCompanion(
          lastSyncError: Value(null),
          syncRetryCount: Value(0),
        ));
  }
  
  // Increment sync retry count
  Future<int> incrementSyncRetryCount(int id) {
    return (update(cabinetsTable)..where((tbl) => tbl.id.equals(id)))
        .write(const CabinetsTableCompanion(
          syncRetryCount: Value.absent(), // This will need to be handled in service layer
        ));
  }
}