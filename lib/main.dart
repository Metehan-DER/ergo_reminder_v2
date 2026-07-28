import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

import 'core/services/storage_service.dart';
import 'core/services/tray_service.dart';
import 'core/services/window_service.dart';
import 'presentation/providers/service_providers.dart';
import 'presentation/providers/app_provider.dart';
import 'presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storageService = await StorageService.init();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    await ref.read(trayServiceProvider).init();
    await ref.read(windowServiceProvider).init();
    // Notification service initializes lazily or can be init here
    await ref.read(notificationServiceProvider).init();
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ergonomik Asistan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        fontFamily: 'Inter',
      ),
      locale: appState.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', ''),
        Locale('en', ''),
      ],
      home: const HomePage(),
    );
  }
}
