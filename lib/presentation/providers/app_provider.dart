import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'service_providers.dart';

class AppState {
  final Locale locale;
  final bool isRunning;
  final bool openSettingsRequested;
  final bool exitRequested;

  const AppState({
    this.locale = const Locale('tr'),
    this.isRunning = false,
    this.openSettingsRequested = false,
    this.exitRequested = false,
  });

  AppState copyWith({
    Locale? locale,
    bool? isRunning,
    bool? openSettingsRequested,
    bool? exitRequested,
  }) {
    return AppState(
      locale: locale ?? this.locale,
      isRunning: isRunning ?? this.isRunning,
      openSettingsRequested: openSettingsRequested ?? this.openSettingsRequested,
      exitRequested: exitRequested ?? this.exitRequested,
    );
  }
}

class AppNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    final storage = ref.watch(storageServiceProvider);
    final savedLang = storage.getString('app_locale', defaultValue: 'tr');
    return AppState(locale: Locale(savedLang));
  }

  void setLocale(Locale locale) {
    state = state.copyWith(locale: locale);
    ref.read(storageServiceProvider).setString('app_locale', locale.languageCode);
  }

  void setRunning(bool isRunning) => state = state.copyWith(isRunning: isRunning);

  void toggleRunning() => state = state.copyWith(isRunning: !state.isRunning);

  void requestOpenSettings() {
    state = state.copyWith(openSettingsRequested: true);
    Future.microtask(() => state = state.copyWith(openSettingsRequested: false));
  }

  void requestExit() {
    state = state.copyWith(exitRequested: true);
    Future.microtask(() => state = state.copyWith(exitRequested: false));
  }
}

final appProvider = NotifierProvider<AppNotifier, AppState>(() => AppNotifier());
