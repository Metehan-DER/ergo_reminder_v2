import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:tray_manager/tray_manager.dart';
import 'i_tray_service.dart';

/// TrayService — [ITrayService] arayüzünün somut implementasyonu.
/// Platform (Windows / macOS) farklılıklarını bu sınıf kapsüller.
class TrayService implements ITrayService {
  @override
  Future<void> init() async {
    try {
      if (Platform.isWindows) {
        await _setWindowsIcon();
      } else if (Platform.isMacOS) {
        try {
          await trayManager.setIcon(
            'assets/icons/app_logo.png',
            isTemplate: true,
          );
        } catch (e) {
          debugPrint('macOS: Icon failed: $e');
        }
      }
    } catch (e) {
      debugPrint('Tray init error: $e');
    }
  }

  Future<void> _setWindowsIcon() async {
    try {
      await trayManager.setIcon('assets/icons/app_logo.ico');
    } catch (e) {
      debugPrint('Windows .ico failed: $e');
      try {
        await trayManager.setIcon('assets/icons/app_logo.png');
      } catch (e2) {
        debugPrint('Windows .png failed: $e2');
        await trayManager.setIcon('EH');
      }
    }
  }

  @override
  Future<void> setToolTip(String text) async {
    await trayManager.setToolTip(text);
  }

  @override
  Future<void> setContextMenu(Menu menu) async {
    await trayManager.setContextMenu(menu);
  }

  @override
  void popUpContextMenu() {
    trayManager.popUpContextMenu();
  }

  @override
  void addListener(TrayListener listener) {
    trayManager.addListener(listener);
  }

  @override
  void removeListener(TrayListener listener) {
    trayManager.removeListener(listener);
  }

  @override
  Future<void> destroy() async {
    await trayManager.destroy();
  }
}
