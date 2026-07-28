import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/stats_repository.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/repositories/stats_repository_impl.dart';
import 'service_providers.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SettingsRepositoryImpl(storage);
});

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return StatsRepositoryImpl(storage);
});
