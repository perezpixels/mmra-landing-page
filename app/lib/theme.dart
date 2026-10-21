import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colour tokens from `src/webapp/webapp.css` (`--wa-*`).
class C {
  static const bg = Color(0xFFF7F5EF);
  static const paper = Color(0xFFFFFDFA);
  static const paper2 = Color(0xFFF1EEE6);
  static const ink = Color(0xFF161512);
  static const muted = Color(0xFF706C63);
  static const line = Color(0xFFDDD8CC);
  static const gold = Color(0xFFA27D2E);
  static const goldLight = Color(0xFFE6CF94);
  static const black = Color(0xFF11110F);
  static const green = Color(0xFF277451);
  static const red = Color(0xFFA8473E);
  static const blue = Color(0xFF315F7C);
  static const dark = Color(0xFF171612);
  static const focusRing = Color(0x1FA27D2E);
}

/// CSS `rem` (16px root).
double rem(double v) => v * 16;

TextStyle sans(
  double remSize, {
  FontWeight weight = FontWeight.w400,
  Color color = C.ink,
  double? height,
  double lsEm = 0,
  TextDecoration? decoration,
  Color? decorationColor,
}) {
  final size = rem(remSize);
  return GoogleFonts.inter(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: lsEm * size,
    decoration: decoration,
    decorationColor: decorationColor ?? color,
  );
}

/// Playfair Display, used for h1/h2/h3 (weight 500 globally).
TextStyle serif(
  double remSize, {
  FontWeight weight = FontWeight.w500,
  Color color = C.ink,
  double? height,
  double lsEm = 0,
}) {
  final size = rem(remSize);
  return GoogleFonts.playfairDisplay(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: lsEm * size,
  );
}

TextStyle mono(double remSize, {Color color = C.ink, double? height}) =>
    GoogleFonts.dmMono(fontSize: rem(remSize), color: color, height: height);

/// Georgia stand-in: Gelasio is metric-compatible with Georgia and is
/// available to every Flutter platform, unlike the system font.
TextStyle reading(double remSize, {Color color = C.ink, double? height}) =>
    GoogleFonts.gelasio(fontSize: rem(remSize), color: color, height: height);

/// Media-query breakpoints from `webapp.css`.
class Bp {
  Bp(this.width);
  factory Bp.of(BuildContext context) => Bp(MediaQuery.sizeOf(context).width);

  final double width;
  bool get le1180 => width <= 1180;
  bool get le1024 => width <= 1024;
  bool get le768 => width <= 768;
  bool get le520 => width <= 520;
  bool get le350 => width <= 350;
}

/// `font-size: clamp(2.05rem, 3.2vw, 3rem)` used by page and document titles.
double titleSize(BuildContext context) {
  final bp = Bp.of(context);
  if (bp.le520) return rem(2);
  return math.min(rem(3), math.max(rem(2.05), bp.width * 0.032));
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: C.gold, surface: C.paper),
    scaffoldBackgroundColor: C.bg,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
  );
  return base.copyWith(
    textTheme: GoogleFonts.interTextTheme(base.textTheme),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: C.ink,
      selectionColor: Color(0x55E6CF94),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? C.gold : Colors.white,
      ),
      side: const BorderSide(color: Color(0xFF8F8B82)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
    ),
  );
}
