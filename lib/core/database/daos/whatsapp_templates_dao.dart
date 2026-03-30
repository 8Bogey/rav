import 'package:drift/drift.dart';
import '../app_database.dart';

part 'whatsapp_templates_dao.g.dart';

@DriftAccessor(tables: [WhatsappTemplatesTable])
class WhatsappTemplatesDao extends DatabaseAccessor<AppDatabase>
    with _$WhatsappTemplatesDaoMixin {
  WhatsappTemplatesDao(super.db);

  // Get all WhatsApp templates
  Future<List<WhatsappTemplateData>> getAllTemplates() =>
      select(whatsappTemplatesTable).get();

  // Get template by ID
  Future<WhatsappTemplateData?> getTemplateById(int id) async {
    return await (select(whatsappTemplatesTable)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  // Get active template
  Future<WhatsappTemplateData?> getActiveTemplate() async {
    return await (select(whatsappTemplatesTable)
          ..where((tbl) => tbl.isActive.equals(1)))
        .getSingleOrNull();
  }

  // Add a new template
  Future<int> addTemplate(Insertable<WhatsappTemplateData> template) {
    return into(whatsappTemplatesTable).insert(template);
  }

  // Update a template
  Future<bool> updateTemplate(Insertable<WhatsappTemplateData> template) {
    return update(whatsappTemplatesTable).replace(template);
  }

  // Delete a template
  Future<int> deleteTemplate(int id) {
    return (delete(whatsappTemplatesTable)..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  // Get dirty templates (those with dirtyFlag = true)
  Future<List<WhatsappTemplateData>> getDirtyTemplates() {
    return (select(whatsappTemplatesTable)..where((tbl) => tbl.dirtyFlag.equals(true))).get();
  }
  
  // Update sync status for a template
  Future<int> updateSyncStatus(int id, String status) {
    return (update(whatsappTemplatesTable)..where((tbl) => tbl.id.equals(id)))
        .write(WhatsappTemplatesTableCompanion(syncStatus: Value(status)));
  }
  
  // Mark a template record as dirty (needing sync)
  Future<int> markRecordAsDirty(int id) {
    return (update(whatsappTemplatesTable)..where((tbl) => tbl.id.equals(id)))
        .write(const WhatsappTemplatesTableCompanion(
          dirtyFlag: Value(true),
          lastModified: Value.absent(), // This will use the default timestamp
        ));
  }
  
  // Clear dirty flag for a template record
  Future<int> clearDirtyFlag(int id) {
    return (update(whatsappTemplatesTable)..where((tbl) => tbl.id.equals(id)))
        .write(const WhatsappTemplatesTableCompanion(dirtyFlag: Value(false)));
  }
  
  // Mark a template record for manual conflict resolution
  Future<int> markConflictForManualResolution(int id) {
    return (update(whatsappTemplatesTable)..where((tbl) => tbl.id.equals(id)))
        .write(WhatsappTemplatesTableCompanion(
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
    return (update(whatsappTemplatesTable)..where((tbl) => tbl.id.equals(id)))
        .write(WhatsappTemplatesTableCompanion(
          conflictResolutionStrategy: Value(conflictResolutionStrategy),
          conflictResolvedAt: Value(conflictResolvedAt),
          conflictOrigin: Value(conflictOrigin),
        ));
  }
  
  // Mark record as deleted locally
  Future<int> markDeletedLocally(int id) {
    return (update(whatsappTemplatesTable)..where((tbl) => tbl.id.equals(id)))
        .write(WhatsappTemplatesTableCompanion(
          deletedLocally: Value(true),
          dirtyFlag: Value(true),
          lastModified: Value(DateTime.now()),
        ));
  }
  
  // Undelete a record
  Future<int> undeleteRecord(int id) {
    return (update(whatsappTemplatesTable)..where((tbl) => tbl.id.equals(id)))
        .write(WhatsappTemplatesTableCompanion(
          deletedLocally: Value(false),
          dirtyFlag: Value(true),
          lastModified: Value(DateTime.now()),
        ));
  }
  
  // Update sync error information
  Future<int> updateSyncError(int id, String errorMessage) {
    return (update(whatsappTemplatesTable)..where((tbl) => tbl.id.equals(id)))
        .write(WhatsappTemplatesTableCompanion(
          lastSyncError: Value(errorMessage),
          syncRetryCount: Value.absent(), // Increment retry count in service layer
        ));
  }
  
  // Increment sync retry count
  Future<int> incrementSyncRetryCount(int id) {
    return (update(whatsappTemplatesTable)..where((tbl) => tbl.id.equals(id)))
        .write(const WhatsappTemplatesTableCompanion(
          syncRetryCount: Value.absent(), // This will need to be handled in service layer
        ));
  }
}