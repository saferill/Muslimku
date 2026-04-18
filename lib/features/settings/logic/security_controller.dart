import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/storage/local_storage.dart';
import '../../../core/storage/secure_storage.dart';

class SecurityController extends ChangeNotifier {
  SecurityController({
    required LocalStorage storage,
    required SecureStorage secureStorage,
    LocalAuthentication? localAuth,
  })  : _storage = storage,
        _secureStorage = secureStorage,
        _localAuth = localAuth ?? LocalAuthentication() {
    _hydrate();
  }

  static const _pinEnabledKey = 'security.pin_enabled';
  static const _biometricsEnabledKey = 'security.biometrics_enabled';
  static const _autoLockMinutesKey = 'security.auto_lock_minutes';
  static const _pinCodeSecureKey = 'security.pin_code';

  final LocalStorage _storage;
  final SecureStorage _secureStorage;
  final LocalAuthentication _localAuth;

  bool _hydrated = false;
  bool _pinEnabled = false;
  bool _biometricsEnabled = false;
  bool _biometricsAvailable = false;
  bool _locked = false;
  int _autoLockMinutes = 1;
  DateTime? _backgroundedAt;

  bool get hydrated => _hydrated;
  bool get pinEnabled => _pinEnabled;
  bool get biometricsEnabled => _biometricsEnabled && _biometricsAvailable;
  bool get biometricsAvailable => _biometricsAvailable;
  bool get locked => _locked;
  int get autoLockMinutes => _autoLockMinutes;
  bool get hasPinConfigured => _pinEnabled;

  Future<void> _hydrate() async {
    await _storage.init();
    _pinEnabled = _storage.getBool(_pinEnabledKey) ?? false;
    _biometricsEnabled = _storage.getBool(_biometricsEnabledKey) ?? false;
    _autoLockMinutes = _storage.getInt(_autoLockMinutesKey) ?? 1;
    await _refreshBiometricsAvailability();
    final savedPin = await _secureStorage.read(_pinCodeSecureKey);
    if (_pinEnabled && (savedPin ?? '').isEmpty) {
      _pinEnabled = false;
      _biometricsEnabled = false;
    }
    _locked = _pinEnabled;
    _hydrated = true;
    notifyListeners();
  }

  Future<void> reload() => _hydrate();

  Future<void> configurePin(String pin) async {
    final normalized = pin.trim();
    if (normalized.length < 4) return;
    await _secureStorage.write(_pinCodeSecureKey, normalized);
    _pinEnabled = true;
    _locked = false;
    await _persist();
    notifyListeners();
  }

  Future<bool> verifyPin(String pin) async {
    final savedPin = await _secureStorage.read(_pinCodeSecureKey);
    return savedPin != null && savedPin == pin.trim();
  }

  Future<bool> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    final normalizedNewPin = newPin.trim();
    if (normalizedNewPin.length < 4) return false;
    final validCurrent = await verifyPin(currentPin);
    if (!validCurrent) return false;
    await _secureStorage.write(_pinCodeSecureKey, normalizedNewPin);
    _pinEnabled = true;
    _locked = false;
    await _persist();
    notifyListeners();
    return true;
  }

  Future<bool> disablePin({
    required String currentPin,
  }) async {
    final validCurrent = await verifyPin(currentPin);
    if (!validCurrent) return false;
    await _secureStorage.delete(_pinCodeSecureKey);
    _pinEnabled = false;
    _biometricsEnabled = false;
    _locked = false;
    await _persist();
    notifyListeners();
    return true;
  }

  Future<void> setBiometricsEnabled(bool value) async {
    await _refreshBiometricsAvailability();
    _biometricsEnabled = value && _biometricsAvailable && _pinEnabled;
    await _persist();
    notifyListeners();
  }

  Future<void> setAutoLockMinutes(int value) async {
    _autoLockMinutes = value;
    await _persist();
    notifyListeners();
  }

  Future<bool> unlockWithPin(String pin) async {
    final success = await verifyPin(pin);
    if (success) {
      _locked = false;
      notifyListeners();
    }
    return success;
  }

  Future<bool> unlockWithBiometrics() async {
    await _refreshBiometricsAvailability();
    if (!_pinEnabled || !_biometricsEnabled || !_biometricsAvailable) {
      return false;
    }
    final success = await _localAuth.authenticate(
      localizedReason: 'Buka kunci Muslimku',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );
    if (success) {
      _locked = false;
      notifyListeners();
    }
    return success;
  }

  void lockNow() {
    if (!_pinEnabled) return;
    _locked = true;
    notifyListeners();
  }

  void onBackground() {
    _backgroundedAt = DateTime.now();
  }

  void onResume() {
    if (!_pinEnabled) return;
    final pausedAt = _backgroundedAt;
    if (pausedAt == null) {
      return;
    }
    final elapsed = DateTime.now().difference(pausedAt);
    if (elapsed.inMinutes >= _autoLockMinutes) {
      _locked = true;
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    await _storage.setBool(_pinEnabledKey, _pinEnabled);
    await _storage.setBool(_biometricsEnabledKey, _biometricsEnabled);
    await _storage.setInt(_autoLockMinutesKey, _autoLockMinutes);
  }

  Future<void> _refreshBiometricsAvailability() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      _biometricsAvailable = canCheck && isSupported;
    } catch (_) {
      _biometricsAvailable = false;
    }
  }
}
