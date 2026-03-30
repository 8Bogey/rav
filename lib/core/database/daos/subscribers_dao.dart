import 'package:drift/drift.dart';
import '../app_database.dart';

part 'subscribers_dao.g.dart';

@DriftAccessor(tables: [SubscribersTable])
class SubscribersDao extends DatabaseAccessor<AppDatabase>
    with _$SubscribersDaoMixin {
  SubscribersDao(super.db);

  // Get all subscribers
  Future<List<Subscriber>> getAllSubscribers() => select(subscribersTable).get();

  // Get subscriber by ID
  Future<Subscriber?> getSubscriberById(int id) async {
    return await (select(subscribersTable)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  // Get subscriber by code
  Future<Subscriber?> getSubscriberByCode(String code) async {
    return await (select(subscribersTable)..where((tbl) => tbl.code.equals(code))).getSingleOrNull();
  }

  // Add a new subscriber
  Future<int> addSubscriber(Insertable<Subscriber> subscriber) {
    return into(subscribersTable).insert(subscriber);
  }

  // Update a subscriber
  Future<bool> updateSubscriber(Insertable<Subscriber> subscriber) {
    return update(subscribersTable).replace(subscriber);
  }

  // Delete a subscriber
  Future<int> deleteSubscriber(int id) {
    return (delete(subscribersTable)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Search subscribers by name or code
  Future<List<Subscriber>> searchSubscribers(String query) {
    return (select(subscribersTable)
          ..where((tbl) => tbl.name.like('%$query%') | tbl.code.like('%$query%')))
        .get();
  }

  // Get dirty subscribers (those with dirtyFlag = true)
  Future<List<Subscriber>> getDirtySubscribers() {
    return (select(subscribersTable)..where((tbl) => tbl.dirtyFlag.equals(true))).get();
  }

  // Update sync status for a subscriber
  Future<int> updateSyncStatus(int id, String status) {
    return (update(subscribersTable)..where((tbl) => tbl.id.equals(id)))
        .write(SubscribersTableCompanion(syncStatus: Value(status)));
  }
  
  // Mark a subscriber record as dirty (needing sync)
  Future<int> markRecordAsDirty(int id) {
    return (update(subscribersTable)..where((tbl) => tbl.id.equals(id)))
        .write(const SubscribersTableCompanion(
          dirtyFlag: Value(true),
          lastModified: Value.absent(), // This will use the default timestamp
        ));
  }
  
  // Clear dirty flag for a subscriber record
  Future<int> clearDirtyFlag(int id) {
    return (update(subscribersTable)..where((tbl) => tbl.id.equals(id)))
        .write(const SubscribersTableCompanion(dirtyFlag: Value(false)));
  }
  
  // Mark a subscriber record for manual conflict resolution
  Future<int> markConflictForManualResolution(int id) {
    return (update(subscribersTable)..where((tbl) => tbl.id.equals(id)))
        .write(SubscribersTableCompanion(
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
    return (update(subscribersTable)..where((tbl) => tbl.id.equals(id)))
        .write(SubscribersTableCompanion(
          conflictResolutionStrategy: Value(conflictResolutionStrategy),
          conflictResolvedAt: Value(conflictResolvedAt),
          conflictOrigin: Value(conflictOrigin),
        ));
  }
  
  // Mark record as deleted locally
  Future<int> markDeletedLocally(int id) {
    return (update(subscribersTable)..where((tbl) => tbl.id.equals(id)))
        .write(SubscribersTableCompanion(
          deletedLocally: Value(true),
          dirtyFlag: Value(true),
          lastModified: Value(DateTime.now()),
        ));
  }
  
  // Undelete a record
  Future<int> undeleteRecord(int id) {
    return (update(subscribersTable)..where((tbl) => tbl.id.equals(id)))
        .write(SubscribersTableCompanion(
          deletedLocally: Value(false),
          dirtyFlag: Value(true),
          lastModified: Value(DateTime.now()),
        ));
  }
  
  // Update sync error information
  Future<int> updateSyncError(int id, String errorMessage) {
    return (update(subscribersTable)..where((tbl) => tbl.id.equals(id)))
        .write(SubscribersTableCompanion(
          lastSyncError: Value(errorMessage),
        ));
  }
  
  // Update sync error information with retry count
  Future<int> updateSyncErrorWithRetryCount(int id, String errorMessage, int retryCount) {
    return (update(subscribersTable)..where((tbl) => tbl.id.equals(id)))
        .write(SubscribersTableCompanion(
          lastSyncError: Value(errorMessage),
          syncRetryCount: Value(retryCount),
        ));
  }
  
  // Update sync retry count
  Future<int> updateSyncRetryCount(int id, int retryCount) {
    return (update(subscribersTable)..where((tbl) => tbl.id.equals(id)))
        .write(SubscribersTableCompanion(
          syncRetryCount: Value(retryCount),
        ));
  }
  
  // Increment sync retry count (handled in service layer with proper read/increment logic)
  Future<int> incrementSyncRetryCount(int id) {
    // This will be handled in the service layer where we can read the current value
    // and increment it properly
    return Future.value(0);
  }
  
  // Reset sync error and retry count after successful sync
  Future<int> resetSyncError(int id) {
    return (update(subscribersTable)..where((tbl) => tbl.id.equals(id)))
        .write(const SubscribersTableCompanion(
          lastSyncError: Value(null),
          syncRetryCount: Value(0),
        ));
  }
  
  // Update last synced timestamp
  Future<int> updateLastSyncedAt(int id) {
    return (update(subscribersTable)..where((tbl) => tbl.id.equals(id)))
        .write(SubscribersTableCompanion(
          lastSyncedAt: Value(DateTime.now()),
        ));
  }
}