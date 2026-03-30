import 'package:drift/drift.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/database/daos/payments_dao.dart';
import 'package:mawlid_al_dhaki/core/services/base_service.dart';

class PaymentsService extends BaseService {
  late PaymentsDao _dao;

  PaymentsService(AppDatabase database) : super(database) {
    _dao = PaymentsDao(database);
  }

  // Get all payments
  Future<List<Payment>> getAllPayments() {
    return _dao.getAllPayments();
  }

  // Get payment by ID
  Future<Payment?> getPaymentById(int id) {
    return _dao.getPaymentById(id);
  }

  // Get payments by subscriber ID
  Future<List<Payment>> getPaymentsBySubscriberId(int subscriberId) {
    return _dao.getPaymentsBySubscriberId(subscriberId);
  }

  // Add a new payment
  Future<int> addPayment(Payment payment) {
    // For inserts, we want to let the database auto-generate the ID
    final companion = PaymentsTableCompanion(
      subscriberId: Value(payment.subscriberId),
      amount: Value(payment.amount),
      worker: Value(payment.worker),
      date: Value(payment.date),
      cabinet: Value(payment.cabinet),
    );
    return _dao.addPayment(companion);
  }

  // Update a payment
  Future<bool> updatePayment(Payment payment) {
    final companion = payment.toCompanion(false);
    return _dao.updatePayment(companion);
  }

  // Delete a payment
  Future<int> deletePayment(int id) {
    return _dao.deletePayment(id);
  }

  // Get dirty payments (those with dirtyFlag = true)
  Future<List<Payment>> getDirtyPayments() {
    return _dao.getDirtyPayments();
  }
  
  // Mark a payment record for manual conflict resolution
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
  
  // Update sync error information
  Future<int> updateSyncError(int id, String errorMessage) {
    return _dao.updateSyncError(id, errorMessage);
  }
  
  // Increment sync retry count
  Future<int> incrementSyncRetryCount(int id) {
    return _dao.incrementSyncRetryCount(id);
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