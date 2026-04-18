import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthActionResult {
  const AuthActionResult({
    required this.success,
    this.message,
    this.fullName,
    this.email,
  });

  final bool success;
  final String? message;
  final String? fullName;
  final String? email;
}

class AppAuthService {
  static bool get supportsEmailPasswordAuth =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static FirebaseAuth? get _authOrNull {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  static User? get currentUser =>
      supportsEmailPasswordAuth ? _authOrNull?.currentUser : null;

  static Future<AuthActionResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!supportsEmailPasswordAuth) {
      return const AuthActionResult(
        success: false,
        message:
            'Login email/password saat ini diaktifkan untuk Android build publik.',
      );
    }

    final auth = _authOrNull;
    if (auth == null) {
      return const AuthActionResult(
        success: false,
        message: 'Firebase belum siap di perangkat ini.',
      );
    }

    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      return AuthActionResult(
        success: true,
        message: user != null && !(user.emailVerified)
            ? 'Berhasil masuk. Verifikasi email Anda tetap disarankan.'
            : null,
        fullName: user?.displayName,
        email: user?.email ?? email,
      );
    } on FirebaseAuthException catch (error) {
      return AuthActionResult(
        success: false,
        message: _mapSignInError(error),
      );
    } catch (_) {
      return const AuthActionResult(
        success: false,
        message: 'Terjadi kendala saat masuk. Coba lagi beberapa saat.',
      );
    }
  }

  static Future<AuthActionResult> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    if (!supportsEmailPasswordAuth) {
      return const AuthActionResult(
        success: false,
        message:
            'Pendaftaran email/password saat ini diaktifkan untuk Android build publik.',
      );
    }

    final auth = _authOrNull;
    if (auth == null) {
      return const AuthActionResult(
        success: false,
        message: 'Firebase belum siap di perangkat ini.',
      );
    }

    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(fullName);
        await user.sendEmailVerification();
        await user.reload();
      }

      return AuthActionResult(
        success: true,
        message:
            'Akun berhasil dibuat. Email verifikasi sudah dikirim ke inbox Anda.',
        fullName: fullName,
        email: email,
      );
    } on FirebaseAuthException catch (error) {
      return AuthActionResult(
        success: false,
        message: _mapSignUpError(error),
      );
    } catch (_) {
      return const AuthActionResult(
        success: false,
        message: 'Terjadi kendala saat membuat akun. Coba lagi beberapa saat.',
      );
    }
  }

  static Future<AuthActionResult> sendPasswordReset(String email) async {
    if (!supportsEmailPasswordAuth) {
      return const AuthActionResult(
        success: false,
        message:
            'Reset password email saat ini diaktifkan untuk Android build publik.',
      );
    }

    final auth = _authOrNull;
    if (auth == null) {
      return const AuthActionResult(
        success: false,
        message: 'Firebase belum siap di perangkat ini.',
      );
    }

    try {
      await auth.sendPasswordResetEmail(email: email);
      return AuthActionResult(
        success: true,
        message: 'Tautan reset dikirim ke $email.',
        email: email,
      );
    } on FirebaseAuthException catch (error) {
      return AuthActionResult(
        success: false,
        message: _mapResetError(error),
      );
    } catch (_) {
      return const AuthActionResult(
        success: false,
        message: 'Gagal mengirim email reset. Coba lagi beberapa saat.',
      );
    }
  }

  static Future<void> signOut() async {
    if (!supportsEmailPasswordAuth) return;
    final auth = _authOrNull;
    if (auth == null) return;
    await auth.signOut();
  }

  static String _mapSignInError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Email atau kata sandi tidak cocok.';
      case 'user-disabled':
        return 'Akun ini dinonaktifkan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah. Periksa jaringan Anda.';
      default:
        return error.message ?? 'Tidak bisa masuk sekarang. Silakan coba lagi.';
    }
  }

  static String _mapSignUpError(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar. Coba masuk saja.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Kata sandi terlalu lemah. Gunakan minimal 8 karakter.';
      case 'operation-not-allowed':
        return 'Email/password belum diaktifkan di Firebase Authentication.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah. Periksa jaringan Anda.';
      default:
        return error.message ??
            'Tidak bisa membuat akun sekarang. Silakan coba lagi.';
    }
  }

  static String _mapResetError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-not-found':
        return 'Email belum terdaftar di sistem.';
      case 'missing-android-pkg-name':
      case 'missing-continue-uri':
      case 'unauthorized-continue-uri':
        return 'Template reset password di Firebase belum lengkap.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah. Periksa jaringan Anda.';
      default:
        return error.message ?? 'Tidak bisa mengirim tautan reset sekarang.';
    }
  }
}
