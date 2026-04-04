import 'package:drift/drift.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';

part 'sync_metadata_dao.g.dart';

@DriftAccessor(tables: [SyncMetadataTable])
class SyncMetadataDao extends DatabaseAccessor<AppDatabase>
    with _$SyncMetadataDaoMixin {
  SyncMetadataDao(AppDatabase db) : super(db);

  /// Get sync metadata for a specific entity table.
  Future<SyncMetadataEntry?> getSyncMetadata(String tableName) {
    return (select(syncMetadataTable)
          ..where((t) => t.entityTableName.equals(tableName)))
        .getSingleOrNull();
  }

  /// Update or insert sync metadata for a table (upsert).
  Future<void> updateSyncMetadata({
    required String tableName,
    required int lastSyncTimestamp,
    String? syncCursor,
  }) async {
    final entry = SyncMetadataTableCompanion(
      entityTableName: Value(tableName),
      lastSyncTimestamp: Value(lastSyncTimestamp),
      syncCursor: Value(syncCursor),
      lastSyncAt: Value(DateTime.now()),
    );
    await into(syncMetadataTable).insertOnConflictUpdate(entry);
  }

  /// Get the last sync timestamp for a table, defaulting to 0.
  Future<int> getLastSyncTimestamp(String tableName) async {
    final metadata = await getSyncMetadata(tableName);
    return metadata?.lastSyncTimestamp ?? 0;
  }
}
