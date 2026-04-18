import '../../../core/services/auth_service.dart';
import '../../../shared/models/user_model.dart';
import 'auth_api.dart';

class AuthRepository {
  AuthRepository(this._api);

  final AuthApi _api;

  Future<AuthActionResult> restoreSession() => _api.restoreSession();

  Future<AuthActionResult> signIn({
    required String identifier,
    required String password,
  }) {
    return _api.signIn(identifier: identifier, password: password);
  }

  Future<AuthActionResult> signUp({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _api.signUp(
      fullName: fullName,
      email: email,
      password: password,
    );
  }

  Future<AuthActionResult> sendPasswordReset(String email) {
    return _api.sendPasswordReset(email);
  }

  Future<AuthActionResult> resendEmailVerification() {
    return _api.resendEmailVerification();
  }

  Future<AuthActionResult> refreshEmailVerification() {
    return _api.refreshEmailVerification();
  }

  Future<AuthActionResult> recoverUsername(String recovery) {
    return _api.recoverUsername(recovery);
  }

  Future<AuthActionResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _api.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<AuthActionResult> signInWithGoogle() {
    return _api.signInWithGoogle();
  }

  Future<AuthActionResult> deleteAccount({
    String? currentPassword,
  }) {
    return _api.deleteAccount(currentPassword: currentPassword);
  }

  Future<AuthActionResult> updateProfile({
    required UserModel user,
  }) {
    return _api.updateProfile(user: user);
  }

  Future<void> syncProfileAndPreferences({
    required UserModel user,
    required Map<String, dynamic> preferences,
  }) {
    return _api.syncProfileAndPreferences(
      user: user,
      preferences: preferences,
    );
  }

  Future<void> signOut() {
    return _api.signOut();
  }
}
