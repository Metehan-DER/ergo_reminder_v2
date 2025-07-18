import 'package:ergo_reminder_v2/credits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'dart:async';
import 'dart:io';

import 'SettingsPage.dart';
import 'config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WindowListener {
  final SystemTray _systemTray = SystemTray();
  final AppWindow _appWindow = AppWindow();
  Timer? _mainTimer;
  int _workMinutes = 0;
  late SharedPreferences _prefs;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Ayarlar
  Map<String, bool> _enabledReminders = {
    'eyeRest': true,
    'posture': true,
    'water': true,
    'stretch': true,
    'walk': true,
  };

  Map<String, int> _reminderIntervals = AppConfig.defaultIntervals;

  TimeOfDay _silentStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _silentEnd = const TimeOfDay(hour: 8, minute: 0);
  bool _autoStart = false;
  bool _isRunning = true;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _initApp();
  }

  Future<void> _initApp() async {
    await _initWindow();
    await _initSystemTray();
    await _initNotifications();
    await _loadSettings();
    _startTracking();
  }

  Future<void> _initWindow() async {
    // Pencere ayarları
    await windowManager.setPreventClose(true);
    await windowManager.setSkipTaskbar(false);
    await windowManager.setTitle('Ergonomik Asistan');

    // Minimum boyut ayarla
    await windowManager.setMinimumSize(const Size(500, 850));

    // macOS için ek ayar kaldırıldı - closable false yapınca
    // macOS'ta sistem tepsisi düzgün çalışmıyor
  }

  Future<void> _initSystemTray() async {
    // Platform'a göre icon path ayarla
    String path;
    if (Platform.isWindows) {
      path = 'assets/logo.ico'; // Windows için .ico formatı önerilir
    } else if (Platform.isMacOS) {
      path = 'assets/logo.png'; // macOS için .png
    } else {
      path = 'assets/logo.png';
    }

    // Sistem tepsisi başlat
    await _systemTray.initSystemTray(
      title: "Ergonomik Asistan",
      iconPath: path,
      toolTip: "Ergonomik Asistan - ${_isRunning ? 'Çalışıyor' : 'Durduruldu'}",
    );

    // Menü oluştur
    final Menu menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(
        label: _isRunning ? 'Durdur' : 'Başlat',
        onClicked: (menuItem) {
          setState(() {
            _isRunning = !_isRunning;
          });
          _updateSystemTrayTooltip();
          // Menüyü yeniden oluştur
          _rebuildSystemTrayMenu();
        },
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Pencereyi Göster',
        onClicked: (menuItem) async {
          await windowManager.show();
          await windowManager.focus();
        },
      ),
      MenuItemLabel(
        label: 'Pencereyi Gizle',
        onClicked: (menuItem) async {
          await windowManager.hide();
        },
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Ayarlar',
        onClicked: (menuItem) async {
          await windowManager.show();
          await windowManager.focus();
          _openSettings();
        },
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Uygulamayı Kapat',
        onClicked: (menuItem) {
          _confirmExit();
        },
      ),
    ]);

    await _systemTray.setContextMenu(menu);

    // Sistem tepsisi click olayları
    _systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick) {
        Platform.isWindows ? _toggleWindow() : _systemTray.popUpContextMenu();
      } else if (eventName == kSystemTrayEventRightClick) {
        Platform.isWindows ? _systemTray.popUpContextMenu() : _toggleWindow();
      }
    });
  }

  Future<void> _rebuildSystemTrayMenu() async {
    final Menu menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(
        label: _isRunning ? 'Durdur' : 'Başlat',
        onClicked: (menuItem) {
          setState(() {
            _isRunning = !_isRunning;
          });
          _updateSystemTrayTooltip();
          _rebuildSystemTrayMenu();
        },
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Pencereyi Göster',
        onClicked: (menuItem) async {
          await windowManager.show();
          await windowManager.focus();
        },
      ),
      MenuItemLabel(
        label: 'Pencereyi Gizle',
        onClicked: (menuItem) async {
          await windowManager.hide();
        },
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Ayarlar',
        onClicked: (menuItem) async {
          await windowManager.show();
          await windowManager.focus();
          _openSettings();
        },
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Uygulamayı Kapat',
        onClicked: (menuItem) {
          _confirmExit();
        },
      ),
    ]);

    await _systemTray.setContextMenu(menu);
  }

  Future<void> _toggleWindow() async {
    bool isVisible = await windowManager.isVisible();
    if (isVisible) {
      await windowManager.hide();
    } else {
      await windowManager.show();
      await windowManager.focus();
    }
  }

  Future<void> _updateSystemTrayTooltip() async {
    await _systemTray.setToolTip(
      "Ergonomik Asistan - ${_isRunning ? 'Çalışıyor' : 'Durduruldu'}",
    );
  }

  Future<void> _confirmExit() async {
    await windowManager.show();
    await windowManager.focus();

    bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uygulamayı Kapat'),
        content: const Text(
          'Ergonomik Asistan\'ı tamamen kapatmak istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      await _systemTray.destroy();
      await windowManager.destroy();
      exit(0);
    }
  }

  Future<void> _initNotifications() async {
    const initializationSettingsWindows = WindowsInitializationSettings(
      appName: 'Ergonomik Asistan',
      appUserModelId: 'com.example.ergonomikasistan',
      guid: 'd3d6b4c7-5f6e-4c1e-b3a2-1a0b9c8d7e6f',
    );

    const initializationSettingsMacOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      windows: initializationSettingsWindows,
      macOS: initializationSettingsMacOS,
    );

    await _notifications.initialize(initializationSettings);
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();

    setState(() {
      // Hatırlatma ayarları
      _enabledReminders['eyeRest'] = _prefs.getBool('reminder_eyeRest') ?? true;
      _enabledReminders['posture'] = _prefs.getBool('reminder_posture') ?? true;
      _enabledReminders['water'] = _prefs.getBool('reminder_water') ?? true;
      _enabledReminders['stretch'] = _prefs.getBool('reminder_stretch') ?? true;
      _enabledReminders['walk'] = _prefs.getBool('reminder_walk') ?? true;

      // Aralıklar
      _reminderIntervals['eyeRest'] = _prefs.getInt('interval_eyeRest') ?? 40;
      _reminderIntervals['posture'] = _prefs.getInt('interval_posture') ?? 30;
      _reminderIntervals['water'] = _prefs.getInt('interval_water') ?? 60;
      _reminderIntervals['stretch'] = _prefs.getInt('interval_stretch') ?? 50;
      _reminderIntervals['walk'] = _prefs.getInt('interval_walk') ?? 120;

      // Sessiz saatler
      int startHour = _prefs.getInt('silent_start_hour') ?? 22;
      int startMinute = _prefs.getInt('silent_start_minute') ?? 0;
      int endHour = _prefs.getInt('silent_end_hour') ?? 8;
      int endMinute = _prefs.getInt('silent_end_minute') ?? 0;

      _silentStart = TimeOfDay(hour: startHour, minute: startMinute);
      _silentEnd = TimeOfDay(hour: endHour, minute: endMinute);

      // Otomatik başlatma - Hata kontrolü ile
      _autoStart = _prefs.getBool('auto_start') ?? false;
      if (_autoStart) {
        try {
          launchAtStartup.enable();
        } catch (e) {
          print('Launch at startup enable failed: $e');
        }
      } else {
        try {
          launchAtStartup.disable();
        } catch (e) {
          print('Launch at startup disable failed: $e');
        }
      }
    });
  }

  void _startTracking() {
    _mainTimer = Timer.periodic(AppConfig.timerInterval, (timer) {
      if (!_isRunning) return;

      setState(() {
        _workMinutes++;
      });

      if (!_isInSilentHours()) {
        _checkReminders();
      }
    });
  }

  bool _isInSilentHours() {
    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = _silentStart.hour * 60 + _silentStart.minute;
    final endMinutes = _silentEnd.hour * 60 + _silentEnd.minute;

    if (startMinutes > endMinutes) {
      // Gece yarısını geçiyor
      return nowMinutes >= startMinutes || nowMinutes < endMinutes;
    } else {
      return nowMinutes >= startMinutes && nowMinutes < endMinutes;
    }
  }

  void _checkReminders() {
    if (_enabledReminders['eyeRest']! &&
        _workMinutes % _reminderIntervals['eyeRest']! == 0) {
      _showNotification(
        'Göz Dinlendirme Zamanı! 👁️',
        '20-20-20 kuralı: 20 saniye boyunca 6 metre uzaklığa bakın. Gözlerinizin dinlenmesi için çok önemli!',
      );
    }

    if (_enabledReminders['posture']! &&
        _workMinutes % _reminderIntervals['posture']! == 0) {
      _showNotification(
        'Duruş Kontrolü! 🧘‍♂️',
        'Sırtınızı dik tutun, ayaklarınızı yerde düz konumlandırın. Omuzlarınızı rahatlatın ve boyun pozisyonunuzu kontrol edin.',
      );
    }

    if (_enabledReminders['water']! &&
        _workMinutes % _reminderIntervals['water']! == 0) {
      _showNotification(
        'Su İçme Zamanı! 💧',
        'Bir bardak su (yaklaşık 250 ml) için mükemmel zaman! Vücudunuzun hidrate kalması konsantrasyon ve sağlığınız için kritik.',
      );
    }

    if (_enabledReminders['stretch']! &&
        _workMinutes % _reminderIntervals['stretch']! == 0) {
      _showNotification(
        'Esneme Vakti! 🤸‍♂️',
        'Boyun, omuz ve sırt esnetme hareketleri yapın. Kas gerginliğini azaltmak ve kan dolaşımını artırmak için önemli.',
      );
    }

    if (_enabledReminders['walk']! &&
        _workMinutes % _reminderIntervals['walk']! == 0) {
      _showNotification(
        'Yürüyüş Molası! 🚶‍♂️',
        '5-10 dakika ayağa kalkıp yürüyün. Kan dolaşımınızı canlandırın ve kaslarınızı aktif tutun.',
      );
    }
  }

  Future<void> _showNotification(String title, String body) async {
    const windowsDetails = WindowsNotificationDetails();

    const macOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBanner: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      windows: windowsDetails,
      macOS: macOSDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> _saveSettings() async {
    // Hatırlatma ayarları
    await _prefs.setBool('reminder_eyeRest', _enabledReminders['eyeRest']!);
    await _prefs.setBool('reminder_posture', _enabledReminders['posture']!);
    await _prefs.setBool('reminder_water', _enabledReminders['water']!);
    await _prefs.setBool('reminder_stretch', _enabledReminders['stretch']!);
    await _prefs.setBool('reminder_walk', _enabledReminders['walk']!);

    // Aralıklar
    await _prefs.setInt('interval_eyeRest', _reminderIntervals['eyeRest']!);
    await _prefs.setInt('interval_posture', _reminderIntervals['posture']!);
    await _prefs.setInt('interval_water', _reminderIntervals['water']!);
    await _prefs.setInt('interval_stretch', _reminderIntervals['stretch']!);
    await _prefs.setInt('interval_walk', _reminderIntervals['walk']!);

    // Sessiz saatler
    await _prefs.setInt('silent_start_hour', _silentStart.hour);
    await _prefs.setInt('silent_start_minute', _silentStart.minute);
    await _prefs.setInt('silent_end_hour', _silentEnd.hour);
    await _prefs.setInt('silent_end_minute', _silentEnd.minute);

    // Otomatik başlatma - Hata kontrolü ile
    await _prefs.setBool('auto_start', _autoStart);
    if (_autoStart) {
      try {
        await launchAtStartup.enable();
      } catch (e) {
        print('Launch at startup enable failed: $e');
      }
    } else {
      try {
        await launchAtStartup.disable();
      } catch (e) {
        print('Launch at startup disable failed: $e');
      }
    }
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          enabledReminders: _enabledReminders,
          reminderIntervals: _reminderIntervals,
          silentStart: _silentStart,
          silentEnd: _silentEnd,
          autoStart: _autoStart,
          onSettingsChanged: (enabled, intervals, start, end, autoStart) {
            setState(() {
              _enabledReminders = enabled;
              _reminderIntervals = intervals;
              _silentStart = start;
              _silentEnd = end;
              _autoStart = autoStart;
            });
            _saveSettings();
          },
        ),
      ),
    );
  }

  // Pencere kapatma olayını yönetir
  @override
  Future<void> onWindowClose() async {
    // Pencereyi kapatma yerine gizle
    await windowManager.hide();

    // Sistem tepsisi tooltip'ini güncelle
    _updateSystemTrayTooltip();
  }

  @override
  Future<void> onWindowCloseRequested() async {
    // macOS için ek güvenlik
    await windowManager.hide();
  }

  @override
  void dispose() {
    _mainTimer?.cancel();
    windowManager.removeListener(this);
    _systemTray.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ergonomik Asistan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.minimize),
            onPressed: () async {
              await windowManager.hide();
            },
            tooltip: 'Sistem tepsisine gizle',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF3E5F5)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Ana durum kartı
                Card(
                  elevation: 8,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isRunning
                                ? Colors.deepPurple.shade100
                                : Colors.grey.shade200,
                          ),
                          child: Icon(
                            _isRunning ? Icons.timer : Icons.timer_off,
                            size: 80,
                            color: _isRunning ? Colors.deepPurple : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _isRunning ? 'Takip Aktif' : 'Takip Durduruldu',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: _isRunning
                                    ? Colors.deepPurple
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppConfig.isTestMode
                              ? 'Test Modu: $_workMinutes ${AppConfig.timeUnit}'
                              : 'Çalışma Süresi: ${_workMinutes ~/ 60} saat ${_workMinutes % 60} dakika',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                ),

                // Kontrol butonu
                Container(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isRunning = !_isRunning;
                      });
                      _updateSystemTrayTooltip();
                    },
                    icon: Icon(
                      _isRunning ? Icons.pause : Icons.play_arrow,
                      size: 28,
                    ),
                    label: Text(
                      _isRunning ? 'Durdur' : 'Başlat',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRunning
                          ? Colors.orange
                          : Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),

                // Durum bilgileri
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusCard(
                        'Aktif Hatırlatıcılar',
                        _enabledReminders.values
                            .where((enabled) => enabled)
                            .length
                            .toString(),
                        Icons.notifications_active,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildStatusCard(
                        'Sonraki Hatırlatıcı',
                        _getNextReminderTime(),
                        Icons.schedule,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),

                // Sistem tepsisi bilgi kartı
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade600),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Uygulama sistem tepsisinde çalışmaya devam eder. Tamamen kapatmak için sistem tepsisindeki menüyü kullanın.',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Sessiz saatler uyarısı
                if (_isInSilentHours())
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.deepPurple.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.nightlight_round, color: Colors.deepPurple),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Sessiz saatler aktif - Hatırlatıcılar susturuldu',
                            style: TextStyle(
                              color: Colors.deepPurple.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getNextReminderTime() {
    if (!_isRunning) return '-';

    int minTime = 999;
    for (var entry in _enabledReminders.entries) {
      if (entry.value) {
        int timeLeft =
            _reminderIntervals[entry.key]! -
            (_workMinutes % _reminderIntervals[entry.key]!);
        if (timeLeft < minTime) {
          minTime = timeLeft;
        }
      }
    }

    return minTime == 999 ? '-' : '$minTime dk';
  }
}
