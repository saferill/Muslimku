<p align="center">
  <img src="assets/Logo/Logo%20Muslimku.png" alt="Logo Muslimku" width="128" />
</p>

<h1 align="center">Muslimku</h1>

<p align="center">
  Daily spiritual companion for prayer times, Qur'an reading, adzan reminders, audio recitation, bookmarks, and personal worship settings.
</p>

<p align="center">
  <a href="https://github.com/saferill/Muslimku/releases">
    <img src="assets/readme/get-it-on-github.svg" alt="Get it on GitHub" width="320" />
  </a>
</p>

<p align="center">
  <a href="https://github.com/saferill/Muslimku/releases">
    <img src="https://img.shields.io/github/v/release/saferill/Muslimku?display_name=release&label=latest%20release&color=0D3B24" alt="Latest Release" />
  </a>
  <img src="https://img.shields.io/badge/Flutter-3.41.x-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-FFCA28?logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-111827" alt="Platform" />
  <img src="https://img.shields.io/badge/Architecture-Feature--based-0D3B24" alt="Architecture" />
</p>

<p align="center">
  <a href="https://github.com/saferill/Muslimku/releases">Download APK</a>
  |
  <a href="docs/firebase_auth_setup.md">Firebase Setup</a>
  |
  <a href="docs/release_checklist.md">Release Checklist</a>
</p>

---

## Overview

Muslimku is a Flutter-based Muslim companion app designed to keep prayer times, Qur'an reading, audio recitation, qibla direction, bookmarks, and personal settings in one place.

The project is structured so it can continue growing cleanly across authentication, worship flows, notifications, audio, and future distribution for Android and iPhone.

## What Muslimku Does

| Area | Main user experience |
| --- | --- |
| Authentication | Sign In, Sign Up, Google Sign-In, email verification, forgot password, forgot username, guest mode |
| Home | Prayer times, next prayer countdown, daily ayah, last read, and quick access to core features |
| Qur'an | Surah list, reader, tafsir, bookmarks, notes, highlights, and sharing |
| Adzan | Local reminders, sound selection, offsets, pre-reminders, qibla compass, and prayer configuration |
| Audio | Reciter selection, playback controls, downloads, playlist, speed, repeat, and shuffle |
| Search | Search verses, open results in reader, bookmark, and share |
| Settings | Account, notifications, Qur'an preferences, audio preferences, security, local data export/import |

## Main Features

### Prayer and Adzan

- prayer times with next prayer countdown
- local adzan notification scheduling
- configurable adzan sound, offsets, vibration, and pre-reminders
- automatic GPS location and manual location selection
- qibla compass support

### Qur'an Experience

- surah browsing and detail view
- ayah reader with tafsir
- bookmark, note, highlight, copy, and share actions
- last read continuation
- translation preference support

### Audio Experience

- qari selection
- surah and ayah playback
- play, pause, next, previous, seek, repeat, shuffle, speed
- sleep timer
- local audio download and playlist support

### Search and Productivity

- verse search
- recent searches
- open result in reader
- bookmark and share directly from search results

### Account and Sync

- guest mode
- cloud sync for signed-in users
- profile update
- password change
- account deletion flow

### Security and App Access

- PIN lock
- biometric unlock support
- auto lock after background timeout
- lock app instantly from settings

## Download Options

Android release builds are published through GitHub Releases so users can choose the APK that best fits their device and storage capacity.

| Build type | Best for | Notes |
| --- | --- | --- |
| `armeabi-v7a` | smaller APK size | usually the lightest Android phone build |
| `arm64-v8a` | most modern Android phones | recommended for most users |
| `universal` | maximum compatibility | largest APK |
| `x86_64` | emulator testing | not intended for normal phones |

Latest release:

- <https://github.com/saferill/Muslimku/releases/latest>

## Quick Download Picks

<p>
  <a href="https://github.com/saferill/Muslimku/releases/latest">
    <img src="https://img.shields.io/badge/armeabi--v7a-Smaller%20Size-7A5C1B?style=for-the-badge&logo=android&logoColor=white" alt="armeabi-v7a APK" />
  </a>
  <a href="https://github.com/saferill/Muslimku/releases/latest">
    <img src="https://img.shields.io/badge/arm64--v8a-Recommended-0D3B24?style=for-the-badge&logo=android&logoColor=white" alt="arm64-v8a APK" />
  </a>
  <a href="https://github.com/saferill/Muslimku/releases/latest">
    <img src="https://img.shields.io/badge/Universal%20APK-Max%20Compatibility-111827?style=for-the-badge&logo=android&logoColor=white" alt="Universal APK" />
  </a>
</p>

## Project Structure

```text
lib/
|- main.dart
|- app.dart
|- core/
|  |- constants/
|  |- network/
|  |- services/
|  |- storage/
|  |- theme/
|  `- utils/
|- shared/
|  |- components/
|  |- models/
|  `- widgets/
|- features/
|  |- splash/
|  |- onboarding/
|  |- auth/
|  |- home/
|  |- quran/
|  |- adzan/
|  |- audio/
|  |- search/
|  |- notification/
|  `- settings/
|- routes/
`- di/
```

## Tech Stack

- Flutter
- Firebase Auth
- Cloud Firestore
- Google Sign-In
- just_audio
- flutter_local_notifications
- geolocator
- geocoding
- flutter_compass
- local_auth
- shared_preferences
- flutter_secure_storage

## Branding

The official Muslimku logo used by this repository is:

- [`assets/Logo/Logo Muslimku.png`](assets/Logo/Logo%20Muslimku.png)

That logo is used for:

- README branding
- app icon
- splash screen
- in-app brand components

## Run Locally

```bash
flutter pub get
flutter run
```

To run on a specific device:

```bash
flutter devices
flutter run -d <device_id>
```

## Build Android

Debug build:

```bash
flutter build apk --debug
```

Release build:

```bash
flutter build apk --release
```

Split-per-ABI release build:

```bash
flutter build apk --release --split-per-abi
```

## GitHub Actions Release Flow

Android releases are built automatically from GitHub Actions.

Workflow file:

- [`.github/workflows/android-release.yml`](.github/workflows/android-release.yml)

Required GitHub secret:

- `ANDROID_GOOGLE_SERVICES_JSON`

## Firebase Setup

Sensitive Firebase files are not stored in this repository.

Prepare these after cloning:

1. `android/app/google-services.json`
2. `ios/Runner/GoogleService-Info.plist` if you want iOS Firebase support
3. any Firebase or provider secrets required by your project

Guides:

- [docs/firebase_auth_setup.md](docs/firebase_auth_setup.md)
- [docs/release_checklist.md](docs/release_checklist.md)

## iPhone Note

Muslimku keeps iOS project structure in the repository, but iPhone distribution is not done through APK files.

The correct iPhone delivery path is:

1. TestFlight
2. App Store

That still requires:

- Apple Developer account
- certificates and provisioning profiles
- App Store Connect setup

## Local Backup Notes

Before deleting your local project folder, make sure:

1. your latest commit is already pushed to GitHub
2. Firebase files are stored safely outside the repo
3. important secrets are stored in GitHub or Firebase, not only on the laptop

## Repository

- GitHub: <https://github.com/saferill/Muslimku>
- Releases: <https://github.com/saferill/Muslimku/releases>
