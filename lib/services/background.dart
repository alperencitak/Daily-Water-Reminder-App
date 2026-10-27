import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import 'notification_service.dart';

const _rescheduleTask = 'dwr_reschedule_reminders';

/// WorkManager entry point. Periodically tops up the reminder schedule so
/// reminders keep coming even if the app isn't opened for weeks.
@pragma('vm:entry-point')
void backgroundDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    DartPluginRegistrant.ensureInitialized();
    try {
      await NotificationService.instance.rescheduleFromStorage();
      return true;
    } catch (e) {
      debugPrint('Background reschedule failed: $e');
      return false;
    }
  });
}

Future<void> registerBackgroundRescheduling() async {
  if (defaultTargetPlatform != TargetPlatform.android) return;
  await Workmanager().initialize(backgroundDispatcher);
  await Workmanager().registerPeriodicTask(
    _rescheduleTask,
    _rescheduleTask,
    frequency: const Duration(hours: 12),
    initialDelay: const Duration(hours: 6),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
  );
}
