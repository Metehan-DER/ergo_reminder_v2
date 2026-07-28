import '../entities/stats_entity.dart';

abstract class StatsRepository {
  Future<DailyStatsEntity> getDailyStats(String dateStr);
  Future<void> saveDailyStats(DailyStatsEntity stats);
}
