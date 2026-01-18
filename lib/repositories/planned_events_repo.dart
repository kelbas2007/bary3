import '../models/planned_event.dart';
import '../services/storage_service.dart';

class PlannedEventsRepository {
  const PlannedEventsRepository();

  Future<List<PlannedEvent>> fetch({bool forceRefresh = false}) {
    return StorageService.getPlannedEvents(forceRefresh: forceRefresh);
  }

  Future<void> saveAll(List<PlannedEvent> events) {
    return StorageService.savePlannedEvents(events);
  }

  Future<void> updateStatus(String id, PlannedEventStatus status) async {
    final events = await StorageService.getPlannedEvents();
    final idx = events.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    events[idx] = events[idx].copyWith(status: status);
    await StorageService.savePlannedEvents(events);
  }
}

