import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/database/daos/events_dao.dart';
import 'package:uuid/uuid.dart';

/// Event types for the event-sourced architecture
class EventTypes {
  static const String entityCreated = 'ENTITY_CREATED';
  static const String entityUpdated = 'ENTITY_UPDATED';
  static const String entityMovedToTrash = 'ENTITY_MOVED_TO_TRASH';
  static const String entityRestoredFromTrash = 'ENTITY_RESTORED_FROM_TRASH';
  static const String entityPermanentlyDeleted = 'ENTITY_PERMANENTLY_DELETED';
}

/// Service for managing the event store in the event-sourced architecture.
/// Events are immutable and append-only, providing a complete audit trail.
class EventService {
  final AppDatabase database;
  late final EventsDao _eventsDao;
  static const _uuid = Uuid();

  EventService(this.database) {
    _eventsDao = database.eventsDao;
  }

  /// Append an event to the local event store.
  /// This is the primary way to record data changes in the event-sourced system.
  Future<String> appendEvent({
    required String eventType,
    required String entityType,
    required String entityId,
    required Map<String, dynamic> payload,
    required int version,
    DateTime? occurredAt,
  }) async {
    final id = _uuid.v4();
    final event = EventsTableCompanion(
      id: Value(id),
      eventType: Value(eventType),
      entityType: Value(entityType),
      entityId: Value(entityId),
      payload: Value(jsonEncode(payload)),
      version: Value(version),
      occurredAt: Value(occurredAt ?? DateTime.now()),
      status: const Value('pending'),
      createdAt: Value(DateTime.now()),
    );

    await _eventsDao.insertEvent(event);
    debugPrint('[EventService] Appended event: $eventType for $entityType/$entityId (v$version)');
    return id;
  }

  /// Get all pending events (not yet synced to Convex)
  Future<List<EventEntry>> getPendingEvents() async {
    return _eventsDao.getPendingEvents();
  }

  /// Get count of pending events
  Future<int> getPendingCount() async {
    return _eventsDao.getPendingCount();
  }

  /// Mark an event as synced to Convex
  Future<int> markEventSynced(String id) async {
    final result = await _eventsDao.markEventSynced(id);
    debugPrint('[EventService] Marked event $id as synced');
    return result;
  }

  /// Mark an event as failed
  Future<int> markEventFailed(String id, String error) async {
    final result = await _eventsDao.markEventFailed(id, error);
    debugPrint('[EventService] Marked event $id as failed: $error');
    return result;
  }

  /// Delete old synced events to clean up the event store
  /// Events are kept for audit purposes, but very old synced events can be cleaned up
  Future<void> cleanupOldEvents({int retentionDays = 90}) async {
    final cutoff = DateTime.now().subtract(Duration(days: retentionDays));
    final deleted = await _eventsDao.deleteOldSyncedEvents(cutoff);
    debugPrint('[EventService] Cleaned up $deleted old synced events');
  }

  /// Get events for a specific entity (for debugging/audit)
  Future<List<EventEntry>> getEventsForEntity(String entityType, String entityId) async {
    return _eventsDao.getEventsForEntity(entityType, entityId);
  }

  /// Rebuild entity state from events (event replay)
  /// This is useful for recovering from data corruption or syncing from scratch
  Future<Map<String, dynamic>?> replayEvents(String entityType, String entityId) async {
    final events = await getEventsForEntity(entityType, entityId);
    if (events.isEmpty) return null;

    Map<String, dynamic>? state;
    for (final event in events) {
      final payload = jsonDecode(event.payload) as Map<String, dynamic>;
      switch (event.eventType) {
        case EventTypes.entityCreated:
          state = payload;
          break;
        case EventTypes.entityUpdated:
          state = {...?state, ...payload};
          break;
        case EventTypes.entityMovedToTrash:
          state = {...?state, 'inTrash': true, 'isDeleted': true};
          break;
        case EventTypes.entityRestoredFromTrash:
          state = {...?state, 'inTrash': false, 'isDeleted': false};
          break;
        case EventTypes.entityPermanentlyDeleted:
          state = null; // Entity is deleted
          break;
      }
    }
    return state;
  }
}
