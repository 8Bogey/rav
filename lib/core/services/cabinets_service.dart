import 'package:drift/drift.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/database/daos/cabinets_dao.dart';
import 'package:mawlid_al_dhaki/core/services/base_service.dart';
import 'package:uuid/uuid.dart';

class CabinetsService extends BaseService {
  CabinetsService(super.database);

  CabinetsDao get _dao => database.cabinetsDao;

  // Get all cabinets
  Future<List<Cabinet>> getAllCabinets({required String ownerId}) {
    return _dao.getAllCabinets(ownerId: ownerId);
  }

  // Get cabinet by ID
  Future<Cabinet?> getCabinetById(String id, {required String ownerId}) {
    return _dao.getCabinetById(id, ownerId: ownerId);
  }

  // Get cabinet by name
  Future<Cabinet?> getCabinetByName(String name, {required String ownerId}) {
    return _dao.getCabinetByName(name, ownerId: ownerId);
  }

  // Add a new cabinet
  Future<String> addCabinet(Cabinet cabinet, {required String ownerId}) {
    // Generate a UUID for the new cabinet
    final id = const Uuid().v4();
    
    final companion = CabinetsTableCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      name: Value(cabinet.name),
      letter: Value(cabinet.letter),
      totalSubscribers: Value(cabinet.totalSubscribers),
      currentSubscribers: Value(cabinet.currentSubscribers),
      collectedAmount: Value(cabinet.collectedAmount),
      delayedSubscribers: Value(cabinet.delayedSubscribers),
      completionDate: Value(cabinet.completionDate),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
      version: const Value(1),
      isDeleted: const Value(false),
    );
    return _dao.addCabinet(companion);
  }

  // Update a cabinet
  Future<bool> updateCabinet(Cabinet cabinet, {required String ownerId}) {
    final companion = cabinet.toCompanion(false).copyWith(
      ownerId: Value(ownerId),
      updatedAt: Value(DateTime.now()),
    );
    return _dao.updateCabinet(companion);
  }

  // Delete a cabinet (soft delete)
  Future<bool> deleteCabinet(String id, {required String ownerId}) {
    final companion = CabinetsTableCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      isDeleted: const Value(true),
      updatedAt: Value(DateTime.now()),
    );
    return _dao.updateCabinet(companion);
  }
}
