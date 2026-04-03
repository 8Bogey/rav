import 'package:drift/drift.dart';
import '../app_database.dart';

part 'trash_dao.g.dart';

@DriftAccessor(tables: [TrashTable])
class TrashDao extends DatabaseAccessor<AppDatabase> with _$TrashDaoMixin {
  TrashDao(super.db);

  /// Get all trash items
  Future<List<TrashItem>> getAllTrashItems({required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);
    return (select(trashTable)
          ..where((t) => t.ownerId.equals(ownerId))
          ..orderBy([(t) => OrderingTerm.desc(t.deletedAt)]))
        .get();
  }

  /// Watch all trash items
  Stream<List<TrashItem>> watchAllTrashItems({required String ownerId}) {
    if (ownerId.isEmpty) return Stream.value([]);
    return (select(trashTable)
          ..where((t) => t.ownerId.equals(ownerId))
          ..orderBy([(t) => OrderingTerm.desc(t.deletedAt)]))
        .watch();
  }

  /// Insert a trash item
  Future<String> insertTrashItem(Insertable<TrashItem> item) async {
    return await into(trashTable).insert(item).then((_) {
      final comp = item as TrashTableCompanion;
      return comp.id.value;
    });
  }

  /// Delete a trash item
  Future<int> deleteTrashItem(String id) {
    return (delete(trashTable)..where((t) => t.id.equals(id))).go();
  }

  /// Delete all trash items for an owner
  Future<int> deleteAllTrashItems(String ownerId) {
    return (delete(trashTable)..where((t) => t.ownerId.equals(ownerId))).go();
  }

  /// Get expired trash items
  Future<List<TrashItem>> getExpiredTrashItems() {
    return (select(trashTable)
          ..where((t) => t.expiresAt.isSmallerThanValue(DateTime.now())))
        .get();
  }

  /// Get trash count
  Future<int> getTrashCount({required String ownerId}) async {
    final query = selectOnly(trashTable)
      ..addColumns([trashTable.id.count()])
      ..where(trashTable.ownerId.equals(ownerId));
    final result = await query.getSingle();
    return result.read(trashTable.id.count()) ?? 0;
  }
}
