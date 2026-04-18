import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/validators.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = AppDependenciesScope.of(context).authController;

    return Scaffold(
      appBar: AppBar(title: const Text('Ubah Password')),
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
                    const Text(
                      'Perbarui password',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Masukkan password saat ini, lalu buat password baru yang lebih kuat.',
                      style: TextStyle(
                        height: 1.55,
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    AppTextField(
                      controller: _currentController,
                      label: 'Password Saat Ini',
                      icon: Icons.lock_outline_rounded,
                      obscureText: true,
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      controller: _newController,
                      label: 'Password Baru',
                      icon: Icons.lock_reset_rounded,
                      obscureText: true,
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      controller: _confirmController,
                      label: 'Konfirmasi Password Baru',
                      icon: Icons.verified_user_outlined,
                      obscureText: true,
                      validator: (value) {
                        final error = Validators.password(value);
                        if (error != null) return error;
                        if (value != _newController.text) {
                          return 'Konfirmasi password tidak sama.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Simpan Password',
                      loading: authController.state.submitting,
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        final message = await authController.changePassword(
                          currentPassword: _currentController.text,
                          newPassword: _newController.text,
                        );
                        if (!mounted || message == null) return;
                        context.showAppSnack(message);
                        if (message.contains('berhasil')) {
                          Navigator.of(context).pop();
                        }
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
