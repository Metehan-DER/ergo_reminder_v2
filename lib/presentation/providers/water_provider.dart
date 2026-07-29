import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/water_entity.dart';
import 'service_providers.dart';

class WaterNotifier extends Notifier<WaterLogEntity> {
  String get _todayStr {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  WaterLogEntity build() {
    Future.microtask(() => loadTodayWaterLog());
    return WaterLogEntity(date: _todayStr, consumedMl: 0);
  }

  Future<void> loadTodayWaterLog() async {
    final storage = ref.read(storageServiceProvider);
    final key = 'water_log_$_todayStr';
    final jsonString = storage.getString(key, defaultValue: '');

    if (jsonString.isNotEmpty) {
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        state = WaterLogEntity.fromJson(jsonMap);
        return;
      } catch (_) {}
    }

    // Default if no log for today
    final defaultLog = WaterLogEntity(date: _todayStr, consumedMl: 0);
    state = defaultLog;
    await _saveWaterLog(defaultLog);
  }

  Future<void> _saveWaterLog(WaterLogEntity log) async {
    final storage = ref.read(storageServiceProvider);
    final key = 'water_log_$_todayStr';
    final jsonString = jsonEncode(log.toJson());
    await storage.setString(key, jsonString);
  }

  Future<void> addGlass() async {
    final newConsumed = state.consumedMl + state.glassSizeMl;
    final updated = state.copyWith(consumedMl: newConsumed);
    state = updated;
    await _saveWaterLog(updated);
  }

  Future<void> removeGlass() async {
    final newConsumed = (state.consumedMl - state.glassSizeMl).clamp(0, 99999);
    final updated = state.copyWith(consumedMl: newConsumed);
    state = updated;
    await _saveWaterLog(updated);
  }

  Future<void> setGoalMl(int newGoalMl) async {
    final updated = state.copyWith(goalMl: newGoalMl);
    state = updated;
    await _saveWaterLog(updated);
  }

  Future<void> resetToday() async {
    final updated = state.copyWith(consumedMl: 0);
    state = updated;
    await _saveWaterLog(updated);
  }
}

final waterProvider = NotifierProvider<WaterNotifier, WaterLogEntity>(() {
  return WaterNotifier();
});
