import 'package:drift/drift.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/database/daos/generator_settings_dao.dart';
import 'package:mawlid_al_dhaki/core/services/base_service.dart';
import 'package:mawlid_al_dhaki/core/services/outbox_service.dart';
import 'package:uuid/uuid.dart';

class GeneratorSettingsService extends BaseService {
  GeneratorSettingsService(super.database);

  GeneratorSettingsDao get _dao => database.generatorSettingsDao;
  late final OutboxService _outbox = OutboxService(database);

  /// Get generator settings for the current owner
  Future<GeneratorSettingsData?> getSettings({required String ownerId}) {
    return _dao.getSettings(ownerId: ownerId);
  }

  /// Watch generator settings - REQUIRES ownerId
  Stream<GeneratorSettingsData?> watchSettings({required String ownerId}) {
    return _dao.watchSettings(ownerId: ownerId);
  }

  /// Save or update generator settings
  Future<String> saveSettings({
    required String ownerId,
    required String name,
    required String phoneNumber,
    required String address,
    String? logoPath,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();

    // Check if settings already exist
    final existing = await _dao.getSettings(ownerId: ownerId);

    final companion = GeneratorSettingsTableCompanion(
      id: Value(existing?.id ?? id),
      ownerId: Value(ownerId),
      name: Value(name),
      phoneNumber: Value(phoneNumber),
      address: Value(address),
      logoPath: Value(logoPath),
      version: Value((existing?.version ?? 0) + 1),
      inTrash: const Value(false),
      createdAt: Value(existing?.createdAt ?? now),
      updatedAt: Value(now),
    );

    await _dao.upsertSettings(companion);

    // Add to outbox for Convex sync
    _outbox.addEntry(
      targetTable: 'generatorSettings',
      operationType: existing != null ? 'update' : 'create',
      documentId: existing?.id ?? id,
      payload: {
        'cloudId': existing?.id ?? id,
        'ownerId': ownerId,
        'name': name,
        'phoneNumber': phoneNumber,
        'address': address,
        'logoPath': logoPath,
        'version': (existing?.version ?? 0) + 1,
        'inTrash': false,
        'updatedAt': now.millisecondsSinceEpoch,
        'createdAt': (existing?.createdAt ?? now).millisecondsSinceEpoch,
      },
    );

    return existing?.id ?? id;
  }

  /// Delete generator settings (soft delete)
  Future<bool> deleteSettings(String id, {required String ownerId}) async {
    final existing = await _dao.getSettings(ownerId: ownerId);
    if (existing == null) return false;

    final now = DateTime.now();
    final newVersion = (existing.version ?? 0) + 1;

    final companion = GeneratorSettingsTableCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      inTrash: const Value(true),
      version: Value(newVersion),
      updatedAt: Value(now),
    );

    await _dao.updateSettings(companion);

    // Add to outbox for Convex sync
    _outbox.addEntry(
      targetTable: 'generatorSettings',
      operationType: 'delete',
      documentId: id,
      payload: {
        'cloudId': id,
        'ownerId': ownerId,
        'version': newVersion,
      },
    );

    return true;
  }
}
