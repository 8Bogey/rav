import 'package:flutter_test/flutter_test.dart' hide isNull, isNotNull;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/services/subscribers_service.dart';

const _testOwnerId = 'test-owner-001';

// Helper to create valid Subscriber with all required Convex sync fields
Subscriber createTestSubscriber({
  String? id,
  String name = 'Test Subscriber',
  String code = 'TS001',
  String cabinet = 'A',
  String phone = '07701234567',
  String status = 'active',
  DateTime? startDate,
  double accumulatedDebt = 0.0,
  String? ownerId,
}) {
  final now = DateTime.now();
  return Subscriber(
    id: id ?? 'test-${now.millisecondsSinceEpoch}-${now.microsecond}',
    name: name,
    code: code,
    cabinet: cabinet,
    phone: phone,
    status: status,
    startDate: startDate ?? now,
    accumulatedDebt: accumulatedDebt,
    tags: null,
    notes: null,
    // Convex sync metadata - all required
    ownerId: ownerId ?? _testOwnerId,
    version: 1,
    updatedAt: now,
    createdAt: now,
    inTrash: false,
  );
}

void main() {
  group('Subscribers Database Tests', () {
    late AppDatabase database;
    late SubscribersService subscribersService;

    setUp(() async {
      // Initialize the binding for tests
      TestWidgetsFlutterBinding.ensureInitialized();

      // Use an in-memory database for testing
      final executor = NativeDatabase.memory();

      // Initialize the database and service
      database = AppDatabase(executor);
      subscribersService = SubscribersService(database);
    });

    tearDown(() async {
      // Close the database after each test
      await database.close();
    });

    test('Can add and retrieve a subscriber', () async {
      final subscriber = createTestSubscriber();

      // Add the subscriber to the database
      final id = await subscribersService.addSubscriber(subscriber,
          ownerId: _testOwnerId);

      // Verify that the subscriber was added
      expect(id, isNotEmpty);

      // Retrieve the subscriber from the database
      final retrievedSubscriber =
          await subscribersService.getSubscriberById(id, ownerId: _testOwnerId);

      // Verify that the subscriber was retrieved correctly
      expect(retrievedSubscriber, isNot(isNull));
      expect(retrievedSubscriber!.name, equals('Test Subscriber'));
      expect(retrievedSubscriber.code, equals('TS001'));
      expect(retrievedSubscriber.cabinet, equals('A'));
      expect(retrievedSubscriber.phone, equals('07701234567'));
      expect(retrievedSubscriber.status, equals('active'));
    });

    test('Can update a subscriber', () async {
      // Create and add a subscriber
      final subscriber = createTestSubscriber(
        name: 'Original Name',
        code: 'ON001',
      );

      final id = await subscribersService.addSubscriber(subscriber,
          ownerId: _testOwnerId);

      // Get the subscriber to update
      final existing =
          await subscribersService.getSubscriberById(id, ownerId: _testOwnerId);
      expect(existing, isNotNull);

      // Update the subscriber using copyWith
      final updatedSubscriber = existing!.copyWith(
        name: 'Updated Name',
        code: 'UN001',
        cabinet: 'C',
        phone: '07701122334',
        status: 'suspended',
        accumulatedDebt: 5000.0,
      );

      final success = await subscribersService
          .updateSubscriber(updatedSubscriber, ownerId: _testOwnerId);

      // Verify that the update was successful
      expect(success, isTrue);

      // Retrieve the updated subscriber
      final retrievedSubscriber =
          await subscribersService.getSubscriberById(id, ownerId: _testOwnerId);

      // Verify that the subscriber was updated correctly
      expect(retrievedSubscriber, isNot(isNull));
      expect(retrievedSubscriber!.name, equals('Updated Name'));
      expect(retrievedSubscriber.code, equals('UN001'));
      expect(retrievedSubscriber.cabinet, equals('C'));
      expect(retrievedSubscriber.phone, equals('07701122334'));
      expect(retrievedSubscriber.status, equals('suspended'));
      expect(retrievedSubscriber.accumulatedDebt, equals(5000.0));
    });

    test('Can delete a subscriber', () async {
      // Create and add a subscriber
      final subscriber = createTestSubscriber(
        name: 'Subscriber to Delete',
        code: 'SD001',
      );

      final id = await subscribersService.addSubscriber(subscriber,
          ownerId: _testOwnerId);

      // Delete the subscriber
      final deletedCount =
          await subscribersService.deleteSubscriber(id, ownerId: _testOwnerId);

      // Verify that the subscriber was deleted
      expect(deletedCount, equals(1));

      // Try to retrieve the deleted subscriber (should not appear in active list)
      final allSubscribers =
          await subscribersService.getAllSubscribers(ownerId: _testOwnerId);
      expect(allSubscribers.any((s) => s.id == id), isFalse);
    });

    test('Can get all subscribers', () async {
      // Add a few subscribers
      await subscribersService.addSubscriber(
          createTestSubscriber(
            name: 'Subscriber 1',
            code: 'S1001',
            cabinet: 'A',
          ),
          ownerId: _testOwnerId);

      await subscribersService.addSubscriber(
          createTestSubscriber(
            name: 'Subscriber 2',
            code: 'S2001',
            cabinet: 'B',
            status: 'suspended',
            accumulatedDebt: 10000.0,
          ),
          ownerId: _testOwnerId);

      // Get all subscribers
      final subscribers =
          await subscribersService.getAllSubscribers(ownerId: _testOwnerId);

      // Verify that we got the subscribers
      expect(subscribers, isNotEmpty);
      expect(subscribers.length, greaterThanOrEqualTo(2));
    });

    test('Can search subscribers', () async {
      // Add a few subscribers
      await subscribersService.addSubscriber(
          createTestSubscriber(
            name: 'Ahmed Ali',
            code: 'AA001',
            cabinet: 'A',
          ),
          ownerId: _testOwnerId);

      await subscribersService.addSubscriber(
          createTestSubscriber(
            name: 'Mohammed Hassan',
            code: 'MH001',
            cabinet: 'B',
            status: 'suspended',
            accumulatedDebt: 10000.0,
          ),
          ownerId: _testOwnerId);

      // Search for subscribers
      final searchResults = await subscribersService.searchSubscribers('Ahmed',
          ownerId: _testOwnerId);

      // Verify that we got the search results
      expect(searchResults, isNotEmpty);
      expect(searchResults.length, equals(1));
      expect(searchResults[0].name, equals('Ahmed Ali'));
    });
  });
}
