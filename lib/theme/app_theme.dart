import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// Deep green-teal used for primary surfaces, the nav bar and highlights.
  static const ink = Color(0xFF1C2B29);
  static const inkSoft = Color(0xFF2F4A46);

  static const orange = Color(0xFFF0782A);
  static const orangeLight = Color(0xFFFFB267);
  static const danger = Color(0xFFD9534F);
}

class AppText {
  AppText._();

  static const title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: -0.2,
  );
  static const section = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: -0.2,
  );
  static const body = TextStyle(fontSize: 14, color: Colors.white);
  static const caption = TextStyle(fontSize: 12, color: Color(0xCCFFFFFF));
}

/// Background colors that change between light and dark appearance.
/// Glass surfaces are translucent, so they adapt automatically.
@immutable
class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.bgTop,
    required this.bgMid,
    required this.bgBottom,
    required this.glowTop,
    required this.glowSide,
    required this.glowBottom,
  });

  final Color bgTop;
  final Color bgMid;
  final Color bgBottom;
  final Color glowTop;
  final Color glowSide;
  final Color glowBottom;

  static const light = Palette(
    bgTop: Color(0xFF8C9A96),
    bgMid: Color(0xFF6B7A76),
    bgBottom: Color(0xFF465451),
    glowTop: Color(0x4DFFFFFF),
    glowSide: Color(0x47C9DBD4),
    glowBottom: Color(0x99243936),
  );

  static const dark = Palette(
    bgTop: Color(0xFF3B4845),
    bgMid: Color(0xFF232D2B),
    bgBottom: Color(0xFF111816),
    glowTop: Color(0x1FFFFFFF),
    glowSide: Color(0x2E6F8F86),
    glowBottom: Color(0x80000000),
  );

  static Palette of(BuildContext context) =>
      Theme.of(context).extension<Palette>() ?? light;

  @override
  Palette copyWith({
    Color? bgTop,
    Color? bgMid,
    Color? bgBottom,
    Color? glowTop,
    Color? glowSide,
    Color? glowBottom,
  }) {
    return Palette(
      bgTop: bgTop ?? this.bgTop,
      bgMid: bgMid ?? this.bgMid,
      bgBottom: bgBottom ?? this.bgBottom,
      glowTop: glowTop ?? this.glowTop,
      glowSide: glowSide ?? this.glowSide,
      glowBottom: glowBottom ?? this.glowBottom,
    );
  }

  @override
  Palette lerp(Palette? other, double t) {
    if (other == null) return this;
    return Palette(
      bgTop: Color.lerp(bgTop, other.bgTop, t)!,
      bgMid: Color.lerp(bgMid, other.bgMid, t)!,
      bgBottom: Color.lerp(bgBottom, other.bgBottom, t)!,
      glowTop: Color.lerp(glowTop, other.glowTop, t)!,
      glowSide: Color.lerp(glowSide, other.glowSide, t)!,
      glowBottom: Color.lerp(glowBottom, other.glowBottom, t)!,
    );
  }
}

class AppTheme {
  AppTheme._();

  static final light = _build(Palette.light);
  static final dark = _build(Palette.dark);

  static ThemeData _build(Palette palette) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.inkSoft,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: palette.bgBottom,
      extensions: [palette],
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.white,
        selectionColor: Color(0x55FFFFFF),
        selectionHandleColor: Colors.white,
      ),
    );
  }
}
