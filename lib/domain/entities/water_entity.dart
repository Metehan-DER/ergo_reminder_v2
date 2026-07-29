class WaterLogEntity {
  final String date; // YYYY-MM-DD
  final int consumedMl;
  final int goalMl;
  final int glassSizeMl;

  const WaterLogEntity({
    required this.date,
    required this.consumedMl,
    this.goalMl = 2000,
    this.glassSizeMl = 250,
  });

  int get consumedGlasses => (consumedMl / glassSizeMl).floor();
  int get goalGlasses => (goalMl / glassSizeMl).ceil();
  double get progressRatio => goalMl > 0 ? (consumedMl / goalMl).clamp(0.0, 1.0) : 0.0;
  bool get isGoalReached => consumedMl >= goalMl;

  WaterLogEntity copyWith({
    String? date,
    int? consumedMl,
    int? goalMl,
    int? glassSizeMl,
  }) {
    return WaterLogEntity(
      date: date ?? this.date,
      consumedMl: consumedMl ?? this.consumedMl,
      goalMl: goalMl ?? this.goalMl,
      glassSizeMl: glassSizeMl ?? this.glassSizeMl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'consumedMl': consumedMl,
      'goalMl': goalMl,
      'glassSizeMl': glassSizeMl,
    };
  }

  factory WaterLogEntity.fromJson(Map<String, dynamic> json) {
    return WaterLogEntity(
      date: json['date'] as String? ?? '',
      consumedMl: json['consumedMl'] as int? ?? 0,
      goalMl: json['goalMl'] as int? ?? 2000,
      glassSizeMl: json['glassSizeMl'] as int? ?? 250,
    );
  }
}
