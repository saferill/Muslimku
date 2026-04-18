import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../widgets/buttons/primary_button.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({
    super.key,
    required this.onConfirm,
  });

  final Future<void> Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: const Text(
        'Logout',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      content: const Text(
        'Apakah kamu yakin ingin keluar dari akun Muslimku?',
        style: TextStyle(color: AppColors.textSecondary),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: <Widget>[
        PrimaryButton(
          label: 'Batalkan',
          onPressed: () => Navigator.of(context).pop(),
          isSecondary: true,
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'Logout',
          icon: Icons.logout,
          onPressed: () async {
            await onConfirm();
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
