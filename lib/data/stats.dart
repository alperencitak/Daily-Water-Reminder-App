import 'models.dart';

class WaterStats {
  const WaterStats({
    required this.currentStreak,
    required this.bestStreak,
    required this.averageMl,
    required this.goalDaysLast30,
  });

  final int currentStreak;
  final int bestStreak;
  final int averageMl;
  final int goalDaysLast30;

  static const empty = WaterStats(
    currentStreak: 0,
    bestStreak: 0,
    averageMl: 0,
    goalDaysLast30: 0,
  );

  /// [history] must be sorted oldest first. Today counts towards the current
  /// streak only once its goal is met, so an unfinished today doesn't break it.
  factory WaterStats.from(List<DayLog> history, DateTime now) {
    final today = dateOnly(now);
    final metDays = {
      for (final d in history)
        if (d.goalMet) d.date,
    };

    var current = 0;
    var cursor = metDays.contains(today)
        ? today
        : DateTime(today.year, today.month, today.day - 1);
    while (metDays.contains(cursor)) {
      current++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }

    var best = 0;
    var run = 0;
    DateTime? previous;
    for (final d in history) {
      if (!d.goalMet) {
        run = 0;
        previous = d.date;
        continue;
      }
      final consecutive =
          previous != null &&
          DateTime(previous.year, previous.month, previous.day + 1) == d.date;
      run = consecutive && run > 0 ? run + 1 : 1;
      if (run > best) best = run;
      previous = d.date;
    }

    final from30 = DateTime(today.year, today.month, today.day - 29);
    final recent = history.where((d) => !d.date.isBefore(from30)).toList();
    final logged = recent.where((d) => d.totalMl > 0).toList();
    final average = logged.isEmpty
        ? 0
        : logged.fold<int>(0, (s, d) => s + d.totalMl) ~/ logged.length;

    return WaterStats(
      currentStreak: current,
      bestStreak: best < current ? current : best,
      averageMl: average,
      goalDaysLast30: recent.where((d) => d.goalMet).length,
    );
  }
}
