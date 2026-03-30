import 'package:drift/drift.dart';
import '../app_database.dart';

part 'payments_dao.g.dart';

@DriftAccessor(tables: [PaymentsTable])
class PaymentsDao extends DatabaseAccessor<AppDatabase>
    with _$PaymentsDaoMixin {
  PaymentsDao(super.db);

  // Get all payments
  Future<List<Payment>> getAllPayments() => select(paymentsTable).get();

  // Get payment by ID
  Future<Payment?> getPaymentById(int id) async {
    return await (select(paymentsTable)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  // Get payments by subscriber ID
  Future<List<Payment>> getPaymentsBySubscriberId(int subscriberId) {
    return (select(paymentsTable)..where((tbl) => tbl.subscriberId.equals(subscriberId))).get();
  }

  // Add a new payment
  Future<int> addPayment(Insertable<Payment> payment) {
    return into(paymentsTable).insert(payment);
  }

  // Update a payment
  Future<bool> updatePayment(Insertable<Payment> payment) {
    return update(paymentsTable).replace(payment);
  }

  // Delete a payment
  Future<int> deletePayment(int id) {
    return (delete(paymentsTable)..where((tbl) => tbl.id.equals(id))).go();
  }

  // Get dirty payments (those with dirtyFlag = true)
  Future<List<Payment>> getDirtyPayments() {
    return (select(paymentsTable)..where((tbl) => tbl.dirtyFlag.equals(true))).get();
  }
  
  // Update sync status for a payment
  Future<int> updateSyncStatus(int id, String status) {
    return (update(paymentsTable)..where((tbl) => tbl.id.equals(id)))
        .write(PaymentsTableCompanion(syncStatus: Value(status)));
  }
  
  // Mark a payment record as dirty (needing sync)
  Future<int> markRecordAsDirty(int id) {
    return (update(paymentsTable)..where((tbl) => tbl.id.equals(id)))
        .write(const PaymentsTableCompanion(
          dirtyFlag: Value(true),
          lastModified: Value.absent(), // This will use the default timestamp
        ));
  }
  
  // Clear dirty flag for a payment record
  Future<int> clearDirtyFlag(int id) {
    return (update(paymentsTable)..where((tbl) => tbl.id.equals(id)))
        .write(const PaymentsTableCompanion(dirtyFlag: Value(false)));
  }
  
  // Mark a payment record for manual conflict resolution
  Future<int> markConflictForManualResolution(int id) {
    return (update(paymentsTable)..where((tbl) => tbl.id.equals(id)))
        .write(PaymentsTableCompanion(
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
    return (update(paymentsTable)..where((tbl) => tbl.id.equals(id)))
        .write(PaymentsTableCompanion(
          conflictResolutionStrategy: Value(conflictResolutionStrategy),
          conflictResolvedAt: Value(conflictResolvedAt),
          conflictOrigin: Value(conflictOrigin),
        ));
  }
  
  // Mark record as deleted locally
  Future<int> markDeletedLocally(int id) {
    return (update(paymentsTable)..where((tbl) => tbl.id.equals(id)))
        .write(PaymentsTableCompanion(
          deletedLocally: Value(true),
          dirtyFlag: Value(true),
          lastModified: Value(DateTime.now()),
        ));
  }
  
  // Undelete a record
  Future<int> undeleteRecord(int id) {
    return (update(paymentsTable)..where((tbl) => tbl.id.equals(id)))
        .write(PaymentsTableCompanion(
          deletedLocally: Value(false),
          dirtyFlag: Value(true),
          lastModified: Value(DateTime.now()),
        ));
  }
  
  // Update sync error information
  Future<int> updateSyncError(int id, String errorMessage) {
    return (update(paymentsTable)..where((tbl) => tbl.id.equals(id)))
        .write(PaymentsTableCompanion(
          lastSyncError: Value(errorMessage),
          syncRetryCount: Value.absent(), // Increment retry count in service layer
        ));
  }
  
  // Increment sync retry count
  Future<int> incrementSyncRetryCount(int id) {
    return (update(paymentsTable)..where((tbl) => tbl.id.equals(id)))
        .write(const PaymentsTableCompanion(
          syncRetryCount: Value.absent(), // This will need to be handled in service layer
        ));
  }
}