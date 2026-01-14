import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tray_manager/tray_manager.dart';
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

class _HomePageState extends State<HomePage>
    with WindowListener, TrayListener, TickerProviderStateMixin {
  Timer? _mainTimer;
  int _workMinutes = 0;
  late SharedPreferences _prefs;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Animasyon controller'ları
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

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

  // _HomePageState içinde en üste ekle
  String _userName = "";
  String _selectedTitle = "Yok";
  String _gender = "Belirtilmemiş";

  // Hatırlatıcı ikon ve renk map'leri
  final Map<String, IconData> _reminderIcons = {
    'eyeRest': Icons.visibility,
    'posture': Icons.accessibility_new,
    'water': Icons.water_drop,
    'stretch': Icons.self_improvement,
    'walk': Icons.directions_walk,
  };

  final Map<String, Color> _reminderColors = {
    'eyeRest': Colors.blue,
    'posture': Colors.purple,
    'water': Colors.cyan,
    'stretch': Colors.orange,
    'walk': Colors.green,
  };

  final Map<String, String> _reminderNames = {
    'eyeRest': 'Göz Dinlendirme',
    'posture': 'Duruş Kontrolü',
    'water': 'Su İçme',
    'stretch': 'Esneme',
    'walk': 'Yürüyüş',
  };

  @override
  void initState() {
    super.initState();

    // Animasyonları başlat
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _fadeController.forward();

    windowManager.addListener(this);
    trayManager.addListener(this);
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
    await windowManager.setPreventClose(true);
    await windowManager.setSkipTaskbar(false);
    await windowManager.setTitle('Ergonomik Asistan');
    await windowManager.setMinimumSize(const Size(500, 850));
  }

  Future<void> _initSystemTray() async {
    try {
      if (Platform.isWindows) {
        _setWindowsIcon();
      } else if (Platform.isMacOS) {
        try {
          await trayManager.setIcon(
            'assets/icons/app_logo.png',
            isTemplate: true,
          );
          debugPrint('macOS: Template icon set successfully');
        } catch (e) {
          debugPrint('macOS: Icon failed: $e');
        }
      }

      await trayManager.setToolTip(
        'Ergonomik Asistan - ${_isRunning ? 'Çalışıyor' : 'Durduruldu'}',
      );

      await _updateTrayMenu();

      debugPrint('Tray manager initialized successfully');
    } catch (e) {
      debugPrint('Tray manager initialization error: $e');
    }
  }

  Future<void> _setWindowsIcon() async {
    try {
      await trayManager.setIcon('assets/icons/app_logo.ico');
      debugPrint('Windows: Custom icon set successfully');
    } catch (e) {
      debugPrint('Windows: Custom icon failed, using fallback: $e');
      try {
        await trayManager.setIcon('assets/icons/app_logo.png');
      } catch (e) {
        debugPrint('Windows: Fallback icon also failed: $e');
        await trayManager.setIcon('EH');
      }
    }
  }

  Future<void> _updateTrayMenu() async {
    List<MenuItem> items = [
      MenuItem(key: 'toggle_running', label: _isRunning ? 'Durdur' : 'Başlat'),
      MenuItem.separator(),
      MenuItem(key: 'show_window', label: 'Pencereyi Göster'),
      MenuItem(key: 'hide_window', label: 'Pencereyi Gizle'),
      MenuItem.separator(),
      MenuItem(key: 'settings', label: 'Ayarlar'),
      MenuItem.separator(),
      MenuItem(key: 'quit', label: 'Uygulamayı Kapat'),
    ];

    await trayManager.setContextMenu(Menu(items: items));
  }

  @override
  void onTrayIconMouseDown() {
    if (Platform.isWindows) {
      _toggleWindow();
    } else {
      trayManager.popUpContextMenu();
    }
  }

  @override
  void onTrayIconRightMouseDown() {
    if (Platform.isWindows) {
      trayManager.popUpContextMenu();
    } else {
      _toggleWindow();
    }
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'toggle_running':
        setState(() {
          _isRunning = !_isRunning;
        });
        _updateSystemTrayTooltip();
        _updateTrayMenu();
        break;
      case 'show_window':
        if (Platform.isMacOS) {
          windowManager.setSkipTaskbar(false);
        }
        windowManager.show();
        windowManager.focus();
        break;
      case 'hide_window':
        windowManager.hide();
        if (Platform.isMacOS) {
          windowManager.setSkipTaskbar(true);
        }
        break;
      case 'settings':
        if (Platform.isMacOS) {
          windowManager.setSkipTaskbar(false);
        }
        windowManager.show();
        windowManager.focus();
        _openSettings();
        break;
      case 'quit':
        _confirmExit();
        break;
    }
  }

  Future<void> _toggleWindow() async {
    bool isVisible = await windowManager.isVisible();
    if (isVisible) {
      await windowManager.hide();
      if (Platform.isMacOS) {
        await windowManager.setSkipTaskbar(true);
      }
    } else {
      if (Platform.isMacOS) {
        await windowManager.setSkipTaskbar(false);
      }
      await windowManager.show();
      await windowManager.focus();
    }
  }

  Future<void> _updateSystemTrayTooltip() async {
    await trayManager.setToolTip(
      "Ergonomik Asistan - ${_isRunning ? 'Çalışıyor' : 'Durduruldu'}",
    );
  }

  Future<void> _confirmExit() async {
    await windowManager.show();
    await windowManager.focus();

    bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
      await trayManager.destroy();
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
      _enabledReminders['eyeRest'] = _prefs.getBool('reminder_eyeRest') ?? true;
      _enabledReminders['posture'] = _prefs.getBool('reminder_posture') ?? true;
      _enabledReminders['water'] = _prefs.getBool('reminder_water') ?? true;
      _enabledReminders['stretch'] = _prefs.getBool('reminder_stretch') ?? true;
      _enabledReminders['walk'] = _prefs.getBool('reminder_walk') ?? true;

      _reminderIntervals['eyeRest'] = _prefs.getInt('interval_eyeRest') ?? 40;
      _reminderIntervals['posture'] = _prefs.getInt('interval_posture') ?? 30;
      _reminderIntervals['water'] = _prefs.getInt('interval_water') ?? 60;
      _reminderIntervals['stretch'] = _prefs.getInt('interval_stretch') ?? 50;
      _reminderIntervals['walk'] = _prefs.getInt('interval_walk') ?? 120;

      _userName = _prefs.getString('user_name') ?? "";
      _selectedTitle = _prefs.getString('user_title') ?? "Yok";
      _gender = _prefs.getString('user_gender') ?? "Belirtilmemiş";

      int startHour = _prefs.getInt('silent_start_hour') ?? 22;
      int startMinute = _prefs.getInt('silent_start_minute') ?? 0;
      int endHour = _prefs.getInt('silent_end_hour') ?? 8;
      int endMinute = _prefs.getInt('silent_end_minute') ?? 0;

      _silentStart = TimeOfDay(hour: startHour, minute: startMinute);
      _silentEnd = TimeOfDay(hour: endHour, minute: endMinute);

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
      return nowMinutes >= startMinutes || nowMinutes < endMinutes;
    } else {
      return nowMinutes >= startMinutes && nowMinutes < endMinutes;
    }
  }

  void _checkReminders() {
    // Aynı anda birden fazla hatırlatıcı tetiklenebileceği için bir liste üzerinden gidelim
    final List<String> triggeredReminders = [];

    _enabledReminders.forEach((key, enabled) {
      if (enabled) {
        int interval = _reminderIntervals[key]!;
        // Eğer çalışma süresi, belirlenen aralığın tam katı ise tetikle
        if (_workMinutes > 0 && _workMinutes % interval == 0) {
          triggeredReminders.add(key);
        }
      }
    });

    // Eğer tetiklenen hatırlatıcılar varsa, her biri için bildirim ve görsel uyarı yap
    for (String key in triggeredReminders) {
      String title = _reminderNames[key] ?? 'Hatırlatıcı';
      String body = _getReminderMessage(key);
      Color color = _reminderColors[key] ?? Colors.deepPurple;
      IconData icon = _reminderIcons[key] ?? Icons.notifications;

      // 1. Standart sistem bildirimini gönder (Arka plan için)
      _showNotification(title, body);

      // 2. Pencereyi görsel olarak hazırla (Öne getir ve parlat)
      _triggerVisualAlert(color);

      // 3. Özel şık diyalogu göster
      _showCustomDialog(title, body, color, icon, key);
    }
  }

  // Hatırlatıcı türüne göre mesaj döndüren yardımcı metod
  String _getReminderMessage(String key) {
    switch (key) {
      case 'eyeRest':
        return '20 saniye boyunca uzağa bakın ve gözlerinizi dinlendirin.';
      case 'posture':
        return 'Sırtınızı dik tutun ve omuzlarınızı rahatlatın.';
      case 'water':
        return 'Vücudunuzun hidrate kalması için bir bardak su için.';
      case 'stretch':
        return 'Hafif esneme hareketleri yaparak kas gerginliğini azaltın.';
      case 'walk':
        return 'Biraz ayağa kalkın ve 5 dakika yürüyüş yapın.';
      default:
        return 'Sağlığınız için kısa bir mola verin.';
    }
  }

  Future<void> _triggerVisualAlert(Color color) async {
    // Pencereyi öne getir
    bool isVisible = await windowManager.isVisible();
    if (!isVisible) {
      await windowManager.show();
    }
    await windowManager.focus();

    // Pencereyi 3 saniyeliğine en üstte tut (kullanıcıyı tamamen engellememek için)
    await windowManager.setAlwaysOnTop(true);
    Future.delayed(const Duration(seconds: 3), () {
      windowManager.setAlwaysOnTop(false);
    });

    // Parlama animasyonunu başlat
    _pulseController.forward();
  }

  void _showCustomDialog(
    String title,
    String body,
    Color color,
    IconData icon,
    String key,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false, // Kullanıcı butonlardan birine basmalı
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: BorderSide(color: color.withOpacity(0.5), width: 2),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 15),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            body,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          actionsPadding: const EdgeInsets.all(15),
          actions: [
            // Erteleme Butonu
            TextButton(
              onPressed: () {
                // Mevcut süreyi 5 dakika geri çekerek 5 dk sonra tekrar tetiklenmesini sağlarız
                setState(() {
                  _workMinutes = _workMinutes - 5;
                });
                Navigator.pop(context);
              },
              child: const Text(
                '5 Dk Ertele',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            // Tamam Butonu
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Tamam, Yapıyorum'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomNotification(
    String title,
    String message,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.all(20),
      width: 350,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.5), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white54,
                        size: 18,
                      ),
                      onPressed: () {
                        /* Bildirimi kapat */
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Ertele",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {},
                      child: const Text("Tamam"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
    await _prefs.setString('user_name', _userName);
    await _prefs.setString('user_title', _selectedTitle);
    await _prefs.setString('user_gender', _gender);

    await _prefs.setBool('reminder_eyeRest', _enabledReminders['eyeRest']!);
    await _prefs.setBool('reminder_posture', _enabledReminders['posture']!);
    await _prefs.setBool('reminder_water', _enabledReminders['water']!);
    await _prefs.setBool('reminder_stretch', _enabledReminders['stretch']!);
    await _prefs.setBool('reminder_walk', _enabledReminders['walk']!);

    await _prefs.setInt('interval_eyeRest', _reminderIntervals['eyeRest']!);
    await _prefs.setInt('interval_posture', _reminderIntervals['posture']!);
    await _prefs.setInt('interval_water', _reminderIntervals['water']!);
    await _prefs.setInt('interval_stretch', _reminderIntervals['stretch']!);
    await _prefs.setInt('interval_walk', _reminderIntervals['walk']!);

    await _prefs.setInt('silent_start_hour', _silentStart.hour);
    await _prefs.setInt('silent_start_minute', _silentStart.minute);
    await _prefs.setInt('silent_end_hour', _silentEnd.hour);
    await _prefs.setInt('silent_end_minute', _silentEnd.minute);

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
          userName: _userName,
          selectedTitle: _selectedTitle,
          gender: _gender,
          onSettingsChanged:
              (enabled, intervals, start, end, autoStart, name, title, gender) {
                setState(() {
                  _enabledReminders = enabled;
                  _reminderIntervals = intervals;
                  _silentStart = start;
                  _silentEnd = end;
                  _autoStart = autoStart;
                  _userName = name;
                  _selectedTitle = title;
                  _gender = gender;
                });
                _saveSettings();
              },
        ),
      ),
    );
  }

  @override
  Future<void> onWindowClose() async {
    debugPrint('onWindowClose called');
    await windowManager.hide();
    if (Platform.isMacOS) {
      await windowManager.setSkipTaskbar(true);
    }
    await _updateSystemTrayTooltip();
  }

  @override
  void onWindowEvent(String eventName) {
    debugPrint('Window event: $eventName');
    if (Platform.isMacOS && eventName == 'minimize') {
      windowManager.hide();
    }
  }

  Future<void> onWindowCloseRequested() async {
    await windowManager.hide();
  }

  @override
  void dispose() {
    _mainTimer?.cancel();
    _pulseController.dispose();
    _fadeController.dispose();
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    trayManager.destroy();
    super.dispose();
  }

  // State içinde tanımla
  List<Color> _backgroundColors = [
    Colors.deepPurple.shade400,
    Colors.purple.shade300,
    Colors.pink.shade300,
  ];

  // Rastgele renk üretme fonksiyonu
  void _changeColors() {
    setState(() {
      _backgroundColors = [
        Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
        Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
        Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
      ];
    });
  }

  String _getPersonalizedGreeting() {
    if (_userName.isEmpty)
      return _isRunning ? 'Sağlığınız Korunuyor' : 'Takip Durduruldu';

    final hour = DateTime.now().hour;
    String timeGreeting;

    if (hour >= 5 && hour < 12) {
      timeGreeting = "Günaydın";
    } else if (hour >= 12 && hour < 18) {
      timeGreeting = "İyi Günler";
    } else if (hour >= 18 && hour < 22) {
      timeGreeting = "İyi Akşamlar";
    } else {
      timeGreeting = "İyi Geceler";
    }

    String titlePart = (_selectedTitle != "Yok") ? "$_selectedTitle " : "";

    return "$timeGreeting, $titlePart$_userName \nSağlığınız Korunuyor...";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Ergonomik Asistan',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.minimize, color: Colors.white),
            onPressed: () async {
              await windowManager.hide();
            },
            tooltip: 'Sistem tepsisine gizle',
          ),
          IconButton(
            icon: const Icon(Icons.palette_outlined, color: Colors.white),
            onPressed: _changeColors,
            tooltip: 'Renkleri Değiştir',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: _openSettings,
            tooltip: 'Ayarlar',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(seconds: 2), // Geçiş süresi
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _backgroundColors, // Değişkeni buraya bağladık
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Ana durum kartı - Glassmorphism efekti
                  _buildMainStatusCard(),

                  const SizedBox(height: 24),

                  // İstatistik kartları
                  _buildStatsRow(),

                  const SizedBox(height: 24),

                  // Hatırlatıcı kartları
                  _buildReminderCards(),

                  const SizedBox(height: 20),

                  // Sessiz saatler uyarısı
                  if (_isInSilentHours()) _buildSilentHoursCard(),

                  const SizedBox(height: 20),

                  // Bilgi kartı
                  _buildInfoCard(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainStatusCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                // Animasyonlu ikon
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _isRunning
                            ? [
                                Colors.white.withOpacity(0.4),
                                Colors.white.withOpacity(0.2),
                              ]
                            : [
                                Colors.grey.withOpacity(0.3),
                                Colors.grey.withOpacity(0.1),
                              ],
                      ),
                    ),
                    child: Icon(
                      _isRunning ? Icons.favorite : Icons.favorite_border,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Durum metni
                Text(
                  _getPersonalizedGreeting(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 12),

                // Süre bilgisi
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppConfig.isTestMode
                        ? 'Test: $_workMinutes ${AppConfig.timeUnit}'
                        : '${_workMinutes ~/ 60}sa ${_workMinutes % 60}dk',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Kontrol butonu
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isRunning = !_isRunning;
                      });
                      _updateSystemTrayTooltip();
                      _updateTrayMenu();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRunning
                          ? Colors.white
                          : Colors.deepPurple.shade600,
                      foregroundColor: _isRunning
                          ? Colors.deepPurple.shade600
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isRunning
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _isRunning ? 'Durdur' : 'Başlat',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildGlassCard(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${_enabledReminders.values.where((e) => e).length}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Aktif Hatırlatıcı',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildGlassCard(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.schedule,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _getNextReminderTime(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Sonraki Hatırlatıcı',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReminderCards() {
    final activeReminders = _enabledReminders.entries
        .where((entry) => entry.value)
        .toList();

    if (activeReminders.isEmpty) {
      return _buildGlassCard(
        child: const Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Henüz aktif hatırlatıcı yok.\nAyarlardan hatırlatıcıları aktifleştirin.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Aktif Hatırlatıcılar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...activeReminders.map((entry) {
          final key = entry.key;
          final interval = _reminderIntervals[key]!;
          final timeLeft = interval - (_workMinutes % interval);
          final progress = 1 - (timeLeft / interval);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildReminderCard(
              name: _reminderNames[key]!,
              icon: _reminderIcons[key]!,
              color: _reminderColors[key]!,
              timeLeft: timeLeft,
              progress: progress,
              interval: interval,
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildReminderCard({
    required String name,
    required IconData icon,
    required Color color,
    required int timeLeft,
    required double progress,
    required int interval,
  }) {
    return _buildGlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // İkon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),

          const SizedBox(width: 16),

          // Bilgi ve progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.6),
                            blurRadius: 8,
                            offset: const Offset(0, 0),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$timeLeft dk',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.7),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSilentHoursCard() {
    return _buildGlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.nightlight_round,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sessiz Saatler Aktif',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Hatırlatıcılar susturuldu',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return _buildGlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.white.withOpacity(0.9),
            size: 24,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Uygulama sistem tepsisinde çalışmaya devam eder. Tamamen kapatmak için sistem tepsisindeki menüyü kullanın.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.1),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
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

    return minTime == 999 ? '-' : '${minTime}dk';
  }
}
