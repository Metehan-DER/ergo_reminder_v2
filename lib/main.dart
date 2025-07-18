import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'dart:io';

import 'HomePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Window Manager initialization
  await windowManager.ensureInitialized();

  const initialSize = Size(500, 850);
  const minimumSize = Size(500, 850);

  WindowOptions windowOptions = WindowOptions(
    size: initialSize,
    minimumSize: minimumSize,
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: Platform.isMacOS ? TitleBarStyle.normal : TitleBarStyle.normal,
    title: 'Ergonomik Asistan',
    // macOS için window kapatıldığında uygulamayı kapatmasını engelle
    windowButtonVisibility: Platform.isMacOS ? true : null,
  );

  // Launch at startup setup
  if (Platform.isWindows || Platform.isMacOS) {
    launchAtStartup.setup(
      appName: 'ErgonomikAsistan',
      appPath: Platform.resolvedExecutable,
      // macOS için paket identifier'ı ekle
      packageName: Platform.isMacOS ? 'com.example.ergonomikasistan' : null,
    );
  }

  // Pencereyi göster
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

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