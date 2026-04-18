import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expanded = true,
    this.loading = false,
    this.isSecondary = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final bool loading;
  final bool isSecondary;

  @override
  Widget build(BuildContext context) {
    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        gradient: isSecondary ? null : AppColors.heroGradient,
        color: isSecondary ? AppColors.surface.withValues(alpha: 0.82) : null,
        borderRadius: BorderRadius.circular(24),
        border: isSecondary
            ? Border.all(color: AppColors.outline.withValues(alpha: 0.4))
            : null,
        boxShadow: isSecondary
            ? null
            : const <BoxShadow>[
                BoxShadow(
                  color: Color(0x33006A39),
                  blurRadius: 28,
                  offset: Offset(0, 16),
                ),
              ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: <Widget>[
          if (loading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (icon != null)
            Icon(
              icon,
              color: isSecondary ? AppColors.primary : Colors.white,
            ),
          if ((loading || icon != null)) const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: isSecondary ? AppColors.primary : Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );

    if (expanded) {
      return SizedBox(
        width: double.infinity,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: loading ? null : onPressed,
            child: child,
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: loading ? null : onPressed,
        child: child,
      ),
    );
  }
}
