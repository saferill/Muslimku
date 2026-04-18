import 'package:flutter/material.dart';

class MuslimKuColors {
  static const Color primary = Color(0xFF0D631B);
  static const Color primaryContainer = Color(0xFF2E7D32);
  static const Color primaryFixed = Color(0xFFA3F69C);
  static const Color primaryFixedDim = Color(0xFF88D982);
  static const Color tertiary = Color(0xFF923357);
  static const Color tertiarySoft = Color(0xFFFFD9E2);

  static const Color background = Color(0xFFF9F9F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLow = Color(0xFFF3F3F3);
  static const Color surfaceContainer = Color(0xFFEEEEEE);
  static const Color surfaceHigh = Color(0xFFE8E8E8);
  static const Color surfaceHighest = Color(0xFFE2E2E2);
  static const Color text = Color(0xFF1A1C1C);
  static const Color textSoft = Color(0xFF5E5E5E);
  static const Color textSecondary = textSoft;
  static const Color outline = Color(0xFFBFCABA);
  static const Color outlineVariant = Color(0xFFBFCABA);
}

ThemeData buildMuslimKuTheme() {
  final scheme = const ColorScheme.light(
    primary: MuslimKuColors.primary,
    onPrimary: Colors.white,
    secondary: MuslimKuColors.textSoft,
    onSecondary: Colors.white,
    surface: MuslimKuColors.surface,
    onSurface: MuslimKuColors.text,
    error: Color(0xFFBA1A1A),
    onError: Colors.white,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: MuslimKuColors.background,
  );

  final textTheme = base.textTheme.copyWith(
    displaySmall: base.textTheme.displaySmall?.copyWith(
      color: MuslimKuColors.text,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.4,
    ),
    headlineMedium: base.textTheme.headlineMedium?.copyWith(
      color: MuslimKuColors.text,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.9,
    ),
    headlineSmall: base.textTheme.headlineSmall?.copyWith(
      color: MuslimKuColors.text,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.7,
    ),
    titleLarge: base.textTheme.titleLarge?.copyWith(
      color: MuslimKuColors.text,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.3,
    ),
    titleMedium: base.textTheme.titleMedium?.copyWith(
      color: MuslimKuColors.text,
      fontWeight: FontWeight.w700,
    ),
    bodyLarge: base.textTheme.bodyLarge?.copyWith(
      color: MuslimKuColors.text,
      height: 1.58,
    ),
    bodyMedium: base.textTheme.bodyMedium?.copyWith(
      color: MuslimKuColors.textSoft,
      height: 1.52,
    ),
    labelLarge: base.textTheme.labelLarge?.copyWith(
      color: MuslimKuColors.text,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.25,
    ),
    labelMedium: base.textTheme.labelMedium?.copyWith(
      color: MuslimKuColors.textSoft,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
    ),
    labelSmall: base.textTheme.labelSmall?.copyWith(
      color: MuslimKuColors.textSoft,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
    ),
  );

  return base.copyWith(
    textTheme: textTheme,
    dividerColor: MuslimKuColors.outline.withValues(alpha: 0.35),
    cardColor: MuslimKuColors.surface,
    splashColor: MuslimKuColors.primary.withValues(alpha: 0.08),
    highlightColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: MuslimKuColors.text,
      centerTitle: false,
    ),
    iconTheme: const IconThemeData(color: MuslimKuColors.text),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.82),
      hintStyle: const TextStyle(color: Color(0xFF8A8F8A)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      prefixIconColor: MuslimKuColors.textSoft,
      suffixIconColor: MuslimKuColors.textSoft,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.75),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: MuslimKuColors.primary, width: 1.2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: MuslimKuColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: MuslimKuColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        side: BorderSide(color: MuslimKuColors.outline.withValues(alpha: 0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: MuslimKuColors.primary,
        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return MuslimKuColors.primary;
        }
        return MuslimKuColors.surfaceHighest;
      }),
      thumbColor: const WidgetStatePropertyAll<Color>(Colors.white),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: MuslimKuColors.text,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
