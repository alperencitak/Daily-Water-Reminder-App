import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Water Reminder'**
  String get appTitle;

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @goalOf.
  ///
  /// In en, this message translates to:
  /// **'of {goal} ml'**
  String goalOf(int goal);

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'{ml} ml to go'**
  String remaining(int ml);

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached! 🎉'**
  String get goalReached;

  /// No description provided for @glassesProgress.
  ///
  /// In en, this message translates to:
  /// **'{count} / {total} glasses'**
  String glassesProgress(int count, int total);

  /// No description provided for @addWater.
  ///
  /// In en, this message translates to:
  /// **'Add water'**
  String get addWater;

  /// No description provided for @customAmount.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customAmount;

  /// No description provided for @customAmountTitle.
  ///
  /// In en, this message translates to:
  /// **'How much did you drink?'**
  String get customAmountTitle;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'+{ml} ml added'**
  String added(int ml);

  /// No description provided for @todayLog.
  ///
  /// In en, this message translates to:
  /// **'Today\'s log'**
  String get todayLog;

  /// No description provided for @noEntriesYet.
  ///
  /// In en, this message translates to:
  /// **'No water logged yet today. Bob is waiting! 💧'**
  String get noEntriesYet;

  /// No description provided for @deleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get deleteEntry;

  /// No description provided for @nextReminder.
  ///
  /// In en, this message translates to:
  /// **'Next reminder at {time}'**
  String nextReminder(String time);

  /// No description provided for @remindersOff.
  ///
  /// In en, this message translates to:
  /// **'Reminders are off'**
  String get remindersOff;

  /// No description provided for @remindersDoneToday.
  ///
  /// In en, this message translates to:
  /// **'No more reminders today'**
  String get remindersDoneToday;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No streak yet} =1{1 day streak} other{{count} day streak}}'**
  String streakDays(int count);

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @statAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily average'**
  String get statAverage;

  /// No description provided for @statBestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get statBestStreak;

  /// No description provided for @statCurrentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get statCurrentStreak;

  /// No description provided for @statGoalDays.
  ///
  /// In en, this message translates to:
  /// **'Goals in 30 days'**
  String get statGoalDays;

  /// No description provided for @daysUnit.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String daysUnit(int count);

  /// No description provided for @pastDays.
  ///
  /// In en, this message translates to:
  /// **'Past days'**
  String get pastDays;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'Your history will appear here once you start logging water.'**
  String get noHistory;

  /// No description provided for @sectionGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get sectionGoal;

  /// No description provided for @calculateCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Calculate your daily water needs'**
  String get calculateCardTitle;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @selectDailyActivity.
  ///
  /// In en, this message translates to:
  /// **'Select your daily activity level:'**
  String get selectDailyActivity;

  /// No description provided for @activity1.
  ///
  /// In en, this message translates to:
  /// **'I move little during the day'**
  String get activity1;

  /// No description provided for @activity2.
  ///
  /// In en, this message translates to:
  /// **'I move a lot during the day'**
  String get activity2;

  /// No description provided for @activity3.
  ///
  /// In en, this message translates to:
  /// **'I do light sports'**
  String get activity3;

  /// No description provided for @activity4.
  ///
  /// In en, this message translates to:
  /// **'I do heavy sports'**
  String get activity4;

  /// No description provided for @chooseOneActivity.
  ///
  /// In en, this message translates to:
  /// **'Choose one activity!'**
  String get chooseOneActivity;

  /// No description provided for @enterValidWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid weight (30-170 kg)!'**
  String get enterValidWeight;

  /// No description provided for @calculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get calculate;

  /// No description provided for @calculatedResult.
  ///
  /// In en, this message translates to:
  /// **'{ml} ml/day'**
  String calculatedResult(int ml);

  /// No description provided for @useAsGoal.
  ///
  /// In en, this message translates to:
  /// **'Use as my goal'**
  String get useAsGoal;

  /// No description provided for @manuallySetWaterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Manually set the amount of water per day'**
  String get manuallySetWaterQuantity;

  /// No description provided for @enterValue.
  ///
  /// In en, this message translates to:
  /// **'Enter value (ml)'**
  String get enterValue;

  /// No description provided for @invalidGoal.
  ///
  /// In en, this message translates to:
  /// **'Enter a value between 900 and 6120 ml'**
  String get invalidGoal;

  /// No description provided for @set.
  ///
  /// In en, this message translates to:
  /// **'SET'**
  String get set;

  /// No description provided for @goalUpdated.
  ///
  /// In en, this message translates to:
  /// **'Daily goal set to {ml} ml'**
  String goalUpdated(int ml);

  /// No description provided for @currentGoal.
  ///
  /// In en, this message translates to:
  /// **'Current goal: {ml} ml'**
  String currentGoal(int ml);

  /// No description provided for @cupSize.
  ///
  /// In en, this message translates to:
  /// **'Default glass size'**
  String get cupSize;

  /// No description provided for @sectionReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get sectionReminders;

  /// No description provided for @reminderNotifications.
  ///
  /// In en, this message translates to:
  /// **'Reminder notifications'**
  String get reminderNotifications;

  /// No description provided for @reminderNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Regular reminders throughout the day'**
  String get reminderNotificationsDesc;

  /// No description provided for @wakeTime.
  ///
  /// In en, this message translates to:
  /// **'Start (wake up)'**
  String get wakeTime;

  /// No description provided for @sleepTime.
  ///
  /// In en, this message translates to:
  /// **'End (bed time)'**
  String get sleepTime;

  /// No description provided for @interval.
  ///
  /// In en, this message translates to:
  /// **'Remind every'**
  String get interval;

  /// No description provided for @intervalAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic ({minutes} min)'**
  String intervalAuto(int minutes);

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesShort(int minutes);

  /// No description provided for @stopWhenGoalReached.
  ///
  /// In en, this message translates to:
  /// **'Stop for the day when goal is reached'**
  String get stopWhenGoalReached;

  /// No description provided for @smartSnooze.
  ///
  /// In en, this message translates to:
  /// **'Skip a reminder if I just drank'**
  String get smartSnooze;

  /// No description provided for @testNotification.
  ///
  /// In en, this message translates to:
  /// **'Send a test notification'**
  String get testNotification;

  /// No description provided for @notificationsBlocked.
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked. Tap to allow them so reminders can reach you.'**
  String get notificationsBlocked;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @remindersPerDay.
  ///
  /// In en, this message translates to:
  /// **'{count} reminders per day'**
  String remindersPerDay(int count);

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyOptions.
  ///
  /// In en, this message translates to:
  /// **'Ad privacy options'**
  String get privacyOptions;

  /// No description provided for @iconsBy.
  ///
  /// In en, this message translates to:
  /// **'Icons by Icons8'**
  String get iconsBy;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @permissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay hydrated with reminders'**
  String get permissionTitle;

  /// No description provided for @permissionBody.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications so Bob can gently remind you to drink water throughout the day. You can change the times anytime.'**
  String get permissionBody;

  /// No description provided for @permissionAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get permissionAllow;

  /// No description provided for @permissionLater.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get permissionLater;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @notifChannelName.
  ///
  /// In en, this message translates to:
  /// **'Reminder Notifications'**
  String get notifChannelName;

  /// No description provided for @notifChannelDesc.
  ///
  /// In en, this message translates to:
  /// **'Daily reminders to drink water.'**
  String get notifChannelDesc;

  /// No description provided for @notifTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to Drink Water!'**
  String get notifTitle;

  /// No description provided for @notifActionDrink.
  ///
  /// In en, this message translates to:
  /// **'I drank {ml} ml'**
  String notifActionDrink(int ml);

  /// No description provided for @notifActionSnooze.
  ///
  /// In en, this message translates to:
  /// **'Remind in 15 min'**
  String get notifActionSnooze;

  /// No description provided for @notifMorningTitle.
  ///
  /// In en, this message translates to:
  /// **'Good morning! ☀️'**
  String get notifMorningTitle;

  /// No description provided for @notifMorningBody.
  ///
  /// In en, this message translates to:
  /// **'Start your day with a glass of water.'**
  String get notifMorningBody;

  /// No description provided for @notifTestBody.
  ///
  /// In en, this message translates to:
  /// **'Reminders are working. Bob says hi! 👋'**
  String get notifTestBody;

  /// No description provided for @greetMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetMorning;

  /// No description provided for @greetAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetAfternoon;

  /// No description provided for @greetEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetEvening;

  /// No description provided for @greetNight.
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get greetNight;

  /// No description provided for @percentDone.
  ///
  /// In en, this message translates to:
  /// **'{percent}% done'**
  String percentDone(int percent);

  /// No description provided for @quickAdd.
  ///
  /// In en, this message translates to:
  /// **'Quick add'**
  String get quickAdd;

  /// No description provided for @permBullet1.
  ///
  /// In en, this message translates to:
  /// **'Gentle reminders through your day'**
  String get permBullet1;

  /// No description provided for @permBullet2.
  ///
  /// In en, this message translates to:
  /// **'Goes quiet once you hit your goal'**
  String get permBullet2;

  /// No description provided for @permBullet3.
  ///
  /// In en, this message translates to:
  /// **'Log a glass right from the notification'**
  String get permBullet3;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily goal'**
  String get dailyGoal;

  /// No description provided for @enterManually.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get enterManually;

  /// No description provided for @activityLevel.
  ///
  /// In en, this message translates to:
  /// **'Activity level'**
  String get activityLevel;

  /// No description provided for @activityShort1.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get activityShort1;

  /// No description provided for @activityShort2.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activityShort2;

  /// No description provided for @activityShort3.
  ///
  /// In en, this message translates to:
  /// **'Light sports'**
  String get activityShort3;

  /// No description provided for @activityShort4.
  ///
  /// In en, this message translates to:
  /// **'Heavy sports'**
  String get activityShort4;

  /// No description provided for @recommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get recommendedForYou;

  /// No description provided for @reminderHours.
  ///
  /// In en, this message translates to:
  /// **'Reminder hours'**
  String get reminderHours;

  /// No description provided for @smartReminders.
  ///
  /// In en, this message translates to:
  /// **'Smart reminders'**
  String get smartReminders;

  /// No description provided for @intervalAutoShort.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get intervalAutoShort;

  /// No description provided for @goalLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goalLabel;

  /// No description provided for @drinksCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No drinks yet} =1{1 drink} other{{count} drinks}}'**
  String drinksCount(int count);

  /// No description provided for @tapBob.
  ///
  /// In en, this message translates to:
  /// **'Tap Bob for a new tip'**
  String get tapBob;

  /// No description provided for @cupSizeCustomTitle.
  ///
  /// In en, this message translates to:
  /// **'Glass size'**
  String get cupSizeCustomTitle;

  /// No description provided for @invalidCup.
  ///
  /// In en, this message translates to:
  /// **'Enter a value between 50 and 1500 ml'**
  String get invalidCup;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
