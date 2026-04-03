import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/convex/convex_config.dart';
import 'package:mawlid_al_dhaki/core/auth/auth0_service.dart';
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
    // Allow sync if authenticated
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

      // Sync each table type using new query names
      await _syncTable('subscribers', lastSync, _applySubscriberChanges);
      await _syncTable('cabinets', lastSync, _applyCabinetChanges);
      await _syncTable('payments', lastSync, _applyPaymentChanges);
      await _syncTable('workers', lastSync, _applyWorkerChanges);

      // Detect hard-deletions from Convex dashboard
      // Items that exist locally but not in cloud should be marked deleted
      await _detectHardDeletions('subscribers', _getLocalSubscriberIds,
          _markSubscriberDeleted);
      await _detectHardDeletions('cabinets', _getLocalCabinetIds,
          _markCabinetDeleted);
      await _detectHardDeletions('payments', _getLocalPaymentIds,
          _markPaymentDeleted);
      await _detectHardDeletions('workers', _getLocalWorkerIds,
          _markWorkerDeleted);

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
      final queryMappings = {
        'subscribers': 'queries/subscribers:getSubscribersModifiedSince',
        'cabinets': 'queries/cabinets:getCabinetsModifiedSince',
        'payments': 'queries/payments:getPaymentsModifiedSince',
        'workers': 'queries/workers:getWorkersModifiedSince',
        'auditLog': 'queries/auditLog:getAuditLogsModifiedSince',
        'whatsappTemplates':
            'queries/whatsappTemplates:getWhatsappTemplatesModifiedSince',
        'generatorSettings':
            'queries/generatorSettings:getGeneratorSettingsModifiedSince',
      };

      final queryName = queryMappings[tableName];
      if (queryName == null) {
        debugPrint('[DownSync] No query mapping for table: $tableName');
        return;
      }

      debugPrint(
          '[DownSync] Calling query: $queryName (ownerId: ${_getCurrentOwnerId()}, since: $sinceTimestamp)');

      final result = await AppConvexConfig.query(queryName, {
        'ownerId': _getCurrentOwnerId(),
        'since': sinceTimestamp,
      });

      debugPrint(
          '[DownSync] Query $tableName result type: ${result.runtimeType}, value: $result');

      if (result is List && result.isNotEmpty) {
        final changes = result.cast<Map<String, dynamic>>();
        debugPrint(
            '[DownSync] Processing ${changes.length} changes for $tableName');
        for (final change in changes) {
          debugPrint(
              '[DownSync]   - ${change['id']}: isDeleted=${change['isDeleted']}');
        }
        await applyChanges(changes);
        debugPrint('[DownSync] Synced ${changes.length} $tableName');
      } else {
        debugPrint('[DownSync] No changes for $tableName (result: $result)');
      }
    } catch (e, st) {
      debugPrint('[DownSync] Error syncing $tableName: $e');
      debugPrint('[DownSync] Stack: $st');
    }
  }

  /// Get current owner ID from Auth0 user
  /// Uses centralized method from Auth0Service for consistency
  String _getCurrentOwnerId() {
    final auth = Auth0Service.instance;
    final userId = auth.userId;
    if (userId != null && userId.isNotEmpty) {
      debugPrint('[ConvexDownSyncService] Using userId: $userId');
      return userId;
    }
    // Fallback for demo mode - MUST match _getCurrentOwnerId in ConvexSyncProcessor
    return 'demo-user';
  }

  /// Apply subscriber changes to local database
  Future<void> _applySubscriberChanges(
      List<Map<String, dynamic>> changes) async {
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
      final isDeleted = change['isDeleted'] as bool? ?? false;
      final incomingVersion = change['version'] as int? ?? 0;

      // Try to find existing by cloudId first, then by id
      var existing = await (database.select(database.cabinetsTable)
            ..where((t) => t.id.equals(change['id'] as String)))
          .getSingleOrNull();

      final existingVersion = existing?.version ?? 0;

      if (incomingVersion > existingVersion) {
        // If incoming is deleted, mark local as deleted instead of full update
        if (isDeleted) {
          if (existing != null) {
            await (database.update(database.cabinetsTable)
                  ..where((t) => t.id.equals(change['id'] as String)))
                .write(CabinetsTableCompanion(
              isDeleted: const Value(true),
              version: Value(incomingVersion),
              updatedAt: Value(now),
            ));
            debugPrint('[DownSync] Soft deleted cabinet: ${change['id']}');
          }
          // Skip further processing for deleted items
          continue;
        }

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
              ? DateTime.fromMillisecondsSinceEpoch(
                  change['completionDate'] as int)
              : null),
          version: Value(incomingVersion),
          isDeleted: Value(isDeleted),
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
    // Handle special cases with proper capitalization
    final singularMappings = {
      'cabinets': 'Cabinet',
      'subscribers': 'Subscriber',
      'payments': 'Payment',
      'workers': 'Worker',
      'auditLog': 'AuditLog',
      'whatsappTemplates': 'WhatsappTemplate',
      'generatorSettings': 'GeneratorSetting',
    };
    return singularMappings[table] ?? table;
  }

  // ==================== Hard Deletion Detection ====================
  // These methods detect items that were hard-deleted in Convex dashboard
  // and mark them as deleted locally so they disappear from the UI

  /// Fetch all active (non-deleted) items from cloud for a table
  Future<Set<String>> _getCloudItemIds(String tableName) async {
    final queryMappings = {
      'subscribers': 'queries/subscribers:getActiveSubscribers',
      'cabinets': 'queries/cabinets:getActiveCabinets',
      'payments': 'queries/payments:getActivePayments',
      'workers': 'queries/workers:getActiveWorkers',
    };

    final queryName = queryMappings[tableName];
    if (queryName == null) {
      debugPrint('[DownSync] No query mapping for cloud items: $tableName');
      return {};
    }

    try {
      debugPrint('[DownSync] Fetching cloud items for $tableName');
      final result = await AppConvexConfig.query(queryName, {
        'ownerId': _getCurrentOwnerId(),
      });

      if (result is List) {
        // Convex documents have 'cloudId' which maps to local 'id'
        // Fall back to _id if cloudId is not set
        final ids = result
            .cast<Map<String, dynamic>>()
            .map((item) {
              final cloudId = item['cloudId'] as String?;
              final id = item['id'] as String?;
              // Prefer cloudId (client's local UUID), fall back to id field
              return cloudId ?? id ?? '';
            })
            .where((id) => id.isNotEmpty)
            .toSet();
        debugPrint('[DownSync] Found ${ids.length} cloud items for $tableName');
        return ids;
      }
    } catch (e) {
      debugPrint('[DownSync] Error fetching cloud items for $tableName: $e');
    }
    return {};
  }

  /// Detect items that exist locally but not in cloud (hard-deleted in dashboard)
  Future<void> _detectHardDeletions(
    String tableName,
    Future<Set<String>> Function() getLocalIds,
    Future<void> Function(String id) markDeleted,
  ) async {
    try {
      final cloudIds = await _getCloudItemIds(tableName);
      final localIds = await getLocalIds();

      // Items in local but not in cloud = hard-deleted in dashboard
      final hardDeleted = localIds.difference(cloudIds);

      if (hardDeleted.isNotEmpty) {
        debugPrint(
            '[DownSync] Detected ${hardDeleted.length} hard-deleted items in $tableName');
        for (final id in hardDeleted) {
          await markDeleted(id);
        }
      }
    } catch (e) {
      debugPrint('[DownSync] Error detecting hard deletions for $tableName: $e');
    }
  }

  // --- Local ID fetchers ---

  Future<Set<String>> _getLocalSubscriberIds() async {
    final rows = await (database.select(database.subscribersTable)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    return rows.map((r) => r.id).toSet();
  }

  Future<Set<String>> _getLocalCabinetIds() async {
    final rows = await (database.select(database.cabinetsTable)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    return rows.map((r) => r.id).toSet();
  }

  Future<Set<String>> _getLocalPaymentIds() async {
    final rows = await (database.select(database.paymentsTable)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    return rows.map((r) => r.id).toSet();
  }

  Future<Set<String>> _getLocalWorkerIds() async {
    final rows = await (database.select(database.workersTable)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    return rows.map((r) => r.id).toSet();
  }

  // --- Mark as deleted ---

  Future<void> _markSubscriberDeleted(String id) async {
    final now = DateTime.now();
    await (database.update(database.subscribersTable)..where((t) => t.id.equals(id))).write(
      SubscribersTableCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ),
    );
    debugPrint('[DownSync] Marked subscriber $id as deleted');
  }

  Future<void> _markCabinetDeleted(String id) async {
    final now = DateTime.now();
    await (database.update(database.cabinetsTable)..where((t) => t.id.equals(id))).write(
      CabinetsTableCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ),
    );
    debugPrint('[DownSync] Marked cabinet $id as deleted');
  }

  Future<void> _markPaymentDeleted(String id) async {
    final now = DateTime.now();
    await (database.update(database.paymentsTable)..where((t) => t.id.equals(id))).write(
      PaymentsTableCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ),
    );
    debugPrint('[DownSync] Marked payment $id as deleted');
  }

  Future<void> _markWorkerDeleted(String id) async {
    final now = DateTime.now();
    await (database.update(database.workersTable)..where((t) => t.id.equals(id))).write(
      WorkersTableCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ),
    );
    debugPrint('[DownSync] Marked worker $id as deleted');
  }
}
