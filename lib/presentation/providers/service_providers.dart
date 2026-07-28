import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/tray_service.dart';
import '../../core/services/window_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('storageServiceProvider must be overridden in main.dart');
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final trayServiceProvider = Provider<TrayService>((ref) {
  return TrayService();
});

final windowServiceProvider = Provider<WindowService>((ref) {
  return WindowService();
});
