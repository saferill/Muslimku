import '../../../core/services/auth_service.dart';
import '../../../shared/models/user_model.dart';

class AuthApi {
  AuthApi(this._service);

  final AuthService _service;

  Future<AuthActionResult> restoreSession() {
    return _service.restoreSession();
  }

  Future<AuthActionResult> signIn({
    required String identifier,
    required String password,
  }) {
    return _service.signIn(identifier: identifier, password: password);
  }

  Future<AuthActionResult> signUp({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _service.signUp(
      fullName: fullName,
      email: email,
      password: password,
    );
  }

  Future<AuthActionResult> sendPasswordReset(String email) {
    return _service.sendPasswordReset(email);
  }

  Future<AuthActionResult> resendEmailVerification() {
    return _service.resendEmailVerification();
  }

  Future<AuthActionResult> refreshEmailVerification() {
    return _service.refreshEmailVerification();
  }

  Future<AuthActionResult> recoverUsername(String recovery) {
    return _service.recoverUsername(recovery);
  }

  Future<AuthActionResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _service.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<AuthActionResult> signInWithGoogle() {
    return _service.signInWithGoogle();
  }

  Future<AuthActionResult> deleteAccount({
    String? currentPassword,
  }) {
    return _service.deleteAccount(currentPassword: currentPassword);
  }

  Future<AuthActionResult> updateProfile({
    required UserModel user,
  }) {
    return _service.updateProfile(user: user);
  }

  Future<void> syncProfileAndPreferences({
    required UserModel user,
    required Map<String, dynamic> preferences,
  }) {
    return _service.syncProfileAndPreferences(
      user: user,
      preferences: preferences,
    );
  }

  Future<void> signOut() {
    return _service.signOut();
  }
}
