import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_provider.dart';
import 'settings_provider.dart';
import 'service_providers.dart';
import '../../domain/entities/settings_entity.dart';

class TimerState {
  final Map<String, int> timeElapsed;
  final List<String> dialogQueue;

  const TimerState({
    this.timeElapsed = const {},
    this.dialogQueue = const [],
  });

  TimerState copyWith({
    Map<String, int>? timeElapsed,
    List<String>? dialogQueue,
  }) {
    return TimerState(
      timeElapsed: timeElapsed ?? this.timeElapsed,
      dialogQueue: dialogQueue ?? this.dialogQueue,
    );
  }
}

class TimerNotifier extends Notifier<TimerState> {
  Timer? _timer;

  @override
  TimerState build() {
    ref.listen(appProvider.select((s) => s.isRunning), (prev, isRunning) {
      if (isRunning) {
        _startTimer();
      } else {
        _stopTimer();
      }
    });

    return const TimerState(
      timeElapsed: {
        'eyeRest': 0,
        'posture': 0,
        'water': 0,
        'stretch': 0,
        'walk': 0,
      }
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _tick();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _tick() {
    final settingsAsync = ref.read(settingsProvider);
    if (!settingsAsync.hasValue) return;
    
    final settings = settingsAsync.value!;
    
    if (_isSilentHour(settings.silentStart, settings.silentEnd)) {
      return;
    }

    final newElapsed = Map<String, int>.from(state.timeElapsed);
    final newQueue = List<String>.from(state.dialogQueue);
    bool stateChanged = false;

    settings.enabledReminders.forEach((key, isEnabled) {
      if (isEnabled) {
        final currentElapsed = (newElapsed[key] ?? 0) + 1;
        final interval = settings.reminderIntervals[key] ?? 30;

        if (currentElapsed >= interval) {
          if (!newQueue.contains(key)) {
            newQueue.add(key);
            _showSystemNotification(key);
          }
          newElapsed[key] = 0;
          stateChanged = true;
        } else {
          newElapsed[key] = currentElapsed;
          stateChanged = true;
        }
      } else {
        newElapsed[key] = 0;
      }
    });

    if (stateChanged) {
      state = state.copyWith(timeElapsed: newElapsed, dialogQueue: newQueue);
    }
  }

  bool _isSilentHour(TimeOfDay start, TimeOfDay end) {
    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    if (startMinutes <= endMinutes) {
      return nowMinutes >= startMinutes && nowMinutes < endMinutes;
    } else {
      return nowMinutes >= startMinutes || nowMinutes < endMinutes;
    }
  }

  Future<void> _showSystemNotification(String id) async {
    final notificationService = ref.read(notificationServiceProvider);
    
    String title = "Hatırlatıcı";
    String body = "Mola zamanı geldi!";

    // Simple mapping for notifications (l10n is tricky outside context, 
    // ideally we use the title from localized map, but hardcoding fallback here)
    if (id == 'eyeRest') { title = "Göz Dinlendirme"; body = "20 saniye uzağa bak."; }
    else if (id == 'water') { title = "Su İçme"; body = "Bir bardak su iç."; }
    else if (id == 'posture') { title = "Duruş Kontrolü"; body = "Dik otur."; }
    else if (id == 'stretch') { title = "Esneme"; body = "Biraz esne."; }
    else if (id == 'walk') { title = "Yürüyüş"; body = "Ayağa kalk ve yürü."; }

    await notificationService.showNotification(
      id: id.hashCode,
      title: title,
      body: body,
    );
  }

  void snoozeReminder(String id) {
    final newElapsed = Map<String, int>.from(state.timeElapsed);
    final settingsAsync = ref.read(settingsProvider);
    if (settingsAsync.hasValue) {
      final interval = settingsAsync.value!.reminderIntervals[id] ?? 30;
      // Snooze sets elapsed to interval - 5, so it rings in 5 mins
      newElapsed[id] = interval > 5 ? interval - 5 : 0;
      state = state.copyWith(timeElapsed: newElapsed);
    }
    removeFirstFromQueue();
  }

  void removeFirstFromQueue() {
    if (state.dialogQueue.isNotEmpty) {
      final newQueue = List<String>.from(state.dialogQueue)..removeAt(0);
      state = state.copyWith(dialogQueue: newQueue);
    }
  }

  void resetElapsed(String id) {
    final newElapsed = Map<String, int>.from(state.timeElapsed);
    newElapsed[id] = 0;
    state = state.copyWith(timeElapsed: newElapsed);
  }
}

final timerProvider = NotifierProvider<TimerNotifier, TimerState>(() {
  return TimerNotifier();
});
