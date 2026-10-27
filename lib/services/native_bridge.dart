import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/models.dart';
import '../data/water_repository.dart';

const _channel = MethodChannel('dwr/native');

bool get _isAndroid =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

/// Brings over the daily goal and the mute setting saved by the
/// native Android app (v3.0) the first time the Flutter version starts.
Future<void> migrateFromNativeApp(WaterRepository repo) async {
  if (!_isAndroid || await repo.getFlag(WaterRepository.migratedKey)) return;
  try {
    final legacy = await _channel.invokeMapMethod<String, Object?>(
      'readLegacySettings',
    );
    if (legacy != null && legacy.isNotEmpty) {
      var settings = await repo.loadSettings();
      final goal = legacy['waterQuantity'] as int?;
      if (goal != null) {
        settings = settings.copyWith(goalMl: goal.clamp(minGoalMl, maxGoalMl));
      }
      if (legacy['silentMode'] == true) {
        settings = settings.copyWith(remindersEnabled: false);
      }
      // The old glass counter isn't imported: it carried no date, so it may be
      // from an earlier day.
      await repo.saveSettings(settings);
    }
  } on PlatformException catch (e) {
    debugPrint('Legacy migration failed: $e');
  }
  await repo.setFlag(WaterRepository.migratedKey, true);
}

Future<String> adUnitId() async {
  if (!_isAndroid) return '';
  try {
    return await _channel.invokeMethod<String>('adUnitId') ?? '';
  } on PlatformException {
    return '';
  }
}

Future<void> openNotificationSettings() async {
  if (!_isAndroid) return;
  await _channel.invokeMethod<void>('openNotificationSettings');
}
