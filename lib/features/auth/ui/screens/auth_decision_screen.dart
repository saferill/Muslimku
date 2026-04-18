import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../di/injection.dart';
import '../../../../routes/route_names.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

class AuthDecisionScreen extends StatelessWidget {
  const AuthDecisionScreen({
    super.key,
    this.showSessionExpired = false,
  });

  final bool showSessionExpired;

  @override
  Widget build(BuildContext context) {
    final authController = AppDependenciesScope.of(context).authController;

    if (showSessionExpired) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted || !authController.state.sessionExpired) return;
        final action = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Sesi Berakhir'),
              content: const Text(
                'Sesi login kamu sudah berakhir. Mau login lagi atau lanjut sebagai guest?',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Guest'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Login lagi'),
                ),
              ],
            );
          },
        );
        if (!context.mounted) return;
        authController.clearSessionExpired();
        if (action == false) {
          authController.continueAsGuest();
        }
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            children: <Widget>[
              const Spacer(),
              Container(
                width: 108,
                height: 108,
                decoration: const BoxDecoration(
                  gradient: AppColors.heroGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mosque_rounded,
                  color: Colors.white,
                  size: 52,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Muslimku',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Teman ibadah digital untuk perjalanan spiritual yang lebih tenang dan terarah.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.55,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              PrimaryButton(
                label: 'Daftar',
                onPressed: () => Navigator.of(context).pushNamed(RouteNames.signup),
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                label: 'Login',
                isSecondary: true,
                onPressed: () => Navigator.of(context).pushNamed(RouteNames.login),
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                label: 'Lanjut dengan Google',
                icon: Icons.g_mobiledata_rounded,
                isSecondary: true,
                onPressed: () async {
                  final message = await authController.signInWithGoogle();
                  if (!context.mounted || message == null) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
                  );
                  if (!authController.state.isAuthenticated) return;
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    RouteNames.bootstrap,
                    (_) => false,
                  );
                },
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: <Widget>[
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(RouteNames.forgotPassword),
                    child: const Text('Lupa Password'),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(RouteNames.forgotUsername),
                    child: const Text('Lupa Username'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: authController.continueAsGuest,
                child: const Text('Lanjut sebagai tamu'),
              ),
              const SizedBox(height: 8),
              const Text(
                '1445 AH • Ramadan',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


