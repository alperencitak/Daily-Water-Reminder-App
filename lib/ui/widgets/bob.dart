import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../content/messages.dart';

/// Bob, the water drop mascot, drawn in code so he can blink, float,
/// jump and change his face.
class Bob extends StatefulWidget {
  const Bob({
    super.key,
    required this.mood,
    this.size = 120,
    this.jumpTrigger = 0,
    this.onTap,
  });

  final BobMood mood;
  final double size;

  /// Bob jumps every time this value changes (e.g. when water is added).
  final int jumpTrigger;
  final VoidCallback? onTap;

  @override
  State<Bob> createState() => _BobState();
}

class _BobState extends State<Bob> with TickerProviderStateMixin {
  late final AnimationController _idle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 170),
  );
  late final AnimationController _jump = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  late final Listenable _all = Listenable.merge([_idle, _blink, _jump]);
  Timer? _blinkTimer;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _scheduleBlink();
  }

  void _scheduleBlink() {
    _blinkTimer = Timer(
      Duration(milliseconds: 1800 + _random.nextInt(3200)),
      () async {
        if (!mounted) return;
        await _blink.forward(from: 0);
        if (!mounted) return;
        await _blink.reverse();
        _scheduleBlink();
      },
    );
  }

  @override
  void didUpdateWidget(Bob old) {
    super.didUpdateWidget(old);
    if (old.jumpTrigger != widget.jumpTrigger || old.mood != widget.mood) {
      _jump.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _idle.dispose();
    _blink.dispose();
    _jump.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap == null
          ? null
          : () {
              _jump.forward(from: 0);
              widget.onTap!();
            },
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size(widget.size, widget.size * 1.3),
          painter: _BobPainter(
            mood: widget.mood,
            idle: _idle,
            blink: _blink,
            jump: _jump,
            repaint: _all,
          ),
        ),
      ),
    );
  }
}

const _ink = Color(0xFF12304F);
const _blush = Color(0xFFFF8FAB);

class _BobPainter extends CustomPainter {
  _BobPainter({
    required this.mood,
    required this.idle,
    required this.blink,
    required this.jump,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final BobMood mood;
  final Animation<double> idle;
  final Animation<double> blink;
  final Animation<double> jump;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final t = idle.value * 2 * pi;
    final j = Curves.easeOut.transform(jump.value);
    final sleeping = mood == BobMood.sleep;

    // Drop occupies the lower part, leaving room for a halo / "zz" above.
    final top = h * 0.16;
    final bottom = h * 0.93;
    final dh = bottom - top;

    final lift = sin(pi * j) * h * 0.16 + (sleeping ? 0 : sin(t) * h * 0.018);
    final squash = 1 + sin(2 * pi * j) * 0.07 * (1 - j) + sin(t * 2) * 0.012;

    // Ground shadow shrinks while Bob is in the air.
    final shadowScale = 1 - (lift / (h * 0.2)).clamp(0.0, 0.5);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, h * 0.965),
        width: w * 0.6 * shadowScale,
        height: h * 0.045 * shadowScale,
      ),
      Paint()..color = const Color(0xFF1F6FE5).withValues(alpha: 0.16),
    );

    canvas.save();
    canvas.translate(w / 2, bottom - lift);
    canvas.scale(1 / squash, squash);
    canvas.translate(-w / 2, -bottom);

    final body = Path()
      ..moveTo(w * 0.5, top)
      ..cubicTo(
        w * 0.62,
        top + dh * 0.2,
        w * 0.96,
        top + dh * 0.42,
        w * 0.96,
        top + dh * 0.66,
      )
      ..cubicTo(w * 0.96, top + dh * 0.88, w * 0.76, bottom, w * 0.5, bottom)
      ..cubicTo(
        w * 0.24,
        bottom,
        w * 0.04,
        top + dh * 0.88,
        w * 0.04,
        top + dh * 0.66,
      )
      ..cubicTo(
        w * 0.04,
        top + dh * 0.42,
        w * 0.38,
        top + dh * 0.2,
        w * 0.5,
        top,
      )
      ..close();
    final bounds = Rect.fromLTRB(0, top, w, bottom);
    canvas.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFA6EBFF), Color(0xFF55B8FF), Color(0xFF2F86F0)],
          stops: [0, 0.55, 1],
        ).createShader(bounds),
    );
    // Soft inner shade at the bottom for volume.
    canvas.drawPath(
      body,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0.2, 0.9),
          radius: 0.9,
          colors: [
            const Color(0xFF1F5FD0).withValues(alpha: 0.35),
            Colors.transparent,
          ],
        ).createShader(bounds),
    );
    // Shine.
    canvas.save();
    canvas.translate(w * 0.27, top + dh * 0.45);
    canvas.rotate(-0.45);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: w * 0.11, height: dh * 0.24),
      Paint()..color = Colors.white.withValues(alpha: 0.75),
    );
    canvas.restore();
    canvas.drawCircle(
      Offset(w * 0.25, top + dh * 0.66),
      w * 0.03,
      Paint()..color = Colors.white.withValues(alpha: 0.7),
    );

    _face(canvas, w, top, dh, t);
    canvas.restore();

    _extras(canvas, w, h, top, t);
  }

  void _face(Canvas canvas, double w, double top, double dh, double t) {
    final cx = w * 0.5;
    final eyeY = top + dh * 0.6;
    final dx = w * 0.17;
    final eyeR = w * 0.07;
    final stroke = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = _ink;
    final white = Paint()..color = Colors.white;

    // Cheeks.
    final blushAlpha = switch (mood) {
      BobMood.love || BobMood.anime => 0.75,
      BobMood.cry => 0.25,
      _ => 0.5,
    };
    for (final s in [-1, 1]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + s * w * 0.29, eyeY + dh * 0.1),
          width: w * 0.15,
          height: w * 0.08,
        ),
        Paint()..color = _blush.withValues(alpha: blushAlpha),
      );
    }

    final open = 1 - blink.value * 0.92;

    void roundEye(Offset c, double r, {int sparkles = 1}) {
      canvas.drawOval(
        Rect.fromCenter(center: c, width: r * 1.7, height: r * 2.1 * open),
        fill,
      );
      if (open > 0.4) {
        canvas.drawCircle(c + Offset(r * 0.32, -r * 0.45), r * 0.36, white);
        if (sparkles > 1) {
          canvas.drawCircle(c + Offset(-r * 0.3, r * 0.4), r * 0.18, white);
        }
      }
    }

    void happyEye(Offset c, double r) {
      canvas.drawArc(
        Rect.fromCenter(
          center: c + Offset(0, r * 0.4),
          width: r * 2,
          height: r * 1.8,
        ),
        pi * 1.1,
        pi * 0.8,
        false,
        stroke,
      );
    }

    void closedEye(Offset c, double r) {
      canvas.drawArc(
        Rect.fromCenter(
          center: c - Offset(0, r * 0.3),
          width: r * 2,
          height: r * 1.4,
        ),
        pi * 0.15,
        pi * 0.7,
        false,
        stroke,
      );
    }

    void heartEye(Offset c, double r) {
      final s = r * 1.25 * (1 + sin(t * 2) * 0.08);
      final p = Path()
        ..moveTo(c.dx, c.dy + s * 0.9)
        ..cubicTo(
          c.dx - s * 1.4,
          c.dy,
          c.dx - s * 0.8,
          c.dy - s * 1.1,
          c.dx,
          c.dy - s * 0.35,
        )
        ..cubicTo(
          c.dx + s * 0.8,
          c.dy - s * 1.1,
          c.dx + s * 1.4,
          c.dy,
          c.dx,
          c.dy + s * 0.9,
        )
        ..close();
      canvas.drawPath(p, Paint()..color = const Color(0xFFFF4F7B));
      canvas.drawCircle(c + Offset(s * 0.35, -s * 0.35), s * 0.18, white);
    }

    final left = Offset(cx - dx, eyeY);
    final right = Offset(cx + dx, eyeY);
    final mouthY = eyeY + dh * 0.15;

    switch (mood) {
      case BobMood.neutral:
        roundEye(left, eyeR);
        roundEye(right, eyeR);
        _smile(canvas, Offset(cx, mouthY), w * 0.16, stroke);
      case BobMood.lol:
        happyEye(left, eyeR);
        happyEye(right, eyeR);
        _openMouth(canvas, Offset(cx, mouthY), w * 0.2, w * 0.13);
      case BobMood.angel:
        closedEye(left, eyeR);
        closedEye(right, eyeR);
        _smile(canvas, Offset(cx, mouthY), w * 0.14, stroke);
      case BobMood.surprise:
        roundEye(left, eyeR * 1.25, sparkles: 2);
        roundEye(right, eyeR * 1.25, sparkles: 2);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx, mouthY + w * 0.02),
            width: w * 0.09,
            height: w * 0.12,
          ),
          fill,
        );
      case BobMood.cry:
        for (final e in [left, right]) {
          roundEye(e, eyeR * 0.9);
        }
        canvas.drawLine(
          left + Offset(-eyeR, -eyeR * 1.6),
          left + Offset(eyeR * 0.8, -eyeR * 2.2),
          stroke,
        );
        canvas.drawLine(
          right + Offset(eyeR, -eyeR * 1.6),
          right + Offset(-eyeR * 0.8, -eyeR * 2.2),
          stroke,
        );
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(cx, mouthY + w * 0.07),
            width: w * 0.18,
            height: w * 0.12,
          ),
          pi * 1.15,
          pi * 0.7,
          false,
          stroke,
        );
        // Falling tears.
        final fall = (t / (2 * pi)) % 1;
        for (final e in [left, right]) {
          final y = e.dy + eyeR * 1.2 + fall * dh * 0.25;
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(e.dx + (e == left ? -eyeR : eyeR), y),
              width: w * 0.05,
              height: w * 0.075,
            ),
            Paint()
              ..color = const Color(0xFFDDF4FF).withValues(alpha: 1 - fall),
          );
        }
      case BobMood.anime:
        roundEye(left, eyeR * 1.3, sparkles: 2);
        roundEye(right, eyeR * 1.3, sparkles: 2);
        _smile(canvas, Offset(cx, mouthY + w * 0.01), w * 0.1, stroke);
      case BobMood.crazy:
        happyEye(left, eyeR);
        roundEye(right, eyeR * 1.15, sparkles: 2);
        _openMouth(
          canvas,
          Offset(cx, mouthY),
          w * 0.2,
          w * 0.1,
          tongueShift: w * 0.05,
        );
      case BobMood.love:
        heartEye(left, eyeR);
        heartEye(right, eyeR);
        _smile(canvas, Offset(cx, mouthY), w * 0.14, stroke);
      case BobMood.sleep:
        closedEye(left + Offset(0, eyeR * 0.6), eyeR);
        closedEye(right + Offset(0, eyeR * 0.6), eyeR);
        final breathe = 1 + sin(t) * 0.25;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx, mouthY + w * 0.03),
            width: w * 0.06 * breathe,
            height: w * 0.07 * breathe,
          ),
          fill,
        );
    }
  }

  void _smile(Canvas canvas, Offset c, double width, Paint stroke) {
    canvas.drawArc(
      Rect.fromCenter(
        center: c - Offset(0, width * 0.3),
        width: width,
        height: width * 0.9,
      ),
      pi * 0.15,
      pi * 0.7,
      false,
      stroke,
    );
  }

  void _openMouth(
    Canvas canvas,
    Offset c,
    double width,
    double height, {
    double tongueShift = 0,
  }) {
    final mouth = Path()
      ..moveTo(c.dx - width / 2, c.dy - height * 0.25)
      ..quadraticBezierTo(
        c.dx,
        c.dy - height * 0.4,
        c.dx + width / 2,
        c.dy - height * 0.25,
      )
      ..quadraticBezierTo(
        c.dx + width * 0.45,
        c.dy + height,
        c.dx,
        c.dy + height,
      )
      ..quadraticBezierTo(
        c.dx - width * 0.45,
        c.dy + height,
        c.dx - width / 2,
        c.dy - height * 0.25,
      )
      ..close();
    canvas.drawPath(mouth, Paint()..color = _ink);
    canvas.save();
    canvas.clipPath(mouth);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(c.dx + tongueShift, c.dy + height * 0.85),
        width: width * 0.6,
        height: height * 0.8,
      ),
      Paint()..color = const Color(0xFFFF7C98),
    );
    canvas.restore();
  }

  void _extras(Canvas canvas, double w, double h, double top, double t) {
    switch (mood) {
      case BobMood.angel:
        final y = top - h * 0.06 + sin(t) * h * 0.012;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(w / 2, y),
            width: w * 0.42,
            height: h * 0.07,
          ),
          Paint()
            ..color = const Color(0xFFFFCC4D)
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.04,
        );
      case BobMood.sleep:
        for (var i = 0; i < 2; i++) {
          final p = ((t / (2 * pi)) + i * 0.5) % 1;
          final tp = TextPainter(
            text: TextSpan(
              text: 'z',
              style: TextStyle(
                fontSize: w * (0.14 + 0.08 * p),
                fontWeight: FontWeight.w900,
                color: const Color(0xFF6E8FB5).withValues(alpha: (1 - p) * 0.9),
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(
            canvas,
            Offset(w * (0.68 + p * 0.18), top + h * 0.08 - p * h * 0.16),
          );
        }
      case BobMood.love:
        final p = (t / (2 * pi)) % 1;
        final tp = TextPainter(
          text: TextSpan(
            text: '❤',
            style: TextStyle(
              fontSize: w * 0.14,
              color: const Color(0xFFFF4F7B).withValues(alpha: 1 - p),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(w * 0.78, top + h * 0.1 - p * h * 0.14));
      default:
        break;
    }
  }

  @override
  bool shouldRepaint(_BobPainter old) => old.mood != mood;
}
