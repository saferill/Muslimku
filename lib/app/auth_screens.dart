import 'package:flutter/material.dart';

import 'app_session.dart';
import '../services/auth_service.dart';
import '../theme/muslimku_theme.dart';
import 'common_widgets.dart';

final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

Widget _buildAuthGlow(Color color, double size) {
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

void _showAuthMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
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

class InteractiveLoginScreen extends StatefulWidget {
  const InteractiveLoginScreen({
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
  State<InteractiveLoginScreen> createState() => _InteractiveLoginScreenState();
}

class _InteractiveLoginScreenState extends State<InteractiveLoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscureText = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailController.addListener(_handleChanged);
    _passwordController.addListener(_handleChanged);
  }

  @override
  void dispose() {
    _emailController
      ..removeListener(_handleChanged)
      ..dispose();
    _passwordController
      ..removeListener(_handleChanged)
      ..dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _emailPattern.hasMatch(_emailController.text.trim()) &&
      _passwordController.text.trim().length >= 8;

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
            child: _buildAuthGlow(
                MuslimKuColors.primary.withValues(alpha: 0.08), 320),
          ),
          Positioned(
            bottom: -140,
            left: -120,
            child: _buildAuthGlow(
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
                          onPressed: widget.onSkip,
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
                      Text('Kembali ke suaka digitalmu',
                          style: theme.textTheme.bodyMedium),
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
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
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
                                  onPressed: widget.onForgotPassword,
                                  child: const Text('Lupa Kata Sandi?'),
                                ),
                              ],
                            ),
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscureText,
                              autofillHints: const [AutofillHints.password],
                              decoration: InputDecoration(
                                hintText:
                                    '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
                                prefixIcon: const Icon(Icons.lock_rounded),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(
                                      () => _obscureText = !_obscureText),
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Gunakan email valid dan kata sandi minimal 8 karakter.',
                              style: theme.textTheme.labelMedium,
                            ),
                            const SizedBox(height: 20),
                            PrimaryButton(
                              label: _submitting ? 'Memproses...' : 'Masuk',
                              onPressed:
                                  _canSubmit && !_submitting ? _submit : null,
                            ),
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
                              onTap: widget.onGoogle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _AuthSocialButton(
                              icon: Icons.apple_rounded,
                              label: 'Apple',
                              onTap: widget.onApple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      TextButton(
                        onPressed: widget.onSignup,
                        child: const Text('Belum punya akun? Daftar'),
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

  void _handleChanged() => setState(() {});

  Future<void> _submit() async {
    if (!_canSubmit) {
      _showAuthMessage(
          context, 'Lengkapi email valid dan kata sandi minimal 8 karakter.');
      return;
    }

    setState(() => _submitting = true);
    final result = await AppAuthService.signInWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (!result.success) {
      _showAuthMessage(
        context,
        result.message ?? 'Tidak bisa masuk sekarang. Coba lagi.',
      );
      return;
    }

    final session = AppSessionScope.of(context);
    session.applyAuthenticatedIdentity(
      fullName: result.fullName,
      email: result.email ?? _emailController.text.trim(),
    );
    if (result.message != null) {
      _showAuthMessage(context, result.message!);
    }
    widget.onLogin();
  }
}

class InteractiveSignupScreen extends StatefulWidget {
  const InteractiveSignupScreen({
    super.key,
    required this.session,
    required this.onBackToLogin,
    required this.onContinue,
    required this.onGoogle,
    required this.onApple,
  });

  final AppSessionController session;
  final VoidCallback onBackToLogin;
  final VoidCallback onContinue;
  final VoidCallback onGoogle;
  final VoidCallback onApple;

  @override
  State<InteractiveSignupScreen> createState() =>
      _InteractiveSignupScreenState();
}

class _InteractiveSignupScreenState extends State<InteractiveSignupScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmController;
  bool _acceptedTerms = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.session.profile.fullName);
    _emailController =
        TextEditingController(text: widget.session.profile.email);
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
    _nameController.addListener(_handleChanged);
    _emailController.addListener(_handleChanged);
    _passwordController.addListener(_handleChanged);
    _confirmController.addListener(_handleChanged);
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_handleChanged)
      ..dispose();
    _emailController
      ..removeListener(_handleChanged)
      ..dispose();
    _passwordController
      ..removeListener(_handleChanged)
      ..dispose();
    _confirmController
      ..removeListener(_handleChanged)
      ..dispose();
    super.dispose();
  }

  bool get _canSubmit {
    final password = _passwordController.text.trim();
    return _nameController.text.trim().isNotEmpty &&
        _emailPattern.hasMatch(_emailController.text.trim()) &&
        password.length >= 8 &&
        password == _confirmController.text.trim() &&
        _acceptedTerms;
  }

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
                            onPressed: widget.onBackToLogin,
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const Spacer(),
                          Text(
                            'Muslimku',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(color: MuslimKuColors.primary),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: widget.onBackToLogin,
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
                        'Bergabunglah dengan komunitas kami untuk suaka digital yang damai.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 22),
                      SurfaceCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            TextField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                hintText: 'Masukkan nama lengkap',
                                prefixIcon: Icon(Icons.person_rounded),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
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
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      hintText: 'Kata Sandi',
                                      prefixIcon:
                                          const Icon(Icons.lock_rounded),
                                      suffixIcon: IconButton(
                                        onPressed: () => setState(
                                          () => _obscurePassword =
                                              !_obscurePassword,
                                        ),
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_rounded
                                              : Icons.visibility_rounded,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _confirmController,
                                    obscureText: _obscureConfirm,
                                    decoration: InputDecoration(
                                      hintText: 'Konfirmasi',
                                      prefixIcon:
                                          const Icon(Icons.lock_reset_rounded),
                                      suffixIcon: IconButton(
                                        onPressed: () => setState(
                                          () => _obscureConfirm =
                                              !_obscureConfirm,
                                        ),
                                        icon: Icon(
                                          _obscureConfirm
                                              ? Icons.visibility_off_rounded
                                              : Icons.visibility_rounded,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _acceptedTerms,
                                  onChanged: (value) => setState(
                                      () => _acceptedTerms = value ?? false),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 14),
                                    child: Text(
                                      'Saya setuju dengan Syarat & Ketentuan dan Kebijakan Privasi.',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Kata sandi minimal 8 karakter dan konfirmasi harus sama.',
                              style: theme.textTheme.labelMedium,
                            ),
                            const SizedBox(height: 16),
                            PrimaryButton(
                              label: _submitting ? 'Memproses...' : 'Buat Akun',
                              onPressed:
                                  _canSubmit && !_submitting ? _submit : null,
                            ),
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
                                    onTap: widget.onGoogle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _AuthSocialButton(
                                    icon: Icons.apple_rounded,
                                    label: 'Apple',
                                    onTap: widget.onApple,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextButton(
                        onPressed: widget.onBackToLogin,
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

  void _handleChanged() => setState(() {});

  Future<void> _submit() async {
    if (!_canSubmit) {
      _showAuthMessage(
          context, 'Lengkapi data akun dengan benar terlebih dahulu.');
      return;
    }

    setState(() => _submitting = true);
    final result = await AppAuthService.signUpWithEmail(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    if (!result.success) {
      _showAuthMessage(
        context,
        result.message ?? 'Tidak bisa membuat akun sekarang. Coba lagi.',
      );
      return;
    }

    widget.session.applyAuthenticatedIdentity(
      fullName: result.fullName ?? _nameController.text.trim(),
      email: result.email ?? _emailController.text.trim(),
    );
    if (result.message != null) {
      _showAuthMessage(context, result.message!);
    }
    widget.onContinue();
  }
}

class InteractiveForgotPasswordScreen extends StatefulWidget {
  const InteractiveForgotPasswordScreen({
    super.key,
    required this.onBackToLogin,
    required this.onSendLink,
  });

  final VoidCallback onBackToLogin;
  final VoidCallback onSendLink;

  @override
  State<InteractiveForgotPasswordScreen> createState() =>
      _InteractiveForgotPasswordScreenState();
}

class _InteractiveForgotPasswordScreenState
    extends State<InteractiveForgotPasswordScreen> {
  late final TextEditingController _emailController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _emailController.addListener(_handleChanged);
  }

  @override
  void dispose() {
    _emailController
      ..removeListener(_handleChanged)
      ..dispose();
    super.dispose();
  }

  bool get _canSubmit => _emailPattern.hasMatch(_emailController.text.trim());

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
            child: _buildAuthGlow(
                MuslimKuColors.primary.withValues(alpha: 0.08), 260),
          ),
          Positioned(
            bottom: -120,
            left: -80,
            child: _buildAuthGlow(
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
                            onPressed: widget.onBackToLogin,
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Verifikasi',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(color: MuslimKuColors.primary),
                          ),
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
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'name@example.com',
                                prefixIcon: Icon(Icons.mail_rounded),
                              ),
                            ),
                            const SizedBox(height: 18),
                            PrimaryButton(
                              label: _submitting
                                  ? 'Mengirim...'
                                  : 'Kirim Tautan Reset',
                              onPressed:
                                  _canSubmit && !_submitting ? _submit : null,
                            ),
                          ],
                        ),
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

  void _handleChanged() => setState(() {});

  Future<void> _submit() async {
    if (!_canSubmit) {
      _showAuthMessage(context, 'Masukkan alamat email yang valid.');
      return;
    }

    setState(() => _submitting = true);
    final result = await AppAuthService.sendPasswordReset(
      _emailController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);

    _showAuthMessage(
      context,
      result.message ?? 'Gagal mengirim email reset.',
    );
    if (!result.success) return;
    widget.onSendLink();
  }
}

class InteractiveOtpVerificationScreen extends StatefulWidget {
  const InteractiveOtpVerificationScreen({
    super.key,
    required this.onVerified,
    required this.onBackToLogin,
    required this.onResend,
  });

  final VoidCallback onVerified;
  final VoidCallback onBackToLogin;
  final VoidCallback onResend;

  @override
  State<InteractiveOtpVerificationScreen> createState() =>
      _InteractiveOtpVerificationScreenState();
}

class _InteractiveOtpVerificationScreenState
    extends State<InteractiveOtpVerificationScreen> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());
    for (final controller in _controllers) {
      controller.addListener(_handleChanged);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller
        ..removeListener(_handleChanged)
        ..dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _code =>
      _controllers.map((controller) => controller.text.trim()).join();
  bool get _canSubmit => _code.length == 6;

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
                            onPressed: widget.onBackToLogin,
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Verifikasi',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(color: MuslimKuColors.primary),
                          ),
                          const Spacer(),
                          Text(
                            'Muslimku',
                            style: theme.textTheme.labelLarge
                                ?.copyWith(color: MuslimKuColors.primary),
                          ),
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
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                      color: MuslimKuColors.surfaceLow,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: TextField(
                                      controller: _controllers[index],
                                      focusNode: _focusNodes[index],
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      maxLength: 1,
                                      onChanged: (value) =>
                                          _handleDigitChange(index, value),
                                      decoration: const InputDecoration(
                                        counterText: '',
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Gunakan kode demo apa pun selama 6 digit penuh.',
                              style: theme.textTheme.labelMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            PrimaryButton(
                              label: 'Verifikasi Akun',
                              onPressed: _canSubmit ? widget.onVerified : null,
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () {
                                _clearCode();
                                widget.onResend();
                                _showAuthMessage(context,
                                    'Kode baru dikirim. Silakan cek inbox Anda.');
                              },
                              child: const Text('Kirim ulang kode'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: widget.onBackToLogin,
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

  void _handleChanged() => setState(() {});

  void _handleDigitChange(int index, String value) {
    if (value.length > 1) {
      final lastChar = value.substring(value.length - 1);
      _controllers[index].text = lastChar;
      _controllers[index].selection = const TextSelection.collapsed(offset: 1);
    }

    if (value.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _clearCode() {
    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes.first.requestFocus();
  }
}

class InteractiveGoogleAccountPickerScreen extends StatelessWidget {
  const InteractiveGoogleAccountPickerScreen({super.key});

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
                            _InteractiveAccountRow(
                              name: 'Ahmad Abdullah',
                              email: 'ahmad.abd@gmail.com',
                              highlight: true,
                              onTap: () => _authenticate(
                                context,
                                name: 'Ahmad Abdullah',
                                email: 'ahmad.abd@gmail.com',
                              ),
                            ),
                            const Divider(height: 1),
                            _InteractiveAccountRow(
                              name: 'Abdullah Kareem',
                              email: 'abdullah.k@gmail.com',
                              onTap: () => _authenticate(
                                context,
                                name: 'Abdullah Kareem',
                                email: 'abdullah.k@gmail.com',
                              ),
                            ),
                            const Divider(height: 1),
                            _InteractiveAccountRow(
                              name: 'Gunakan akun lain',
                              email: '',
                              isAdd: true,
                              onTap: () => _authenticate(
                                context,
                                name: 'Pengguna Muslimku',
                                email: 'pengguna@muslimku.app',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Google akan membagikan nama, alamat email, dan preferensi dasar akun Anda kepada Muslimku.',
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

  void _authenticate(
    BuildContext context, {
    required String name,
    required String email,
  }) {
    final session = AppSessionScope.of(context);
    session
        .updateProfile(session.profile.copyWith(fullName: name, email: email));
    Navigator.of(context).pop(true);
  }
}

class InteractiveAppleIdConfirmationScreen extends StatelessWidget {
  const InteractiveAppleIdConfirmationScreen({super.key});

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
                          'Gunakan Apple ID Anda untuk masuk ke Muslimku.',
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
                          onPressed: () => _authenticate(context),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
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
                          'Autentikasi aman. Data Anda terenkripsi dan hanya dipakai untuk mempersonalisasi pengalaman Muslimku.',
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

  void _authenticate(BuildContext context) {
    final session = AppSessionScope.of(context);
    session.updateProfile(
      session.profile.copyWith(
        fullName: 'Ahmed Al-Farsi',
        email: 'a.alfarsi@icloud.com',
      ),
    );
    Navigator.of(context).pop(true);
  }
}

class _InteractiveAccountRow extends StatelessWidget {
  const _InteractiveAccountRow({
    required this.name,
    required this.email,
    required this.onTap,
    this.highlight = false,
    this.isAdd = false,
  });

  final String name;
  final String email;
  final VoidCallback onTap;
  final bool highlight;
  final bool isAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
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
