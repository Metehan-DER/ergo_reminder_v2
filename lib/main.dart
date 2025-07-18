import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'dart:io';

import 'HomePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Window Manager initialization
  await windowManager.ensureInitialized();

  const initialSize = Size(500, 850); // Initial window size
  const minimumSize = Size(500, 850); // Minimum window size

  WindowOptions windowOptions = const WindowOptions(
    size: initialSize,
    minimumSize: minimumSize, // Added minimum size constraint
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'Ergonomik Asistan',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setMinimumSize(
      minimumSize,
    ); // Ensure minimum size is enforced

    // Sistem tepsisi için gerekli ayarlar
    await windowManager.setPreventClose(
      true,
    ); // X butonuna basınca kapatmasını engeller
    await windowManager.setSkipTaskbar(false); // Taskbar'da görünür olsun
    await windowManager.setResizable(true); // Yeniden boyutlandırma izni

    await windowManager.show();
    await windowManager.focus();
  });

  // Launch at startup setup
  if (Platform.isWindows || Platform.isMacOS) {
    launchAtStartup.setup(
      appName: 'ErgonomikAsistan',
      appPath: Platform.resolvedExecutable,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ergonomik Asistan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            elevation: 3,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}
