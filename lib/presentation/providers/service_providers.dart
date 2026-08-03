import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/i_notification_service.dart';
import '../../core/services/i_tray_service.dart';
import '../../core/services/i_window_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/tray_service.dart';
import '../../core/services/window_service.dart';

/// storageServiceProvider — ana.dart'ta overrideWithValue ile başlatılır.
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('storageServiceProvider must be overridden in main.dart');
});

/// Yüksek seviye modüller [INotificationService] arayüzüne bağımlı (DIP).
final notificationServiceProvider = Provider<INotificationService>((ref) {
  return NotificationService();
});

/// Yüksek seviye modüller [ITrayService] arayüzüne bağımlı (DIP).
final trayServiceProvider = Provider<ITrayService>((ref) {
  return TrayService();
});

/// Yüksek seviye modüller [IWindowService] arayüzüne bağımlı (DIP).
final windowServiceProvider = Provider<IWindowService>((ref) {
  return WindowService();
});
