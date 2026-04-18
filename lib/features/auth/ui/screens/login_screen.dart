import 'package:flutter/material.dart';

import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/validators.dart';
import '../../../../di/injection.dart';
import '../../../../routes/route_names.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = AppDependenciesScope.of(context).authController;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: authController,
          builder: (context, _) {
            final state = authController.state;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 8),
                    const Text(
                      'Selamat datang kembali',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Masuk untuk menyinkronkan preferensi ibadah, bacaan terakhir, dan pengingat adzan kamu.',
                      style: TextStyle(height: 1.5),
                    ),
                    const SizedBox(height: 28),
                    AuthForm(
                      children: <Widget>[
                        AppTextField(
                          controller: _identifierController,
                          label: 'Email / Username',
                          hint: 'name@example.com / username',
                          icon: Icons.person_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.emailOrUsername,
                        ),
                        const SizedBox(height: 18),
                        AppTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Masukkan password',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          validator: Validators.password,
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.of(context)
                                .pushNamed(RouteNames.forgotPassword),
                            child: const Text('Lupa password?'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        AuthButton(
                          label: 'Login',
                          loading: state.submitting,
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;
                            final message = await authController.signIn(
                              identifier: _identifierController.text.trim(),
                              password: _passwordController.text,
                            );
                            if (!mounted) return;
                            if (message != null) context.showAppSnack(message);
                            if (authController.state.isAuthenticated) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                RouteNames.bootstrap,
                                (_) => false,
                              );
                              return;
                            }
                            if (authController.state.requiresVerification) {
                              Navigator.of(context).pushNamed(RouteNames.otp);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        AuthButton(
                          label: 'Lanjut dengan Google',
                          icon: Icons.g_mobiledata_rounded,
                          isSecondary: true,
                          onPressed: () async {
                            final message = await authController.signInWithGoogle();
                            if (!mounted) return;
                            if (message != null) context.showAppSnack(message);
                            if (!authController.state.isAuthenticated) return;
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              RouteNames.bootstrap,
                              (_) => false,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        children: <Widget>[
                          TextButton(
                            onPressed: () =>
                                Navigator.of(context).pushReplacementNamed(
                              RouteNames.signup,
                            ),
                            child: const Text('Belum punya akun? Daftar'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.of(context).pushNamed(
                              RouteNames.forgotUsername,
                            ),
                            child: const Text('Lupa username'),
                          ),
                        ],
                      ),
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
