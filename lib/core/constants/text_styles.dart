import 'package:flutter/material.dart';

import 'colors.dart';

class AppTextStyles {
  static const headingDisplay = TextStyle(
    fontSize: 38,
    height: 1.05,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -1.1,
  );

  static const headingLarge = TextStyle(
    fontSize: 30,
    height: 1.1,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.8,
  );

  static const headingMedium = TextStyle(
    fontSize: 22,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const bodyLarge = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const labelCaps = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.6,
    color: AppColors.textSecondary,
  );
}
