import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:window_manager/window_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/daily_quotes.dart';
import '../../core/constants/reminder_contents.dart';
import '../../core/constants/todo_display_constants.dart';
import '../../core/utils/page_transitions.dart';

import '../providers/app_provider.dart';
import '../providers/service_providers.dart';
import '../providers/settings_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/timer_provider.dart';
import '../providers/tray_provider.dart';

import 'settings_page.dart';
import 'stats_page.dart';
import 'todo_page.dart';
import 'calendar_page.dart';
import '../widgets/glass_card.dart';
import '../widgets/reminder_card.dart';
import '../widgets/reminder_dialog.dart';
import '../widgets/silent_hours_card.dart';
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

  // OCP: Icon ve renk map'leri artık TodoDisplayConstants'tan okunuyor.
  // Yeni reminder eklemek için bu dosya değiştirilmez.

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

    // SRP: Dialog UI artık reminder_dialog.dart'ta — bu metod sadece çağırır.
    showReminderDialog(
      context: context,
      id: id,
      title: title,
      body: body,
      color: color,
      icon: icon,
      snoozeLabel: _l10n.snoozeButtonLabel,
      okLabel: _l10n.dialogOk,
      onSnooze: () {
        _isDialogShowing = false;
        ref.read(timerProvider.notifier).snoozeReminder(id);
      },
      onOk: () {
        _isDialogShowing = false;
        ref.read(timerProvider.notifier).removeFirstFromQueue();
      },
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
        // OCP: switch kaldırıldı, ReminderContents kullanılıyor
        final content = ReminderContents.getById(activeId);
        final isTr = ref.read(appProvider).locale.languageCode == 'tr';
        final icon = TodoDisplayConstants.reminderIcon(activeId);
        final color = TodoDisplayConstants.reminderColor(activeId);

        _showReminderDialog(
          id: activeId,
          title: content.title(isTr: isTr),
          body: content.body(isTr: isTr),
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

  // Not: bu widget artık aktif temanın accent rengini kullanıyor, bu yüzden
  // dosyanın başında `import '../providers/theme_provider.dart';` ve
  // haptic feedback için `import 'package:flutter/services.dart';` olduğundan
  // emin ol (yoksa ekle).

  Widget _buildMainStatusCard({
    required bool isRunning,
    required int workMinutes,
    required String userName,
    required String userTitle,
  }) {
    final title = _getGreetingTitle(userName, userTitle);
    final subtitle = _getGreetingSubtitle(isRunning);
    final accent = ref.watch(themeProvider).primarySeedColor;


    return GlassCard(
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
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      isRunning
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      key: ValueKey(isRunning),
                      size: 36,
                      color: Colors.white,
                    ),
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
                    Row(
                      children: [
                        // Aktif takip sırasında küçük, nabız gibi atan bir
                        // durum noktası — "canlı" olduğunu tek bakışta belli eder.
                        if (isRunning) ...[
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
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
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        if (!isRunning)
                          BoxShadow(
                            color: accent.withValues(alpha: 0.45),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        final newState = !isRunning;
                        ref.read(appProvider.notifier).setRunning(newState);
                        ref
                            .read(trayProvider.notifier)
                            .updateTrayMenu(newState);
                      },
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: Icon(
                          isRunning
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          key: ValueKey(isRunning),
                          size: 20,
                        ),
                      ),
                      label: Text(
                        isRunning ? _l10n.stop : _l10n.start,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        // Takip zaten aktifken buton "sakinleşir" — dikkat çekmesi
                        // gereken an, henüz başlatılmamış olduğu andır.
                        backgroundColor: isRunning
                            ? Colors.white.withValues(alpha: 0.14)
                            : accent.withValues(alpha: 0.85),
                        foregroundColor: isRunning
                            ? Colors.white
                            : Colors.white,
                        elevation: isRunning ? 0 : 4,
                        side: isRunning
                            ? const BorderSide(color: Colors.white30)
                            : BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
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

    return GlassCard(
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
          child: GlassCard(
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
          child: GlassCard(
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
            child: GlassCard(
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
      return GlassCard(
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
          // OCP: switch kaldırıldı — icon/renk/isim constants'tan okunuyor
          final content = ReminderContents.getById(key);
          final isTr = ref.read(appProvider).locale.languageCode == 'tr';

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            // SRP: ReminderCard widget'ı kendi dosyasında
            child: ReminderCard(
              name: content.title(isTr: isTr),
              icon: TodoDisplayConstants.reminderIcon(key),
              color: TodoDisplayConstants.reminderColor(key),
              timeLeft: timeLeft,
              progress: progress.clamp(0.0, 1.0),
              minuteShortLabel: _l10n.minuteShort,
            ),
          );
        }),
      ],
    );
  }

  // _buildReminderCard → ReminderCard widget'ına taşındı (SRP)

  /// Sessiz saat kartı — SilentHoursCard widget'ına delege eder (SRP).
  Widget _buildSilentHoursCard() {
    return SilentHoursCard(
      title: _l10n.silentHoursActive,
      subtitle: _l10n.silentHoursMuted,
    );
  }

  // _buildGlassCard → GlassCard widget'ına taşındı (SRP)
  // _getReminderName / _getReminderMessage → ReminderContents sabitine taşındı (OCP)
}

