import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/storage/local_storage.dart';
import '../../../shared/models/user_model.dart';
import '../data/auth_repository.dart';
import 'auth_state.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required LocalStorage storage,
    required AuthRepository repository,
    required LocationService locationService,
    required NotificationService notificationService,
  })  : _storage = storage,
        _repository = repository,
        _locationService = locationService,
        _notificationService = notificationService;

  static const _accessModeKey = 'session.access_mode';
  static const _onboardingDoneKey = 'session.onboarding_done';
  static const _permissionsSeenKey = 'session.permissions_seen';
  static const _profileUidKey = 'session.profile.uid';
  static const _profileUsernameKey = 'session.profile.username';
  static const _profileNameKey = 'session.profile.full_name';
  static const _profileEmailKey = 'session.profile.email';
  static const _profilePhoneKey = 'session.profile.phone';
  static const _profileBioKey = 'session.profile.bio';
  static const _profileMemberSinceKey = 'session.profile.member_since';
  static const _pendingVerificationKey = 'session.pending_verification_email';
  static const _locationKey = 'session.current_location';
  static const _adzanAudioKey = 'session.adzan_audio';
  static const _quranReciterKey = 'session.quran_reciter';
  static const _themeModeKey = 'session.theme_mode';
  static const _interfaceLanguageKey = 'session.interface_language';
  static const _translationKey = 'session.translation';
  static const _readerShowTranslationKey = 'session.reader_show_translation';
  static const _readerShowTafsirKey = 'session.reader_show_tafsir';
  static const _readerFontScaleKey = 'session.reader_font_scale';
  static const _locationPermissionKey = 'session.location_permission';
  static const _notificationPermissionKey = 'session.notification_permission';
  static const _adzanAlertsKey = 'session.adzan_alerts';
  static const _dailyVersesKey = 'session.daily_verses';

  final LocalStorage _storage;
  final AuthRepository _repository;
  final LocationService _locationService;
  final NotificationService _notificationService;

  AuthState _state = AuthState.initial;

  AuthState get state => _state;

  Future<void> hydrate() async {
    await _storage.init();

    final storedAccessMode =
        _parseAccessMode(_storage.getString(_accessModeKey));
    final pendingVerificationEmail =
        _storage.getString(_pendingVerificationKey);

    _state = _state.copyWith(
      hydrated: true,
      accessMode: storedAccessMode,
      onboardingComplete: _storage.getBool(_onboardingDoneKey) ?? false,
      permissionsPromptSeen: _storage.getBool(_permissionsSeenKey) ?? false,
      locationPermissionEnabled:
          _storage.getBool(_locationPermissionKey) ?? false,
      notificationPermissionEnabled:
          _storage.getBool(_notificationPermissionKey) ?? false,
      pendingVerificationEmail: pendingVerificationEmail,
      user: UserModel(
        uid: _storage.getString(_profileUidKey) ?? UserModel.demo.uid,
        username:
            _storage.getString(_profileUsernameKey) ?? UserModel.demo.username,
        fullName:
            _storage.getString(_profileNameKey) ?? UserModel.demo.fullName,
        email: _storage.getString(_profileEmailKey) ?? UserModel.demo.email,
        phone: _storage.getString(_profilePhoneKey) ?? UserModel.demo.phone,
        bio: _storage.getString(_profileBioKey) ?? UserModel.demo.bio,
        memberSince: _storage.getString(_profileMemberSinceKey) ??
            UserModel.demo.memberSince,
        isGuest: storedAccessMode == AppAccessMode.guest,
      ),
      currentLocation: _storage.getString(_locationKey) ??
          AppConstants.popularLocations.first,
      adzanAudio: AppConstants.normalizeAdzanSound(
        _storage.getString(_adzanAudioKey),
      ),
      quranReciter: _storage.getString(_quranReciterKey) ??
          AppConstants.quranReciters.first,
      themeModeName: _storage.getString(_themeModeKey) ?? 'system',
      interfaceLanguage: _storage.getString(_interfaceLanguageKey) ??
          AppConstants.interfaceLanguages.first,
      translation: _storage.getString(_translationKey) ??
          AppConstants.translationOptions.first,
      readerShowTranslation:
          _storage.getBool(_readerShowTranslationKey) ?? true,
      readerShowTafsir: _storage.getBool(_readerShowTafsirKey) ?? false,
      readerFontScale: _storage.getDouble(_readerFontScaleKey) ?? 1.0,
      adzanAlerts: _storage.getBool(_adzanAlertsKey) ?? true,
      dailyVerses: _storage.getBool(_dailyVersesKey) ?? true,
    );

    if (_state.isGuest) {
      _state = _state.copyWith(
          user: UserModel.guest, accessMode: AppAccessMode.guest);
    } else if (_state.isSignedOut && !_state.requiresVerification) {
      _state = _state.copyWith(user: UserModel.guest);
    }
    notifyListeners();

    final restored = await _repository.restoreSession();
    _applyAuthResultOnHydrate(restored, storedAccessMode);
  }

  Future<void> reloadLocalPreferences() async {
    await _storage.init();
    final updatedUser = _state.isGuest
        ? UserModel.guest
        : _state.user.copyWith(
            uid: _storage.getString(_profileUidKey) ?? _state.user.uid,
            username:
                _storage.getString(_profileUsernameKey) ?? _state.user.username,
            fullName:
                _storage.getString(_profileNameKey) ?? _state.user.fullName,
            email: _storage.getString(_profileEmailKey) ?? _state.user.email,
            phone: _storage.getString(_profilePhoneKey) ?? _state.user.phone,
            bio: _storage.getString(_profileBioKey) ?? _state.user.bio,
            memberSince: _storage.getString(_profileMemberSinceKey) ??
                _state.user.memberSince,
            isGuest: _state.isGuest,
          );

    _state = _state.copyWith(
      user: updatedUser,
      currentLocation:
          _storage.getString(_locationKey) ?? _state.currentLocation,
      adzanAudio: AppConstants.normalizeAdzanSound(
        _storage.getString(_adzanAudioKey) ?? _state.adzanAudio,
      ),
      quranReciter: _storage.getString(_quranReciterKey) ?? _state.quranReciter,
      themeModeName: _storage.getString(_themeModeKey) ?? _state.themeModeName,
      interfaceLanguage:
          _storage.getString(_interfaceLanguageKey) ?? _state.interfaceLanguage,
      translation: _storage.getString(_translationKey) ?? _state.translation,
      readerShowTranslation: _storage.getBool(_readerShowTranslationKey) ??
          _state.readerShowTranslation,
      readerShowTafsir:
          _storage.getBool(_readerShowTafsirKey) ?? _state.readerShowTafsir,
      readerFontScale:
          _storage.getDouble(_readerFontScaleKey) ?? _state.readerFontScale,
      adzanAlerts: _storage.getBool(_adzanAlertsKey) ?? _state.adzanAlerts,
      dailyVerses: _storage.getBool(_dailyVersesKey) ?? _state.dailyVerses,
      locationPermissionEnabled: _storage.getBool(_locationPermissionKey) ??
          _state.locationPermissionEnabled,
      notificationPermissionEnabled:
          _storage.getBool(_notificationPermissionKey) ??
              _state.notificationPermissionEnabled,
    );
    notifyListeners();
  }

  Future<void> refreshSession() async {
    final restored = await _repository.restoreSession();
    final previousAuthenticated = _state.isAuthenticated;

    if (restored.success) {
      _state = _state.copyWith(
        accessMode: AppAccessMode.authenticated,
        user: restored.user ?? _state.user,
        clearPendingVerificationEmail: true,
        clearSessionExpired: true,
      );
      _applyRemotePreferences(restored.preferences);
      await _persist();
      notifyListeners();
      return;
    }

    if (restored.code == AuthResultCode.needsVerification) {
      _state = _state.copyWith(
        accessMode: AppAccessMode.signedOut,
        user: restored.user ?? _state.user,
        pendingVerificationEmail: restored.email ??
            restored.user?.email ??
            _state.pendingVerificationEmail,
        clearSessionExpired: true,
      );
      await _persist();
      notifyListeners();
      return;
    }

    if (previousAuthenticated &&
        restored.code == AuthResultCode.sessionExpired) {
      _state = _state.copyWith(
        accessMode: AppAccessMode.signedOut,
        user: UserModel.guest,
        sessionExpired: true,
        clearPendingVerificationEmail: true,
      );
      await _persist();
      notifyListeners();
    }
  }

  Future<String?> signIn({
    required String identifier,
    required String password,
  }) async {
    _setSubmitting(true);
    final result = await _repository.signIn(
      identifier: identifier,
      password: password,
    );
    _setSubmitting(false);

    if (result.success) {
      _state = _state.copyWith(
        accessMode: AppAccessMode.authenticated,
        user: result.user ?? _state.user,
        clearPendingVerificationEmail: true,
        clearSessionExpired: true,
      );
      _applyRemotePreferences(result.preferences);
      await _persist();
      notifyListeners();
      return result.message;
    }

    if (result.code == AuthResultCode.needsVerification) {
      _state = _state.copyWith(
        accessMode: AppAccessMode.signedOut,
        user: result.user ?? _state.user,
        pendingVerificationEmail: result.email ?? result.user?.email,
        clearSessionExpired: true,
      );
      await _persist();
      notifyListeners();
    }

    return result.message;
  }

  Future<String?> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _setSubmitting(true);
    final result = await _repository.signUp(
      fullName: fullName,
      email: email,
      password: password,
    );
    _setSubmitting(false);

    if (result.code == AuthResultCode.needsVerification) {
      _state = _state.copyWith(
        accessMode: AppAccessMode.signedOut,
        user: result.user ??
            _state.user.copyWith(
              fullName: fullName,
              email: email,
              isGuest: false,
            ),
        pendingVerificationEmail: result.email ?? email.trim(),
        clearSessionExpired: true,
      );
      await _persist();
      notifyListeners();
    }

    return result.message;
  }

  Future<String?> signInWithGoogle() async {
    _setSubmitting(true);
    final result = await _repository.signInWithGoogle();
    _setSubmitting(false);

    if (result.success) {
      _state = _state.copyWith(
        accessMode: AppAccessMode.authenticated,
        user: result.user ?? _state.user,
        clearPendingVerificationEmail: true,
        clearSessionExpired: true,
      );
      _applyRemotePreferences(result.preferences);
      await _persist();
      notifyListeners();
    }

    return result.message;
  }

  Future<String?> resendVerificationEmail() async {
    _setSubmitting(true);
    final result = await _repository.resendEmailVerification();
    _setSubmitting(false);

    if (result.code == AuthResultCode.needsVerification) {
      _state = _state.copyWith(
        pendingVerificationEmail: result.email ??
            _state.pendingVerificationEmail ??
            _state.user.email,
      );
      await _persist();
      notifyListeners();
    }

    return result.message;
  }

  Future<String?> verifyPendingEmail() async {
    _setSubmitting(true);
    final result = await _repository.refreshEmailVerification();
    _setSubmitting(false);

    if (result.success) {
      _state = _state.copyWith(
        accessMode: AppAccessMode.authenticated,
        user: result.user ?? _state.user,
        clearPendingVerificationEmail: true,
        clearSessionExpired: true,
      );
      _applyRemotePreferences(result.preferences);
      await _persist();
      notifyListeners();
      return result.message;
    }

    if (result.code == AuthResultCode.needsVerification) {
      _state = _state.copyWith(
        pendingVerificationEmail: result.email ??
            _state.pendingVerificationEmail ??
            _state.user.email,
      );
      await _persist();
      notifyListeners();
    }

    return result.message;
  }

  Future<AuthActionResult> sendPasswordReset(String email) async {
    _setSubmitting(true);
    final result = await _repository.sendPasswordReset(email);
    _setSubmitting(false);
    return result;
  }

  Future<AuthActionResult> recoverUsernameDetails(String recovery) async {
    _setSubmitting(true);
    final result = await _repository.recoverUsername(recovery);
    _setSubmitting(false);
    return result;
  }

  Future<String?> recoverUsername(String recovery) async {
    final result = await recoverUsernameDetails(recovery);
    return result.message;
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setSubmitting(true);
    final result = await _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
    _setSubmitting(false);
    return result.message;
  }

  Future<String?> deleteAccount({
    String? currentPassword,
  }) async {
    _setSubmitting(true);
    final result = await _repository.deleteAccount(
      currentPassword: currentPassword,
    );
    _setSubmitting(false);

    if (result.success) {
      _state = AuthState.initial.copyWith(
        hydrated: true,
        user: UserModel.guest,
        onboardingComplete: _state.onboardingComplete,
        permissionsPromptSeen: _state.permissionsPromptSeen,
        currentLocation: _state.currentLocation,
        adzanAudio: _state.adzanAudio,
        quranReciter: _state.quranReciter,
        interfaceLanguage: _state.interfaceLanguage,
        translation: _state.translation,
        locationPermissionEnabled: _state.locationPermissionEnabled,
        notificationPermissionEnabled: _state.notificationPermissionEnabled,
        adzanAlerts: _state.adzanAlerts,
        dailyVerses: _state.dailyVerses,
        clearPendingVerificationEmail: true,
      );
      await _persist();
      notifyListeners();
    }

    return result.message;
  }

  void continueAsGuest() {
    _state = _state.copyWith(
      accessMode: AppAccessMode.guest,
      user: UserModel.guest,
      clearPendingVerificationEmail: true,
      clearSessionExpired: true,
    );
    unawaited(_persist());
    notifyListeners();
  }

  void clearSessionExpired() {
    _state = _state.copyWith(clearSessionExpired: true);
    unawaited(_persist());
    notifyListeners();
  }

  void completeOnboarding() {
    _state = _state.copyWith(onboardingComplete: true);
    unawaited(_persist());
    notifyListeners();
  }

  Future<String?> enableLocation() async {
    final permission = await _locationService.requestPermission();
    if (!permission.success) return permission.message;

    final lookup = await _locationService.detectNearestLocation();
    _state = _state.copyWith(
      locationPermissionEnabled: lookup.success,
      currentLocation: lookup.nearestLocation?.label ??
          lookup.location?.label ??
          _state.currentLocation,
    );
    await _persist();
    notifyListeners();
    await _syncRemoteProfileIfNeeded();
    return lookup.message ?? 'Izin lokasi aktif.';
  }

  Future<String?> enableNotifications() async {
    final granted = await _notificationService.requestPermission();
    _state = _state.copyWith(notificationPermissionEnabled: granted);
    await _persist();
    notifyListeners();
    await _syncRemoteProfileIfNeeded();
    return granted
        ? 'Notifikasi berhasil diaktifkan.'
        : 'Izin notifikasi belum diberikan.';
  }

  void markPermissionsSeen() {
    _state = _state.copyWith(permissionsPromptSeen: true);
    unawaited(_persist());
    notifyListeners();
  }

  void updateLocation(String value) {
    _state = _state.copyWith(currentLocation: value);
    unawaited(_persist());
    unawaited(_syncRemoteProfileIfNeeded());
    notifyListeners();
  }

  Future<String?> updateProfile(UserModel value) async {
    if (_state.isGuest) {
      return 'Masuk dulu untuk memperbarui profil.';
    }

    _setSubmitting(true);
    final result = await _repository.updateProfile(
      user: value.copyWith(isGuest: false),
    );
    _setSubmitting(false);

    if (!result.success) {
      return result.message;
    }

    _state = _state.copyWith(
      user: result.user ?? value.copyWith(isGuest: false),
    );
    await _persist();
    notifyListeners();
    return result.message;
  }

  void updateAdzanAudio(String value) {
    _state = _state.copyWith(
      adzanAudio: AppConstants.normalizeAdzanSound(value),
    );
    unawaited(_persist());
    unawaited(_syncRemoteProfileIfNeeded());
    notifyListeners();
  }

  void updateQuranReciter(String value) {
    _state = _state.copyWith(quranReciter: value);
    unawaited(_persist());
    unawaited(_syncRemoteProfileIfNeeded());
    notifyListeners();
  }

  void updateThemeMode(String value) {
    _state = _state.copyWith(themeModeName: value);
    unawaited(_persist());
    unawaited(_syncRemoteProfileIfNeeded());
    notifyListeners();
  }

  void updateInterfaceLanguage(String value) {
    _state = _state.copyWith(interfaceLanguage: value);
    unawaited(_persist());
    unawaited(_syncRemoteProfileIfNeeded());
    notifyListeners();
  }

  void updateTranslation(String value) {
    _state = _state.copyWith(translation: value);
    unawaited(_persist());
    unawaited(_syncRemoteProfileIfNeeded());
    notifyListeners();
  }

  void updateReaderShowTranslation(bool value) {
    _state = _state.copyWith(readerShowTranslation: value);
    unawaited(_persist());
    unawaited(_syncRemoteProfileIfNeeded());
    notifyListeners();
  }

  void updateReaderShowTafsir(bool value) {
    _state = _state.copyWith(readerShowTafsir: value);
    unawaited(_persist());
    unawaited(_syncRemoteProfileIfNeeded());
    notifyListeners();
  }

  void updateReaderFontScale(double value) {
    _state = _state.copyWith(readerFontScale: value);
    unawaited(_persist());
    unawaited(_syncRemoteProfileIfNeeded());
    notifyListeners();
  }

  void setAdzanAlerts(bool value) {
    _state = _state.copyWith(adzanAlerts: value);
    unawaited(_persist());
    unawaited(_syncRemoteProfileIfNeeded());
    notifyListeners();
  }

  void setDailyVerses(bool value) {
    _state = _state.copyWith(dailyVerses: value);
    unawaited(_persist());
    unawaited(_syncRemoteProfileIfNeeded());
    notifyListeners();
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _state = AuthState.initial.copyWith(
      hydrated: true,
      user: UserModel.guest,
      onboardingComplete: _state.onboardingComplete,
      permissionsPromptSeen: _state.permissionsPromptSeen,
      currentLocation: _state.currentLocation,
      adzanAudio: _state.adzanAudio,
      quranReciter: _state.quranReciter,
      themeModeName: _state.themeModeName,
      interfaceLanguage: _state.interfaceLanguage,
      translation: _state.translation,
      locationPermissionEnabled: _state.locationPermissionEnabled,
      notificationPermissionEnabled: _state.notificationPermissionEnabled,
      adzanAlerts: _state.adzanAlerts,
      dailyVerses: _state.dailyVerses,
      clearPendingVerificationEmail: true,
    );
    await _persist();
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

  void _setSubmitting(bool value) {
    _state = _state.copyWith(submitting: value);
    notifyListeners();
  }

  void _applyAuthResultOnHydrate(
    AuthActionResult result,
    AppAccessMode storedAccessMode,
  ) {
    if (result.success) {
      _state = _state.copyWith(
        accessMode: AppAccessMode.authenticated,
        user: result.user ?? _state.user,
        clearPendingVerificationEmail: true,
        clearSessionExpired: true,
      );
      _applyRemotePreferences(result.preferences);
      unawaited(_persist());
      notifyListeners();
      return;
    }

    if (result.code == AuthResultCode.needsVerification) {
      _state = _state.copyWith(
        accessMode: AppAccessMode.signedOut,
        user: result.user ?? _state.user,
        pendingVerificationEmail: result.email ??
            result.user?.email ??
            _state.pendingVerificationEmail,
        clearSessionExpired: true,
      );
      unawaited(_persist());
      notifyListeners();
      return;
    }

    if (storedAccessMode == AppAccessMode.guest) {
      _state = _state.copyWith(
        accessMode: AppAccessMode.guest,
        user: UserModel.guest,
        clearPendingVerificationEmail: true,
        clearSessionExpired: true,
      );
      unawaited(_persist());
      notifyListeners();
      return;
    }

    if (storedAccessMode == AppAccessMode.authenticated) {
      _state = _state.copyWith(
        accessMode: AppAccessMode.signedOut,
        user: UserModel.guest,
        sessionExpired: true,
        clearPendingVerificationEmail: true,
      );
      unawaited(_persist());
      notifyListeners();
      return;
    }

    if (!_state.requiresVerification) {
      _state = _state.copyWith(user: UserModel.guest);
      unawaited(_persist());
      notifyListeners();
    }
  }

  void _applyRemotePreferences(Map<String, dynamic>? data) {
    if (data == null) return;
    _state = _state.copyWith(
      currentLocation:
          (data['currentLocation'] as String?) ?? _state.currentLocation,
      adzanAudio: AppConstants.normalizeAdzanSound(
        (data['adzanAudio'] as String?) ?? _state.adzanAudio,
      ),
      quranReciter: (data['quranReciter'] as String?) ?? _state.quranReciter,
      themeModeName: (data['themeModeName'] as String?) ?? _state.themeModeName,
      interfaceLanguage:
          (data['interfaceLanguage'] as String?) ?? _state.interfaceLanguage,
      translation: (data['translation'] as String?) ?? _state.translation,
      readerShowTranslation: (data['readerShowTranslation'] as bool?) ??
          _state.readerShowTranslation,
      readerShowTafsir:
          (data['readerShowTafsir'] as bool?) ?? _state.readerShowTafsir,
      readerFontScale: (data['readerFontScale'] as num?)?.toDouble() ??
          _state.readerFontScale,
      adzanAlerts: (data['adzanAlerts'] as bool?) ?? _state.adzanAlerts,
      dailyVerses: (data['dailyVerses'] as bool?) ?? _state.dailyVerses,
      locationPermissionEnabled: (data['locationPermissionEnabled'] as bool?) ??
          _state.locationPermissionEnabled,
      notificationPermissionEnabled:
          (data['notificationPermissionEnabled'] as bool?) ??
              _state.notificationPermissionEnabled,
    );
  }

  Future<void> _syncRemoteProfileIfNeeded() async {
    if (!_state.isAuthenticated) return;
    await _repository.syncProfileAndPreferences(
      user: _state.user,
      preferences: _preferencesMap(),
    );
  }

  Map<String, dynamic> _preferencesMap() {
    return <String, dynamic>{
      'currentLocation': _state.currentLocation,
      'adzanAudio': _state.adzanAudio,
      'quranReciter': _state.quranReciter,
      'themeModeName': _state.themeModeName,
      'interfaceLanguage': _state.interfaceLanguage,
      'translation': _state.translation,
      'readerShowTranslation': _state.readerShowTranslation,
      'readerShowTafsir': _state.readerShowTafsir,
      'readerFontScale': _state.readerFontScale,
      'adzanAlerts': _state.adzanAlerts,
      'dailyVerses': _state.dailyVerses,
      'locationPermissionEnabled': _state.locationPermissionEnabled,
      'notificationPermissionEnabled': _state.notificationPermissionEnabled,
    };
  }

  Future<void> _persist() async {
    await _storage.setString(_accessModeKey, _state.accessMode.name);
    await _storage.setBool(_onboardingDoneKey, _state.onboardingComplete);
    await _storage.setBool(_permissionsSeenKey, _state.permissionsPromptSeen);
    await _storage.setString(_profileUidKey, _state.user.uid);
    await _storage.setString(_profileUsernameKey, _state.user.username);
    await _storage.setString(_profileNameKey, _state.user.fullName);
    await _storage.setString(_profileEmailKey, _state.user.email);
    await _storage.setString(_profilePhoneKey, _state.user.phone);
    await _storage.setString(_profileBioKey, _state.user.bio);
    await _storage.setString(_profileMemberSinceKey, _state.user.memberSince);
    if ((_state.pendingVerificationEmail ?? '').isEmpty) {
      await _storage.remove(_pendingVerificationKey);
    } else {
      await _storage.setString(
        _pendingVerificationKey,
        _state.pendingVerificationEmail!,
      );
    }
    await _storage.setString(_locationKey, _state.currentLocation);
    await _storage.setString(_adzanAudioKey, _state.adzanAudio);
    await _storage.setString(_quranReciterKey, _state.quranReciter);
    await _storage.setString(_themeModeKey, _state.themeModeName);
    await _storage.setString(_interfaceLanguageKey, _state.interfaceLanguage);
    await _storage.setString(_translationKey, _state.translation);
    await _storage.setBool(
      _readerShowTranslationKey,
      _state.readerShowTranslation,
    );
    await _storage.setBool(
      _readerShowTafsirKey,
      _state.readerShowTafsir,
    );
    await _storage.setDouble(_readerFontScaleKey, _state.readerFontScale);
    await _storage.setBool(
      _locationPermissionKey,
      _state.locationPermissionEnabled,
    );
    await _storage.setBool(
      _notificationPermissionKey,
      _state.notificationPermissionEnabled,
    );
    await _storage.setBool(_adzanAlertsKey, _state.adzanAlerts);
    await _storage.setBool(_dailyVersesKey, _state.dailyVerses);
  }
}
