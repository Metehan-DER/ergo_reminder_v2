import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/water_entity.dart';
import 'repository_providers.dart';

/// WaterNotifier — Su takibi iş mantığı.
///
/// Önceki implementasyonda doğrudan [storageServiceProvider]'a ve
/// JSON encode/decode'a bağımlıydı (DIP ihlali + SRP ihlali).
/// Artık yalnızca [WaterRepository] soyutlamasına bağımlıdır.
class WaterNotifier extends Notifier<WaterLogEntity> {
  String get _todayStr {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  WaterLogEntity build() {
    Future.microtask(() => _loadTodayWaterLog());
    return WaterLogEntity(date: _todayStr, consumedMl: 0);
  }

  Future<void> _loadTodayWaterLog() async {
    final repo = ref.read(waterRepositoryProvider);
    final log = await repo.getWaterLog(_todayStr);
    state = log;
  }

  Future<void> _persist(WaterLogEntity log) async {
    await ref.read(waterRepositoryProvider).saveWaterLog(log);
  }

  Future<void> addGlass() async {
    final updated = state.copyWith(consumedMl: state.consumedMl + state.glassSizeMl);
    state = updated;
    await _persist(updated);
  }

  Future<void> removeGlass() async {
    final newConsumed = (state.consumedMl - state.glassSizeMl).clamp(0, 99999);
    final updated = state.copyWith(consumedMl: newConsumed);
    state = updated;
    await _persist(updated);
  }

  Future<void> setGoalMl(int newGoalMl) async {
    final updated = state.copyWith(goalMl: newGoalMl);
    state = updated;
    await _persist(updated);
  }

  Future<void> resetToday() async {
    final updated = state.copyWith(consumedMl: 0);
    state = updated;
    await _persist(updated);
  }
}

final waterProvider = NotifierProvider<WaterNotifier, WaterLogEntity>(() {
  return WaterNotifier();
});
