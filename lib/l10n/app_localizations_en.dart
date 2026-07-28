// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ergonomic Assistant';

  @override
  String get statusHealthy => 'Your Health is Protected';

  @override
  String get statusStopped => 'Tracking Stopped';

  @override
  String get statusHealthyContinued => 'Your Health is Protected...';

  @override
  String get greetingMorning => 'Good Morning';

  @override
  String get greetingAfternoon => 'Good Afternoon';

  @override
  String get greetingEvening => 'Good Evening';

  @override
  String get greetingNight => 'Good Night';

  @override
  String workTimeFormat(int hours, int mins) {
    return '${hours}h ${mins}m';
  }

  @override
  String get activeRemindersCount => 'Active Reminders';

  @override
  String get nextReminderLabel => 'Next Reminder';

  @override
  String get todayReceived => 'Today Received';

  @override
  String get todayPostponed => 'Today Snoozed';

  @override
  String get activeRemindersTitle => 'Active Reminders';

  @override
  String get noActiveReminders =>
      'No active reminders yet.\nEnable reminders in settings.';

  @override
  String get minuteShort => 'min';

  @override
  String get silentHoursActive => 'Silent Hours Active';

  @override
  String get silentHoursMuted => 'Reminders are muted';

  @override
  String get infoTrayText =>
      'The app continues running in the system tray. Use the tray menu to quit completely.';

  @override
  String get dialogOk => 'OK, I\'m On It';

  @override
  String snoozeOption(int minutes) {
    return 'Snooze $minutes min';
  }

  @override
  String get snoozeButtonLabel => 'Snooze';

  @override
  String get exitTitle => 'Quit Application';

  @override
  String get exitContent =>
      'Do you want to completely quit Ergonomic Assistant?';

  @override
  String get cancel => 'Cancel';

  @override
  String get quit => 'Quit';

  @override
  String get stop => 'Stop';

  @override
  String get start => 'Start';

  @override
  String get settings => 'Settings';

  @override
  String get changeColors => 'Change Colors';

  @override
  String get tooltipHideToTray => 'Hide to system tray';

  @override
  String get trayShowWindow => 'Show Window';

  @override
  String get trayHideWindow => 'Hide Window';

  @override
  String get trayQuit => 'Quit Application';

  @override
  String get trayRunning => 'Running';

  @override
  String get trayStopped => 'Stopped';

  @override
  String get reminderEyeRest => 'Eye Rest';

  @override
  String get reminderPosture => 'Posture Check';

  @override
  String get reminderWater => 'Drink Water';

  @override
  String get reminderStretch => 'Stretching';

  @override
  String get reminderWalk => 'Walk Break';

  @override
  String get msgEyeRest =>
      'Look 20 feet away for 20 seconds and rest your eyes.';

  @override
  String get msgPosture => 'Straighten your back and relax your shoulders.';

  @override
  String get msgWater => 'Drink a glass of water to stay hydrated.';

  @override
  String get msgStretch => 'Do some light stretching to reduce muscle tension.';

  @override
  String get msgWalk => 'Stand up and take a 5-minute walk.';

  @override
  String get reminderDefault => 'Reminder';

  @override
  String get msgDefault => 'Take a short break for your health.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get profileSection => 'Customize Profile';

  @override
  String get nameLabel => 'Your Name';

  @override
  String get titleLabel => 'Honorific Title';

  @override
  String get genderLabel => 'Gender';

  @override
  String get genderUnspecified => 'Unspecified';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get noTitleOption => 'None';

  @override
  String get reminderSettingsSection => 'Reminder Settings';

  @override
  String get descEyeRest => '20-20-20 rule reminder';

  @override
  String get descPosture => 'Sitting posture check';

  @override
  String get descWater => 'Hydration reminder';

  @override
  String get descStretch => 'Muscle tension relief';

  @override
  String get descWalk => 'Improve blood circulation';

  @override
  String get every => 'Every';

  @override
  String get minutesSuffix => 'minutes';

  @override
  String get silentHoursSection => 'Silent Hours';

  @override
  String get silentHoursDesc => 'Reminders are muted during these hours';

  @override
  String get startTimeLabel => 'Start Time:';

  @override
  String get endTimeLabel => 'End Time:';

  @override
  String get systemSettingsSection => 'System Settings';

  @override
  String get systemSettingsDesc => 'App startup and system integration';

  @override
  String get autoStartLabel => 'Run at system startup';

  @override
  String get autoStartDesc => 'Start app when computer starts';

  @override
  String get saveSettings => 'Save Settings';

  @override
  String get settingsSaved => 'Settings saved successfully';

  @override
  String get languageSection => 'Dil / Language';

  @override
  String get testModePrefix => 'Test:';
}
