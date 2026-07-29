import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'app_provider.dart';
import 'settings_provider.dart';
import 'service_providers.dart';
import 'stats_provider.dart';
import '../../core/config/app_config.dart';

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

  String get nextReminderLabel {
    // Minimum kalan süreyi bul (timeElapsed'e göre)
    // timeElapsed[key] = kaç dakika geçti — interval'dan çıkararak kalan süreyi bul
    return '-'; // hesaplama providers'da yapılacak
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
            _showSystemNotification(key, settings.reminderIntervals);
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

  Future<void> _showSystemNotification(
    String id,
    Map<String, int> intervals,
  ) async {
    final notificationService = ref.read(notificationServiceProvider);

    String title = 'Hatırlatıcı';
    String body = 'Kısa bir mola verin!';

    switch (id) {
      case 'eyeRest':
        title = 'Göz Dinlendirme';
        body = '20 saniye boyunca uzağa bakın ve gözlerinizi dinlendirin.';
        break;
      case 'posture':
        title = 'Duruş Kontrolü';
        body = 'Sırtınızı dik tutun ve omuzlarınızı rahatlatın.';
        break;
      case 'water':
        title = 'Su İçme';
        body = 'Vücudunuzun hidrate kalması için bir bardak su için.';
        break;
      case 'stretch':
        title = 'Esneme';
        body = 'Hafif esneme hareketleri yaparak kas gerginliğini azaltın.';
        break;
      case 'walk':
        title = 'Yürüyüş';
        body = 'Biraz ayağa kalkın ve 5 dakika yürüyüş yapın.';
        break;
    }

    await notificationService.showNotification(
      id: id.hashCode,
      title: title,
      body: body,
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


// ── TrayNotifier ──────────────────────────────────────────────────────────────

class TrayNotifier extends Notifier<void> implements TrayListener, WindowListener {
  @override
  void build() {
    final trayService = ref.read(trayServiceProvider);
    final windowService = ref.read(windowServiceProvider);

    trayService.addListener(this);
    windowService.addListener(this);

    ref.onDispose(() {
      trayService.removeListener(this);
      windowService.removeListener(this);
      trayService.destroy();
    });
  }

  Future<void> updateTrayMenu(bool isRunning) async {
    final items = [
      MenuItem(key: 'toggle_running', label: isRunning ? 'Durdur' : 'Başlat'),
      MenuItem.separator(),
      MenuItem(key: 'show_window', label: 'Pencereyi Göster'),
      MenuItem(key: 'hide_window', label: 'Pencereyi Gizle'),
      MenuItem.separator(),
      MenuItem(key: 'settings', label: 'Ayarlar'),
      MenuItem.separator(),
      MenuItem(key: 'quit', label: 'Uygulamayı Kapat'),
    ];
    await ref.read(trayServiceProvider).setContextMenu(Menu(items: items));
    await ref.read(trayServiceProvider).setToolTip(
      'Ergonomik Asistan — ${isRunning ? "Çalışıyor" : "Durduruldu"}',
    );
  }

  Future<void> toggleWindow() async {
    final windowService = ref.read(windowServiceProvider);
    final isVisible = await windowService.isVisible();
    if (isVisible) {
      await windowService.hide();
    } else {
      await windowService.show();
      await windowManager.focus();
    }
  }

  // ── TrayListener ──
  @override
  void onTrayIconMouseDown() {
    if (Platform.isWindows) {
      toggleWindow();
    } else {
      ref.read(trayServiceProvider).popUpContextMenu();
    }
  }

  @override
  void onTrayIconRightMouseDown() {
    if (Platform.isWindows) {
      ref.read(trayServiceProvider).popUpContextMenu();
    } else {
      toggleWindow();
    }
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    final windowService = ref.read(windowServiceProvider);
    switch (menuItem.key) {
      case 'toggle_running':
        final current = ref.read(appProvider).isRunning;
        ref.read(appProvider.notifier).setRunning(!current);
        updateTrayMenu(!current);
        break;
      case 'show_window':
        windowService.show();
        windowManager.focus();
        break;
      case 'hide_window':
        windowService.hide();
        break;
      case 'settings':
        windowService.show();
        windowManager.focus();
        ref.read(appProvider.notifier).requestOpenSettings();
        break;
      case 'quit':
        ref.read(appProvider.notifier).requestExit();
        break;
    }
  }

  // ── WindowListener ──
  @override
  void onWindowClose() {
    ref.read(windowServiceProvider).hide();
    final isRunning = ref.read(appProvider).isRunning;
    updateTrayMenu(isRunning);
  }

  @override
  void onWindowEvent(String eventName) {
    if (Platform.isMacOS && eventName == 'minimize') {
      ref.read(windowServiceProvider).hide();
    }
  }

  @override void onWindowBlur() {}
  @override void onWindowFocus() {}
  @override void onWindowMaximize() {}
  @override void onWindowUnmaximize() {}
  @override void onWindowMinimize() {}
  @override void onWindowMove() {}
  @override void onWindowMoved() {}
  @override void onWindowResize() {}
  @override void onWindowResized() {}
  @override void onWindowRestore() {}
  @override void onWindowEnterFullScreen() {}
  @override void onWindowLeaveFullScreen() {}
  @override void onWindowDocked() {}
  @override void onWindowUndocked() {}
  @override void onTrayIconMouseUp() {}
  @override void onTrayIconRightMouseUp() {}
}

final trayProvider = NotifierProvider<TrayNotifier, void>(() => TrayNotifier());
