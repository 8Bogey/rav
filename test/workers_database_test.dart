import 'package:flutter_test/flutter_test.dart' hide isNull, isNotNull;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/services/workers_service.dart';

void main() {
  group('Workers Database Tests', () {
    late AppDatabase database;
    late WorkersService workersService;

    setUp(() async {
      // Initialize the binding for tests
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Use an in-memory database for testing
      final executor = NativeDatabase.memory();
      
      // Initialize the database and service
      database = AppDatabase(executor);
      workersService = WorkersService(database);
    });

    tearDown(() async {
      // Close the database after each test
      await database.close();
    });

    test('Can add and retrieve a worker', () async {
      // Create a new worker
      const worker = Worker(
        id: 0, // Will be auto-generated
        name: 'Test Worker',
        phone: '07701234567',
        permissions: '["collect", "add_subscriber"]',
        todayCollected: 0.0,
        monthTotal: 0.0,
      );

      // Add the worker to the database
      final id = await workersService.addWorker(worker);
      
      // Verify that the worker was added
      expect(id, greaterThan(0));

      // Retrieve the worker from the database
      final retrievedWorker = await workersService.getWorkerById(id);
      
      // Verify that the worker was retrieved correctly
      expect(retrievedWorker, isNot(isNull));
      expect(retrievedWorker!.name, equals('Test Worker'));
      expect(retrievedWorker.phone, equals('07701234567'));
      expect(retrievedWorker.permissions, equals('["collect", "add_subscriber"]'));
    });

    test('Can update a worker', () async {
      // Create and add a worker
      const worker = Worker(
        id: 0,
        name: 'Original Worker',
        phone: '07709876543',
        permissions: '["collect"]',
        todayCollected: 0.0,
        monthTotal: 0.0,
      );

      final id = await workersService.addWorker(worker);

      // Update the worker
      final updatedWorker = worker.copyWith(
        id: id,
        name: 'Updated Worker',
        phone: '07701122334',
        permissions: '["collect", "add_subscriber", "edit_data"]',
        todayCollected: 150000.0,
        monthTotal: 500000.0,
      );

      final success = await workersService.updateWorker(updatedWorker);
      
      // Verify that the update was successful
      expect(success, isTrue);

      // Retrieve the updated worker
      final retrievedWorker = await workersService.getWorkerById(id);
      
      // Verify that the worker was updated correctly
      expect(retrievedWorker, isNot(isNull));
      expect(retrievedWorker!.name, equals('Updated Worker'));
      expect(retrievedWorker.phone, equals('07701122334'));
      expect(retrievedWorker.permissions, equals('["collect", "add_subscriber", "edit_data"]'));
      expect(retrievedWorker.todayCollected, equals(150000.0));
      expect(retrievedWorker.monthTotal, equals(500000.0));
    });

    test('Can delete a worker', () async {
      // Create and add a worker
      const worker = Worker(
        id: 0,
        name: 'Worker to Delete',
        phone: '07705566778',
        permissions: '["collect"]',
        todayCollected: 0.0,
        monthTotal: 0.0,
      );

      final id = await workersService.addWorker(worker);

      // Delete the worker
      final deletedCount = await workersService.deleteWorker(id);
      
      // Verify that the worker was deleted
      expect(deletedCount, equals(1));

      // Try to retrieve the deleted worker
      final retrievedWorker = await workersService.getWorkerById(id);
      
      // Verify that the worker no longer exists
      expect(retrievedWorker, null);
    });

    test('Can get all workers', () async {
      // Add a few workers
      const worker1 = Worker(
        id: 0,
        name: 'Worker 1',
        phone: '07701234567',
        permissions: '["collect", "add_subscriber"]',
        todayCollected: 180000.0,
        monthTotal: 620000.0,
      );

      const worker2 = Worker(
        id: 0,
        name: 'Worker 2',
        phone: '07709876543',
        permissions: '["collect"]',
        todayCollected: 150000.0,
        monthTotal: 580000.0,
      );

      await workersService.addWorker(worker1);
      await workersService.addWorker(worker2);

      // Get all workers
      final workers = await workersService.getAllWorkers();
      
      // Verify that we got the workers
      expect(workers, isNotEmpty);
      expect(workers.length, greaterThanOrEqualTo(2));
    });

    test('Can get worker by name', () async {
      // Add a few workers
      const worker1 = Worker(
        id: 0,
        name: 'Ahmed Mohammed',
        phone: '07701234567',
        permissions: '["collect", "add_subscriber"]',
        todayCollected: 180000.0,
        monthTotal: 620000.0,
      );

      const worker2 = Worker(
        id: 0,
        name: 'Ali Hassan',
        phone: '07709876543',
        permissions: '["collect"]',
        todayCollected: 150000.0,
        monthTotal: 580000.0,
      );

      await workersService.addWorker(worker1);
      await workersService.addWorker(worker2);

      // Get worker by name
      final worker = await workersService.getWorkerByName('Ahmed Mohammed');
      
      // Verify that we got the correct worker
      expect(worker, isNot(isNull));
      expect(worker!.name, equals('Ahmed Mohammed'));
      expect(worker.phone, equals('07701234567'));
    });
  });
}