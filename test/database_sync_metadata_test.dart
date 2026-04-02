import 'package:flutter_test/flutter_test.dart' hide isNull, isNotNull;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';

void main() {
  group('Database Sync Metadata Tests', () {
    late AppDatabase database;

    setUp(() async {
      // Initialize the binding for tests
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // Use an in-memory database for testing
      final executor = NativeDatabase.memory();
      
      // Initialize the database
      database = AppDatabase(executor);
    });

    tearDown(() async {
      // Close the database after each test
      await database.close();
    });

    group('SubscribersTable Sync Metadata', () {
      test('All sync metadata fields exist', () async {
        final subscriber = Subscriber(
          id: 0,
          name: 'Test Subscriber',
          code: 'TS001',
          cabinet: 'CAB001',
          phone: '07701234567',
          status: 1,
          startDate: DateTime.now(),
          accumulatedDebt: 0.0,
          tags: null,
          notes: null,
          // Sync metadata fields
          lastModified: DateTime.now(),
          lastSyncedAt: DateTime.now(),
          syncStatus: 'sync_pending',
          dirtyFlag: true,
          cloudId: 'cloud-123',
          deletedLocally: false,
          permissionsMask: 'admin',
          conflictOrigin: 'both',
          conflictDetectedAt: DateTime.now(),
          conflictResolvedAt: DateTime.now(),
          conflictResolutionStrategy: 'merge',
          lastSyncError: 'Network timeout',
          syncRetryCount: 2,
        );

        final id = await database.into(database.subscribersTable).insert(subscriber);

        final insertedSubscriber = await (database.select(database.subscribersTable)
              ..where((tbl) => tbl.id.equals(id)))
            .getSingle();

        // Verify all sync metadata fields exist and can be set
        expect(insertedSubscriber.lastModified, isNot(null));
        expect(insertedSubscriber.lastSyncedAt, isNot(null));
        expect(insertedSubscriber.syncStatus, 'sync_pending');
        expect(insertedSubscriber.dirtyFlag, true);
        expect(insertedSubscriber.cloudId, 'cloud-123');
        expect(insertedSubscriber.deletedLocally, false);
        expect(insertedSubscriber.permissionsMask, 'admin');
        expect(insertedSubscriber.conflictOrigin, 'both');
        expect(insertedSubscriber.conflictDetectedAt, isNot(null));
        expect(insertedSubscriber.conflictResolvedAt, isNot(null));
        expect(insertedSubscriber.conflictResolutionStrategy, 'merge');
        expect(insertedSubscriber.lastSyncError, 'Network timeout');
        expect(insertedSubscriber.syncRetryCount, 2);
      });

      test('Sync metadata fields have correct default values', () async {
        final subscriber = Subscriber(
          id: 0,
          name: 'Test Subscriber',
          code: 'TS002',
          cabinet: 'CAB001',
          phone: '07701234567',
          status: 1,
          startDate: DateTime.now(),
          accumulatedDebt: 0.0,
          tags: null,
          notes: null,
          // Only providing minimum required fields, others should use defaults
        );

        final id = await database.into(database.subscribersTable).insert(subscriber);

        final insertedSubscriber = await (database.select(database.subscribersTable)
              ..where((tbl) => tbl.id.equals(id)))
            .getSingle();

        // Verify default values for sync metadata fields
        expect(insertedSubscriber.syncStatus, 'local_only');
        expect(insertedSubscriber.dirtyFlag, false);
        expect(insertedSubscriber.deletedLocally, false);
        expect(insertedSubscriber.syncRetryCount, 0);
      });

      test('Sync metadata fields can be updated', () async {
        final subscriber = Subscriber(
          id: 0,
          name: 'Test Subscriber',
          code: 'TS003',
          cabinet: 'CAB001',
          phone: '07701234567',
          status: 1,
          startDate: DateTime.now(),
          accumulatedDebt: 0.0,
          tags: null,
          notes: null,
        );

        final id = await database.into(database.subscribersTable).insert(subscriber);

        // Update sync metadata fields
        final now = DateTime.now();
        await (database.update(database.subscribersTable)
              ..where((tbl) => tbl.id.equals(id)))
            .write(Subscriber(
          id: id,
          name: 'Test Subscriber',
          code: 'TS003',
          cabinet: 'CAB001',
          phone: '07701234567',
          status: 1,
          startDate: DateTime.now(),
          accumulatedDebt: 0.0,
          tags: null,
          notes: null,
          // Updated sync metadata fields
          lastModified: now,
          lastSyncedAt: now,
          syncStatus: 'synced',
          dirtyFlag: false,
          cloudId: 'updated-cloud-456',
          deletedLocally: true,
          permissionsMask: 'user',
          conflictOrigin: 'cloud',
          conflictDetectedAt: now,
          conflictResolvedAt: now,
          conflictResolutionStrategy: 'cloud_wins',
          lastSyncError: 'Connection failed',
          syncRetryCount: 3,
        ).toCompanion(true));

        final updatedSubscriber = await (database.select(database.subscribersTable)
              ..where((tbl) => tbl.id.equals(id)))
            .getSingle();

        // Verify updated sync metadata fields
        expect(updatedSubscriber.lastModified, isNot(null));
        expect(updatedSubscriber.lastSyncedAt, isNot(null));
        expect(updatedSubscriber.syncStatus, 'synced');
        expect(updatedSubscriber.dirtyFlag, false);
        expect(updatedSubscriber.cloudId, 'updated-cloud-456');
        expect(updatedSubscriber.deletedLocally, true);
        expect(updatedSubscriber.permissionsMask, 'user');
        expect(updatedSubscriber.conflictOrigin, 'cloud');
        expect(updatedSubscriber.conflictDetectedAt, isNot(null));
        expect(updatedSubscriber.conflictResolvedAt, isNot(null));
        expect(updatedSubscriber.conflictResolutionStrategy, 'cloud_wins');
        expect(updatedSubscriber.lastSyncError, 'Connection failed');
        expect(updatedSubscriber.syncRetryCount, 3);
      });
    });

    group('CabinetsTable Sync Metadata', () {
      test('All sync metadata fields exist', () async {
        final cabinet = Cabinet(
          id: 0,
          name: 'Test Cabinet',
          letter: 'F',
          totalSubscribers: 100,
          currentSubscribers: 50,
          collectedAmount: 50000.0,
          delayedSubscribers: 5,
          completionDate: DateTime.now(),
          // Sync metadata fields
          lastModified: DateTime.now(),
          lastSyncedAt: DateTime.now(),
          syncStatus: 'sync_pending',
          dirtyFlag: true,
          cloudId: 'cabinet-cloud-123',
          deletedLocally: false,
          permissionsMask: 'admin',
        );

        final id = await database.into(database.cabinetsTable).insert(cabinet);

        final insertedCabinet = await (database.select(database.cabinetsTable)
              ..where((tbl) => tbl.id.equals(id)))
            .getSingle();

        // Verify all sync metadata fields exist and can be set
        expect(insertedCabinet.lastModified, isNot(null));
        expect(insertedCabinet.lastSyncedAt, isNot(null));
        expect(insertedCabinet.syncStatus, 'sync_pending');
        expect(insertedCabinet.dirtyFlag, true);
        expect(insertedCabinet.cloudId, 'cabinet-cloud-123');
        expect(insertedCabinet.deletedLocally, false);
        expect(insertedCabinet.permissionsMask, 'admin');
      });

      test('Sync metadata fields have correct default values', () async {
        final cabinet = Cabinet(
          id: 0,
          name: 'Test Cabinet 2',
          letter: 'G',
          totalSubscribers: 100,
          currentSubscribers: 50,
          collectedAmount: 50000.0,
          delayedSubscribers: 5,
          completionDate: DateTime.now(),
          // Only providing minimum required fields
        );

        final id = await database.into(database.cabinetsTable).insert(cabinet);

        final insertedCabinet = await (database.select(database.cabinetsTable)
              ..where((tbl) => tbl.id.equals(id)))
            .getSingle();

        // Verify default values for sync metadata fields
        expect(insertedCabinet.syncStatus, 'local_only');
        expect(insertedCabinet.dirtyFlag, false);
        expect(insertedCabinet.deletedLocally, false);
      });
    });

    group('PaymentsTable Sync Metadata', () {
      test('All sync metadata fields exist', () async {
        final payment = Payment(
          id: 0,
          subscriberId: 1,
          amount: 10000.0,
          worker: 'Test Worker',
          date: DateTime.now(),
          cabinet: 'CAB001',
          // Sync metadata fields
          lastModified: DateTime.now(),
          lastSyncedAt: DateTime.now(),
          syncStatus: 'sync_pending',
          dirtyFlag: true,
          cloudId: 'payment-cloud-123',
          deletedLocally: false,
          permissionsMask: 'admin',
        );

        final id = await database.into(database.paymentsTable).insert(payment);

        final insertedPayment = await (database.select(database.paymentsTable)
              ..where((tbl) => tbl.id.equals(id)))
            .getSingle();

        // Verify all sync metadata fields exist and can be set
        expect(insertedPayment.lastModified, isNot(null));
        expect(insertedPayment.lastSyncedAt, isNot(null));
        expect(insertedPayment.syncStatus, 'sync_pending');
        expect(insertedPayment.dirtyFlag, true);
        expect(insertedPayment.cloudId, 'payment-cloud-123');
        expect(insertedPayment.deletedLocally, false);
        expect(insertedPayment.permissionsMask, 'admin');
      });

      test('Sync metadata fields have correct default values', () async {
        final payment = Payment(
          id: 0,
          subscriberId: 1,
          amount: 10000.0,
          worker: 'Test Worker',
          date: DateTime.now(),
          cabinet: 'CAB001',
          // Only providing minimum required fields
        );

        final id = await database.into(database.paymentsTable).insert(payment);

        final insertedPayment = await (database.select(database.paymentsTable)
              ..where((tbl) => tbl.id.equals(id)))
            .getSingle();

        // Verify default values for sync metadata fields
        expect(insertedPayment.syncStatus, 'local_only');
        expect(insertedPayment.dirtyFlag, false);
        expect(insertedPayment.deletedLocally, false);
      });
    });

    group('WorkersTable Sync Metadata', () {
      test('All sync metadata fields exist', () async {
        final worker = Worker(
          id: 0,
          name: 'Test Worker',
          phone: '07701234567',
          permissions: '["collect", "add_subscriber"]',
          todayCollected: 0.0,
          monthTotal: 0.0,
          // Sync metadata fields
          lastModified: DateTime.now(),
          lastSyncedAt: DateTime.now(),
          syncStatus: 'sync_pending',
          dirtyFlag: true,
          cloudId: 'worker-cloud-123',
          deletedLocally: false,
          permissionsMask: 'admin',
        );

        final id = await database.into(database.workersTable).insert(worker);

        final insertedWorker = await (database.select(database.workersTable)
              ..where((tbl) => tbl.id.equals(id)))
            .getSingle();

        // Verify all sync metadata fields exist and can be set
        expect(insertedWorker.lastModified, isNot(null));
        expect(insertedWorker.lastSyncedAt, isNot(null));
        expect(insertedWorker.syncStatus, 'sync_pending');
        expect(insertedWorker.dirtyFlag, true);
        expect(insertedWorker.cloudId, 'worker-cloud-123');
        expect(insertedWorker.deletedLocally, false);
        expect(insertedWorker.permissionsMask, 'admin');
      });

      test('Sync metadata fields have correct default values', () async {
        const worker = Worker(
          id: 0,
          name: 'Test Worker 2',
          phone: '07701234567',
          permissions: '["collect"]',
          todayCollected: 0.0,
          monthTotal: 0.0,
          // Only providing minimum required fields
        );

        final id = await database.into(database.workersTable).insert(worker);

        final insertedWorker = await (database.select(database.workersTable)
              ..where((tbl) => tbl.id.equals(id)))
            .getSingle();

        // Verify default values for sync metadata fields
        expect(insertedWorker.syncStatus, 'local_only');
        expect(insertedWorker.dirtyFlag, false);
        expect(insertedWorker.deletedLocally, false);
      });
    });

    group('AuditLogTable Sync Metadata', () {
      test('All sync metadata fields exist', () async {
        final auditLogEntry = AuditLogEntry(
          id: 0,
          user: 'Test User',
          action: 'create',
          target: 'subscriber',
          details: 'Created subscriber TS001',
          type: 'subscribers',
          timestamp: DateTime.now(),
          // Sync metadata fields
          lastModified: DateTime.now(),
          lastSyncedAt: DateTime.now(),
          syncStatus: 'sync_pending',
          dirtyFlag: true,
          cloudId: 'audit-cloud-123',
          deletedLocally: false,
          permissionsMask: 'admin',
        );

        final id = await database.into(database.auditLogTable).insert(auditLogEntry);

        final insertedAuditLog = await (database.select(database.auditLogTable)
              ..where((tbl) => tbl.id.equals(id)))
            .getSingle();

        // Verify all sync metadata fields exist and can be set
        expect(insertedAuditLog.lastModified, isNot(null));
        expect(insertedAuditLog.lastSyncedAt, isNot(null));
        expect(insertedAuditLog.syncStatus, 'sync_pending');
        expect(insertedAuditLog.dirtyFlag, true);
        expect(insertedAuditLog.cloudId, 'audit-cloud-123');
        expect(insertedAuditLog.deletedLocally, false);
        expect(insertedAuditLog.permissionsMask, 'admin');
      });

      test('Sync metadata fields have correct default values', () async {
        final auditLogEntry = AuditLogEntry(
          id: 0,
          user: 'Test User',
          action: 'update',
          target: 'payment',
          details: 'Updated payment amount',
          type: 'payments',
          timestamp: DateTime.now(),
          // Only providing minimum required fields
        );

        final id = await database.into(database.auditLogTable).insert(auditLogEntry);

        final insertedAuditLog = await (database.select(database.auditLogTable)
              ..where((tbl) => tbl.id.equals(id)))
            .getSingle();

        // Verify default values for sync metadata fields
        expect(insertedAuditLog.syncStatus, 'local_only');
        expect(insertedAuditLog.dirtyFlag, false);
        expect(insertedAuditLog.deletedLocally, false);
      });
    });

    group('WhatsappTemplatesTable Sync Metadata', () {
      test('All sync metadata fields exist', () async {
        final whatsappTemplate = WhatsappTemplateData(
          id: 0,
          title: 'Welcome Message',
          content: 'Welcome to our service!',
          isActive: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          // Sync metadata fields
          lastModified: DateTime.now(),
          lastSyncedAt: DateTime.now(),
          syncStatus: 'sync_pending',
          dirtyFlag: true,
          cloudId: 'template-cloud-123',
          deletedLocally: false,
          permissionsMask: 'admin',
        );

        final id = await database.into(database.whatsappTemplatesTable).insert(whatsappTemplate);

        final insertedTemplate = await (database.select(database.whatsappTemplatesTable)
              ..where((tbl) => tbl.id.equals(id)))
            .getSingle();

        // Verify all sync metadata fields exist and can be set
        expect(insertedTemplate.lastModified, isNot(null));
        expect(insertedTemplate.lastSyncedAt, isNot(null));
        expect(insertedTemplate.syncStatus, 'sync_pending');
        expect(insertedTemplate.dirtyFlag, true);
        expect(insertedTemplate.cloudId, 'template-cloud-123');
        expect(insertedTemplate.deletedLocally, false);
        expect(insertedTemplate.permissionsMask, 'admin');
      });

      test('Sync metadata fields have correct default values', () async {
        final whatsappTemplate = WhatsappTemplateData(
          id: 0,
          title: 'Follow-up Message',
          content: 'Thank you for your payment!',
          isActive: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          // Only providing minimum required fields
        );

        final id = await database.into(database.whatsappTemplatesTable).insert(whatsappTemplate);

        final insertedTemplate = await (database.select(database.whatsappTemplatesTable)
              ..where((tbl) => tbl.id.equals(id)))
            .getSingle();

        // Verify default values for sync metadata fields
        expect(insertedTemplate.syncStatus, 'local_only');
        expect(insertedTemplate.dirtyFlag, false);
        expect(insertedTemplate.deletedLocally, false);
      });
    });
  });
}