import 'package:flutter_test/flutter_test.dart' hide isNull, isNotNull;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/services/subscribers_service.dart';

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
      // Create a new subscriber
      final subscriber = Subscriber(
        id: 0, // Will be auto-generated
        name: 'Test Subscriber',
        code: 'TS001',
        cabinet: 'A',
        phone: '07701234567',
        status: 1, // active
        startDate: DateTime.now(),
        accumulatedDebt: 0.0,
        tags: null,
        notes: null,
      );

      // Add the subscriber to the database
      final id = await subscribersService.addSubscriber(subscriber);
      
      // Verify that the subscriber was added
      expect(id, greaterThan(0));

      // Retrieve the subscriber from the database
      final retrievedSubscriber = await subscribersService.getSubscriberById(id);
      
      // Verify that the subscriber was retrieved correctly
      expect(retrievedSubscriber, isNot(isNull));
      expect(retrievedSubscriber!.name, equals('Test Subscriber'));
      expect(retrievedSubscriber.code, equals('TS001'));
      expect(retrievedSubscriber.cabinet, equals('A'));
      expect(retrievedSubscriber.phone, equals('07701234567'));
      expect(retrievedSubscriber.status, equals(1));
    });

    test('Can update a subscriber', () async {
      // Create and add a subscriber
      final subscriber = Subscriber(
        id: 0,
        name: 'Original Name',
        code: 'ON001',
        cabinet: 'B',
        phone: '07709876543',
        status: 1, // active
        startDate: DateTime.now(),
        accumulatedDebt: 0.0,
        tags: null,
        notes: null,
      );

      final id = await subscribersService.addSubscriber(subscriber);

      // Update the subscriber
      final updatedSubscriber = subscriber.copyWith(
        id: id,
        name: 'Updated Name',
        code: 'UN001',
        cabinet: 'C',
        phone: '07701122334',
        status: 2, // suspended
        accumulatedDebt: 5000.0,
      );

      final success = await subscribersService.updateSubscriber(updatedSubscriber);
      
      // Verify that the update was successful
      expect(success, isTrue);

      // Retrieve the updated subscriber
      final retrievedSubscriber = await subscribersService.getSubscriberById(id);
      
      // Verify that the subscriber was updated correctly
      expect(retrievedSubscriber, isNot(isNull));
      expect(retrievedSubscriber!.name, equals('Updated Name'));
      expect(retrievedSubscriber.code, equals('UN001'));
      expect(retrievedSubscriber.cabinet, equals('C'));
      expect(retrievedSubscriber.phone, equals('07701122334'));
      expect(retrievedSubscriber.status, equals(2));
      expect(retrievedSubscriber.accumulatedDebt, equals(5000.0));
    });

    test('Can delete a subscriber', () async {
      // Create and add a subscriber
      final subscriber = Subscriber(
        id: 0,
        name: 'Subscriber to Delete',
        code: 'SD001',
        cabinet: 'D',
        phone: '07705566778',
        status: 1, // active
        startDate: DateTime.now(),
        accumulatedDebt: 0.0,
        tags: null,
        notes: null,
      );

      final id = await subscribersService.addSubscriber(subscriber);

      // Delete the subscriber
      final deletedCount = await subscribersService.deleteSubscriber(id);
      
      // Verify that the subscriber was deleted
      expect(deletedCount, equals(1));

      // Try to retrieve the deleted subscriber
      final retrievedSubscriber = await subscribersService.getSubscriberById(id);
      
      // Verify that the subscriber no longer exists
      expect(retrievedSubscriber, null);
    });

    test('Can get all subscribers', () async {
      // Add a few subscribers
      final subscriber1 = Subscriber(
        id: 0,
        name: 'Subscriber 1',
        code: 'S1001',
        cabinet: 'A',
        phone: '07701234567',
        status: 1, // active
        startDate: DateTime.now(),
        accumulatedDebt: 0.0,
        tags: null,
        notes: null,
      );

      final subscriber2 = Subscriber(
        id: 0,
        name: 'Subscriber 2',
        code: 'S2001',
        cabinet: 'B',
        phone: '07709876543',
        status: 2, // suspended
        startDate: DateTime.now(),
        accumulatedDebt: 10000.0,
        tags: null,
        notes: null,
      );

      await subscribersService.addSubscriber(subscriber1);
      await subscribersService.addSubscriber(subscriber2);

      // Get all subscribers
      final subscribers = await subscribersService.getAllSubscribers();
      
      // Verify that we got the subscribers
      expect(subscribers, isNotEmpty);
      expect(subscribers.length, greaterThanOrEqualTo(2));
    });

    test('Can search subscribers', () async {
      // Add a few subscribers
      final subscriber1 = Subscriber(
        id: 0,
        name: 'Ahmed Ali',
        code: 'AA001',
        cabinet: 'A',
        phone: '07701234567',
        status: 1, // active
        startDate: DateTime.now(),
        accumulatedDebt: 0.0,
        tags: null,
        notes: null,
      );

      final subscriber2 = Subscriber(
        id: 0,
        name: 'Mohammed Hassan',
        code: 'MH001',
        cabinet: 'B',
        phone: '07709876543',
        status: 2, // suspended
        startDate: DateTime.now(),
        accumulatedDebt: 10000.0,
        tags: null,
        notes: null,
      );

      await subscribersService.addSubscriber(subscriber1);
      await subscribersService.addSubscriber(subscriber2);

      // Search for subscribers
      final searchResults = await subscribersService.searchSubscribers('Ahmed');
      
      // Verify that we got the search results
      expect(searchResults, isNotEmpty);
      expect(searchResults.length, equals(1));
      expect(searchResults[0].name, equals('Ahmed Ali'));
    });
  });
}