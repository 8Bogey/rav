import 'package:drift/drift.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/database/daos/cabinets_dao.dart';
import 'package:mawlid_al_dhaki/core/services/base_service.dart';

class CabinetsService extends BaseService {
  CabinetsService(super.database);

  CabinetsDao get _dao => database.cabinetsDao;

  // Get all cabinets
  Future<List<Cabinet>> getAllCabinets() {
    return _dao.getAllCabinets();
  }

  // Get cabinet by ID
  Future<Cabinet?> getCabinetById(int id) {
    return _dao.getCabinetById(id);
  }

  // Get cabinet by name
  Future<Cabinet?> getCabinetByName(String name) {
    return _dao.getCabinetByName(name);
  }

  // Add a new cabinet
  Future<int> addCabinet(Cabinet cabinet) {
    // For inserts, we want to let the database auto-generate the ID
    final companion = CabinetsTableCompanion(
      name: Value(cabinet.name),
      letter: Value(cabinet.letter),
      totalSubscribers: Value(cabinet.totalSubscribers),
      currentSubscribers: Value(cabinet.currentSubscribers),
      collectedAmount: Value(cabinet.collectedAmount),
      delayedSubscribers: Value(cabinet.delayedSubscribers),
      completionDate: Value(cabinet.completionDate),
    );
    return _dao.addCabinet(companion);
  }

  // Update a cabinet
  Future<bool> updateCabinet(Cabinet cabinet) {
    final companion = cabinet.toCompanion(false);
    return _dao.updateCabinet(companion);
  }

  // Delete a cabinet
  Future<int> deleteCabinet(int id) {
    return _dao.deleteCabinet(id);
  }

  // Get dirty cabinets (those with dirtyFlag = true)
  Future<List<Cabinet>> getDirtyCabinets() {
    return _dao.getDirtyCabinets();
  }
  
  // Mark a cabinet record for manual conflict resolution
  Future<int> markConflictForManualResolution(int id) {
    return _dao.markConflictForManualResolution(id);
  }
  
  // Update conflict resolution information
  Future<int> updateConflictResolution(int id, {
    String? conflictResolutionStrategy,
    DateTime? conflictResolvedAt,
    String? conflictOrigin,
  }) {
    return _dao.updateConflictResolution(
      id,
      conflictResolutionStrategy: conflictResolutionStrategy,
      conflictResolvedAt: conflictResolvedAt,
      conflictOrigin: conflictOrigin,
    );
  }
  
  // Mark record as deleted locally
  Future<int> markDeletedLocally(int id) {
    return _dao.markDeletedLocally(id);
  }
  
  // Undelete a record
  Future<int> undeleteRecord(int id) {
    return _dao.undeleteRecord(id);
  }
  
  // Update sync error information
  Future<int> updateSyncError(int id, String errorMessage) {
    return _dao.updateSyncError(id, errorMessage);
  }
  
  // Increment sync retry count
  Future<int> incrementSyncRetryCount(int id) {
    return _dao.incrementSyncRetryCount(id);
  }
  
  // Reset sync error and retry count after successful sync
  Future<int> resetSyncError(int id) {
    return _dao.resetSyncError(id);
  }
  
  // Update sync status
  Future<int> updateSyncStatus(int id, String status) {
    return _dao.updateSyncStatus(id, status);
  }
  
  // Mark record as dirty
  Future<int> markRecordAsDirty(int id) {
    return _dao.markRecordAsDirty(id);
  }
  
  // Clear dirty flag
  Future<int> clearDirtyFlag(int id) {
    return _dao.clearDirtyFlag(id);
  }
}