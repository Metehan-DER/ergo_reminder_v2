import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:tray_manager/tray_manager.dart';

class TrayService {
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

  Future<void> setToolTip(String text) async {
    await trayManager.setToolTip(text);
  }

  Future<void> setContextMenu(Menu menu) async {
    await trayManager.setContextMenu(menu);
  }

  void popUpContextMenu() {
    trayManager.popUpContextMenu();
  }

  void addListener(TrayListener listener) {
    trayManager.addListener(listener);
  }

  void removeListener(TrayListener listener) {
    trayManager.removeListener(listener);
  }

  Future<void> destroy() async {
    await trayManager.destroy();
  }
}
