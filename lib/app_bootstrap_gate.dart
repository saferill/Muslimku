import 'package:flutter/material.dart';

import 'di/injection.dart';
import 'features/auth/ui/screens/auth_decision_screen.dart';
import 'features/auth/ui/screens/otp_screen.dart';
import 'features/auth/ui/screens/permission_screen.dart';
import 'features/onboarding/ui/onboarding_screen.dart';
import 'features/splash/splash_screen.dart';
import 'shared/components/app_shell/main_shell.dart';

class AppBootstrapGate extends StatelessWidget {
  const AppBootstrapGate({super.key});

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependenciesScope.of(context);

    return AnimatedBuilder(
      animation: dependencies.authController,
      builder: (context, _) {
        final state = dependencies.authController.state;

        if (!state.hydrated) {
          return const SplashScreen();
        }

        if (state.requiresVerification) {
          return const OtpScreen();
        }

        if (state.isSignedOut) {
          return AuthDecisionScreen(showSessionExpired: state.sessionExpired);
        }

        if (!state.onboardingComplete) {
          return const OnboardingScreen();
        }

        if (!state.permissionsPromptSeen) {
          return const RouteAwarePermissionScreen();
        }

        return const MainShell();
      },
    );
  }
}
