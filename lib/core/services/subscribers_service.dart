import 'package:drift/drift.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/database/daos/subscribers_dao.dart';
import 'package:mawlid_al_dhaki/core/services/base_service.dart';

class SubscribersService extends BaseService {
  late SubscribersDao _dao;

  SubscribersService(AppDatabase database) : super(database) {
    _dao = SubscribersDao(database);
  }

  // Get all subscribers
  Future<List<Subscriber>> getAllSubscribers() {
    return _dao.getAllSubscribers();
  }

  // Get subscriber by ID
  Future<Subscriber?> getSubscriberById(int id) {
    return _dao.getSubscriberById(id);
  }

  // Get subscriber by code
  Future<Subscriber?> getSubscriberByCode(String code) {
    return _dao.getSubscriberByCode(code);
  }

  // Add a new subscriber
  Future<int> addSubscriber(Subscriber subscriber) {
    // For inserts, we want to let the database auto-generate the ID
    final companion = SubscribersTableCompanion(
      name: Value(subscriber.name),
      code: Value(subscriber.code),
      cabinet: Value(subscriber.cabinet),
      phone: Value(subscriber.phone),
      status: Value(subscriber.status),
      startDate: Value(subscriber.startDate),
      accumulatedDebt: Value(subscriber.accumulatedDebt),
      tags: Value(subscriber.tags),
      notes: Value(subscriber.notes),
    );
    return _dao.addSubscriber(companion);
  }

  // Update a subscriber
  Future<bool> updateSubscriber(Subscriber subscriber) {
    final companion = subscriber.toCompanion(false);
    return _dao.updateSubscriber(companion);
  }

  // Delete a subscriber
  Future<int> deleteSubscriber(int id) {
    return _dao.deleteSubscriber(id);
  }

  // Search subscribers by name or code
  Future<List<Subscriber>> searchSubscribers(String query) {
    return _dao.searchSubscribers(query);
  }

  // Get dirty subscribers (those with dirtyFlag = true)
  Future<List<Subscriber>> getDirtySubscribers() {
    return _dao.getDirtySubscribers();
  }
  
  // Mark a subscriber record for manual conflict resolution
  Future<int> markConflictForManualResolution(int id) {
    return _dao.markConflictForManualResolution(id);
  }
  
  // Update conflict resolution information
  Future<int> updateConflictResolution(int id, {
    String? conflictResolutionStrategy,
    DateTime? conflictResolvedAt,
    String? conflictOrigin,
  }) {
    return _dao.updateConflictResolution(
      id,
      conflictResolutionStrategy: conflictResolutionStrategy,
      conflictResolvedAt: conflictResolvedAt,
      conflictOrigin: conflictOrigin,
    );
  }
  
  // Mark record as deleted locally
  Future<int> markDeletedLocally(int id) {
    return _dao.markDeletedLocally(id);
  }
  
  // Undelete a record
  Future<int> undeleteRecord(int id) {
    return _dao.undeleteRecord(id);
  }
  
  // Update sync error information and increment retry count
  Future<int> updateSyncError(int id, String errorMessage) async {
    // First get the current subscriber to read the current retry count
    final subscriber = await getSubscriberById(id);
    if (subscriber != null) {
      final currentRetryCount = subscriber.syncRetryCount ?? 0;
      // Update with error message and incremented retry count
      return _dao.updateSyncErrorWithRetryCount(id, errorMessage, currentRetryCount + 1);
    }
    return 0;
  }
  
  // Increment sync retry count
  Future<int> incrementSyncRetryCount(int id) async {
    // Get the current subscriber to read the current retry count
    final subscriber = await getSubscriberById(id);
    if (subscriber != null) {
      final currentRetryCount = subscriber.syncRetryCount ?? 0;
      return _dao.updateSyncRetryCount(id, currentRetryCount + 1);
    }
    return 0;
  }
  
  // Update sync status
  Future<int> updateSyncStatus(int id, String status) {
    return _dao.updateSyncStatus(id, status);
  }
  
  // Mark record as dirty
  Future<int> markRecordAsDirty(int id) {
    return _dao.markRecordAsDirty(id);
  }
  
  // Clear dirty flag
  Future<int> clearDirtyFlag(int id) {
    return _dao.clearDirtyFlag(id);
  }
}