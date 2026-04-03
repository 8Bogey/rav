import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/database/daos/trash_dao.dart';
import 'package:mawlid_al_dhaki/core/convex/convex_config.dart';
import 'package:mawlid_al_dhaki/core/auth/auth0_service.dart';
import 'package:uuid/uuid.dart';

/// Service for managing the trash bin.
/// Handles move to trash, restore, and permanent delete operations.
class TrashService {
  final AppDatabase database;
  late final TrashDao _trashDao;
  static const _uuid = Uuid();
  static const int _trashExpiryDays = 30;

  TrashService(this.database) {
    _trashDao = database.trashDao;
  }

  String _getCurrentOwnerId() {
    final auth = Auth0Service.instance;
    final userId = auth.userId;
    if (userId != null && userId.isNotEmpty) {
      return userId;
    }
    return 'demo-user';
  }

  /// Move an entity to trash.
  Future<bool> moveToTrash({
    required String entityType,
    required String entityId,
    required Map<String, dynamic> entityData,
  }) async {
    final ownerId = _getCurrentOwnerId();
    final id = _uuid.v4();
    final now = DateTime.now();
    final expiresAt = now.add(Duration(days: _trashExpiryDays));

    // Create local trash record
    final trashItem = TrashTableCompanion.insert(
      id: id,
      entityType: entityType,
      entityId: entityId,
      entityData: jsonEncode(entityData),
      ownerId: ownerId,
      deletedAt: now,
      expiresAt: expiresAt,
      createdAt: now,
      updatedAt: now,
    );

    await _trashDao.insertTrashItem(trashItem);

    // Sync to Convex
    try {
      await AppConvexConfig.mutation('mutations/trash:moveToTrash', {
        'ownerId': ownerId,
        'entityType': entityType,
        'entityId': entityId,
        'entityData': jsonEncode(entityData),
        'deletedBy': ownerId,
      });
    } catch (e) {
      debugPrint('[TrashService] Failed to sync moveToTrash to Convex: $e');
    }

    debugPrint('[TrashService] Moved $entityType/$entityId to trash');
    return true;
  }

  /// Restore an entity from trash.
  /// This re-inserts the entity into the original table and syncs to Convex.
  Future<bool> restoreFromTrash(String trashId) async {
    final ownerId = _getCurrentOwnerId();
    
    // Get trash item
    final items = await _trashDao.getAllTrashItems(ownerId: ownerId);
    final trashItem = items.firstWhere((item) => item.id == trashId);
    final entityData = jsonDecode(trashItem.entityData) as Map<String, dynamic>;

    // Re-insert entity into original table based on entityType
    await _restoreEntityToTable(trashItem.entityType, entityData, ownerId);

    // Delete from local trash
    await _trashDao.deleteTrashItem(trashId);

    // Sync to Convex - this will set isDeleted: false on the remote entity
    try {
      await AppConvexConfig.mutation('mutations/trash:restoreFromTrash', {
        'ownerId': ownerId,
        'entityType': trashItem.entityType,
        'entityId': trashItem.entityId,
      });
    } catch (e) {
      debugPrint('[TrashService] Failed to sync restoreFromTrash to Convex: $e');
    }

    debugPrint('[TrashService] Restored ${trashItem.entityType}/${trashItem.entityId} from trash');
    return true;
  }

  /// Re-insert an entity into its original table based on entityType.
  Future<void> _restoreEntityToTable(
    String entityType,
    Map<String, dynamic> data,
    String ownerId,
  ) async {
    final now = DateTime.now();
    
    switch (entityType) {
      case 'subscribers':
        final companion = SubscribersTableCompanion(
          id: Value(data['id'] as String),
          ownerId: Value(ownerId),
          name: Value(data['name'] as String),
          code: Value(data['code'] as String),
          cabinet: Value(data['cabinet'] as String),
          phone: Value(data['phone'] as String),
          status: Value(data['status'] as int),
          startDate: Value(DateTime.parse(data['startDate'] as String)),
          accumulatedDebt: Value(data['accumulatedDebt'] as double),
          tags: Value(data['tags'] as String?),
          notes: Value(data['notes'] as String?),
          version: Value(data['version'] as int? ?? 1),
          isDeleted: const Value(false),
          createdAt: Value(now),
          updatedAt: Value(now),
        );
        await database.subscribersDao.addSubscriber(companion);
        break;
        
      case 'cabinets':
        DateTime? completionDate;
        if (data['completionDate'] != null) {
          try {
            completionDate = DateTime.parse(data['completionDate'] as String);
          } catch (_) {}
        }
        final companion = CabinetsTableCompanion(
          id: Value(data['id'] as String),
          ownerId: Value(ownerId),
          name: Value(data['name'] as String),
          letter: Value(data['letter'] as String? ?? ''),
          totalSubscribers: Value(data['totalSubscribers'] as int),
          currentSubscribers: Value(data['currentSubscribers'] as int),
          collectedAmount: Value(data['collectedAmount'] as double),
          delayedSubscribers: Value(data['delayedSubscribers'] as int),
          completionDate: Value(completionDate),
          version: Value(data['version'] as int? ?? 1),
          isDeleted: const Value(false),
          createdAt: Value(now),
          updatedAt: Value(now),
        );
        await database.cabinetsDao.addCabinet(companion);
        break;
        
      case 'payments':
        final companion = PaymentsTableCompanion(
          id: Value(data['id'] as String),
          ownerId: Value(ownerId),
          subscriberId: Value(data['subscriberId'] as String),
          amount: Value(data['amount'] as double),
          worker: Value(data['worker'] as String),
          date: Value(DateTime.parse(data['date'] as String)),
          cabinet: Value(data['cabinet'] as String),
          version: Value(data['version'] as int? ?? 1),
          isDeleted: const Value(false),
          createdAt: Value(now),
          updatedAt: Value(now),
        );
        await database.paymentsDao.addPayment(companion);
        break;
        
      case 'workers':
        final companion = WorkersTableCompanion(
          id: Value(data['id'] as String),
          ownerId: Value(ownerId),
          name: Value(data['name'] as String),
          phone: Value(data['phone'] as String),
          permissions: Value(data['permissions'] as String),
          todayCollected: Value(data['todayCollected'] as double),
          monthTotal: Value(data['monthTotal'] as double),
          version: Value(data['version'] as int? ?? 1),
          isDeleted: const Value(false),
          createdAt: Value(now),
          updatedAt: Value(now),
        );
        await database.workersDao.addWorker(companion);
        break;
        
      default:
        debugPrint('[TrashService] Unknown entity type: $entityType');
    }
  }

  /// Permanently delete an entity from trash.
  /// This hard-deletes the entity from the original table if it exists.
  Future<bool> permanentlyDelete(String trashId) async {
    final ownerId = _getCurrentOwnerId();
    
    // Get trash item
    final items = await _trashDao.getAllTrashItems(ownerId: ownerId);
    final trashItem = items.firstWhere((item) => item.id == trashId);

    // Hard-delete entity from original table if it still exists (soft-deleted)
    await _hardDeleteEntityFromTable(trashItem.entityType, trashItem.entityId, ownerId);

    // Delete from local trash
    await _trashDao.deleteTrashItem(trashId);

    // Sync to Convex - this will delete the remote entity
    try {
      await AppConvexConfig.mutation('mutations/trash:permanentlyDelete', {
        'ownerId': ownerId,
        'entityType': trashItem.entityType,
        'entityId': trashItem.entityId,
      });
    } catch (e) {
      debugPrint('[TrashService] Failed to sync permanentlyDelete to Convex: $e');
    }

    debugPrint('[TrashService] Permanently deleted ${trashItem.entityType}/${trashItem.entityId}');
    return true;
  }

  /// Hard-delete an entity from its original table.
  Future<void> _hardDeleteEntityFromTable(
    String entityType,
    String entityId,
    String ownerId,
  ) async {
    try {
      switch (entityType) {
        case 'subscribers':
          await (database.delete(database.subscribersTable)
            ..where((t) => t.id.equals(entityId) & t.ownerId.equals(ownerId)))
              .go();
          break;
        case 'cabinets':
          await (database.delete(database.cabinetsTable)
            ..where((t) => t.id.equals(entityId) & t.ownerId.equals(ownerId)))
              .go();
          break;
        case 'payments':
          await (database.delete(database.paymentsTable)
            ..where((t) => t.id.equals(entityId) & t.ownerId.equals(ownerId)))
              .go();
          break;
        case 'workers':
          await (database.delete(database.workersTable)
            ..where((t) => t.id.equals(entityId) & t.ownerId.equals(ownerId)))
              .go();
          break;
        default:
          debugPrint('[TrashService] Unknown entity type for hard delete: $entityType');
      }
    } catch (e) {
      debugPrint('[TrashService] Error hard deleting entity: $e');
    }
  }

  /// Empty all trash.
  Future<bool> emptyTrash() async {
    final ownerId = _getCurrentOwnerId();
    
    // Get all trash items and hard-delete their entities first
    final items = await _trashDao.getAllTrashItems(ownerId: ownerId);
    for (final item in items) {
      await _hardDeleteEntityFromTable(item.entityType, item.entityId, ownerId);
    }
    
    final count = await _trashDao.deleteAllTrashItems(ownerId);

    // Sync to Convex
    try {
      await AppConvexConfig.mutation('mutations/trash:emptyTrash', {
        'ownerId': ownerId,
      });
    } catch (e) {
      debugPrint('[TrashService] Failed to sync emptyTrash to Convex: $e');
    }

    debugPrint('[TrashService] Emptied trash ($count items)');
    return true;
  }

  /// Get all trash items
  Future<List<TrashItem>> getTrashItems() async {
    final ownerId = _getCurrentOwnerId();
    return _trashDao.getAllTrashItems(ownerId: ownerId);
  }

  /// Watch trash items
  Stream<List<TrashItem>> watchTrashItems() {
    final ownerId = _getCurrentOwnerId();
    return _trashDao.watchAllTrashItems(ownerId: ownerId);
  }

  /// Get trash count
  Future<int> getTrashCount() async {
    final ownerId = _getCurrentOwnerId();
    return _trashDao.getTrashCount(ownerId: ownerId);
  }

  /// Delete expired trash items locally
  Future<int> cleanupExpiredTrash() async {
    final expired = await _trashDao.getExpiredTrashItems();
    int deleted = 0;
    for (final item in expired) {
      await _hardDeleteEntityFromTable(item.entityType, item.entityId, item.ownerId);
      await _trashDao.deleteTrashItem(item.id);
      deleted++;
    }
    debugPrint('[TrashService] Cleaned up $deleted expired trash items');
    return deleted;
  }
}
