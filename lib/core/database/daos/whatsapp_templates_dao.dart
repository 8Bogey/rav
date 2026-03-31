import 'package:drift/drift.dart';
import '../app_database.dart';

part 'whatsapp_templates_dao.g.dart';

@DriftAccessor(tables: [WhatsappTemplatesTable])
class WhatsappTemplatesDao extends DatabaseAccessor<AppDatabase>
    with _$WhatsappTemplatesDaoMixin {
  WhatsappTemplatesDao(super.db);

  // Get all active WhatsApp templates - REQUIRES ownerId
  Future<List<WhatsappTemplateData>> getAllTemplates({required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);
    
    return (select(whatsappTemplatesTable)
      ..where((tbl) => tbl.ownerId.equals(ownerId))
      ..where((tbl) => tbl.isDeleted.equals(false)))
        .get();
  }

  // Watch all active templates - REQUIRES ownerId
  Stream<List<WhatsappTemplateData>> watchAllTemplates({required String ownerId}) {
    if (ownerId.isEmpty) return Stream.value([]);
    
    return (select(whatsappTemplatesTable)
      ..where((tbl) => tbl.ownerId.equals(ownerId))
      ..where((tbl) => tbl.isDeleted.equals(false)))
        .watch();
  }

  // Get template by ID (UUID) - REQUIRES ownerId
  Future<WhatsappTemplateData?> getTemplateById(String id, {required String ownerId}) async {
    if (ownerId.isEmpty) return null;
    
    return await (select(whatsappTemplatesTable)
      ..where((tbl) => tbl.id.equals(id))
      ..where((tbl) => tbl.ownerId.equals(ownerId)))
        .getSingleOrNull();
  }

  // Get active template - REQUIRES ownerId
  Future<WhatsappTemplateData?> getActiveTemplate({required String ownerId}) async {
    if (ownerId.isEmpty) return null;
    
    return await (select(whatsappTemplatesTable)
      ..where((tbl) => tbl.ownerId.equals(ownerId))
      ..where((tbl) => tbl.isActive.equals(1)))
        .getSingleOrNull();
  }

  // Add a new template
  Future<String> addTemplate(Insertable<WhatsappTemplateData> template) async {
    return await into(whatsappTemplatesTable).insert(template).then((_) {
      final comp = template as WhatsappTemplatesTableCompanion;
      return comp.id.value;
    });
  }

  // Insert template and return ID
  Future<String> insertTemplate(Insertable<WhatsappTemplateData> template) async {
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
          isDeleted: Value(true),
        ));
  }

  // Hard delete
  Future<int> hardDeleteTemplate(String id) {
    return (delete(whatsappTemplatesTable)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Get dirty templates - REQUIRES ownerId
  Future<List<WhatsappTemplateData>> getDirtyTemplates({required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);
    
    return (select(whatsappTemplatesTable)
      ..where((tbl) => tbl.ownerId.equals(ownerId))
      ..where((tbl) => tbl.dirtyFlag.equals(true)))
        .get();
  }

  // Mark a template record as dirty
  Future<int> markRecordAsDirty(String id) {
    return (update(whatsappTemplatesTable)..where((tbl) => tbl.id.equals(id)))
        .write(WhatsappTemplatesTableCompanion(
          dirtyFlag: const Value(true),
          updatedAt: Value(DateTime.now()),
        ));
  }

  // Clear dirty flag
  Future<int> clearDirtyFlag(String id) {
    return (update(whatsappTemplatesTable)..where((tbl) => tbl.id.equals(id)))
        .write(const WhatsappTemplatesTableCompanion(dirtyFlag: Value(false)));
  }

  // Update last synced timestamp
  Future<int> updateLastSyncedAt(String id) {
    return (update(whatsappTemplatesTable)..where((tbl) => tbl.id.equals(id)))
        .write(WhatsappTemplatesTableCompanion(
          lastSyncedAt: Value(DateTime.now()),
        ));
  }
  
  // Set active template (deactivate others first) - REQUIRES ownerId
  Future<void> setActiveTemplate(String id, {required String ownerId}) async {
    if (ownerId.isEmpty) return;
    
    await transaction(() async {
      // Deactivate all templates for this owner
      final allTemplates = await getAllTemplates(ownerId: ownerId);
      for (final template in allTemplates) {
        if (template.id != id) {
          await (update(whatsappTemplatesTable)..where((tbl) => tbl.id.equals(template.id)))
              .write(const WhatsappTemplatesTableCompanion(isActive: Value(0)));
        }
      }
      
      // Activate the selected template
      await (update(whatsappTemplatesTable)..where((tbl) => tbl.id.equals(id)))
          .write(const WhatsappTemplatesTableCompanion(isActive: Value(1)));
    });
  }
  
  // Count templates - REQUIRES ownerId
  Future<int> countTemplates({required String ownerId}) async {
    if (ownerId.isEmpty) return 0;
    
    final query = selectOnly(whatsappTemplatesTable)
      ..addColumns([whatsappTemplatesTable.id.count()])
      ..where(whatsappTemplatesTable.ownerId.equals(ownerId))
      ..where(whatsappTemplatesTable.isDeleted.equals(false));
    
    final result = await query.getSingle();
    return result.read(whatsappTemplatesTable.id.count()) ?? 0;
  }
}