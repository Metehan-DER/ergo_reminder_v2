import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/stats_repository.dart';
import '../../domain/repositories/todo_repository.dart';
import '../../domain/repositories/water_repository.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../data/repositories/stats_repository_impl.dart';
import '../../data/repositories/todo_repository_impl.dart';
import '../../data/repositories/water_repository_impl.dart';
import 'service_providers.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SettingsRepositoryImpl(storage);
});

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return StatsRepositoryImpl(storage);
});

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return TodoRepositoryImpl(storage);
});

/// WaterRepository provider — [WaterNotifier]'ın storage'a doğrudan
/// bağımlılığını ortadan kaldırır (DIP).
final waterRepositoryProvider = Provider<WaterRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return WaterRepositoryImpl(storage);
});
