import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/database/daos/workers_dao.dart';
import 'package:mawlid_al_dhaki/core/services/base_service.dart';
import 'package:mawlid_al_dhaki/core/services/outbox_service.dart';
import 'package:mawlid_al_dhaki/core/services/trash_service.dart';
import 'package:uuid/uuid.dart';

class WorkersService extends BaseService {
  WorkersService(super.database);

  WorkersDao get _dao => database.workersDao;
  late final OutboxService _outbox = OutboxService(database);
  static const _uuid = Uuid();

  // Get all workers
  Future<List<Worker>> getAllWorkers({required String ownerId}) {
    return _dao.getAllWorkers(ownerId: ownerId);
  }

  // Get worker by ID
  Future<Worker?> getWorkerById(String id, {required String ownerId}) {
    return _dao.getWorkerById(id, ownerId: ownerId);
  }

  // Get worker by name
  Future<Worker?> getWorkerByName(String name, {required String ownerId}) {
    return _dao.getWorkerByName(name, ownerId: ownerId);
  }

  // Add a new worker
  Future<String> addWorker(Worker worker, {required String ownerId}) {
    final id = _uuid.v4();
    final now = DateTime.now();
    final companion = WorkersTableCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      name: Value(worker.name),
      phone: Value(worker.phone),
      permissions: Value(worker.permissions),
      todayCollected: Value(worker.todayCollected),
      monthTotal: Value(worker.monthTotal),
      version: const Value(1),
      isDeleted: const Value(false),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    // Add to outbox for Convex sync
    _outbox.addEntry(
      targetTable: 'workers',
      operationType: 'create',
      documentId: id,
      payload: {
        'cloudId': id, // Client's local UUID for tracking
        'ownerId': ownerId,
        'name': worker.name,
        'phone': worker.phone,
        'permissions': worker.permissions,
        'todayCollected': worker.todayCollected,
        'monthTotal': worker.monthTotal,
        'version': 1,
        'isDeleted': false,
        'updatedAt': now.millisecondsSinceEpoch,
        'createdAt': now.millisecondsSinceEpoch,
      },
    );

    return _dao.addWorker(companion);
  }

  // Update a worker
  Future<bool> updateWorker(Worker worker, {required String ownerId}) {
    final now = DateTime.now();
    final newVersion = (worker.version ?? 0) + 1;
    final companion = worker.toCompanion(false).copyWith(
          ownerId: Value(ownerId),
          version: Value(newVersion),
          updatedAt: Value(now),
        );

    // Add to outbox for Convex sync
    _outbox.addEntry(
      targetTable: 'workers',
      operationType: 'update',
      documentId: worker.id,
      payload: {
        'id': worker.id,
        'ownerId': ownerId,
        'name': worker.name,
        'phone': worker.phone,
        'permissions': worker.permissions,
        'todayCollected': worker.todayCollected,
        'monthTotal': worker.monthTotal,
        'version': newVersion,
        'isDeleted': worker.isDeleted,
        'updatedAt': now.millisecondsSinceEpoch,
        'createdAt': worker.createdAt?.millisecondsSinceEpoch ??
            now.millisecondsSinceEpoch,
      },
    );

    return _dao.updateWorker(companion);
  }

  // Soft delete a worker (move to trash first)
  Future<bool> deleteWorker(String id, {required String ownerId}) async {
    final now = DateTime.now();
    final existing = await _dao.getWorkerById(id, ownerId: ownerId);
    final newVersion = (existing?.version ?? 0) + 1;

    // Move to trash before soft deleting
    if (existing != null) {
      try {
        final trashService = TrashService(database);
        await trashService.moveToTrash(
          entityType: 'workers',
          entityId: id,
          entityData: {
            'id': existing.id,
            'name': existing.name,
            'phone': existing.phone,
            'permissions': existing.permissions,
            'todayCollected': existing.todayCollected,
            'monthTotal': existing.monthTotal,
            'ownerId': ownerId,
            'version': existing.version,
          },
        );
        debugPrint('[WorkersService] Moved worker to trash');
      } catch (e) {
        debugPrint('[WorkersService] Failed to move worker to trash: $e');
      }
    }

    final companion = WorkersTableCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      isDeleted: const Value(true),
      version: Value(newVersion),
      updatedAt: Value(now),
    );

    // Add to outbox for Convex sync
    // Use cloudId for delete lookup (local UUID)
    _outbox.addEntry(
      targetTable: 'workers',
      operationType: 'delete',
      documentId: id,
      payload: {
        'cloudId': id, // Send cloudId for lookup instead of Convex id
        'ownerId': ownerId,
        'version': newVersion,
      },
    );

    return _dao.updateWorker(companion);
  }

  // Watch all workers (reactive stream)
  Stream<List<Worker>> watchWorkers({required String ownerId}) {
    return _dao.watchAllWorkers(ownerId: ownerId);
  }
}
