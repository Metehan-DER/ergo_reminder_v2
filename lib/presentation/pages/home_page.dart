import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:window_manager/window_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/daily_quotes.dart';
import '../../core/utils/page_transitions.dart';

import '../providers/app_provider.dart';
import '../providers/service_providers.dart';
import '../providers/settings_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/timer_provider.dart';

import 'settings_page.dart';
import 'stats_page.dart';
import 'todo_page.dart';
import 'calendar_page.dart';
import '../widgets/todo_summary_card.dart';
import '../widgets/water_tracker_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AppLocalizations _l10n;
  bool _isDialogShowing = false;

  static const List<Color> _defaultColors = [
    Colors.deepPurple,
    Color(0xFFF3E5F5),
  ];
  List<Color> _backgroundColors = List.from(_defaultColors);

  final Map<String, IconData> _reminderIcons = {
    'eyeRest': Icons.visibility,
    'posture': Icons.accessibility_new,
    'water': Icons.local_drink,
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

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context);
  }

  void _openSettings() {
    Navigator.of(context).push(AppPageRoute(child: const SettingsPage()));
  }

  void _openStats() {
    Navigator.of(context).push(AppPageRoute(child: const StatsPage()));
  }

  void _openTodo() {
    Navigator.of(context).push(AppPageRoute(child: const TodoPage()));
  }

  void _changeColors() {
    final themeNotifier = ref.read(themeProvider.notifier);
    final themeState = ref.read(themeProvider);
    final nextIndex =
        (themeState.paletteIndex + 1) % ThemeState.palettes.length;
    themeNotifier.setPaletteIndex(nextIndex);
    setState(() {
      _backgroundColors = ref.read(themeProvider).activeGradientColors;
    });
  }

  bool _isInSilentHours(TimeOfDay start, TimeOfDay end) {
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

  String _getGreetingTitle(String userName, String userTitle) {
    final hour = DateTime.now().hour;
    String timeGreeting;
    if (hour >= 5 && hour < 12) {
      timeGreeting = _l10n.greetingMorning;
    } else if (hour >= 12 && hour < 18) {
      timeGreeting = _l10n.greetingAfternoon;
    } else if (hour >= 18 && hour < 22) {
      timeGreeting = _l10n.greetingEvening;
    } else {
      timeGreeting = _l10n.greetingNight;
    }
    if (userName.trim().isEmpty) return timeGreeting;
    final titlePart = (userTitle != 'Yok' && userTitle != _l10n.noTitleOption)
        ? '$userTitle '
        : '';
    return '$timeGreeting, $titlePart$userName';
  }

  String _getGreetingSubtitle(bool isRunning) {
    return isRunning ? _l10n.statusHealthyContinued : _l10n.statusStopped;
  }

  void _showReminderDialog({
    required String id,
    required String title,
    required String body,
    required Color color,
    required IconData icon,
  }) {
    if (_isDialogShowing) return;
    _isDialogShowing = true;

    try {
      ref.read(windowServiceProvider).show();
      windowManager.focus();
      windowManager.setAlwaysOnTop(true);
      windowManager.setAlwaysOnTop(false);
    } catch (_) {}

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          backgroundColor: Colors.deepPurple.shade900.withValues(alpha: 0.9),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
            TextButton(
              onPressed: () {
                _isDialogShowing = false;
                ref.read(timerProvider.notifier).snoozeReminder(id);
                Navigator.pop(ctx);
              },
              child: Text(
                _l10n.snoozeButtonLabel,
                style: const TextStyle(color: Colors.white60),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                _isDialogShowing = false;
                ref.read(timerProvider.notifier).removeFirstFromQueue();
                Navigator.pop(ctx);
              },
              child: Text(_l10n.dialogOk),
            ),
          ],
        ),
      ),
    ).then((_) {
      _isDialogShowing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final timerState = ref.watch(timerProvider);
    final appState = ref.watch(appProvider);
    final themeState = ref.watch(themeProvider);

    _backgroundColors = themeState.activeGradientColors;

    final isRunning = appState.isRunning;

    ref.listen<TimerState>(timerProvider, (previous, next) {
      if (next.dialogQueue.isNotEmpty && !_isDialogShowing) {
        final activeId = next.dialogQueue.first;
        final name = _getReminderName(activeId);
        final msg = _getReminderMessage(activeId);
        final icon = _reminderIcons[activeId] ?? Icons.notifications;
        final color = _reminderColors[activeId] ?? Colors.deepPurple;

        _showReminderDialog(
          id: activeId,
          title: name,
          body: msg,
          color: color,
          icon: icon,
        );
      }
    });

    return settingsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Text(
            'Hata: $err',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      data: (settings) {
        final inSilentHours = _isInSilentHours(
          settings.silentStart,
          settings.silentEnd,
        );

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.35,
                      child: Lottie.asset(
                        'assets/animations/bg_waves.json',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      'ErgoMate',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (isRunning ? Colors.greenAccent : Colors.white30)
                            .withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isRunning
                                  ? Colors.greenAccent
                                  : Colors.orangeAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isRunning ? _l10n.trayRunning : _l10n.trayStopped,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.minimize, color: Colors.white),
                onPressed: () async {
                  await ref.read(windowServiceProvider).hide();
                },
                tooltip: _l10n.tooltipHideToTray,
              ),
              IconButton(
                icon: const Icon(Icons.check_box_outlined, color: Colors.white),
                onPressed: _openTodo,
                tooltip: _l10n.todoTitle,
              ),
              IconButton(
                icon: const Icon(Icons.bar_chart_rounded, color: Colors.white),
                onPressed: _openStats,
                tooltip: _l10n.statisticsTitle,
              ),
              IconButton(
                icon: const Icon(Icons.palette_outlined, color: Colors.white),
                onPressed: _changeColors,
                tooltip: _l10n.changeColors,
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: _openSettings,
                tooltip: _l10n.settings,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: AnimatedContainer(
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            constraints: const BoxConstraints.expand(),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _backgroundColors,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 24,
                  left: 24,
                  top: 24,
                  bottom: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sol Panel (%55) — Ana Durum ve Aktif Hatırlatıcılar
                    Expanded(
                      flex: 55,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 24),
                          child: Column(
                            children: [
                              _buildMainStatusCard(
                                isRunning: isRunning,
                                workMinutes: timerState.workMinutes,
                                userName: settings.userName,
                                userTitle: settings.userTitle,
                              ),
                              const SizedBox(height: 16),
                              _buildReminderCards(
                                enabledReminders: settings.enabledReminders,
                                reminderIntervals: settings.reminderIntervals,
                                timerState: timerState,
                              ),
                              const SizedBox(height: 16),
                              const WaterTrackerCard(),
                              const SizedBox(height: 16),
                              const TodoSummaryCard(),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Sağ Panel (%45) — İstatistikler, Günün Notu, Sessiz Saatler ve Bilgi
                    Expanded(
                      flex: 45,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatsRow(
                              enabledReminders: settings.enabledReminders,
                              reminderIntervals: settings.reminderIntervals,
                              timerState: timerState,
                              isRunning: isRunning,
                            ),
                            const SizedBox(height: 16),
                            _buildDailyQuoteCard(context),
                            const SizedBox(height: 16),
                            if (inSilentHours) ...[
                              _buildSilentHoursCard(),
                              const SizedBox(height: 16),
                            ],
                            CalendarPage(),
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
      },
    );
  }

  // ── Widget Builders ──────────────────────────────────────────────────────────

  Widget _buildMainStatusCard({
    required bool isRunning,
    required int workMinutes,
    required String userName,
    required String userTitle,
  }) {
    final title = _getGreetingTitle(userName, userTitle);
    final subtitle = _getGreetingSubtitle(isRunning);

    return _buildGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isRunning
                        ? Colors.greenAccent.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.15),
                    boxShadow: [
                      BoxShadow(
                        color: (isRunning ? Colors.greenAccent : Colors.white)
                            .withValues(alpha: 0.25),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    isRunning
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 15,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      AppConfig.isTestMode
                          ? '${_l10n.testModePrefix} $workMinutes ${AppConfig.timeUnit}'
                          : _l10n.workTimeFormat(
                              workMinutes ~/ 60,
                              workMinutes % 60,
                            ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final newState = !isRunning;
                      ref.read(appProvider.notifier).setRunning(newState);
                      ref.read(trayProvider.notifier).updateTrayMenu(newState);
                    },
                    icon: Icon(
                      isRunning
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      size: 20,
                    ),
                    label: Text(
                      isRunning ? _l10n.stop : _l10n.start,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRunning ? Colors.white : Colors.grey,
                      foregroundColor: isRunning
                          ? Colors.indigo.shade900
                          : Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyQuoteCard(BuildContext context) {
    final locale = ref.watch(appProvider).locale;
    final quote = DailyQuotes.getQuoteForToday();
    final isTr = locale.languageCode == 'tr';

    return _buildGlassCard(
      isLightGlass: true,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.format_quote_rounded,
                  color: Colors.amberAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _l10n.dailyQuoteTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"${isTr ? quote.textTr : quote.textEn}"',
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                '💡 ${quote.category}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow({
    required Map<String, bool> enabledReminders,
    required Map<String, int> reminderIntervals,
    required TimerState timerState,
    required bool isRunning,
  }) {
    final activeCount = enabledReminders.values.where((e) => e).length;
    final nextLabel = ref
        .read(timerProvider.notifier)
        .getNextReminderLabel(enabledReminders, reminderIntervals);
    final statsAsync = ref.watch(statsProvider);
    final completedCount = statsAsync.value?.completed ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildGlassCard(
            isLightGlass: true,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$activeCount',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _l10n.activeRemindersCount,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildGlassCard(
            isLightGlass: true,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.schedule,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  nextLabel,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _l10n.nextReminderLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _openStats,
            child: _buildGlassCard(
              isLightGlass: true,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.task_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$completedCount',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _l10n.todayCompleted,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReminderCards({
    required Map<String, bool> enabledReminders,
    required Map<String, int> reminderIntervals,
    required TimerState timerState,
  }) {
    final activeReminders = enabledReminders.entries
        .where((e) => e.value)
        .toList();

    if (activeReminders.isEmpty) {
      return _buildGlassCard(
        isLightGlass: true,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            _l10n.noActiveReminders,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            _l10n.activeRemindersTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
        ...activeReminders.map((entry) {
          final key = entry.key;
          final interval = reminderIntervals[key] ?? 30;
          final elapsed = timerState.timeElapsed[key] ?? 0;
          final timeLeft = interval - elapsed;
          final progress = elapsed / interval;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildReminderCard(
              name: _getReminderName(key),
              icon: _reminderIcons[key] ?? Icons.notifications,
              color: _reminderColors[key] ?? Colors.deepPurple,
              timeLeft: timeLeft,
              progress: progress.clamp(0.0, 1.0),
              interval: interval,
            ),
          );
        }),
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
    VoidCallback? onSnooze,
  }) {
    // Süre dolmasına 1 dakika veya daha az kaldığında kart hafifçe nabız
    // gibi parlar — kullanıcı bildirimi almadan önce görsel bir ön işaret alır.
    final isUrgent = timeLeft <= 1;

    return _UrgentPulse(
      active: isUrgent,
      color: color,
      child: _buildGlassCard(
        isLightGlass: true,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withValues(alpha: 0.85), color.withValues(alpha: 0.55)],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (onSnooze != null)
                        GestureDetector(
                          onTap: onSnooze,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.snooze_rounded,
                              size: 18,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isUrgent
                              ? color.withValues(alpha: 0.35)
                              : Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isUrgent
                                ? color.withValues(alpha: 0.6)
                                : Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          '$timeLeft ${_l10n.minuteShort}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: progress),
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOutCubic,
                      builder: (context, animatedProgress, _) {
                        return LinearProgressIndicator(
                          value: animatedProgress,
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 5,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSilentHoursCard() {
    return _buildGlassCard(
      isLightGlass: true,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.indigo.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.nightlight_round,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _l10n.silentHoursActive,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _l10n.silentHoursMuted,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({
    required Widget child,
    EdgeInsets? padding,
    bool isLightGlass = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLightGlass
              ? [
                  Colors.white.withValues(alpha: 0.18),
                  Colors.white.withValues(alpha: 0.06),
                ]
              : [
                  Colors.white.withValues(alpha: 0.25),
                  Colors.white.withValues(alpha: 0.1),
                ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: isLightGlass ? 0.12 : 0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: isLightGlass ? 8 : 10,
            sigmaY: isLightGlass ? 8 : 10,
          ),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _getReminderName(String key) {
    switch (key) {
      case 'eyeRest':
        return _l10n.reminderEyeRest;
      case 'posture':
        return _l10n.reminderPosture;
      case 'water':
        return _l10n.reminderWater;
      case 'stretch':
        return _l10n.reminderStretch;
      case 'walk':
        return _l10n.reminderWalk;
      default:
        return _l10n.reminderDefault;
    }
  }

  String _getReminderMessage(String key) {
    switch (key) {
      case 'eyeRest':
        return _l10n.msgEyeRest;
      case 'posture':
        return _l10n.msgPosture;
      case 'water':
        return _l10n.msgWater;
      case 'stretch':
        return _l10n.msgStretch;
      case 'walk':
        return _l10n.msgWalk;
      default:
        return _l10n.msgDefault;
    }
  }
}

/// Süresi dolmak üzere olan hatırlatıcı kartına hafif, tekrarlayan bir
/// parlama efekti ekler. `active` false iken hiçbir ek maliyet olmadan
/// çocuğu doğrudan döndürür.
class _UrgentPulse extends StatefulWidget {
  final Widget child;
  final bool active;
  final Color color;

  const _UrgentPulse({
    required this.child,
    required this.active,
    required this.color,
  });

  @override
  State<_UrgentPulse> createState() => _UrgentPulseState();
}

class _UrgentPulseState extends State<_UrgentPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _UrgentPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.active && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.20 + t * 0.25),
                blurRadius: 14 + t * 10,
                spreadRadius: t * 1.5,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
