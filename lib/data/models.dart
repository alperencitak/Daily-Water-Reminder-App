import 'dart:math';

import 'package:flutter/material.dart';

const minGoalMl = 900;
const maxGoalMl = 6120;
const defaultGoalMl = 2400;
const defaultCupMl = 200;
const cupSizes = [150, 200, 250, 330, 500];
const minCupMl = 50;
const maxCupMl = 1500;
const intervalChoices = [30, 60, 90, 120];

class AppSettings {
  const AppSettings({
    this.goalMl = defaultGoalMl,
    this.cupMl = defaultCupMl,
    this.remindersEnabled = true,
    this.wakeMinutes = 9 * 60,
    this.sleepMinutes = 23 * 60,
    this.intervalMinutes = 0,
    this.stopWhenGoalReached = true,
    this.skipAfterDrink = true,
    this.themeMode = ThemeMode.system,
  });

  final int goalMl;
  final int cupMl;
  final bool remindersEnabled;

  /// Minutes after midnight. [sleepMinutes] may be smaller than [wakeMinutes]
  /// for people who go to bed after midnight.
  final int wakeMinutes;
  final int sleepMinutes;

  /// 0 means "automatic": spread the glasses evenly over the active hours.
  final int intervalMinutes;
  final bool stopWhenGoalReached;
  final bool skipAfterDrink;
  final ThemeMode themeMode;

  int get activeMinutes {
    final span = sleepMinutes - wakeMinutes;
    return span > 0 ? span : span + 24 * 60;
  }

  int get glassesPerDay => max(1, (goalMl / cupMl).ceil());

  int get autoIntervalMinutes {
    final raw = activeMinutes / glassesPerDay;
    // Round to a friendly 15 minute step, kept in a sensible range.
    final rounded = (raw / 15).round() * 15;
    return rounded.clamp(30, 180);
  }

  int get effectiveIntervalMinutes =>
      intervalMinutes > 0 ? intervalMinutes : autoIntervalMinutes;

  AppSettings copyWith({
    int? goalMl,
    int? cupMl,
    bool? remindersEnabled,
    int? wakeMinutes,
    int? sleepMinutes,
    int? intervalMinutes,
    bool? stopWhenGoalReached,
    bool? skipAfterDrink,
    ThemeMode? themeMode,
  }) {
    return AppSettings(
      goalMl: goalMl ?? this.goalMl,
      cupMl: cupMl ?? this.cupMl,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      wakeMinutes: wakeMinutes ?? this.wakeMinutes,
      sleepMinutes: sleepMinutes ?? this.sleepMinutes,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      stopWhenGoalReached: stopWhenGoalReached ?? this.stopWhenGoalReached,
      skipAfterDrink: skipAfterDrink ?? this.skipAfterDrink,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, Object> toJson() => {
    'goalMl': goalMl,
    'cupMl': cupMl,
    'remindersEnabled': remindersEnabled,
    'wakeMinutes': wakeMinutes,
    'sleepMinutes': sleepMinutes,
    'intervalMinutes': intervalMinutes,
    'stopWhenGoalReached': stopWhenGoalReached,
    'skipAfterDrink': skipAfterDrink,
    'themeMode': themeMode.name,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    const d = AppSettings();
    return AppSettings(
      goalMl: json['goalMl'] as int? ?? d.goalMl,
      cupMl: json['cupMl'] as int? ?? d.cupMl,
      remindersEnabled: json['remindersEnabled'] as bool? ?? d.remindersEnabled,
      wakeMinutes: json['wakeMinutes'] as int? ?? d.wakeMinutes,
      sleepMinutes: json['sleepMinutes'] as int? ?? d.sleepMinutes,
      intervalMinutes: json['intervalMinutes'] as int? ?? d.intervalMinutes,
      stopWhenGoalReached:
          json['stopWhenGoalReached'] as bool? ?? d.stopWhenGoalReached,
      skipAfterDrink: json['skipAfterDrink'] as bool? ?? d.skipAfterDrink,
      themeMode: ThemeMode.values.firstWhere(
        (m) => m.name == json['themeMode'],
        orElse: () => d.themeMode,
      ),
    );
  }
}

class DrinkEntry {
  const DrinkEntry(this.time, this.ml);

  final DateTime time;
  final int ml;

  List<int> toJson() => [time.millisecondsSinceEpoch, ml];

  factory DrinkEntry.fromJson(List<dynamic> json) => DrinkEntry(
    DateTime.fromMillisecondsSinceEpoch(json[0] as int),
    json[1] as int,
  );
}

/// Everything logged on one calendar day, plus the goal that applied that day
/// (so changing the goal later doesn't rewrite history).
class DayLog {
  const DayLog({
    required this.date,
    required this.goalMl,
    this.entries = const [],
  });

  final DateTime date;
  final int goalMl;
  final List<DrinkEntry> entries;

  int get totalMl => entries.fold(0, (sum, e) => sum + e.ml);
  bool get goalMet => totalMl >= goalMl;
  double get progress => goalMl == 0 ? 0 : totalMl / goalMl;
  DateTime? get lastDrink => entries.isEmpty ? null : entries.last.time;

  DayLog copyWith({int? goalMl, List<DrinkEntry>? entries}) => DayLog(
    date: date,
    goalMl: goalMl ?? this.goalMl,
    entries: entries ?? this.entries,
  );

  Map<String, Object> toJson() => {
    'g': goalMl,
    'e': entries.map((e) => e.toJson()).toList(),
  };

  factory DayLog.fromJson(DateTime date, Map<String, dynamic> json) => DayLog(
    date: date,
    goalMl: json['g'] as int? ?? defaultGoalMl,
    entries: (json['e'] as List<dynamic>? ?? const [])
        .map((e) => DrinkEntry.fromJson(e as List<dynamic>))
        .toList(),
  );
}

/// The clock the UI reads. Tests and the store screenshot tool replace it to
/// freeze the time of day.
DateTime Function() appNow = DateTime.now;

DateTime dateOnly(DateTime t) => DateTime(t.year, t.month, t.day);

String dayKey(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
