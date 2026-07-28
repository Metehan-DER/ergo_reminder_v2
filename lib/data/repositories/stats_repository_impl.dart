import '../../core/services/storage_service.dart';
import '../../domain/entities/stats_entity.dart';
import '../../domain/repositories/stats_repository.dart';

class StatsRepositoryImpl implements StatsRepository {
  final StorageService _storage;

  StatsRepositoryImpl(this._storage);

  @override
  Future<DailyStatsEntity> getDailyStats(String dateStr) async {
    return DailyStatsEntity(
      date: dateStr,
      completed: _storage.getInt('stat_${dateStr}_completed', defaultValue: 0),
      snoozed: _storage.getInt('stat_${dateStr}_snoozed', defaultValue: 0),
      ignored: _storage.getInt('stat_${dateStr}_ignored', defaultValue: 0),
    );
  }

  @override
  Future<void> saveDailyStats(DailyStatsEntity stats) async {
    await _storage.setInt('stat_${stats.date}_completed', stats.completed);
    await _storage.setInt('stat_${stats.date}_snoozed', stats.snoozed);
    await _storage.setInt('stat_${stats.date}_ignored', stats.ignored);
  }
}
