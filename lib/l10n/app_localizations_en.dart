// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Daily Water Reminder';

  @override
  String get navToday => 'Today';

  @override
  String get navHistory => 'History';

  @override
  String get navSettings => 'Settings';

  @override
  String goalOf(int goal) {
    return 'of $goal ml';
  }

  @override
  String remaining(int ml) {
    return '$ml ml to go';
  }

  @override
  String get goalReached => 'Goal reached! 🎉';

  @override
  String glassesProgress(int count, int total) {
    return '$count / $total glasses';
  }

  @override
  String get addWater => 'Add water';

  @override
  String get customAmount => 'Custom';

  @override
  String get customAmountTitle => 'How much did you drink?';

  @override
  String get undo => 'Undo';

  @override
  String added(int ml) {
    return '+$ml ml added';
  }

  @override
  String get todayLog => 'Today\'s log';

  @override
  String get noEntriesYet => 'No water logged yet today. Bob is waiting! 💧';

  @override
  String get deleteEntry => 'Entry deleted';

  @override
  String nextReminder(String time) {
    return 'Next reminder at $time';
  }

  @override
  String get remindersOff => 'Reminders are off';

  @override
  String get remindersDoneToday => 'No more reminders today';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count day streak',
      one: '1 day streak',
      zero: 'No streak yet',
    );
    return '$_temp0';
  }

  @override
  String get last7Days => 'Last 7 days';

  @override
  String get statAverage => 'Daily average';

  @override
  String get statBestStreak => 'Best streak';

  @override
  String get statCurrentStreak => 'Current streak';

  @override
  String get statGoalDays => 'Goals in 30 days';

  @override
  String daysUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get pastDays => 'Past days';

  @override
  String get noHistory =>
      'Your history will appear here once you start logging water.';

  @override
  String get sectionGoal => 'Daily goal';

  @override
  String get calculateCardTitle => 'Calculate your daily water needs';

  @override
  String get weight => 'Weight';

  @override
  String get selectDailyActivity => 'Select your daily activity level:';

  @override
  String get activity1 => 'I move little during the day';

  @override
  String get activity2 => 'I move a lot during the day';

  @override
  String get activity3 => 'I do light sports';

  @override
  String get activity4 => 'I do heavy sports';

  @override
  String get chooseOneActivity => 'Choose one activity!';

  @override
  String get enterValidWeight => 'Enter a valid weight (30-170 kg)!';

  @override
  String get calculate => 'Calculate';

  @override
  String calculatedResult(int ml) {
    return '$ml ml/day';
  }

  @override
  String get useAsGoal => 'Use as my goal';

  @override
  String get manuallySetWaterQuantity =>
      'Manually set the amount of water per day';

  @override
  String get enterValue => 'Enter value (ml)';

  @override
  String get invalidGoal => 'Enter a value between 900 and 6120 ml';

  @override
  String get set => 'SET';

  @override
  String goalUpdated(int ml) {
    return 'Daily goal set to $ml ml';
  }

  @override
  String currentGoal(int ml) {
    return 'Current goal: $ml ml';
  }

  @override
  String get cupSize => 'Default glass size';

  @override
  String get sectionReminders => 'Reminders';

  @override
  String get reminderNotifications => 'Reminder notifications';

  @override
  String get reminderNotificationsDesc =>
      'Regular reminders throughout the day';

  @override
  String get wakeTime => 'Start (wake up)';

  @override
  String get sleepTime => 'End (bed time)';

  @override
  String get interval => 'Remind every';

  @override
  String intervalAuto(int minutes) {
    return 'Automatic ($minutes min)';
  }

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get stopWhenGoalReached => 'Stop for the day when goal is reached';

  @override
  String get smartSnooze => 'Skip a reminder if I just drank';

  @override
  String get testNotification => 'Send a test notification';

  @override
  String get notificationsBlocked =>
      'Notifications are blocked. Tap to allow them so reminders can reach you.';

  @override
  String get openSettings => 'Open settings';

  @override
  String remindersPerDay(int count) {
    return '$count reminders per day';
  }

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get sectionAbout => 'About';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyOptions => 'Ad privacy options';

  @override
  String get iconsBy => 'Icons by Icons8';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get permissionTitle => 'Stay hydrated with reminders';

  @override
  String get permissionBody =>
      'Allow notifications so Bob can gently remind you to drink water throughout the day. You can change the times anytime.';

  @override
  String get permissionAllow => 'Allow';

  @override
  String get permissionLater => 'Not now';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get notifChannelName => 'Reminder Notifications';

  @override
  String get notifChannelDesc => 'Daily reminders to drink water.';

  @override
  String get notifTitle => 'Time to Drink Water!';

  @override
  String notifActionDrink(int ml) {
    return 'I drank $ml ml';
  }

  @override
  String get notifActionSnooze => 'Remind in 15 min';

  @override
  String get notifMorningTitle => 'Good morning! ☀️';

  @override
  String get notifMorningBody => 'Start your day with a glass of water.';

  @override
  String get notifTestBody => 'Reminders are working. Bob says hi! 👋';

  @override
  String get greetMorning => 'Good morning';

  @override
  String get greetAfternoon => 'Good afternoon';

  @override
  String get greetEvening => 'Good evening';

  @override
  String get greetNight => 'Good night';

  @override
  String percentDone(int percent) {
    return '$percent% done';
  }

  @override
  String get quickAdd => 'Quick add';

  @override
  String get permBullet1 => 'Gentle reminders through your day';

  @override
  String get permBullet2 => 'Goes quiet once you hit your goal';

  @override
  String get permBullet3 => 'Log a glass right from the notification';

  @override
  String get dailyGoal => 'Daily goal';

  @override
  String get enterManually => 'Enter manually';

  @override
  String get activityLevel => 'Activity level';

  @override
  String get activityShort1 => 'Calm';

  @override
  String get activityShort2 => 'Active';

  @override
  String get activityShort3 => 'Light sports';

  @override
  String get activityShort4 => 'Heavy sports';

  @override
  String get recommendedForYou => 'Recommended for you';

  @override
  String get reminderHours => 'Reminder hours';

  @override
  String get smartReminders => 'Smart reminders';

  @override
  String get intervalAutoShort => 'Auto';

  @override
  String get goalLabel => 'Goal';

  @override
  String drinksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count drinks',
      one: '1 drink',
      zero: 'No drinks yet',
    );
    return '$_temp0';
  }

  @override
  String get tapBob => 'Tap Bob for a new tip';

  @override
  String get cupSizeCustomTitle => 'Glass size';

  @override
  String get invalidCup => 'Enter a value between 50 and 1500 ml';
}
