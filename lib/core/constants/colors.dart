import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFFAF9F4);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceLow = Color(0xFFF5F4EF);
  static const surfaceHigh = Color(0xFFE9E8E3);
  static const surfaceVariant = Color(0xFFE3E3DE);
  static const textPrimary = Color(0xFF1B1C19);
  static const textSecondary = Color(0xFF3E4A3F);
  static const outline = Color(0xFFBDCABC);
  static const primary = Color(0xFF006A39);
  static const primaryBright = Color(0xFF008649);
  static const primarySoft = Color(0xFF82FAAB);
  static const secondary = Color(0xFF3B6750);
  static const tertiary = Color(0xFF735C00);
  static const tertiarySoft = Color(0xFFFFE088);
  static const error = Color(0xFFBA1A1A);
  static const errorSoft = Color(0xFFFFDAD6);
  static const darkSurface = Color(0xFF142119);
  static const darkSurfaceAlt = Color(0xFF203126);
  static const white = Colors.white;

  static const heroGradient = LinearGradient(
    colors: [primary, primaryBright],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const splashGradient = LinearGradient(
    colors: [Color(0xFF0D3B24), Color(0xFF002113)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
