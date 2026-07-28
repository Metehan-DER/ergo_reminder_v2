import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppState {
  final Locale? locale;
  final bool isRunning;

  const AppState({
    this.locale,
    this.isRunning = false,
  });

  AppState copyWith({
    Locale? locale,
    bool? isRunning,
  }) {
    return AppState(
      locale: locale ?? this.locale,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class AppNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    return const AppState();
  }

  void setLocale(Locale locale) {
    state = state.copyWith(locale: locale);
  }

  void setRunning(bool isRunning) {
    state = state.copyWith(isRunning: isRunning);
  }

  void toggleRunning() {
    state = state.copyWith(isRunning: !state.isRunning);
  }
}

final appProvider = NotifierProvider<AppNotifier, AppState>(() {
  return AppNotifier();
});
