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
    final trashItem = TrashTableCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      entityData: Value(jsonEncode(entityData)),
      ownerId: Value(ownerId),
      deletedAt: Value(now),
      expiresAt: Value(expiresAt),
      createdAt: Value(now),
      updatedAt: Value(now),
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
  Future<bool> restoreFromTrash(String trashId) async {
    final ownerId = _getCurrentOwnerId();
    
    // Get trash item
    final items = await _trashDao.getAllTrashItems(ownerId: ownerId);
    final trashItem = items.firstWhere((item) => item.id == trashId);

    // Delete from local trash
    await _trashDao.deleteTrashItem(trashId);

    // Sync to Convex
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

  /// Permanently delete an entity from trash.
  Future<bool> permanentlyDelete(String trashId) async {
    final ownerId = _getCurrentOwnerId();
    
    // Get trash item
    final items = await _trashDao.getAllTrashItems(ownerId: ownerId);
    final trashItem = items.firstWhere((item) => item.id == trashId);

    // Delete from local trash
    await _trashDao.deleteTrashItem(trashId);

    // Sync to Convex
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

  /// Empty all trash.
  Future<bool> emptyTrash() async {
    final ownerId = _getCurrentOwnerId();
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
      await _trashDao.deleteTrashItem(item.id);
      deleted++;
    }
    debugPrint('[TrashService] Cleaned up $deleted expired trash items');
    return deleted;
  }
}
