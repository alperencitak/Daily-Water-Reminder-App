import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import 'theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    final stats = state.stats;
    final today = state.today.date;

    final byDate = {for (final d in state.history) d.date: d}
      ..[today] = state.today;
    final week = [
      for (var i = 6; i >= 0; i--)
        byDate[DateTime(today.year, today.month, today.day - i)] ??
            DayLog(
              date: DateTime(today.year, today.month, today.day - i),
              goalMl: state.settings.goalMl,
            ),
    ];
    final past = state.history
        .where((d) => d.date != today && d.totalMl > 0)
        .toList()
        .reversed
        .toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverSafeArea(
          bottom: false,
          sliver: SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
            sliver: SliverList.list(
              children: [
                Text(l10n.navHistory, style: nunito(30, 900, color: c.ink)),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        emoji: '🔥',
                        tint: c.warm,
                        value: l10n.daysUnit(stats.currentStreak),
                        label: l10n.statCurrentStreak,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatTile(
                        emoji: '🏆',
                        tint: const Color(0xFFFFC94D),
                        value: l10n.daysUnit(stats.bestStreak),
                        label: l10n.statBestStreak,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        emoji: '💧',
                        tint: c.accent,
                        value: '${stats.averageMl} ml',
                        label: l10n.statAverage,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatTile(
                        emoji: '🎯',
                        tint: c.success,
                        value: l10n.daysUnit(stats.goalDaysLast30),
                        label: l10n.statGoalDays,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SoftCard(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.last7Days,
                        style: nunito(18, 900, color: c.ink),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(height: 200, child: _WeekChart(days: week)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(l10n.pastDays, style: nunito(20, 900, color: c.ink)),
                const SizedBox(height: 12),
                if (past.isEmpty)
                  SoftCard(
                    child: Row(
                      children: [
                        const Text('📅', style: TextStyle(fontSize: 26)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            l10n.noHistory,
                            style: nunito(15, 700, color: c.muted),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SoftCard(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        for (var i = 0; i < past.length; i++) ...[
                          if (i > 0)
                            Divider(
                              height: 1,
                              indent: 76,
                              endIndent: 18,
                              color: c.divider,
                            ),
                          _DayRow(day: past[i]),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.emoji,
    required this.tint,
    required this.value,
    required this.label,
  });

  final String emoji;
  final Color tint;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SoftCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: nunito(22, 900, color: c.ink)),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: nunito(13, 700, color: c.muted),
          ),
        ],
      ),
    );
  }
}

/// Bars for the last 7 days with a dashed goal line. Tap a bar to see its value.
class _WeekChart extends StatefulWidget {
  const _WeekChart({required this.days});

  final List<DayLog> days;

  @override
  State<_WeekChart> createState() => _WeekChartState();
}

class _WeekChartState extends State<_WeekChart> {
  late int _selected = widget.days.length - 1;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final locale = AppLocalizations.of(context).localeName;
    final days = widget.days;
    final goal = days.last.goalMl;
    final maxValue = days.fold<int>(goal, (m, d) => max(m, d.totalMl)) * 1.1;

    return LayoutBuilder(
      builder: (context, box) {
        final barArea = box.maxHeight - 52;
        final goalY = barArea * (1 - goal / maxValue) + 26;
        return Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: goalY,
              child: CustomPaint(
                size: const Size(double.infinity, 2),
                painter: _DashPainter(c.success),
              ),
            ),
            Positioned(
              right: 0,
              top: goalY - 20,
              child: Text('$goal', style: nunito(11, 800, color: c.success)),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < days.length; i++)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selected = i);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _selected == i ? 1 : 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: c.ink,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                days[i].totalMl >= 1000
                                    ? '${(days[i].totalMl / 1000).toStringAsFixed(1)}L'
                                    : '${days[i].totalMl}',
                                style: nunito(11, 800, color: c.bgBottom),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TweenAnimationBuilder<double>(
                            tween: Tween(end: days[i].totalMl / maxValue),
                            duration: Duration(milliseconds: 600 + i * 70),
                            curve: Curves.easeOutBack,
                            builder: (context, f, _) => AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: _selected == i ? 26 : 20,
                              height: max(8, f.clamp(0.0, 1.0) * barArea),
                              decoration: BoxDecoration(
                                gradient: days[i].goalMet || _selected == i
                                    ? LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [c.aqua, c.accentDeep],
                                      )
                                    : null,
                                color: days[i].goalMet || _selected == i
                                    ? null
                                    : c.waterBack,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat.E(locale).format(days[i].date),
                            style: nunito(
                              12,
                              _selected == i ? 900 : 700,
                              color: _selected == i ? c.ink : c.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (double x = 0; x < size.width - 34; x += 10) {
      canvas.drawLine(Offset(x, 0), Offset(x + 5, 0), paint);
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day});

  final DayLog day;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final locale = AppLocalizations.of(context).localeName;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 46,
            child: CustomPaint(
              painter: _MiniRing(
                day.progress.clamp(0.0, 1.0),
                day.goalMet ? c.success : c.accent,
                c.divider,
              ),
              child: Center(
                child: day.goalMet
                    ? Icon(Icons.check_rounded, color: c.success, size: 22)
                    : Text(
                        '${(day.progress * 100).round()}',
                        style: nunito(12, 900, color: c.ink),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              DateFormat.MMMMEEEEd(locale).format(day.date),
              style: nunito(15, 800, color: c.ink),
            ),
          ),
          Text('${day.totalMl} ml', style: nunito(15, 900, color: c.ink)),
          Text(' / ${day.goalMl}', style: nunito(13, 700, color: c.muted)),
        ],
      ),
    );
  }
}

class _MiniRing extends CustomPainter {
  _MiniRing(this.value, this.color, this.track);

  final double value;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(3);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * pi, false, p..color = track);
    canvas.drawArc(rect, -pi / 2, 2 * pi * value, false, p..color = color);
  }

  @override
  bool shouldRepaint(_MiniRing old) => old.value != value || old.color != color;
}
