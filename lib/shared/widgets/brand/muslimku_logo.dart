import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/colors.dart';

class MuslimkuLogo extends StatelessWidget {
  const MuslimkuLogo({
    super.key,
    this.size = 64,
    this.padding = 6,
    this.radius,
    this.showShadow = true,
    this.backgroundColor,
    this.borderColor,
  });

  final double size;
  final double padding;
  final double? radius;
  final bool showShadow;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = radius ?? size * 0.28;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(effectiveRadius),
        border: Border.all(
          color: borderColor ?? AppColors.primary.withValues(alpha: 0.12),
        ),
        boxShadow: showShadow
            ? const <BoxShadow>[
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveRadius - 4),
        child: Image.asset(
          AppConstants.logoAssetPath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class MuslimkuBrand extends StatelessWidget {
  const MuslimkuBrand({
    super.key,
    this.logoSize = 44,
    this.gap = 12,
    this.textColor = AppColors.primary,
    this.textSize = 24,
    this.textWeight = FontWeight.w900,
    this.center = false,
  });

  final double logoSize;
  final double gap;
  final Color textColor;
  final double textSize;
  final FontWeight textWeight;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        MuslimkuLogo(
          size: logoSize,
          padding: 4,
          radius: logoSize * 0.28,
          showShadow: false,
          backgroundColor: Colors.white.withValues(alpha: 0.95),
          borderColor: AppColors.primary.withValues(alpha: 0.14),
        ),
        SizedBox(width: gap),
        Text(
          AppConstants.appName,
          style: TextStyle(
            color: textColor,
            fontSize: textSize,
            fontWeight: textWeight,
            letterSpacing: -0.8,
          ),
        ),
      ],
    );

    if (center) {
      return Center(child: row);
    }
    return row;
  }
}
