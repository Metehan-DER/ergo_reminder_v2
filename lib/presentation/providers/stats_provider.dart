import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/stats_entity.dart';
import 'repository_providers.dart';

class StatsNotifier extends AsyncNotifier<DailyStatsEntity> {
  String get _todayStr {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<DailyStatsEntity> build() async {
    return ref.watch(statsRepositoryProvider).getDailyStats(_todayStr);
  }

  Future<void> incrementCompleted() async {
    final current = state.value ?? DailyStatsEntity(completed: 0, snoozed: 0, ignored: 0, date: _todayStr);
    final updated = current.copyWith(completed: current.completed + 1);
    await ref.read(statsRepositoryProvider).saveDailyStats(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> incrementSnoozed() async {
    final current = state.value ?? DailyStatsEntity(completed: 0, snoozed: 0, ignored: 0, date: _todayStr);
    final updated = current.copyWith(snoozed: current.snoozed + 1);
    await ref.read(statsRepositoryProvider).saveDailyStats(updated);
    state = AsyncValue.data(updated);
  }

  Future<void> incrementIgnored() async {
    final current = state.value ?? DailyStatsEntity(completed: 0, snoozed: 0, ignored: 0, date: _todayStr);
    final updated = current.copyWith(ignored: current.ignored + 1);
    await ref.read(statsRepositoryProvider).saveDailyStats(updated);
    state = AsyncValue.data(updated);
  }
}

final statsProvider = AsyncNotifierProvider<StatsNotifier, DailyStatsEntity>(() {
  return StatsNotifier();
});
