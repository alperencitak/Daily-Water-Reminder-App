// ignore_for_file: depend_on_referenced_packages
// Renders the app's real screens (no device or emulator) and composes the
// Google Play listing graphics from them.
//
//   flutter test tool/store_assets_test.dart
//
// Output goes to store/screenshots/<lang>/ and store/feature-graphic/.
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:remindertodrinkwaterapp/content/messages.dart';
import 'package:remindertodrinkwaterapp/data/models.dart';
import 'package:remindertodrinkwaterapp/data/stats.dart';
import 'package:remindertodrinkwaterapp/data/water_repository.dart';
import 'package:remindertodrinkwaterapp/l10n/app_localizations.dart';
import 'package:remindertodrinkwaterapp/services/notification_service.dart';
import 'package:remindertodrinkwaterapp/state/app_state.dart';
import 'package:remindertodrinkwaterapp/ui/history_screen.dart';
import 'package:remindertodrinkwaterapp/ui/home_screen.dart';
import 'package:remindertodrinkwaterapp/ui/settings_screen.dart';
import 'package:remindertodrinkwaterapp/ui/theme.dart';
import 'package:remindertodrinkwaterapp/ui/widgets/bob.dart';
import 'package:remindertodrinkwaterapp/ui/widgets/nav_bar.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

const _dpr = 2.625;
const _shotW = 1080.0;
const _shotH = 2340.0;
final _now = DateTime(2026, 10, 28, 14, 20);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _loadFont('Nunito', 'assets/fonts/Nunito.ttf');
    await _loadFont(
      'MaterialIcons',
      'C:/src/flutter/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
    );
    await _loadFont('Emoji', 'C:/Windows/Fonts/seguiemj.ttf');
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/package_info'),
          (call) async => {
            'appName': 'Daily Water Reminder',
            'packageName': 'com.alperencitak.remindertodrinkwaterapp',
            'version': '4.0.0',
            'buildNumber': '11',
            'buildSignature': '',
          },
        );
    appNow = () => _now;
  });

  for (final lang in ['tr', 'en']) {
    testWidgets('store assets ($lang)', (tester) async {
      // flutter_test draws shadows as hard-edged bands unless this is off;
      // it has to be put back before the test ends.
      debugDisableShadows = false;
      final out = 'store/screenshots/$lang';
      final copy = _Copy(lang);
      final locale = Locale(lang);

      tester.view
        ..physicalSize = const Size(_shotW, _shotH)
        ..devicePixelRatio = _dpr
        ..padding = const FakeViewPadding(top: 28 * _dpr, bottom: 16 * _dpr)
        ..viewPadding = const FakeViewPadding(
          top: 28 * _dpr,
          bottom: 16 * _dpr,
        );
      addTearDown(tester.view.reset);

      Future<ui.Image> shot(
        Widget page, {
        required int nav,
        bool dark = false,
        double scroll = 0,
        int? bobSeed,
      }) async {
        messageRandom = Random(bobSeed ?? 1);
        final key = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: key,
            child: _Scene(
              key: UniqueKey(),
              state: _sampleState(),
              page: page,
              nav: nav,
              dark: dark,
              locale: locale,
              opaqueTop: scroll != 0,
            ),
          ),
        );
        for (var i = 0; i < 6; i++) {
          await tester.pump(const Duration(milliseconds: 300));
        }
        // Several short drags: one long drag would leave the screen.
        var remaining = scroll;
        while (remaining > 0) {
          final step = min(remaining, 240.0);
          await tester.drag(
            find.byType(CustomScrollView).first,
            Offset(0, -step),
          );
          await tester.pump(const Duration(milliseconds: 400));
          remaining -= step;
        }
        for (var i = 0; i < 4; i++) {
          await tester.pump(const Duration(milliseconds: 300));
        }
        return _capture(tester, key, _dpr);
      }

      final home = await shot(const HomeScreen(), nav: 0, bobSeed: _bobSeed);
      final homeLog = await shot(const HomeScreen(), nav: 0, scroll: 685);
      final reminders = await shot(const SettingsScreen(), nav: 2, scroll: 480);
      final history = await shot(const HistoryScreen(), nav: 1);
      final goal = await shot(const SettingsScreen(), nav: 2);
      final dark = await shot(
        const HomeScreen(),
        nav: 0,
        dark: true,
        bobSeed: _bobSeed,
      );

      for (final (name, img) in [
        ('raw_home', home),
        ('raw_log', homeLog),
        ('raw_reminders', reminders),
        ('raw_history', history),
        ('raw_goal', goal),
        ('raw_dark', dark),
      ]) {
        await _save(tester, img, 'store/raw/$lang/$name.png');
      }

      final slides = [
        ('01_home', copy.h1, const [0xFF2D8CFF, 0xFF5FD3FF], home, null),
        (
          '02_quick_add',
          copy.h2,
          const [0xFF6C5CE7, 0xFF3A9BFF],
          homeLog,
          null,
        ),
        (
          '03_reminders',
          copy.h3,
          const [0xFF0FB9B1, 0xFF2D8CFF],
          reminders,
          _NotificationCard(lang: lang),
        ),
        ('04_history', copy.h4, const [0xFF2563EB, 0xFF7C3AED], history, null),
        ('05_goal', copy.h5, const [0xFF5FD3FF, 0xFF2D8CFF], goal, null),
        ('06_dark', copy.h6, const [0xFF0C1E33, 0xFF1F4E8C], dark, null),
      ];
      for (final (name, headline, colors, image, overlay) in slides) {
        final key = GlobalKey();
        tester.view
          ..physicalSize = const Size(1080, 1920)
          ..devicePixelRatio = 1
          ..padding = FakeViewPadding.zero
          ..viewPadding = FakeViewPadding.zero;
        await tester.pumpWidget(
          RepaintBoundary(
            key: key,
            child: _Slide(
              headline: headline,
              colors: colors.map(Color.new).toList(),
              image: image,
              overlay: overlay,
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        await _save(tester, await _capture(tester, key, 1), '$out/$name.png');
      }

      // Feature graphic, 1024x500.
      final fKey = GlobalKey();
      tester.view
        ..physicalSize = const Size(1024, 500)
        ..devicePixelRatio = 1;
      await tester.pumpWidget(
        RepaintBoundary(
          key: fKey,
          child: _FeatureGraphic(copy: copy, image: home),
        ),
      );
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
      await _save(
        tester,
        await _capture(tester, fKey, 1),
        'store/feature-graphic/feature_$lang.png',
      );

      // Dispose animated widgets so no timers are left pending.
      await tester.pumpWidget(const SizedBox());
      debugDisableShadows = true;
    });
  }
}

/// Seed for which Bob is cheerful (picked by looking at the output).
const _bobSeed = 13;

Future<void> _loadFont(String family, String path) async {
  final bytes = File(path).readAsBytesSync();
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.sublistView(bytes)));
  await loader.load();
}

Future<ui.Image> _capture(
  WidgetTester tester,
  GlobalKey key,
  double ratio,
) async {
  return (await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    return boundary.toImage(pixelRatio: ratio);
  }))!;
}

Future<void> _save(WidgetTester tester, ui.Image image, String path) async {
  await tester.runAsync(() async {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(data!.buffer.asUint8List());
  });
}

AppState _sampleState() {
  final state = AppState(WaterRepository(), NotificationService.instance);
  state.settings = const AppSettings(
    goalMl: 2400,
    cupMl: 250,
    wakeMinutes: 8 * 60,
    sleepMinutes: 22 * 60 + 30,
  );
  final today = dateOnly(_now);
  DrinkEntry at(int h, int m, int ml) =>
      DrinkEntry(DateTime(today.year, today.month, today.day, h, m), ml);
  state.today = DayLog(
    date: today,
    goalMl: 2400,
    entries: [
      at(8, 10, 250),
      at(9, 25, 200),
      at(10, 45, 330),
      at(11, 50, 250),
      at(12, 40, 250),
      at(13, 30, 250),
    ],
  );
  const past = [
    2500, 2450, 2600, 2420, 1700, 2480, 2200, 2550, 2480, 2430, //
    2500, 2610, 2450, 1900, 2300, 2400, 2520, 2470, 1600, 2410,
    2480, 2500, 2390, 2440, 2560, 2480, 2000, 2430, 2500, 2470,
  ];
  final history = <DayLog>[];
  for (var i = past.length; i >= 1; i--) {
    final date = DateTime(today.year, today.month, today.day - i);
    var left = past[i - 1];
    final entries = <DrinkEntry>[];
    var hour = 8;
    while (left > 0) {
      final ml = min(left, 250 + (hour % 3) * 50);
      entries.add(
        DrinkEntry(DateTime(date.year, date.month, date.day, hour, 5), ml),
      );
      left -= ml;
      hour += 1;
    }
    history.add(DayLog(date: date, goalMl: 2400, entries: entries));
  }
  state.history = history;
  state.stats = WaterStats.from([...history, state.today], _now);
  return state;
}

ThemeData _theme(Brightness b) {
  final t = buildTheme(b);
  return t.copyWith(
    textTheme: t.textTheme.apply(fontFamilyFallback: const ['Emoji']),
  );
}

/// One app screen the way it looks on a phone: fake status bar and the
/// floating navigation bar around the page.
class _Scene extends StatelessWidget {
  const _Scene({
    super.key,
    required this.state,
    required this.page,
    required this.nav,
    required this.dark,
    required this.locale,
    this.opaqueTop = false,
  });

  final AppState state;
  final Widget page;
  final int nav;
  final bool dark;
  final Locale locale;

  /// Solid band behind the status bar, so scrolled content doesn't show
  /// through it.
  final bool opaqueTop;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: state,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        home: Builder(
          builder: (context) {
            final c = context.colors;
            final l10n = AppLocalizations.of(context);
            return Scaffold(
              backgroundColor: c.bgBottom,
              body: GradientBackground(
                child: Stack(
                  children: [
                    Positioned.fill(child: page),
                    if (opaqueTop)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 48,
                        child: ColoredBox(color: c.bgTop),
                      ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 28,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 26),
                        child: Row(
                          children: [
                            Text(
                              DateFormat.jm(locale.languageCode).format(_now),
                              style: nunito(13, 800, color: c.ink),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.signal_cellular_alt_rounded,
                              size: 15,
                              color: c.ink,
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.wifi_rounded, size: 15, color: c.ink),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.battery_full_rounded,
                              size: 17,
                              color: c.ink,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: ColoredBox(
                color: c.bgBottom,
                child: SafeArea(
                  top: false,
                  minimum: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: FloatingNavBar(
                      index: nav,
                      onChanged: (_) {},
                      items: [
                        NavItem(
                          Icons.water_drop_outlined,
                          Icons.water_drop_rounded,
                          l10n.navToday,
                        ),
                        NavItem(
                          Icons.insights_outlined,
                          Icons.insights_rounded,
                          l10n.navHistory,
                        ),
                        NavItem(
                          Icons.tune_outlined,
                          Icons.tune_rounded,
                          l10n.navSettings,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Phone extends StatelessWidget {
  const _Phone({required this.image, required this.screenWidth});

  final ui.Image image;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    const bezel = 16.0;
    final screenHeight = screenWidth * _shotH / _shotW;
    final radius = screenWidth * 0.088;
    return Container(
      padding: const EdgeInsets.all(bezel),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1626),
        borderRadius: BorderRadius.circular(radius + bezel),
        border: Border.all(color: const Color(0xFF2A3C55), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x59000000),
            blurRadius: 70,
            offset: Offset(0, 36),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            RawImage(
              image: image,
              width: screenWidth,
              height: screenHeight,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
            ),
            Positioned(
              top: screenWidth * 0.028,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: screenWidth * 0.032,
                  height: screenWidth * 0.032,
                  decoration: const BoxDecoration(
                    color: Color(0xFF05080F),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({
    required this.headline,
    required this.colors,
    required this.image,
    this.overlay,
  });

  final String headline;
  final List<Color> colors;
  final ui.Image image;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
              ),
            ),
          ),
          // Soft bubbles for depth.
          for (final (x, y, r, a) in const [
            (-120.0, 1100.0, 260.0, 0.10),
            (880.0, 520.0, 200.0, 0.10),
            (760.0, 1500.0, 320.0, 0.07),
            (60.0, 420.0, 90.0, 0.12),
          ])
            Positioned(
              left: x,
              top: y,
              child: Container(
                width: r,
                height: r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: a),
                ),
              ),
            ),
          Positioned(
            top: 96,
            left: 60,
            right: 60,
            child: Text(
              headline,
              textAlign: TextAlign.center,
              style: nunito(
                100,
                900,
                color: Colors.white,
                height: 1.06,
              ).copyWith(fontFamilyFallback: const ['Emoji']),
            ),
          ),
          Positioned(
            top: 400,
            left: (1080 - 872) / 2,
            child: _Phone(image: image, screenWidth: 840),
          ),
          if (overlay != null)
            Positioned(top: 1590, left: 60, right: 60, child: overlay!),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.lang});

  final String lang;

  @override
  Widget build(BuildContext context) {
    final l10n = lookupAppLocalizations(Locale(lang));
    const ink = Color(0xFF16304B);
    const muted = Color(0xFF6B8099);
    return Container(
      padding: const EdgeInsets.fromLTRB(36, 30, 36, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(48),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D0B2A55),
            blurRadius: 60,
            offset: Offset(0, 30),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF5FD3FF), Color(0xFF2D8CFF)],
                  ),
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 18),
              Text(
                '${l10n.appTitle}  ·  ${lang == 'tr' ? 'şimdi' : 'now'}',
                style: nunito(30, 700, color: muted),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(l10n.notifTitle, style: nunito(42, 900, color: ink)),
          const SizedBox(height: 6),
          Text(reminderMessages(lang)[1], style: nunito(34, 600, color: ink)),
          const SizedBox(height: 26),
          Row(
            children: [
              Text(
                l10n.notifActionDrink(250),
                style: nunito(32, 800, color: const Color(0xFF2D8CFF)),
              ),
              const SizedBox(width: 56),
              Text(
                l10n.notifActionSnooze,
                style: nunito(32, 800, color: const Color(0xFF2D8CFF)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureGraphic extends StatelessWidget {
  const _FeatureGraphic({required this.copy, required this.image});

  final _Copy copy;
  final ui.Image image;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2D8CFF), Color(0xFF5FD3FF)],
                ),
              ),
            ),
          ),
          for (final (x, y, r, a) in const [
            (-90.0, 280.0, 280.0, 0.10),
            (560.0, -120.0, 260.0, 0.10),
            (880.0, 330.0, 240.0, 0.08),
          ])
            Positioned(
              left: x,
              top: y,
              child: Container(
                width: r,
                height: r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: a),
                ),
              ),
            ),
          Positioned(
            left: 56,
            top: 60,
            width: 520,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  copy.featureTitle,
                  style: nunito(70, 900, color: Colors.white, height: 1.02),
                ),
                const SizedBox(height: 14),
                Text(
                  copy.featureTagline,
                  style: nunito(
                    28,
                    700,
                    color: Colors.white.withValues(alpha: 0.92),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            left: 70,
            bottom: 6,
            child: Bob(mood: BobMood.lol, size: 120),
          ),
          Positioned(
            left: 640,
            top: 56,
            child: _Phone(image: image, screenWidth: 270),
          ),
        ],
      ),
    );
  }
}

class _Copy {
  _Copy(this.lang);

  final String lang;
  bool get tr => lang == 'tr';

  String get h1 =>
      tr ? 'Su içmeyi\nasla unutma' : 'Never forget\nto drink water';
  String get h2 => tr ? 'Tek dokunuşla\nkaydet' : 'Log every sip\nin one tap';
  String get h3 =>
      tr ? 'Gün boyu akıllı\nhatırlatmalar' : 'Smart reminders\nall day long';
  String get h4 => tr ? 'İlerlemeni\ntakip et' : 'Track your\nprogress';
  String get h5 =>
      tr ? 'Hedefi sana\ngöre ayarla' : 'A goal made\njust for you';
  String get h6 => tr ? 'Açık ve koyu\ntema' : 'Light and dark\nthemes';
  String get featureTitle =>
      tr ? 'Günlük Su\nHatırlatıcı' : 'Daily Water\nReminder';
  String get featureTagline => tr
      ? 'Susuz kalma. Bob sana\ngün boyu hatırlatır.'
      : 'Stay hydrated. Bob will\nremind you all day.';
}
