import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/database/daos/subscribers_dao.dart';
import 'package:mawlid_al_dhaki/core/services/base_service.dart';
import 'package:mawlid_al_dhaki/core/services/outbox_service.dart';
import 'package:mawlid_al_dhaki/core/services/trash_service.dart';
import 'package:uuid/uuid.dart';

class SubscribersService extends BaseService {
  SubscribersService(super.database);

  SubscribersDao get _dao => database.subscribersDao;
  late final OutboxService _outbox = OutboxService(database);
  static const _uuid = Uuid();

  // Get all subscribers
  Future<List<Subscriber>> getAllSubscribers({required String ownerId}) {
    return _dao.getAllSubscribers(ownerId: ownerId);
  }

  // Get subscriber by ID
  Future<Subscriber?> getSubscriberById(String id, {required String ownerId}) {
    return _dao.getSubscriberById(id, ownerId: ownerId);
  }

  // Get subscriber by code
  Future<Subscriber?> getSubscriberByCode(String code,
      {required String ownerId}) {
    return _dao.getSubscriberByCode(code, ownerId: ownerId);
  }

  // Add a new subscriber
  Future<String> addSubscriber(Subscriber subscriber,
      {required String ownerId}) {
    final id = _uuid.v4();
    final now = DateTime.now();
    final companion = SubscribersTableCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      name: Value(subscriber.name),
      code: Value(subscriber.code),
      cabinet: Value(subscriber.cabinet),
      phone: Value(subscriber.phone),
      status: Value(subscriber.status),
      startDate: Value(subscriber.startDate),
      accumulatedDebt: Value(subscriber.accumulatedDebt),
      tags: Value(subscriber.tags),
      notes: Value(subscriber.notes),
      version: const Value(1),
      isDeleted: const Value(false),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    // Add to outbox for Convex sync
    // Include cloudId so Convex can persist it for later delete lookups
    _outbox.addEntry(
      targetTable: 'subscribers',
      operationType: 'create',
      documentId: id,
      payload: {
        'cloudId': id, // Client's local UUID for tracking
        'ownerId': ownerId,
        'name': subscriber.name,
        'code': subscriber.code,
        'cabinet': subscriber.cabinet,
        'phone': subscriber.phone,
        'status': subscriber.status,
        'startDate': subscriber.startDate.millisecondsSinceEpoch,
        'accumulatedDebt': subscriber.accumulatedDebt,
        'tags': subscriber.tags,
        'notes': subscriber.notes,
        'version': 1,
        'isDeleted': false,
        'updatedAt': now.millisecondsSinceEpoch,
        'createdAt': now.millisecondsSinceEpoch,
      },
    );

    return _dao.addSubscriber(companion);
  }

  // Update a subscriber
  Future<bool> updateSubscriber(Subscriber subscriber,
      {required String ownerId}) {
    final now = DateTime.now();
    final newVersion = (subscriber.version ?? 0) + 1;
    final companion = subscriber.toCompanion(false).copyWith(
          ownerId: Value(ownerId),
          version: Value(newVersion),
          updatedAt: Value(now),
        );

    // Add to outbox for Convex sync
    // NOTE: Update operations - include id if we have Convex ID tracked
    // For now, use local UUID but this needs Convex ID tracking for full support
    _outbox.addEntry(
      targetTable: 'subscribers',
      operationType: 'update',
      documentId: subscriber.id,
      payload: {
        // For updates, we need the Convex document ID - currently using local ID
        // This will need convexId field tracking for proper sync
        'id': subscriber.id, // TODO: Use Convex document ID when available
        'ownerId': ownerId,
        'name': subscriber.name,
        'code': subscriber.code,
        'cabinet': subscriber.cabinet,
        'phone': subscriber.phone,
        'status': subscriber.status,
        'startDate': subscriber.startDate.millisecondsSinceEpoch,
        'accumulatedDebt': subscriber.accumulatedDebt,
        'tags': subscriber.tags,
        'notes': subscriber.notes,
        'version': newVersion,
        'isDeleted': subscriber.isDeleted,
        'updatedAt': now.millisecondsSinceEpoch,
        'createdAt': subscriber.createdAt?.millisecondsSinceEpoch ??
            now.millisecondsSinceEpoch,
      },
    );

    return _dao.updateSubscriber(companion);
  }

  // Soft delete a subscriber (move to trash first)
  Future<bool> deleteSubscriber(String id, {required String ownerId}) async {
    final now = DateTime.now();
    // Get current subscriber to increment version
    final existing = await _dao.getSubscriberById(id, ownerId: ownerId);
    final newVersion = (existing?.version ?? 0) + 1;

    // Move to trash before soft deleting
    if (existing != null) {
      try {
        final trashService = TrashService(database);
        await trashService.moveToTrash(
          entityType: 'subscribers',
          entityId: id,
          entityData: {
            'id': existing.id,
            'name': existing.name,
            'code': existing.code,
            'cabinet': existing.cabinet,
            'phone': existing.phone,
            'status': existing.status,
            'startDate': existing.startDate.toIso8601String(),
            'accumulatedDebt': existing.accumulatedDebt,
            'tags': existing.tags,
            'notes': existing.notes,
            'ownerId': ownerId,
            'version': existing.version,
          },
        );
        debugPrint('[SubscribersService] Moved subscriber to trash');
      } catch (e) {
        debugPrint('[SubscribersService] Failed to move subscriber to trash: $e');
      }
    }

    final companion = SubscribersTableCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      isDeleted: const Value(true),
      version: Value(newVersion),
      updatedAt: Value(now),
    );

    // Add to outbox for Convex sync
    // Use cloudId for delete lookup (local UUID)
    _outbox.addEntry(
      targetTable: 'subscribers',
      operationType: 'delete',
      documentId: id,
      payload: {
        'cloudId': id, // Send cloudId for lookup instead of Convex id
        'ownerId': ownerId,
        'version': newVersion,
      },
    );

    return _dao.updateSubscriber(companion);
  }

  // Search subscribers by name or code
  Future<List<Subscriber>> searchSubscribers(String query,
      {required String ownerId}) {
    return _dao.searchSubscribers(query, ownerId: ownerId);
  }

  // Watch all subscribers (reactive stream)
  Stream<List<Subscriber>> watchSubscribers({required String ownerId}) {
    return _dao.watchAllSubscribers(ownerId: ownerId);
  }
}
