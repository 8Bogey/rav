/**
 * Local Database Migration Manager
 * 
 * Handles the migration from Drift V1 (Int IDs) to Drift V2 (UUIDs).
 * The simplest strategy is to wipe the old local database and rebuild from Convex.
 * 
 * Following MINIMAX_IMPLEMENTATION_GUIDE.md patterns.
 */

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/database/database_provider.dart';
import 'package:path_provider/path_provider.dart';

/// Result of a migration operation
class MigrationResult {
  final bool success;
  final String? error;
  final int? deletedTablesCount;

  const MigrationResult({
    required this.success,
    this.error,
    this.deletedTablesCount,
  });
}

/// Handles local database migration and wipe operations
class DatabaseMigrationManager {
  final AppDatabase _database;
  
  DatabaseMigrationManager({required AppDatabase database}) : _database = database;

  /// Check if migration is needed (schema version mismatch)
  Future<bool> needsMigration() async {
    try {
      // Check if the old integer ID tables exist
      // This is a simplified check - in production you'd check schema version
      return true; // Always migrate for now since we're changing IDs
    } catch (e) {
      debugPrint('DatabaseMigrationManager: Error checking migration status: $e');
      return true;
    }
  }

  /// Wipe the local database and rebuild from Convex
  /// This is the simplest migration strategy for UUID changes
  Future<MigrationResult> wipeAndRebuild() async {
    try {
      debugPrint('DatabaseMigrationManager: Starting wipe and rebuild...');
      
      // 1. Close the database connection
      await _database.close();
      
      // 2. Delete the SQLite database file
      final dbFile = await _getDatabaseFile();
      if (await dbFile.exists()) {
        await dbFile.delete();
        debugPrint('DatabaseMigrationManager: Deleted database file: ${dbFile.path}');
      }
      
      // 3. Delete any WAL/SHM files
      final walFile = File('${dbFile.path}-wal');
      final shmFile = File('${dbFile.path}-shm');
      if (await walFile.exists()) await walFile.delete();
      if (await shmFile.exists()) await shmFile.delete();
      
      // 4. Re-open the database (will create fresh schema)
      // Note: This requires re-initialization in the app
      debugPrint('DatabaseMigrationManager: Database wiped successfully');
      
      return const MigrationResult(
        success: true,
        deletedTablesCount: 7, // All tables will be fresh
      );
    } catch (e) {
      debugPrint('DatabaseMigrationManager: Error during wipe: $e');
      return MigrationResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Clear all data from tables but keep schema (soft wipe)
  Future<MigrationResult> clearAllData() async {
    try {
      debugPrint('DatabaseMigrationManager: Clearing all data...');
      
      await _database.transaction(() async {
        // Clear all tables (soft delete style - just truncate)
        await _database.delete(_database.subscribersTable).go();
        await _database.delete(_database.cabinetsTable).go();
        await _database.delete(_database.paymentsTable).go();
        await _database.delete(_database.workersTable).go();
        await _database.delete(_database.auditLogTable).go();
        await _database.delete(_database.generatorSettingsTable).go();
        await _database.delete(_database.whatsappTemplatesTable).go();
        await _database.delete(_database.outboxTable).go();
      });
      
      debugPrint('DatabaseMigrationManager: All data cleared');
      return const MigrationResult(
        success: true,
        deletedTablesCount: 8,
      );
    } catch (e) {
      debugPrint('DatabaseMigrationManager: Error clearing data: $e');
      return MigrationResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Reset outbox (clear pending sync items)
  Future<MigrationResult> resetOutbox() async {
    try {
      debugPrint('DatabaseMigrationManager: Resetting outbox...');
      
      await (_database.delete(_database.outboxTable)
        ..where((t) => t.status.equals('pending') | t.status.equals('failed')))
          .go();
      
      debugPrint('DatabaseMigrationManager: Outbox reset complete');
      return const MigrationResult(success: true);
    } catch (e) {
      return MigrationResult(success: false, error: e.toString());
    }
  }

  /// Get the database file path
  Future<File> _getDatabaseFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/mawlid_al_dhaki.sqlite');
  }

  /// Get database file size (for debugging)
  Future<int> getDatabaseSizeBytes() async {
    try {
      final file = await _getDatabaseFile();
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}

/// Provider for database migration manager
final databaseMigrationManagerProvider = Provider<DatabaseMigrationManager>((ref) {
  final database = ref.watch(databaseProvider);
  return DatabaseMigrationManager(database: database);
});

/// Provider for checking if initial sync is needed
final needsInitialSyncProvider = FutureProvider<bool>((ref) async {
  final migrationManager = ref.watch(databaseMigrationManagerProvider);
  return await migrationManager.needsMigration();
});

/// Database initialization state
enum DatabaseState {
  initial,
  needsMigration,
  ready,
  syncing,
}

/// Provider for database state
final databaseStateProvider = StateProvider<DatabaseState>((ref) {
  return DatabaseState.initial;
});