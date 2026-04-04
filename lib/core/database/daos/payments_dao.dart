import 'package:drift/drift.dart';
import '../app_database.dart';

part 'payments_dao.g.dart';

@DriftAccessor(tables: [PaymentsTable])
class PaymentsDao extends DatabaseAccessor<AppDatabase>
    with _$PaymentsDaoMixin {
  PaymentsDao(super.db);

  // Get all active payments - uses composite index (by_ownerId_inTrash)
  Future<List<Payment>> getAllPayments({required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);

    return (select(paymentsTable)
          ..where((t) => t.ownerId.equals(ownerId) & t.inTrash.equals(false)))
        .get();
  }

  // Watch all active payments - uses composite index (by_ownerId_inTrash)
  Stream<List<Payment>> watchAllPayments({required String ownerId}) {
    if (ownerId.isEmpty) return Stream.value([]);

    return (select(paymentsTable)
          ..where((t) => t.ownerId.equals(ownerId) & t.inTrash.equals(false)))
        .watch();
  }

  // Get payment by ID (UUID) - REQUIRES ownerId
  Future<Payment?> getPaymentById(String id, {required String ownerId}) async {
    if (ownerId.isEmpty) return null;

    return await (select(paymentsTable)
          ..where((tbl) => tbl.id.equals(id))
          ..where((tbl) => tbl.ownerId.equals(ownerId)))
        .getSingleOrNull();
  }

  // Get payments by subscriber ID - uses composite index (by_ownerId_subscriberId_inTrash)
  Future<List<Payment>> getPaymentsBySubscriberId(String subscriberId,
      {required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);

    return (select(paymentsTable)
          ..where((t) =>
              t.ownerId.equals(ownerId) &
              t.subscriberId.equals(subscriberId) &
              t.inTrash.equals(false)))
        .get();
  }

  // Watch payments by subscriber - uses composite index (by_ownerId_subscriberId_inTrash)
  Stream<List<Payment>> watchPaymentsBySubscriber(String subscriberId,
      {required String ownerId}) {
    if (ownerId.isEmpty) return Stream.value([]);

    return (select(paymentsTable)
          ..where((t) =>
              t.ownerId.equals(ownerId) &
              t.subscriberId.equals(subscriberId) &
              t.inTrash.equals(false)))
        .watch();
  }

  // Add a new payment
  Future<String> addPayment(Insertable<Payment> payment) async {
    return await into(paymentsTable).insert(payment).then((_) {
      final comp = payment as PaymentsTableCompanion;
      return comp.id.value;
    });
  }

  // Insert payment and return ID
  Future<String> insertPayment(Insertable<Payment> payment) async {
    return await into(paymentsTable).insert(payment).then((_) {
      final comp = payment as PaymentsTableCompanion;
      return comp.id.value;
    });
  }

  // Update a payment
  Future<bool> updatePayment(Insertable<Payment> payment) {
    // Use write() for partial updates instead of replace() which requires all fields
    final comp = payment as PaymentsTableCompanion;
    return (update(paymentsTable)..where((tbl) => tbl.id.equals(comp.id.value)))
        .write(payment)
        .then((rows) => rows > 0);
  }

  // Soft delete a payment
  Future<int> deletePayment(String id) {
    return (update(paymentsTable)..where((tbl) => tbl.id.equals(id)))
        .write(PaymentsTableCompanion(
      inTrash: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));
  }

  // Hard delete
  Future<int> hardDeletePayment(String id) {
    return (delete(paymentsTable)..where((tbl) => tbl.id.equals(id))).go();
  }

  // NOTE: dirtyFlag, lastSyncedAt, syncStatus, cloudId, deletedLocally,
  // permissionsMask, lastModified fields removed from schema.
  // Sync-related DAO methods (getDirtyPayments, markRecordAsDirty,
  // clearDirtyFlag, updateLastSyncedAt) have been removed.

  // Get payments by date range - REQUIRES ownerId
  Future<List<Payment>> getPaymentsByDateRange(DateTime start, DateTime end,
      {required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);

    return (select(paymentsTable)
          ..where((tbl) => tbl.ownerId.equals(ownerId))
          ..where((tbl) => tbl.date.isBiggerOrEqualValue(start))
          ..where((tbl) => tbl.date.isSmallerOrEqualValue(end)))
        .get();
  }

  // Get payments by worker - uses composite index (by_ownerId_worker_inTrash)
  Future<List<Payment>> getPaymentsByWorker(String worker,
      {required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);

    return (select(paymentsTable)
          ..where((t) =>
              t.ownerId.equals(ownerId) &
              t.worker.equals(worker) &
              t.inTrash.equals(false)))
        .get();
  }

  // Get payments by cabinet - uses composite index (by_ownerId_cabinet_inTrash)
  Future<List<Payment>> getPaymentsByCabinet(String cabinet,
      {required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);

    return (select(paymentsTable)
          ..where((t) =>
              t.ownerId.equals(ownerId) &
              t.cabinet.equals(cabinet) &
              t.inTrash.equals(false)))
        .get();
  }

  // Sum payments amount - REQUIRES ownerId
  Future<double> sumPaymentsAmount(
      {required String ownerId, DateTime? startDate, DateTime? endDate}) async {
    if (ownerId.isEmpty) return 0.0;

    var query = selectOnly(paymentsTable)
      ..addColumns([paymentsTable.amount.sum()])
      ..where(paymentsTable.ownerId.equals(ownerId))
      ..where(paymentsTable.inTrash.equals(false));

    if (startDate != null) {
      query.where(paymentsTable.date.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where(paymentsTable.date.isSmallerOrEqualValue(endDate));
    }

    final result = await query.getSingle();
    return result.read(paymentsTable.amount.sum()) ?? 0.0;
  }

  // Count payments - REQUIRES ownerId
  Future<int> countPayments(
      {required String ownerId, DateTime? startDate, DateTime? endDate}) async {
    if (ownerId.isEmpty) return 0;

    var query = selectOnly(paymentsTable)
      ..addColumns([paymentsTable.id.count()])
      ..where(paymentsTable.ownerId.equals(ownerId))
      ..where(paymentsTable.inTrash.equals(false));

    if (startDate != null) {
      query.where(paymentsTable.date.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where(paymentsTable.date.isSmallerOrEqualValue(endDate));
    }

    final result = await query.getSingle();
    return result.read(paymentsTable.id.count()) ?? 0;
  }
}
