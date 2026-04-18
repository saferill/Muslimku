import 'package:flutter/material.dart';

import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/validators.dart';
import '../../../../di/injection.dart';
import '../../../../routes/route_names.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_form.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = AppDependenciesScope.of(context).authController;

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Akun')),
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
                    const Text(
                      'Bergabung dengan Muslimku',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Buat akun untuk menyimpan bacaan, preferensi audio, dan jadwal ibadah personalmu.',
                      style: TextStyle(height: 1.5),
                    ),
                    const SizedBox(height: 28),
                    AuthForm(
                      children: <Widget>[
                        AppTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'Abdullah Rahman',
                          icon: Icons.person_outline,
                          validator: (value) =>
                              Validators.requiredField(value, 'Nama lengkap'),
                        ),
                        const SizedBox(height: 18),
                        AppTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'name@example.com',
                          icon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 18),
                        AppTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Minimal 8 karakter',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          validator: Validators.password,
                        ),
                        const SizedBox(height: 18),
                        AppTextField(
                          controller: _confirmController,
                          label: 'Confirm Password',
                          hint: 'Ulangi password',
                          icon: Icons.verified_user_outlined,
                          obscureText: true,
                          validator: (value) {
                            final error = Validators.password(value);
                            if (error != null) return error;
                            if (value != _passwordController.text) {
                              return 'Konfirmasi password tidak sama.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        AuthButton(
                          label: 'Buat Akun',
                          loading: state.submitting,
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;
                            final message = await authController.signUp(
                              fullName: _nameController.text.trim(),
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                            );
                            if (!mounted) return;
                            if (message != null) context.showAppSnack(message);
                            if (authController.state.requiresVerification) {
                              Navigator.of(context).pushReplacementNamed(
                                RouteNames.otp,
                              );
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
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed(RouteNames.login),
                      child: const Text('Sudah punya akun? Login'),
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
