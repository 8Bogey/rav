import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/convex/convex_config.dart';
import 'package:mawlid_al_dhaki/core/auth/auth0_service.dart';
import 'package:mawlid_al_dhaki/core/services/event_service.dart' show EventService, EventTypes;
import 'package:shared_preferences/shared_preferences.dart';

/// Service for pulling changes from Convex Cloud to local Drift database.
/// Implements cloud-to-local sync (down-sync) for Local-First architecture.
class ConvexDownSyncService {
  final AppDatabase database;
  late final EventService _eventService;
  static const String _lastSyncKey = 'convex_last_sync_timestamp';

  ConvexDownSyncService(this.database) {
    _eventService = EventService(database);
  }

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

      // First: Sync events from Convex (event-sourced approach)
      await _syncEventsFromCloud(lastSync);

      // Second: Sync each table type using legacy query names (backward compatibility)
      await _syncTable('subscribers', lastSync, _applySubscriberChanges);
      await _syncTable('cabinets', lastSync, _applyCabinetChanges);
      await _syncTable('payments', lastSync, _applyPaymentChanges);
      await _syncTable('workers', lastSync, _applyWorkerChanges);

      // Detect hard-deletions from Convex dashboard
      // Items that exist locally but not in cloud should be marked deleted
      await _detectHardDeletions(
          'subscribers', _getLocalSubscriberIds, _markSubscriberDeleted);
      await _detectHardDeletions(
          'cabinets', _getLocalCabinetIds, _markCabinetDeleted);
      await _detectHardDeletions(
          'payments', _getLocalPaymentIds, _markPaymentDeleted);
      await _detectHardDeletions(
          'workers', _getLocalWorkerIds, _markWorkerDeleted);
      await _detectHardDeletions(
          'auditLog', _getLocalAuditLogIds, _markAuditLogDeleted);
      await _detectHardDeletions('whatsappTemplates',
          _getLocalWhatsappTemplateIds, _markWhatsappTemplateDeleted);
      await _detectHardDeletions('generatorSettings',
          _getLocalGeneratorSettingsIds, _markGeneratorSettingsDeleted);

      // Update last sync timestamp
      await _setLastSyncTimestamp(now);
      debugPrint('ConvexDownSyncService: Down-sync completed');
    } catch (e) {
      debugPrint('ConvexDownSyncService Error: $e');
    }
  }

  /// Sync events from Convex to local event store.
  /// This is the primary down-sync method for the event-sourced architecture.
  Future<void> _syncEventsFromCloud(int sinceTimestamp) async {
    try {
      debugPrint('[EventDownSync] Fetching events since $sinceTimestamp');
      
      final result = await AppConvexConfig.query('queries/events:getEventsSince', {
        'ownerId': _getCurrentOwnerId(),
        'since': sinceTimestamp,
      });

      if (result is! List || result.isEmpty) {
        debugPrint('[EventDownSync] No new events');
        return;
      }

      final events = result.cast<Map<String, dynamic>>();
      debugPrint('[EventDownSync] Processing ${events.length} events from cloud');

      for (final eventData in events) {
        try {
          final eventType = eventData['eventType'] as String;
          final entityType = eventData['entityType'] as String;
          final entityId = eventData['entityId'] as String;
          final version = eventData['version'] as int;
          final occurredAt = DateTime.fromMillisecondsSinceEpoch(eventData['occurredAt'] as int);

          // Parse payload - handle both string and already-decoded map
          Map<String, dynamic> payload;
          final payloadRaw = eventData['payload'];
          if (payloadRaw is String) {
            try {
              payload = jsonDecode(payloadRaw) as Map<String, dynamic>;
            } catch (e) {
              debugPrint('[EventDownSync] Failed to parse payload JSON: $e');
              payload = {};
            }
          } else if (payloadRaw is Map) {
            payload = Map<String, dynamic>.from(payloadRaw);
          } else {
            debugPrint('[EventDownSync] Unexpected payload type: ${payloadRaw.runtimeType}');
            payload = {};
          }

          // Check if we already have this event locally
          final existingEvents = await _eventService.getEventsForEntity(entityType, entityId);
          final alreadyHas = existingEvents.any((e) =>
            e.eventType == eventType && e.version == version);
          
          if (alreadyHas) {
            continue; // Skip duplicate events
          }

          // Apply the event to local state
          await _applyEventLocally(eventType, entityType, entityId, payload, version);

          // Record the event locally as synced
          await _eventService.appendEvent(
            eventType: eventType,
            entityType: entityType,
            entityId: entityId,
            payload: payload,
            version: version,
            occurredAt: occurredAt,
          );
        } catch (e) {
          debugPrint('[EventDownSync] Error processing event: $e');
          // Continue with next event instead of failing entirely
        }
      }

      debugPrint('[EventDownSync] Events sync completed');
    } catch (e) {
      debugPrint('[EventDownSync] Error: $e');
    }
  }

  /// Apply an event to the local database state.
  Future<void> _applyEventLocally(
    String eventType,
    String entityType,
    String entityId,
    Map<String, dynamic> payload,
    int version,
  ) async {
    switch (eventType) {
      case EventTypes.entityCreated:
      case EventTypes.entityUpdated:
        // Update the entity in the local database
        await _updateLocalEntity(entityType, entityId, payload, version);
        break;
      case EventTypes.entityMovedToTrash:
        // Mark entity as deleted locally
        await _markLocalEntityDeleted(entityType, entityId, version);
        break;
      case EventTypes.entityRestoredFromTrash:
        // Restore entity locally (would need to re-insert from payload)
        await _updateLocalEntity(entityType, entityId, payload, version);
        break;
      case EventTypes.entityPermanentlyDeleted:
        // Delete entity from local database
        await _deleteLocalEntity(entityType, entityId);
        break;
    }
  }

  /// Update a local entity from cloud event data.
  Future<void> _updateLocalEntity(
    String entityType,
    String entityId,
    Map<String, dynamic> payload,
    int version,
  ) async {
    // This is a simplified implementation - in production, you'd map
    // entityType to the correct table and update accordingly
    debugPrint('[EventDownSync] Would update $entityType/$entityId with v$version');
  }

  /// Mark a local entity as deleted.
  Future<void> _markLocalEntityDeleted(
    String entityType,
    String entityId,
    int version,
  ) async {
    debugPrint('[EventDownSync] Would mark $entityType/$entityId as deleted');
  }

  /// Delete a local entity.
  Future<void> _deleteLocalEntity(String entityType, String entityId) async {
    debugPrint('[EventDownSync] Would delete $entityType/$entityId');
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
      // Convex documents store the client's local UUID in 'cloudId'
      // This maps to the local database 'id' field
      final localId = change['cloudId'] as String?;
      if (localId == null || localId.isEmpty) {
        debugPrint(
            '[DownSync] Skipping subscriber change without cloudId: ${change['_id']}');
        continue;
      }

      // LWW: Only apply if incoming version is newer
      final existing = await (database.select(database.subscribersTable)
            ..where((t) => t.id.equals(localId)))
          .getSingleOrNull();

      final incomingVersion = change['version'] as int? ?? 0;
      final existingVersion = existing?.version ?? 0;

      if (incomingVersion > existingVersion) {
        final isDeleted = change['isDeleted'] as bool? ?? false;

        // If incoming is deleted, mark local as deleted instead of full update
        if (isDeleted) {
          if (existing != null) {
            await (database.update(database.subscribersTable)
                  ..where((t) => t.id.equals(localId)))
                .write(SubscribersTableCompanion(
              isDeleted: const Value(true),
              version: Value(incomingVersion),
              updatedAt: Value(now),
            ));
            debugPrint('[DownSync] Soft deleted subscriber: $localId');
          }
          continue;
        }

        final companion = SubscribersTableCompanion(
          id: Value(localId),
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
          isDeleted: Value(isDeleted),
          updatedAt: Value(change['updatedAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(change['updatedAt'] as int)
              : now),
          createdAt: Value(change['createdAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(change['createdAt'] as int)
              : now),
        );

        if (existing != null) {
          await (database.update(database.subscribersTable)
                ..where((t) => t.id.equals(localId)))
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
      // Convex documents store the client's local UUID in 'cloudId'
      final localId = change['cloudId'] as String?;
      if (localId == null || localId.isEmpty) {
        debugPrint(
            '[DownSync] Skipping cabinet change without cloudId: ${change['_id']}');
        continue;
      }

      final isDeleted = change['isDeleted'] as bool? ?? false;
      final incomingVersion = change['version'] as int? ?? 0;

      var existing = await (database.select(database.cabinetsTable)
            ..where((t) => t.id.equals(localId)))
          .getSingleOrNull();

      final existingVersion = existing?.version ?? 0;

      if (incomingVersion > existingVersion) {
        // If incoming is deleted, mark local as deleted instead of full update
        if (isDeleted) {
          if (existing != null) {
            await (database.update(database.cabinetsTable)
                  ..where((t) => t.id.equals(localId)))
                .write(CabinetsTableCompanion(
              isDeleted: const Value(true),
              version: Value(incomingVersion),
              updatedAt: Value(now),
            ));
            debugPrint('[DownSync] Soft deleted cabinet: $localId');
          }
          continue;
        }

        final companion = CabinetsTableCompanion(
          id: Value(localId),
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
                ..where((t) => t.id.equals(localId)))
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
      // Convex documents store the client's local UUID in 'cloudId'
      final localId = change['cloudId'] as String?;
      if (localId == null || localId.isEmpty) {
        debugPrint(
            '[DownSync] Skipping payment change without cloudId: ${change['_id']}');
        continue;
      }

      final existing = await (database.select(database.paymentsTable)
            ..where((t) => t.id.equals(localId)))
          .getSingleOrNull();

      final incomingVersion = change['version'] as int? ?? 0;
      final existingVersion = existing?.version ?? 0;

      if (incomingVersion > existingVersion) {
        final isDeleted = change['isDeleted'] as bool? ?? false;

        // If incoming is deleted, mark local as deleted instead of full update
        if (isDeleted) {
          if (existing != null) {
            await (database.update(database.paymentsTable)
                  ..where((t) => t.id.equals(localId)))
                .write(PaymentsTableCompanion(
              isDeleted: const Value(true),
              version: Value(incomingVersion),
              updatedAt: Value(now),
            ));
            debugPrint('[DownSync] Soft deleted payment: $localId');
          }
          continue;
        }

        final companion = PaymentsTableCompanion(
          id: Value(localId),
          ownerId: Value(change['ownerId'] as String? ?? ''),
          subscriberId: Value(change['subscriberId'] as String? ?? ''),
          amount: Value(change['amount'] as double? ?? 0),
          worker: Value(change['worker'] as String? ?? ''),
          date: Value(change['date'] != null
              ? DateTime.fromMillisecondsSinceEpoch(change['date'] as int)
              : now),
          cabinet: Value(change['cabinet'] as String? ?? ''),
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
          await (database.update(database.paymentsTable)
                ..where((t) => t.id.equals(localId)))
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
      // Convex documents store the client's local UUID in 'cloudId'
      final localId = change['cloudId'] as String?;
      if (localId == null || localId.isEmpty) {
        debugPrint(
            '[DownSync] Skipping worker change without cloudId: ${change['_id']}');
        continue;
      }

      final existing = await (database.select(database.workersTable)
            ..where((t) => t.id.equals(localId)))
          .getSingleOrNull();

      final incomingVersion = change['version'] as int? ?? 0;
      final existingVersion = existing?.version ?? 0;

      if (incomingVersion > existingVersion) {
        final isDeleted = change['isDeleted'] as bool? ?? false;

        // If incoming is deleted, mark local as deleted instead of full update
        if (isDeleted) {
          if (existing != null) {
            await (database.update(database.workersTable)
                  ..where((t) => t.id.equals(localId)))
                .write(WorkersTableCompanion(
              isDeleted: const Value(true),
              version: Value(incomingVersion),
              updatedAt: Value(now),
            ));
            debugPrint('[DownSync] Soft deleted worker: $localId');
          }
          continue;
        }

        final companion = WorkersTableCompanion(
          id: Value(localId),
          ownerId: Value(change['ownerId'] as String? ?? ''),
          name: Value(change['name'] as String? ?? ''),
          phone: Value(change['phone'] as String? ?? ''),
          permissions: Value(change['permissions'] as String? ?? '{}'),
          todayCollected: Value(change['todayCollected'] as double? ?? 0),
          monthTotal: Value(change['monthTotal'] as double? ?? 0),
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
          await (database.update(database.workersTable)
                ..where((t) => t.id.equals(localId)))
              .write(companion);
        } else {
          await database.into(database.workersTable).insert(companion);
        }
      }
    }
  }

  // ==================== Hard Deletion Detection ====================
  // These methods detect items that were hard-deleted in Convex dashboard
  // and mark them as deleted locally so they disappear from the UI

  /// Fetch ALL items from cloud for a table (including soft-deleted).
  /// Uses get*ModifiedSince with since: 0 to get every document.
  /// This is critical for accurate hard-deletion detection: we need to know
  /// about ALL cloud documents (including soft-deleted ones) so we can distinguish
  /// between "soft-deleted by app" and "hard-deleted from Convex dashboard".
  Future<Set<String>> _getCloudItemIds(String tableName) async {
    // Use the ModifiedSince queries with since: 0 to get ALL documents
    final queryMappings = {
      'subscribers': 'queries/subscribers:getSubscribersModifiedSince',
      'cabinets': 'queries/cabinets:getCabinetsModifiedSince',
      'payments': 'queries/payments:getPaymentsModifiedSince',
      'workers': 'queries/workers:getWorkersModifiedSince',
    };

    final queryName = queryMappings[tableName];
    if (queryName == null) {
      debugPrint('[DownSync] No query mapping for cloud items: $tableName');
      return {};
    }

    try {
      debugPrint(
          '[DownSync] Fetching ALL cloud items for $tableName (including soft-deleted)');
      final result = await AppConvexConfig.query(queryName, {
        'ownerId': _getCurrentOwnerId(),
        'since': 0, // Get everything since epoch start
      });

      if (result is List) {
        // Convex documents have 'cloudId' which maps to local 'id'
        // The schema stores the client's local UUID in cloudId
        final ids = result
            .cast<Map<String, dynamic>>()
            .map((item) {
              // Only use cloudId - this is the client's local UUID stored in Convex
              // Do NOT fall back to 'id' field because the schema doesn't have one
              // (item['id'] would be null and cause false positives in hard-deletion detection)
              return (item['cloudId'] as String?) ?? '';
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
      debugPrint(
          '[DownSync] Error detecting hard deletions for $tableName: $e');
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
    await (database.update(database.subscribersTable)
          ..where((t) => t.id.equals(id)))
        .write(
      SubscribersTableCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ),
    );
    debugPrint('[DownSync] Marked subscriber $id as deleted');
  }

  Future<void> _markCabinetDeleted(String id) async {
    final now = DateTime.now();
    await (database.update(database.cabinetsTable)
          ..where((t) => t.id.equals(id)))
        .write(
      CabinetsTableCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ),
    );
    debugPrint('[DownSync] Marked cabinet $id as deleted');
  }

  Future<void> _markPaymentDeleted(String id) async {
    final now = DateTime.now();
    await (database.update(database.paymentsTable)
          ..where((t) => t.id.equals(id)))
        .write(
      PaymentsTableCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ),
    );
    debugPrint('[DownSync] Marked payment $id as deleted');
  }

  Future<void> _markWorkerDeleted(String id) async {
    final now = DateTime.now();
    await (database.update(database.workersTable)
          ..where((t) => t.id.equals(id)))
        .write(
      WorkersTableCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ),
    );
    debugPrint('[DownSync] Marked worker $id as deleted');
  }

  Future<Set<String>> _getLocalAuditLogIds() async {
    final rows = await (database.select(database.auditLogTable)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    return rows.map((r) => r.id).toSet();
  }

  Future<Set<String>> _getLocalWhatsappTemplateIds() async {
    final rows = await (database.select(database.whatsappTemplatesTable)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    return rows.map((r) => r.id).toSet();
  }

  Future<Set<String>> _getLocalGeneratorSettingsIds() async {
    final rows = await (database.select(database.generatorSettingsTable)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    return rows.map((r) => r.id).toSet();
  }

  Future<void> _markAuditLogDeleted(String id) async {
    final now = DateTime.now();
    await (database.update(database.auditLogTable)
          ..where((t) => t.id.equals(id)))
        .write(
      AuditLogTableCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ),
    );
    debugPrint('[DownSync] Marked audit log $id as deleted');
  }

  Future<void> _markWhatsappTemplateDeleted(String id) async {
    final now = DateTime.now();
    await (database.update(database.whatsappTemplatesTable)
          ..where((t) => t.id.equals(id)))
        .write(
      WhatsappTemplatesTableCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ),
    );
    debugPrint('[DownSync] Marked whatsapp template $id as deleted');
  }

  Future<void> _markGeneratorSettingsDeleted(String id) async {
    final now = DateTime.now();
    await (database.update(database.generatorSettingsTable)
          ..where((t) => t.id.equals(id)))
        .write(
      GeneratorSettingsTableCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ),
    );
    debugPrint('[DownSync] Marked generator settings $id as deleted');
  }
}
