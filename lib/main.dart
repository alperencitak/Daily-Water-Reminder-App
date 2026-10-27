import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'data/water_repository.dart';
import 'l10n/app_localizations.dart';
import 'services/background.dart';
import 'services/native_bridge.dart';
import 'services/notification_service.dart';
import 'state/app_state.dart';
import 'ui/history_screen.dart';
import 'ui/home_screen.dart';
import 'ui/settings_screen.dart';
import 'ui/theme.dart';
import 'ui/widgets/banner_ad.dart';
import 'ui/widgets/nav_bar.dart';
import 'ui/widgets/permission_sheet.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = WaterRepository();
  await migrateFromNativeApp(repo);
  await NotificationService.instance.init();

  final state = AppState(repo, NotificationService.instance);
  await state.load();

  runApp(ChangeNotifierProvider.value(value: state, child: const WaterApp()));

  unawaited(registerBackgroundRescheduling());
  unawaited(Ads.init());
}

class WaterApp extends StatelessWidget {
  const WaterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<AppState, ThemeMode>(
      (s) => s.settings.themeMode,
    );
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: themeMode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell>
    with SingleTickerProviderStateMixin {
  int _index = 0;

  /// Plays on every tab change: the new page fades and slides up slightly.
  late final AnimationController _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
    value: 1,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _enter,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _askForNotifications());
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  /// Explains why before showing the system prompt, once.
  Future<void> _askForNotifications() async {
    final state = context.read<AppState>();
    final repo = WaterRepository();
    if (state.notificationsAllowed ||
        await repo.getFlag(WaterRepository.permissionAskedKey)) {
      return;
    }
    await repo.setFlag(WaterRepository.permissionAskedKey, true);
    if (!mounted) return;
    if (await showPermissionSheet(context)) {
      await state.requestNotificationPermission();
    }
  }

  void _select(int i) {
    if (i == _index) return;
    setState(() => _index = i);
    _enter.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: c.bgBottom,
            systemNavigationBarIconBrightness: dark
                ? Brightness.light
                : Brightness.dark,
          ),
      child: Scaffold(
        backgroundColor: c.bgBottom,
        body: GradientBackground(
          child: Column(
            children: [
              // Banner sits at the very top, under the status bar.
              ValueListenableBuilder<bool>(
                valueListenable: Ads.bannerVisible,
                builder: (context, visible, child) => Padding(
                  padding: EdgeInsets.only(
                    top: visible ? MediaQuery.paddingOf(context).top : 0,
                  ),
                  child: child,
                ),
                child: const BannerAdView(),
              ),
              Expanded(
                child: ValueListenableBuilder<bool>(
                  valueListenable: Ads.bannerVisible,
                  // With a banner on top the status bar inset is already used.
                  builder: (context, visible, child) =>
                      MediaQuery.removePadding(
                        context: context,
                        removeTop: visible,
                        child: child!,
                      ),
                  // IndexedStack keeps every tab alive (scroll position,
                  // state) but only paints the selected one, so pages can
                  // never overlap.
                  child: FadeTransition(
                    opacity: _curve,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.03),
                        end: Offset.zero,
                      ).animate(_curve),
                      child: IndexedStack(
                        index: _index,
                        children: const [
                          HomeScreen(),
                          HistoryScreen(),
                          SettingsScreen(),
                        ],
                      ),
                    ),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingNavBar(
                    index: _index,
                    onChanged: _select,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
