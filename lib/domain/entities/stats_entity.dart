class DailyStatsEntity {
  final int completed;
  final int snoozed;
  final int ignored;
  final String date;

  const DailyStatsEntity({
    required this.completed,
    required this.snoozed,
    required this.ignored,
    required this.date,
  });

  DailyStatsEntity copyWith({
    int? completed,
    int? snoozed,
    int? ignored,
    String? date,
  }) {
    return DailyStatsEntity(
      completed: completed ?? this.completed,
      snoozed: snoozed ?? this.snoozed,
      ignored: ignored ?? this.ignored,
      date: date ?? this.date,
    );
  }
}
