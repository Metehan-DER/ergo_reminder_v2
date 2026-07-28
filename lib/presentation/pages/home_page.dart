import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_provider.dart';
import '../providers/timer_provider.dart';
import '../providers/settings_provider.dart';
import 'settings_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with TickerProviderStateMixin {
  late AppLocalizations _l10n;
  Locale? _lastLocale;

  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  List<Color> _backgroundColors = [
    Colors.deepPurple,
    const Color(0xFFF3E5F5)
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context);
    final currentLocale = Localizations.localeOf(context);
    if (_lastLocale != currentLocale) {
      _lastLocale = currentLocale;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _changeColors() {
    setState(() {
      _backgroundColors = [
        Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
        Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
      ];
    });
  }

  void _openSettings() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
  }

  String _getGreeting(String userName, String selectedTitle) {
    final hour = DateTime.now().hour;
    String timeGreeting;
    if (hour >= 5 && hour < 12) timeGreeting = _l10n.greetingMorning;
    else if (hour >= 12 && hour < 18) timeGreeting = _l10n.greetingAfternoon;
    else if (hour >= 18 && hour < 22) timeGreeting = _l10n.greetingEvening;
    else timeGreeting = _l10n.greetingNight;
    String titlePart = (selectedTitle != _l10n.noTitleOption && selectedTitle != "Yok") ? "$selectedTitle " : "";
    return "$timeGreeting, $titlePart$userName \\n${_l10n.statusHealthyContinued}";
  }

  void _showReminderDialog(String id, String title, String body, Function(String) onSnooze, Function(String) onDone) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () {
              onSnooze(id);
              Navigator.pop(ctx);
            },
            child: Text(_l10n.snoozeButtonLabel),
          ),
          ElevatedButton(
            onPressed: () {
              onDone(id);
              Navigator.pop(ctx);
            },
            child: Text(_l10n.dialogOk),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    
    
    ref.listen(timerProvider.select((s) => s.dialogQueue), (prev, next) {
      if (next.isNotEmpty && (prev == null || prev.isEmpty || prev.first != next.first)) {
          final id = next.first;
          _showReminderDialog(
             id, 
             _l10n.reminderDefault, 
             _l10n.msgDefault, 
             (id) => ref.read(timerProvider.notifier).snoozeReminder(id),
             (id) => ref.read(timerProvider.notifier).removeFirstFromQueue()
          );
      }
    });

    return settingsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Hata: $e'))),
      data: (settings) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Ergonomik Asistan', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
            actions: [
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
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _backgroundColors,
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
                      _buildMainStatusCard(settings.userName, settings.userTitle),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildMainStatusCard(String userName, String selectedTitle) {
    final isRunning = ref.watch(appProvider).isRunning;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          ScaleTransition(
            scale: isRunning ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isRunning ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isRunning ? Icons.shield : Icons.shield_outlined,
                size: 64,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _getGreeting(userName, selectedTitle),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            isRunning ? _l10n.trayRunning : _l10n.trayStopped,
            style: TextStyle(
              fontSize: 16,
              color: isRunning ? Colors.greenAccent : Colors.orangeAccent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final isRunning = ref.watch(appProvider).isRunning;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (!isRunning)
          ElevatedButton.icon(
            onPressed: () => ref.read(appProvider.notifier).setRunning(true),
            icon: const Icon(Icons.play_arrow),
            label: Text(_l10n.start),
          )
        else
          ElevatedButton.icon(
            onPressed: () => ref.read(appProvider.notifier).setRunning(false),
            icon: const Icon(Icons.pause),
            label: Text(_l10n.stop),
          ),
      ],
    );
  }
}
