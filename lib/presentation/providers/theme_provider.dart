import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'service_providers.dart';

class ThemeState {
  final ThemeMode themeMode;
  final int paletteIndex;

  static const List<List<Color>> palettes = [
    // 0. Mor Şafak (Cosmic Violet & Magenta)
    [Color(0xFF673AB7), Color(0xFF9C27B0), Color(0xFFF06292)],
    // 1. Okyanus Esintisi (Teal, Cyan & Blue)
    [Color(0xFF00695C), Color(0xFF00897B), Color(0xFF0288D1)],
    // 2. Gece Şafağı (Deep Indigo & Periwinkle) — tonlar arası fark büyütüldü,
    // önceki sürümde üç durak da birbirine çok yakındı ve düz bir leke gibi görünüyordu.
    [Color(0xFF283593), Color(0xFF3949AB), Color(0xFF5C6BC0)],
    // 3. Gün Batımı (Rose & Warm Amber)
    [Color(0xFFD81B60), Color(0xFFE53935), Color(0xFFFB8C00)],
    // 4. Zümrüt Ormanı (Deep Green & Mint)
    [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF00897B)],
    // 5. Kehribar Işıltısı (Deep Bronze & Warm Gold)
    [Color(0xFF4E342E), Color(0xFFD84315), Color(0xFFFF8F00)],
    // 6. Sis (Slate & Cool Gray) — düşük doygunluklu, sakin seçenek;
    // uygulamanın göz dinlendirme/ergonomi temasıyla daha tutarlı bir alternatif.
    [Color(0xFF37474F), Color(0xFF546E7A), Color(0xFF78909C)],
  ];

  // Palet adları — sırası `palettes` ile birebir eşleşir.
  // UI'da (ör. tema seçim tooltip'i, erişilebilirlik etiketi) kullanılmak üzere.
  static const List<String> paletteNamesTr = [
    'Mor Şafak',
    'Okyanus Esintisi',
    'Gece Şafağı',
    'Gün Batımı',
    'Zümrüt Ormanı',
    'Kehribar Işıltısı',
    'Sis',
  ];

  static const List<String> paletteNamesEn = [
    'Cosmic Violet',
    'Ocean Breeze',
    'Midnight Dawn',
    'Sunset Glow',
    'Emerald Forest',
    'Amber Glow',
    'Fog',
  ];

  const ThemeState({
    this.themeMode = ThemeMode.system,
    this.paletteIndex = 0,
  });

  List<Color> get activeGradientColors {
    return palettes[paletteIndex % palettes.length];
  }

  Color get primarySeedColor => activeGradientColors.first;

  /// Aktif paletin dile göre görünen adı — ör. tema seçim kartında rozet/tooltip için.
  String paletteName({required bool isTr}) {
    final names = isTr ? paletteNamesTr : paletteNamesEn;
    return names[paletteIndex % names.length];
  }

  /// Palet rengine göre türetilmiş, Material 3 uyumlu tam tema.
  /// Böylece Switch, Chip, Dropdown gibi standart widget'lar da
  /// seçilen paletle otomatik uyumlu olur — sadece arka plan gradyanı değil.
  ThemeData buildThemeData(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primarySeedColor,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      scaffoldBackgroundColor: Colors.transparent,
    );
  }

  ThemeData get lightThemeData => buildThemeData(Brightness.light);
  ThemeData get darkThemeData => buildThemeData(Brightness.dark);

  ThemeState copyWith({
    ThemeMode? themeMode,
    int? paletteIndex,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      paletteIndex: paletteIndex ?? this.paletteIndex,
    );
  }
}

class ThemeNotifier extends Notifier<ThemeState> {
  static const _paletteKey = 'theme_palette_index';
  static const _modeKey = 'theme_mode_index';

  @override
  ThemeState build() {
    final storage = ref.watch(storageServiceProvider);
    final paletteIdx = storage.getInt(_paletteKey, defaultValue: 0);
    final modeIdx = storage.getInt(_modeKey, defaultValue: 0);

    return ThemeState(
      themeMode: _modeFromIndex(modeIdx),
      paletteIndex: paletteIdx,
    );
  }

  ThemeMode _modeFromIndex(int index) {
    switch (index) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  int _indexFromMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
      case ThemeMode.system:
        return 0;
    }
  }

  void nextPalette() {
    final nextIdx = (state.paletteIndex + 1) % ThemeState.palettes.length;
    setPaletteIndex(nextIdx);
  }

  void previousPalette() {
    final count = ThemeState.palettes.length;
    final prevIdx = (state.paletteIndex - 1 + count) % count;
    setPaletteIndex(prevIdx);
  }

  void setPaletteIndex(int index) {
    if (index < 0 || index >= ThemeState.palettes.length) return;
    state = state.copyWith(paletteIndex: index);
    ref.read(storageServiceProvider).setInt(_paletteKey, index);
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    ref.read(storageServiceProvider).setInt(_modeKey, _indexFromMode(mode));
  }

  /// Sistem / açık / koyu arasında sırayla geçiş yapar — tek dokunuşluk toggle için.
  void cycleThemeMode() {
    const order = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];
    final currentIdx = order.indexOf(state.themeMode);
    setThemeMode(order[(currentIdx + 1) % order.length]);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(() {
  return ThemeNotifier();
});