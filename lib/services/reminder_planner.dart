import 'dart:math';

import '../data/models.dart';

class PlannedReminder {
  const PlannedReminder(this.time, {this.isFirstOfDay = false});

  final DateTime time;
  final bool isFirstOfDay;
}

/// Android allows ~500 alarms per app, and each scheduled notification is
/// persisted by the plugin, so keep the window short. The periodic background
/// task and every app start extend it.
const maxScheduledReminders = 96;
const maxPlanDays = 5;

/// Works out when reminders should fire, as plain local times.
///
/// Reminders are scheduled as individual one-off notifications for the next
/// days (instead of one repeating alarm) so today's can be skipped once the
/// goal is reached while tomorrow's still fire, even if the app isn't opened.
List<PlannedReminder> planReminders({
  required AppSettings settings,
  required DayLog today,
  required DateTime now,
}) {
  if (!settings.remindersEnabled) return const [];

  final interval = settings.effectiveIntervalMinutes;
  final slotsPerDay = settings.activeMinutes ~/ interval + 1;
  final days = (maxScheduledReminders ~/ slotsPerDay).clamp(2, maxPlanDays);
  final todayDate = dateOnly(now);
  final skipToday = settings.stopWhenGoalReached && today.goalMet;

  DateTime? skipUntil;
  final lastDrink = today.lastDrink;
  if (settings.skipAfterDrink && lastDrink != null) {
    skipUntil = lastDrink.add(Duration(minutes: max(15, interval ~/ 2)));
  }

  final result = <PlannedReminder>[];
  // Start at -1 so a window that runs past midnight (e.g. 10:00 → 01:00)
  // still yields tonight's late slots.
  for (var offset = -1; offset < days; offset++) {
    final windowStart = DateTime(
      todayDate.year,
      todayDate.month,
      todayDate.day + offset,
      0,
      settings.wakeMinutes,
    );
    for (var k = 0; k * interval <= settings.activeMinutes; k++) {
      final time = windowStart.add(Duration(minutes: k * interval));
      if (!time.isAfter(now.add(const Duration(minutes: 1)))) continue;
      final belongsToToday = offset <= 0;
      if (belongsToToday) {
        if (skipToday) continue;
        if (skipUntil != null && time.isBefore(skipUntil)) continue;
      }
      result.add(PlannedReminder(time, isFirstOfDay: k == 0));
      if (result.length >= maxScheduledReminders) return result;
    }
  }
  return result;
}
