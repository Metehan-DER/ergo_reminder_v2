import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const initializationSettingsWindows = WindowsInitializationSettings(
      appName: 'ErgoMate',
      appUserModelId: 'com.example.ergomate',
      guid: 'd3d6b4c7-5f6e-4c1e-b3a2-1a0b9c8d7e6f',
    );

    const initializationSettingsMacOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true,
    );

    const initializationSettings = InitializationSettings(
      windows: initializationSettingsWindows,
      macOS: initializationSettingsMacOS,
    );

    await _notifications.initialize(initializationSettings);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    // İptal et: Aynı bildirim id'sinin üst üste yığılmasını önle
    try {
      await _notifications.cancel(id);
    } catch (_) {}

    const windowsDetails = WindowsNotificationDetails();
    const macOsDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
      presentList: true,
      sound: 'default',
    );

    const notificationDetails = NotificationDetails(
      windows: windowsDetails,
      macOS: macOsDetails,
    );

    // Sistem alert zil sesi çal
    try {
      SystemSound.play(SystemSoundType.alert);
    } catch (_) {}

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
