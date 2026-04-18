import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/colors.dart';

class MuslimkuAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MuslimkuAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions = const <Widget>[],
  });

  final String? title;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: Text(
        title ?? AppConstants.appName,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.8,
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
