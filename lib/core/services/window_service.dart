import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowService {
  Future<void> init() async {
    await windowManager.setPreventClose(true);
    await windowManager.setSkipTaskbar(false);
    await windowManager.setTitle('Ergonomik Asistan');
    await windowManager.setMinimumSize(const Size(500, 850));
  }

  Future<void> show() async {
    await windowManager.show();
    await windowManager.setSkipTaskbar(false);
  }

  Future<void> hide() async {
    await windowManager.hide();
    await windowManager.setSkipTaskbar(true);
  }

  Future<bool> isVisible() async {
    return await windowManager.isVisible();
  }

  void addListener(WindowListener listener) {
    windowManager.addListener(listener);
  }

  void removeListener(WindowListener listener) {
    windowManager.removeListener(listener);
  }

  Future<void> close() async {
    await windowManager.destroy();
  }
}
