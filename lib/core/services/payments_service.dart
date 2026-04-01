import 'package:drift/drift.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/database/daos/payments_dao.dart';
import 'package:mawlid_al_dhaki/core/services/base_service.dart';
import 'package:uuid/uuid.dart';

class PaymentsService extends BaseService {
  PaymentsService(super.database);

  PaymentsDao get _dao => database.paymentsDao;
  static const _uuid = Uuid();

  // Get all payments
  Future<List<Payment>> getAllPayments({required String ownerId}) {
    return _dao.getAllPayments(ownerId: ownerId);
  }

  // Get payment by ID
  Future<Payment?> getPaymentById(String id, {required String ownerId}) {
    return _dao.getPaymentById(id, ownerId: ownerId);
  }

  // Get payments by subscriber ID
  Future<List<Payment>> getPaymentsBySubscriberId(String subscriberId, {required String ownerId}) {
    return _dao.getPaymentsBySubscriberId(subscriberId, ownerId: ownerId);
  }

  // Add a new payment
  Future<String> addPayment(Payment payment, {required String ownerId}) {
    final id = _uuid.v4();
    final companion = PaymentsTableCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      subscriberId: Value(payment.subscriberId),
      amount: Value(payment.amount),
      worker: Value(payment.worker),
      date: Value(payment.date),
      cabinet: Value(payment.cabinet),
    );
    return _dao.addPayment(companion);
  }

  // Update a payment
  Future<bool> updatePayment(Payment payment, {required String ownerId}) {
    final companion = payment.toCompanion(false).copyWith(
      ownerId: Value(ownerId),
      updatedAt: Value(DateTime.now()),
    );
    return _dao.updatePayment(companion);
  }

  // Soft delete a payment
  Future<bool> deletePayment(String id, {required String ownerId}) {
    final companion = PaymentsTableCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      isDeleted: const Value(true),
      updatedAt: Value(DateTime.now()),
    );
    return _dao.updatePayment(companion);
  }

  // Watch all payments (reactive stream)
  Stream<List<Payment>> watchPayments({required String ownerId}) {
    return _dao.watchAllPayments(ownerId: ownerId);
  }
}