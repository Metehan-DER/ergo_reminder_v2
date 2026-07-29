import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';
import 'l10n/app_localizations.dart';

import 'core/services/storage_service.dart';
import 'presentation/providers/service_providers.dart';
import 'presentation/providers/app_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/timer_provider.dart';
import 'presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1000, 680),
    minimumSize: Size(850, 580),
    center: true,
    title: 'Ergonomik Asistan',
    skipTaskbar: false,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  final storageService = await StorageService.init();

  runApp(
    ProviderScope(
      overrides: [storageServiceProvider.overrideWithValue(storageService)],
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
    await ref.read(notificationServiceProvider).init();
    ref.read(trayProvider);
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appProvider);
    final themeState = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ergonomik Asistan',
      themeMode: themeState.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeState.primarySeedColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.manropeTextTheme(),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeState.primarySeedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme),
      ),
      locale: appState.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('tr', ''), Locale('en', '')],
      home: const HomePage(),
    );
  }
}
