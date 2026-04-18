import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/validators.dart';
import '../../../../di/injection.dart';
import '../../../../routes/route_names.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';

class ForgotUsernameScreen extends StatefulWidget {
  const ForgotUsernameScreen({super.key});

  @override
  State<ForgotUsernameScreen> createState() => _ForgotUsernameScreenState();
}

class _ForgotUsernameScreenState extends State<ForgotUsernameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recoveryController = TextEditingController();
  String? _recoveredUsername;
  String? _recoveredEmail;

  @override
  void dispose() {
    _recoveryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = AppDependenciesScope.of(context).authController;

    return Scaffold(
      appBar: AppBar(title: const Text('Lupa Username')),
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
                      child: const Center(
                        child: Icon(
                          Icons.badge_outlined,
                          size: 72,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Pulihkan username',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Masukkan email atau nomor telepon yang terhubung ke akunmu. Kami akan mencari username yang tersimpan lalu menampilkannya di aplikasi.',
                      style: TextStyle(
                        height: 1.55,
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      controller: _recoveryController,
                      label: 'Email / Phone',
                      hint: 'name@example.com / +62...',
                      icon: Icons.person_search_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.phoneOrEmail,
                      onChanged: (_) {
                        if (_recoveredUsername == null &&
                            _recoveredEmail == null) {
                          return;
                        }
                        setState(() {
                          _recoveredUsername = null;
                          _recoveredEmail = null;
                        });
                      },
                    ),
                    const SizedBox(height: 22),
                    PrimaryButton(
                      label: 'Cari Username',
                      loading: authController.state.submitting,
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        final result =
                            await authController.recoverUsernameDetails(
                          _recoveryController.text.trim(),
                        );
                        if (!mounted) return;
                        if (result.success &&
                            result.code == AuthResultCode.usernameRecovered) {
                          setState(() {
                            _recoveredUsername = result.username;
                            _recoveredEmail = result.email;
                          });
                          context.showAppSnack(
                            'Username ditemukan dan ditampilkan di bawah.',
                          );
                          return;
                        }
                        if (result.message == null) return;
                        context.showAppSnack(result.message!);
                      },
                    ),
                    if (_recoveredUsername != null) ...<Widget>[
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Hasil pencarian akun',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _recoveredUsername!,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                            if ((_recoveredEmail ?? '').isNotEmpty) ...<Widget>[
                              const SizedBox(height: 6),
                              Text(
                                _recoveredEmail!,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      await Clipboard.setData(
                                        ClipboardData(
                                          text: _recoveredUsername!,
                                        ),
                                      );
                                      if (!mounted) return;
                                      context.showAppSnack('Username disalin.');
                                    },
                                    icon: const Icon(Icons.copy_rounded),
                                    label: const Text('Copy'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: () => Navigator.of(context)
                                        .pushReplacementNamed(RouteNames.login),
                                    icon: const Icon(Icons.login_rounded),
                                    label: const Text('Login'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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
