import 'package:flutter_test/flutter_test.dart';
import 'package:remindertodrinkwaterapp/data/models.dart';
import 'package:remindertodrinkwaterapp/data/stats.dart';
import 'package:remindertodrinkwaterapp/services/reminder_planner.dart';

DayLog _day(DateTime date, {int goal = 2000, List<int> drinks = const []}) =>
    DayLog(
      date: dateOnly(date),
      goalMl: goal,
      entries: [for (final ml in drinks) DrinkEntry(date, ml)],
    );

void main() {
  group('planReminders', () {
    const settings = AppSettings(
      goalMl: 2000,
      cupMl: 250,
      wakeMinutes: 9 * 60,
      sleepMinutes: 21 * 60,
      intervalMinutes: 60,
    );

    test('only plans future slots inside the active window', () {
      final now = DateTime(2026, 10, 27, 12, 30);
      final plan = planReminders(
        settings: settings,
        today: _day(now),
        now: now,
      );
      expect(plan.first.time, DateTime(2026, 10, 27, 13));
      final todays = plan.where((r) => dateOnly(r.time) == dateOnly(now));
      expect(todays.map((r) => r.time.hour), [
        13,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
        21,
      ]);
      expect(plan.every((r) => r.time.hour >= 9 && r.time.hour <= 21), isTrue);
      expect(plan.length, lessThanOrEqualTo(maxScheduledReminders));
    });

    test('skips the rest of today once the goal is met, keeps tomorrow', () {
      final now = DateTime(2026, 10, 27, 12, 30);
      final plan = planReminders(
        settings: settings,
        today: _day(now, drinks: [2000]),
        now: now,
      );
      expect(plan.first.time, DateTime(2026, 10, 28, 9));
      expect(plan.first.isFirstOfDay, isTrue);
    });

    test('skips slots right after a drink', () {
      final now = DateTime(2026, 10, 27, 12, 50);
      final today = DayLog(
        date: dateOnly(now),
        goalMl: 2000,
        entries: [DrinkEntry(DateTime(2026, 10, 27, 12, 45), 250)],
      );
      final plan = planReminders(settings: settings, today: today, now: now);
      expect(plan.first.time, DateTime(2026, 10, 27, 14));
    });

    test('handles a bed time after midnight', () {
      final late = settings.copyWith(wakeMinutes: 10 * 60, sleepMinutes: 60);
      final now = DateTime(2026, 10, 27, 23, 30);
      final plan = planReminders(settings: late, today: _day(now), now: now);
      expect(plan.first.time, DateTime(2026, 10, 28, 0));
      expect(plan[1].time, DateTime(2026, 10, 28, 1));
      expect(plan[2].time, DateTime(2026, 10, 28, 10));
    });

    test('nothing when reminders are disabled', () {
      final now = DateTime(2026, 10, 27, 8);
      final plan = planReminders(
        settings: settings.copyWith(remindersEnabled: false),
        today: _day(now),
        now: now,
      );
      expect(plan, isEmpty);
    });

    test('automatic interval spreads glasses over the day', () {
      // 14 h window, 2400 ml in 200 ml glasses = 12 glasses -> 70 min -> 75.
      const s = AppSettings(goalMl: 2400, cupMl: 200);
      expect(s.autoIntervalMinutes, 75);
    });
  });

  group('WaterStats', () {
    test('streaks and averages', () {
      final now = DateTime(2026, 10, 27, 10);
      final history = [
        _day(DateTime(2026, 10, 20), drinks: [2000]),
        _day(DateTime(2026, 10, 21), drinks: [2000]),
        _day(DateTime(2026, 10, 22), drinks: [2000]),
        _day(DateTime(2026, 10, 24), drinks: [500]),
        _day(DateTime(2026, 10, 25), drinks: [2100]),
        _day(DateTime(2026, 10, 26), drinks: [2000]),
        _day(now, drinks: [300]),
      ];
      final stats = WaterStats.from(history, now);
      expect(
        stats.currentStreak,
        2,
      ); // today not finished yet, doesn't break it
      expect(stats.bestStreak, 3);
      expect(stats.goalDaysLast30, 5);
      expect(stats.averageMl, (2000 * 4 + 500 + 2100 + 300) ~/ 7);
    });
  });
}
