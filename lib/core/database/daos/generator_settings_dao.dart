import 'package:drift/drift.dart';
import '../app_database.dart';

part 'generator_settings_dao.g.dart';

@DriftAccessor(tables: [GeneratorSettingsTable])
class GeneratorSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$GeneratorSettingsDaoMixin {
  GeneratorSettingsDao(super.db);

  /// Get generator settings - uses unique owner index (unique_ownerId)
  Future<GeneratorSettingsData?> getSettings({required String ownerId}) async {
    if (ownerId.isEmpty) return null;

    return (select(generatorSettingsTable)
          ..where((t) => t.ownerId.equals(ownerId)))
        .getSingleOrNull();
  }

  /// Watch generator settings - uses unique owner index (unique_ownerId)
  Stream<GeneratorSettingsData?> watchSettings({required String ownerId}) {
    if (ownerId.isEmpty) return Stream.value(null);

    return (select(generatorSettingsTable)
          ..where((t) => t.ownerId.equals(ownerId)))
        .watchSingleOrNull();
  }

  /// Insert or update generator settings (upsert pattern)
  Future<void> upsertSettings(GeneratorSettingsTableCompanion settings) async {
    await into(generatorSettingsTable).insertOnConflictUpdate(settings);
  }

  /// Update existing settings
  Future<bool> updateSettings(GeneratorSettingsTableCompanion settings) async {
    final comp = settings;
    return (update(generatorSettingsTable)
          ..where((tbl) => tbl.id.equals(comp.id.value)))
        .write(settings)
        .then((rows) => rows > 0);
  }

  /// Soft delete settings - uses inTrash instead of isDeleted
  Future<bool> softDeleteSettings(String id) {
    return (update(generatorSettingsTable)..where((tbl) => tbl.id.equals(id)))
        .write(GeneratorSettingsTableCompanion(
          inTrash: const Value(true),
          updatedAt: Value(DateTime.now()),
        ))
        .then((rows) => rows > 0);
  }

  /// Get all generator settings for owner (singleton pattern - returns max 1)
  Future<List<GeneratorSettingsData>> getAllGeneratorSettings(
      {required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);

    return (select(generatorSettingsTable)
          ..where((t) => t.ownerId.equals(ownerId))
          ..limit(1))
        .get();
  }
}
