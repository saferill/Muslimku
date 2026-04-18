import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/network_exceptions.dart';
import '../../shared/models/user_model.dart';

enum AuthResultCode {
  success,
  needsVerification,
  invalidCredentials,
  wrongPassword,
  userNotFound,
  accountExists,
  passwordResetSent,
  usernameRecovered,
  networkError,
  sessionExpired,
  googleConfigMissing,
  unsupported,
  failure,
}

class AuthActionResult {
  const AuthActionResult({
    required this.code,
    required this.success,
    this.message,
    this.user,
    this.email,
    this.username,
    this.maskedDestination,
    this.preferences,
  });

  final AuthResultCode code;
  final bool success;
  final String? message;
  final UserModel? user;
  final String? email;
  final String? username;
  final String? maskedDestination;
  final Map<String, dynamic>? preferences;
}

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    ApiClient? apiClient,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _apiClient = apiClient ?? ApiClient();

  static bool _googleInitialized = false;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final ApiClient _apiClient;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  User? get currentUser => _auth.currentUser;

  static Future<void> ensureInitialized() async {
    if (_googleInitialized) return;
    try {
      await GoogleSignIn.instance.initialize();
      _googleInitialized = true;
    } catch (_) {
      // Runtime config issues are mapped during sign-in.
    }
  }

  Future<AuthActionResult> restoreSession() async {
    final user = currentUser;
    if (user == null) {
      return const AuthActionResult(
        code: AuthResultCode.sessionExpired,
        success: false,
      );
    }

    try {
      await user.reload();
      final refreshed = _auth.currentUser;
      if (refreshed == null) {
        return const AuthActionResult(
          code: AuthResultCode.sessionExpired,
          success: false,
          message: 'Sesi login berakhir. Silakan masuk lagi.',
        );
      }

      final profileDoc = await _users.doc(refreshed.uid).get();
      final profile = _mergeUserProfile(
        firebaseUser: refreshed,
        data: profileDoc.data(),
      );
      if (!profileDoc.exists) {
        await _users.doc(refreshed.uid).set(
          <String, dynamic>{
            ...profile.toJson(),
            'emailVerified': _isVerifiedUser(refreshed, profileDoc.data()),
            'updatedAtEpochMs': DateTime.now().millisecondsSinceEpoch,
          },
          SetOptions(merge: true),
        );
      }

      if (!_isVerifiedUser(refreshed, profileDoc.data())) {
        return AuthActionResult(
          code: AuthResultCode.needsVerification,
          success: false,
          message: 'Verifikasi email masih diperlukan sebelum lanjut.',
          user: profile,
          email: refreshed.email,
          preferences: profileDoc.data(),
        );
      }

      return AuthActionResult(
        code: AuthResultCode.success,
        success: true,
        user: profile,
        email: refreshed.email,
        username: profile.username,
        preferences: profileDoc.data(),
      );
    } on FirebaseAuthException catch (error) {
      return AuthActionResult(
        code: _mapErrorCode(error),
        success: false,
        message: _mapFirebaseError(error),
      );
    } catch (_) {
      return const AuthActionResult(
        code: AuthResultCode.failure,
        success: false,
        message: 'Gagal memulihkan sesi. Coba login ulang.',
      );
    }
  }

  Future<AuthActionResult> signIn({
    required String identifier,
    required String password,
  }) async {
    try {
      final email = await _resolveEmail(identifier.trim());
      if (email == null) {
        return const AuthActionResult(
          code: AuthResultCode.userNotFound,
          success: false,
          message: 'Akun tidak ditemukan. Coba daftar dulu.',
        );
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return const AuthActionResult(
          code: AuthResultCode.failure,
          success: false,
          message: 'Login gagal. Coba lagi.',
        );
      }

      await user.reload();
      final refreshed = _auth.currentUser;
      if (refreshed == null) {
        return const AuthActionResult(
          code: AuthResultCode.failure,
          success: false,
          message: 'Login gagal. Coba lagi.',
        );
      }

      final profileDoc = await _users.doc(refreshed.uid).get();
      final profile = _mergeUserProfile(
        firebaseUser: refreshed,
        data: profileDoc.data(),
      );
      if (!profileDoc.exists) {
        await _users.doc(refreshed.uid).set(
          <String, dynamic>{
            ...profile.toJson(),
            'emailVerified': _isVerifiedUser(refreshed, profileDoc.data()),
            'updatedAtEpochMs': DateTime.now().millisecondsSinceEpoch,
          },
          SetOptions(merge: true),
        );
      }

      if (!_isVerifiedUser(refreshed, profileDoc.data())) {
        try {
          await refreshed.sendEmailVerification();
        } catch (_) {
          // Surface the verification requirement even if resend fails.
        }
        await _auth.signOut();
        return AuthActionResult(
          code: AuthResultCode.needsVerification,
          success: false,
          message:
              'Email belum terverifikasi. Kami kirim ulang link verifikasi ke email Anda.',
          user: profile,
          email: refreshed.email,
          username: profile.username,
          preferences: profileDoc.data(),
        );
      }

      return AuthActionResult(
        code: AuthResultCode.success,
        success: true,
        message: 'Login berhasil.',
        user: profile,
        email: refreshed.email,
        username: profile.username,
        preferences: profileDoc.data(),
      );
    } on FirebaseAuthException catch (error) {
      return AuthActionResult(
        code: _mapErrorCode(error),
        success: false,
        message: _mapFirebaseError(error),
      );
    } catch (_) {
      return const AuthActionResult(
        code: AuthResultCode.failure,
        success: false,
        message: 'Terjadi kendala saat login. Coba lagi sebentar.',
      );
    }
  }

  Future<AuthActionResult> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final existing = await _lookupUserByEmail(normalizedEmail);
      if (existing != null) {
        return AuthActionResult(
          code: AuthResultCode.accountExists,
          success: false,
          message: 'Email sudah terdaftar. Gunakan halaman login.',
          user: existing,
          email: existing.email,
          username: existing.username,
        );
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return const AuthActionResult(
          code: AuthResultCode.failure,
          success: false,
          message: 'Akun belum berhasil dibuat. Coba lagi.',
        );
      }

      final username = await _generateUniqueUsername(fullName, normalizedEmail);
      await user.updateDisplayName(fullName.trim());
      await user.sendEmailVerification();

      final profile = UserModel(
        uid: user.uid,
        username: username,
        fullName: fullName.trim(),
        email: normalizedEmail,
        phone: '',
        bio: 'Mulai perjalanan ibadah bersama Muslimku.',
        memberSince: _formatMemberSince(user.metadata.creationTime),
        isGuest: false,
      );

      await _users.doc(user.uid).set(
        <String, dynamic>{
          ...profile.toJson(),
          'emailVerified': false,
          'updatedAtEpochMs': DateTime.now().millisecondsSinceEpoch,
        },
        SetOptions(merge: true),
      );
      await _auth.signOut();

      return AuthActionResult(
        code: AuthResultCode.needsVerification,
        success: false,
        message:
            'Akun dibuat. Username kamu $username. Buka email Anda lalu klik link verifikasi sebelum Sign In.',
        user: profile,
        email: profile.email,
        username: profile.username,
      );
    } on FirebaseAuthException catch (error) {
      return AuthActionResult(
        code: _mapErrorCode(error),
        success: false,
        message: _mapFirebaseError(error),
      );
    } catch (_) {
      return const AuthActionResult(
        code: AuthResultCode.failure,
        success: false,
        message: 'Terjadi kendala saat membuat akun. Coba lagi sebentar.',
      );
    }
  }

  Future<AuthActionResult> signInWithGoogle() async {
    try {
      await ensureInitialized();
      final google = GoogleSignIn.instance;
      final account = await google.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        return AuthActionResult(
          code: AuthResultCode.googleConfigMissing,
          success: false,
          message: _googleSetupMessage,
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        return const AuthActionResult(
          code: AuthResultCode.failure,
          success: false,
          message: 'Google Sign-In gagal. Coba lagi.',
        );
      }

      final currentProfileDoc = await _users.doc(user.uid).get();
      final existingData = currentProfileDoc.data();
      final username = (existingData?['username'] as String?) ??
          await _generateUniqueUsername(
            user.displayName ?? user.email ?? 'muslimku',
            user.email ?? 'muslimku',
          );

      final profile = _mergeUserProfile(
        firebaseUser: user,
        data: <String, dynamic>{
          ...?existingData,
          'username': username,
          'emailVerified': true,
        },
      );

      await _users.doc(user.uid).set(
        <String, dynamic>{
          ...profile.toJson(),
          'emailVerified': true,
          'updatedAtEpochMs': DateTime.now().millisecondsSinceEpoch,
        },
        SetOptions(merge: true),
      );

      return AuthActionResult(
        code: AuthResultCode.success,
        success: true,
        message: 'Masuk dengan Google berhasil.',
        user: profile,
        email: profile.email,
        username: profile.username,
        preferences: currentProfileDoc.data(),
      );
    } on GoogleSignInException catch (error) {
      return AuthActionResult(
        code: AuthResultCode.googleConfigMissing,
        success: false,
        message: error.description?.trim().isNotEmpty == true
            ? '${error.description}\n\n$_googleSetupMessage'
            : _googleSetupMessage,
      );
    } on FirebaseAuthException catch (error) {
      return AuthActionResult(
        code: _mapErrorCode(error),
        success: false,
        message: _mapFirebaseError(error),
      );
    } catch (_) {
      return AuthActionResult(
        code: AuthResultCode.googleConfigMissing,
        success: false,
        message: _googleSetupMessage,
      );
    }
  }

  Future<AuthActionResult> resendEmailVerification() async {
    final user = currentUser;
    if (user == null) {
      return const AuthActionResult(
        code: AuthResultCode.sessionExpired,
        success: false,
        message: 'Sesi verifikasi tidak ditemukan. Ulangi login atau daftar.',
      );
    }

    try {
      await user.sendEmailVerification();
      return AuthActionResult(
        code: AuthResultCode.needsVerification,
        success: false,
        message:
            'Link verifikasi dikirim ulang ke ${user.email ?? 'email Anda'}.',
        email: user.email,
      );
    } on FirebaseAuthException catch (error) {
      return AuthActionResult(
        code: _mapErrorCode(error),
        success: false,
        message: _mapFirebaseError(error),
      );
    } catch (_) {
      return const AuthActionResult(
        code: AuthResultCode.failure,
        success: false,
        message: 'Gagal mengirim ulang verifikasi email.',
      );
    }
  }

  Future<AuthActionResult> refreshEmailVerification() async {
    final user = currentUser;
    if (user == null) {
      return const AuthActionResult(
        code: AuthResultCode.sessionExpired,
        success: false,
        message: 'Sesi verifikasi berakhir. Ulangi login atau daftar.',
      );
    }

    try {
      await user.reload();
      final refreshed = _auth.currentUser;
      if (refreshed == null) {
        return const AuthActionResult(
          code: AuthResultCode.sessionExpired,
          success: false,
          message: 'Sesi verifikasi berakhir. Ulangi login atau daftar.',
        );
      }

      if (!_isVerifiedUser(refreshed, null)) {
        return AuthActionResult(
          code: AuthResultCode.needsVerification,
          success: false,
          message: 'Email belum terverifikasi. Periksa inbox atau folder spam.',
          email: refreshed.email,
        );
      }

      await _users.doc(refreshed.uid).set(
        <String, dynamic>{
          'emailVerified': true,
          'updatedAtEpochMs': DateTime.now().millisecondsSinceEpoch,
        },
        SetOptions(merge: true),
      );

      final profileDoc = await _users.doc(refreshed.uid).get();
      final profile = _mergeUserProfile(
        firebaseUser: refreshed,
        data: profileDoc.data(),
      );
      return AuthActionResult(
        code: AuthResultCode.success,
        success: true,
        message: 'Verifikasi berhasil.',
        user: profile,
        email: profile.email,
        username: profile.username,
        preferences: profileDoc.data(),
      );
    } catch (_) {
      return const AuthActionResult(
        code: AuthResultCode.failure,
        success: false,
        message: 'Gagal memeriksa status verifikasi.',
      );
    }
  }

  Future<AuthActionResult> sendPasswordReset(String email) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      await _auth.sendPasswordResetEmail(email: normalizedEmail);
      return AuthActionResult(
        code: AuthResultCode.passwordResetSent,
        success: true,
        message: 'Link reset password dikirim ke $normalizedEmail.',
        email: normalizedEmail,
      );
    } on FirebaseAuthException catch (error) {
      return AuthActionResult(
        code: _mapErrorCode(error),
        success: false,
        message: _mapFirebaseError(error),
      );
    } catch (_) {
      return const AuthActionResult(
        code: AuthResultCode.failure,
        success: false,
        message: 'Tidak bisa mengirim reset password sekarang.',
      );
    }
  }

  Future<AuthActionResult> recoverUsername(String recovery) async {
    final query = recovery.trim();
    if (query.isEmpty) {
      return const AuthActionResult(
        code: AuthResultCode.invalidCredentials,
        success: false,
        message: 'Email atau nomor telepon wajib diisi.',
      );
    }

    try {
      final response = await _apiClient.postJson(
        ApiEndpoints.authFunction('sendUsernameReminder'),
        body: <String, dynamic>{
          'recovery': query,
        },
      );
      final success = response['success'] == true;
      if (success) {
        final maskedDestination = response['maskedDestination'] as String?;
        final username = response['username'] as String?;
        return AuthActionResult(
          code: AuthResultCode.usernameRecovered,
          success: true,
          message: maskedDestination == null || maskedDestination.isEmpty
              ? 'Username berhasil ditemukan.'
              : 'Username berhasil dikirim ke $maskedDestination.',
          username: username,
          maskedDestination: maskedDestination,
        );
      }

      final failureCode = '${response['code'] ?? ''}';
      final message = response['message'] as String?;
      if (failureCode == 'user_not_found') {
        return AuthActionResult(
          code: AuthResultCode.userNotFound,
          success: false,
          message: message ?? 'Akun tidak ditemukan dengan data tersebut.',
        );
      }
      if (failureCode == 'rate_limited') {
        return AuthActionResult(
          code: AuthResultCode.networkError,
          success: false,
          message: message ?? 'Terlalu banyak permintaan. Coba lagi nanti.',
        );
      }
    } on NetworkException {
      // Fallback to local lookup when Functions cannot be reached.
    } catch (_) {
      // Fallback to local lookup when remote delivery is unavailable.
    }

    try {
      UserModel? user;
      if (query.contains('@')) {
        user = await _lookupUserByEmail(query.toLowerCase());
      } else {
        final snapshot =
            await _users.where('phone', isEqualTo: query).limit(1).get();
        if (snapshot.docs.isNotEmpty) {
          user = UserModel.fromJson(snapshot.docs.first.data());
        }
      }

      if (user == null) {
        return const AuthActionResult(
          code: AuthResultCode.userNotFound,
          success: false,
          message: 'Akun tidak ditemukan dengan email atau nomor itu.',
        );
      }

      return AuthActionResult(
        code: AuthResultCode.usernameRecovered,
        success: true,
        message:
            'Username ditemukan di perangkat ini. Sign In dengan username ${user.username}.',
        username: user.username,
        email: user.email,
        user: user,
      );
    } catch (_) {
      return const AuthActionResult(
        code: AuthResultCode.failure,
        success: false,
        message: 'Gagal memulihkan username sekarang.',
      );
    }
  }

  Future<AuthActionResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = currentUser;
    if (user == null || user.email == null) {
      return const AuthActionResult(
        code: AuthResultCode.sessionExpired,
        success: false,
        message: 'Sesi login tidak tersedia. Silakan masuk lagi.',
      );
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return const AuthActionResult(
        code: AuthResultCode.success,
        success: true,
        message: 'Password berhasil diubah.',
      );
    } on FirebaseAuthException catch (error) {
      return AuthActionResult(
        code: _mapErrorCode(error),
        success: false,
        message: _mapFirebaseError(error),
      );
    } catch (_) {
      return const AuthActionResult(
        code: AuthResultCode.failure,
        success: false,
        message: 'Gagal mengubah password sekarang.',
      );
    }
  }

  Future<AuthActionResult> updateProfile({
    required UserModel user,
  }) async {
    final current = currentUser;
    if (current == null) {
      return const AuthActionResult(
        code: AuthResultCode.sessionExpired,
        success: false,
        message: 'Sesi login tidak tersedia. Silakan masuk lagi.',
      );
    }

    try {
      final normalizedName = user.fullName.trim();
      final normalizedEmail = user.email.trim().toLowerCase();
      final normalizedBio = user.bio.trim();
      final normalizedPhone = user.phone.trim();
      final currentEmail = (current.email ?? '').trim().toLowerCase();

      if (normalizedEmail.isNotEmpty &&
          normalizedEmail != currentEmail &&
          !_canChangeEmail(current)) {
        return const AuthActionResult(
          code: AuthResultCode.unsupported,
          success: false,
          message:
              'Email akun Google tidak bisa diubah dari aplikasi. Ubah email dari akun Google Anda.',
        );
      }

      if (normalizedEmail.isNotEmpty && normalizedEmail != currentEmail) {
        final existing = await _lookupUserByEmail(normalizedEmail);
        if (existing != null && existing.uid != current.uid) {
          return const AuthActionResult(
            code: AuthResultCode.accountExists,
            success: false,
            message: 'Email tersebut sudah digunakan oleh akun lain.',
          );
        }
      }

      if (normalizedName.isNotEmpty && normalizedName != current.displayName) {
        await current.updateDisplayName(normalizedName);
      }

      var emailChanged = false;
      if (normalizedEmail.isNotEmpty && normalizedEmail != currentEmail) {
        await current.verifyBeforeUpdateEmail(normalizedEmail);
        emailChanged = true;
      }

      final mergedUser = UserModel(
        uid: current.uid,
        username: user.username.trim(),
        fullName: normalizedName.isEmpty ? user.fullName : normalizedName,
        email: emailChanged
            ? currentEmail
            : (normalizedEmail.isEmpty ? currentEmail : normalizedEmail),
        phone: normalizedPhone,
        bio: normalizedBio.isEmpty
            ? 'Mulai perjalanan ibadah bersama Muslimku.'
            : normalizedBio,
        memberSince: user.memberSince,
        isGuest: false,
      );

      await _users.doc(current.uid).set(
        <String, dynamic>{
          ...mergedUser.toJson(),
          if (emailChanged) 'pendingEmail': normalizedEmail,
          'updatedAtEpochMs': DateTime.now().millisecondsSinceEpoch,
        },
        SetOptions(merge: true),
      );

      return AuthActionResult(
        code: AuthResultCode.success,
        success: true,
        message: emailChanged
            ? 'Profil diperbarui. Link verifikasi email baru sudah dikirim.'
            : 'Profil berhasil diperbarui.',
        user: mergedUser,
        email: mergedUser.email,
        username: mergedUser.username,
      );
    } on FirebaseAuthException catch (error) {
      return AuthActionResult(
        code: _mapErrorCode(error),
        success: false,
        message: _mapFirebaseError(error),
      );
    } catch (_) {
      return const AuthActionResult(
        code: AuthResultCode.failure,
        success: false,
        message: 'Profil belum berhasil diperbarui. Coba lagi.',
      );
    }
  }

  Future<void> syncProfileAndPreferences({
    required UserModel user,
    required Map<String, dynamic> preferences,
  }) async {
    final current = currentUser;
    if (current == null) return;

    await _users.doc(current.uid).set(
      <String, dynamic>{
        ...user.toJson(),
        ...preferences,
        'updatedAtEpochMs': DateTime.now().millisecondsSinceEpoch,
      },
      SetOptions(merge: true),
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Ignore when Google sign-in has not been configured.
    }
  }

  Future<AuthActionResult> deleteAccount({
    String? currentPassword,
  }) async {
    final user = currentUser;
    if (user == null) {
      return const AuthActionResult(
        code: AuthResultCode.sessionExpired,
        success: false,
        message: 'Sesi login tidak tersedia. Silakan masuk lagi.',
      );
    }

    try {
      if (user.providerData.any((entry) => entry.providerId == 'password')) {
        if ((currentPassword ?? '').trim().isEmpty || user.email == null) {
          return const AuthActionResult(
            code: AuthResultCode.invalidCredentials,
            success: false,
            message: 'Masukkan password saat ini untuk menghapus akun.',
          );
        }
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword!.trim(),
        );
        await user.reauthenticateWithCredential(credential);
      } else if (_isGoogleAccount(user)) {
        await ensureInitialized();
        final account = await GoogleSignIn.instance.authenticate();
        final idToken = account.authentication.idToken;
        if (idToken == null || idToken.isEmpty) {
          return AuthActionResult(
            code: AuthResultCode.googleConfigMissing,
            success: false,
            message: _googleSetupMessage,
          );
        }
        final credential = GoogleAuthProvider.credential(idToken: idToken);
        await user.reauthenticateWithCredential(credential);
      }

      await _deleteCollection(_users.doc(user.uid).collection('bookmarks'));
      await _deleteCollection(_users.doc(user.uid).collection('reading'));
      await _users.doc(user.uid).delete();
      await user.delete();

      return const AuthActionResult(
        code: AuthResultCode.success,
        success: true,
        message: 'Akun berhasil dihapus permanen.',
      );
    } on FirebaseAuthException catch (error) {
      return AuthActionResult(
        code: _mapErrorCode(error),
        success: false,
        message: _mapFirebaseError(error),
      );
    } catch (_) {
      return const AuthActionResult(
        code: AuthResultCode.failure,
        success: false,
        message:
            'Gagal menghapus akun sekarang. Coba lagi setelah login ulang.',
      );
    }
  }

  Future<String?> _resolveEmail(String identifier) async {
    if (identifier.contains('@')) {
      return identifier.toLowerCase();
    }

    final username = identifier.toLowerCase();
    final snapshot =
        await _users.where('username', isEqualTo: username).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.data()['email'] as String?;
  }

  Future<UserModel?> _lookupUserByEmail(String email) async {
    final snapshot = await _users
        .where('email', isEqualTo: email.toLowerCase())
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return UserModel.fromJson(snapshot.docs.first.data());
  }

  Future<String> _generateUniqueUsername(String fullName, String email) async {
    final seed =
        _slugify(fullName).isEmpty ? _slugify(email) : _slugify(fullName);
    var username = seed;
    var index = 1;
    while (true) {
      final snapshot =
          await _users.where('username', isEqualTo: username).limit(1).get();
      if (snapshot.docs.isEmpty) {
        return username;
      }
      username = '$seed$index';
      index += 1;
    }
  }

  UserModel _mergeUserProfile({
    required User firebaseUser,
    Map<String, dynamic>? data,
  }) {
    final displayName = firebaseUser.displayName?.trim();
    final email =
        firebaseUser.email?.trim() ?? (data?['email'] ?? '') as String;
    final username = (data?['username'] as String?) ??
        _slugify(
          displayName?.isNotEmpty == true
              ? displayName!
              : email.split('@').first,
        );

    return UserModel(
      uid: firebaseUser.uid,
      username: username,
      fullName: (data?['fullName'] as String?) ??
          (displayName?.isNotEmpty == true
              ? displayName!
              : email.split('@').first),
      email: email,
      phone: (data?['phone'] as String?) ?? '',
      bio: (data?['bio'] as String?) ??
          'Mulai perjalanan ibadah bersama Muslimku.',
      memberSince: (data?['memberSince'] as String?) ??
          _formatMemberSince(firebaseUser.metadata.creationTime),
      isGuest: false,
    );
  }

  bool _isGoogleAccount(User user) {
    return user.providerData.any((entry) => entry.providerId == 'google.com');
  }

  bool _canChangeEmail(User user) {
    return user.providerData.any((entry) => entry.providerId == 'password');
  }

  bool _isVerifiedUser(User user, Map<String, dynamic>? data) {
    return _isGoogleAccount(user) ||
        user.emailVerified ||
        (data?['emailVerified'] == true);
  }

  String _slugify(String value) {
    final lower = value.toLowerCase();
    final sanitized = lower.replaceAll(RegExp(r'[^a-z0-9]+'), '');
    return sanitized.isEmpty ? 'muslimkuuser' : sanitized;
  }

  String _formatMemberSince(DateTime? value) {
    final date = value ?? DateTime.now();
    return 'Sejak ${date.year}';
  }

  Future<void> _deleteCollection(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    final snapshot = await collection.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  AuthResultCode _mapErrorCode(FirebaseAuthException error) {
    switch (error.code) {
      case 'wrong-password':
        return AuthResultCode.wrongPassword;
      case 'user-not-found':
        return AuthResultCode.userNotFound;
      case 'email-already-in-use':
        return AuthResultCode.accountExists;
      case 'network-request-failed':
        return AuthResultCode.networkError;
      case 'invalid-email':
      case 'invalid-credential':
        return AuthResultCode.invalidCredentials;
      default:
        return AuthResultCode.failure;
    }
  }

  String _mapFirebaseError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'invalid-credential':
        return 'Email/username atau password tidak cocok.';
      case 'wrong-password':
        return 'Password yang dimasukkan salah.';
      case 'user-not-found':
        return 'Akun tidak ditemukan.';
      case 'user-disabled':
        return 'Akun ini dinonaktifkan.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Gunakan login.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 8 karakter.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'requires-recent-login':
        return 'Untuk keamanan, login ulang dulu lalu coba lagi.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah. Periksa jaringan Anda.';
      default:
        return error.message ?? 'Terjadi kendala autentikasi.';
    }
  }

  static const String _googleSetupMessage =
      'Google Sign-In belum siap. Pastikan provider Google aktif di Firebase, '
      'SHA-1 dan SHA-256 aplikasi Android sudah ditambahkan, lalu download ulang '
      'android/app/google-services.json.';
}
