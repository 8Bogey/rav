import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/convex/convex_config.dart';
import 'package:mawlid_al_dhaki/features/auth/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for pulling changes from Convex Cloud to local Drift database.
/// Implements cloud-to-local sync (down-sync) for Local-First architecture.
class ConvexDownSyncService {
  final AppDatabase database;
  static const String _lastSyncKey = 'convex_last_sync_timestamp';

  ConvexDownSyncService(this.database);

  /// Get last sync timestamp from SharedPreferences
  Future<int> _getLastSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastSyncKey) ?? 0;
  }

  /// Save last sync timestamp
  Future<void> _setLastSyncTimestamp(int timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncKey, timestamp);
  }

  /// Check if sync can proceed
  bool get _canSync {
    if (!AppConvexConfig.isInitialized) return false;
    // In demo mode, allow sync
    if (kDemoAuthLogin) return true;
    return AppConvexConfig.isAuthenticated;
  }

  /// Sync all tables from Convex to local database
  Future<void> syncFromCloud() async {
    if (!_canSync) {
      debugPrint('ConvexDownSyncService: Skipping - not initialized');
      return;
    }

    try {
      final lastSync = await _getLastSyncTimestamp();
      final now = DateTime.now().millisecondsSinceEpoch;

      debugPrint('ConvexDownSyncService: Starting down-sync from $lastSync');

      // Sync each table type
      await _syncTable('subscribers', lastSync, _applySubscriberChanges);
      await _syncTable('cabinets', lastSync, _applyCabinetChanges);
      await _syncTable('payments', lastSync, _applyPaymentChanges);
      await _syncTable('workers', lastSync, _applyWorkerChanges);

      // Update last sync timestamp
      await _setLastSyncTimestamp(now);
      debugPrint('ConvexDownSyncService: Down-sync completed');
    } catch (e) {
      debugPrint('ConvexDownSyncService Error: $e');
    }
  }

  /// Sync a specific table from Convex
  Future<void> _syncTable(
    String tableName,
    int sinceTimestamp,
    Future<void> Function(List<Map<String, dynamic>>) applyChanges,
  ) async {
    try {
      // Query Convex for changes since last sync
      final queryName = 'get${_toSingular(tableName)}sModifiedSince';
      final result = await AppConvexConfig.query(queryName, {
        'since': sinceTimestamp,
      });

      if (result is List && result.isNotEmpty) {
        final changes = result.cast<Map<String, dynamic>>();
        await applyChanges(changes);
        debugPrint('ConvexDownSyncService: Synced ${changes.length} $tableName');
      }
    } catch (e) {
      debugPrint('ConvexDownSyncService: Error syncing $tableName: $e');
    }
  }

  /// Apply subscriber changes to local database
  Future<void> _applySubscriberChanges(List<Map<String, dynamic>> changes) async {
    final now = DateTime.now();
    for (final change in changes) {
      // LWW: Only apply if incoming version is newer
      final existing = await (database.select(database.subscribersTable)
            ..where((t) => t.id.equals(change['id'] as String)))
          .getSingleOrNull();

      final incomingVersion = change['version'] as int? ?? 0;
      final existingVersion = existing?.version ?? 0;

      if (incomingVersion > existingVersion) {
        final companion = SubscribersTableCompanion(
          id: Value(change['id'] as String),
          ownerId: Value(change['ownerId'] as String? ?? ''),
          name: Value(change['name'] as String? ?? ''),
          code: Value(change['code'] as String? ?? ''),
          cabinet: Value(change['cabinet'] as String? ?? ''),
          phone: Value(change['phone'] as String? ?? ''),
          status: Value(change['status'] as int? ?? 1),
          startDate: Value(change['startDate'] != null
              ? DateTime.fromMillisecondsSinceEpoch(change['startDate'] as int)
              : now),
          accumulatedDebt: Value(change['accumulatedDebt'] as double? ?? 0),
          tags: Value(change['tags'] as String?),
          notes: Value(change['notes'] as String?),
          version: Value(incomingVersion),
          isDeleted: Value(change['isDeleted'] as bool? ?? false),
          updatedAt: Value(change['updatedAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(change['updatedAt'] as int)
              : now),
          createdAt: Value(change['createdAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(change['createdAt'] as int)
              : now),
        );

        if (existing != null) {
          await (database.update(database.subscribersTable)
                ..where((t) => t.id.equals(change['id'] as String)))
              .write(companion);
        } else {
          await database.into(database.subscribersTable).insert(companion);
        }
      }
    }
  }

  /// Apply cabinet changes to local database
  Future<void> _applyCabinetChanges(List<Map<String, dynamic>> changes) async {
    final now = DateTime.now();
    for (final change in changes) {
      final existing = await (database.select(database.cabinetsTable)
            ..where((t) => t.id.equals(change['id'] as String)))
          .getSingleOrNull();

      final incomingVersion = change['version'] as int? ?? 0;
      final existingVersion = existing?.version ?? 0;

      if (incomingVersion > existingVersion) {
        final companion = CabinetsTableCompanion(
          id: Value(change['id'] as String),
          ownerId: Value(change['ownerId'] as String? ?? ''),
          name: Value(change['name'] as String? ?? ''),
          letter: Value(change['letter'] as String? ?? ''),
          totalSubscribers: Value(change['totalSubscribers'] as int? ?? 0),
          currentSubscribers: Value(change['currentSubscribers'] as int? ?? 0),
          collectedAmount: Value(change['collectedAmount'] as double? ?? 0),
          delayedSubscribers: Value(change['delayedSubscribers'] as int? ?? 0),
          completionDate: Value(change['completionDate'] != null
              ? DateTime.fromMillisecondsSinceEpoch(change['completionDate'] as int)
              : null),
          version: Value(incomingVersion),
          isDeleted: Value(change['isDeleted'] as bool? ?? false),
          updatedAt: Value(change['updatedAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(change['updatedAt'] as int)
              : now),
          createdAt: Value(change['createdAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(change['createdAt'] as int)
              : now),
        );

        if (existing != null) {
          await (database.update(database.cabinetsTable)
                ..where((t) => t.id.equals(change['id'] as String)))
              .write(companion);
        } else {
          await database.into(database.cabinetsTable).insert(companion);
        }
      }
    }
  }

  /// Apply payment changes to local database
  Future<void> _applyPaymentChanges(List<Map<String, dynamic>> changes) async {
    final now = DateTime.now();
    for (final change in changes) {
      final existing = await (database.select(database.paymentsTable)
            ..where((t) => t.id.equals(change['id'] as String)))
          .getSingleOrNull();

      final incomingVersion = change['version'] as int? ?? 0;
      final existingVersion = existing?.version ?? 0;

      if (incomingVersion > existingVersion) {
        final companion = PaymentsTableCompanion(
          id: Value(change['id'] as String),
          ownerId: Value(change['ownerId'] as String? ?? ''),
          subscriberId: Value(change['subscriberId'] as String? ?? ''),
          amount: Value(change['amount'] as double? ?? 0),
          worker: Value(change['worker'] as String? ?? ''),
          date: Value(change['date'] != null
              ? DateTime.fromMillisecondsSinceEpoch(change['date'] as int)
              : now),
          cabinet: Value(change['cabinet'] as String? ?? ''),
          version: Value(incomingVersion),
          isDeleted: Value(change['isDeleted'] as bool? ?? false),
          updatedAt: Value(change['updatedAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(change['updatedAt'] as int)
              : now),
          createdAt: Value(change['createdAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(change['createdAt'] as int)
              : now),
        );

        if (existing != null) {
          await (database.update(database.paymentsTable)
                ..where((t) => t.id.equals(change['id'] as String)))
              .write(companion);
        } else {
          await database.into(database.paymentsTable).insert(companion);
        }
      }
    }
  }

  /// Apply worker changes to local database
  Future<void> _applyWorkerChanges(List<Map<String, dynamic>> changes) async {
    final now = DateTime.now();
    for (final change in changes) {
      final existing = await (database.select(database.workersTable)
            ..where((t) => t.id.equals(change['id'] as String)))
          .getSingleOrNull();

      final incomingVersion = change['version'] as int? ?? 0;
      final existingVersion = existing?.version ?? 0;

      if (incomingVersion > existingVersion) {
        final companion = WorkersTableCompanion(
          id: Value(change['id'] as String),
          ownerId: Value(change['ownerId'] as String? ?? ''),
          name: Value(change['name'] as String? ?? ''),
          phone: Value(change['phone'] as String? ?? ''),
          permissions: Value(change['permissions'] as String? ?? '{}'),
          todayCollected: Value(change['todayCollected'] as double? ?? 0),
          monthTotal: Value(change['monthTotal'] as double? ?? 0),
          version: Value(incomingVersion),
          isDeleted: Value(change['isDeleted'] as bool? ?? false),
          updatedAt: Value(change['updatedAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(change['updatedAt'] as int)
              : now),
          createdAt: Value(change['createdAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(change['createdAt'] as int)
              : now),
        );

        if (existing != null) {
          await (database.update(database.workersTable)
                ..where((t) => t.id.equals(change['id'] as String)))
              .write(companion);
        } else {
          await database.into(database.workersTable).insert(companion);
        }
      }
    }
  }

  String _toSingular(String table) {
    if (table.endsWith('s')) {
      return table[0].toUpperCase() + table.substring(1, table.length - 1);
    }
    return table[0].toUpperCase() + table.substring(1);
  }
}