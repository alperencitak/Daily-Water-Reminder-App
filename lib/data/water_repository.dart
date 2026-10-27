import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// Persistent storage. Uses [SharedPreferencesAsync] (no in-memory cache) so the
/// UI isolate and background isolates (notification actions, WorkManager) always
/// see each other's writes.
class WaterRepository {
  WaterRepository([SharedPreferencesAsync? prefs])
    : _prefs = prefs ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _prefs;

  static const _settingsKey = 'settings';
  static const _dayPrefix = 'day_';
  static const migratedKey = 'migrated_native_v3';
  static const permissionAskedKey = 'permission_asked';

  Future<AppSettings> loadSettings() async {
    final raw = await _prefs.getString(_settingsKey);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) =>
      _prefs.setString(_settingsKey, jsonEncode(settings.toJson()));

  Future<DayLog> loadDay(DateTime day, {required int fallbackGoalMl}) async {
    final date = dateOnly(day);
    final raw = await _prefs.getString('$_dayPrefix${dayKey(date)}');
    if (raw == null) return DayLog(date: date, goalMl: fallbackGoalMl);
    try {
      return DayLog.fromJson(date, jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return DayLog(date: date, goalMl: fallbackGoalMl);
    }
  }

  Future<void> saveDay(DayLog log) => _prefs.setString(
    '$_dayPrefix${dayKey(log.date)}',
    jsonEncode(log.toJson()),
  );

  /// Logs from the last [days] days (oldest first). Days without a record are
  /// omitted.
  Future<List<DayLog>> loadHistory({int days = 365}) async {
    final today = dateOnly(DateTime.now());
    final keys = <String, DateTime>{};
    for (var i = 0; i < days; i++) {
      final d = DateTime(today.year, today.month, today.day - i);
      keys['$_dayPrefix${dayKey(d)}'] = d;
    }
    final all = await _prefs.getAll(allowList: keys.keys.toSet());
    final logs = <DayLog>[];
    for (final entry in all.entries) {
      final value = entry.value;
      if (value is! String) continue;
      try {
        logs.add(
          DayLog.fromJson(
            keys[entry.key]!,
            jsonDecode(value) as Map<String, dynamic>,
          ),
        );
      } catch (_) {}
    }
    logs.sort((a, b) => a.date.compareTo(b.date));
    return logs;
  }

  /// Adds a drink to today's log and returns the updated day.
  Future<DayLog> addDrink(int ml, {DateTime? at}) async {
    final now = at ?? DateTime.now();
    final settings = await loadSettings();
    final day = await loadDay(now, fallbackGoalMl: settings.goalMl);
    final updated = day.copyWith(
      goalMl: settings.goalMl,
      entries: [...day.entries, DrinkEntry(now, ml)],
    );
    await saveDay(updated);
    return updated;
  }

  Future<String?> getString(String key) => _prefs.getString(key);

  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  Future<bool> getFlag(String key) async => await _prefs.getBool(key) ?? false;

  Future<void> setFlag(String key, bool value) => _prefs.setBool(key, value);
}
