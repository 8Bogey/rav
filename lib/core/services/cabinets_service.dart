import 'package:drift/drift.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/database/daos/cabinets_dao.dart';
import 'package:mawlid_al_dhaki/core/services/base_service.dart';
import 'package:mawlid_al_dhaki/core/services/outbox_service.dart';
import 'package:uuid/uuid.dart';

class CabinetsService extends BaseService {
  CabinetsService(super.database);

  CabinetsDao get _dao => database.cabinetsDao;
  late final OutboxService _outbox = OutboxService(database);

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
    final now = DateTime.now();
    
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
      createdAt: Value(now),
      updatedAt: Value(now),
      version: const Value(1),
      isDeleted: const Value(false),
    );
    
    // Add to outbox for Convex sync
    // Use cloudId to track Convex document ID for updates
    _outbox.addEntry(
      targetTable: 'cabinets',
      operationType: 'create',
      documentId: id,
      payload: {
        'cloudId': id, // Use local UUID as cloudId for tracking
        'ownerId': ownerId,
        'name': cabinet.name,
        'letter': cabinet.letter,
        'totalSubscribers': cabinet.totalSubscribers,
        'currentSubscribers': cabinet.currentSubscribers,
        'collectedAmount': cabinet.collectedAmount,
        'delayedSubscribers': cabinet.delayedSubscribers,
        'completionDate': cabinet.completionDate?.millisecondsSinceEpoch,
        'version': 1,
        'isDeleted': false,
        'updatedAt': now.millisecondsSinceEpoch,
        'createdAt': now.millisecondsSinceEpoch,
      },
    );
    
    return _dao.addCabinet(companion);
  }

  // Update a cabinet
  Future<bool> updateCabinet(Cabinet cabinet, {required String ownerId}) {
    final now = DateTime.now();
    final newVersion = (cabinet.version ?? 0) + 1;
    final companion = cabinet.toCompanion(false).copyWith(
      ownerId: Value(ownerId),
      version: Value(newVersion),
      updatedAt: Value(now),
    );
    
    // Add to outbox for Convex sync
    _outbox.addEntry(
      targetTable: 'cabinets',
      operationType: 'update',
      documentId: cabinet.id,
      payload: {
        'id': cabinet.id,
        'ownerId': ownerId,
        'name': cabinet.name,
        'letter': cabinet.letter,
        'totalSubscribers': cabinet.totalSubscribers,
        'currentSubscribers': cabinet.currentSubscribers,
        'collectedAmount': cabinet.collectedAmount,
        'delayedSubscribers': cabinet.delayedSubscribers,
        'completionDate': cabinet.completionDate?.millisecondsSinceEpoch,
        'version': newVersion,
        'isDeleted': cabinet.isDeleted,
        'updatedAt': now.millisecondsSinceEpoch,
        'createdAt': cabinet.createdAt?.millisecondsSinceEpoch ?? now.millisecondsSinceEpoch,
      },
    );
    
    return _dao.updateCabinet(companion);
  }

  // Delete a cabinet (soft delete)
  Future<bool> deleteCabinet(String id, {required String ownerId}) async {
    final now = DateTime.now();
    final existing = await _dao.getCabinetById(id, ownerId: ownerId);
    final newVersion = (existing?.version ?? 0) + 1;
    
    // Use soft delete which only updates isDeleted and updatedAt
    final result = await _dao.softDeleteCabinet(id);
    
    // Add to outbox for Convex sync
    _outbox.addEntry(
      targetTable: 'cabinets',
      operationType: 'delete',
      documentId: id,
      payload: {
        'id': id,
        'ownerId': ownerId,
        'version': newVersion,
      },
    );
    
    return result;
  }
}
