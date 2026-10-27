import 'package:flutter/material.dart';

/// Little glass outline filled to [fill] (0..1). Used for cup sizes and the
/// log, so sizes read at a glance.
class CupIcon extends StatelessWidget {
  const CupIcon({
    super.key,
    required this.fill,
    required this.color,
    this.size = 28,
  });

  final double fill;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size(size * 0.8, size),
    painter: _CupPainter(fill, color),
  );
}

class _CupPainter extends CustomPainter {
  _CupPainter(this.fill, this.color);

  final double fill;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final inset = w * 0.12;
    final glass = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w - inset, h * 0.92)
      ..quadraticBezierTo(w - inset, h, w - inset * 2, h)
      ..lineTo(inset * 2, h)
      ..quadraticBezierTo(inset, h, inset, h * 0.92)
      ..close();
    canvas.save();
    canvas.clipPath(glass);
    final top = h * (1 - fill.clamp(0.0, 1.0));
    canvas.drawRect(
      Rect.fromLTRB(0, top, w, h),
      Paint()..color = color.withValues(alpha: 0.55),
    );
    canvas.restore();
    canvas.drawPath(
      glass,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = (w * 0.1).clamp(1.5, 3.5)
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_CupPainter old) => old.fill != fill || old.color != color;
}
