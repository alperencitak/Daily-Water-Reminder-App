import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../content/messages.dart';
import '../data/models.dart';
import '../data/water_repository.dart';
import '../l10n/app_localizations.dart';
import 'reminder_planner.dart';

const _channelId =
    'reminder_notifications'; // same id as the native app, keeps user's channel settings
const _actionDrink = 'drink';
const _actionSnooze = 'snooze';
const _snoozeId = 900000;
const _signatureKey = 'schedule_signature';

/// Called by the plugin in a background isolate when a notification action
/// (e.g. "I drank 200 ml") is tapped while the app isn't running.
@pragma('vm:entry-point')
Future<void> onBackgroundNotificationResponse(
  NotificationResponse response,
) async {
  DartPluginRegistrant.ensureInitialized();
  await NotificationService.instance.init();
  await NotificationService.instance.handleAction(response);
}

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  final _repo = WaterRepository();
  bool _initialized = false;

  /// Fired (in the UI isolate) after a notification action changed stored data.
  VoidCallback? onDataChanged;

  Future<void> init({
    DidReceiveNotificationResponseCallback? onForegroundResponse,
  }) async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Unknown zone id: use a fixed zone with the device's current offset.
      final hours = DateTime.now().timeZoneOffset.inHours;
      final name = hours == 0
          ? 'Etc/UTC'
          : 'Etc/GMT${hours > 0 ? '-' : '+'}${hours.abs()}';
      tz.setLocalLocation(tz.getLocation(name));
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_water'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse:
          onForegroundResponse ??
          (response) async {
            if (await handleAction(response)) onDataChanged?.call();
          },
      onDidReceiveBackgroundNotificationResponse:
          onBackgroundNotificationResponse,
    );
    _initialized = true;
  }

  AppLocalizations get _l10n {
    final locale = PlatformDispatcher.instance.locale;
    final supported = AppLocalizations.supportedLocales.any(
      (l) => l.languageCode == locale.languageCode,
    );
    return lookupAppLocalizations(
      Locale(supported ? locale.languageCode : 'en'),
    );
  }

  String get _languageCode => _l10n.localeName;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  Future<bool> areEnabled() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _android?.areNotificationsEnabled() ?? false;
    }
    final perms = await _ios?.checkPermissions();
    return perms?.isEnabled ?? true;
  }

  Future<bool> requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _android?.requestNotificationsPermission() ?? false;
    }
    return await _ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;
  }

  NotificationDetails _details({required int cupMl, bool withActions = true}) {
    final l10n = _l10n;
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        l10n.notifChannelName,
        channelDescription: l10n.notifChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
        icon: 'ic_stat_water',
        color: const Color(0xFF1E88E5),
        styleInformation: const DefaultStyleInformation(true, true),
        actions: withActions
            ? [
                AndroidNotificationAction(
                  _actionDrink,
                  l10n.notifActionDrink(cupMl),
                  icon: const DrawableResourceAndroidBitmap('ic_action_drink'),
                ),
                AndroidNotificationAction(
                  _actionSnooze,
                  l10n.notifActionSnooze,
                ),
              ]
            : null,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  /// Cancels every pending reminder and schedules the plan for the coming days.
  /// Safe to call often: on start, resume, after drinking, after setting changes,
  /// and from the periodic background task.
  Future<void> rescheduleFromStorage() async {
    final settings = await _repo.loadSettings();
    final today = await _repo.loadDay(
      DateTime.now(),
      fallbackGoalMl: settings.goalMl,
    );
    await reschedule(settings, today);
  }

  Future<void> reschedule(AppSettings settings, DayLog today) {
    // Run one at a time; a burst of calls (start + resume + worker) shouldn't
    // interleave cancel/schedule.
    final run = _queue.then((_) => _reschedule(settings, today));
    _queue = run.catchError((Object e) => debugPrint('Reschedule failed: $e'));
    return _queue;
  }

  Future<void> _queue = Future.value();

  Future<void> _reschedule(AppSettings settings, DayLog today) async {
    await init();
    final plan = planReminders(
      settings: settings,
      today: today,
      now: DateTime.now(),
    );

    // Everything the plan depends on besides the clock. If it's unchanged and
    // the pending reminders are still there, the schedule is already right.
    final signature = jsonEncode([
      settings.toJson(),
      dayKey(today.date),
      today.goalMet,
      today.lastDrink?.millisecondsSinceEpoch,
      _languageCode,
    ]);
    final pending = (await _plugin.pendingNotificationRequests())
        .where((r) => r.id < _snoozeId)
        .length;
    if (pending == plan.length &&
        await _repo.getString(_signatureKey) == signature) {
      return;
    }

    await _plugin.cancelAllPendingNotifications();
    await _repo.setString(_signatureKey, signature);
    if (plan.isEmpty) return;

    final l10n = _l10n;
    final messages = reminderMessages(_languageCode);
    final details = _details(cupMl: settings.cupMl);
    var id = 1;
    for (final reminder in plan) {
      final t = reminder.time;
      final when = tz.TZDateTime(
        tz.local,
        t.year,
        t.month,
        t.day,
        t.hour,
        t.minute,
      );
      await _plugin.zonedSchedule(
        id: id++,
        scheduledDate: when,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: reminder.isFirstOfDay ? l10n.notifMorningTitle : l10n.notifTitle,
        body: reminder.isFirstOfDay
            ? l10n.notifMorningBody
            : pickRandom(messages),
      );
    }
  }

  /// Handles notification taps/actions. Returns true if stored data changed.
  Future<bool> handleAction(NotificationResponse response) async {
    switch (response.actionId) {
      case _actionDrink:
        final settings = await _repo.loadSettings();
        final today = await _repo.addDrink(settings.cupMl);
        await reschedule(settings, today);
        return true;
      case _actionSnooze:
        final settings = await _repo.loadSettings();
        final l10n = _l10n;
        await _plugin.zonedSchedule(
          id: _snoozeId,
          scheduledDate: tz.TZDateTime.now(
            tz.local,
          ).add(const Duration(minutes: 15)),
          notificationDetails: _details(cupMl: settings.cupMl),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          title: l10n.notifTitle,
          body: pickRandom(reminderMessages(_languageCode)),
        );
        return false;
      default:
        return false;
    }
  }
}
