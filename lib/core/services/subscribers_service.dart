import 'package:drift/drift.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/database/daos/subscribers_dao.dart';
import 'package:mawlid_al_dhaki/core/services/base_service.dart';
import 'package:uuid/uuid.dart';

class SubscribersService extends BaseService {
  SubscribersService(super.database);

  SubscribersDao get _dao => database.subscribersDao;
  static const _uuid = Uuid();

  // Get all subscribers
  Future<List<Subscriber>> getAllSubscribers({required String ownerId}) {
    return _dao.getAllSubscribers(ownerId: ownerId);
  }

  // Get subscriber by ID
  Future<Subscriber?> getSubscriberById(String id, {required String ownerId}) {
    return _dao.getSubscriberById(id, ownerId: ownerId);
  }

  // Get subscriber by code
  Future<Subscriber?> getSubscriberByCode(String code, {required String ownerId}) {
    return _dao.getSubscriberByCode(code, ownerId: ownerId);
  }

  // Add a new subscriber
  Future<String> addSubscriber(Subscriber subscriber, {required String ownerId}) {
    final id = _uuid.v4();
    final companion = SubscribersTableCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
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
  Future<bool> updateSubscriber(Subscriber subscriber, {required String ownerId}) {
    final companion = subscriber.toCompanion(false).copyWith(
      ownerId: Value(ownerId),
      updatedAt: Value(DateTime.now()),
    );
    return _dao.updateSubscriber(companion);
  }

  // Soft delete a subscriber
  Future<bool> deleteSubscriber(String id, {required String ownerId}) {
    final companion = SubscribersTableCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      isDeleted: const Value(true),
      updatedAt: Value(DateTime.now()),
    );
    return _dao.updateSubscriber(companion);
  }

  // Search subscribers by name or code
  Future<List<Subscriber>> searchSubscribers(String query, {required String ownerId}) {
    return _dao.searchSubscribers(query, ownerId: ownerId);
  }

  // Watch all subscribers (reactive stream)
  Stream<List<Subscriber>> watchSubscribers({required String ownerId}) {
    return _dao.watchAllSubscribers(ownerId: ownerId);
  }
}