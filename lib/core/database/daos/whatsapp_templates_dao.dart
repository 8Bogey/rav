import 'package:drift/drift.dart';
import '../app_database.dart';

part 'whatsapp_templates_dao.g.dart';

@DriftAccessor(tables: [WhatsappTemplatesTable])
class WhatsappTemplatesDao extends DatabaseAccessor<AppDatabase>
    with _$WhatsappTemplatesDaoMixin {
  WhatsappTemplatesDao(super.db);

  // Get all active WhatsApp templates - uses composite index (by_ownerId_inTrash)
  Future<List<WhatsappTemplateData>> getAllTemplates(
      {required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);

    return (select(whatsappTemplatesTable)
          ..where((t) => t.ownerId.equals(ownerId) & t.inTrash.equals(false)))
        .get();
  }

  // Watch all active templates - uses composite index (by_ownerId_inTrash)
  Stream<List<WhatsappTemplateData>> watchAllTemplates(
      {required String ownerId}) {
    if (ownerId.isEmpty) return Stream.value([]);

    return (select(whatsappTemplatesTable)
          ..where((t) => t.ownerId.equals(ownerId) & t.inTrash.equals(false)))
        .watch();
  }

  // Get template by ID (UUID) - REQUIRES ownerId
  Future<WhatsappTemplateData?> getTemplateById(String id,
      {required String ownerId}) async {
    if (ownerId.isEmpty) return null;

    return await (select(whatsappTemplatesTable)
          ..where((tbl) => tbl.id.equals(id))
          ..where((tbl) => tbl.ownerId.equals(ownerId)))
        .getSingleOrNull();
  }

  // Get active template - uses composite index (by_ownerId_isActive_inTrash)
  Future<WhatsappTemplateData?> getActiveTemplate(
      {required String ownerId}) async {
    if (ownerId.isEmpty) return null;

    return (select(whatsappTemplatesTable)
          ..where((t) =>
              t.ownerId.equals(ownerId) &
              t.isActive.equals(true) &
              t.inTrash.equals(false)))
        .getSingleOrNull();
  }

  // Get active WhatsApp templates - uses composite index (by_ownerId_isActive_inTrash)
  Future<List<WhatsappTemplateData>> getActiveWhatsappTemplates(
      {required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);

    return (select(whatsappTemplatesTable)
          ..where((t) =>
              t.ownerId.equals(ownerId) &
              t.isActive.equals(true) &
              t.inTrash.equals(false)))
        .get();
  }

  // Add a new template
  Future<String> addTemplate(Insertable<WhatsappTemplateData> template) async {
    return await into(whatsappTemplatesTable).insert(template).then((_) {
      final comp = template as WhatsappTemplatesTableCompanion;
      return comp.id.value;
    });
  }

  // Insert template and return ID
  Future<String> insertTemplate(
      Insertable<WhatsappTemplateData> template) async {
    return await into(whatsappTemplatesTable).insert(template).then((_) {
      final comp = template as WhatsappTemplatesTableCompanion;
      return comp.id.value;
    });
  }

  // Update a template
  Future<bool> updateTemplate(Insertable<WhatsappTemplateData> template) {
    return update(whatsappTemplatesTable).replace(template);
  }

  // Soft delete a template
  Future<int> deleteTemplate(String id) {
    return (update(whatsappTemplatesTable)..where((tbl) => tbl.id.equals(id)))
        .write(const WhatsappTemplatesTableCompanion(
      inTrash: Value(true),
    ));
  }

  // Hard delete
  Future<int> hardDeleteTemplate(String id) {
    return (delete(whatsappTemplatesTable)..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  // NOTE: dirtyFlag, lastSyncedAt, syncStatus, cloudId, deletedLocally,
  // permissionsMask, lastModified fields removed from schema.
  // Sync-related DAO methods (getDirtyTemplates, markRecordAsDirty,
  // clearDirtyFlag, updateLastSyncedAt) have been removed.

  // Set active template (deactivate others first) - REQUIRES ownerId
  Future<void> setActiveTemplate(String id, {required String ownerId}) async {
    if (ownerId.isEmpty) return;

    await transaction(() async {
      // Deactivate all templates for this owner
      final allTemplates = await getAllTemplates(ownerId: ownerId);
      for (final template in allTemplates) {
        if (template.id != id) {
          await (update(whatsappTemplatesTable)
                ..where((tbl) => tbl.id.equals(template.id)))
              .write(const WhatsappTemplatesTableCompanion(
                  isActive: Value(false)));
        }
      }

      // Activate the selected template
      await (update(whatsappTemplatesTable)..where((tbl) => tbl.id.equals(id)))
          .write(const WhatsappTemplatesTableCompanion(isActive: Value(true)));
    });
  }

  // Count templates - uses composite index (by_ownerId_inTrash)
  Future<int> countTemplates({required String ownerId}) async {
    if (ownerId.isEmpty) return 0;

    final query = selectOnly(whatsappTemplatesTable)
      ..addColumns([whatsappTemplatesTable.id.count()])
      ..where(whatsappTemplatesTable.ownerId.equals(ownerId))
      ..where(whatsappTemplatesTable.inTrash.equals(false));

    final result = await query.getSingle();
    return result.read(whatsappTemplatesTable.id.count()) ?? 0;
  }
}
