// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Günlük Su Hatırlatıcı';

  @override
  String get navToday => 'Bugün';

  @override
  String get navHistory => 'Geçmiş';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String goalOf(int goal) {
    return '/ $goal ml';
  }

  @override
  String remaining(int ml) {
    return '$ml ml kaldı';
  }

  @override
  String get goalReached => 'Hedefe ulaştın! 🎉';

  @override
  String glassesProgress(int count, int total) {
    return '$count / $total bardak';
  }

  @override
  String get addWater => 'Su ekle';

  @override
  String get customAmount => 'Özel';

  @override
  String get customAmountTitle => 'Ne kadar su içtin?';

  @override
  String get undo => 'Geri al';

  @override
  String added(int ml) {
    return '+$ml ml eklendi';
  }

  @override
  String get todayLog => 'Bugünkü kayıtlar';

  @override
  String get noEntriesYet => 'Bugün henüz su kaydı yok. Bob seni bekliyor! 💧';

  @override
  String get deleteEntry => 'Kayıt silindi';

  @override
  String nextReminder(String time) {
    return 'Sonraki hatırlatma $time';
  }

  @override
  String get remindersOff => 'Hatırlatmalar kapalı';

  @override
  String get remindersDoneToday => 'Bugün başka hatırlatma yok';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count günlük seri',
      zero: 'Henüz seri yok',
    );
    return '$_temp0';
  }

  @override
  String get last7Days => 'Son 7 gün';

  @override
  String get statAverage => 'Günlük ortalama';

  @override
  String get statBestStreak => 'En uzun seri';

  @override
  String get statCurrentStreak => 'Güncel seri';

  @override
  String get statGoalDays => 'Son 30 günde hedef';

  @override
  String daysUnit(int count) {
    return '$count gün';
  }

  @override
  String get pastDays => 'Önceki günler';

  @override
  String get noHistory =>
      'Su kaydetmeye başladığında geçmişin burada görünecek.';

  @override
  String get sectionGoal => 'Günlük hedef';

  @override
  String get calculateCardTitle => 'Günlük su ihtiyacınızı hesaplayın';

  @override
  String get weight => 'Kilo';

  @override
  String get selectDailyActivity => 'Günlük aktivite seviyenizi seçin:';

  @override
  String get activity1 => 'Gün boyunca çok az hareket ederim';

  @override
  String get activity2 => 'Gün boyunca çok hareket ederim';

  @override
  String get activity3 => 'Hafif spor yaparım';

  @override
  String get activity4 => 'Ağır spor yaparım';

  @override
  String get chooseOneActivity => 'Bir aktivite seçin!';

  @override
  String get enterValidWeight => 'Geçerli bir kilo girin (30-170 kg)!';

  @override
  String get calculate => 'Hesapla';

  @override
  String calculatedResult(int ml) {
    return '$ml ml/gün';
  }

  @override
  String get useAsGoal => 'Hedefim olarak kullan';

  @override
  String get manuallySetWaterQuantity =>
      'Günlük su miktarını manuel olarak ayarla';

  @override
  String get enterValue => 'Değer girin (ml)';

  @override
  String get invalidGoal => '900 ile 6120 ml arasında bir değer girin';

  @override
  String get set => 'AYARLA';

  @override
  String goalUpdated(int ml) {
    return 'Günlük hedef $ml ml olarak ayarlandı';
  }

  @override
  String currentGoal(int ml) {
    return 'Mevcut hedef: $ml ml';
  }

  @override
  String get cupSize => 'Varsayılan bardak boyutu';

  @override
  String get sectionReminders => 'Hatırlatmalar';

  @override
  String get reminderNotifications => 'Hatırlatma bildirimleri';

  @override
  String get reminderNotificationsDesc => 'Gün boyunca düzenli hatırlatmalar';

  @override
  String get wakeTime => 'Başlangıç (uyanma)';

  @override
  String get sleepTime => 'Bitiş (yatma)';

  @override
  String get interval => 'Hatırlatma sıklığı';

  @override
  String intervalAuto(int minutes) {
    return 'Otomatik ($minutes dk)';
  }

  @override
  String minutesShort(int minutes) {
    return '$minutes dk';
  }

  @override
  String get stopWhenGoalReached => 'Hedefe ulaşınca o gün için sustur';

  @override
  String get smartSnooze => 'Az önce içtiysem hatırlatmayı atla';

  @override
  String get testNotification => 'Deneme bildirimi gönder';

  @override
  String get notificationsBlocked =>
      'Bildirimler kapalı. Hatırlatmaların sana ulaşması için dokunup izin ver.';

  @override
  String get openSettings => 'Ayarları aç';

  @override
  String remindersPerDay(int count) {
    return 'Günde $count hatırlatma';
  }

  @override
  String get sectionAppearance => 'Görünüm';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get sectionAbout => 'Hakkında';

  @override
  String get privacyPolicy => 'Gizlilik Politikası';

  @override
  String get privacyOptions => 'Reklam gizlilik seçenekleri';

  @override
  String get iconsBy => 'İkonlar: Icons8';

  @override
  String version(String version) {
    return 'Sürüm $version';
  }

  @override
  String get permissionTitle => 'Hatırlatmalarla susuz kalma';

  @override
  String get permissionBody =>
      'Bob\'un gün boyunca sana nazikçe su içmeyi hatırlatabilmesi için bildirimlere izin ver. Saatleri istediğin zaman değiştirebilirsin.';

  @override
  String get permissionAllow => 'İzin ver';

  @override
  String get permissionLater => 'Şimdi değil';

  @override
  String get cancel => 'İptal';

  @override
  String get ok => 'Tamam';

  @override
  String get notifChannelName => 'Hatırlatma Bildirimleri';

  @override
  String get notifChannelDesc => 'Günlük su içme hatırlatmaları.';

  @override
  String get notifTitle => 'Su İçme Zamanı!';

  @override
  String notifActionDrink(int ml) {
    return '$ml ml içtim';
  }

  @override
  String get notifActionSnooze => '15 dk sonra hatırlat';

  @override
  String get notifMorningTitle => 'Günaydın! ☀️';

  @override
  String get notifMorningBody => 'Güne bir bardak su ile başla.';

  @override
  String get notifTestBody => 'Hatırlatmalar çalışıyor. Bob selam söylüyor! 👋';

  @override
  String get greetMorning => 'Günaydın';

  @override
  String get greetAfternoon => 'İyi günler';

  @override
  String get greetEvening => 'İyi akşamlar';

  @override
  String get greetNight => 'İyi geceler';

  @override
  String percentDone(int percent) {
    return '%$percent tamam';
  }

  @override
  String get quickAdd => 'Hızlı ekle';

  @override
  String get permBullet1 => 'Gün boyu nazik hatırlatmalar';

  @override
  String get permBullet2 => 'Hedefine ulaşınca susar';

  @override
  String get permBullet3 => 'Bildirimden tek dokunuşla kaydet';

  @override
  String get dailyGoal => 'Günlük hedef';

  @override
  String get enterManually => 'Elle gir';

  @override
  String get activityLevel => 'Aktivite seviyen';

  @override
  String get activityShort1 => 'Sakin';

  @override
  String get activityShort2 => 'Hareketli';

  @override
  String get activityShort3 => 'Hafif spor';

  @override
  String get activityShort4 => 'Ağır spor';

  @override
  String get recommendedForYou => 'Sana önerilen';

  @override
  String get reminderHours => 'Hatırlatma saatleri';

  @override
  String get smartReminders => 'Akıllı hatırlatmalar';

  @override
  String get intervalAutoShort => 'Oto';

  @override
  String get goalLabel => 'Hedef';

  @override
  String drinksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kayıt',
      zero: 'Henüz kayıt yok',
    );
    return '$_temp0';
  }

  @override
  String get tapBob => 'Yeni bir söz için Bob\'a dokun';

  @override
  String get cupSizeCustomTitle => 'Bardak boyutu';

  @override
  String get invalidCup => '50 ile 1500 ml arasında bir değer girin';
}
