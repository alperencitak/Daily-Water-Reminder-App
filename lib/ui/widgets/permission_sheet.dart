import 'dart:math';

import 'package:flutter/material.dart';

import '../../content/messages.dart';
import '../../l10n/app_localizations.dart';
import '../theme.dart';
import 'bob.dart';

/// Friendly explanation shown once before the system notification prompt.
/// Returns true if the user wants to allow notifications.
Future<bool> showPermissionSheet(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    builder: (_) => const _PermissionSheet(),
  );
  return result ?? false;
}

class _PermissionSheet extends StatelessWidget {
  const _PermissionSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.colors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 190,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [c.cardAlt, c.waterBack.withValues(alpha: 0.6)],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(top: 26, right: 70, child: _Bell(color: c.warm)),
                  const Bob(mood: BobMood.anime, size: 110),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(
              l10n.permissionTitle,
              textAlign: TextAlign.center,
              style: nunito(24, 900, color: c.ink, height: 1.2),
            ),
            const SizedBox(height: 18),
            _Bullet(icon: Icons.schedule_rounded, text: l10n.permBullet1),
            _Bullet(icon: Icons.emoji_events_rounded, text: l10n.permBullet2),
            _Bullet(icon: Icons.touch_app_rounded, text: l10n.permBullet3),
            const SizedBox(height: 22),
            GradientButton(
              label: l10n.permissionAllow,
              icon: Icons.notifications_active_rounded,
              onTap: () => Navigator.pop(context, true),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                l10n.permissionLater,
                style: nunito(15, 800, color: c.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c.cardAlt,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: c.accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(text, style: nunito(15.5, 700, color: c.ink)),
          ),
        ],
      ),
    );
  }
}

/// Gently ringing bell next to Bob.
class _Bell extends StatefulWidget {
  const _Bell({required this.color});

  final Color color;

  @override
  State<_Bell> createState() => _BellState();
}

class _BellState extends State<_Bell> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        // Short wiggle, then rest.
        final t = _c.value;
        final angle = t < 0.4 ? sin(t * pi * 12) * 0.3 * (1 - t / 0.4) : 0.0;
        return Transform.rotate(
          angle: angle,
          alignment: Alignment.topCenter,
          child: child,
        );
      },
      child: Icon(Icons.notifications_rounded, size: 40, color: widget.color),
    );
  }
}
