import 'package:flutter_test/flutter_test.dart' hide isNull, isNotNull;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/services/payments_service.dart';

void main() {
  group('Payments Database Tests', () {
    late AppDatabase database;
    late PaymentsService paymentsService;

    setUp(() async {
      // Initialize the binding for tests
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Use an in-memory database for testing
      final executor = NativeDatabase.memory();
      
      // Initialize the database and service
      database = AppDatabase(executor);
      paymentsService = PaymentsService(database);
    });

    tearDown(() async {
      // Close the database after each test
      await database.close();
    });

    test('Can add and retrieve a payment', () async {
      // Create a new payment
      final payment = Payment(
        id: 0, // Will be auto-generated
        subscriberId: 1,
        amount: 15000.0,
        worker: 'Test Worker',
        date: DateTime.now(),
        cabinet: 'A',
      );

      // Add the payment to the database
      final id = await paymentsService.addPayment(payment);
      
      // Verify that the payment was added
      expect(id, greaterThan(0));

      // Retrieve the payment from the database
      final retrievedPayment = await paymentsService.getPaymentById(id);
      
      // Verify that the payment was retrieved correctly
      expect(retrievedPayment, isNot(isNull));
      expect(retrievedPayment!.amount, equals(15000.0));
      expect(retrievedPayment.worker, equals('Test Worker'));
      expect(retrievedPayment.cabinet, equals('A'));
    });

    test('Can update a payment', () async {
      // Create and add a payment
      final payment = Payment(
        id: 0,
        subscriberId: 1,
        amount: 15000.0,
        worker: 'Original Worker',
        date: DateTime.now(),
        cabinet: 'A',
      );

      final id = await paymentsService.addPayment(payment);

      // Update the payment
      final updatedPayment = payment.copyWith(
        id: id,
        amount: 20000.0,
        worker: 'Updated Worker',
        cabinet: 'B',
      );

      final success = await paymentsService.updatePayment(updatedPayment);
      
      // Verify that the update was successful
      expect(success, isTrue);

      // Retrieve the updated payment
      final retrievedPayment = await paymentsService.getPaymentById(id);
      
      // Verify that the payment was updated correctly
      expect(retrievedPayment, isNot(isNull));
      expect(retrievedPayment!.amount, equals(20000.0));
      expect(retrievedPayment.worker, equals('Updated Worker'));
      expect(retrievedPayment.cabinet, equals('B'));
    });

    test('Can delete a payment', () async {
      // Create and add a payment
      final payment = Payment(
        id: 0,
        subscriberId: 1,
        amount: 15000.0,
        worker: 'Test Worker',
        date: DateTime.now(),
        cabinet: 'A',
      );

      final id = await paymentsService.addPayment(payment);

      // Delete the payment
      final deletedCount = await paymentsService.deletePayment(id);
      
      // Verify that the payment was deleted
      expect(deletedCount, equals(1));

      // Try to retrieve the deleted payment
      final retrievedPayment = await paymentsService.getPaymentById(id);
      
      // Verify that the payment no longer exists
      expect(retrievedPayment, null);
    });

    test('Can get all payments', () async {
      // Add a few payments
      final payment1 = Payment(
        id: 0,
        subscriberId: 1,
        amount: 15000.0,
        worker: 'Worker 1',
        date: DateTime.now(),
        cabinet: 'A',
      );

      final payment2 = Payment(
        id: 0,
        subscriberId: 2,
        amount: 20000.0,
        worker: 'Worker 2',
        date: DateTime.now(),
        cabinet: 'B',
      );

      await paymentsService.addPayment(payment1);
      await paymentsService.addPayment(payment2);

      // Get all payments
      final payments = await paymentsService.getAllPayments();
      
      // Verify that we got the payments
      expect(payments, isNotEmpty);
      expect(payments.length, greaterThanOrEqualTo(2));
    });

    test('Can get payments by subscriber ID', () async {
      // Add a few payments
      final payment1 = Payment(
        id: 0,
        subscriberId: 1,
        amount: 15000.0,
        worker: 'Worker 1',
        date: DateTime.now(),
        cabinet: 'A',
      );

      final payment2 = Payment(
        id: 0,
        subscriberId: 1,
        amount: 20000.0,
        worker: 'Worker 2',
        date: DateTime.now(),
        cabinet: 'B',
      );

      final payment3 = Payment(
        id: 0,
        subscriberId: 2,
        amount: 25000.0,
        worker: 'Worker 3',
        date: DateTime.now(),
        cabinet: 'C',
      );

      await paymentsService.addPayment(payment1);
      await paymentsService.addPayment(payment2);
      await paymentsService.addPayment(payment3);

      // Get payments by subscriber ID
      final payments = await paymentsService.getPaymentsBySubscriberId(1);
      
      // Verify that we got the payments for the specific subscriber
      expect(payments, isNotEmpty);
      expect(payments.length, equals(2));
      expect(payments.every((payment) => payment.subscriberId == 1), isTrue);
    });
  });
}