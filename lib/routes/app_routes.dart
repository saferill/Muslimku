import 'package:flutter/material.dart';

import '../app_bootstrap_gate.dart';
import '../features/adzan/ui/screens/adzan_alert_screen.dart';
import '../features/audio/ui/screens/audio_screen.dart';
import '../features/auth/ui/screens/change_password_screen.dart';
import '../features/auth/ui/screens/forgot_password_screen.dart';
import '../features/auth/ui/screens/forgot_username_screen.dart';
import '../features/auth/ui/screens/login_screen.dart';
import '../features/auth/ui/screens/otp_screen.dart';
import '../features/auth/ui/screens/reset_password_screen.dart';
import '../features/auth/ui/screens/signup_screen.dart';
import '../features/notification/ui/notification_screen.dart';
import '../features/quran/data/models/surah_model.dart';
import '../features/quran/ui/screens/bookmarks_screen.dart';
import '../features/quran/ui/screens/reader_screen.dart';
import '../features/quran/ui/screens/surah_detail_screen.dart';
import '../features/settings/ui/screens/about_screen.dart';
import '../features/settings/ui/screens/account_screen.dart';
import '../features/settings/ui/screens/audio_settings_screen.dart';
import '../features/settings/ui/screens/delete_account_screen.dart';
import '../features/settings/ui/screens/logout_confirmation_screen.dart';
import '../features/settings/ui/screens/notification_settings_screen.dart';
import '../features/settings/ui/screens/quran_settings_screen.dart';
import '../features/settings/ui/screens/system_states_screen.dart';
import 'route_names.dart';

class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.bootstrap:
        return _page(const AppBootstrapGate(), settings);
      case RouteNames.login:
        return _page(
          LoginScreen(initialMessage: settings.arguments as String?),
          settings,
        );
      case RouteNames.signup:
        return _page(const SignupScreen(), settings);
      case RouteNames.otp:
        return _page(const OtpScreen(), settings);
      case RouteNames.forgotPassword:
        return _page(const ForgotPasswordScreen(), settings);
      case RouteNames.forgotUsername:
        return _page(const ForgotUsernameScreen(), settings);
      case RouteNames.resetPassword:
        return _page(const ResetPasswordScreen(), settings);
      case RouteNames.changePassword:
        return _page(const ChangePasswordScreen(), settings);
      case RouteNames.notifications:
        return _page(const NotificationScreen(), settings);
      case RouteNames.surahDetail:
        final surah = settings.arguments as SurahModel?;
        return _page(SurahDetailScreen(surah: surah), settings);
      case RouteNames.reader:
        final surah = settings.arguments as SurahModel?;
        return _page(ReaderScreen(surah: surah), settings);
      case RouteNames.audio:
        return _page(const AudioScreen(), settings);
      case RouteNames.bookmarks:
        return _page(const BookmarksScreen(), settings);
      case RouteNames.adzanAlert:
        final payload = settings.arguments as String?;
        return _page(AdzanAlertScreen(payload: payload), settings);
      case RouteNames.account:
        return _page(const AccountScreen(), settings);
      case RouteNames.logoutConfirmation:
        return _page(const LogoutConfirmationScreen(), settings);
      case RouteNames.deleteAccount:
        return _page(const DeleteAccountScreen(), settings);
      case RouteNames.systemStates:
        return _page(const SystemStatesScreen(), settings);
      case RouteNames.notificationSettings:
        return _page(const NotificationSettingsScreen(), settings);
      case RouteNames.quranSettings:
        return _page(const QuranSettingsScreen(), settings);
      case RouteNames.audioSettings:
        return _page(const AudioSettingsScreen(), settings);
      case RouteNames.about:
        return _page(const AboutScreen(), settings);
      default:
        return _page(const AppBootstrapGate(), settings);
    }
  }

  static MaterialPageRoute<dynamic> _page(
    Widget child,
    RouteSettings settings,
  ) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => child,
    );
  }
}
