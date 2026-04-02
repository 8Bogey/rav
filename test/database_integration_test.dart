import 'package:flutter_test/flutter_test.dart' hide isNull, isNotNull;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/services/cabinets_service.dart';

void main() {
  group('Database Integration Tests', () {
    late AppDatabase database;
    late CabinetsService cabinetsService;

    setUp(() async {
      // Initialize the binding for tests
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Use an in-memory database for testing
      final executor = NativeDatabase.memory();
      
      // Initialize the database and service
      database = AppDatabase(executor);
      cabinetsService = CabinetsService(database);
    });

    tearDown(() async {
      // Close the database after each test
      await database.close();
    });

    test('Can add and retrieve a cabinet', () async {
      // Create a new cabinet
      const cabinet = Cabinet(
        id: 0, // Will be auto-generated
        name: 'Test Cabinet',
        letter: 'A',
        totalSubscribers: 100,
        currentSubscribers: 50,
        collectedAmount: 25000.0,
        delayedSubscribers: 10,
        completionDate: null,
      );

      // Add the cabinet to the database
      final id = await cabinetsService.addCabinet(cabinet);
      
      // Verify that the cabinet was added
      expect(id, greaterThan(0));

      // Retrieve the cabinet from the database
      final retrievedCabinet = await cabinetsService.getCabinetById(id);
      
      // Verify that the cabinet was retrieved correctly
      expect(retrievedCabinet, isNot(isNull));
      expect(retrievedCabinet!.name, equals('Test Cabinet'));
      expect(retrievedCabinet.totalSubscribers, equals(100));
      expect(retrievedCabinet.currentSubscribers, equals(50));
      expect(retrievedCabinet.collectedAmount, equals(25000.0));
      expect(retrievedCabinet.delayedSubscribers, equals(10));
    });

    test('Can update a cabinet', () async {
      // Create and add a cabinet
      const cabinet = Cabinet(
        id: 0,
        name: 'Original Name',
        letter: 'B',
        totalSubscribers: 100,
        currentSubscribers: 50,
        collectedAmount: 25000.0,
        delayedSubscribers: 10,
        completionDate: null,
      );

      final id = await cabinetsService.addCabinet(cabinet);

      // Update the cabinet
      final updatedCabinet = cabinet.copyWith(
        id: id,
        name: 'Updated Name',
        totalSubscribers: 200,
        currentSubscribers: 150,
        collectedAmount: 50000.0,
        delayedSubscribers: 20,
      );

      final success = await cabinetsService.updateCabinet(updatedCabinet);
      
      // Verify that the update was successful
      expect(success, isTrue);

      // Retrieve the updated cabinet
      final retrievedCabinet = await cabinetsService.getCabinetById(id);
      
      // Verify that the cabinet was updated correctly
      expect(retrievedCabinet, isNot(isNull));
      expect(retrievedCabinet!.name, equals('Updated Name'));
      expect(retrievedCabinet.totalSubscribers, equals(200));
      expect(retrievedCabinet.currentSubscribers, equals(150));
      expect(retrievedCabinet.collectedAmount, equals(50000.0));
      expect(retrievedCabinet.delayedSubscribers, equals(20));
    });

    test('Can delete a cabinet', () async {
      // Create and add a cabinet
      const cabinet = Cabinet(
        id: 0,
        name: 'Cabinet to Delete',
        letter: 'C',
        totalSubscribers: 100,
        currentSubscribers: 50,
        collectedAmount: 25000.0,
        delayedSubscribers: 10,
        completionDate: null,
      );

      final id = await cabinetsService.addCabinet(cabinet);

      // Delete the cabinet
      final deletedCount = await cabinetsService.deleteCabinet(id);
      
      // Verify that the cabinet was deleted
      expect(deletedCount, equals(1));

      // Try to retrieve the deleted cabinet
      final retrievedCabinet = await cabinetsService.getCabinetById(id);
      
      // Verify that the cabinet no longer exists
      expect(retrievedCabinet, null);
    });

    test('Can get all cabinets', () async {
      // Add a few cabinets
      const cabinet1 = Cabinet(
        id: 0,
        name: 'Cabinet 1',
        letter: 'D',
        totalSubscribers: 100,
        currentSubscribers: 50,
        collectedAmount: 25000.0,
        delayedSubscribers: 10,
        completionDate: null,
      );

      const cabinet2 = Cabinet(
        id: 0,
        name: 'Cabinet 2',
        letter: 'E',
        totalSubscribers: 200,
        currentSubscribers: 150,
        collectedAmount: 50000.0,
        delayedSubscribers: 20,
        completionDate: null,
      );

      await cabinetsService.addCabinet(cabinet1);
      await cabinetsService.addCabinet(cabinet2);

      // Get all cabinets
      final cabinets = await cabinetsService.getAllCabinets();
      
      // Verify that we got the cabinets
      expect(cabinets, isNotEmpty);
      expect(cabinets.length, greaterThanOrEqualTo(2));
    });
  });
}