import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/database/daos/cabinets_dao.dart';
import 'package:mawlid_al_dhaki/core/services/base_service.dart';
import 'package:mawlid_al_dhaki/core/services/outbox_service.dart';
import 'package:mawlid_al_dhaki/core/services/trash_service.dart';
import 'package:uuid/uuid.dart';

class CabinetsService extends BaseService {
  CabinetsService(super.database);

  CabinetsDao get _dao => database.cabinetsDao;
  late final OutboxService _outbox = OutboxService(database);

  // Get all cabinets
  Future<List<Cabinet>> getAllCabinets({required String ownerId}) {
    return _dao.getAllCabinets(ownerId: ownerId);
  }

  // Get cabinet by ID
  Future<Cabinet?> getCabinetById(String id, {required String ownerId}) {
    return _dao.getCabinetById(id, ownerId: ownerId);
  }

  // Get cabinet by name
  Future<Cabinet?> getCabinetByName(String name, {required String ownerId}) {
    return _dao.getCabinetByName(name, ownerId: ownerId);
  }

  // Add a new cabinet
  Future<String> addCabinet(Cabinet cabinet, {required String ownerId}) {
    if (cabinet.name.trim().isEmpty)
      throw ArgumentError('Name cannot be empty');
    if (cabinet.totalSubscribers < 0)
      throw ArgumentError('Total subscribers cannot be negative');
    if (cabinet.currentSubscribers < 0)
      throw ArgumentError('Current subscribers cannot be negative');
    if (cabinet.collectedAmount < 0)
      throw ArgumentError('Collected amount cannot be negative');
    if (cabinet.delayedSubscribers < 0)
      throw ArgumentError('Delayed subscribers cannot be negative');

    // Generate a UUID for the new cabinet
    final id = const Uuid().v4();
    final now = DateTime.now();

    final companion = CabinetsTableCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      name: Value(cabinet.name),
      letter: Value(cabinet.letter),
      totalSubscribers: Value(cabinet.totalSubscribers),
      currentSubscribers: Value(cabinet.currentSubscribers),
      collectedAmount: Value(cabinet.collectedAmount),
      delayedSubscribers: Value(cabinet.delayedSubscribers),
      completionDate: Value(cabinet.completionDate),
      createdAt: Value(now),
      updatedAt: Value(now),
      version: const Value(1),
      inTrash: const Value(false),
    );

    // Add to outbox for Convex sync
    // Use cloudId to track Convex document ID for updates
    _outbox.addEntry(
      targetTable: 'cabinets',
      operationType: 'create',
      documentId: id,
      payload: {
        'cloudId': id, // Use local UUID as cloudId for tracking
        'ownerId': ownerId,
        'name': cabinet.name,
        'letter': cabinet.letter,
        'totalSubscribers': cabinet.totalSubscribers,
        'currentSubscribers': cabinet.currentSubscribers,
        'collectedAmount': cabinet.collectedAmount,
        'delayedSubscribers': cabinet.delayedSubscribers,
        'completionDate': cabinet.completionDate?.millisecondsSinceEpoch,
        'version': 1,
        'inTrash': false,
        'updatedAt': now.millisecondsSinceEpoch,
        'createdAt': now.millisecondsSinceEpoch,
      },
    );

    return _dao.addCabinet(companion);
  }

  // Update a cabinet
  Future<bool> updateCabinet(Cabinet cabinet, {required String ownerId}) {
    final now = DateTime.now();
    final newVersion = (cabinet.version ?? 0) + 1;
    final companion = cabinet.toCompanion(false).copyWith(
          ownerId: Value(ownerId),
          version: Value(newVersion),
          updatedAt: Value(now),
        );

    // Add to outbox for Convex sync
    _outbox.addEntry(
      targetTable: 'cabinets',
      operationType: 'update',
      documentId: cabinet.id,
      payload: {
        'id': cabinet.id,
        'ownerId': ownerId,
        'name': cabinet.name,
        'letter': cabinet.letter,
        'totalSubscribers': cabinet.totalSubscribers,
        'currentSubscribers': cabinet.currentSubscribers,
        'collectedAmount': cabinet.collectedAmount,
        'delayedSubscribers': cabinet.delayedSubscribers,
        'completionDate': cabinet.completionDate?.millisecondsSinceEpoch,
        'version': newVersion,
        'inTrash': cabinet.inTrash,
        'updatedAt': now.millisecondsSinceEpoch,
        'createdAt': cabinet.createdAt?.millisecondsSinceEpoch ??
            now.millisecondsSinceEpoch,
      },
    );

    return _dao.updateCabinet(companion);
  }

  // Delete a cabinet (soft delete + move to trash)
  Future<bool> deleteCabinet(String id, {required String ownerId}) {
    debugPrint(
        '[CabinetsService] deleteCabinet called: id=$id, ownerId=$ownerId');
    return database.transaction(() async {
      final now = DateTime.now();
      final existing = await _dao.getCabinetById(id, ownerId: ownerId);
      debugPrint('[CabinetsService] existing cabinet: $existing');
      if (existing == null) return false;
      final newVersion = (existing.version ?? 0) + 1;
      debugPrint('[CabinetsService] newVersion: $newVersion');

      // Move to trash before soft deleting
      try {
        final trashService = TrashService(database);
        await trashService.moveToTrash(
          entityType: 'cabinets',
          entityId: id,
          entityData: {
            'id': existing.id,
            'name': existing.name,
            'letter': existing.letter,
            'totalSubscribers': existing.totalSubscribers,
            'currentSubscribers': existing.currentSubscribers,
            'collectedAmount': existing.collectedAmount,
            'delayedSubscribers': existing.delayedSubscribers,
            'completionDate': existing.completionDate?.toIso8601String(),
            'ownerId': ownerId,
            'version': existing.version,
          },
        );
        debugPrint('[CabinetsService] Moved cabinet to trash');
      } catch (e) {
        debugPrint('[CabinetsService] Failed to move cabinet to trash: $e');
      }

      // Use soft delete which only updates isDeleted and updatedAt
      final result = await _dao.softDeleteCabinet(id);
      debugPrint('[CabinetsService] softDeleteCabinet result: $result');

      // Add to outbox for Convex sync
      // Use cloudId for delete lookup (local UUID)
      _outbox.addEntry(
        targetTable: 'cabinets',
        operationType: 'delete',
        documentId: id,
        payload: {
          'cloudId': id, // Send cloudId for lookup instead of Convex id
          'ownerId': ownerId,
          'version': newVersion,
        },
      );
      debugPrint('[CabinetsService] outbox entry added');

      return result;
    });
  }
}
