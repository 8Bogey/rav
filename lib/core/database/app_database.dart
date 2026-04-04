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
import 'daos/sync_metadata_dao.dart';

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
    SyncMetadataTable,
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
    SyncMetadataDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _driftInit());

  static QueryExecutor _driftInit() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dbFolder.path, 'mawlid_al_dhaki');

      final dir = Directory(dbPath);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }

      final file = File(p.join(dbPath, 'mawlid_al_dhaki_v3.db'));
      return NativeDatabase.createInBackground(file);
    });
  }

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        // Enable WAL mode for better concurrent read/write performance
        await customStatement('PRAGMA journal_mode=WAL');
        // Enable foreign keys
        await customStatement('PRAGMA foreign_keys=ON');
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Run all intermediate migrations
        if (from < 2) await _migrateV1toV2();
        if (from < 3) await _migrateV2toV3();
        if (from < 4) await _migrateV3toV4();
        if (from < 5) await _migrateV4toV5();
        if (from < 6) await _migrateV5toV6();
        if (from < 7) await _migrateV6toV7();
      },
      beforeOpen: (details) async {
        // Enable WAL mode and foreign keys on every open
        await customStatement('PRAGMA journal_mode=WAL');
        await customStatement('PRAGMA foreign_keys=ON');

        // Self-healing: fix any NULL values that might cause crashes
        await _sanitizeDatabase();
      },
    );
  }

  Future<void> _migrateV1toV2() async {
    // Legacy: added sync metadata fields
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
  }

  Future<void> _migrateV2toV3() async {
    await _migrateAddColumn(
        'ALTER TABLE cabinets_table ADD COLUMN letter TEXT DEFAULT ""');
  }

  Future<void> _migrateV3toV4() async {
    // Added Convex sync metadata (ownerId, version, updatedAt, createdAt, isDeleted)
    const v4AlterStatements = [
      'ALTER TABLE subscribers_table ADD COLUMN id TEXT',
      'ALTER TABLE subscribers_table ADD COLUMN owner_id TEXT',
      'ALTER TABLE subscribers_table ADD COLUMN version INTEGER DEFAULT 1',
      'ALTER TABLE subscribers_table ADD COLUMN updated_at INTEGER',
      'ALTER TABLE subscribers_table ADD COLUMN created_at INTEGER',
      'ALTER TABLE subscribers_table ADD COLUMN is_deleted INTEGER DEFAULT 0',
      'ALTER TABLE cabinets_table ADD COLUMN id TEXT',
      'ALTER TABLE cabinets_table ADD COLUMN owner_id TEXT',
      'ALTER TABLE cabinets_table ADD COLUMN version INTEGER DEFAULT 1',
      'ALTER TABLE cabinets_table ADD COLUMN updated_at INTEGER',
      'ALTER TABLE cabinets_table ADD COLUMN created_at INTEGER',
      'ALTER TABLE cabinets_table ADD COLUMN is_deleted INTEGER DEFAULT 0',
      'ALTER TABLE payments_table ADD COLUMN id TEXT',
      'ALTER TABLE payments_table ADD COLUMN owner_id TEXT',
      'ALTER TABLE payments_table ADD COLUMN version INTEGER DEFAULT 1',
      'ALTER TABLE payments_table ADD COLUMN updated_at INTEGER',
      'ALTER TABLE payments_table ADD COLUMN created_at INTEGER',
      'ALTER TABLE payments_table ADD COLUMN is_deleted INTEGER DEFAULT 0',
      'ALTER TABLE workers_table ADD COLUMN id TEXT',
      'ALTER TABLE workers_table ADD COLUMN owner_id TEXT',
      'ALTER TABLE workers_table ADD COLUMN version INTEGER DEFAULT 1',
      'ALTER TABLE workers_table ADD COLUMN updated_at INTEGER',
      'ALTER TABLE workers_table ADD COLUMN created_at INTEGER',
      'ALTER TABLE workers_table ADD COLUMN is_deleted INTEGER DEFAULT 0',
      'ALTER TABLE audit_log_table ADD COLUMN id TEXT',
      'ALTER TABLE audit_log_table ADD COLUMN owner_id TEXT',
      'ALTER TABLE audit_log_table ADD COLUMN version INTEGER DEFAULT 1',
      'ALTER TABLE audit_log_table ADD COLUMN updated_at INTEGER',
      'ALTER TABLE audit_log_table ADD COLUMN created_at INTEGER',
      'ALTER TABLE audit_log_table ADD COLUMN is_deleted INTEGER DEFAULT 0',
      'ALTER TABLE whatsapp_templates_table ADD COLUMN id TEXT',
      'ALTER TABLE whatsapp_templates_table ADD COLUMN owner_id TEXT',
      'ALTER TABLE whatsapp_templates_table ADD COLUMN version INTEGER DEFAULT 1',
      'ALTER TABLE whatsapp_templates_table ADD COLUMN updated_at INTEGER',
      'ALTER TABLE whatsapp_templates_table ADD COLUMN created_at INTEGER',
      'ALTER TABLE whatsapp_templates_table ADD COLUMN is_deleted INTEGER DEFAULT 0',
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
    // Backfill IDs
    await customStatement(
        "UPDATE subscribers_table SET id = 'sub-' || ROWID || '-' || RANDOM() WHERE id IS NULL");
    await customStatement(
        "UPDATE cabinets_table SET id = 'cab-' || ROWID || '-' || RANDOM() WHERE id IS NULL");
    await customStatement(
        "UPDATE payments_table SET id = 'pay-' || ROWID || '-' || RANDOM() WHERE id IS NULL");
    await customStatement(
        "UPDATE workers_table SET id = 'wrk-' || ROWID || '-' || RANDOM() WHERE id IS NULL");
    await customStatement(
        "UPDATE audit_log_table SET id = 'aud-' || ROWID || '-' || RANDOM() WHERE id IS NULL");
    await customStatement(
        "UPDATE whatsapp_templates_table SET id = 'wat-' || ROWID || '-' || RANDOM() WHERE id IS NULL");
    await customStatement(
        "UPDATE generator_settings_table SET id = 'gen-' || ROWID || '-' || RANDOM() WHERE id IS NULL");
  }

  Future<void> _migrateV4toV5() async {
    // EventsTable and TrashTable added
    // These are created via customStatement since m.createTable may not work in all cases
    await customStatement('''
      CREATE TABLE IF NOT EXISTS events_table (
        id TEXT NOT NULL PRIMARY KEY,
        event_type TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        payload TEXT NOT NULL,
        version INTEGER NOT NULL,
        occurred_at INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        created_at INTEGER NOT NULL
      )
    ''');
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
  }

  Future<void> _migrateV5toV6() async {
    // inTrash, status TEXT enum, isActive BOOL, trashMovedAt
    // SubscribersTable: recreate with status TEXT + inTrash
    await _recreateTableWithStatusConversion(
        'subscribers_table',
        [
          'id TEXT NOT NULL PRIMARY KEY',
          'name TEXT NOT NULL',
          'code TEXT NOT NULL',
          'cabinet TEXT NOT NULL',
          'phone TEXT NOT NULL',
          "status TEXT NOT NULL DEFAULT 'active'",
          'start_date INTEGER NOT NULL',
          'accumulated_debt REAL NOT NULL DEFAULT 0',
          'tags TEXT',
          'notes TEXT',
          'last_modified INTEGER',
          'last_synced_at INTEGER',
          "sync_status TEXT DEFAULT 'local_only'",
          'dirty_flag INTEGER DEFAULT 0',
          'cloud_id TEXT',
          'deleted_locally INTEGER DEFAULT 0',
          'permissions_mask TEXT',
          'owner_id TEXT',
          'version INTEGER DEFAULT 1',
          'in_trash INTEGER DEFAULT 0',
          'trash_moved_at INTEGER',
          'is_deleted INTEGER DEFAULT 0',
          'updated_at INTEGER',
          'created_at INTEGER',
        ],
        statusColumnIndex: 5);

    // WhatsApp templates: recreate with isActive BOOL
    await _recreateTableWithBoolConversion(
        'whatsapp_templates_table',
        [
          'id TEXT NOT NULL PRIMARY KEY',
          'title TEXT NOT NULL',
          'content TEXT NOT NULL',
          'is_active INTEGER NOT NULL DEFAULT 0',
          'last_modified INTEGER',
          'last_synced_at INTEGER',
          "sync_status TEXT DEFAULT 'local_only'",
          'dirty_flag INTEGER DEFAULT 0',
          'cloud_id TEXT',
          'deleted_locally INTEGER DEFAULT 0',
          'permissions_mask TEXT',
          'owner_id TEXT',
          'version INTEGER DEFAULT 1',
          'in_trash INTEGER DEFAULT 0',
          'trash_moved_at INTEGER',
          'is_deleted INTEGER DEFAULT 0',
          'updated_at INTEGER',
          'created_at INTEGER',
        ],
        boolColumnIndex: 3);

    // Other tables: add in_trash + trash_moved_at
    for (final table in [
      'cabinets_table',
      'payments_table',
      'workers_table',
      'audit_log_table',
      'generator_settings_table',
    ]) {
      try {
        await customStatement(
            'ALTER TABLE $table ADD COLUMN in_trash INTEGER DEFAULT 0');
        await customStatement(
            'ALTER TABLE $table ADD COLUMN trash_moved_at INTEGER');
        await customStatement('UPDATE $table SET in_trash = is_deleted');
      } catch (e) {
        developer.log('Warning: Migration for $table: $e', name: 'AppDatabase');
      }
    }
  }

  /// Migration v6→v7: Remove ALL legacy sync metadata, add proper indexes,
  /// unify sync into a single SyncMetadataTable
  Future<void> _migrateV6toV7() async {
    // For each entity table, recreate WITHOUT legacy fields:
    // Remove: last_modified, last_synced_at, sync_status, dirty_flag, cloud_id,
    //         deleted_locally, permissions_mask, is_deleted
    // Keep: id, domain fields, owner_id, version, in_trash, trash_moved_at,
    //        updated_at, created_at

    final tableMigrations = {
      'subscribers_table': {
        'columns': [
          'id TEXT NOT NULL PRIMARY KEY',
          'name TEXT NOT NULL',
          'code TEXT NOT NULL',
          'cabinet TEXT NOT NULL',
          'phone TEXT NOT NULL',
          "status TEXT NOT NULL DEFAULT 'active'",
          'start_date INTEGER NOT NULL',
          'accumulated_debt REAL NOT NULL DEFAULT 0',
          'tags TEXT',
          'notes TEXT',
          'owner_id TEXT',
          'version INTEGER DEFAULT 1',
          'in_trash INTEGER DEFAULT 0',
          'trash_moved_at INTEGER',
          'updated_at INTEGER',
          'created_at INTEGER',
        ],
        // SELECT columns from old table (by position)
        // Old: id(0), name(1), code(2), cabinet(3), phone(4), status(5),
        //      start_date(6), accumulated_debt(7), tags(8), notes(9),
        //      last_modified(10), last_synced_at(11), sync_status(12),
        //      dirty_flag(13), cloud_id(14), deleted_locally(15),
        //      permissions_mask(16), owner_id(17), version(18),
        //      in_trash(19), trash_moved_at(20), is_deleted(21),
        //      updated_at(22), created_at(23)
        'select':
            'id, name, code, cabinet, phone, status, start_date, accumulated_debt, tags, notes, owner_id, version, in_trash, trash_moved_at, updated_at, created_at',
        'indexes': [
          'CREATE INDEX IF NOT EXISTS idx_subscribers_owner_intrash ON subscribers_table(owner_id, in_trash)',
          'CREATE INDEX IF NOT EXISTS idx_subscribers_owner_status ON subscribers_table(owner_id, status)',
          'CREATE INDEX IF NOT EXISTS idx_subscribers_owner_cabinet ON subscribers_table(owner_id, cabinet)',
        ],
      },
      'cabinets_table': {
        'columns': [
          'id TEXT NOT NULL PRIMARY KEY',
          'name TEXT NOT NULL',
          'letter TEXT NOT NULL DEFAULT ""',
          'total_subscribers INTEGER NOT NULL',
          'current_subscribers INTEGER NOT NULL',
          'collected_amount REAL NOT NULL DEFAULT 0',
          'delayed_subscribers INTEGER NOT NULL',
          'completion_date INTEGER',
          'owner_id TEXT',
          'version INTEGER DEFAULT 1',
          'in_trash INTEGER DEFAULT 0',
          'trash_moved_at INTEGER',
          'updated_at INTEGER',
          'created_at INTEGER',
        ],
        'select':
            'id, name, letter, total_subscribers, current_subscribers, collected_amount, delayed_subscribers, completion_date, owner_id, version, in_trash, trash_moved_at, updated_at, created_at',
        'indexes': [
          'CREATE INDEX IF NOT EXISTS idx_cabinets_owner_intrash ON cabinets_table(owner_id, in_trash)',
          'CREATE INDEX IF NOT EXISTS idx_cabinets_owner_name ON cabinets_table(owner_id, name)',
        ],
      },
      'payments_table': {
        'columns': [
          'id TEXT NOT NULL PRIMARY KEY',
          'subscriber_id TEXT NOT NULL',
          'amount REAL NOT NULL',
          'worker TEXT NOT NULL',
          'date INTEGER NOT NULL',
          'cabinet TEXT NOT NULL',
          'owner_id TEXT',
          'version INTEGER DEFAULT 1',
          'in_trash INTEGER DEFAULT 0',
          'trash_moved_at INTEGER',
          'updated_at INTEGER',
          'created_at INTEGER',
        ],
        'select':
            'id, subscriber_id, amount, worker, date, cabinet, owner_id, version, in_trash, trash_moved_at, updated_at, created_at',
        'indexes': [
          'CREATE INDEX IF NOT EXISTS idx_payments_owner_intrash ON payments_table(owner_id, in_trash)',
          'CREATE INDEX IF NOT EXISTS idx_payments_owner_subscriber ON payments_table(owner_id, subscriber_id)',
          'CREATE INDEX IF NOT EXISTS idx_payments_owner_worker ON payments_table(owner_id, worker)',
          'CREATE INDEX IF NOT EXISTS idx_payments_owner_date ON payments_table(owner_id, date)',
          'CREATE INDEX IF NOT EXISTS idx_payments_owner_cabinet ON payments_table(owner_id, cabinet)',
        ],
      },
      'workers_table': {
        'columns': [
          'id TEXT NOT NULL PRIMARY KEY',
          'name TEXT NOT NULL',
          'phone TEXT NOT NULL',
          'permissions TEXT NOT NULL DEFAULT "{}"',
          'today_collected REAL NOT NULL DEFAULT 0',
          'month_total REAL NOT NULL DEFAULT 0',
          'owner_id TEXT',
          'version INTEGER DEFAULT 1',
          'in_trash INTEGER DEFAULT 0',
          'trash_moved_at INTEGER',
          'updated_at INTEGER',
          'created_at INTEGER',
        ],
        'select':
            'id, name, phone, permissions, today_collected, month_total, owner_id, version, in_trash, trash_moved_at, updated_at, created_at',
        'indexes': [
          'CREATE INDEX IF NOT EXISTS idx_workers_owner_intrash ON workers_table(owner_id, in_trash)',
          'CREATE INDEX IF NOT EXISTS idx_workers_owner_name ON workers_table(owner_id, name)',
        ],
      },
      'audit_log_table': {
        'columns': [
          'id TEXT NOT NULL PRIMARY KEY',
          'user TEXT NOT NULL',
          'action TEXT NOT NULL',
          'target TEXT NOT NULL',
          'details TEXT NOT NULL',
          'type TEXT NOT NULL',
          'timestamp INTEGER NOT NULL',
          'owner_id TEXT',
          'version INTEGER DEFAULT 1',
          'in_trash INTEGER DEFAULT 0',
          'trash_moved_at INTEGER',
          'updated_at INTEGER',
          'created_at INTEGER',
        ],
        'select':
            'id, user, action, target, details, type, timestamp, owner_id, version, in_trash, trash_moved_at, updated_at, created_at',
        'indexes': [
          'CREATE INDEX IF NOT EXISTS idx_audit_owner_timestamp ON audit_log_table(owner_id, timestamp)',
          'CREATE INDEX IF NOT EXISTS idx_audit_owner_action ON audit_log_table(owner_id, action)',
        ],
      },
      'whatsapp_templates_table': {
        'columns': [
          'id TEXT NOT NULL PRIMARY KEY',
          'title TEXT NOT NULL',
          'content TEXT NOT NULL',
          'is_active INTEGER NOT NULL DEFAULT 0',
          'owner_id TEXT',
          'version INTEGER DEFAULT 1',
          'in_trash INTEGER DEFAULT 0',
          'trash_moved_at INTEGER',
          'updated_at INTEGER',
          'created_at INTEGER',
        ],
        'select':
            'id, title, content, is_active, owner_id, version, in_trash, trash_moved_at, updated_at, created_at',
        'indexes': [
          'CREATE INDEX IF NOT EXISTS idx_whatsapp_owner_active ON whatsapp_templates_table(owner_id, is_active)',
          'CREATE INDEX IF NOT EXISTS idx_whatsapp_owner_intrash ON whatsapp_templates_table(owner_id, in_trash)',
        ],
      },
      'generator_settings_table': {
        'columns': [
          'id TEXT NOT NULL PRIMARY KEY',
          'name TEXT NOT NULL',
          'phone_number TEXT NOT NULL',
          'address TEXT NOT NULL',
          'logo_path TEXT',
          'owner_id TEXT',
          'version INTEGER DEFAULT 1',
          'in_trash INTEGER DEFAULT 0',
          'trash_moved_at INTEGER',
          'updated_at INTEGER',
          'created_at INTEGER',
        ],
        'select':
            'id, name, phone_number, address, logo_path, owner_id, version, in_trash, trash_moved_at, updated_at, created_at',
        'indexes': [
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_generator_settings_owner ON generator_settings_table(owner_id)',
        ],
      },
    };

    for (final entry in tableMigrations.entries) {
      final tableName = entry.key;
      final columns = entry.value['columns'] as List<String>;
      final selectCols = entry.value['select'] as String;
      final indexes = entry.value['indexes'] as List<String>;

      final tempName = '${tableName}_v7';
      final colDefs = columns.join(',\n  ');

      try {
        // Create new table
        await customStatement('CREATE TABLE $tempName (\n  $colDefs\n)');

        // Copy data (only the columns that exist in both old and new)
        await customStatement(
            'INSERT INTO $tempName ($selectCols) SELECT $selectCols FROM $tableName');

        // Drop old table
        await customStatement('DROP TABLE IF EXISTS $tableName');

        // Rename new table
        await customStatement('ALTER TABLE $tempName RENAME TO $tableName');

        // Create indexes
        for (final indexSql in indexes) {
          await customStatement(indexSql);
        }

        developer.log('Migrated $tableName to v7', name: 'AppDatabase');
      } catch (e) {
        developer.log('Warning: Migration for $tableName failed: $e',
            name: 'AppDatabase');
      }
    }

    // Create SyncMetadataTable (replaces per-table sync fields)
    await customStatement('''
      CREATE TABLE IF NOT EXISTS sync_metadata_table (
        table_name TEXT NOT NULL PRIMARY KEY,
        last_sync_timestamp INTEGER NOT NULL DEFAULT 0,
        sync_cursor TEXT,
        last_sync_at INTEGER
      )
    ''');

    // Initialize sync metadata for all tables
    final tables = [
      'subscribers',
      'cabinets',
      'payments',
      'workers',
      'audit_log',
      'whatsapp_templates',
      'generator_settings',
    ];
    for (final table in tables) {
      await customStatement(
          "INSERT OR IGNORE INTO sync_metadata_table (table_name, last_sync_timestamp) VALUES ('$table', 0)");
    }

    // Add indexes to infrastructure tables
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_outbox_status_created ON outbox_table(status, created_at)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_events_status_created ON events_table(status, created_at)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_events_entity ON events_table(entity_type, entity_id)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_trash_owner_expires ON trash_table(owner_id, expires_at)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_trash_entity ON trash_table(entity_type, entity_id)');
  }

  /// Helper: recreate a table with status int→text conversion
  Future<void> _recreateTableWithStatusConversion(
    String tableName,
    List<String> columns, {
    required int statusColumnIndex,
  }) async {
    final tempName = '${tableName}_v6';
    final colDefs = columns.join(',\n  ');

    await customStatement('CREATE TABLE $tempName (\n  $colDefs\n)');
    await customStatement('INSERT INTO $tempName SELECT * FROM $tableName');

    // Convert status int → string
    await customStatement(
        "UPDATE $tempName SET status = 'inactive' WHERE status = '0' OR status = 0");
    await customStatement(
        "UPDATE $tempName SET status = 'active' WHERE status = '1' OR status = 1");
    await customStatement(
        "UPDATE $tempName SET status = 'suspended' WHERE status = '2' OR status = 2");
    await customStatement(
        "UPDATE $tempName SET status = 'disconnected' WHERE status = '3' OR status = 3");

    await customStatement('DROP TABLE $tableName');
    await customStatement('ALTER TABLE $tempName RENAME TO $tableName');
  }

  /// Helper: recreate a table with int→bool conversion
  Future<void> _recreateTableWithBoolConversion(
    String tableName,
    List<String> columns, {
    required int boolColumnIndex,
  }) async {
    final tempName = '${tableName}_v6';
    final colDefs = columns.join(',\n  ');

    await customStatement('CREATE TABLE $tempName (\n  $colDefs\n)');
    await customStatement('INSERT INTO $tempName SELECT * FROM $tableName');

    await customStatement('DROP TABLE $tableName');
    await customStatement('ALTER TABLE $tempName RENAME TO $tableName');
  }

  /// Runs a manual ALTER for column additions; rethrows unless SQLite reports duplicate column.
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

  /// Self-healing: fix any NULL values that might cause crashes
  Future<void> _sanitizeDatabase() async {
    try {
      await customStatement(
          "UPDATE cabinets_table SET name = 'Unknown' WHERE name IS NULL");
      await customStatement(
          "UPDATE cabinets_table SET letter = '' WHERE letter IS NULL");
      await customStatement(
          "UPDATE cabinets_table SET total_subscribers = 0 WHERE total_subscribers IS NULL");
      await customStatement(
          "UPDATE cabinets_table SET current_subscribers = 0 WHERE current_subscribers IS NULL");
      await customStatement(
          "UPDATE cabinets_table SET collected_amount = 0 WHERE collected_amount IS NULL");
      await customStatement(
          "UPDATE cabinets_table SET delayed_subscribers = 0 WHERE delayed_subscribers IS NULL");
    } catch (e) {
      developer.log('Warning: Failed to sanitize database: $e',
          name: 'AppDatabase');
    }
  }

  // ─── Data Pruning ───────────────────────────────────────────────

  /// Prune old audit logs (older than retentionDays)
  Future<int> pruneAuditLogs({int retentionDays = 90}) async {
    final cutoff = DateTime.now().subtract(Duration(days: retentionDays));
    final result = await (delete(auditLogTable)
          ..where((t) => t.timestamp.isSmallerThanValue(cutoff)))
        .go();
    if (result > 0) {
      developer.log('Pruned $result old audit log entries',
          name: 'AppDatabase');
    }
    return result;
  }

  /// Prune synced events older than retentionDays
  Future<int> pruneSyncedEvents({int retentionDays = 30}) async {
    final cutoff = DateTime.now().subtract(Duration(days: retentionDays));
    final result = await (delete(eventsTable)
          ..where((t) =>
              t.status.equals('synced') &
              t.createdAt.isSmallerThanValue(cutoff)))
        .go();
    if (result > 0) {
      developer.log('Pruned $result old synced events', name: 'AppDatabase');
    }
    return result;
  }

  /// Prune synced outbox entries older than retentionDays
  Future<int> pruneSyncedOutbox({int retentionDays = 7}) async {
    final cutoff = DateTime.now().subtract(Duration(days: retentionDays));
    final result = await (delete(outboxTable)
          ..where((t) =>
              t.status.equals('synced') &
              t.createdAt.isSmallerThanValue(cutoff)))
        .go();
    if (result > 0) {
      developer.log('Pruned $result old outbox entries', name: 'AppDatabase');
    }
    return result;
  }

  /// Prune expired trash items
  Future<int> pruneExpiredTrash() async {
    final now = DateTime.now();
    final result = await (delete(trashTable)
          ..where((t) => t.expiresAt.isSmallerThanValue(now)))
        .go();
    if (result > 0) {
      developer.log('Pruned $result expired trash items', name: 'AppDatabase');
    }
    return result;
  }

  /// Run all pruning operations
  Future<void> runPruning() async {
    await pruneAuditLogs();
    await pruneSyncedEvents();
    await pruneSyncedOutbox();
    await pruneExpiredTrash();
  }
}

// ============================================================
// SYNC METADATA TABLE — Centralized sync state (replaces per-table fields)
// ============================================================
@DataClassName('SyncMetadataEntry')
class SyncMetadataTable extends Table {
  TextColumn get entityTableName => text()(); // 'subscribers', 'cabinets', etc.
  IntColumn get lastSyncTimestamp => integer().withDefault(const Constant(0))();
  TextColumn get syncCursor => text().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {entityTableName};
}

// ============================================================
// OUTBOX TABLE — Offline write queue
// ============================================================
@DataClassName('OutboxEntry')
class OutboxTable extends Table {
  TextColumn get id => text()(); // UUID

  // Operation details
  TextColumn get targetTable => text()();
  TextColumn get operationType => text()(); // 'create', 'update', 'delete'
  TextColumn get documentId => text()();
  TextColumn get payload => text()(); // JSON

  // Status tracking
  TextColumn get status => text().withDefault(const Constant('pending'))();
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
// SUBSCRIBERS TABLE — Clean schema (no legacy fields)
// ============================================================
@DataClassName('Subscriber')
class SubscribersTable extends Table {
  TextColumn get id => text()(); // UUID primary key
  TextColumn get name => text()();
  TextColumn get code => text()();
  TextColumn get cabinet => text()(); // Cabinet UUID reference
  TextColumn get phone => text()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get startDate => dateTime()();
  RealColumn get accumulatedDebt => real().withDefault(const Constant(0))();
  TextColumn get tags => text().nullable()(); // JSON array of strings
  TextColumn get notes => text().nullable()();

  // Sync metadata (only what's needed)
  TextColumn get ownerId => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get inTrash => boolean().withDefault(const Constant(false))();
  DateTimeColumn get trashMovedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// CABINETS TABLE — Clean schema
// ============================================================
@DataClassName('Cabinet')
class CabinetsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get letter => text().withDefault(const Constant(''))();
  IntColumn get totalSubscribers => integer()();
  IntColumn get currentSubscribers => integer()();
  RealColumn get collectedAmount => real().withDefault(const Constant(0))();
  IntColumn get delayedSubscribers => integer()();
  DateTimeColumn get completionDate => dateTime().nullable()();

  TextColumn get ownerId => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get inTrash => boolean().withDefault(const Constant(false))();
  DateTimeColumn get trashMovedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// PAYMENTS TABLE — Clean schema
// ============================================================
@DataClassName('Payment')
class PaymentsTable extends Table {
  TextColumn get id => text()();
  TextColumn get subscriberId => text()(); // Subscriber UUID
  RealColumn get amount => real()();
  TextColumn get worker => text()(); // Worker UUID
  DateTimeColumn get date => dateTime()();
  TextColumn get cabinet => text()(); // Cabinet UUID

  TextColumn get ownerId => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get inTrash => boolean().withDefault(const Constant(false))();
  DateTimeColumn get trashMovedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// WORKERS TABLE — Clean schema
// ============================================================
@DataClassName('Worker')
class WorkersTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get permissions =>
      text().withDefault(const Constant('{}'))(); // JSON
  RealColumn get todayCollected => real().withDefault(const Constant(0))();
  RealColumn get monthTotal => real().withDefault(const Constant(0))();

  TextColumn get ownerId => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get inTrash => boolean().withDefault(const Constant(false))();
  DateTimeColumn get trashMovedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// AUDIT LOG TABLE — Clean schema
// ============================================================
@DataClassName('AuditLogEntry')
class AuditLogTable extends Table {
  TextColumn get id => text()();
  TextColumn get user => text()();
  TextColumn get action => text()();
  TextColumn get target => text()();
  TextColumn get details => text()();
  TextColumn get type => text()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();

  TextColumn get ownerId => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get inTrash => boolean().withDefault(const Constant(false))();
  DateTimeColumn get trashMovedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// GENERATOR SETTINGS TABLE — Per-tenant singleton
// ============================================================
@DataClassName('GeneratorSettingsData')
class GeneratorSettingsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phoneNumber => text()();
  TextColumn get address => text()();
  TextColumn get logoPath => text().nullable()();

  TextColumn get ownerId => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get inTrash => boolean().withDefault(const Constant(false))();
  DateTimeColumn get trashMovedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// EVENTS TABLE — Event-sourced sync
// ============================================================
@DataClassName('EventEntry')
class EventsTable extends Table {
  TextColumn get id => text()();
  TextColumn get eventType => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get payload => text()(); // JSON
  IntColumn get version => integer()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// WHATSAPP TEMPLATES TABLE — Clean schema
// ============================================================
@DataClassName('WhatsappTemplateData')
class WhatsappTemplatesTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();

  TextColumn get ownerId => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get inTrash => boolean().withDefault(const Constant(false))();
  DateTimeColumn get trashMovedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// TRASH TABLE — Soft-deleted items
// ============================================================
@DataClassName('TrashItem')
class TrashTable extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get entityData => text()(); // JSON snapshot
  TextColumn get ownerId => text()();
  DateTimeColumn get deletedAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
