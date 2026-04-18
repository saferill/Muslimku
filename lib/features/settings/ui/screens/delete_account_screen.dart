import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../di/injection.dart';
import '../../../../routes/route_names.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependenciesScope.of(context);
    final settings = dependencies.settingsController;

    return AnimatedBuilder(
      animation: dependencies.authController,
      builder: (context, _) {
        final state = settings.state;
        return Scaffold(
          appBar: AppBar(title: const Text('Hapus Akun')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.errorSoft.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Column(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: Color(0x33BA1A1A),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: AppColors.error,
                          size: 34,
                        ),
                      ),
                      SizedBox(height: 18),
                      Text(
                        'Kami sedih melihatmu pergi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Menghapus akun bersifat permanen. Bookmark, progres baca, dan pengaturan yang tersinkron akan dihapus dari cloud.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          height: 1.55,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Peringatan Kehilangan Data',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Akun ${state.user.email} akan dihapus permanen. Untuk akun email/password, masukkan password saat ini. Untuk akun Google, kolom ini boleh kosong.',
                        style: const TextStyle(
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        controller: _passwordController,
                        label: 'Password Saat Ini',
                        hint: 'Kosongkan jika akun Google',
                        icon: Icons.lock_outline_rounded,
                        obscureText: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Hapus Akun Permanen',
                  icon: Icons.delete_forever_rounded,
                  loading: state.submitting,
                  onPressed: () async {
                    final message = await settings.deleteAccount(
                      currentPassword: _passwordController.text.trim(),
                    );
                    if (!context.mounted || message == null) return;
                    context.showAppSnack(message);
                    if (!message.toLowerCase().contains('berhasil')) return;
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      RouteNames.bootstrap,
                      (_) => false,
                    );
                  },
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Batalkan',
                  isSecondary: true,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
