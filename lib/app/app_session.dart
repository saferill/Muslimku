import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/demo_content.dart';
import '../data/location_catalog.dart';

const kPopularLocations = <String>[
  'Jakarta, Indonesia',
  'Bandung, Indonesia',
  'Surabaya, Indonesia',
  'Yogyakarta, Indonesia',
  'Kuala Lumpur, Malaysia',
  'Makkah, Arab Saudi',
];

const kRecentLocations = <String>[
  'Jakarta, Indonesia',
  'Dubai, Uni Emirat Arab',
  'London, Britania Raya',
];

const kAdzanSoundOptions = <String>[
  'Makkah (Masjid al-Haram)',
  'Madinah (Masjid Nabawi)',
  'Al-Aqsa (Yerusalem)',
  'Nada lembut modern',
];

const kQuranReciterOptions = <String>[
  'Mishary Rashid Alafasy',
  'Abdul Basit Abdus Samad',
  'Maher Al-Muaiqly',
  'Saad Al-Ghamdi',
];

const kInterfaceLanguageOptions = <String>[
  'Bahasa Indonesia',
  'English (United States)',
];

const kTranslationOptions = <String>[
  'Indonesia (Kemenag RI)',
  'English (Sahih International)',
];

enum AppAccessMode { signedOut, guest, authenticated }

class AppSessionController extends ChangeNotifier {
  static const _accessModeKey = 'session.access_mode';
  static const _onboardingDoneKey = 'session.onboarding_done';
  static const _permissionsSeenKey = 'session.permissions_seen';
  static const _profileNameKey = 'session.profile.full_name';
  static const _profileEmailKey = 'session.profile.email';
  static const _profilePhoneKey = 'session.profile.phone';
  static const _profileBioKey = 'session.profile.bio';
  static const _profileMemberSinceKey = 'session.profile.member_since';
  static const _locationKey = 'session.current_location';
  static const _adzanAudioKey = 'session.adzan_audio';
  static const _quranReciterKey = 'session.quran_reciter';
  static const _interfaceLanguageKey = 'session.interface_language';
  static const _translationKey = 'session.translation';
  static const _locationPermissionKey = 'session.location_permission';
  static const _notificationPermissionKey = 'session.notification_permission';
  static const _adzanAlertsKey = 'session.adzan_alerts';
  static const _dailyVersesKey = 'session.daily_verses';

  SharedPreferences? _prefs;
  bool _hydrated = false;
  AppAccessMode _accessMode = AppAccessMode.signedOut;
  bool _onboardingComplete = false;
  bool _permissionsPromptSeen = false;
  ProfileData _profile = demoProfile;
  String _currentLocation = kPopularLocations.first;
  String _adzanAudio = kAdzanSoundOptions.first;
  String _quranReciter = kQuranReciterOptions.first;
  String _interfaceLanguage = kInterfaceLanguageOptions.first;
  String _translation = kTranslationOptions.first;
  bool _locationPermissionEnabled = false;
  bool _notificationPermissionEnabled = false;
  bool _adzanAlerts = true;
  bool _dailyVerses = false;

  bool get hydrated => _hydrated;
  AppAccessMode get accessMode => _accessMode;
  bool get isSignedOut => _accessMode == AppAccessMode.signedOut;
  bool get isGuest => _accessMode == AppAccessMode.guest;
  bool get isAuthenticated => _accessMode == AppAccessMode.authenticated;
  bool get onboardingComplete => _onboardingComplete;
  bool get permissionsPromptSeen => _permissionsPromptSeen;
  ProfileData get profile => _profile;
  String get currentLocation => _currentLocation;
  String get adzanAudio => _adzanAudio;
  String get quranReciter => _quranReciter;
  String get interfaceLanguage => _interfaceLanguage;
  String get translation => _translation;
  AppLocationData get selectedLocation => lookupLocation(_currentLocation);
  bool get locationPermissionEnabled => _locationPermissionEnabled;
  bool get notificationPermissionEnabled => _notificationPermissionEnabled;
  bool get adzanAlerts => _adzanAlerts;
  bool get dailyVerses => _dailyVerses;
  bool get permissionsReady =>
      _locationPermissionEnabled && _notificationPermissionEnabled;

  ProfileData get _loggedOutProfile => demoProfile.copyWith(
        fullName: 'Tamu Muslimku',
        email: '',
        phone: '',
        bio: 'Masuk untuk menyimpan preferensi ibadah dan profil Anda.',
      );

  Future<void> hydrate() async {
    _prefs = await SharedPreferences.getInstance();
    final prefs = _prefs!;
    _accessMode = _parseAccessMode(prefs.getString(_accessModeKey));
    _onboardingComplete = prefs.getBool(_onboardingDoneKey) ?? false;
    _permissionsPromptSeen = prefs.getBool(_permissionsSeenKey) ?? false;
    _profile = ProfileData(
      fullName: prefs.getString(_profileNameKey) ?? demoProfile.fullName,
      email: prefs.getString(_profileEmailKey) ?? demoProfile.email,
      phone: prefs.getString(_profilePhoneKey) ?? demoProfile.phone,
      bio: prefs.getString(_profileBioKey) ?? demoProfile.bio,
      memberSince:
          prefs.getString(_profileMemberSinceKey) ?? demoProfile.memberSince,
    );
    _currentLocation = prefs.getString(_locationKey) ?? kPopularLocations.first;
    _adzanAudio = prefs.getString(_adzanAudioKey) ?? kAdzanSoundOptions.first;
    _quranReciter =
        prefs.getString(_quranReciterKey) ?? kQuranReciterOptions.first;
    _interfaceLanguage = prefs.getString(_interfaceLanguageKey) ??
        kInterfaceLanguageOptions.first;
    _translation =
        prefs.getString(_translationKey) ?? kTranslationOptions.first;
    _locationPermissionEnabled = prefs.getBool(_locationPermissionKey) ?? false;
    _notificationPermissionEnabled =
        prefs.getBool(_notificationPermissionKey) ?? false;
    _adzanAlerts = prefs.getBool(_adzanAlertsKey) ?? true;
    _dailyVerses = prefs.getBool(_dailyVersesKey) ?? false;
    _hydrated = true;
    notifyListeners();
  }

  void applyAuthenticatedIdentity({
    String? fullName,
    String? email,
  }) {
    _accessMode = AppAccessMode.authenticated;
    _profile = _profile.copyWith(
      fullName: _sanitizeOrFallback(fullName, _profile.fullName),
      email: _sanitizeOrFallback(email, _profile.email),
    );
    _persist();
    notifyListeners();
  }

  void enterGuestMode() {
    if (_accessMode == AppAccessMode.guest) return;
    _accessMode = AppAccessMode.guest;
    _persist();
    notifyListeners();
  }

  void syncAccessMode(AppAccessMode value) {
    if (_accessMode == value) return;
    _accessMode = value;
    _persist();
    notifyListeners();
  }

  void markOnboardingComplete() {
    if (_onboardingComplete) return;
    _onboardingComplete = true;
    _persist();
    notifyListeners();
  }

  void markPermissionsPromptSeen() {
    if (_permissionsPromptSeen) return;
    _permissionsPromptSeen = true;
    _persist();
    notifyListeners();
  }

  void resetAccess() {
    _accessMode = AppAccessMode.signedOut;
    _profile = _loggedOutProfile;
    _persist();
    notifyListeners();
  }

  void updateProfile(ProfileData value) {
    _profile = value;
    _persist();
    notifyListeners();
  }

  void updateLocation(String value) {
    if (_currentLocation == value) return;
    _currentLocation = value;
    _persist();
    notifyListeners();
  }

  void updateAdzanAudio(String value) {
    if (_adzanAudio == value) return;
    _adzanAudio = value;
    _persist();
    notifyListeners();
  }

  void updateQuranReciter(String value) {
    if (_quranReciter == value) return;
    _quranReciter = value;
    _persist();
    notifyListeners();
  }

  void updateInterfaceLanguage(String value) {
    if (_interfaceLanguage == value) return;
    _interfaceLanguage = value;
    _persist();
    notifyListeners();
  }

  void updateTranslation(String value) {
    if (_translation == value) return;
    _translation = value;
    _persist();
    notifyListeners();
  }

  void setLocationPermissionEnabled(bool value) {
    if (_locationPermissionEnabled == value) return;
    _locationPermissionEnabled = value;
    _persist();
    notifyListeners();
  }

  void setNotificationPermissionEnabled(bool value) {
    if (_notificationPermissionEnabled == value) return;
    _notificationPermissionEnabled = value;
    _persist();
    notifyListeners();
  }

  void setAdzanAlerts(bool value) {
    if (_adzanAlerts == value) return;
    _adzanAlerts = value;
    _persist();
    notifyListeners();
  }

  void setDailyVerses(bool value) {
    if (_dailyVerses == value) return;
    _dailyVerses = value;
    _persist();
    notifyListeners();
  }

  AppAccessMode _parseAccessMode(String? rawValue) {
    switch (rawValue) {
      case 'guest':
        return AppAccessMode.guest;
      case 'authenticated':
        return AppAccessMode.authenticated;
      default:
        return AppAccessMode.signedOut;
    }
  }

  String _sanitizeOrFallback(String? value, String fallback) {
    final sanitized = value?.trim();
    if (sanitized == null || sanitized.isEmpty) return fallback;
    return sanitized;
  }

  void _persist() {
    final prefs = _prefs;
    if (prefs == null) return;

    prefs.setString(_accessModeKey, _accessMode.name);
    prefs.setBool(_onboardingDoneKey, _onboardingComplete);
    prefs.setBool(_permissionsSeenKey, _permissionsPromptSeen);
    prefs.setString(_profileNameKey, _profile.fullName);
    prefs.setString(_profileEmailKey, _profile.email);
    prefs.setString(_profilePhoneKey, _profile.phone);
    prefs.setString(_profileBioKey, _profile.bio);
    prefs.setString(_profileMemberSinceKey, _profile.memberSince);
    prefs.setString(_locationKey, _currentLocation);
    prefs.setString(_adzanAudioKey, _adzanAudio);
    prefs.setString(_quranReciterKey, _quranReciter);
    prefs.setString(_interfaceLanguageKey, _interfaceLanguage);
    prefs.setString(_translationKey, _translation);
    prefs.setBool(_locationPermissionKey, _locationPermissionEnabled);
    prefs.setBool(_notificationPermissionKey, _notificationPermissionEnabled);
    prefs.setBool(_adzanAlertsKey, _adzanAlerts);
    prefs.setBool(_dailyVersesKey, _dailyVerses);
  }
}

class AppSessionScope extends InheritedNotifier<AppSessionController> {
  const AppSessionScope({
    super.key,
    required AppSessionController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppSessionController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppSessionScope>();
    assert(scope != null, 'AppSessionScope not found in widget tree.');
    return scope!.notifier!;
  }
}
