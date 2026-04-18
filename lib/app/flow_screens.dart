import 'package:flutter/material.dart';

import 'app_session.dart';
import 'auth_screens.dart';
import '../data/demo_content.dart';
import '../services/location_service.dart';
import '../theme/muslimku_theme.dart';
import 'common_widgets.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, this.onContinue});

  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [MuslimKuColors.primaryContainer, MuslimKuColors.primary],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: PatternOverlay()),
            Positioned(
              top: -120,
              left: -80,
              child: _glow(
                  MuslimKuColors.primaryFixedDim.withValues(alpha: 0.20), 320),
            ),
            Positioned(
              bottom: -140,
              right: -80,
              child: _glow(
                  MuslimKuColors.primaryFixedDim.withValues(alpha: 0.10), 320),
            ),
            SafeArea(
              child: InkWell(
                onTap: onContinue,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
                  child: Column(
                    children: [
                      const Spacer(),
                      Column(
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 38,
                                  offset: const Offset(0, 26),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(5),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(36),
                              ),
                              child: const Icon(Icons.mosque_rounded,
                                  size: 54, color: MuslimKuColors.primary),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'Muslimku',
                            style: theme.textTheme.displaySmall
                                ?.copyWith(color: Colors.white, fontSize: 40),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'SUAKA DIGITAL',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white70,
                              letterSpacing: 3.2,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          Text(
                            'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontSize: 28,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '"Sesungguhnya dengan mengingat Allah hati menjadi tenteram."',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white60,
                              letterSpacing: 1.6,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            onContinue == null
                                ? 'Menyiapkan pengalaman Anda...'
                                : 'Ketuk di mana saja untuk lanjut',
                            style: theme.textTheme.labelLarge
                                ?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _glow(Color color, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(color: color, blurRadius: 120, spreadRadius: 20)
          ],
        ),
      ),
    );
  }
}

enum AuthStep { login, signup, forgotPassword, otp }

class AuthFlowScreen extends StatefulWidget {
  const AuthFlowScreen({
    super.key,
    required this.onAuthenticated,
    required this.onSkip,
  });

  final VoidCallback onAuthenticated;
  final VoidCallback onSkip;

  @override
  State<AuthFlowScreen> createState() => _AuthFlowScreenState();
}

class _AuthFlowScreenState extends State<AuthFlowScreen> {
  AuthStep _step = AuthStep.login;

  @override
  Widget build(BuildContext context) {
    final session = AppSessionScope.of(context);

    switch (_step) {
      case AuthStep.login:
        return InteractiveLoginScreen(
          onLogin: widget.onAuthenticated,
          onSignup: () => setState(() => _step = AuthStep.signup),
          onForgotPassword: () =>
              setState(() => _step = AuthStep.forgotPassword),
          onSkip: widget.onSkip,
          onGoogle: () => _handleGoogle(context),
          onApple: () => _handleApple(context),
        );
      case AuthStep.signup:
        return InteractiveSignupScreen(
          session: session,
          onBackToLogin: () => setState(() => _step = AuthStep.login),
          onContinue: widget.onAuthenticated,
          onGoogle: () => _handleGoogle(context),
          onApple: () => _handleApple(context),
        );
      case AuthStep.forgotPassword:
        return InteractiveForgotPasswordScreen(
          onBackToLogin: () => setState(() => _step = AuthStep.login),
          onSendLink: () => setState(() => _step = AuthStep.login),
        );
      case AuthStep.otp:
        return InteractiveOtpVerificationScreen(
          onVerified: widget.onAuthenticated,
          onBackToLogin: () => setState(() => _step = AuthStep.login),
          onResend: () {},
        );
    }
  }

  Future<void> _handleGoogle(BuildContext context) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Google Sign-In belum aktif. Lengkapi OAuth client di Firebase untuk mengaktifkannya.',
          ),
        ),
      );
  }

  Future<void> _handleApple(BuildContext context) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Sign in with Apple belum aktif. Lengkapi konfigurasi provider di Firebase terlebih dahulu.',
          ),
        ),
      );
  }
}

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  late final PageController _pageController;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = onboardingSteps[_index];
    final lastPage = _index == onboardingSteps.length - 1;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: widget.onDone,
                          child: const Text('Lewati'),
                        ),
                      ),
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: onboardingSteps.length,
                          onPageChanged: (value) =>
                              setState(() => _index = value),
                          itemBuilder: (context, pageIndex) {
                            return _OnboardingPage(
                                step: onboardingSteps[pageIndex],
                                index: pageIndex);
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          onboardingSteps.length,
                          (dotIndex) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: dotIndex == _index ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: dotIndex == _index
                                  ? MuslimKuColors.primary
                                  : MuslimKuColors.surfaceHighest,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      PrimaryButton(
                        label: lastPage ? 'Mulai' : 'Lanjut',
                        onPressed: () {
                          if (lastPage) {
                            widget.onDone();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeOutCubic,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      TextButton(
                        onPressed: widget.onDone,
                        child: const Text('Lewati dulu'),
                      ),
                      const SizedBox(height: 6),
                      Text(step.caption,
                          style: Theme.of(context).textTheme.labelMedium),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
    required this.onLogin,
    required this.onSignup,
    required this.onForgotPassword,
    required this.onSkip,
    required this.onGoogle,
    required this.onApple,
  });

  final VoidCallback onLogin;
  final VoidCallback onSignup;
  final VoidCallback onForgotPassword;
  final VoidCallback onSkip;
  final VoidCallback onGoogle;
  final VoidCallback onApple;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          Positioned(
            top: -140,
            right: -120,
            child:
                _authGlow(MuslimKuColors.primary.withValues(alpha: 0.08), 320),
          ),
          Positioned(
            bottom: -140,
            left: -120,
            child: _authGlow(
                MuslimKuColors.primaryContainer.withValues(alpha: 0.10), 340),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: onSkip,
                          child: const Text('Lewati'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          color: MuslimKuColors.primaryContainer,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: MuslimKuColors.primary
                                  .withValues(alpha: 0.18),
                              blurRadius: 26,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.mosque_rounded,
                            color: Colors.white, size: 44),
                      ),
                      const SizedBox(height: 18),
                      Text('Muslimku',
                          style: theme.textTheme.displaySmall
                              ?.copyWith(fontSize: 38)),
                      const SizedBox(height: 6),
                      Text(
                        'Kembali ke suaka digitalmu',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 26),
                      SurfaceCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Alamat Email',
                                style: theme.textTheme.labelLarge),
                            const SizedBox(height: 8),
                            TextField(
                              decoration: const InputDecoration(
                                hintText: 'name@example.com',
                                prefixIcon: Icon(Icons.mail_rounded),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Kata Sandi',
                                    style: theme.textTheme.labelLarge),
                                TextButton(
                                  onPressed: onForgotPassword,
                                  child: const Text('Lupa Kata Sandi?'),
                                ),
                              ],
                            ),
                            TextField(
                              obscureText: true,
                              decoration: const InputDecoration(
                                hintText: '••••••••',
                                prefixIcon: Icon(Icons.lock_rounded),
                              ),
                            ),
                            const SizedBox(height: 20),
                            PrimaryButton(label: 'Masuk', onPressed: onLogin),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                              child: Divider(
                                  color: MuslimKuColors.outline
                                      .withValues(alpha: 0.4))),
                          const SizedBox(width: 12),
                          Text('atau lanjutkan dengan',
                              style: theme.textTheme.labelMedium),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Divider(
                                  color: MuslimKuColors.outline
                                      .withValues(alpha: 0.4))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _AuthSocialButton(
                              icon: Icons.g_mobiledata_rounded,
                              label: 'Google',
                              onTap: onGoogle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _AuthSocialButton(
                              icon: Icons.apple_rounded,
                              label: 'Apple',
                              onTap: onApple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      TextButton(
                        onPressed: onSignup,
                        child: const Text('Belum punya akun? Daftar'),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '“Hati menemukan ketenangan dalam mengingat Allah”',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelMedium
                            ?.copyWith(letterSpacing: 1.2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SignupScreen extends StatelessWidget {
  const SignupScreen({
    super.key,
    required this.onBackToLogin,
    required this.onContinue,
    required this.onGoogle,
    required this.onApple,
  });

  final VoidCallback onBackToLogin;
  final VoidCallback onContinue;
  final VoidCallback onGoogle;
  final VoidCallback onApple;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: onBackToLogin,
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const Spacer(),
                          Text('Muslimku',
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(color: MuslimKuColors.primary)),
                          const Spacer(),
                          TextButton(
                            onPressed: onBackToLogin,
                            child: const Text('Lewati'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text('Buat Akun',
                          style: theme.textTheme.displaySmall
                              ?.copyWith(fontSize: 36)),
                      const SizedBox(height: 6),
                      Text(
                        'Bergabunglah dengan komunitas kami untuk suaka digital yang damai',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 22),
                      SurfaceCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            TextField(
                              decoration: const InputDecoration(
                                hintText: 'Masukkan nama lengkap',
                                prefixIcon: Icon(Icons.person_rounded),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              decoration: const InputDecoration(
                                hintText: 'email@example.com',
                                prefixIcon: Icon(Icons.mail_rounded),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      hintText: 'Kata Sandi',
                                      prefixIcon: Icon(Icons.lock_rounded),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      hintText: 'Konfirmasi',
                                      prefixIcon:
                                          Icon(Icons.lock_reset_rounded),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Checkbox(value: true, onChanged: (_) {}),
                                Expanded(
                                  child: Text(
                                    'Saya setuju dengan Syarat & Ketentuan dan Kebijakan Privasi',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            PrimaryButton(
                                label: 'Buat Akun', onPressed: onContinue),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                    child: Divider(
                                        color: MuslimKuColors.outline
                                            .withValues(alpha: 0.4))),
                                const SizedBox(width: 12),
                                Text('atau daftar dengan',
                                    style: theme.textTheme.labelMedium),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Divider(
                                        color: MuslimKuColors.outline
                                            .withValues(alpha: 0.4))),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _AuthSocialButton(
                                    icon: Icons.g_mobiledata_rounded,
                                    label: 'Google',
                                    onTap: onGoogle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _AuthSocialButton(
                                    icon: Icons.apple_rounded,
                                    label: 'Apple',
                                    onTap: onApple,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextButton(
                        onPressed: onBackToLogin,
                        child: const Text('Sudah punya akun? Masuk'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({
    super.key,
    required this.onBackToLogin,
    required this.onSendLink,
  });

  final VoidCallback onBackToLogin;
  final VoidCallback onSendLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          Positioned(
            top: -120,
            right: -80,
            child:
                _authGlow(MuslimKuColors.primary.withValues(alpha: 0.08), 260),
          ),
          Positioned(
            bottom: -120,
            left: -80,
            child: _authGlow(
                MuslimKuColors.primaryContainer.withValues(alpha: 0.10), 280),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: onBackToLogin,
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const SizedBox(width: 6),
                          Text('Verifikasi',
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(color: MuslimKuColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: MuslimKuColors.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.lock_reset_rounded,
                            color: MuslimKuColors.primary, size: 40),
                      ),
                      const SizedBox(height: 20),
                      Text('Atur Ulang Kata Sandi',
                          style: theme.textTheme.displaySmall
                              ?.copyWith(fontSize: 34)),
                      const SizedBox(height: 8),
                      Text(
                        'Masukkan alamat email untuk menerima tautan reset kata sandi.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      SurfaceCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Alamat Email',
                                style: theme.textTheme.labelLarge),
                            const SizedBox(height: 8),
                            TextField(
                              decoration: const InputDecoration(
                                hintText: 'name@example.com',
                                prefixIcon: Icon(Icons.mail_rounded),
                              ),
                            ),
                            const SizedBox(height: 18),
                            PrimaryButton(
                                label: 'Kirim Tautan Reset',
                                onPressed: onSendLink),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: onBackToLogin,
                        child: const Text('Kembali ke Masuk'),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                        textDirection: TextDirection.rtl,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: MuslimKuColors.primaryContainer,
                          fontSize: 28,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({
    super.key,
    required this.onVerified,
    required this.onBackToLogin,
    required this.onResend,
  });

  final VoidCallback onVerified;
  final VoidCallback onBackToLogin;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: onBackToLogin,
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const SizedBox(width: 6),
                          Text('Verifikasi',
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(color: MuslimKuColors.primary)),
                          const Spacer(),
                          Text('Muslimku',
                              style: theme.textTheme.labelLarge
                                  ?.copyWith(color: MuslimKuColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 26),
                      Text('Periksa kotak masuk',
                          style: theme.textTheme.displaySmall
                              ?.copyWith(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(
                        'Kami telah mengirim kode 6 digit ke email Anda. Masukkan di bawah untuk melanjutkan.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      SurfaceCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Row(
                              children: List.generate(
                                6,
                                (index) => Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        right: index == 5 ? 0 : 6),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      color: MuslimKuColors.surfaceLow,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: TextField(
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      maxLength: 1,
                                      decoration: const InputDecoration(
                                        counterText: '',
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            PrimaryButton(
                                label: 'Verifikasi Akun',
                                onPressed: onVerified),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: onResend,
                              child: const Text('Kirim ulang (dalam 59 dtk)'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: onBackToLogin,
                        child: const Text('Kembali ke Masuk'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GoogleAccountPickerScreen extends StatelessWidget {
  const GoogleAccountPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                  child: Column(
                    children: [
                      SurfaceCard(
                        padding: const EdgeInsets.fromLTRB(0, 28, 0, 20),
                        child: Column(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: MuslimKuColors.primaryContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.mosque_rounded,
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            Text('Pilih akun',
                                style: theme.textTheme.titleLarge),
                            const SizedBox(height: 6),
                            Text(
                              'Untuk melanjutkan ke Muslimku',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: MuslimKuColors.textSecondary),
                            ),
                            const SizedBox(height: 20),
                            const Divider(height: 1),
                            _AccountRow(
                              name: 'Ahmad Abdullah',
                              email: 'ahmad.abd@gmail.com',
                              highlight: true,
                            ),
                            const Divider(height: 1),
                            _AccountRow(
                              name: 'Abdullah Kareem',
                              email: 'abdullah.k@gmail.com',
                            ),
                            const Divider(height: 1),
                            _AccountRow(
                              name: 'Gunakan akun lain',
                              email: '',
                              isAdd: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Untuk melanjutkan, Google akan membagikan nama, alamat email, preferensi bahasa, dan foto '
                        'profil Anda kepada Muslimku. Anda dapat meninjau kebijakan privasi dan ketentuan layanan kami.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelMedium
                            ?.copyWith(color: MuslimKuColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppleIdConfirmationScreen extends StatelessWidget {
  const AppleIdConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.35,
              child: const AppBackground(),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                  child: Container(
                    decoration: BoxDecoration(
                      color: MuslimKuColors.surface,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 28,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
                    child: Column(
                      children: [
                        Container(
                          width: 46,
                          height: 6,
                          decoration: BoxDecoration(
                            color:
                                MuslimKuColors.outline.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: MuslimKuColors.surfaceLow,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(Icons.face_rounded,
                              size: 52, color: MuslimKuColors.text),
                        ),
                        const SizedBox(height: 20),
                        Text('Masuk dengan Apple ID',
                            style: theme.textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text(
                          'Gunakan Apple ID Anda untuk masuk ke Muslimku',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: MuslimKuColors.textSecondary),
                        ),
                        const SizedBox(height: 22),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: MuslimKuColors.surfaceLow,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: MuslimKuColors.surfaceHigh,
                                child: Icon(Icons.person_rounded,
                                    color: MuslimKuColors.text),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Ahmed Al-Farsi',
                                        style: theme.textTheme.labelLarge),
                                    Text(
                                      'a.alfarsi@icloud.com',
                                      style:
                                          theme.textTheme.labelMedium?.copyWith(
                                        color: MuslimKuColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded,
                                  color: MuslimKuColors.textSecondary),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        PrimaryButton(
                            label: 'Lanjutkan',
                            onPressed: () => Navigator.of(context).pop()),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: MuslimKuColors.textSecondary,
                            side: BorderSide(
                                color: MuslimKuColors.outline
                                    .withValues(alpha: 0.4)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('Batal'),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Autentikasi aman. Data Anda terenkripsi dan ditangani dengan hati-hati.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelMedium
                              ?.copyWith(color: MuslimKuColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.name,
    required this.email,
    this.highlight = false,
    this.isAdd = false,
  });

  final String name;
  final String email;
  final bool highlight;
  final bool isAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => Navigator.of(context).pop(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: highlight
                  ? MuslimKuColors.primaryFixed.withValues(alpha: 0.3)
                  : MuslimKuColors.surface,
              child: Icon(
                isAdd ? Icons.person_add_rounded : Icons.person_rounded,
                color: highlight
                    ? MuslimKuColors.primary
                    : MuslimKuColors.textSecondary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: theme.textTheme.labelLarge),
                  if (email.isNotEmpty)
                    Text(
                      email,
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: MuslimKuColors.textSecondary),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthSocialButton extends StatelessWidget {
  const _AuthSocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: MuslimKuColors.text),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

Widget _authGlow(Color color, double size) {
  return IgnorePointer(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 120, spreadRadius: 20)],
      ),
    ),
  );
}

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({
    super.key,
    required this.onContinue,
    required this.onLater,
  });

  final VoidCallback onContinue;
  final VoidCallback onLater;

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool _requestingLocation = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = AppSessionScope.of(context);
    final ready = session.permissionsReady;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: widget.onLater,
                        icon: const Icon(Icons.close_rounded,
                            color: MuslimKuColors.primary),
                      ),
                      const Spacer(),
                      Text(
                        'Izin Penting',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(color: MuslimKuColors.primary),
                      ),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: MuslimKuColors.primaryContainer,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 22,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.mosque_rounded,
                                color: Colors.white, size: 36),
                          ),
                          const SizedBox(height: 18),
                          Text('Mulai Perjalananmu',
                              style: theme.textTheme.headlineSmall),
                          const SizedBox(height: 6),
                          Text(
                            'Untuk memberikan pengalaman spiritual yang paling akurat, Muslimku memerlukan beberapa izin.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 22),
                          _PermissionCard(
                            icon: Icons.location_on_rounded,
                            title: 'Akses Lokasi',
                            description:
                                'Menghitung waktu salat dan arah kiblat secara presisi berdasarkan lokasi Anda.',
                            enabled: session.locationPermissionEnabled,
                            onAllow: _requestingLocation
                                ? () {}
                                : () => _requestLocationPermission(session),
                          ),
                          const SizedBox(height: 16),
                          _PermissionCard(
                            icon: Icons.notifications_active_rounded,
                            title: 'Akses Notifikasi',
                            description:
                                'Jangan lewatkan salat dengan pengingat adzan tepat waktu, doa harian, dan notifikasi spiritual.',
                            enabled: session.notificationPermissionEnabled,
                            onAllow: () =>
                                session.setNotificationPermissionEnabled(
                              !session.notificationPermissionEnabled,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: MuslimKuColors.surfaceLow
                                  .withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.security_rounded,
                                    color: MuslimKuColors.primary, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Data Anda tetap privat & aman',
                                  style: theme.textTheme.labelSmall
                                      ?.copyWith(letterSpacing: 1.2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  decoration: BoxDecoration(
                    color: MuslimKuColors.surface.withValues(alpha: 0.94),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 24,
                        offset: const Offset(0, -8),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: ready ? widget.onContinue : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: MuslimKuColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: Text(
                          ready
                              ? 'Lanjut ke Aplikasi'
                              : 'Aktifkan izin terlebih dahulu',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestLocationPermission(
    AppSessionController session,
  ) async {
    setState(() => _requestingLocation = true);
    final result = await AppLocationService.requestLocationPermission();
    if (!mounted) return;
    setState(() => _requestingLocation = false);
    session.setLocationPermissionEnabled(result.success);

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? 'Izin lokasi berhasil diaktifkan.'
              : (result.message ?? 'Izin lokasi belum diberikan.'),
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.enabled,
    required this.onAllow,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool enabled;
  final VoidCallback onAllow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: MuslimKuColors.primaryFixed,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: MuslimKuColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(description, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: enabled
                    ? MuslimKuColors.primary
                    : MuslimKuColors.surfaceHigh,
                foregroundColor:
                    enabled ? Colors.white : MuslimKuColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: onAllow,
              child: Text(enabled ? 'Sudah Aktif' : 'Izinkan Akses'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.step,
    required this.index,
  });

  final OnboardingStepData step;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.70),
                borderRadius: BorderRadius.circular(42),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 28,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: _OnboardingArt(step: step, index: index),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          step.title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(fontSize: 36),
        ),
        Text(
          step.highlight,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 36,
            color: MuslimKuColors.primary,
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            step.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _OnboardingArt extends StatelessWidget {
  const _OnboardingArt({
    required this.step,
    required this.index,
  });

  final OnboardingStepData step;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  MuslimKuColors.primaryFixed.withValues(alpha: 0.25),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: -20,
          top: -20,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: MuslimKuColors.primaryFixed.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: -10,
          bottom: -10,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: MuslimKuColors.primary.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: index == 0
                ? _AdzanIllustration(step: step)
                : index == 1
                    ? const _QuranIllustration()
                    : const _AudioIllustration(),
          ),
        ),
      ],
    );
  }
}

class _AdzanIllustration extends StatelessWidget {
  const _AdzanIllustration({required this.step});

  final OnboardingStepData step;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(
              Icons.mosque_rounded,
              size: 110,
              color: MuslimKuColors.primaryContainer,
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: GlassInfoCard(
              leading: step.icon,
              title: 'Salat Berikutnya',
              subtitle: 'Asr • 15:24',
              tag: 'ALARM AKTIF',
            ),
          ),
        ],
      ),
    );
  }
}

class _QuranIllustration extends StatelessWidget {
  const _QuranIllustration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Center(
            child: Icon(
              Icons.auto_stories_rounded,
              size: 120,
              color: MuslimKuColors.primaryContainer,
            ),
          ),
        ),
        Positioned(
          left: 18,
          right: 18,
          bottom: 18,
          child: GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_stories_rounded,
                        color: MuslimKuColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Hikmah Harian',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: MuslimKuColors.primary),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'أَفَلَا يَتَدَبَّرُونَ الْقُرْآنَ',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: MuslimKuColors.text),
                ),
                SizedBox(height: 6),
                Text(
                  '"Then do they not reflect upon the Qur\'an?"',
                  style: TextStyle(color: MuslimKuColors.textSoft),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AudioIllustration extends StatelessWidget {
  const _AudioIllustration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  AudioBar(height: 36, opacity: 0.2),
                  AudioBar(height: 64, opacity: 0.35),
                  AudioBar(height: 92, opacity: 0.55),
                  AudioBar(height: 54, opacity: 0.7),
                  AudioBar(height: 112, opacity: 1.0),
                  AudioBar(height: 70, opacity: 0.75),
                  AudioBar(height: 88, opacity: 0.55),
                  AudioBar(height: 42, opacity: 0.3),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: MuslimKuColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.headphones_rounded,
                    size: 52, color: MuslimKuColors.primary),
              ),
            ],
          ),
        ),
        const Positioned(
          left: 18,
          right: 18,
          bottom: 18,
          child: GlassInfoCard(
            leading: Icons.play_arrow_rounded,
            title: 'Mishary Rashid Alafasy',
            subtitle: 'Surah Ar-Rahman',
            tag: 'PLAYING',
          ),
        ),
      ],
    );
  }
}
