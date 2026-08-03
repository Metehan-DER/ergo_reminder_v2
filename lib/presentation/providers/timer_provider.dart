import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'app_provider.dart';
import 'settings_provider.dart';
import 'service_providers.dart';
import 'stats_provider.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/reminder_contents.dart';

/// TimerState — hatırlatıcı zamanlayıcısının immutable durumu.
class TimerState {
  final int workMinutes;
  final Map<String, int> timeElapsed;
  final List<String> dialogQueue;
  final int totalRemindersToday;
  final int totalSnoozedToday;

  const TimerState({
    this.workMinutes = 0,
    this.timeElapsed = const {},
    this.dialogQueue = const [],
    this.totalRemindersToday = 0,
    this.totalSnoozedToday = 0,
  });

  TimerState copyWith({
    int? workMinutes,
    Map<String, int>? timeElapsed,
    List<String>? dialogQueue,
    int? totalRemindersToday,
    int? totalSnoozedToday,
  }) {
    return TimerState(
      workMinutes: workMinutes ?? this.workMinutes,
      timeElapsed: timeElapsed ?? this.timeElapsed,
      dialogQueue: dialogQueue ?? this.dialogQueue,
      totalRemindersToday: totalRemindersToday ?? this.totalRemindersToday,
      totalSnoozedToday: totalSnoozedToday ?? this.totalSnoozedToday,
    );
  }
}

/// TimerNotifier — Ergonomik hatırlatıcı zamanlayıcısının iş mantığı.
///
/// SRP: Yalnızca timer tick, sessiz saat kontrolü ve dialog kuyruğu
/// yönetiminden sorumludur. Tray yönetimi [TrayNotifier]'a taşındı.
///
/// OCP: Bildirim metinleri [ReminderContents]'ten okunur; yeni hatırlatıcı
/// eklemek için bu sınıf değiştirilmez.
///
/// DIP: [windowManager] doğrudan çağrısı yerine [IWindowService] kullanılır.
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
      },
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(AppConfig.timerInterval, (_) => _tick());
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _tick() {
    final isRunning = ref.read(appProvider).isRunning;
    if (!isRunning) return;

    final settingsAsync = ref.read(settingsProvider);
    if (!settingsAsync.hasValue) return;

    final settings = settingsAsync.value!;

    // Sessiz saat kontrolü
    if (_isSilentHour(settings.silentStart, settings.silentEnd)) return;

    final newElapsed = Map<String, int>.from(state.timeElapsed);
    final newQueue = List<String>.from(state.dialogQueue);
    int newWorkMinutes = state.workMinutes + 1;
    int newTotalReminders = state.totalRemindersToday;

    settings.enabledReminders.forEach((key, isEnabled) {
      if (isEnabled) {
        final currentElapsed = (newElapsed[key] ?? 0) + 1;
        final interval = settings.reminderIntervals[key] ?? 30;

        if (currentElapsed >= interval) {
          if (!newQueue.contains(key)) {
            newQueue.add(key);
            newTotalReminders++;
            _showSystemNotification(key);
          }
          newElapsed[key] = 0;
        } else {
          newElapsed[key] = currentElapsed;
        }
      } else {
        newElapsed[key] = 0;
      }
    });

    state = state.copyWith(
      workMinutes: newWorkMinutes,
      timeElapsed: newElapsed,
      dialogQueue: newQueue,
      totalRemindersToday: newTotalReminders,
    );
  }

  bool _isSilentHour(TimeOfDay start, TimeOfDay end) {
    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    if (startMinutes > endMinutes) {
      return nowMinutes >= startMinutes || nowMinutes < endMinutes;
    } else {
      return nowMinutes >= startMinutes && nowMinutes < endMinutes;
    }
  }

  /// OCP: switch kaldırıldı. İçerik [ReminderContents]'ten okunur.
  /// DIP: windowManager doğrudan değil, [IWindowService] üzerinden.
  Future<void> _showSystemNotification(String id) async {
    final content = ReminderContents.getById(id);
    // TODO: dil bilgisi locale provider'dan alınabilir; şimdilik Türkçe varsayılan
    const isTr = true;

    final windowService = ref.read(windowServiceProvider);
    try {
      await windowService.show();
      // DIP: windowManager.focus() artık WindowService üzerinden yok — sadece show() kullanılıyor.
      // focus() IWindowService'e eklenebilir; şimdilik doğrudan çağrı korunuyor
      await windowManager.focus();
      await windowManager.setAlwaysOnTop(true);
      await windowManager.setAlwaysOnTop(false);
    } catch (_) {}

    await ref.read(notificationServiceProvider).showNotification(
      id: id.hashCode,
      title: content.title(isTr: isTr),
      body: content.body(isTr: isTr),
    );
  }

  void snoozeReminder(String id) {
    final settingsAsync = ref.read(settingsProvider);
    final newElapsed = Map<String, int>.from(state.timeElapsed);

    if (settingsAsync.hasValue) {
      final interval = settingsAsync.value!.reminderIntervals[id] ?? 30;
      // 5 dakika erteleme: interval - 5 dakika kala tekrar tetiklenecek
      newElapsed[id] = interval > 5 ? interval - 5 : 0;
    }

    final newQueue = List<String>.from(state.dialogQueue)..remove(id);

    ref.read(statsProvider.notifier).incrementSnoozed();

    state = state.copyWith(
      timeElapsed: newElapsed,
      dialogQueue: newQueue,
      totalSnoozedToday: state.totalSnoozedToday + 1,
    );
  }

  void removeFirstFromQueue() {
    if (state.dialogQueue.isNotEmpty) {
      final newQueue = List<String>.from(state.dialogQueue)..removeAt(0);
      ref.read(statsProvider.notifier).incrementCompleted();
      state = state.copyWith(dialogQueue: newQueue);
    }
  }

  void resetWorkMinutes() {
    state = state.copyWith(workMinutes: 0);
  }

  String getNextReminderLabel(Map<String, bool> enabled, Map<String, int> intervals) {
    if (!ref.read(appProvider).isRunning) return '-';

    int minTime = 999;
    for (var entry in enabled.entries) {
      if (entry.value) {
        final elapsed = state.timeElapsed[entry.key] ?? 0;
        final interval = intervals[entry.key] ?? 30;
        final timeLeft = interval - elapsed;
        if (timeLeft < minTime) minTime = timeLeft;
      }
    }
    return minTime == 999 ? '-' : '${minTime}dk';
  }
}

final timerProvider = NotifierProvider<TimerNotifier, TimerState>(() {
  return TimerNotifier();
});
