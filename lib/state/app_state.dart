import 'dart:async';

import 'package:flutter/widgets.dart';

import '../data/models.dart';
import '../data/stats.dart';
import '../data/water_repository.dart';
import '../services/notification_service.dart';
import '../services/reminder_planner.dart';

class AppState extends ChangeNotifier with WidgetsBindingObserver {
  AppState(this._repo, this._notifications);

  final WaterRepository _repo;
  final NotificationService _notifications;

  AppSettings settings = const AppSettings();
  DayLog today = DayLog(date: dateOnly(DateTime.now()), goalMl: defaultGoalMl);
  List<DayLog> history = const [];
  WaterStats stats = WaterStats.empty;
  bool notificationsAllowed = true;
  bool loaded = false;

  Timer? _midnightTimer;

  Future<void> load() async {
    WidgetsBinding.instance.addObserver(this);
    _notifications.onDataChanged = refresh;
    await refresh();
    loaded = true;
    notifyListeners();
  }

  /// Re-reads everything from storage (background isolates may have written)
  /// and rebuilds the reminder plan.
  Future<void> refresh() async {
    settings = await _repo.loadSettings();
    await _reloadDays();
    notificationsAllowed = await _notifications.areEnabled();
    _scheduleMidnightRefresh();
    notifyListeners();
    unawaited(_notifications.reschedule(settings, today));
  }

  Future<void> _reloadDays() async {
    final now = DateTime.now();
    today = await _repo.loadDay(now, fallbackGoalMl: settings.goalMl);
    history = await _repo.loadHistory();
    stats = WaterStats.from(_withToday(history), now);
  }

  /// History plus today's in-memory state (today may not be saved yet).
  List<DayLog> _withToday(List<DayLog> logs) => [
    ...logs.where((d) => d.date != today.date),
    today,
  ];

  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 5);
    _midnightTimer = Timer(nextMidnight.difference(now), refresh);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }

  DateTime? get nextReminder {
    final plan = planReminders(
      settings: settings,
      today: today,
      now: appNow(),
    );
    return plan.isEmpty ? null : plan.first.time;
  }

  Future<void> addDrink(int ml) async {
    today = await _repo.addDrink(ml);
    await _afterTodayChanged();
  }

  Future<void> removeEntry(DrinkEntry entry) async {
    final entries = [...today.entries]..remove(entry);
    today = today.copyWith(entries: entries);
    await _repo.saveDay(today);
    await _afterTodayChanged();
  }

  Future<void> restoreEntry(DrinkEntry entry) async {
    final entries = [...today.entries, entry]
      ..sort((a, b) => a.time.compareTo(b.time));
    today = today.copyWith(entries: entries);
    await _repo.saveDay(today);
    await _afterTodayChanged();
  }

  Future<void> _afterTodayChanged() async {
    final logs = history.where((d) => d.date != today.date).toList()
      ..add(today);
    history = logs;
    stats = WaterStats.from(logs, DateTime.now());
    notifyListeners();
    unawaited(_notifications.reschedule(settings, today));
  }

  Future<void> updateSettings(AppSettings next) async {
    final goalChanged = next.goalMl != settings.goalMl;
    settings = next;
    await _repo.saveSettings(next);
    if (goalChanged) {
      // Today's progress is measured against the new goal from now on.
      today = today.copyWith(goalMl: next.goalMl);
      if (today.entries.isNotEmpty) await _repo.saveDay(today);
      final logs = history.where((d) => d.date != today.date).toList()
        ..add(today);
      history = logs;
      stats = WaterStats.from(logs, DateTime.now());
    }
    notifyListeners();
    unawaited(_notifications.reschedule(settings, today));
  }

  Future<bool> requestNotificationPermission() async {
    await _notifications.requestPermission();
    notificationsAllowed = await _notifications.areEnabled();
    notifyListeners();
    if (notificationsAllowed) {
      unawaited(_notifications.reschedule(settings, today));
    }
    return notificationsAllowed;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _midnightTimer?.cancel();
    super.dispose();
  }
}
