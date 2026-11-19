import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colors sampled directly from the Figma export.
class AppColors {
  static const primary = Color(0xFF447F98);
  static const tint = Color(0xFFD6EBF3); // light blue surfaces / chips
  static const tintBorder = Color(0xFFB9D9E1);
  static const ink = Color(0xFF263842); // headings
  static const body = Color(0xFF5A7181); // secondary text
  static const muted = Color(0xFF6E8290); // hints / captions
  static const border = Color(0xFFDADEE1);
  static const field = Color(0xFFFAFCFD);
  static const error = Color(0xFFB93838);
  static const errorBg = Color(0xFFFFF2F2);
  static const navIcon = Color(0xFF3F5362);
  static const scrim = Color(0x80263842); // ink @ 50%
}

class AppText {
  static TextStyle base({
    double size = 15,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle h1({Color color = AppColors.ink}) =>
      base(size: 30, weight: FontWeight.w700, color: color, height: 1.2);
  static TextStyle h2() => base(size: 26, weight: FontWeight.w700, height: 1.2);
  static TextStyle appBar() => base(size: 20, weight: FontWeight.w600);
  static TextStyle pageTitle() => base(size: 22, weight: FontWeight.w700);
  static TextStyle section() => base(size: 18, weight: FontWeight.w700);
  static TextStyle label() => base(size: 15, weight: FontWeight.w700);
  static TextStyle bodyText({double size = 15}) =>
      base(size: size, color: AppColors.body, height: 1.5);
  static TextStyle caption() => base(size: 13, color: AppColors.body);
  static TextStyle eyebrow({Color color = AppColors.body, double size = 11}) =>
      base(size: size, weight: FontWeight.w700, color: color, letterSpacing: 0.6);
  static TextStyle link({double size = 13}) =>
      base(size: size, weight: FontWeight.w700, color: AppColors.primary);
  static TextStyle button({Color color = Colors.white}) =>
      base(size: 15, weight: FontWeight.w700, color: color);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    surface: Colors.white,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.white,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(),
    splashFactory: InkRipple.splashFactory,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
  );
}
