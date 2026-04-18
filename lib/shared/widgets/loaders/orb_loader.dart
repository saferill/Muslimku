import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';

class OrbLoader extends StatelessWidget {
  const OrbLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(
        3,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: AppColors.primarySoft.withValues(
              alpha: index == 0 ? 0.95 : index == 1 ? 0.6 : 0.3,
            ),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
