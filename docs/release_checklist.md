# Release Checklist

Checklist ini untuk menutup gap terakhir sebelum app dipakai banyak orang.

## Firebase

- Google provider aktif di Firebase Authentication
- SHA-1 dan SHA-256 Android sudah diisi untuk `com.muslimku.app`
- `android/app/google-services.json` sudah diganti versi terbaru dan `oauth_client` tidak kosong
- Firestore rules sudah dideploy dari [firestore.rules](</c:/Users/Hype AMD/Downloads/Muslim Ku/firestore.rules:1>)
- Firebase Functions sudah dideploy dari [functions/index.js](</c:/Users/Hype AMD/Downloads/Muslim Ku/functions/index.js:1>)

## OTP Delivery

- `RESEND_API_KEY` terisi
- `RESEND_FROM_EMAIL` memakai domain yang sudah valid
  - untuk setup kamu: `Muslimku <noreply@mail.muslimku.app>`
- atau `AWS_REGION` terisi
- `AWS_ACCESS_KEY_ID` terisi
- `AWS_SECRET_ACCESS_KEY` terisi
- `SES_FROM_EMAIL` sudah diverifikasi di Amazon SES
- SES account sudah keluar dari sandbox jika mau kirim ke semua user
- `TWILIO_ACCOUNT_SID` terisi jika SMS dipakai
- `TWILIO_AUTH_TOKEN` terisi jika SMS dipakai
- `TWILIO_FROM_NUMBER` terisi dan nomor sudah aktif

## App Config

- Base URL Functions sesuai environment
  - default saat ini: `asia-southeast1 / muslimku-bce48`
  - override tersedia via `--dart-define`
- Notifikasi Android sudah diizinkan di device
- Exact alarm permission diuji di Android yang relevan

## Auth Flow QA

- Sign up -> OTP -> auto login
- Login email/username -> home
- Login akun unverified -> OTP -> verified
- Forgot password -> OTP -> set password baru -> login
- Forgot username -> email/SMS terkirim
- Google Sign-In -> login sukses
- Logout -> balik ke auth decision
- Session expired -> popup -> login again / guest

## Quran Sync QA

- Bookmark guest tersimpan lokal
- Guest upgrade ke account -> bookmark local tersinkron
- Last read tersimpan dan terbaca kembali
- Cloud bookmark sync antar device berjalan

## Adzan QA

- Scheduler background tetap aktif
- Sound subuh dan reguler masing-masing bisa dipilih
- Test sound berfungsi
- Qibla compass tampil realtime

## Monitoring

- Firebase Auth error logs dipantau
- Cloud Functions logs dipantau
- Abuse/rate-limit OTP dipantau setelah launch
