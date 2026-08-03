import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'i_window_service.dart';

/// WindowService — [IWindowService] arayüzünün somut implementasyonu.
class WindowService implements IWindowService {
  @override
  Future<void> init() async {
    await windowManager.setPreventClose(true);
    await windowManager.setSkipTaskbar(false);
    await windowManager.setTitle('Ergonomik Asistan');
    await windowManager.setMinimumSize(const Size(850, 580));
  }

  @override
  Future<void> show() async {
    await windowManager.show();
    await windowManager.setSkipTaskbar(false);
  }

  @override
  Future<void> hide() async {
    await windowManager.hide();
    await windowManager.setSkipTaskbar(true);
  }

  @override
  Future<bool> isVisible() async {
    return await windowManager.isVisible();
  }

  @override
  void addListener(WindowListener listener) {
    windowManager.addListener(listener);
  }

  @override
  void removeListener(WindowListener listener) {
    windowManager.removeListener(listener);
  }

  @override
  Future<void> close() async {
    await windowManager.destroy();
  }
}
