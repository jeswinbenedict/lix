import 'package:flutter/material.dart';

class AppTheme {
  // ── Color Tokens ─────────────────────────────────────────
  static const Color background = Color(0xFFF8F9FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFFEDE9FF);
  static const Color secondary = Color(0xFFFF6B6B);
  static const Color accent = Color(0xFF34D399);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color shimmerBase = Color(0xFFF3F4F6);
  static const Color shimmerHigh = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);

  // ── Mood Colors ───────────────────────────────────────────
  static const Color moodHappy = Color(0xFFFFD700);
  static const Color moodSad = Color(0xFF4FC3F7);
  static const Color moodAnxious = Color(0xFFCE93D8);
  static const Color moodBored = Color(0xFF80CBC4);
  static const Color moodMotivated = Color(0xFFFF7043);
  static const Color moodRomantic = Color(0xFFF48FB1);

  // ── Dark mode color overrides ────────────────────────────
  static const Color darkBackground = Color(0xFF0F0F1A);
  static const Color darkSurface = Color(0xFF1C1C2E);
  static const Color darkBorder = Color(0xFF2A2A3E);
  static const Color darkShimmerBase = Color(0xFF1E1E30);
  static const Color darkTextPrimary = Color(0xFFF1F1F8);
  static const Color darkTextSecondary = Color(0xFF9B9BB4);

  // ── Border Radius Tokens ─────────────────────────────────
  static const double radiusXS = 6.0;
  static const double radiusSM = 10.0;
  static const double radiusMD = 14.0;
  static const double radiusLG = 20.0;
  static const double radiusXL = 28.0;
  static const double radiusFull = 100.0;

  // ── Shadow Definitions ───────────────────────────────────
  static List<BoxShadow> get shadowSM => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMD => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowPrimary => [
    BoxShadow(
      color: primary.withOpacity(0.25),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  // ── Responsive Spacing ───────────────────────────────────
  static double horizontalPadding(BuildContext context) =>
      (MediaQuery.of(context).size.width * 0.05).clamp(16.0, 24.0);

  static double cardPadding(BuildContext context) =>
      MediaQuery.of(context).size.width < 380 ? 14.0 : 18.0;

  static double sectionGap(BuildContext context) =>
      MediaQuery.of(context).size.width < 380 ? 20.0 : 28.0;

  static double navBarHeight(BuildContext context) =>
      MediaQuery.of(context).size.width < 380 ? 60.0 : 70.0;

  static double avatarSize(BuildContext context) =>
      (MediaQuery.of(context).size.width * 0.08).clamp(40.0, 64.0);

  // ── Responsive Typography ────────────────────────────────
  static double displayText(BuildContext context) =>
      _lerp(MediaQuery.of(context).size.width, 320, 480, 28, 36);

  static double heading1(BuildContext context) =>
      _lerp(MediaQuery.of(context).size.width, 320, 480, 22, 28);

  static double heading2(BuildContext context) =>
      _lerp(MediaQuery.of(context).size.width, 320, 480, 18, 22);

  static double bodyLarge(BuildContext context) =>
      _lerp(MediaQuery.of(context).size.width, 320, 480, 15, 16);

  static double bodyRegular(BuildContext context) =>
      _lerp(MediaQuery.of(context).size.width, 320, 480, 13, 14);

  static double caption(BuildContext context) =>
      _lerp(MediaQuery.of(context).size.width, 320, 480, 11, 12);

  // ── Breakpoints ──────────────────────────────────────────
  static bool isXSmall(BuildContext context) =>
      MediaQuery.of(context).size.width < 360;
  static bool isSmall(BuildContext context) =>
      MediaQuery.of(context).size.width < 400;
  static bool isMedium(BuildContext context) =>
      MediaQuery.of(context).size.width < 430;
  static bool isLarge(BuildContext context) =>
      MediaQuery.of(context).size.width >= 430;

  // ── Grid Columns ─────────────────────────────────────────
  static int gridColumns(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 481) return 3;
    return 2;
  }

  // ── Light Theme ──────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      surface: surface,
      primary: primary,
      secondary: secondary,
      error: error,
    ).copyWith(surfaceContainerHighest: background),
    scaffoldBackgroundColor: background,
    fontFamily: 'sans-serif',
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        side: const BorderSide(color: border),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
        ),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: shimmerBase,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
    ),
  );

  // ── Dark Theme ✅ NEW ─────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      surface: darkSurface,
      primary: primary,
      secondary: secondary,
      error: error,
    ).copyWith(surfaceContainerHighest: darkBackground),
    scaffoldBackgroundColor: darkBackground,
    fontFamily: 'sans-serif',
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: darkTextPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: darkTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        side: const BorderSide(color: darkBorder),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
        ),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkShimmerBase,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: const BorderSide(color: darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: const BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMD),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: darkTextSecondary, fontSize: 14),
    ),
  );

  // ── Helper ───────────────────────────────────────────────
  static double _lerp(
    double val,
    double minVal,
    double maxVal,
    double minOut,
    double maxOut,
  ) {
    final t = ((val - minVal) / (maxVal - minVal)).clamp(0.0, 1.0);
    return minOut + t * (maxOut - minOut);
  }
}
