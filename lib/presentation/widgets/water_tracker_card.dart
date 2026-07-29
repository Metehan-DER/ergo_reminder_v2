import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../providers/water_provider.dart';
import 'animated_water_cup.dart';

class WaterTrackerCard extends ConsumerWidget {
  const WaterTrackerCard({super.key});

  void _showGoalSelector(BuildContext context, WidgetRef ref, int currentGoalMl) {
    final l10n = AppLocalizations.of(context);
    final goals = [1500, 2000, 2500, 3000, 3500];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade900.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.water_drop_rounded, color: Colors.cyanAccent, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        l10n.selectWaterGoal,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: goals.map((goal) {
                      final isSelected = goal == currentGoalMl;
                      final liters = (goal / 1000).toStringAsFixed(1);
                      final glasses = (goal / 250).round();

                      return GestureDetector(
                        onTap: () {
                          ref.read(waterProvider.notifier).setGoalMl(goal);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.cyanAccent.withValues(alpha: 0.25)
                                : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? Colors.cyanAccent : Colors.white12,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '$liters Litre',
                                style: TextStyle(
                                  color: isSelected ? Colors.cyanAccent : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$glasses Bardak',
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final waterLog = ref.watch(waterProvider);

    final consumedLiters = (waterLog.consumedMl / 1000).toStringAsFixed(2);
    final goalLiters = (waterLog.goalMl / 1000).toStringAsFixed(1);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Canlı Dalgalı Su Bardağı Widget'ı
              AnimatedWaterCup(
                progress: waterLog.progressRatio,
                width: 58,
                height: 78,
              ),
              const SizedBox(width: 16),

              // Metrikler ve Bilgiler
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.water_drop_rounded,
                          color: Colors.cyanAccent,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.waterTrackerTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Litre Metriği
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$consumedLiters ',
                            style: const TextStyle(
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          TextSpan(
                            text: '/ $goalLiters Litre',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Bardak Sayısı & Hedef Ayar Butonu
                    Row(
                      children: [
                        Text(
                          '${waterLog.consumedGlasses} / ${waterLog.goalGlasses} Bardak',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _showGoalSelector(context, ref, waterLog.goalMl),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: Colors.white54,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Ekle / Çıkar Aksiyon Butonları
              Column(
                children: [
                  // +1 Bardak Butonu
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(waterProvider.notifier).addGlass();
                    },
                    icon: const Icon(Icons.add_rounded, size: 16, color: Colors.black),
                    label: Text(
                      l10n.addGlass,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // -1 Bardak Butonu
                  if (waterLog.consumedMl > 0)
                    GestureDetector(
                      onTap: () {
                        ref.read(waterProvider.notifier).removeGlass();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          l10n.removeGlass,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
