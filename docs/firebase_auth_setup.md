# Firebase Auth Setup

Dokumen ini melengkapi dua bagian yang tidak bisa dibuat otomatis dari kode Flutter:

1. Google Sign-In Android
2. Backend OTP 6 digit + email/SMS delivery

## 1. Google Sign-In Android

Masalah awal project ini:

- file [android/app/google-services.json](</c:/Users/Hype AMD/Downloads/Muslim Ku/android/app/google-services.json:1>) masih punya `oauth_client: []`
- itu berarti Firebase belum membuat client OAuth Android/Web yang dipakai runtime Google login

Langkah yang harus kamu lakukan:

1. Buka Firebase Console untuk project `muslimku-bce48`
2. Masuk ke `Authentication > Sign-in method`
3. Aktifkan provider `Google`
4. Masuk ke `Project settings > Your apps > Android app`
5. Tambahkan SHA-1 dan SHA-256 untuk package `com.muslimku.app`
6. Simpan, lalu download ulang `google-services.json`
7. Ganti file lama di `android/app/google-services.json`

Catatan:

- Setelah benar, file baru tidak lagi punya `oauth_client` kosong
- Kode Flutter sudah siap menampilkan pesan error yang lebih jelas jika config masih salah

## 2. Backend OTP 6 Digit

Scaffold backend sudah ditambahkan:

- [firebase.json](</c:/Users/Hype AMD/Downloads/Muslim Ku/firebase.json:1>)
- [firestore.rules](</c:/Users/Hype AMD/Downloads/Muslim Ku/firestore.rules:1>)
- [.firebaserc](</c:/Users/Hype AMD/Downloads/Muslim Ku/.firebaserc:1>)
- [functions/package.json](</c:/Users/Hype AMD/Downloads/Muslim Ku/functions/package.json:1>)
- [functions/index.js](</c:/Users/Hype AMD/Downloads/Muslim Ku/functions/index.js:1>)
- [functions/.env.example](</c:/Users/Hype AMD/Downloads/Muslim Ku/functions/.env.example:1>)

Function yang tersedia:

- `startAuthOtp`
- `verifyAuthOtp`
- `completePasswordReset`
- `sendUsernameReminder`

Flow yang sudah dicakup:

- Sign Up -> kirim OTP -> verifikasi OTP -> backend create Firebase user -> app auto login
- Login unverified -> kirim OTP -> verifikasi OTP -> email verified
- Forgot Password -> kirim OTP -> verifikasi OTP -> set password baru
- Forgot Username -> kirim username via email/SMS

## 3. Environment Variables

Default yang didukung backend sekarang:

- Email provider: Resend
- atau Amazon SES
- SMS provider: Twilio

Isi environment Firebase Functions dengan nilai real dari provider kamu.

Contoh:

```bash
firebase functions:secrets:set RESEND_API_KEY
firebase functions:secrets:set RESEND_FROM_EMAIL
firebase functions:secrets:set TWILIO_ACCOUNT_SID
firebase functions:secrets:set TWILIO_AUTH_TOKEN
firebase functions:secrets:set TWILIO_FROM_NUMBER
firebase functions:secrets:set AWS_REGION
firebase functions:secrets:set AWS_ACCESS_KEY_ID
firebase functions:secrets:set AWS_SECRET_ACCESS_KEY
firebase functions:secrets:set SES_FROM_EMAIL
```

Untuk domain kamu, nilai yang direkomendasikan adalah:

```bash
RESEND_FROM_EMAIL="Muslimku <noreply@mail.muslimku.app>"
```

Function sekarang sudah memakai deklarasi secret Firebase v2, jadi secret di atas memang akan ikut dimount saat runtime.

Urutan pemakaian provider email di backend sekarang:

1. `Resend` kalau `RESEND_*` terisi
2. `Amazon SES` kalau `AWS_*` dan `SES_FROM_EMAIL` terisi

Kalau kamu lebih suka provider lain, paling aman tinggal ganti helper pengiriman di [functions/index.js](</c:/Users/Hype AMD/Downloads/Muslim Ku/functions/index.js:1>).

## 3A. Kalau Belum Punya Domain

Jalur paling realistis tanpa domain:

1. Buat akun AWS
2. Buka Amazon SES
3. Verifikasi satu alamat email pengirim biasa
   - contoh: `muslimku.app@gmail.com`
4. Ajukan SES keluar dari sandbox supaya bisa kirim ke recipient mana pun
5. Isi secret:
   - `AWS_REGION`
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `SES_FROM_EMAIL`

Sumber resmi:

- SES email identity bisa berupa alamat email, tidak harus domain:
  https://docs.aws.amazon.com/ses/latest/APIReference-V2/API_CreateEmailIdentity.html
- SES production/sandbox:
  https://docs.aws.amazon.com/ses/latest/dg/request-production-access.html

## 4. Install dan Deploy Functions

Di root project:

```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

Region default backend sudah di-set ke `asia-southeast1`.

Flutter app sekarang menembak endpoint:

`https://asia-southeast1-muslimku-bce48.cloudfunctions.net`

Kalau nanti kamu ganti region atau project id, kamu bisa override tanpa edit kode lewat `--dart-define`:

```bash
--dart-define=FIREBASE_PROJECT_ID=muslimku-bce48
--dart-define=FIREBASE_FUNCTIONS_REGION=asia-southeast1
```

Atau langsung isi base URL penuh:

```bash
--dart-define=FIREBASE_FUNCTIONS_BASE_URL=https://asia-southeast1-muslimku-bce48.cloudfunctions.net
```

Kalau mau edit langsung, file yang dipakai adalah:

- [lib/core/network/api_endpoints.dart](</c:/Users/Hype AMD/Downloads/Muslim Ku/lib/core/network/api_endpoints.dart:1>)

## 5. Validasi yang Sudah Selesai di App

Bagian Flutter yang sekarang sudah memakai flow OTP backend:

- [auth_service.dart](</c:/Users/Hype AMD/Downloads/Muslim Ku/lib/core/services/auth_service.dart:1>)
- [auth_controller.dart](</c:/Users/Hype AMD/Downloads/Muslim Ku/lib/features/auth/logic/auth_controller.dart:1>)
- [otp_screen.dart](</c:/Users/Hype AMD/Downloads/Muslim Ku/lib/features/auth/ui/screens/otp_screen.dart:1>)
- [forgot_password_screen.dart](</c:/Users/Hype AMD/Downloads/Muslim Ku/lib/features/auth/ui/screens/forgot_password_screen.dart:1>)
- [reset_password_screen.dart](</c:/Users/Hype AMD/Downloads/Muslim Ku/lib/features/auth/ui/screens/reset_password_screen.dart:1>)
- [forgot_username_screen.dart](</c:/Users/Hype AMD/Downloads/Muslim Ku/lib/features/auth/ui/screens/forgot_username_screen.dart:1>)

## 6. Firestore Security

Rules dasar juga sudah ditambahkan:

- client hanya boleh baca/tulis dokumen user miliknya sendiri
- subcollection `bookmarks` dan `reading` hanya bisa diakses owner
- collection backend sensitif seperti `authOtpChallenges` dan `authRateLimits` tertutup total untuk client

Lihat:

- [firestore.rules](</c:/Users/Hype AMD/Downloads/Muslim Ku/firestore.rules:1>)

## 7. Catatan Penting

- Aku tidak build APK
- `dart analyze lib` sudah bersih setelah perubahan ini
- OTP email/SMS akan benar-benar aktif hanya setelah Firebase Functions dideploy dan secret provider diisi
