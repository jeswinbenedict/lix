import 'package:flutter/material.dart';

class AppTheme {
  // ── Color Tokens ─────────────────────────────────────────
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceGlass = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFFF3E8FF);
  static const Color secondary = Color(0xFFEC4899);
  static const Color accent = Color(0xFF8B5CF6);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color shimmerBase = Color(0xFFF1F5F9);
  static const Color shimmerHigh = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);

  // ── Mood Colors ───────────────────────────────────────────
  static const Color moodHappy = Color(0xFFF59E0B);
  static const Color moodSad = Color(0xFF3B82F6);
  static const Color moodAnxious = Color(0xFFA855F7);
  static const Color moodBored = Color(0xFF10B981);
  static const Color moodMotivated = Color(0xFFEF4444);
  static const Color moodRomantic = Color(0xFFEC4899);

  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [Color(0xFF7C3AED), Color(0xFFA855F7), Color(0xFFEC4899)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get auroraBackgroundGradient => const LinearGradient(
        colors: [
          Color(0xFFF5F3FF), // Soft Violet Tint
          Color(0xFFFDF2F8), // Soft Rose Tint
          Color(0xFFF0F9FF), // Soft Sky Tint
          Color(0xFFF0FDF4), // Soft Mint Tint
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get cardGlassGradient => LinearGradient(
        colors: [
          Colors.white.withAlpha(240),
          Colors.white.withAlpha(210),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // ── Border Radius Tokens ─────────────────────────────────
  static const double radiusXS = 8.0;
  static const double radiusSM = 12.0;
  static const double radiusMD = 16.0;
  static const double radiusLG = 20.0;
  static const double radiusXL = 28.0;
  static const double radiusFull = 100.0;

  // ── Shadow Definitions ───────────────────────────────────
  static List<BoxShadow> get shadowSM => [
        BoxShadow(
          color: const Color(0xFF0F172A).withAlpha(10),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowMD => [
        BoxShadow(
          color: const Color(0xFF7C3AED).withAlpha(16),
          blurRadius: 28,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get shadowPrimary => [
        BoxShadow(
          color: primary.withAlpha(55),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
      ];

  // ── Responsive Spacing ───────────────────────────────────
  static double horizontalPadding(BuildContext context) =>
      (MediaQuery.of(context).size.width * 0.05).clamp(16.0, 32.0);

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
      _lerp(MediaQuery.of(context).size.width, 320, 1200, 28, 42);

  static double heading1(BuildContext context) =>
      _lerp(MediaQuery.of(context).size.width, 320, 1200, 22, 32);

  static double heading2(BuildContext context) =>
      _lerp(MediaQuery.of(context).size.width, 320, 1200, 18, 24);

  static double heading3(BuildContext context) =>
      _lerp(MediaQuery.of(context).size.width, 320, 1200, 16, 20);

  static double bodyLarge(BuildContext context) =>
      _lerp(MediaQuery.of(context).size.width, 320, 1200, 15, 18);

  static double bodyRegular(BuildContext context) =>
      _lerp(MediaQuery.of(context).size.width, 320, 1200, 13, 15);

  static double caption(BuildContext context) =>
      _lerp(MediaQuery.of(context).size.width, 320, 1200, 11, 13);

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
        appBarTheme: const AppBarTheme(
          backgroundColor: surface,
          foregroundColor: textPrimary,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
            side: const BorderSide(color: border, width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusMD),
            ),
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMD),
            borderSide: const BorderSide(color: border, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMD),
            borderSide: const BorderSide(color: border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMD),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          hintStyle: const TextStyle(color: textSecondary, fontSize: 15),
        ),
      );

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

