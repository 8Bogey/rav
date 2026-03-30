import 'dart:developer' as developer;

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/subscribers_dao.dart';
import 'daos/cabinets_dao.dart';
import 'daos/payments_dao.dart';
import 'daos/workers_dao.dart';
import 'daos/audit_log_dao.dart';
import 'daos/whatsapp_templates_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    SubscribersTable,
    CabinetsTable,
    PaymentsTable,
    WorkersTable,
    AuditLogTable,
    WhatsappTemplatesTable,
    GeneratorSettingsTable,
  ],
  daos: [
    SubscribersDao,
    CabinetsDao,
    PaymentsDao,
    WorkersDao,
    AuditLogDao,
    WhatsappTemplatesDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _driftInit());

  static QueryExecutor _driftInit() {
    return driftDatabase(name: 'mawlid_al_dhaki_v1.db');
  }

  /// Runs a manual ALTER for v1→v2-style migrations; rethrows unless SQLite reports duplicate column.
  Future<void> _migrateAddColumn(String sql) async {
    try {
      await customStatement(sql);
    } catch (e, st) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('duplicate column') || msg.contains('already exists')) {
        developer.log(
          'Skipping migration (column already present): $sql',
          name: 'AppDatabase',
        );
        return;
      }
      developer.log(
        'Migration failed: $e',
        name: 'AppDatabase',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        print('Creating database tables...');
        await m.createAll();
        print('Database tables created successfully');
      },
      onUpgrade: (Migrator m, int from, int to) async {
        print('Upgrading database from version $from to $to');
        // Migrate from version 1 to version 2: add sync metadata fields (if not exist)
        if (from < 2) {
          const alterStatements = [
            'ALTER TABLE subscribers_table ADD COLUMN last_modified INTEGER',
            'ALTER TABLE subscribers_table ADD COLUMN last_synced_at INTEGER',
            'ALTER TABLE subscribers_table ADD COLUMN sync_status TEXT',
            'ALTER TABLE subscribers_table ADD COLUMN dirty_flag INTEGER',
            'ALTER TABLE subscribers_table ADD COLUMN cloud_id TEXT',
            'ALTER TABLE subscribers_table ADD COLUMN deleted_locally INTEGER',
            'ALTER TABLE cabinets_table ADD COLUMN letter TEXT',
            'ALTER TABLE cabinets_table ADD COLUMN last_modified INTEGER',
            'ALTER TABLE cabinets_table ADD COLUMN last_synced_at INTEGER',
            'ALTER TABLE cabinets_table ADD COLUMN sync_status TEXT',
            'ALTER TABLE cabinets_table ADD COLUMN dirty_flag INTEGER',
            'ALTER TABLE cabinets_table ADD COLUMN cloud_id TEXT',
            'ALTER TABLE cabinets_table ADD COLUMN deleted_locally INTEGER',
            'ALTER TABLE payments_table ADD COLUMN last_modified INTEGER',
            'ALTER TABLE payments_table ADD COLUMN last_synced_at INTEGER',
            'ALTER TABLE payments_table ADD COLUMN sync_status TEXT',
            'ALTER TABLE payments_table ADD COLUMN dirty_flag INTEGER',
            'ALTER TABLE payments_table ADD COLUMN cloud_id TEXT',
            'ALTER TABLE payments_table ADD COLUMN deleted_locally INTEGER',
            'ALTER TABLE workers_table ADD COLUMN last_modified INTEGER',
            'ALTER TABLE workers_table ADD COLUMN last_synced_at INTEGER',
            'ALTER TABLE workers_table ADD COLUMN sync_status TEXT',
            'ALTER TABLE workers_table ADD COLUMN dirty_flag INTEGER',
            'ALTER TABLE workers_table ADD COLUMN cloud_id TEXT',
            'ALTER TABLE workers_table ADD COLUMN deleted_locally INTEGER',
            'ALTER TABLE audit_log_table ADD COLUMN last_modified INTEGER',
            'ALTER TABLE audit_log_table ADD COLUMN last_synced_at INTEGER',
            'ALTER TABLE audit_log_table ADD COLUMN sync_status TEXT',
            'ALTER TABLE audit_log_table ADD COLUMN dirty_flag INTEGER',
            'ALTER TABLE audit_log_table ADD COLUMN cloud_id TEXT',
            'ALTER TABLE audit_log_table ADD COLUMN deleted_locally INTEGER',
            'ALTER TABLE whatsapp_templates_table ADD COLUMN last_modified INTEGER',
            'ALTER TABLE whatsapp_templates_table ADD COLUMN last_synced_at INTEGER',
            'ALTER TABLE whatsapp_templates_table ADD COLUMN sync_status TEXT',
            'ALTER TABLE whatsapp_templates_table ADD COLUMN dirty_flag INTEGER',
            'ALTER TABLE whatsapp_templates_table ADD COLUMN cloud_id TEXT',
            'ALTER TABLE whatsapp_templates_table ADD COLUMN deleted_locally INTEGER',
          ];
          for (final sql in alterStatements) {
            await _migrateAddColumn(sql);
          }
          print('Database migration to v2 completed successfully');
        }
        
        // Migrate to version 3: ensure letter column exists in cabinets_table
        if (from < 3) {
          await _migrateAddColumn('ALTER TABLE cabinets_table ADD COLUMN letter TEXT DEFAULT ""');
          print('Database migration to v3 completed successfully');
        }
      },
      beforeOpen: (details) async {
        print('Database opening with version ${details.versionNow}, wasCreated: ${details.wasCreated}');
        // Fix any NULL values in cabinets_table that might cause null check crashes
        try {
          await customStatement("UPDATE cabinets_table SET name = 'Unknown' WHERE name IS NULL");
          await customStatement("UPDATE cabinets_table SET letter = '' WHERE letter IS NULL");
          await customStatement("UPDATE cabinets_table SET total_subscribers = 0 WHERE total_subscribers IS NULL");
          await customStatement("UPDATE cabinets_table SET current_subscribers = 0 WHERE current_subscribers IS NULL");
          await customStatement("UPDATE cabinets_table SET collected_amount = 0 WHERE collected_amount IS NULL");
          await customStatement("UPDATE cabinets_table SET delayed_subscribers = 0 WHERE delayed_subscribers IS NULL");
        } catch (e) {
          print('Warning: Failed to sanitize cabinets_table: $e');
        }
      },
    );
  }
}

// Subscribers table
@DataClassName('Subscriber')
class SubscribersTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get code => text().unique()();
  TextColumn get cabinet => text()();
  TextColumn get phone => text()();
  IntColumn get status =>
      integer()(); // 0: inactive, 1: active, 2: suspended, 3: disconnected
  DateTimeColumn get startDate => dateTime()();
  RealColumn get accumulatedDebt => real().withDefault(const Constant(0))();
  TextColumn get tags => text().nullable()();
  TextColumn get notes => text().nullable()();
  
    // Sync metadata fields for offline-first functionality
    DateTimeColumn get lastModified => dateTime().nullable()(); // Timestamp of last local modification
    DateTimeColumn get lastSyncedAt => dateTime().nullable()(); // Timestamp of last successful sync with cloud
    TextColumn get syncStatus => text().withDefault(const Constant('local_only')).nullable()(); // Status: local_only, sync_pending, synced, conflict
    BoolColumn get dirtyFlag => boolean().withDefault(const Constant(false)).nullable()(); // Indicates if record has unsynced changes
    TextColumn get cloudId => text().nullable()(); // Unique identifier in cloud database
    BoolColumn get deletedLocally => boolean().withDefault(const Constant(false)).nullable()(); // Soft delete marker for sync purposes
    TextColumn get permissionsMask => text().nullable()(); // Selective sync markers for Android permissions
    
    // Conflict resolution fields
    TextColumn get conflictOrigin => text().nullable()(); // Origin of conflict (cloud/local/both)
    DateTimeColumn get conflictDetectedAt => dateTime().nullable()(); // When conflict was detected
    DateTimeColumn get conflictResolvedAt => dateTime().nullable()(); // When conflict was resolved
    TextColumn get conflictResolutionStrategy => text().nullable()(); // How conflict was resolved (local_wins/cloud_wins/merge/manual)
    
    // Sync error tracking fields
    TextColumn get lastSyncError => text().nullable()(); // Last sync error message
    IntColumn get syncRetryCount => integer().withDefault(const Constant(0)).nullable()(); // Number of sync retries
  }

  // Cabinets table
  @DataClassName('Cabinet')
  class CabinetsTable extends Table {
    IntColumn get id => integer().autoIncrement()();
    TextColumn get name => text()();
    TextColumn get letter => text().withDefault(const Constant(''))(); // Cabinet letter (A, B, C, etc.) - separate from name
    IntColumn get totalSubscribers => integer()();
    IntColumn get currentSubscribers => integer()();
    RealColumn get collectedAmount => real().withDefault(const Constant(0))();
    IntColumn get delayedSubscribers => integer()();
    DateTimeColumn get completionDate => dateTime().nullable()();
    
    // Sync metadata fields for offline-first functionality
    DateTimeColumn get lastModified => dateTime().nullable()(); // Timestamp of last local modification
    DateTimeColumn get lastSyncedAt => dateTime().nullable()(); // Timestamp of last successful sync with cloud
    TextColumn get syncStatus => text().withDefault(const Constant('local_only')).nullable()(); // Status: local_only, sync_pending, synced, conflict
    BoolColumn get dirtyFlag => boolean().withDefault(const Constant(false)).nullable()(); // Indicates if record has unsynced changes
    TextColumn get cloudId => text().nullable()(); // Unique identifier in cloud database
    BoolColumn get deletedLocally => boolean().withDefault(const Constant(false)).nullable()(); // Soft delete marker for sync purposes
    TextColumn get permissionsMask => text().nullable()(); // Selective sync markers for Android permissions
    
    // Conflict resolution fields
    TextColumn get conflictOrigin => text().nullable()(); // Origin of conflict (cloud/local/both)
    DateTimeColumn get conflictDetectedAt => dateTime().nullable()(); // When conflict was detected
    DateTimeColumn get conflictResolvedAt => dateTime().nullable()(); // When conflict was resolved
    TextColumn get conflictResolutionStrategy => text().nullable()(); // How conflict was resolved (local_wins/cloud_wins/merge/manual)
    
    // Sync error tracking fields
    TextColumn get lastSyncError => text().nullable()(); // Last sync error message
    IntColumn get syncRetryCount => integer().withDefault(const Constant(0)).nullable()(); // Number of sync retries
  }

  // Payments table
  @DataClassName('Payment')
  class PaymentsTable extends Table {
    IntColumn get id => integer().autoIncrement()();
    IntColumn get subscriberId => integer().references(SubscribersTable, #id)();
    RealColumn get amount => real()();
    TextColumn get worker => text()();
    DateTimeColumn get date => dateTime()();
    TextColumn get cabinet => text()();
    
    // Sync metadata fields for offline-first functionality
    DateTimeColumn get lastModified => dateTime().nullable()(); // Timestamp of last local modification
    DateTimeColumn get lastSyncedAt => dateTime().nullable()(); // Timestamp of last successful sync with cloud
    TextColumn get syncStatus => text().withDefault(const Constant('local_only')).nullable()(); // Status: local_only, sync_pending, synced, conflict
    BoolColumn get dirtyFlag => boolean().withDefault(const Constant(false)).nullable()(); // Indicates if record has unsynced changes
    TextColumn get cloudId => text().nullable()(); // Unique identifier in cloud database
    BoolColumn get deletedLocally => boolean().withDefault(const Constant(false)).nullable()(); // Soft delete marker for sync purposes
    TextColumn get permissionsMask => text().nullable()(); // Selective sync markers for Android permissions
    
    // Conflict resolution fields
    TextColumn get conflictOrigin => text().nullable()(); // Origin of conflict (cloud/local/both)
    DateTimeColumn get conflictDetectedAt => dateTime().nullable()(); // When conflict was detected
    DateTimeColumn get conflictResolvedAt => dateTime().nullable()(); // When conflict was resolved
    TextColumn get conflictResolutionStrategy => text().nullable()(); // How conflict was resolved (local_wins/cloud_wins/merge/manual)
    
    // Sync error tracking fields
    TextColumn get lastSyncError => text().nullable()(); // Last sync error message
    IntColumn get syncRetryCount => integer().withDefault(const Constant(0)).nullable()(); // Number of sync retries
  }
  
  // Workers table
  @DataClassName('Worker')
  class WorkersTable extends Table {
    IntColumn get id => integer().autoIncrement()();
    TextColumn get name => text()();
    TextColumn get phone => text()();
    TextColumn get permissions => text()(); // JSON string of permissions
    RealColumn get todayCollected => real().withDefault(const Constant(0))();
    RealColumn get monthTotal => real().withDefault(const Constant(0))();
    
    // Sync metadata fields for offline-first functionality
    DateTimeColumn get lastModified => dateTime().nullable()(); // Timestamp of last local modification
    DateTimeColumn get lastSyncedAt => dateTime().nullable()(); // Timestamp of last successful sync with cloud
    TextColumn get syncStatus => text().withDefault(const Constant('local_only')).nullable()(); // Status: local_only, sync_pending, synced, conflict
    BoolColumn get dirtyFlag => boolean().withDefault(const Constant(false)).nullable()(); // Indicates if record has unsynced changes
    TextColumn get cloudId => text().nullable()(); // Unique identifier in cloud database
    BoolColumn get deletedLocally => boolean().withDefault(const Constant(false)).nullable()(); // Soft delete marker for sync purposes
    TextColumn get permissionsMask => text().nullable()(); // Selective sync markers for Android permissions
    
    // Conflict resolution fields
    TextColumn get conflictOrigin => text().nullable()(); // Origin of conflict (cloud/local/both)
    DateTimeColumn get conflictDetectedAt => dateTime().nullable()(); // When conflict was detected
    DateTimeColumn get conflictResolvedAt => dateTime().nullable()(); // When conflict was resolved
    TextColumn get conflictResolutionStrategy => text().nullable()(); // How conflict was resolved (local_wins/cloud_wins/merge/manual)
    
    // Sync error tracking fields
    TextColumn get lastSyncError => text().nullable()(); // Last sync error message
    IntColumn get syncRetryCount => integer().withDefault(const Constant(0)).nullable()(); // Number of sync retries
  }
  
  // Audit log table
  @DataClassName('AuditLogEntry')
  class AuditLogTable extends Table {
    IntColumn get id => integer().autoIncrement()();
    TextColumn get user => text()();
    TextColumn get action => text()();
    TextColumn get target => text()();
    TextColumn get details => text()();
    TextColumn get type => text()();
    DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
    
    // Sync metadata fields for offline-first functionality
    DateTimeColumn get lastModified => dateTime().nullable()(); // Timestamp of last local modification
    DateTimeColumn get lastSyncedAt => dateTime().nullable()(); // Timestamp of last successful sync with cloud
    TextColumn get syncStatus => text().withDefault(const Constant('local_only')).nullable()(); // Status: local_only, sync_pending, synced, conflict
    BoolColumn get dirtyFlag => boolean().withDefault(const Constant(false)).nullable()(); // Indicates if record has unsynced changes
    TextColumn get cloudId => text().nullable()(); // Unique identifier in cloud database
    BoolColumn get deletedLocally => boolean().withDefault(const Constant(false)).nullable()(); // Soft delete marker for sync purposes
    TextColumn get permissionsMask => text().nullable()(); // Selective sync markers for Android permissions
    
    // Conflict resolution fields
    TextColumn get conflictOrigin => text().nullable()(); // Origin of conflict (cloud/local/both)
    DateTimeColumn get conflictDetectedAt => dateTime().nullable()(); // When conflict was detected
    DateTimeColumn get conflictResolvedAt => dateTime().nullable()(); // When conflict was resolved
    TextColumn get conflictResolutionStrategy => text().nullable()(); // How conflict was resolved (local_wins/cloud_wins/merge/manual)
    
    // Sync error tracking fields
    TextColumn get lastSyncError => text().nullable()(); // Last sync error message
    IntColumn get syncRetryCount => integer().withDefault(const Constant(0)).nullable()(); // Number of sync retries
  }
  
  // Generator Settings table
  @DataClassName('GeneratorSettingsData')
  class GeneratorSettingsTable extends Table {
    IntColumn get id => integer().autoIncrement()();
    TextColumn get name => text()();
    TextColumn get phoneNumber => text()();
    TextColumn get address => text()();
    TextColumn get logoPath => text().nullable()();
    DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
    DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  }
  
  // WhatsApp templates table
  @DataClassName('WhatsappTemplateData')
  class WhatsappTemplatesTable extends Table {
    IntColumn get id => integer().autoIncrement()();
    TextColumn get title => text()();
    TextColumn get content => text()();
    IntColumn get isActive => integer().withDefault(const Constant(0))();
    DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
    DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
    
    // Sync metadata fields for offline-first functionality
    DateTimeColumn get lastModified => dateTime().nullable()(); // Timestamp of last local modification
    DateTimeColumn get lastSyncedAt => dateTime().nullable()(); // Timestamp of last successful sync with cloud
    TextColumn get syncStatus => text().withDefault(const Constant('local_only')).nullable()(); // Status: local_only, sync_pending, synced, conflict
    BoolColumn get dirtyFlag => boolean().withDefault(const Constant(false)).nullable()(); // Indicates if record has unsynced changes
    TextColumn get cloudId => text().nullable()(); // Unique identifier in cloud database
    BoolColumn get deletedLocally => boolean().withDefault(const Constant(false)).nullable()(); // Soft delete marker for sync purposes
    TextColumn get permissionsMask => text().nullable()(); // Selective sync markers for Android permissions
    
    // Conflict resolution fields
    TextColumn get conflictOrigin => text().nullable()(); // Origin of conflict (cloud/local/both)
    DateTimeColumn get conflictDetectedAt => dateTime().nullable()(); // When conflict was detected
    DateTimeColumn get conflictResolvedAt => dateTime().nullable()(); // When conflict was resolved
    TextColumn get conflictResolutionStrategy => text().nullable()(); // How conflict was resolved (local_wins/cloud_wins/merge/manual)
    
    // Sync error tracking fields
    TextColumn get lastSyncError => text().nullable()(); // Last sync error message
    IntColumn get syncRetryCount => integer().withDefault(const Constant(0)).nullable()(); // Number of sync retries
  }
