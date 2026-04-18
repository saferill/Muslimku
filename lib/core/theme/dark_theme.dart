import 'package:flutter/material.dart';

import '../constants/colors.dart';

class DarkAppTheme {
  static ThemeData build() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primarySoft,
      brightness: Brightness.dark,
      primary: AppColors.primarySoft,
      secondary: AppColors.tertiarySoft,
      surface: AppColors.darkSurface,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.darkSurface,
      cardColor: AppColors.darkSurfaceAlt,
    );
  }
}
