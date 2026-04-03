import 'package:drift/drift.dart';
import '../app_database.dart';

part 'payments_dao.g.dart';

@DriftAccessor(tables: [PaymentsTable])
class PaymentsDao extends DatabaseAccessor<AppDatabase>
    with _$PaymentsDaoMixin {
  PaymentsDao(super.db);

  // Get all active payments - REQUIRES ownerId
  Future<List<Payment>> getAllPayments({required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);
    
    return (select(paymentsTable)
      ..where((tbl) => tbl.ownerId.equals(ownerId))
      ..where((tbl) => tbl.isDeleted.equals(false)))
        .get();
  }

  // Watch all active payments - REQUIRES ownerId
  Stream<List<Payment>> watchAllPayments({required String ownerId}) {
    if (ownerId.isEmpty) return Stream.value([]);
    
    return (select(paymentsTable)
      ..where((tbl) => tbl.ownerId.equals(ownerId))
      ..where((tbl) => tbl.isDeleted.equals(false)))
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

  // Get payments by subscriber ID (UUID) - REQUIRES ownerId
  Future<List<Payment>> getPaymentsBySubscriberId(String subscriberId, {required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);
    
    return (select(paymentsTable)
      ..where((tbl) => tbl.ownerId.equals(ownerId))
      ..where((tbl) => tbl.subscriberId.equals(subscriberId)))
        .get();
  }

  // Watch payments by subscriber - REQUIRES ownerId
  Stream<List<Payment>> watchPaymentsBySubscriber(String subscriberId, {required String ownerId}) {
    if (ownerId.isEmpty) return Stream.value([]);
    
    return (select(paymentsTable)
      ..where((tbl) => tbl.ownerId.equals(ownerId))
      ..where((tbl) => tbl.subscriberId.equals(subscriberId)))
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
          isDeleted: const Value(true),
          updatedAt: Value(DateTime.now()),
        ));
  }

  // Hard delete
  Future<int> hardDeletePayment(String id) {
    return (delete(paymentsTable)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Get dirty payments - REQUIRES ownerId
  Future<List<Payment>> getDirtyPayments({required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);
    
    return (select(paymentsTable)
      ..where((tbl) => tbl.ownerId.equals(ownerId))
      ..where((tbl) => tbl.dirtyFlag.equals(true)))
        .get();
  }

  // Mark a payment record as dirty
  Future<int> markRecordAsDirty(String id) {
    return (update(paymentsTable)..where((tbl) => tbl.id.equals(id)))
        .write(PaymentsTableCompanion(
          dirtyFlag: const Value(true),
          updatedAt: Value(DateTime.now()),
        ));
  }

  // Clear dirty flag
  Future<int> clearDirtyFlag(String id) {
    return (update(paymentsTable)..where((tbl) => tbl.id.equals(id)))
        .write(const PaymentsTableCompanion(dirtyFlag: Value(false)));
  }

  // Update last synced timestamp
  Future<int> updateLastSyncedAt(String id) {
    return (update(paymentsTable)..where((tbl) => tbl.id.equals(id)))
        .write(PaymentsTableCompanion(
          lastSyncedAt: Value(DateTime.now()),
        ));
  }
  
  // Get payments by date range - REQUIRES ownerId
  Future<List<Payment>> getPaymentsByDateRange(DateTime start, DateTime end, {required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);
    
    return (select(paymentsTable)
      ..where((tbl) => tbl.ownerId.equals(ownerId))
      ..where((tbl) => tbl.date.isBiggerOrEqualValue(start))
      ..where((tbl) => tbl.date.isSmallerOrEqualValue(end)))
        .get();
  }
  
  // Get payments by worker - REQUIRES ownerId
  Future<List<Payment>> getPaymentsByWorker(String worker, {required String ownerId}) {
    if (ownerId.isEmpty) return Future.value([]);
    
    return (select(paymentsTable)
      ..where((tbl) => tbl.ownerId.equals(ownerId))
      ..where((tbl) => tbl.worker.equals(worker)))
        .get();
  }
  
  // Sum payments amount - REQUIRES ownerId
  Future<double> sumPaymentsAmount({required String ownerId, DateTime? startDate, DateTime? endDate}) async {
    if (ownerId.isEmpty) return 0.0;
    
    var query = selectOnly(paymentsTable)
      ..addColumns([paymentsTable.amount.sum()])
      ..where(paymentsTable.ownerId.equals(ownerId))
      ..where(paymentsTable.isDeleted.equals(false));
    
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
  Future<int> countPayments({required String ownerId, DateTime? startDate, DateTime? endDate}) async {
    if (ownerId.isEmpty) return 0;
    
    var query = selectOnly(paymentsTable)
      ..addColumns([paymentsTable.id.count()])
      ..where(paymentsTable.ownerId.equals(ownerId))
      ..where(paymentsTable.isDeleted.equals(false));
    
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