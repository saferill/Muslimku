class Validators {
  static String? requiredField(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return '$field wajib diisi.';
    }
    return null;
  }

  static String? email(String? value) {
    final required = requiredField(value, 'Email');
    if (required != null) return required;
    final email = value!.trim();
    if (!email.contains('@') || !email.contains('.')) {
      return 'Format email tidak valid.';
    }
    return null;
  }

  static String? password(String? value) {
    final required = requiredField(value, 'Kata sandi');
    if (required != null) return required;
    if (value!.trim().length < 8) {
      return 'Gunakan minimal 8 karakter.';
    }
    return null;
  }

  static String? emailOrUsername(String? value) {
    final required = requiredField(value, 'Email atau username');
    if (required != null) return required;
    final input = value!.trim();
    if (input.contains('@') && (!input.contains('.') || input.startsWith('@'))) {
      return 'Format email tidak valid.';
    }
    if (input.length < 3) {
      return 'Masukkan email atau username yang valid.';
    }
    return null;
  }

  static String? phoneOrEmail(String? value) {
    final required = requiredField(value, 'Email atau nomor');
    if (required != null) return required;
    final input = value!.trim();
    if (input.contains('@')) {
      return email(input);
    }
    if (input.length < 8) {
      return 'Masukkan email atau nomor yang valid.';
    }
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.trim().length != 6) {
      return 'Masukkan 6 digit kode verifikasi.';
    }
    return null;
  }
}
