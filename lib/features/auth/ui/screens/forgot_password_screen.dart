import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/validators.dart';
import '../../../../di/injection.dart';
import '../../../../routes/route_names.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = AppDependenciesScope.of(context).authController;

    return Scaffold(
      appBar: AppBar(title: const Text('Lupa Password')),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: authController,
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
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
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            gradient: AppColors.heroGradient,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: const Icon(
                            Icons.mark_email_read_rounded,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Atur ulang akses akun',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Masukkan email akunmu. Kami kirimkan link reset password agar kamu bisa mengatur password baru dengan aman.',
                      style: TextStyle(
                        height: 1.55,
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      controller: _emailController,
                      label: 'Alamat Email',
                      hint: 'name@example.com',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 22),
                    PrimaryButton(
                      label: 'Kirim Link Reset',
                      loading: authController.state.submitting,
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        final result = await authController.sendPasswordReset(
                          _emailController.text.trim(),
                        );
                        if (!mounted) return;
                        if (result.message != null) {
                          context.showAppSnack(result.message!);
                        }
                        if (!result.success &&
                            result.code != AuthResultCode.passwordResetSent) {
                          return;
                        }
                        Navigator.of(context).pushReplacementNamed(
                          RouteNames.resetPassword,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
