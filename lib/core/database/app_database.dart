import 'dart:developer' as developer;
import 'dart:io' show Directory, File;

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/subscribers_dao.dart';
import 'daos/cabinets_dao.dart';
import 'daos/payments_dao.dart';
import 'daos/workers_dao.dart';
import 'daos/audit_log_dao.dart';
import 'daos/whatsapp_templates_dao.dart';
import 'daos/generator_settings_dao.dart';
import 'daos/events_dao.dart';
import 'daos/trash_dao.dart';

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
    OutboxTable,
    EventsTable,
    TrashTable,
  ],
  daos: [
    SubscribersDao,
    CabinetsDao,
    PaymentsDao,
    WorkersDao,
    AuditLogDao,
    WhatsappTemplatesDao,
    GeneratorSettingsDao,
    EventsDao,
    TrashDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _driftInit());

  static QueryExecutor _driftInit() {
    // Use LazyDatabase with a stable path in the application documents directory
    // This ensures data persists across app restarts on Windows
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dbFolder.path, 'mawlid_al_dhaki');
      
      // Ensure directory exists
      final dir = Directory(dbPath);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      
      final file = File(p.join(dbPath, 'mawlid_al_dhaki_v2.db'));
      return NativeDatabase.createInBackground(file);
    });
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
  int get schemaVersion => 5;

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
        
        // Migrate to version 4: add Convex sync metadata (ownerId, version, updatedAt, createdAt, isDeleted)
        if (from < 4) {
          const v4AlterStatements = [
            // SubscribersTable - UUID migration + new sync fields
            'ALTER TABLE subscribers_table ADD COLUMN id TEXT',
            'ALTER TABLE subscribers_table ADD COLUMN owner_id TEXT',
            'ALTER TABLE subscribers_table ADD COLUMN version INTEGER DEFAULT 1',
            'ALTER TABLE subscribers_table ADD COLUMN updated_at INTEGER',
            'ALTER TABLE subscribers_table ADD COLUMN created_at INTEGER',
            'ALTER TABLE subscribers_table ADD COLUMN is_deleted INTEGER DEFAULT 0',
            
            // CabinetsTable
            'ALTER TABLE cabinets_table ADD COLUMN id TEXT',
            'ALTER TABLE cabinets_table ADD COLUMN owner_id TEXT',
            'ALTER TABLE cabinets_table ADD COLUMN version INTEGER DEFAULT 1',
            'ALTER TABLE cabinets_table ADD COLUMN updated_at INTEGER',
            'ALTER TABLE cabinets_table ADD COLUMN created_at INTEGER',
            'ALTER TABLE cabinets_table ADD COLUMN is_deleted INTEGER DEFAULT 0',
            
            // PaymentsTable
            'ALTER TABLE payments_table ADD COLUMN id TEXT',
            'ALTER TABLE payments_table ADD COLUMN owner_id TEXT',
            'ALTER TABLE payments_table ADD COLUMN version INTEGER DEFAULT 1',
            'ALTER TABLE payments_table ADD COLUMN updated_at INTEGER',
            'ALTER TABLE payments_table ADD COLUMN created_at INTEGER',
            'ALTER TABLE payments_table ADD COLUMN is_deleted INTEGER DEFAULT 0',
            
            // WorkersTable
            'ALTER TABLE workers_table ADD COLUMN id TEXT',
            'ALTER TABLE workers_table ADD COLUMN owner_id TEXT',
            'ALTER TABLE workers_table ADD COLUMN version INTEGER DEFAULT 1',
            'ALTER TABLE workers_table ADD COLUMN updated_at INTEGER',
            'ALTER TABLE workers_table ADD COLUMN created_at INTEGER',
            'ALTER TABLE workers_table ADD COLUMN is_deleted INTEGER DEFAULT 0',
            
            // AuditLogTable
            'ALTER TABLE audit_log_table ADD COLUMN id TEXT',
            'ALTER TABLE audit_log_table ADD COLUMN owner_id TEXT',
            'ALTER TABLE audit_log_table ADD COLUMN version INTEGER DEFAULT 1',
            'ALTER TABLE audit_log_table ADD COLUMN updated_at INTEGER',
            'ALTER TABLE audit_log_table ADD COLUMN created_at INTEGER',
            'ALTER TABLE audit_log_table ADD COLUMN is_deleted INTEGER DEFAULT 0',
            
            // WhatsappTemplatesTable
            'ALTER TABLE whatsapp_templates_table ADD COLUMN id TEXT',
            'ALTER TABLE whatsapp_templates_table ADD COLUMN owner_id TEXT',
            'ALTER TABLE whatsapp_templates_table ADD COLUMN version INTEGER DEFAULT 1',
            'ALTER TABLE whatsapp_templates_table ADD COLUMN updated_at INTEGER',
            'ALTER TABLE whatsapp_templates_table ADD COLUMN created_at INTEGER',
            'ALTER TABLE whatsapp_templates_table ADD COLUMN is_deleted INTEGER DEFAULT 0',
            
            // GeneratorSettingsTable
            'ALTER TABLE generator_settings_table ADD COLUMN id TEXT',
            'ALTER TABLE generator_settings_table ADD COLUMN owner_id TEXT',
            'ALTER TABLE generator_settings_table ADD COLUMN version INTEGER DEFAULT 1',
            'ALTER TABLE generator_settings_table ADD COLUMN updated_at INTEGER',
            'ALTER TABLE generator_settings_table ADD COLUMN created_at INTEGER',
            'ALTER TABLE generator_settings_table ADD COLUMN is_deleted INTEGER DEFAULT 0',
          ];
          for (final sql in v4AlterStatements) {
            await _migrateAddColumn(sql);
          }
          
          // Backfill id columns with UUIDs for existing rows (prevents NULL primary key)
          // Using ROWID as a seed for deterministic UUID generation
          await customStatement(
            "UPDATE subscribers_table SET id = 'sub-' || ROWID || '-' || RANDOM() WHERE id IS NULL"
          );
          await customStatement(
            "UPDATE cabinets_table SET id = 'cab-' || ROWID || '-' || RANDOM() WHERE id IS NULL"
          );
          await customStatement(
            "UPDATE payments_table SET id = 'pay-' || ROWID || '-' || RANDOM() WHERE id IS NULL"
          );
          await customStatement(
            "UPDATE workers_table SET id = 'wrk-' || ROWID || '-' || RANDOM() WHERE id IS NULL"
          );
          await customStatement(
            "UPDATE audit_log_table SET id = 'aud-' || ROWID || '-' || RANDOM() WHERE id IS NULL"
          );
          await customStatement(
            "UPDATE whatsapp_templates_table SET id = 'wat-' || ROWID || '-' || RANDOM() WHERE id IS NULL"
          );
          await customStatement(
            "UPDATE generator_settings_table SET id = 'gen-' || ROWID || '-' || RANDOM() WHERE id IS NULL"
          );
          
          print('Database migration to v4 completed successfully');
        }
        
        // Migrate to version 5: add EventsTable and TrashTable for event-sourced sync and trash functionality
        if (from < 5) {
          await m.createTable(eventsTable);
          await m.createTable(trashTable);
          print('Database migration to v5 completed successfully (EventsTable and TrashTable added)');
        }
      },
      beforeOpen: (details) async {
        print('Database opening with version ${details.versionNow}, wasCreated: ${details.wasCreated}');
        
        // Ensure trash_table exists (for databases that may have been at v5 before trash was added to migration)
        try {
          await customStatement('SELECT 1 FROM trash_table LIMIT 1');
        } catch (e) {
          // Table doesn't exist, create it
          try {
            await customStatement('''
              CREATE TABLE IF NOT EXISTS trash_table (
                id TEXT NOT NULL PRIMARY KEY,
                entity_type TEXT NOT NULL,
                entity_id TEXT NOT NULL,
                entity_data TEXT NOT NULL,
                owner_id TEXT NOT NULL,
                deleted_at INTEGER NOT NULL,
                expires_at INTEGER NOT NULL,
                created_at INTEGER NOT NULL,
                updated_at INTEGER NOT NULL
              )
            ''');
            print('Created missing trash_table');
          } catch (createError) {
            print('Warning: Failed to create trash_table: $createError');
          }
        }
        
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

// ============================================================
// OUTBOX TABLE - For offline write queue (Convex sync)
// ============================================================
@DataClassName('OutboxEntry')
class OutboxTable extends Table {
  TextColumn get id => text()(); // UUID
  
  // Operation details
  TextColumn get targetTable => text()(); // e.g., 'subscribers', 'payments' (renamed from tableName to avoid conflict)
  TextColumn get operationType => text()(); // 'create', 'update', 'delete'
  TextColumn get documentId => text()(); // The Convex document ID
  TextColumn get payload => text()(); // JSON serialized document data
  
  // Status tracking
  TextColumn get status => text().withDefault(const Constant('pending'))(); // 'pending', 'syncing', 'failed', 'synced'
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  
  // Timestamps
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// SUBSCRIBERS TABLE - Updated for Convex sync
// ============================================================
@DataClassName('Subscriber')
class SubscribersTable extends Table {
  // Global UUID from Convex (primary key)
  TextColumn get id => text()();
  
  // Domain Data
  TextColumn get name => text()();
  TextColumn get code => text()();
  TextColumn get cabinet => text()();
  TextColumn get phone => text()();
  IntColumn get status => integer()(); // 0: inactive, 1: active, 2: suspended, 3: disconnected
  DateTimeColumn get startDate => dateTime()();
  RealColumn get accumulatedDebt => real().withDefault(const Constant(0))();
  TextColumn get tags => text().nullable()();
  TextColumn get notes => text().nullable()();
  
  // Legacy sync metadata (kept for v1→v2 compatibility)
  DateTimeColumn get lastModified => dateTime().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('local_only')).nullable()();
  BoolColumn get dirtyFlag => boolean().withDefault(const Constant(false)).nullable()();
  TextColumn get cloudId => text().nullable()();
  BoolColumn get deletedLocally => boolean().withDefault(const Constant(false)).nullable()();
  TextColumn get permissionsMask => text().nullable()();
  
  // Convex sync metadata (NEW)
  TextColumn get ownerId => text().nullable()(); // Tenant isolation
  IntColumn get version => integer().withDefault(const Constant(1))(); // LWW conflict resolution
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))(); // Soft delete
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// CABINETS TABLE - Updated for Convex sync
// ============================================================
@DataClassName('Cabinet')
class CabinetsTable extends Table {
  // Global UUID from Convex
  TextColumn get id => text()();
  
  // Domain Data
  TextColumn get name => text()();
  TextColumn get letter => text().withDefault(const Constant(''))();
  IntColumn get totalSubscribers => integer()();
  IntColumn get currentSubscribers => integer()();
  RealColumn get collectedAmount => real().withDefault(const Constant(0))();
  IntColumn get delayedSubscribers => integer()();
  DateTimeColumn get completionDate => dateTime().nullable()();
  
  // Legacy sync metadata
  DateTimeColumn get lastModified => dateTime().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('local_only')).nullable()();
  BoolColumn get dirtyFlag => boolean().withDefault(const Constant(false)).nullable()();
  TextColumn get cloudId => text().nullable()();
  BoolColumn get deletedLocally => boolean().withDefault(const Constant(false)).nullable()();
  TextColumn get permissionsMask => text().nullable()();
  
  // Convex sync metadata (NEW)
  TextColumn get ownerId => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// PAYMENTS TABLE - Updated for Convex sync
// ============================================================
@DataClassName('Payment')
class PaymentsTable extends Table {
  // Global UUID from Convex
  TextColumn get id => text()();
  
  // Domain Data (references by UUID now)
  TextColumn get subscriberId => text()(); // Changed from IntColumn to TextColumn (UUID)
  RealColumn get amount => real()();
  TextColumn get worker => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get cabinet => text()();
  
  // Legacy sync metadata
  DateTimeColumn get lastModified => dateTime().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('local_only')).nullable()();
  BoolColumn get dirtyFlag => boolean().withDefault(const Constant(false)).nullable()();
  TextColumn get cloudId => text().nullable()();
  BoolColumn get deletedLocally => boolean().withDefault(const Constant(false)).nullable()();
  TextColumn get permissionsMask => text().nullable()();
  
  // Convex sync metadata (NEW)
  TextColumn get ownerId => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// WORKERS TABLE - Updated for Convex sync
// ============================================================
@DataClassName('Worker')
class WorkersTable extends Table {
  // Global UUID from Convex
  TextColumn get id => text()();
  
  // Domain Data
  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get permissions => text()(); // JSON string of permissions
  RealColumn get todayCollected => real().withDefault(const Constant(0))();
  RealColumn get monthTotal => real().withDefault(const Constant(0))();
  
  // Legacy sync metadata
  DateTimeColumn get lastModified => dateTime().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('local_only')).nullable()();
  BoolColumn get dirtyFlag => boolean().withDefault(const Constant(false)).nullable()();
  TextColumn get cloudId => text().nullable()();
  BoolColumn get deletedLocally => boolean().withDefault(const Constant(false)).nullable()();
  TextColumn get permissionsMask => text().nullable()();
  
  // Convex sync metadata (NEW)
  TextColumn get ownerId => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// AUDIT LOG TABLE - Updated for Convex sync
// ============================================================
@DataClassName('AuditLogEntry')
class AuditLogTable extends Table {
  // Global UUID from Convex
  TextColumn get id => text()();
  
  // Domain Data
  TextColumn get user => text()();
  TextColumn get action => text()();
  TextColumn get target => text()();
  TextColumn get details => text()();
  TextColumn get type => text()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  
  // Legacy sync metadata
  DateTimeColumn get lastModified => dateTime().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('local_only')).nullable()();
  BoolColumn get dirtyFlag => boolean().withDefault(const Constant(false)).nullable()();
  TextColumn get cloudId => text().nullable()();
  BoolColumn get deletedLocally => boolean().withDefault(const Constant(false)).nullable()();
  TextColumn get permissionsMask => text().nullable()();
  
  // Convex sync metadata (NEW)
  TextColumn get ownerId => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// GENERATOR SETTINGS TABLE - Per-tenant singleton
// ============================================================
@DataClassName('GeneratorSettingsData')
class GeneratorSettingsTable extends Table {
  // Global UUID from Convex
  TextColumn get id => text()();
  
  // Domain Data
  TextColumn get name => text()();
  TextColumn get phoneNumber => text()();
  TextColumn get address => text()();
  TextColumn get logoPath => text().nullable()();
  
  // Convex sync metadata (NEW)
  TextColumn get ownerId => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// EVENTS TABLE - For event-sourced sync (Phase 1)
// ============================================================
@DataClassName('EventEntry')
class EventsTable extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get eventType => text()(); // 'ENTITY_CREATED', 'ENTITY_UPDATED', etc.
  TextColumn get entityType => text()(); // 'subscribers', 'cabinets', etc.
  TextColumn get entityId => text()(); // The entity's UUID
  TextColumn get payload => text()(); // JSON serialized event data
  IntColumn get version => integer()(); // Entity version at time of event
  DateTimeColumn get occurredAt => dateTime()(); // When event occurred
  TextColumn get status => text().withDefault(const Constant('pending'))(); // 'pending', 'synced', 'failed'
  DateTimeColumn get createdAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// WHATSAPP TEMPLATES TABLE - Updated for Convex sync
// ============================================================
@DataClassName('WhatsappTemplateData')
class WhatsappTemplatesTable extends Table {
  // Global UUID from Convex
  TextColumn get id => text()();
  
  // Domain Data
  TextColumn get title => text()();
  TextColumn get content => text()();
  IntColumn get isActive => integer().withDefault(const Constant(0))();
  
  // Legacy sync metadata
  DateTimeColumn get lastModified => dateTime().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('local_only')).nullable()();
  BoolColumn get dirtyFlag => boolean().withDefault(const Constant(false)).nullable()();
  TextColumn get cloudId => text().nullable()();
  BoolColumn get deletedLocally => boolean().withDefault(const Constant(false)).nullable()();
  TextColumn get permissionsMask => text().nullable()();
  
  // Convex sync metadata (NEW)
  TextColumn get ownerId => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// TRASH TABLE - For soft-deleted items before permanent deletion
// ============================================================
@DataClassName('TrashItem')
class TrashTable extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get entityType => text()(); // 'subscribers', 'cabinets', etc.
  TextColumn get entityId => text()(); // The entity's UUID
  TextColumn get entityData => text()(); // JSON snapshot of entity
  TextColumn get ownerId => text()();
  DateTimeColumn get deletedAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime()(); // Auto-delete after this
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}