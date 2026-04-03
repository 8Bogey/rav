import 'package:drift/drift.dart';
import '../app_database.dart';

part 'generator_settings_dao.g.dart';

@DriftAccessor(tables: [GeneratorSettingsTable])
class GeneratorSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$GeneratorSettingsDaoMixin {
  GeneratorSettingsDao(super.db);

  /// Get generator settings for a specific owner
  Future<GeneratorSettingsData?> getSettings({required String ownerId}) async {
    if (ownerId.isEmpty) return null;

    return await (select(generatorSettingsTable)
          ..where((tbl) => tbl.ownerId.equals(ownerId))
          ..where((tbl) => tbl.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  /// Watch generator settings - REQUIRES ownerId
  Stream<GeneratorSettingsData?> watchSettings({required String ownerId}) {
    if (ownerId.isEmpty) return Stream.value(null);

    return (select(generatorSettingsTable)
          ..where((tbl) => tbl.ownerId.equals(ownerId))
          ..where((tbl) => tbl.isDeleted.equals(false)))
        .watchSingleOrNull();
  }

  /// Insert or update generator settings (upsert pattern)
  Future<void> upsertSettings(GeneratorSettingsTableCompanion settings) async {
    await into(generatorSettingsTable).insertOnConflictUpdate(settings);
  }

  /// Update existing settings
  Future<bool> updateSettings(
      GeneratorSettingsTableCompanion settings) async {
    final comp = settings;
    return (update(generatorSettingsTable)
          ..where((tbl) => tbl.id.equals(comp.id.value)))
        .write(settings)
        .then((rows) => rows > 0);
  }

  /// Soft delete settings
  Future<bool> softDeleteSettings(String id) {
    return (update(generatorSettingsTable)..where((tbl) => tbl.id.equals(id)))
        .write(GeneratorSettingsTableCompanion(
      isDeleted: const Value(true),
      updatedAt: Value(DateTime.now()),
    ))
        .then((rows) => rows > 0);
  }
}
