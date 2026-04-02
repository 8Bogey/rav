import 'dart:async';
import 'package:drift/drift.dart';
import 'package:convex_flutter/convex_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/convex/convex_config.dart';

/// Processor for fetching changes from Convex Cloud and applying them locally.
/// Implements Local-First: pull from cloud and resolve via LWW.
class SyncDownProcessor {
  final AppDatabase database;
  final ConvexClient client = AppConvexConfig.client;

  bool _isProcessing = false;
  Timer? _syncTimer;
  static const String _lastSyncKey = 'sync_down_last_timestamp';

  SyncDownProcessor(this.database);

  /// Start the background sync down loop.
  void start() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 15), (_) => processSyncDown());
    debugPrint('SyncDownProcessor: Started background loop');
  }

  /// Stop the background sync down loop.
  void stop() {
    _syncTimer?.cancel();
    _syncTimer = null;
    debugPrint('SyncDownProcessor: Stopped');
  }

  Future<void> processSyncDown() async {
    if (_isProcessing || !AppConvexConfig.isAuthenticated) return;

    _isProcessing = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncThreshold = prefs.getInt(_lastSyncKey) ?? 0;
      
      // Get the owner ID
      // NOTE: In the real app, we should fetch from authenticated identity,
      // but AppConvexConfig might hold tenant ID or it's fetched via Auth.
      // For now we will fetch the current connected ownerId.
      // Since queries can be authenticated, the server can use its own subject!
      // Actually convex server can check ownerId inside the query, but we must pass it.
      // Wait, we can pass a dummy ownerId if the backend allows, or fetch it.
      // Assuming AppConvexConfig has it or we can just fetch it from local settings/auth logic.
      final ownerId = await _getOwnerId();
      if (ownerId == null || ownerId.isEmpty) {
        _isProcessing = false;
        return;
      }

      debugPrint('SyncDownProcessor: Fetching changes since $lastSyncThreshold');

      final result = await client.query(
        'sync:getChangesSince',
        {
          'lastSyncThreshold': lastSyncThreshold,
          'ownerId': ownerId,
        },
      );

      await _applyChanges(result);
      
      // Update threshold upon success
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
      debugPrint('SyncDownProcessor: Successfully synced down changes');
    } catch (e) {
      debugPrint('SyncDownProcessor Error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  Future<String?> _getOwnerId() async {
    // Attempt to get ownerId. Usually it's the subject of the JWT or stored in app prefs.
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tenant_owner_id'); 
    // Fallback or adjust this to match exact local app logic for tenant ID.
  }

  Future<void> _applyChanges(dynamic changes) async {
    // The query returns { subscribers: [], cabinets: [], ... }
    final subscribers = changes['subscribers'] as List<dynamic>? ?? [];
    for (final sub in subscribers) {
      await _upsertSubscriber(sub);
    }
    
    final cabinets = changes['cabinets'] as List<dynamic>? ?? [];
    for (final cab in cabinets) {
      await _upsertCabinet(cab);
    }
    // Repeat for other tables...
  }

  Future<void> _upsertSubscriber(Map<String, dynamic> data) async {
    final syncId = data['syncId'] as String?;
    if (syncId == null) return;
    
    final cloudVersion = data['version'] as int? ?? 0;
    
    final existing = await (database.select(database.subscribersTable)..where((t) => t.id.equals(syncId))).getSingleOrNull();
    
    if (existing == null) {
      // Insert new
      await database.into(database.subscribersTable).insert(
        SubscribersTableCompanion.insert(
          id: syncId,
          name: data['name'] ?? '',
          code: data['code'] ?? '',
          cabinet: data['cabinet'] ?? '',
          phone: data['phone'] ?? '',
          status: data['status'] ?? 0,
          startDate: DateTime.fromMillisecondsSinceEpoch(data['startDate'] ?? 0),
          ownerId: Value(data['ownerId']),
          version: Value(cloudVersion),
          isDeleted: Value(data['isDeleted'] ?? false),
          updatedAt: Value(DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] ?? 0)),
          createdAt: Value(DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0)),
        ),
      );
    } else {
      // LWW check
      if (cloudVersion > existing.version) {
        await (database.update(database.subscribersTable)..where((t) => t.id.equals(syncId))).write(
          SubscribersTableCompanion(
            name: Value(data['name']),
            code: Value(data['code']),
            cabinet: Value(data['cabinet']),
            phone: Value(data['phone']),
            status: Value(data['status']),
            version: Value(cloudVersion),
            isDeleted: Value(data['isDeleted']),
            updatedAt: Value(DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] ?? 0)),
          ),
        );
      }
    }
  }

  Future<void> _upsertCabinet(Map<String, dynamic> data) async {
    final syncId = data['syncId'] as String?;
    if (syncId == null) return;
    
    final cloudVersion = data['version'] as int? ?? 0;
    
    final existing = await (database.select(database.cabinetsTable)..where((t) => t.id.equals(syncId))).getSingleOrNull();
    
    if (existing == null) {
      await database.into(database.cabinetsTable).insert(
        CabinetsTableCompanion.insert(
          id: syncId,
          name: data['name'] ?? '',
          letter: data['letter'] ?? '',
          totalSubscribers: data['totalSubscribers'] ?? 0,
          currentSubscribers: data['currentSubscribers'] ?? 0,
          collectedAmount: data['collectedAmount'] ?? 0.0,
          delayedSubscribers: data['delayedSubscribers'] ?? 0,
          ownerId: Value(data['ownerId']),
          version: Value(cloudVersion),
          isDeleted: Value(data['isDeleted'] ?? false),
          updatedAt: Value(DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] ?? 0)),
          createdAt: Value(DateTime.fromMillisecondsSinceEpoch(data['createdAt'] ?? 0)),
        ),
      );
    } else {
      if (cloudVersion > existing.version) {
        await (database.update(database.cabinetsTable)..where((t) => t.id.equals(syncId))).write(
          CabinetsTableCompanion(
            name: Value(data['name']),
            letter: Value(data['letter']),
            totalSubscribers: Value(data['totalSubscribers']),
            currentSubscribers: Value(data['currentSubscribers']),
            collectedAmount: Value(data['collectedAmount']),
            delayedSubscribers: Value(data['delayedSubscribers']),
            version: Value(cloudVersion),
            isDeleted: Value(data['isDeleted']),
            updatedAt: Value(DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] ?? 0)),
          ),
        );
      }
    }
  }
}
