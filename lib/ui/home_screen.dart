import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../content/messages.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import 'theme.dart';
import 'widgets/bob.dart';
import 'widgets/confetti.dart';
import 'widgets/cup_icon.dart';
import 'widgets/water_progress.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ({BobMood mood, String line})? _bob;
  BobSituation? _bobSituation;
  int _jump = 0;
  int _confetti = 0;

  ({BobMood mood, String line}) _bobFor(
    AppState state,
    String languageCode, {
    bool fresh = false,
  }) {
    // Keep Bob's line stable across rebuilds; change it when his situation
    // does (caught up, goal reached, bed time) or when he's tapped.
    final situation = bobSituation(
      progress: state.today.progress,
      now: appNow(),
    );
    if (fresh || _bob == null || _bobSituation != situation) {
      _bobSituation = situation;
      _bob = pickBob(
        languageCode: languageCode,
        progress: state.today.progress,
        now: appNow(),
      );
    }
    return _bob!;
  }

  Future<void> _add(AppState state, int ml) async {
    HapticFeedback.mediumImpact();
    final wasMet = state.today.goalMet;
    setState(() => _jump++);
    await state.addDrink(ml);
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final reached = !wasMet && state.today.goalMet;
    if (reached) {
      HapticFeedback.heavyImpact();
      setState(() => _confetti++);
    }
    final entry = state.today.entries.last;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(reached ? l10n.goalReached : l10n.added(ml)),
          duration: const Duration(seconds: 3),
          persist: false,
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () => state.removeEntry(entry),
          ),
        ),
      );
  }

  Future<void> _customAmount(AppState state) async {
    final ml = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CustomAmountSheet(initial: state.settings.cupMl),
    );
    if (ml != null) await _add(state, ml);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final today = state.today;
    final bob = _bobFor(state, l10n.localeName);

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverSafeArea(
              bottom: false,
              sliver: SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 24),
                sliver: SliverList.list(
                  children: [
                    _Header(state: state),
                    const SizedBox(height: 18),
                    _Hero(
                      today: today,
                      bob: bob,
                      jump: _jump,
                      onBobTap: () {
                        HapticFeedback.lightImpact();
                        setState(
                          () => _bobFor(state, l10n.localeName, fresh: true),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _ReminderPill(state: state),
                    const SizedBox(height: 24),
                    _SectionTitle(l10n.quickAdd),
                    const SizedBox(height: 12),
                    _QuickAdd(
                      cupMl: state.settings.cupMl,
                      onAdd: (ml) => _add(state, ml),
                      onUndo: today.entries.isEmpty
                          ? null
                          : () {
                              HapticFeedback.selectionClick();
                              state.removeEntry(today.entries.last);
                            },
                      onCustom: () => _customAmount(state),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(child: _SectionTitle(l10n.todayLog)),
                        Text(
                          l10n.drinksCount(today.entries.length),
                          style: nunito(14, 700, color: c.muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _TodayLog(state: state),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned.fill(child: Confetti(trigger: _confetti)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: nunito(20, 900, color: context.colors.ink));
}

class _Header extends StatelessWidget {
  const _Header({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final hour = appNow().hour;
    final greeting = switch (hour) {
      >= 5 && < 12 => '${l10n.greetMorning} ☀️',
      >= 12 && < 18 => '${l10n.greetAfternoon} 🌤️',
      >= 18 && < 23 => '${l10n.greetEvening} 🌙',
      _ => '${l10n.greetNight} 💤',
    };
    final date = DateFormat.MMMMEEEEd(l10n.localeName).format(appNow());
    final streak = state.stats.currentStreak;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: nunito(14, 700, color: c.muted)),
              const SizedBox(height: 2),
              Text(greeting, style: nunito(26, 900, color: c.ink)),
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            gradient: streak > 0
                ? const LinearGradient(
                    colors: [Color(0xFFFFB547), Color(0xFFFF7E5F)],
                  )
                : null,
            color: streak > 0 ? null : c.card,
            borderRadius: BorderRadius.circular(20),
            boxShadow: c.softShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                '$streak',
                style: nunito(
                  16,
                  900,
                  color: streak > 0 ? Colors.white : c.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Big card: water level, amount, Bob floating on the surface with a speech bubble.
class _Hero extends StatelessWidget {
  const _Hero({
    required this.today,
    required this.bob,
    required this.jump,
    required this.onBobTap,
  });

  final DayLog today;
  final ({BobMood mood, String line}) bob;
  final int jump;
  final VoidCallback onBobTap;

  static const _height = 400.0;
  static const _bobSize = 92.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final percent = (today.progress * 100).round();
    final mood = today.goalMet
        ? (bob.mood == BobMood.sleep ? BobMood.sleep : BobMood.love)
        : bob.mood;

    return Container(
      height: _height,
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(36),
        boxShadow: c.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: today.progress.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 1100),
        curve: Curves.easeOutCubic,
        builder: (context, level, _) {
          final bobH = _bobSize * 1.3;
          final waterTop = _height * (1 - level);
          final bobBottom = (waterTop + bobH * 0.32).clamp(
            205.0 + bobH,
            _height - 6,
          );
          return Stack(
            children: [
              Positioned.fill(child: WaterFill(level: level)),
              Positioned(
                left: 22,
                right: 22,
                top: 20,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TweenAnimationBuilder<int>(
                            tween: IntTween(end: today.totalMl),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                            builder: (context, v, _) => Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '$v',
                                    style: nunito(
                                      46,
                                      900,
                                      color: c.ink,
                                      height: 1,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' ml',
                                    style: nunito(20, 800, color: c.muted),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            today.goalMet
                                ? l10n.goalReached
                                : l10n.remaining(today.goalMl - today.totalMl),
                            style: nunito(15, 700, color: c.muted),
                          ),
                        ],
                      ),
                    ),
                    _ProgressRing(
                      progress: today.progress,
                      // Turkish puts the percent sign first.
                      label: l10n.localeName == 'tr'
                          ? '%$percent'
                          : '$percent%',
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 22,
                right: 22,
                top: 118,
                child: _SpeechBubble(text: bob.line),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: bobBottom - bobH,
                child: Center(
                  child: Bob(
                    mood: mood,
                    size: _bobSize,
                    jumpTrigger: jump,
                    onTap: onBobTap,
                  ),
                ),
              ),
              Positioned(
                right: 18,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${l10n.goalLabel} ${today.goalMl} ml',
                    style: nunito(13, 800, color: const Color(0xFF1F6FE5)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.progress, required this.label});

  final double progress;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox.square(
      dimension: 66,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: progress.clamp(0.0, 1.0)),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => CustomPaint(
          painter: _RingPainter(v, c.accent, c.divider),
          child: Center(
            child: Text(label, style: nunito(15, 900, color: c.ink)),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.color, this.track);

  final double value;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect.deflate(4), 0, 2 * pi, false, stroke..color = track);
    canvas.drawArc(
      rect.deflate(4),
      -pi / 2,
      2 * pi * value,
      false,
      stroke..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color;
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, a) => FadeTransition(
        opacity: a,
        child: ScaleTransition(
          scale: Tween(begin: 0.92, end: 1.0).animate(a),
          child: child,
        ),
      ),
      child: Column(
        key: ValueKey(text),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: c.cardAlt,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: nunito(14.5, 700, color: c.ink, height: 1.3),
            ),
          ),
          CustomPaint(
            size: const Size(20, 10),
            painter: _TailPainter(c.cardAlt),
          ),
        ],
      ),
    );
  }
}

class _TailPainter extends CustomPainter {
  _TailPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(size.width / 2, size.height * 1.4, size.width, 0)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_TailPainter old) => old.color != color;
}

class _ReminderPill extends StatelessWidget {
  const _ReminderPill({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final next = state.nextReminder;
    final String text;
    final IconData icon;
    if (!state.settings.remindersEnabled || !state.notificationsAllowed) {
      text = l10n.remindersOff;
      icon = Icons.notifications_off_rounded;
    } else if (next == null || dateOnly(next) != state.today.date) {
      text = l10n.remindersDoneToday;
      icon = Icons.bedtime_rounded;
    } else {
      text = l10n.nextReminder(DateFormat.Hm(l10n.localeName).format(next));
      icon = Icons.notifications_active_rounded;
    }
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Container(
          key: ValueKey(text),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(20),
            boxShadow: c.softShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: c.accent),
              const SizedBox(width: 8),
              Text(text, style: nunito(14, 800, color: c.ink)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAdd extends StatelessWidget {
  const _QuickAdd({
    required this.cupMl,
    required this.onAdd,
    required this.onUndo,
    required this.onCustom,
  });

  final int cupMl;
  final ValueChanged<int> onAdd;
  final VoidCallback? onUndo;
  final VoidCallback onCustom;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final others = ({150, 250, 330, 500}..remove(cupMl)).take(3).toList()
      ..sort();
    return Column(
      children: [
        Row(
          children: [
            Pressable(
              onTap: onUndo,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: c.card,
                  shape: BoxShape.circle,
                  boxShadow: c.softShadow,
                ),
                child: Icon(Icons.undo_rounded, color: c.accent, size: 26),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Pressable(
                onTap: () => onAdd(cupMl),
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: c.accentGradient,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: c.accent.withValues(alpha: 0.4),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CupIcon(fill: 0.6, size: 30, color: Colors.white),
                      const SizedBox(width: 10),
                      Text(
                        '+$cupMl ml',
                        style: nunito(22, 900, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final ml in others) ...[
              Expanded(
                child: _CupButton(ml: ml, onTap: () => onAdd(ml)),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Pressable(
                onTap: onCustom,
                child: Container(
                  height: 92,
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: c.softShadow,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: c.cardAlt,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add_rounded, color: c.accent),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.customAmount,
                        style: nunito(13, 800, color: c.ink),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CupButton extends StatelessWidget {
  const _CupButton({required this.ml, required this.onTap});

  final int ml;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 92,
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: c.softShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupIcon(
              fill: (ml / 500).clamp(0.25, 1.0),
              size: 34,
              color: c.accent,
            ),
            const SizedBox(height: 8),
            Text('$ml ml', style: nunito(13, 800, color: c.ink)),
          ],
        ),
      ),
    );
  }
}

class _TodayLog extends StatelessWidget {
  const _TodayLog({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final entries = state.today.entries.reversed.toList();
    if (entries.isEmpty) {
      return SoftCard(
        child: Row(
          children: [
            const Text('💧', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                l10n.noEntriesYet,
                style: nunito(15, 700, color: c.muted),
              ),
            ),
          ],
        ),
      );
    }
    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0)
              Divider(height: 1, indent: 72, endIndent: 18, color: c.divider),
            _EntryRow(
              key: ValueKey(entries[i].time),
              entry: entries[i],
              onDelete: () {
                final entry = entries[i];
                state.removeEntry(entry);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(l10n.deleteEntry),
                      persist: false,
                      action: SnackBarAction(
                        label: l10n.undo,
                        onPressed: () => state.restoreEntry(entry),
                      ),
                    ),
                  );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({super.key, required this.entry, required this.onDelete});

  final DrinkEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final locale = AppLocalizations.of(context).localeName;
    return Dismissible(
      key: ValueKey(entry.time),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: c.danger.withValues(alpha: 0.12),
        child: Icon(Icons.delete_rounded, color: c.danger),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: c.cardAlt,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: CupIcon(
                  fill: (entry.ml / 500).clamp(0.25, 1.0),
                  size: 24,
                  color: c.accent,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                '${entry.ml} ml',
                style: nunito(16, 800, color: c.ink),
              ),
            ),
            Text(
              DateFormat.Hm(locale).format(entry.time),
              style: nunito(14, 700, color: c.muted),
            ),
            const SizedBox(width: 4),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onDelete,
              icon: Icon(Icons.close_rounded, size: 20, color: c.muted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet to log any amount: big number, slider and quick steppers.
class _CustomAmountSheet extends StatefulWidget {
  const _CustomAmountSheet({required this.initial});

  final int initial;

  @override
  State<_CustomAmountSheet> createState() => _CustomAmountSheetState();
}

class _CustomAmountSheetState extends State<_CustomAmountSheet> {
  late double _ml = widget.initial.toDouble();

  void _step(int d) {
    HapticFeedback.selectionClick();
    setState(() => _ml = (_ml + d).clamp(50, 1500));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.customAmountTitle, style: nunito(20, 900, color: c.ink)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RoundIcon(icon: Icons.remove_rounded, onTap: () => _step(-50)),
                const SizedBox(width: 18),
                CupIcon(
                  fill: (_ml / 1000).clamp(0.15, 1.0),
                  size: 56,
                  color: c.accent,
                ),
                const SizedBox(width: 18),
                _RoundIcon(icon: Icons.add_rounded, onTap: () => _step(50)),
              ],
            ),
            const SizedBox(height: 12),
            Text('${_ml.round()} ml', style: nunito(36, 900, color: c.ink)),
            Slider(
              value: _ml,
              min: 50,
              max: 1500,
              divisions: 29,
              onChanged: (v) {
                if (v.round() != _ml.round()) HapticFeedback.selectionClick();
                setState(() => _ml = v);
              },
            ),
            const SizedBox(height: 8),
            GradientButton(
              label: l10n.addWater,
              onTap: () => Navigator.pop(context, _ml.round()),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(color: c.cardAlt, shape: BoxShape.circle),
        child: Icon(icon, color: c.accent, size: 28),
      ),
    );
  }
}
