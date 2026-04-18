import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/muslimku_theme.dart';
import 'app_session.dart';
import 'flow_screens.dart';
import 'shell_screens.dart';

class PrototypeApp extends StatelessWidget {
  const PrototypeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muslim Ku',
      debugShowCheckedModeBanner: false,
      theme: buildMuslimKuTheme(),
      home: const PrototypeRoot(),
    );
  }
}

enum AppStage { splash, auth, onboarding, permissions, shell }

class PrototypeRoot extends StatefulWidget {
  const PrototypeRoot({super.key});

  @override
  State<PrototypeRoot> createState() => _PrototypeRootState();
}

class _PrototypeRootState extends State<PrototypeRoot> {
  AppStage _stage = AppStage.splash;
  bool _booting = true;
  late final AppSessionController _session;

  @override
  void initState() {
    super.initState();
    _session = AppSessionController();
    _bootstrap();
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSessionScope(
      controller: _session,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: KeyedSubtree(
          key: ValueKey('${_stage.name}-${_booting ? 'boot' : 'ready'}'),
          child: _buildCurrentStage(),
        ),
      ),
    );
  }

  Widget _buildCurrentStage() {
    if (_booting) {
      return const SplashScreen();
    }

    switch (_stage) {
      case AppStage.splash:
        return const SplashScreen();
      case AppStage.auth:
        return AuthFlowScreen(
          onAuthenticated: _handleAuthenticated,
          onSkip: _handleGuestMode,
        );
      case AppStage.onboarding:
        return OnboardingFlowScreen(
          onDone: _handleOnboardingDone,
        );
      case AppStage.permissions:
        return PermissionScreen(
          onContinue: _handlePermissionsFinished,
          onLater: _handlePermissionsFinished,
        );
      case AppStage.shell:
        return MainShell(
          onRestartFlow: _handleLogout,
        );
    }
  }

  Future<void> _bootstrap() async {
    await _session.hydrate();

    final currentUser = AppAuthService.currentUser;
    if (currentUser != null) {
      _session.applyAuthenticatedIdentity(
        fullName: currentUser.displayName,
        email: currentUser.email,
      );
    } else if (_session.accessMode == AppAccessMode.authenticated) {
      _session.resetAccess();
    }

    if (!mounted) return;
    setState(() {
      _stage = _deriveStage();
      _booting = false;
    });
  }

  AppStage _deriveStage() {
    if (_session.isSignedOut) return AppStage.auth;
    if (!_session.onboardingComplete) return AppStage.onboarding;
    if (!_session.permissionsPromptSeen) return AppStage.permissions;
    return AppStage.shell;
  }

  void _handleAuthenticated() {
    if (!mounted) return;
    setState(() => _stage = _deriveStage());
  }

  void _handleGuestMode() {
    _session.enterGuestMode();
    if (!mounted) return;
    setState(() => _stage = _deriveStage());
  }

  void _handleOnboardingDone() {
    _session.markOnboardingComplete();
    if (!mounted) return;
    setState(() => _stage = _deriveStage());
  }

  void _handlePermissionsFinished() {
    _session.markPermissionsPromptSeen();
    if (!mounted) return;
    setState(() => _stage = _deriveStage());
  }

  Future<void> _handleLogout() async {
    await AppAuthService.signOut();
    _session.resetAccess();
    if (!mounted) return;
    setState(() => _stage = AppStage.auth);
  }
}
