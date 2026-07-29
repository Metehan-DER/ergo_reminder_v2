import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../providers/stats_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeState = ref.watch(themeProvider);
    final statsAsync = ref.watch(statsProvider);
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.statisticsTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: themeState.activeGradientColors,
          ),
        ),
        child: SafeArea(
          child: statsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            error: (err, stack) => Center(
              child: Text(
                'Hata: $err',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            data: (stats) {
              final total = stats.completed + stats.snoozed + stats.ignored;
              final rate = total > 0
                  ? (stats.completed / total * 100).round()
                  : 0;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sol Kolon (%48) — Başarı Oranı & Metrik Kartları
                    Expanded(
                      flex: 48,
                      child: Column(
                        children: [
                          _buildGlassCard(
                            padding: const EdgeInsets.all(24),
                            child: Row(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    SizedBox(
                                      width: 90,
                                      height: 90,
                                      child: CircularProgressIndicator(
                                        value: total > 0
                                            ? stats.completed / total
                                            : 0.0,
                                        strokeWidth: 9,
                                        backgroundColor: Colors.white
                                            .withValues(alpha: 0.2),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                              Colors.greenAccent,
                                            ),
                                      ),
                                    ),
                                    Text(
                                      '%$rate',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.successRate,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        rate >= 70
                                            ? 'Mükemmel! Günlük molalarınızı düzenli alıyorsunuz.'
                                            : 'Daha iyi bir ergonomi için molalarınızı aksatmayın.',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.white70,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetricCard(
                                  title: l10n.todayCompleted,
                                  count: stats.completed,
                                  icon: Icons.check_circle_outline,
                                  color: Colors.greenAccent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMetricCard(
                                  title: l10n.todaySnoozed,
                                  count: stats.snoozed,
                                  icon: Icons.snooze_outlined,
                                  color: Colors.amberAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildMetricCard(
                                  title: l10n.todayIgnored,
                                  count: stats.ignored,
                                  icon: Icons.cancel_outlined,
                                  color: Colors.pinkAccent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildMetricCard(
                                  title: l10n.totalReminders,
                                  count: total,
                                  icon: Icons.analytics_outlined,
                                  color: Colors.cyanAccent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Sağ Kolon (%52) — Kategori Dağılım Paneli
                    Expanded(
                      flex: 52,
                      child: Column(
                        children: [
                          settingsAsync.when(
                            data: (settings) => _buildBreakdownSection(
                              context,
                              l10n,
                              settings.enabledReminders,
                            ),
                            loading: () => const SizedBox.shrink(),
                            error: (err, stack) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return _buildGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownSection(
    BuildContext context,
    AppLocalizations l10n,
    Map<String, bool> enabledReminders,
  ) {
    final reminderNames = {
      'eyeRest': l10n.reminderEyeRest,
      'posture': l10n.reminderPosture,
      'water': l10n.reminderWater,
      'stretch': l10n.reminderStretch,
      'walk': l10n.reminderWalk,
    };

    final reminderColors = {
      'eyeRest': Colors.blue,
      'posture': Colors.purple,
      'water': Colors.cyan,
      'stretch': Colors.orange,
      'walk': Colors.green,
    };

    return _buildGlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.breakdownTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          ...enabledReminders.entries.map((entry) {
            final key = entry.key;
            final name = reminderNames[key] ?? key;
            final color = reminderColors[key] ?? Colors.teal;
            final isEnabled = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isEnabled ? color : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 15,
                        color: isEnabled ? Colors.white : Colors.white38,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isEnabled
                          ? Colors.white.withValues(alpha: 0.25)
                          : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isEnabled
                            ? Colors.white.withValues(alpha: 0.3)
                            : Colors.white12,
                      ),
                    ),
                    child: Text(
                      isEnabled ? 'Aktif' : 'Pasif',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isEnabled ? Colors.white : Colors.white38,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.25),
            Colors.white.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}
