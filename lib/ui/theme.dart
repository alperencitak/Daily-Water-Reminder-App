import 'package:flutter/material.dart';

/// Design tokens for the app. Soft sky/aqua palette, white rounded cards,
/// gentle shadows.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bgTop,
    required this.bgBottom,
    required this.card,
    required this.cardAlt,
    required this.ink,
    required this.muted,
    required this.accent,
    required this.accentDeep,
    required this.aqua,
    required this.waterFront,
    required this.waterBack,
    required this.success,
    required this.warm,
    required this.danger,
    required this.shadow,
    required this.divider,
  });

  final Color bgTop;
  final Color bgBottom;
  final Color card;
  final Color cardAlt;
  final Color ink;
  final Color muted;
  final Color accent;
  final Color accentDeep;
  final Color aqua;
  final Color waterFront;
  final Color waterBack;
  final Color success;
  final Color warm;
  final Color danger;
  final Color shadow;
  final Color divider;

  static const light = AppColors(
    bgTop: Color(0xFFE3F2FF),
    bgBottom: Color(0xFFF6FAFF),
    card: Colors.white,
    cardAlt: Color(0xFFEFF6FF),
    ink: Color(0xFF16304B),
    muted: Color(0xFF7189A3),
    accent: Color(0xFF3A9BFF),
    accentDeep: Color(0xFF1F6FE5),
    aqua: Color(0xFF5ED3F3),
    waterFront: Color(0xFF6CC4FF),
    waterBack: Color(0xFFB4E0FF),
    success: Color(0xFF34C38F),
    warm: Color(0xFFFF9F43),
    danger: Color(0xFFFF6B7A),
    shadow: Color(0x1F2A6BB5),
    divider: Color(0xFFE6EEF7),
  );

  static const dark = AppColors(
    bgTop: Color(0xFF0C1E33),
    bgBottom: Color(0xFF08131F),
    card: Color(0xFF13283F),
    cardAlt: Color(0xFF1A3350),
    ink: Color(0xFFE8F3FF),
    muted: Color(0xFF8EA6C1),
    accent: Color(0xFF4DA8FF),
    accentDeep: Color(0xFF2D7FF0),
    aqua: Color(0xFF4CC6EA),
    waterFront: Color(0xFF2F8EE0),
    waterBack: Color(0xFF1C5E9E),
    success: Color(0xFF3DD39B),
    warm: Color(0xFFFFAD5C),
    danger: Color(0xFFFF7A88),
    shadow: Color(0x66000000),
    divider: Color(0xFF223B57),
  );

  LinearGradient get accentGradient => LinearGradient(
    colors: [aqua, accent, accentDeep],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  LinearGradient get background => LinearGradient(
    colors: [bgTop, bgBottom],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  List<BoxShadow> get softShadow => [
    BoxShadow(color: shadow, blurRadius: 24, offset: const Offset(0, 10)),
  ];

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      bgTop: l(bgTop, other.bgTop),
      bgBottom: l(bgBottom, other.bgBottom),
      card: l(card, other.card),
      cardAlt: l(cardAlt, other.cardAlt),
      ink: l(ink, other.ink),
      muted: l(muted, other.muted),
      accent: l(accent, other.accent),
      accentDeep: l(accentDeep, other.accentDeep),
      aqua: l(aqua, other.aqua),
      waterFront: l(waterFront, other.waterFront),
      waterBack: l(waterBack, other.waterBack),
      success: l(success, other.success),
      warm: l(warm, other.warm),
      danger: l(danger, other.danger),
      shadow: l(shadow, other.shadow),
      divider: l(divider, other.divider),
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

/// Nunito is a variable font: the weight has to be passed as a font variation.
TextStyle nunito(double size, int weight, {Color? color, double? height}) =>
    TextStyle(
      fontFamily: 'Nunito',
      fontSize: size,
      fontWeight: FontWeight.values[(weight ~/ 100 - 1).clamp(0, 8)],
      fontVariations: [FontVariation('wght', weight.toDouble())],
      color: color,
      height: height,
    );

TextStyle _w(TextStyle? base, int weight) =>
    (base ?? const TextStyle()).copyWith(
      fontFamily: 'Nunito',
      fontWeight: FontWeight.values[(weight ~/ 100 - 1).clamp(0, 8)],
      fontVariations: [FontVariation('wght', weight.toDouble())],
    );

ThemeData buildTheme(Brightness brightness) {
  final c = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  final scheme =
      ColorScheme.fromSeed(
        seedColor: c.accent,
        brightness: brightness,
      ).copyWith(
        primary: c.accent,
        onPrimary: Colors.white,
        surface: c.bgBottom,
        onSurface: c.ink,
        onSurfaceVariant: c.muted,
        error: c.danger,
      );
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: 'Nunito',
    scaffoldBackgroundColor: c.bgBottom,
    splashFactory: InkSparkle.splashFactory,
  );
  final t = base.textTheme;
  final text = t
      .copyWith(
        displaySmall: _w(t.displaySmall, 900),
        headlineLarge: _w(t.headlineLarge, 900),
        headlineMedium: _w(t.headlineMedium, 900),
        headlineSmall: _w(t.headlineSmall, 800),
        titleLarge: _w(t.titleLarge, 800),
        titleMedium: _w(t.titleMedium, 700),
        titleSmall: _w(t.titleSmall, 700),
        bodyLarge: _w(t.bodyLarge, 600),
        bodyMedium: _w(t.bodyMedium, 600),
        bodySmall: _w(t.bodySmall, 600),
        labelLarge: _w(t.labelLarge, 800),
        labelMedium: _w(t.labelMedium, 700),
        labelSmall: _w(t.labelSmall, 700),
      )
      .apply(bodyColor: c.ink, displayColor: c.ink);

  return base.copyWith(
    extensions: [c],
    textTheme: text,
    dialogTheme: DialogThemeData(
      backgroundColor: c.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.card,
      showDragHandle: true,
      dragHandleColor: c.divider,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.ink,
      contentTextStyle: nunito(15, 700, color: c.bgBottom),
      actionTextColor: c.aqua,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStatePropertyAll(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? c.accent : c.divider,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: c.accent,
      inactiveTrackColor: c.divider,
      thumbColor: Colors.white,
      overlayColor: c.accent.withValues(alpha: 0.12),
      trackHeight: 10,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.cardAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: c.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      },
    ),
  );
}

/// Standard rounded card surface.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
    this.gradient,
    this.radius = 28,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Gradient? gradient;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? c.card) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: c.softShadow,
      ),
      child: child,
    );
  }
}

/// Shrinks a little while pressed and gives a light haptic, used by every
/// tappable piece of custom UI so the app feels responsive.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.95,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _set(true) : null,
      onTapCancel: () => _set(false),
      onTapUp: enabled ? (_) => _set(false) : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: enabled ? 1 : 0.45,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Page background gradient.
class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(gradient: context.colors.background),
    child: child,
  );
}

/// Full-width primary action with the accent gradient.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Pressable(
      onTap: onTap,
      child: Container(
        height: 58,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: c.accentGradient,
          borderRadius: BorderRadius.circular(29),
          boxShadow: [
            BoxShadow(
              color: c.accent.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Text(label, style: nunito(17, 900, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
