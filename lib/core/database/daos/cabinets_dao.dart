import 'package:drift/drift.dart';
import '../app_database.dart';

part 'cabinets_dao.g.dart';

@DriftAccessor(tables: [CabinetsTable])
class CabinetsDao extends DatabaseAccessor<AppDatabase>
    with _$CabinetsDaoMixin {
  CabinetsDao(super.db);

  // Get all active cabinets - REQUIRES ownerId
  Future<List<Cabinet>> getAllCabinets({required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);
    
    return (select(cabinetsTable)
      ..where((tbl) => tbl.ownerId.equals(ownerId))
      ..where((tbl) => tbl.isDeleted.equals(false)))
        .get();
  }

  // Watch all active cabinets - REQUIRES ownerId
  Stream<List<Cabinet>> watchAllCabinets({required String ownerId}) {
    if (ownerId.isEmpty) return Stream.value([]);
    
    return (select(cabinetsTable)
      ..where((tbl) => tbl.ownerId.equals(ownerId))
      ..where((tbl) => tbl.isDeleted.equals(false)))
        .watch();
  }

  // Get cabinet by ID (UUID) - REQUIRES ownerId
  Future<Cabinet?> getCabinetById(String id, {required String ownerId}) async {
    if (ownerId.isEmpty) return null;
    
    return await (select(cabinetsTable)
      ..where((tbl) => tbl.id.equals(id))
      ..where((tbl) => tbl.ownerId.equals(ownerId)))
        .getSingleOrNull();
  }

  // Get cabinet by name - REQUIRES ownerId
  Future<Cabinet?> getCabinetByName(String name, {required String ownerId}) async {
    if (ownerId.isEmpty) return null;
    
    return await (select(cabinetsTable)
      ..where((tbl) => tbl.name.equals(name))
      ..where((tbl) => tbl.ownerId.equals(ownerId)))
        .getSingleOrNull();
  }

  // Add a new cabinet
  Future<String> addCabinet(Insertable<Cabinet> cabinet) async {
    return await into(cabinetsTable).insert(cabinet).then((_) {
      final comp = cabinet as CabinetsTableCompanion;
      return comp.id.value;
    });
  }

  // Insert cabinet and return ID
  Future<String> insertCabinet(Insertable<Cabinet> cabinet) async {
    return await into(cabinetsTable).insert(cabinet).then((_) {
      final comp = cabinet as CabinetsTableCompanion;
      return comp.id.value;
    });
  }

  // Update a cabinet
  Future<bool> updateCabinet(Insertable<Cabinet> cabinet) {
    // Use write() for partial updates instead of replace() which requires all fields
    final comp = cabinet as CabinetsTableCompanion;
    return (update(cabinetsTable)..where((tbl) => tbl.id.equals(comp.id.value)))
        .write(cabinet)
        .then((rows) => rows > 0);
  }

  // Soft delete a cabinet
  Future<bool> softDeleteCabinet(String id) {
    return (update(cabinetsTable)..where((tbl) => tbl.id.equals(id)))
        .write(CabinetsTableCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(DateTime.now()),
        ))
        .then((rows) => rows > 0);
  }

  // Hard delete
  Future<int> hardDeleteCabinet(String id) {
    return (delete(cabinetsTable)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Get dirty cabinets - REQUIRES ownerId
  Future<List<Cabinet>> getDirtyCabinets({required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);
    
    return (select(cabinetsTable)
      ..where((tbl) => tbl.ownerId.equals(ownerId))
      ..where((tbl) => tbl.dirtyFlag.equals(true)))
        .get();
  }

  // Mark a cabinet record as dirty
  Future<int> markRecordAsDirty(String id) {
    return (update(cabinetsTable)..where((tbl) => tbl.id.equals(id)))
        .write(CabinetsTableCompanion(
          dirtyFlag: const Value(true),
          updatedAt: Value(DateTime.now()),
        ));
  }

  // Clear dirty flag
  Future<int> clearDirtyFlag(String id) {
    return (update(cabinetsTable)..where((tbl) => tbl.id.equals(id)))
        .write(const CabinetsTableCompanion(dirtyFlag: Value(false)));
  }

  // Update last synced timestamp
  Future<int> updateLastSyncedAt(String id) {
    return (update(cabinetsTable)..where((tbl) => tbl.id.equals(id)))
        .write(CabinetsTableCompanion(
          lastSyncedAt: Value(DateTime.now()),
        ));
  }
  
  // Get cabinet stats (count active subscribers, sum collected)
  Future<Map<String, dynamic>> getCabinetStats(String id, {required String ownerId}) async {
    final cabinet = await getCabinetById(id, ownerId: ownerId);
    if (cabinet == null) return {};
    
    return {
      'totalSubscribers': cabinet.totalSubscribers,
      'currentSubscribers': cabinet.currentSubscribers,
      'collectedAmount': cabinet.collectedAmount,
      'delayedSubscribers': cabinet.delayedSubscribers,
    };
  }
  
  // Count cabinets - REQUIRES ownerId
  Future<int> countCabinets({required String ownerId}) async {
    if (ownerId.isEmpty) return 0;
    
    final query = selectOnly(cabinetsTable)
      ..addColumns([cabinetsTable.id.count()])
      ..where(cabinetsTable.ownerId.equals(ownerId))
      ..where(cabinetsTable.isDeleted.equals(false));
    
    final result = await query.getSingle();
    return result.read(cabinetsTable.id.count()) ?? 0;
  }
  
  // Sum collected amount - REQUIRES ownerId
  Future<double> sumCollectedAmount({required String ownerId}) async {
    if (ownerId.isEmpty) return 0.0;
    
    final query = selectOnly(cabinetsTable)
      ..addColumns([cabinetsTable.collectedAmount.sum()])
      ..where(cabinetsTable.ownerId.equals(ownerId))
      ..where(cabinetsTable.isDeleted.equals(false));
    
    final result = await query.getSingle();
    return result.read(cabinetsTable.collectedAmount.sum()) ?? 0.0;
  }
}