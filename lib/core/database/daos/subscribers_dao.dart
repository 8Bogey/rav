import 'package:drift/drift.dart';
import '../app_database.dart';

part 'subscribers_dao.g.dart';

@DriftAccessor(tables: [SubscribersTable])
class SubscribersDao extends DatabaseAccessor<AppDatabase>
    with _$SubscribersDaoMixin {
  SubscribersDao(super.db);

  /// Get active subscribers - REQUIRES ownerId for tenant isolation
  /// Returns empty list if ownerId is null (no data leak)
  Future<List<Subscriber>> getAllSubscribers({required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);

    final query = select(subscribersTable)
      ..where((tbl) => tbl.ownerId.equals(ownerId))
      ..where((tbl) => tbl.isDeleted.equals(false));

    return query.get();
  }

  /// Watch active subscribers - REQUIRES ownerId for tenant isolation
  Stream<List<Subscriber>> watchAllSubscribers({required String ownerId}) {
    if (ownerId.isEmpty) return Stream.value([]);

    final query = select(subscribersTable)
      ..where((tbl) => tbl.ownerId.equals(ownerId))
      ..where((tbl) => tbl.isDeleted.equals(false));

    return query.watch();
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
      isDeleted: Value(true),
      updatedAt: Value(null), // Will be set by copyWith in service
    ));
  }

  // Hard delete (only for cleanup, not normal use)
  Future<int> hardDeleteSubscriber(String id) {
    return (delete(subscribersTable)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Search subscribers by name or code - REQUIRES ownerId
  Future<List<Subscriber>> searchSubscribers(String query,
      {required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);

    return (select(subscribersTable)
          ..where((tbl) => tbl.ownerId.equals(ownerId))
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..where(
              (tbl) => tbl.name.like('%$query%') | tbl.code.like('%$query%')))
        .get();
  }

  // Watch search results - REQUIRES ownerId
  Stream<List<Subscriber>> watchSearchSubscribers(String query,
      {required String ownerId}) {
    if (ownerId.isEmpty) return Stream.value([]);

    return (select(subscribersTable)
          ..where((tbl) => tbl.ownerId.equals(ownerId))
          ..where((tbl) => tbl.isDeleted.equals(false))
          ..where(
              (tbl) => tbl.name.like('%$query%') | tbl.code.like('%$query%')))
        .watch();
  }

  // Get dirty subscribers - REQUIRES ownerId
  Future<List<Subscriber>> getDirtySubscribers({required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);

    return (select(subscribersTable)
          ..where((tbl) => tbl.ownerId.equals(ownerId))
          ..where((tbl) => tbl.dirtyFlag.equals(true)))
        .get();
  }

  // Mark a subscriber record as dirty (needing sync)
  Future<int> markRecordAsDirty(String id) {
    return (update(subscribersTable)..where((tbl) => tbl.id.equals(id)))
        .write(SubscribersTableCompanion(
      dirtyFlag: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));
  }

  // Clear dirty flag for a subscriber record
  Future<int> clearDirtyFlag(String id) {
    return (update(subscribersTable)..where((tbl) => tbl.id.equals(id)))
        .write(const SubscribersTableCompanion(dirtyFlag: Value(false)));
  }

  // Update last synced timestamp
  Future<int> updateLastSyncedAt(String id) {
    return (update(subscribersTable)..where((tbl) => tbl.id.equals(id)))
        .write(SubscribersTableCompanion(
      lastSyncedAt: Value(DateTime.now()),
    ));
  }

  // Get subscribers by cabinet - REQUIRES ownerId
  Future<List<Subscriber>> getSubscribersByCabinet(String cabinet,
      {required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);

    return (select(subscribersTable)
          ..where((tbl) => tbl.ownerId.equals(ownerId))
          ..where((tbl) => tbl.cabinet.equals(cabinet))
          ..where((tbl) => tbl.isDeleted.equals(false)))
        .get();
  }

  // Count active subscribers - REQUIRES ownerId
  Future<int> countActiveSubscribers({required String ownerId}) async {
    if (ownerId.isEmpty) return 0;

    final query = selectOnly(subscribersTable)
      ..addColumns([subscribersTable.id.count()])
      ..where(subscribersTable.ownerId.equals(ownerId))
      ..where(subscribersTable.status.equals(1)) // 1 = active
      ..where(subscribersTable.isDeleted.equals(false));

    final result = await query.getSingle();
    return result.read(subscribersTable.id.count()) ?? 0;
  }

  // Sum total debt - REQUIRES ownerId
  Future<double> sumAccumulatedDebt({required String ownerId}) async {
    if (ownerId.isEmpty) return 0.0;

    final query = selectOnly(subscribersTable)
      ..addColumns([subscribersTable.accumulatedDebt.sum()])
      ..where(subscribersTable.ownerId.equals(ownerId))
      ..where(subscribersTable.isDeleted.equals(false));

    final result = await query.getSingle();
    return result.read(subscribersTable.accumulatedDebt.sum()) ?? 0.0;
  }
}
