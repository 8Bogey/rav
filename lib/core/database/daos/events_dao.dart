import 'package:drift/drift.dart';
import '../app_database.dart';

part 'events_dao.g.dart';

@DriftAccessor(tables: [EventsTable])
class EventsDao extends DatabaseAccessor<AppDatabase> with _$EventsDaoMixin {
  EventsDao(super.db);

  /// Get all pending events (not yet synced to Convex)
  Future<List<EventEntry>> getPendingEvents() {
    return (select(eventsTable)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm.asc(t.occurredAt)]))
        .get();
  }

  /// Get events since a specific timestamp (for down-sync processing)
  Future<List<EventEntry>> getEventsSince(DateTime since) {
    return (select(eventsTable)
          ..where((t) => t.occurredAt.isBiggerOrEqualValue(since))
          ..orderBy([(t) => OrderingTerm.asc(t.occurredAt)]))
        .get();
  }

  /// Get events for a specific entity
  Future<List<EventEntry>> getEventsForEntity(String entityType, String entityId) {
    return (select(eventsTable)
          ..where((t) => t.entityType.equals(entityType))
          ..where((t) => t.entityId.equals(entityId))
          ..orderBy([(t) => OrderingTerm.asc(t.occurredAt)]))
        .get();
  }

  /// Insert a new event
  Future<String> insertEvent(Insertable<EventEntry> event) async {
    return await into(eventsTable).insert(event).then((_) {
      final comp = event as EventsTableCompanion;
      return comp.id.value;
    });
  }

  /// Mark an event as synced
  Future<int> markEventSynced(String id) {
    return (update(eventsTable)..where((t) => t.id.equals(id)))
        .write(EventsTableCompanion(
      status: const Value('synced'),
    ));
  }

  /// Mark an event as failed
  Future<int> markEventFailed(String id, String error) {
    return (update(eventsTable)..where((t) => t.id.equals(id)))
        .write(EventsTableCompanion(
      status: const Value('failed'),
    ));
  }

  /// Delete synced events older than a threshold
  Future<int> deleteOldSyncedEvents(DateTime before) {
    return (delete(eventsTable)
          ..where((t) => t.status.equals('synced'))
          ..where((t) => t.createdAt.isSmallerThanValue(before)))
        .go();
  }

  /// Get count of pending events
  Future<int> getPendingCount() async {
    final query = selectOnly(eventsTable)
      ..addColumns([eventsTable.id.count()])
      ..where(eventsTable.status.equals('pending'));
    final result = await query.getSingle();
    return result.read(eventsTable.id.count()) ?? 0;
  }
}
