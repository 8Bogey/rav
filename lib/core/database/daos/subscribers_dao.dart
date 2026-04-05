import 'package:drift/drift.dart';
import '../app_database.dart';

part 'subscribers_dao.g.dart';

@DriftAccessor(tables: [SubscribersTable])
class SubscribersDao extends DatabaseAccessor<AppDatabase>
    with _$SubscribersDaoMixin {
  SubscribersDao(super.db);

  /// Get active subscribers - uses composite index (by_ownerId_inTrash)
  Future<List<Subscriber>> getAllSubscribers({required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);

    return (select(subscribersTable)
          ..where((t) => t.ownerId.equals(ownerId) & t.inTrash.equals(false)))
        .get();
  }

  /// Watch active subscribers - uses composite index (by_ownerId_inTrash)
  Stream<List<Subscriber>> watchAllSubscribers({required String ownerId}) {
    if (ownerId.isEmpty) return Stream.value([]);

    return (select(subscribersTable)
          ..where((t) => t.ownerId.equals(ownerId) & t.inTrash.equals(false)))
        .watch();
  }

  // Get subscriber by ID (UUID) - REQUIRES ownerId
  Future<Subscriber?> getSubscriberById(String id,
      {required String ownerId}) async {
    if (ownerId.isEmpty) return null;

    return await (select(subscribersTable)
          ..where((tbl) => tbl.id.equals(id))
          ..where((tbl) => tbl.ownerId.equals(ownerId)))
        .getSingleOrNull();
  }

  // Get subscriber by code - REQUIRES ownerId
  Future<Subscriber?> getSubscriberByCode(String code,
      {required String ownerId}) async {
    if (ownerId.isEmpty) return null;

    return await (select(subscribersTable)
          ..where((tbl) => tbl.code.equals(code))
          ..where((tbl) => tbl.ownerId.equals(ownerId)))
        .getSingleOrNull();
  }

  // Add a new subscriber (with auto-generated UUID)
  Future<String> addSubscriber(Insertable<Subscriber> subscriber) {
    return into(subscribersTable).insert(subscriber).then((_) {
      // Return the ID that was inserted
      final comp = subscriber as SubscribersTableCompanion;
      return comp.id.value;
    });
  }

  // Add subscriber and return the ID
  Future<String> insertSubscriber(Insertable<Subscriber> subscriber) async {
    return await into(subscribersTable).insert(subscriber).then((_) {
      final comp = subscriber as SubscribersTableCompanion;
      return comp.id.value;
    });
  }

  // Update a subscriber
  Future<bool> updateSubscriber(Insertable<Subscriber> subscriber) async {
    // Use write() instead of replace() to allow partial updates
    // For replace(), all required fields must be present
    final comp = subscriber as SubscribersTableCompanion;
    final rowsAffected = await (update(subscribersTable)
          ..where((tbl) => tbl.id.equals(comp.id.value)))
        .write(subscriber);
    return rowsAffected > 0;
  }

  // Soft delete a subscriber (mark as deleted)
  Future<int> deleteSubscriber(String id) {
    return (update(subscribersTable)..where((tbl) => tbl.id.equals(id)))
        .write(const SubscribersTableCompanion(
      inTrash: Value(true),
      updatedAt: Value(null), // Will be set by copyWith in service
    ));
  }

  // Hard delete (only for cleanup, not normal use)
  Future<int> hardDeleteSubscriber(String id) {
    return (delete(subscribersTable)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Search subscribers by name or code - uses composite index prefix
  Future<List<Subscriber>> searchSubscribers(String query,
      {required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);

    return (select(subscribersTable)
          ..where((t) =>
              t.ownerId.equals(ownerId) &
              t.inTrash.equals(false) &
              (t.name.like('%$query%') | t.code.like('%$query%'))))
        .get();
  }

  // Watch search results - uses composite index prefix
  Stream<List<Subscriber>> watchSearchSubscribers(String query,
      {required String ownerId}) {
    if (ownerId.isEmpty) return Stream.value([]);

    return (select(subscribersTable)
          ..where((t) =>
              t.ownerId.equals(ownerId) &
              t.inTrash.equals(false) &
              (t.name.like('%$query%') | t.code.like('%$query%'))))
        .watch();
  }

  // NOTE: dirtyFlag, lastSyncedAt, syncStatus, cloudId, deletedLocally,
  // permissionsMask, lastModified fields removed from schema.
  // Sync-related DAO methods (getDirtySubscribers, markRecordAsDirty,
  // clearDirtyFlag, updateLastSyncedAt) have been removed.

  // Get subscribers by cabinet - uses composite index (by_ownerId_cabinet_inTrash)
  Future<List<Subscriber>> getSubscribersByCabinet(String cabinet,
      {required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);

    return (select(subscribersTable)
          ..where((t) =>
              t.ownerId.equals(ownerId) &
              t.cabinet.equals(cabinet) &
              t.inTrash.equals(false)))
        .get();
  }

  // Get subscribers by status - uses composite index (by_ownerId_status_inTrash)
  Future<List<Subscriber>> getSubscribersByStatus(String status,
      {required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);

    return (select(subscribersTable)
          ..where((t) =>
              t.ownerId.equals(ownerId) &
              t.status.equals(status) &
              t.inTrash.equals(false)))
        .get();
  }

  // Get paginated subscribers - uses composite index (by_ownerId_inTrash)
  Future<List<Subscriber>> getPaginatedSubscribers({
    required String ownerId,
    int limit = 50,
    int offset = 0,
  }) {
    if (ownerId.isEmpty) return Future.value([]);
    return (select(subscribersTable)
          ..where((t) => t.ownerId.equals(ownerId) & t.inTrash.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.name)])
          ..limit(limit, offset: offset))
        .get();
  }

  // Count active subscribers - REQUIRES ownerId
  Future<int> countActiveSubscribers({required String ownerId}) async {
    if (ownerId.isEmpty) return 0;

    final query = selectOnly(subscribersTable)
      ..addColumns([subscribersTable.id.count()])
      ..where(subscribersTable.ownerId.equals(ownerId))
      ..where(subscribersTable.status.equals('active'))
      ..where(subscribersTable.inTrash.equals(false));

    final result = await query.getSingle();
    return result.read(subscribersTable.id.count()) ?? 0;
  }

  // Count all active subscribers (non-trashed) - REQUIRES ownerId
  Future<int> countSubscribers({required String ownerId}) async {
    if (ownerId.isEmpty) return 0;

    final query = selectOnly(subscribersTable)
      ..addColumns([subscribersTable.id.count()])
      ..where(subscribersTable.ownerId.equals(ownerId))
      ..where(subscribersTable.inTrash.equals(false));

    final result = await query.getSingle();
    return result.read(subscribersTable.id.count()) ?? 0;
  }

  // Sum total debt - REQUIRES ownerId
  Future<double> sumAccumulatedDebt({required String ownerId}) async {
    if (ownerId.isEmpty) return 0.0;

    final query = selectOnly(subscribersTable)
      ..addColumns([subscribersTable.accumulatedDebt.sum()])
      ..where(subscribersTable.ownerId.equals(ownerId))
      ..where(subscribersTable.inTrash.equals(false));

    final result = await query.getSingle();
    return result.read(subscribersTable.accumulatedDebt.sum()) ?? 0.0;
  }
}
