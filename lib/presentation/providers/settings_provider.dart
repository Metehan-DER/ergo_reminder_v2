import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/settings_entity.dart';
import 'repository_providers.dart';

class SettingsNotifier extends AsyncNotifier<SettingsEntity> {
  @override
  Future<SettingsEntity> build() async {
    return ref.watch(settingsRepositoryProvider).getSettings();
  }

  Future<void> updateSettings(SettingsEntity newSettings) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(settingsRepositoryProvider).saveSettings(newSettings);
      state = AsyncValue.data(newSettings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, SettingsEntity>(() {
  return SettingsNotifier();
});
