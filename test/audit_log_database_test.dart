import 'package:flutter_test/flutter_test.dart' hide isNull, isNotNull;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/services/audit_log_service.dart';

void main() {
  group('Audit Log Database Tests', () {
    late AppDatabase database;
    late AuditLogService auditLogService;

    setUp(() async {
      // Initialize the binding for tests
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Use an in-memory database for testing
      final executor = NativeDatabase.memory();
      
      // Initialize the database and service
      database = AppDatabase(executor);
      auditLogService = AuditLogService(database);
    });

    tearDown(() async {
      // Close the database after each test
      await database.close();
    });

    test('Can add and retrieve an audit log entry', () async {
      // Create a new audit log entry
      final auditLogEntry = AuditLogEntry(
        id: 0, // Will be auto-generated
        user: 'Admin',
        action: 'Added subscriber',
        target: 'Ahmed Ali (A4)',
        details: 'Subscriber added successfully',
        type: 'add',
        timestamp: DateTime.now(),
      );

      // Add the audit log entry to the database
      final id = await auditLogService.addAuditLogEntry(auditLogEntry);
      
      // Verify that the audit log entry was added
      expect(id, greaterThan(0));

      // Retrieve the audit log entry from the database
      final retrievedEntry = await auditLogService.getAuditLogEntryById(id);
      
      // Verify that the audit log entry was retrieved correctly
      expect(retrievedEntry, isNot(isNull));
      expect(retrievedEntry!.user, equals('Admin'));
      expect(retrievedEntry.action, equals('Added subscriber'));
      expect(retrievedEntry.target, equals('Ahmed Ali (A4)'));
      expect(retrievedEntry.details, equals('Subscriber added successfully'));
      expect(retrievedEntry.type, equals('add'));
    });

    test('Can update an audit log entry', () async {
      // Create and add an audit log entry
      final auditLogEntry = AuditLogEntry(
        id: 0,
        user: 'Admin',
        action: 'Added subscriber',
        target: 'Ahmed Ali (A4)',
        details: 'Subscriber added successfully',
        type: 'add',
        timestamp: DateTime.now(),
      );

      final id = await auditLogService.addAuditLogEntry(auditLogEntry);

      // Update the audit log entry
      final updatedEntry = auditLogEntry.copyWith(
        id: id,
        action: 'Updated subscriber',
        details: 'Subscriber information updated',
        type: 'update',
      );

      final success = await auditLogService.updateAuditLogEntry(updatedEntry);
      
      // Verify that the update was successful
      expect(success, isTrue);

      // Retrieve the updated audit log entry
      final retrievedEntry = await auditLogService.getAuditLogEntryById(id);
      
      // Verify that the audit log entry was updated correctly
      expect(retrievedEntry, isNot(isNull));
      expect(retrievedEntry!.action, equals('Updated subscriber'));
      expect(retrievedEntry.details, equals('Subscriber information updated'));
      expect(retrievedEntry.type, equals('update'));
    });

    test('Can delete an audit log entry', () async {
      // Create and add an audit log entry
      final auditLogEntry = AuditLogEntry(
        id: 0,
        user: 'Admin',
        action: 'Deleted subscriber',
        target: 'Mohammed Hassan (B2)',
        details: 'Subscriber removed due to disconnection',
        type: 'delete',
        timestamp: DateTime.now(),
      );

      final id = await auditLogService.addAuditLogEntry(auditLogEntry);

      // Delete the audit log entry
      final deletedCount = await auditLogService.deleteAuditLogEntry(id);
      
      // Verify that the audit log entry was deleted
      expect(deletedCount, equals(1));

      // Try to retrieve the deleted audit log entry
      final retrievedEntry = await auditLogService.getAuditLogEntryById(id);
      
      // Verify that the audit log entry no longer exists
      expect(retrievedEntry, null);
    });

    test('Can get all audit log entries', () async {
      // Add a few audit log entries
      final entry1 = AuditLogEntry(
        id: 0,
        user: 'Admin',
        action: 'Added subscriber',
        target: 'Ahmed Ali (A4)',
        details: 'Subscriber added successfully',
        type: 'add',
        timestamp: DateTime.now(),
      );

      final entry2 = AuditLogEntry(
        id: 0,
        user: 'Worker',
        action: 'Collected payment',
        target: 'Mohammed Hassan (B2)',
        details: 'Payment of 15,000 IQD collected',
        type: 'payment',
        timestamp: DateTime.now(),
      );

      await auditLogService.addAuditLogEntry(entry1);
      await auditLogService.addAuditLogEntry(entry2);

      // Get all audit log entries
      final entries = await auditLogService.getAllAuditLogEntries();
      
      // Verify that we got the audit log entries
      expect(entries, isNotEmpty);
      expect(entries.length, greaterThanOrEqualTo(2));
    });
  });
}