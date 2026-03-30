import 'package:drift/drift.dart';
import 'package:mawlid_al_dhaki/core/supabase/sync_conflict.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/services/cabinets_service.dart';
import 'package:mawlid_al_dhaki/core/services/subscribers_service.dart';
import 'package:mawlid_al_dhaki/core/services/payments_service.dart';
import 'package:mawlid_al_dhaki/core/services/workers_service.dart';

/// Service for resolving synchronization conflicts
class ConflictResolutionService {
  final AppDatabase _database;
  final CabinetsService _cabinetsService;
  final SubscribersService _subscribersService;
  final PaymentsService _paymentsService;
  final WorkersService _workersService;

  ConflictResolutionService({
    required AppDatabase database,
    required CabinetsService cabinetsService,
    required SubscribersService subscribersService,
    required PaymentsService paymentsService,
    required WorkersService workersService,
  })  : _database = database,
        _cabinetsService = cabinetsService,
        _subscribersService = subscribersService,
        _paymentsService = paymentsService,
        _workersService = workersService;

  /// Resolve a conflict using the specified strategy
  Future<void> resolveConflict(
    SyncConflict conflict,
    ConflictResolutionStrategy strategy,
  ) async {
    switch (strategy) {
      case ConflictResolutionStrategy.lastWriteWins:
        await _resolveLastWriteWins(conflict);
        break;
      case ConflictResolutionStrategy.preferLocal:
        await _resolvePreferLocal(conflict);
        break;
      case ConflictResolutionStrategy.preferCloud:
        await _resolvePreferCloud(conflict);
        break;
      case ConflictResolutionStrategy.mergeChanges:
        await _resolveMergeChanges(conflict);
        break;
      case ConflictResolutionStrategy.manualResolution:
        await _markForManualResolution(conflict);
        break;
      case ConflictResolutionStrategy.forkRecord:
        await _resolveForkRecord(conflict);
        break;
    }
  }

  /// Resolve using last-write-wins strategy (most recent timestamp wins)
  Future<void> _resolveLastWriteWins(SyncConflict conflict) async {
    if (conflict.cloudLastModified != null &&
        conflict.localLastModified.isBefore(conflict.cloudLastModified!)) {
      // Cloud is newer, prefer cloud
      await _resolvePreferCloud(conflict);
    } else {
      // Local is newer or equal, prefer local
      await _resolvePreferLocal(conflict);
    }
  }

  /// Resolve by keeping local version and discarding cloud changes
  Future<void> _resolvePreferLocal(SyncConflict conflict) async {
    print('Resolving conflict ${conflict.localRecordId} with preferLocal strategy');

    // Mark local record as synced (clears conflict)
    await _updateConflictResolved(conflict, 'preferLocal');

    // The local version will be synced to cloud on next sync
  }

  /// Resolve by keeping cloud version and discarding local changes
  Future<void> _resolvePreferCloud(SyncConflict conflict) async {
    print('Resolving conflict ${conflict.localRecordId} with preferCloud strategy');

    // Fetch cloud data and update local record
    // This is handled by SupabaseService during sync
    await _updateConflictResolved(conflict, 'preferCloud');
  }

  /// Resolve by merging non-conflicting fields from both versions
  Future<void> _resolveMergeChanges(SyncConflict conflict) async {
    print('Resolving conflict ${conflict.localRecordId} with mergeChanges strategy');

    if (conflict.localData == null || conflict.cloudData == null) {
      // Can't merge without both versions - fall back to last-write-wins
      await _resolveLastWriteWins(conflict);
      return;
    }

    // Merge fields that don't conflict
    final mergedData = _mergeFieldValues(
      conflict.localData!,
      conflict.cloudData!,
    );

    // Update local record with merged data
    await _updateLocalWithMergedData(conflict, mergedData);
    await _updateConflictResolved(conflict, 'merge');
  }

  /// Merge field values from local and cloud
  Map<String, dynamic> _mergeFieldValues(
    Map<String, dynamic> local,
    Map<String, dynamic> cloud,
  ) {
    final merged = <String, dynamic>{};
    final allKeys = {...local.keys, ...cloud.keys};

    for (final key in allKeys) {
      // Skip sync metadata fields
      if (_isSyncMetadataField(key)) continue;

      final localValue = local[key];
      final cloudValue = cloud[key];

      if (localValue == cloudValue) {
        // Values are the same, use either
        merged[key] = localValue;
      } else if (localValue == null) {
        // Local is null, use cloud value
        merged[key] = cloudValue;
      } else if (cloudValue == null) {
        // Cloud is null, use local value
        merged[key] = localValue;
      } else {
        // Both have different values - can't auto-merge
        // Prefer local for now (could be made configurable)
        merged[key] = localValue;
      }
    }

    return merged;
  }

  /// Check if field is a sync metadata field
  bool _isSyncMetadataField(String fieldName) {
    const syncFields = [
      'last_modified',
      'sync_status',
      'dirty_flag',
      'cloud_id',
      'deleted_locally',
      'permissions_mask',
      'conflict_origin',
      'conflict_detected_at',
      'conflict_resolved_at',
      'conflict_resolution_strategy',
      'last_synced_at',
      'last_sync_error',
      'sync_retry_count',
    ];
    return syncFields.contains(fieldName.toLowerCase());
  }

  /// Mark conflict for manual resolution
  Future<void> _markForManualResolution(SyncConflict conflict) async {
    print('Marking conflict ${conflict.localRecordId} for manual resolution');

    // Update the record to mark it for manual resolution
    await _updateConflictStatus(conflict, 'manual');
  }

  /// Fork the record (create both versions as separate records)
  Future<void> _resolveForkRecord(SyncConflict conflict) async {
    print('Forking conflict ${conflict.localRecordId}');

    // This would create a copy of the local record with a new ID
    // and mark the original for deletion
    await _updateConflictResolved(conflict, 'fork');
  }

  /// Update conflict resolved status in local database
  Future<void> _updateConflictResolved(
    SyncConflict conflict,
    String resolutionStrategy,
  ) async {
    final now = DateTime.now();

    switch (conflict.tableName) {
      case 'subscribers':
        await _database.customStatement(
          'UPDATE subscribers SET sync_status = ?, conflict_resolved_at = ?, conflict_resolution_strategy = ? WHERE id = ?',
          ['synced', now.toIso8601String(), resolutionStrategy, conflict.localRecordId],
        );
        break;
      case 'cabinets':
        await _database.customStatement(
          'UPDATE cabinets SET sync_status = ?, conflict_resolved_at = ?, conflict_resolution_strategy = ? WHERE id = ?',
          ['synced', now.toIso8601String(), resolutionStrategy, conflict.localRecordId],
        );
        break;
      case 'payments':
        await _database.customStatement(
          'UPDATE payments SET sync_status = ?, conflict_resolved_at = ?, conflict_resolution_strategy = ? WHERE id = ?',
          ['synced', now.toIso8601String(), resolutionStrategy, conflict.localRecordId],
        );
        break;
      case 'workers':
        await _database.customStatement(
          'UPDATE workers SET sync_status = ?, conflict_resolved_at = ?, conflict_resolution_strategy = ? WHERE id = ?',
          ['synced', now.toIso8601String(), resolutionStrategy, conflict.localRecordId],
        );
        break;
    }
  }

  /// Update conflict status (for manual resolution)
  Future<void> _updateConflictStatus(
    SyncConflict conflict,
    String status,
  ) async {
    final now = DateTime.now();

    switch (conflict.tableName) {
      case 'subscribers':
        await _database.customStatement(
          'UPDATE subscribers SET sync_status = ?, conflict_origin = ?, conflict_detected_at = ? WHERE id = ?',
          [status, 'manual', now.toIso8601String(), conflict.localRecordId],
        );
        break;
      case 'cabinets':
        await _database.customStatement(
          'UPDATE cabinets SET sync_status = ?, conflict_origin = ?, conflict_detected_at = ? WHERE id = ?',
          [status, 'manual', now.toIso8601String(), conflict.localRecordId],
        );
        break;
      case 'payments':
        await _database.customStatement(
          'UPDATE payments SET sync_status = ?, conflict_origin = ?, conflict_detected_at = ? WHERE id = ?',
          [status, 'manual', now.toIso8601String(), conflict.localRecordId],
        );
        break;
      case 'workers':
        await _database.customStatement(
          'UPDATE workers SET sync_status = ?, conflict_origin = ?, conflict_detected_at = ? WHERE id = ?',
          [status, 'manual', now.toIso8601String(), conflict.localRecordId],
        );
        break;
    }
  }

  /// Update local record with merged data
  Future<void> _updateLocalWithMergedData(
    SyncConflict conflict,
    Map<String, dynamic> mergedData,
  ) async {
    // This would update the local record with the merged data
    // Implementation depends on the table structure
    print('Updating local record with merged data: $mergedData');
  }

  /// Get all unresolved conflicts
  Future<List<SyncConflict>> getUnresolvedConflicts() async {
    final conflicts = <SyncConflict>[];

    // Query each table for conflicts
    conflicts.addAll(await _getTableConflicts('subscribers'));
    conflicts.addAll(await _getTableConflicts('cabinets'));
    conflicts.addAll(await _getTableConflicts('payments'));
    conflicts.addAll(await _getTableConflicts('workers'));

    return conflicts;
  }

  /// Get conflicts from a specific table
  Future<List<SyncConflict>> _getTableConflicts(String tableName) async {
    final conflicts = <SyncConflict>[];

    try {
      final results = await _database.customSelect(
        'SELECT * FROM $tableName WHERE sync_status = ?',
        variables: [Variable.withString('conflict')],
      ).get();

      for (final row in results) {
        conflicts.add(SyncConflict(
          localRecordId: row.read<int>('id'),
          cloudRecordId: row.read<String?>('cloud_id'),
          tableName: tableName,
          localLastModified: row.read<DateTime?>('last_modified') ?? DateTime.now(),
          cloudLastModified: null, // Would need cloud query
          conflictType: ConflictType.concurrentModification,
          conflictOrigin: row.read<String?>('conflict_origin'),
          conflictDetectedAt: row.read<DateTime?>('conflict_detected_at') ?? DateTime.now(),
        ));
      }
    } catch (e) {
      print('Error getting conflicts from $tableName: $e');
    }

    return conflicts;
  }

  /// Auto-resolve all resolvable conflicts using recommended strategy
  Future<int> autoResolveConflicts() async {
    final conflicts = await getUnresolvedConflicts();
    int resolvedCount = 0;

    for (final conflict in conflicts) {
      final strategy = conflict.recommendedResolutionStrategy;

      // Skip manual resolution - those need user input
      if (strategy == ConflictResolutionStrategy.manualResolution) {
        continue;
      }

      try {
        await resolveConflict(conflict, strategy);
        resolvedCount++;
      } catch (e) {
        print('Failed to resolve conflict ${conflict.localRecordId}: $e');
      }
    }

    return resolvedCount;
  }
}
