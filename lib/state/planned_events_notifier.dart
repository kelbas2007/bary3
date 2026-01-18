import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/planned_event.dart';
import 'providers.dart';

final plannedEventsProvider =
    AsyncNotifierProvider<PlannedEventsNotifier, List<PlannedEvent>>(
  PlannedEventsNotifier.new,
);

class PlannedEventsNotifier extends AsyncNotifier<List<PlannedEvent>> {
  @override
  Future<List<PlannedEvent>> build() async {
    ref.watch(plannedEventsVersionProvider);
    final repo = ref.read(plannedEventsRepositoryProvider);
    return repo.fetch();
  }

  Future<void> refresh() async {
    // state = const AsyncLoading(); // Не сбрасываем состояние в loading, чтобы избежать мигания
    // Просто обновляем данные
    state = await AsyncValue.guard(() => ref.read(plannedEventsRepositoryProvider).fetch(forceRefresh: true));
  }
}

