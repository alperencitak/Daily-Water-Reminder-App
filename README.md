Daily Water Reminder is an open source project that reminds the user to drink water regularly. The application calculates the amount of water the user should drink daily and reminds them to drink at regular intervals throughout the day.

Since version 4.0 the app is written in **Flutter** (previously Jetpack Compose). It keeps the same package name, so it updates the existing Play Store app in place and carries over the user's daily goal.

## **Key Features**
- Daily water requirement calculation (weight + activity level) and manual goal
- Regular reminders between your wake-up and bed time, automatic or custom interval
- Reminders stop for the day once the goal is reached, and skip a slot right after you drink
- "I drank" and "Remind in 15 min" buttons right on the notification, works without opening the app
- Reminders survive reboots and app updates, and are topped up in the background
- Quick add with different glass sizes, custom amount, undo, today's log
- History: last 7 days chart, streaks, daily average, goals met
- Bob, the water mascot, reacts to your progress
- Light / dark theme, English and Turkish

## **Technology Stack**
- Flutter, Provider
- flutter_local_notifications + timezone (scheduled reminders), WorkManager (background top-up)
- shared_preferences (local storage)
- Google Mobile Ads with UMP consent

## **Building a release**

1. Put your upload keystore details in `android/key.properties` (never commit it):
   ```properties
   storeFile=C:/path/to/upload-keystore.jks
   storePassword=...
   keyAlias=...
   keyPassword=...
   ```
2. Provide the AdMob IDs the same way as before, as Gradle properties (for example in `~/.gradle/gradle.properties`):
   ```properties
   ADMOB_APP_ID=ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy
   ADMOB_AD_UNIT_ID=ca-app-pub-xxxxxxxxxxxxxxxx/zzzzzzzzzz
   ```
   Debug builds always use Google's test ads; a release build without `ADMOB_AD_UNIT_ID` shows no ads.
3. Bump `version:` in `pubspec.yaml` (`name+versionCode`), then:
   ```bash
   flutter build appbundle --release
   ```
   The bundle is written to `build/app/outputs/bundle/release/app-release.aab`.

## **Screenshots**

![Image](https://github.com/user-attachments/assets/b8a4e444-b569-4c81-974e-a5f4346d60f8) ![Image](https://github.com/user-attachments/assets/d5565e38-fc0b-423f-a44a-80b235df8266)
