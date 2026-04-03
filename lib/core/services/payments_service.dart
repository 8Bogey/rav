import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/database/daos/payments_dao.dart';
import 'package:mawlid_al_dhaki/core/services/base_service.dart';
import 'package:mawlid_al_dhaki/core/services/outbox_service.dart';
import 'package:mawlid_al_dhaki/core/services/trash_service.dart';
import 'package:uuid/uuid.dart';

class PaymentsService extends BaseService {
  PaymentsService(super.database);

  PaymentsDao get _dao => database.paymentsDao;
  late final OutboxService _outbox = OutboxService(database);
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
  Future<List<Payment>> getPaymentsBySubscriberId(String subscriberId,
      {required String ownerId}) {
    return _dao.getPaymentsBySubscriberId(subscriberId, ownerId: ownerId);
  }

  // Add a new payment
  Future<String> addPayment(Payment payment, {required String ownerId}) {
    final id = _uuid.v4();
    final now = DateTime.now();
    final companion = PaymentsTableCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      subscriberId: Value(payment.subscriberId),
      amount: Value(payment.amount),
      worker: Value(payment.worker),
      date: Value(payment.date),
      cabinet: Value(payment.cabinet),
      version: const Value(1),
      isDeleted: const Value(false),
      createdAt: Value(now),
      updatedAt: Value(now),
    );

    // Add to outbox for Convex sync
    _outbox.addEntry(
      targetTable: 'payments',
      operationType: 'create',
      documentId: id,
      payload: {
        'cloudId': id, // Client's local UUID for tracking
        'ownerId': ownerId,
        'subscriberId': payment.subscriberId,
        'amount': payment.amount,
        'worker': payment.worker,
        'date': payment.date.millisecondsSinceEpoch,
        'cabinet': payment.cabinet,
        'version': 1,
        'isDeleted': false,
        'updatedAt': now.millisecondsSinceEpoch,
        'createdAt': now.millisecondsSinceEpoch,
      },
    );

    return _dao.addPayment(companion);
  }

  // Update a payment
  Future<bool> updatePayment(Payment payment, {required String ownerId}) {
    final now = DateTime.now();
    final newVersion = (payment.version ?? 0) + 1;
    final companion = payment.toCompanion(false).copyWith(
          ownerId: Value(ownerId),
          version: Value(newVersion),
          updatedAt: Value(now),
        );

    // Add to outbox for Convex sync
    _outbox.addEntry(
      targetTable: 'payments',
      operationType: 'update',
      documentId: payment.id,
      payload: {
        'id': payment.id,
        'ownerId': ownerId,
        'subscriberId': payment.subscriberId,
        'amount': payment.amount,
        'worker': payment.worker,
        'date': payment.date.millisecondsSinceEpoch,
        'cabinet': payment.cabinet,
        'version': newVersion,
        'isDeleted': payment.isDeleted,
        'updatedAt': now.millisecondsSinceEpoch,
        'createdAt': payment.createdAt?.millisecondsSinceEpoch ??
            now.millisecondsSinceEpoch,
      },
    );

    return _dao.updatePayment(companion);
  }

  // Soft delete a payment (move to trash first)
  Future<bool> deletePayment(String id, {required String ownerId}) async {
    final now = DateTime.now();
    final existing = await _dao.getPaymentById(id, ownerId: ownerId);
    final newVersion = (existing?.version ?? 0) + 1;

    // Move to trash before soft deleting
    if (existing != null) {
      try {
        final trashService = TrashService(database);
        await trashService.moveToTrash(
          entityType: 'payments',
          entityId: id,
          entityData: {
            'id': existing.id,
            'subscriberId': existing.subscriberId,
            'amount': existing.amount,
            'worker': existing.worker,
            'date': existing.date.toIso8601String(),
            'cabinet': existing.cabinet,
            'ownerId': ownerId,
            'version': existing.version,
          },
        );
        debugPrint('[PaymentsService] Moved payment to trash');
      } catch (e) {
        debugPrint('[PaymentsService] Failed to move payment to trash: $e');
      }
    }

    final companion = PaymentsTableCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      isDeleted: const Value(true),
      version: Value(newVersion),
      updatedAt: Value(now),
    );

    // Add to outbox for Convex sync
    // Use cloudId for delete lookup (local UUID)
    _outbox.addEntry(
      targetTable: 'payments',
      operationType: 'delete',
      documentId: id,
      payload: {
        'cloudId': id, // Send cloudId for lookup instead of Convex id
        'ownerId': ownerId,
        'version': newVersion,
      },
    );

    return _dao.updatePayment(companion);
  }

  // Watch all payments (reactive stream)
  Stream<List<Payment>> watchPayments({required String ownerId}) {
    return _dao.watchAllPayments(ownerId: ownerId);
  }
}
