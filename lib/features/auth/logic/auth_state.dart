import '../../../shared/models/user_model.dart';
import '../../../core/constants/app_constants.dart';

enum AppAccessMode { signedOut, guest, authenticated }

class AuthState {
  const AuthState({
    required this.hydrated,
    required this.submitting,
    required this.accessMode,
    required this.onboardingComplete,
    required this.permissionsPromptSeen,
    required this.locationPermissionEnabled,
    required this.notificationPermissionEnabled,
    required this.user,
    required this.currentLocation,
    required this.adzanAudio,
    required this.quranReciter,
    required this.themeModeName,
    required this.interfaceLanguage,
    required this.translation,
    required this.readerShowTranslation,
    required this.readerShowTafsir,
    required this.readerFontScale,
    required this.adzanAlerts,
    required this.dailyVerses,
    required this.pendingVerificationEmail,
    required this.sessionExpired,
  });

  final bool hydrated;
  final bool submitting;
  final AppAccessMode accessMode;
  final bool onboardingComplete;
  final bool permissionsPromptSeen;
  final bool locationPermissionEnabled;
  final bool notificationPermissionEnabled;
  final UserModel user;
  final String currentLocation;
  final String adzanAudio;
  final String quranReciter;
  final String themeModeName;
  final String interfaceLanguage;
  final String translation;
  final bool readerShowTranslation;
  final bool readerShowTafsir;
  final double readerFontScale;
  final bool adzanAlerts;
  final bool dailyVerses;
  final String? pendingVerificationEmail;
  final bool sessionExpired;

  bool get isSignedOut => accessMode == AppAccessMode.signedOut;
  bool get isGuest => accessMode == AppAccessMode.guest;
  bool get isAuthenticated => accessMode == AppAccessMode.authenticated;
  bool get requiresVerification =>
      (pendingVerificationEmail ?? '').isNotEmpty && !isAuthenticated;

  AuthState copyWith({
    bool? hydrated,
    bool? submitting,
    AppAccessMode? accessMode,
    bool? onboardingComplete,
    bool? permissionsPromptSeen,
    bool? locationPermissionEnabled,
    bool? notificationPermissionEnabled,
    UserModel? user,
    String? currentLocation,
    String? adzanAudio,
    String? quranReciter,
    String? themeModeName,
    String? interfaceLanguage,
    String? translation,
    bool? readerShowTranslation,
    bool? readerShowTafsir,
    double? readerFontScale,
    bool? adzanAlerts,
    bool? dailyVerses,
    String? pendingVerificationEmail,
    bool? sessionExpired,
    bool clearPendingVerificationEmail = false,
    bool clearSessionExpired = false,
  }) {
    return AuthState(
      hydrated: hydrated ?? this.hydrated,
      submitting: submitting ?? this.submitting,
      accessMode: accessMode ?? this.accessMode,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      permissionsPromptSeen:
          permissionsPromptSeen ?? this.permissionsPromptSeen,
      locationPermissionEnabled:
          locationPermissionEnabled ?? this.locationPermissionEnabled,
      notificationPermissionEnabled:
          notificationPermissionEnabled ?? this.notificationPermissionEnabled,
      user: user ?? this.user,
      currentLocation: currentLocation ?? this.currentLocation,
      adzanAudio: adzanAudio ?? this.adzanAudio,
      quranReciter: quranReciter ?? this.quranReciter,
      themeModeName: themeModeName ?? this.themeModeName,
      interfaceLanguage: interfaceLanguage ?? this.interfaceLanguage,
      translation: translation ?? this.translation,
      readerShowTranslation:
          readerShowTranslation ?? this.readerShowTranslation,
      readerShowTafsir: readerShowTafsir ?? this.readerShowTafsir,
      readerFontScale: readerFontScale ?? this.readerFontScale,
      adzanAlerts: adzanAlerts ?? this.adzanAlerts,
      dailyVerses: dailyVerses ?? this.dailyVerses,
      pendingVerificationEmail: clearPendingVerificationEmail
          ? null
          : (pendingVerificationEmail ?? this.pendingVerificationEmail),
      sessionExpired:
          clearSessionExpired ? false : (sessionExpired ?? this.sessionExpired),
    );
  }

  static const initial = AuthState(
    hydrated: false,
    submitting: false,
    accessMode: AppAccessMode.signedOut,
    onboardingComplete: false,
    permissionsPromptSeen: false,
    locationPermissionEnabled: false,
    notificationPermissionEnabled: false,
    user: UserModel.guest,
    currentLocation: 'Jakarta, Indonesia',
    adzanAudio: AppConstants.defaultRegularAdzanSound,
    quranReciter: 'Misyari Rasyid Al-Afasi',
    themeModeName: 'system',
    interfaceLanguage: 'Bahasa Indonesia',
    translation: 'Indonesia (Kemenag RI)',
    readerShowTranslation: true,
    readerShowTafsir: false,
    readerFontScale: 1.0,
    adzanAlerts: true,
    dailyVerses: true,
    pendingVerificationEmail: null,
    sessionExpired: false,
  );
}
