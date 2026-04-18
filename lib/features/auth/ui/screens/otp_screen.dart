import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../di/injection.dart';
import '../../../../routes/route_names.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = AppDependenciesScope.of(context).authController;

    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi')),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: authController,
          builder: (context, _) {
            final email = authController.state.pendingVerificationEmail;
            if ((email ?? '').isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: <Widget>[
                    const Spacer(),
                    const Icon(
                      Icons.mark_email_unread_outlined,
                      size: 72,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sesi verifikasi tidak ditemukan',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ulangi login atau daftar untuk meminta link verifikasi email baru.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const Spacer(),
                    PrimaryButton(
                      label: 'Kembali ke Login',
                      onPressed: () =>
                          Navigator.of(context).pushNamedAndRemoveUntil(
                        RouteNames.login,
                        (_) => false,
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLow,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Center(
                      child: Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          gradient: AppColors.heroGradient,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.mark_email_read_outlined,
                          size: 44,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                      'Verifikasi email kamu',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Kami sudah mengirim link verifikasi ke $email. Buka email itu, klik link verifikasinya, lalu kembali ke aplikasi untuk melanjutkan.',
                    style: const TextStyle(
                      height: 1.55,
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 20,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.email_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            email!,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Saya Sudah Verifikasi Email',
                    loading: authController.state.submitting,
                    onPressed: () async {
                      final message = await authController.verifyPendingEmail();
                      if (!context.mounted || message == null) return;
                      context.showAppSnack(message);
                      if (!authController.state.isAuthenticated) return;
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        RouteNames.bootstrap,
                        (_) => false,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Kirim Ulang Email Verifikasi',
                    isSecondary: true,
                    onPressed: () async {
                      final message =
                          await authController.resendVerificationEmail();
                      if (!context.mounted || message == null) return;
                      context.showAppSnack(message);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamedAndRemoveUntil(
                      RouteNames.login,
                      (_) => false,
                    ),
                    child: const Text('Gunakan akun lain'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
