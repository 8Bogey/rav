import 'package:drift/drift.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/supabase/supabase_service.dart';
import 'package:mawlid_al_dhaki/core/supabase/sync_conflict.dart';

/// Enhanced synchronization service that handles bidirectional sync between 
/// local Drift database and Supabase cloud database with conflict resolution.
///
/// This service implements the sync architecture described in B08_IMPLEMENTATION_NOTES.md
class SyncService {
  final AppDatabase _localDatabase;
  final SupabaseService _supabaseService;
  
  // Sync configuration
  static const int MAX_RETRY_ATTEMPTS = 3;
  static const Duration RETRY_DELAY = Duration(seconds: 5);

  SyncService({
    required AppDatabase database,
    required SupabaseService supabaseService,
  })  : _localDatabase = database,
        _supabaseService = supabaseService;

  /// Main sync function that performs bidirectional synchronization
  Future<void> sync() async {
    try {
      print('Starting bidirectional sync...');
      
      // Phase 1: Local → Cloud sync
      await _syncLocalToCloud();
      
      // Phase 2: Cloud → Local sync
      await _syncCloudToLocal();
      
      print('Bidirectional sync completed successfully.');
    } catch (e) {
      print('Error during sync: $e');
      rethrow;
    }
  }

  /// Sync local changes to cloud database
  Future<void> _syncLocalToCloud() async {
    print('Syncing local changes to cloud...');
    
    try {
      await _supabaseService.syncLocalToCloud();
      print('Local to cloud sync completed.');
    } catch (e) {
      print('Error syncing local to cloud: $e');
      rethrow;
    }
  }

  /// Sync cloud changes to local database
  Future<void> _syncCloudToLocal() async {
    print('Syncing cloud changes to local database...');
    
    try {
      await _supabaseService.syncCloudToLocal();
      print('Cloud to local sync completed.');
    } catch (e) {
      print('Error syncing cloud to local: $e');
      rethrow;
    }
  }

  /// Detect conflicts between local and cloud records
  Future<List<SyncConflict>> detectConflicts() async {
    // For now, we'll integrate conflict detection into the sync process
    // This method can be expanded later with more sophisticated conflict detection
    return _supabaseService.detectAndResolveConflicts();
  }

  /// Resolve conflicts using last-write-wins strategy
  Future<void> resolveConflictsLastWriteWins(List<SyncConflict> conflicts) async {
    for (final conflict in conflicts) {
      switch (conflict.conflictType) {
        case ConflictType.concurrentModification:
          await _resolveConcurrentModification(conflict);
          break;
        case ConflictType.deleteModifyConflict:
          await _resolveDeleteModifyConflict(conflict);
          break;
        case ConflictType.dualDeleteConflict:
          // Nothing to do for dual deletes
          break;
        case ConflictType.businessRuleViolation:
          // Mark for manual resolution
          print('Business rule violation conflict requires manual resolution');
          break;
        case ConflictType.dataIntegrityConflict:
          // Attempt merge or mark for manual resolution
          print('Data integrity conflict detected');
          break;
      }
    }
  }
  
  /// Resolve concurrent modification conflict using last-write-wins strategy
  Future<void> _resolveConcurrentModification(SyncConflict conflict) async {
    // For concurrent modifications, keep the version with the most recent timestamp
    if (conflict.cloudLastModified != null && 
        conflict.localLastModified.isBefore(conflict.cloudLastModified!)) {
      // Cloud version is more recent, update local record with cloud data
      await _updateLocalFromCloud(conflict);
    } 
    // If local version is more recent or equal, it will be synced to cloud during next sync
  }
  
  /// Resolve delete/modify conflict using last-write-wins strategy
  Future<void> _resolveDeleteModifyConflict(SyncConflict conflict) async {
    // For delete/modify conflicts, keep the version with the most recent timestamp
    if (conflict.cloudLastModified != null && 
        conflict.localLastModified.isBefore(conflict.cloudLastModified!)) {
      // Cloud version is more recent, undelete local record and update with cloud data
      await _undeleteAndSyncWithCloud(conflict);
    } else {
      // Local delete is more recent, it will be synced to cloud during next sync
      // Mark local record as needing deletion in cloud
      await _markForCloudDeletion(conflict);
    }
  }
  
  /// Update local record with cloud data
  Future<void> _updateLocalFromCloud(SyncConflict conflict) async {
    // For now, we'll delegate this to the Supabase service
    // In a full implementation, this would fetch the specific cloud record and update the local database
    print('Updating local record ${conflict.localRecordId} from cloud data');
    
    // This would typically involve:
    // 1. Fetching the cloud record by ID
    // 2. Updating the local database record with cloud data
    // 3. Setting sync status to 'synced'
    // 4. Clearing the dirty flag
    
    // For now, we'll rely on the existing sync process to handle this during full sync
  }
  
  /// Undelete local record and update with cloud data
  Future<void> _undeleteAndSyncWithCloud(SyncConflict conflict) async {
    // For delete/modify conflicts where cloud version is more recent
    print('Undeleting local record ${conflict.localRecordId} and syncing with cloud data');
    
    // This would typically involve:
    // 1. Setting deletedLocally flag to false
    // 2. Updating the local record with cloud data
    // 3. Setting sync status to 'synced'
    // 4. Clearing the dirty flag
    
    // For now, we'll rely on the existing sync process to handle this during full sync
  }
  
  /// Mark local record for deletion in cloud
  Future<void> _markForCloudDeletion(SyncConflict conflict) async {
    // For delete/modify conflicts where local delete is more recent
    print('Marking local record ${conflict.localRecordId} for deletion in cloud');
    
    // This would typically involve:
    // 1. Ensuring the deletedLocally flag remains true
    // 2. Setting sync status to 'sync_pending' to ensure deletion is synced to cloud
    // 3. Keeping the dirty flag true
    
    // For now, we'll rely on the existing sync process to handle this during full sync
  }

  /// Update sync status for a record
  Future<void> updateSyncStatus(int recordId, String table, String status) async {
    try {
      switch (table) {
        case 'subscribers':
          await _localDatabase.subscribersDao.updateSyncStatus(recordId, status);
          break;
        case 'cabinets':
          await _localDatabase.cabinetsDao.updateSyncStatus(recordId, status);
          break;
        case 'payments':
          await _localDatabase.paymentsDao.updateSyncStatus(recordId, status);
          break;
        case 'workers':
          await _localDatabase.workersDao.updateSyncStatus(recordId, status);
          break;
        case 'audit_log':
          await _localDatabase.auditLogDao.updateSyncStatus(recordId, status);
          break;
        case 'whatsapp_templates':
          await _localDatabase.whatsappTemplatesDao.updateSyncStatus(recordId, status);
          break;
      }
    } catch (e) {
      print('Error updating sync status for record $recordId in table $table: $e');
      rethrow;
    }
  }

  /// Mark a record as dirty (needing sync)
  Future<void> markRecordAsDirty(int recordId, String table) async {
    try {
      switch (table) {
        case 'subscribers':
          await _localDatabase.subscribersDao.markRecordAsDirty(recordId);
          break;
        case 'cabinets':
          await _localDatabase.cabinetsDao.markRecordAsDirty(recordId);
          break;
        case 'payments':
          await _localDatabase.paymentsDao.markRecordAsDirty(recordId);
          break;
        case 'workers':
          await _localDatabase.workersDao.markRecordAsDirty(recordId);
          break;
        case 'audit_log':
          await _localDatabase.auditLogDao.markRecordAsDirty(recordId);
          break;
        case 'whatsapp_templates':
          await _localDatabase.whatsappTemplatesDao.markRecordAsDirty(recordId);
          break;
      }
      
      // Also update sync status to sync_pending if it was synced
      await updateSyncStatus(recordId, table, 'sync_pending');
    } catch (e) {
      print('Error marking record $recordId in table $table as dirty: $e');
      rethrow;
    }
  }

  /// Clear dirty flag after successful sync
  Future<void> clearDirtyFlag(int recordId, String table) async {
    try {
      switch (table) {
        case 'subscribers':
          await _localDatabase.subscribersDao.clearDirtyFlag(recordId);
          break;
        case 'cabinets':
          await _localDatabase.cabinetsDao.clearDirtyFlag(recordId);
          break;
        case 'payments':
          await _localDatabase.paymentsDao.clearDirtyFlag(recordId);
          break;
        case 'workers':
          await _localDatabase.workersDao.clearDirtyFlag(recordId);
          break;
        case 'audit_log':
          await _localDatabase.auditLogDao.clearDirtyFlag(recordId);
          break;
        case 'whatsapp_templates':
          await _localDatabase.whatsappTemplatesDao.clearDirtyFlag(recordId);
          break;
      }
      
      // Also update sync status to synced
      await updateSyncStatus(recordId, table, 'synced');
    } catch (e) {
      print('Error clearing dirty flag for record $recordId in table $table: $e');
      rethrow;
    }
  }
}