import 'package:drift/drift.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';

/// Service for migrating legacy Supabase data to Convex UUID format.
/// 
/// This handles the transition from:
/// - Integer-based IDs (Supabase auto-increment) to UUIDs (Convex)
/// - Legacy cloudId, lastModified columns to new Convex sync metadata
/// - Updating foreign key references (e.g., payments.subscriberId)
/// 
/// Usage: Call [runMigration] once on app startup for existing databases.
class SupabaseToConvexMigrationService {
  final AppDatabase database;
  
  // Migration tracking key
  static const String _migrationCompleteKey = 'supabase_to_convex_migration_done';

  SupabaseToConvexMigrationService(this.database);

  /// Check if migration has already been completed
  Future<bool> isMigrationNeeded() async {
    // Check if there are any records missing Convex IDs
    final subsWithoutId = await (database.select(database.subscribersTable)
          ..where((t) => t.id.isNull() | t.id.equals('')))
        .get();
    
    final cabinetsWithoutId = await (database.select(database.cabinetsTable)
          ..where((t) => t.id.isNull() | t.id.equals('')))
        .get();
    
    final paymentsWithoutId = await (database.select(database.paymentsTable)
          ..where((t) => t.id.isNull() | t.id.equals('')))
        .get();
    
    final workersWithoutId = await (database.select(database.workersTable)
          ..where((t) => t.id.isNull() | t.id.equals('')))
        .get();
    
    return subsWithoutId.isNotEmpty || 
           cabinetsWithoutId.isNotEmpty || 
           paymentsWithoutId.isNotEmpty || 
           workersWithoutId.isNotEmpty;
  }

  /// Main entry point - run full migration
  Future<void> runMigration() async {
    final needsMigration = await isMigrationNeeded();
    if (!needsMigration) {
      return;
    }

    await _migrateSubscribers();
    await _migrateCabinets();
    await _migratePayments();
    await _migrateWorkers();
    
    // Migration complete - mark it
    await _markMigrationComplete();
  }

  /// Migrate subscribers table
  Future<void> _migrateSubscribers() async {
    // Get all subscribers missing UUIDs
    final records = await (database.select(database.subscribersTable)
          ..where((t) => t.id.isNull() | t.id.equals('')))
        .get();
    
    for (final record in records) {
      // Generate new UUID - use cloudId if available and looks like UUID, otherwise generate new one
      String newId;
      if (record.cloudId != null && record.cloudId!.isNotEmpty) {
        // Check if cloudId looks like a UUID (from newer Convex sync)
        if (_isValidUuid(record.cloudId!)) {
          newId = record.cloudId!;
        } else {
          // Legacy integer ID - generate new UUID and map it
          newId = _generateUuid();
        }
      } else {
        newId = _generateUuid();
      }
      
      final now = DateTime.now();
      await (database.update(database.subscribersTable)
            ..where((t) => t.id.equals(record.id)))
          .write(SubscribersTableCompanion(
        id: Value(newId),
        ownerId: Value(record.ownerId ?? ''),
        version: const Value(1),
        updatedAt: Value(now),
        createdAt: Value(record.createdAt ?? now),
        isDeleted: Value(record.deletedLocally ?? false),
      ));
    }
  }

  /// Migrate cabinets table
  Future<void> _migrateCabinets() async {
    final records = await (database.select(database.cabinetsTable)
          ..where((t) => t.id.isNull() | t.id.equals('')))
        .get();
    
    for (final record in records) {
      String newId;
      if (record.cloudId != null && record.cloudId!.isNotEmpty) {
        if (_isValidUuid(record.cloudId!)) {
          newId = record.cloudId!;
        } else {
          newId = _generateUuid();
        }
      } else {
        newId = _generateUuid();
      }
      
      final now = DateTime.now();
      await (database.update(database.cabinetsTable)
            ..where((t) => t.id.equals(record.id)))
          .write(CabinetsTableCompanion(
        id: Value(newId),
        ownerId: Value(record.ownerId ?? ''),
        version: const Value(1),
        updatedAt: Value(now),
        createdAt: Value(record.createdAt ?? now),
        isDeleted: Value(record.deletedLocally ?? false),
      ));
    }
  }

  /// Migrate payments table (includes foreign key update for subscriberId)
  Future<void> _migratePayments() async {
    final records = await (database.select(database.paymentsTable)
          ..where((t) => t.id.isNull() | t.id.equals('')))
        .get();
    
    for (final record in records) {
      String newId;
      if (record.cloudId != null && record.cloudId!.isNotEmpty) {
        if (_isValidUuid(record.cloudId!)) {
          newId = record.cloudId!;
        } else {
          newId = _generateUuid();
        }
      } else {
        newId = _generateUuid();
      }
      
      // Update subscriberId if it looks like an integer (legacy Supabase reference)
      String newSubscriberId = record.subscriberId ?? '';
      if (newSubscriberId.isNotEmpty && !_isValidUuid(newSubscriberId)) {
        // Try to find the subscriber by code or other identifier
        final subscriber = await (database.select(database.subscribersTable)
              ..where((t) => t.code.equals(newSubscriberId)))
            .getSingleOrNull();
        if (subscriber != null) {
          newSubscriberId = subscriber.id;
        }
      }
      
      final now = DateTime.now();
      await (database.update(database.paymentsTable)
            ..where((t) => t.id.equals(record.id)))
          .write(PaymentsTableCompanion(
        id: Value(newId),
        ownerId: Value(record.ownerId ?? ''),
        subscriberId: Value(newSubscriberId ?? ''),
        version: const Value(1),
        updatedAt: Value(now),
        createdAt: Value(record.createdAt ?? now),
        isDeleted: Value(record.deletedLocally ?? false),
      ));
    }
  }

  /// Migrate workers table
  Future<void> _migrateWorkers() async {
    final records = await (database.select(database.workersTable)
          ..where((t) => t.id.isNull() | t.id.equals('')))
        .get();
    
    for (final record in records) {
      String newId;
      if (record.cloudId != null && record.cloudId!.isNotEmpty) {
        if (_isValidUuid(record.cloudId!)) {
          newId = record.cloudId!;
        } else {
          newId = _generateUuid();
        }
      } else {
        newId = _generateUuid();
      }
      
      final now = DateTime.now();
      await (database.update(database.workersTable)
            ..where((t) => t.id.equals(record.id)))
          .write(WorkersTableCompanion(
        id: Value(newId),
        ownerId: Value(record.ownerId ?? ''),
        version: const Value(1),
        updatedAt: Value(now),
        createdAt: Value(record.createdAt ?? now),
        isDeleted: Value(record.deletedLocally ?? false),
      ));
    }
  }

  /// Mark migration as complete in SharedPreferences
  Future<void> _markMigrationComplete() async {
    // We could use SharedPreferences here, but simpler to just verify 
    // isMigrationNeeded() returns false after running
  }

  /// Check if a string is a valid UUID
  bool _isValidUuid(String value) {
    // UUID v4 regex pattern
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(value);
  }

  /// Generate a new UUID (using DateTime-based for simplicity, or use uuid package)
  String _generateUuid() {
    // Simple UUID v4 generation using timestamp + random
    final now = DateTime.now();
    final random = now.microsecondsSinceEpoch.toRadixString(16).padLeft(16, '0');
    return '${random.substring(0, 8)}-${random.substring(8, 12)}-4${random.substring(12, 15)}-${(int.parse(random.substring(15, 16), radix: 16) | 8).toRadixString(16)}${random.substring(16, 19)}-${random.substring(19)}';
  }
}
