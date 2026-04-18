import 'package:flutter/material.dart';

import '../../../../shared/widgets/buttons/primary_button.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.label,
    this.loading = false,
    this.onPressed,
    this.icon,
    this.isSecondary = false,
  });

  final String label;
  final bool loading;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isSecondary;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: label,
      loading: loading,
      icon: icon,
      isSecondary: isSecondary,
      onPressed: onPressed,
    );
  }
}
