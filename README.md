# Muslimku

Muslimku adalah aplikasi Flutter untuk kebutuhan ibadah harian dengan fokus pada:

- jadwal shalat dan pengingat adzan
- baca Al-Qur'an, tafsir, audio, bookmark, dan last read
- autentikasi pengguna dan guest mode
- pengaturan aplikasi, keamanan, dan preferensi ibadah

Repo ini dipakai sebagai source of truth project agar aman dibackup ke GitHub dan bisa dilanjutkan lagi kapan saja.

## Tech Stack

- Flutter
- Riverpod
- Firebase Auth / Firestore / Functions
- Android native scheduling untuk alarm adzan

## Struktur Utama

```text
lib/
|- core/
|- shared/
|- features/
|- routes/
`- di/
```

Feature utama yang ada di repo ini:

- `splash`
- `onboarding`
- `auth`
- `home`
- `quran`
- `adzan`
- `audio`
- `search`
- `notification`
- `settings`

## Menjalankan Project

Pastikan Flutter SDK dan Android toolchain sudah terpasang.

```bash
flutter pub get
flutter run
```

Untuk build Android:

```bash
flutter build apk --debug
flutter build apk --release --split-per-abi
```

## Setup Firebase

File Firebase sensitif tidak ikut dikomit ke repo.

Yang perlu disiapkan lagi setelah clone:

1. download `google-services.json` dari Firebase Console
2. simpan ke `android/app/google-services.json`
3. jika pakai iOS, simpan `GoogleService-Info.plist` ke `ios/Runner/`
4. isi secret Firebase Functions sesuai panduan di `docs/firebase_auth_setup.md`

File terkait:

- [docs/firebase_auth_setup.md](docs/firebase_auth_setup.md)
- [docs/release_checklist.md](docs/release_checklist.md)

## Catatan Repo

- file build, cache lokal, dan konfigurasi mesin tidak disimpan ke GitHub
- audio adzan bawaan tetap disimpan karena dipakai aplikasi
- project ini memakai struktur feature-based di folder `lib/features`

## Catatan APK

APK release universal yang ada di laptop saat ini lebih besar dari batas file GitHub biasa, jadi tidak aman langsung dikomit ke repo utama.

Kalau mau menyimpan APK di GitHub, opsi yang benar:

1. build APK `split-per-abi` yang ukurannya lebih kecil
2. upload APK ke GitHub Releases
3. atau pakai Git LFS

## Backup Lokal

Kalau repo GitHub ini sudah aman dan lengkap, kamu bisa hapus folder lokal project dari laptop.

Sebelum menghapus folder lokal, pastikan:

1. commit terakhir sudah masuk ke GitHub
2. file penting seperti `google-services.json` sudah kamu simpan terpisah
3. secret Firebase Functions tetap kamu simpan di akun Firebase, bukan di repo
