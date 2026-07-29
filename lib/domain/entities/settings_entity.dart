import 'package:flutter/material.dart';

class SettingsEntity {
  final String userName;
  final String userTitle;
  final String gender;
  final bool autoStart;
  final TimeOfDay silentStart;
  final TimeOfDay silentEnd;
  final Map<String, bool> enabledReminders;
  final Map<String, int> reminderIntervals;
  final bool isOnboardingCompleted;

  const SettingsEntity({
    required this.userName,
    required this.userTitle,
    required this.gender,
    required this.autoStart,
    required this.silentStart,
    required this.silentEnd,
    required this.enabledReminders,
    required this.reminderIntervals,
    this.isOnboardingCompleted = false,
  });

  SettingsEntity copyWith({
    String? userName,
    String? userTitle,
    String? gender,
    bool? autoStart,
    TimeOfDay? silentStart,
    TimeOfDay? silentEnd,
    Map<String, bool>? enabledReminders,
    Map<String, int>? reminderIntervals,
    bool? isOnboardingCompleted,
  }) {
    return SettingsEntity(
      userName: userName ?? this.userName,
      userTitle: userTitle ?? this.userTitle,
      gender: gender ?? this.gender,
      autoStart: autoStart ?? this.autoStart,
      silentStart: silentStart ?? this.silentStart,
      silentEnd: silentEnd ?? this.silentEnd,
      enabledReminders: enabledReminders ?? this.enabledReminders,
      reminderIntervals: reminderIntervals ?? this.reminderIntervals,
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
    );
  }
}
