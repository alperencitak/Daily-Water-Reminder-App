import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../services/native_bridge.dart';
import '../state/app_state.dart';
import 'theme.dart';
import 'widgets/banner_ad.dart';
import 'widgets/cup_icon.dart';

const _privacyPolicyUrl = 'https://sites.google.com/view/dwrprivacypolicy';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverSafeArea(
          bottom: false,
          sliver: SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
            sliver: SliverList.list(
              children: [
                Text(l10n.navSettings, style: nunito(30, 900, color: c.ink)),
                const SizedBox(height: 18),
                const _GoalCard(),
                const SizedBox(height: 16),
                const _CupCard(),
                const SizedBox(height: 16),
                const _ReminderCard(),
                const SizedBox(height: 16),
                const _ThemeCard(),
                const SizedBox(height: 16),
                const _AboutCard(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Building blocks

class _CardTitle extends StatelessWidget {
  const _CardTitle({
    required this.icon,
    required this.title,
    required this.color,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Color color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        _IconTile(icon: icon, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title, style: nunito(18, 900, color: c.ink)),
        ),
        ?trailing,
      ],
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: color, size: 21),
  );
}

/// Rounded pill used for every choice (cup size, interval, ...).
class _Pill extends StatelessWidget {
  const _Pill({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          gradient: selected ? c.accentGradient : null,
          color: selected ? null : c.cardAlt,
          borderRadius: BorderRadius.circular(18),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: c.accent.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: DefaultTextStyle.merge(
          style: nunito(14, 800, color: selected ? Colors.white : c.ink),
          child: IconTheme.merge(
            data: IconThemeData(color: selected ? Colors.white : c.accent),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      scale: 0.98,
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(title, style: nunito(15.5, 750, color: c.ink))],
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Goal

class _GoalCard extends StatelessWidget {
  const _GoalCard();

  Future<void> _setGoal(BuildContext context, int ml) async {
    final state = context.read<AppState>();
    final goal = ml.clamp(minGoalMl, maxGoalMl);
    if (goal == state.settings.goalMl) return;
    await state.updateSettings(state.settings.copyWith(goalMl: goal));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final goal = context.select<AppState, int>((s) => s.settings.goalMl);
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      decoration: BoxDecoration(
        gradient: c.accentGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: c.accent.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.flag_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.dailyGoal,
                style: nunito(
                  16,
                  800,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _GlassButton(
                icon: Icons.remove_rounded,
                onTap: () => _setGoal(context, goal - 100),
              ),
              Expanded(
                child: TweenAnimationBuilder<int>(
                  tween: IntTween(end: goal),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$v',
                          style: nunito(
                            46,
                            900,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        TextSpan(
                          text: ' ml',
                          style: nunito(
                            20,
                            800,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              _GlassButton(
                icon: Icons.add_rounded,
                onTap: () => _setGoal(context, goal + 100),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _WhitePill(
                  icon: Icons.calculate_rounded,
                  label: l10n.calculate,
                  onTap: () async {
                    final ml = await showModalBottomSheet<int>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const _CalculatorSheet(),
                    );
                    if (ml != null && context.mounted) {
                      await _setGoal(context, ml);
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _WhitePill(
                  icon: Icons.edit_rounded,
                  label: l10n.enterManually,
                  onTap: () async {
                    final ml = await showModalBottomSheet<int>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => _ManualGoalSheet(initial: goal),
                    );
                    if (ml != null && context.mounted) {
                      await _setGoal(context, ml);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: () {
      HapticFeedback.selectionClick();
      onTap();
    },
    scale: 0.88,
    child: Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 26),
    ),
  );
}

class _WhitePill extends StatelessWidget {
  const _WhitePill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: c.accentDeep),
            const SizedBox(width: 6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: nunito(14, 800, color: c.accentDeep),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalculatorSheet extends StatefulWidget {
  const _CalculatorSheet();

  @override
  State<_CalculatorSheet> createState() => _CalculatorSheetState();
}

class _CalculatorSheetState extends State<_CalculatorSheet> {
  double _kg = 70;
  int _perKg = 32;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final result = _kg.round() * _perKg;
    final activities = [
      (30, '🛋️', l10n.activityShort1, l10n.activity1),
      (32, '🚶', l10n.activityShort2, l10n.activity2),
      (34, '🚴', l10n.activityShort3, l10n.activity3),
      (36, '🏋️', l10n.activityShort4, l10n.activity4),
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                l10n.calculateCardTitle,
                textAlign: TextAlign.center,
                style: nunito(20, 900, color: c.ink),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(l10n.weight, style: nunito(16, 800, color: c.muted)),
                const Spacer(),
                Text('${_kg.round()} kg', style: nunito(26, 900, color: c.ink)),
              ],
            ),
            Slider(
              value: _kg,
              min: 30,
              max: 170,
              divisions: 140,
              onChanged: (v) {
                if (v.round() != _kg.round()) HapticFeedback.selectionClick();
                setState(() => _kg = v);
              },
            ),
            const SizedBox(height: 8),
            Text(l10n.activityLevel, style: nunito(16, 800, color: c.muted)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.9,
              children: [
                for (final a in activities)
                  Pressable(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _perKg = a.$1);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _perKg == a.$1
                            ? c.accent.withValues(alpha: 0.12)
                            : c.cardAlt,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _perKg == a.$1 ? c.accent : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(a.$2, style: const TextStyle(fontSize: 26)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              a.$3,
                              maxLines: 2,
                              style: nunito(14, 800, color: c.ink),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Center(
              child: Text(
                l10n.recommendedForYou,
                style: nunito(14, 700, color: c.muted),
              ),
            ),
            Center(
              child: TweenAnimationBuilder<int>(
                tween: IntTween(end: result),
                duration: const Duration(milliseconds: 350),
                builder: (context, v, _) =>
                    Text('$v ml', style: nunito(38, 900, color: c.accent)),
              ),
            ),
            const SizedBox(height: 14),
            GradientButton(
              label: l10n.useAsGoal,
              icon: Icons.check_rounded,
              onTap: () => Navigator.pop(context, result),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManualGoalSheet extends StatefulWidget {
  const _ManualGoalSheet({required this.initial});

  final int initial;

  @override
  State<_ManualGoalSheet> createState() => _ManualGoalSheetState();
}

class _ManualGoalSheetState extends State<_ManualGoalSheet> {
  late final _controller = TextEditingController(text: '${widget.initial}');
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(AppLocalizations l10n) {
    final v = int.tryParse(_controller.text);
    if (v == null || v < minGoalMl || v > maxGoalMl) {
      HapticFeedback.heavyImpact();
      setState(() => _error = l10n.invalidGoal);
      return;
    }
    Navigator.pop(context, v);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.manuallySetWaterQuantity,
                textAlign: TextAlign.center,
                style: nunito(20, 900, color: c.ink),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                autofocus: true,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: nunito(34, 900, color: c.ink),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: InputDecoration(
                  suffixText: 'ml',
                  errorText: _error,
                ),
                onChanged: (_) => setState(() => _error = null),
                onSubmitted: (_) => _submit(l10n),
              ),
              const SizedBox(height: 18),
              GradientButton(label: l10n.set, onTap: () => _submit(l10n)),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cup size

class _CupCard extends StatelessWidget {
  const _CupCard();

  Future<void> _custom(BuildContext context, AppState state) async {
    final ml = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CustomCupSheet(initial: state.settings.cupMl),
    );
    if (ml != null) {
      await state.updateSettings(state.settings.copyWith(cupMl: ml));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final state = context.watch<AppState>();
    final current = state.settings.cupMl;
    // A size typed by the user is shown as its own selected pill.
    final sizes = [...cupSizes, if (!cupSizes.contains(current)) current]
      ..sort();

    Widget cupPill(int ml) => _Pill(
      selected: current == ml,
      onTap: () => state.updateSettings(state.settings.copyWith(cupMl: ml)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Builder(
            builder: (context) => CupIcon(
              fill: (ml / 500).clamp(0.2, 1.0),
              size: 18,
              color: IconTheme.of(context).color!,
            ),
          ),
          const SizedBox(width: 6),
          Text('$ml'),
        ],
      ),
    );

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(
            icon: Icons.local_drink_rounded,
            title: l10n.cupSize,
            color: c.aqua,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final ml in sizes) cupPill(ml),
              _Pill(
                selected: false,
                onTap: () => _custom(context, state),
                child: const Icon(Icons.add_rounded, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomCupSheet extends StatefulWidget {
  const _CustomCupSheet({required this.initial});

  final int initial;

  @override
  State<_CustomCupSheet> createState() => _CustomCupSheetState();
}

class _CustomCupSheetState extends State<_CustomCupSheet> {
  late final _controller = TextEditingController(text: '${widget.initial}');
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(AppLocalizations l10n) {
    final v = int.tryParse(_controller.text);
    if (v == null || v < minCupMl || v > maxCupMl) {
      HapticFeedback.heavyImpact();
      setState(() => _error = l10n.invalidCup);
      return;
    }
    Navigator.pop(context, v);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.cupSizeCustomTitle,
                style: nunito(20, 900, color: c.ink),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                autofocus: true,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: nunito(34, 900, color: c.ink),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: InputDecoration(
                  suffixText: 'ml',
                  errorText: _error,
                ),
                onChanged: (_) => setState(() => _error = null),
                onSubmitted: (_) => _submit(l10n),
              ),
              const SizedBox(height: 18),
              GradientButton(label: l10n.ok, onTap: () => _submit(l10n)),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reminders

class _ReminderCard extends StatelessWidget {
  const _ReminderCard();

  Future<int?> _pickTime(BuildContext context, int minutes) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
    );
    return picked == null ? null : picked.hour * 60 + picked.minute;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final state = context.watch<AppState>();
    final s = state.settings;
    final perDay = s.activeMinutes ~/ s.effectiveIntervalMinutes + 1;

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(
            icon: Icons.notifications_active_rounded,
            title: l10n.sectionReminders,
            color: c.warm,
            trailing: Switch(
              value: s.remindersEnabled,
              onChanged: (v) async {
                HapticFeedback.selectionClick();
                if (v && !state.notificationsAllowed) {
                  await state.requestNotificationPermission();
                }
                await state.updateSettings(
                  state.settings.copyWith(remindersEnabled: v),
                );
              },
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            child: !state.notificationsAllowed
                ? Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Pressable(
                      onTap: () async {
                        if (!await state.requestNotificationPermission()) {
                          await openNotificationSettings();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: c.danger.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.notifications_off_rounded,
                              color: c.danger,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.notificationsBlocked,
                                style: nunito(14, 700, color: c.ink),
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: c.danger),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: !s.remindersEnabled
                ? Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      l10n.reminderNotificationsDesc,
                      style: nunito(14, 650, color: c.muted),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 18),
                      Text(
                        l10n.reminderHours,
                        style: nunito(14, 800, color: c.muted),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _TimeTile(
                              icon: Icons.wb_sunny_rounded,
                              color: c.warm,
                              label: l10n.wakeTime,
                              minutes: s.wakeMinutes,
                              onTap: () async {
                                final m = await _pickTime(
                                  context,
                                  s.wakeMinutes,
                                );
                                if (m != null && m != s.sleepMinutes) {
                                  await state.updateSettings(
                                    state.settings.copyWith(wakeMinutes: m),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _TimeTile(
                              icon: Icons.nightlight_round,
                              color: const Color(0xFF7C6CF2),
                              label: l10n.sleepTime,
                              minutes: s.sleepMinutes,
                              onTap: () async {
                                final m = await _pickTime(
                                  context,
                                  s.sleepMinutes,
                                );
                                if (m != null && m != s.wakeMinutes) {
                                  await state.updateSettings(
                                    state.settings.copyWith(sleepMinutes: m),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.interval,
                              style: nunito(14, 800, color: c.muted),
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              l10n.remindersPerDay(perDay),
                              key: ValueKey(perDay),
                              style: nunito(13, 800, color: c.accent),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Pill(
                            selected: s.intervalMinutes == 0,
                            onTap: () => state.updateSettings(
                              s.copyWith(intervalMinutes: 0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${l10n.intervalAutoShort} · ${l10n.minutesShort(s.autoIntervalMinutes)}',
                                ),
                              ],
                            ),
                          ),
                          for (final m in intervalChoices)
                            _Pill(
                              selected: s.intervalMinutes == m,
                              onTap: () => state.updateSettings(
                                s.copyWith(intervalMinutes: m),
                              ),
                              child: Text(l10n.minutesShort(m)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l10n.smartReminders,
                        style: nunito(14, 800, color: c.muted),
                      ),
                      const SizedBox(height: 2),
                      _ToggleRow(
                        title: l10n.stopWhenGoalReached,
                        value: s.stopWhenGoalReached,
                        onChanged: (v) => state.updateSettings(
                          s.copyWith(stopWhenGoalReached: v),
                        ),
                      ),
                      _ToggleRow(
                        title: l10n.smartSnooze,
                        value: s.skipAfterDrink,
                        onChanged: (v) =>
                            state.updateSettings(s.copyWith(skipAfterDrink: v)),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.minutes,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final int minutes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: minutes ~/ 60 % 24, minute: minutes % 60),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.cardAlt,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: nunito(13, 750, color: c.muted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(time, style: nunito(26, 900, color: c.ink)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Appearance

class _ThemeCard extends StatelessWidget {
  const _ThemeCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final state = context.watch<AppState>();
    final options = [
      (ThemeMode.system, l10n.themeSystem, Icons.brightness_auto_rounded),
      (ThemeMode.light, l10n.themeLight, Icons.light_mode_rounded),
      (ThemeMode.dark, l10n.themeDark, Icons.dark_mode_rounded),
    ];
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(
            icon: Icons.palette_rounded,
            title: l10n.sectionAppearance,
            color: const Color(0xFFE76FB0),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final (mode, label, icon) in options) ...[
                if (mode != ThemeMode.system) const SizedBox(width: 10),
                Expanded(
                  child: Pressable(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      state.updateSettings(
                        state.settings.copyWith(themeMode: mode),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: c.cardAlt,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: state.settings.themeMode == mode
                              ? c.accent
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          _ThemePreview(mode: mode),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(icon, size: 15, color: c.muted),
                              const SizedBox(width: 4),
                              Text(label, style: nunito(13, 800, color: c.ink)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.mode});

  final ThemeMode mode;

  @override
  Widget build(BuildContext context) {
    Widget half(AppColors p) => Expanded(
      child: Container(
        color: p.bgBottom,
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [p.card, p.waterFront],
                    stops: const [0.45, 0.46],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 52,
        height: 64,
        child: Row(
          children: switch (mode) {
            ThemeMode.light => [half(AppColors.light)],
            ThemeMode.dark => [half(AppColors.dark)],
            ThemeMode.system => [half(AppColors.light), half(AppColors.dark)],
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// About

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    Widget row(IconData icon, Color color, String label, VoidCallback onTap) =>
        Pressable(
          scale: 0.98,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                _IconTile(icon: icon, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label, style: nunito(15.5, 750, color: c.ink)),
                ),
                Icon(Icons.chevron_right_rounded, color: c.muted),
              ],
            ),
          ),
        );
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
      child: Column(
        children: [
          row(
            Icons.shield_rounded,
            c.success,
            l10n.privacyPolicy,
            () => launchUrl(
              Uri.parse(_privacyPolicyUrl),
              mode: LaunchMode.externalApplication,
            ),
          ),
          FutureBuilder<bool>(
            future: Ads.privacyOptionsRequired(),
            builder: (context, snap) => snap.data == true
                ? row(
                    Icons.ads_click_rounded,
                    c.warm,
                    l10n.privacyOptions,
                    Ads.showPrivacyOptions,
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snap) => Text(
              snap.hasData ? l10n.version(snap.data!.version) : '',
              style: nunito(13, 700, color: c.muted),
            ),
          ),
        ],
      ),
    );
  }
}
