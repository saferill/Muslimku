import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../di/injection.dart';

class AppLockBoundary extends StatefulWidget {
  const AppLockBoundary({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<AppLockBoundary> createState() => _AppLockBoundaryState();
}

class _AppLockBoundaryState extends State<AppLockBoundary>
    with WidgetsBindingObserver {
  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pinController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final security = AppDependenciesScope.of(context).securityController;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      security.onBackground();
    }
    if (state == AppLifecycleState.resumed) {
      security.onResume();
    }
  }

  @override
  Widget build(BuildContext context) {
    final security = AppDependenciesScope.of(context).securityController;
    return AnimatedBuilder(
      animation: security,
      builder: (context, _) {
        return Stack(
          children: <Widget>[
            widget.child,
            if (security.pinEnabled && security.locked)
              Positioned.fill(
                child: ColoredBox(
                  color: const Color(0xFFF5F3ED),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: 92,
                            height: 92,
                            decoration: BoxDecoration(
                              gradient: AppColors.heroGradient,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Muslimku Terkunci',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Masukkan PIN untuk melanjutkan.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _pinController,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            maxLength: 6,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              labelText: 'PIN Keamanan',
                              counterText: '',
                            ),
                            onSubmitted: (_) => _unlockWithPin(context),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () => _unlockWithPin(context),
                              child: const Text('Buka Kunci'),
                            ),
                          ),
                          if (security.biometricsEnabled) ...<Widget>[
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () async {
                                final success =
                                    await security.unlockWithBiometrics();
                                if (!context.mounted) return;
                                if (!success) {
                                  context.showAppSnack(
                                    'Buka kunci biometrik belum berhasil.',
                                  );
                                }
                              },
                              icon: const Icon(Icons.fingerprint_rounded),
                              label: const Text('Gunakan Biometrik'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _unlockWithPin(BuildContext context) async {
    final security = AppDependenciesScope.of(context).securityController;
    final success = await security.unlockWithPin(_pinController.text);
    if (!context.mounted) return;
    if (success) {
      _pinController.clear();
      return;
    }
    context.showAppSnack('PIN tidak cocok.');
  }
}
