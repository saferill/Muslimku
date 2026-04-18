<div align="center">
  <img src="assets/readme/muslimku-hero.svg" alt="Muslimku Hero" width="100%" />
</div>

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
  <img src="https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20Analytics-FFCA28?logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-111827" alt="Platform" />
  <img src="https://img.shields.io/badge/Architecture-Feature--based-0D3B24" alt="Architecture" />
</p>

<p align="center">
  <a href="https://github.com/saferill/Muslimku/releases">Download APK</a>
  |
  <a href="docs/firebase_auth_setup.md">Setup Firebase</a>
  |
  <a href="docs/release_checklist.md">Release Checklist</a>
</p>

---

## Visual Showcase

<div align="center">
  <img src="assets/readme/muslimku-showcase.svg" alt="Muslimku Showcase" width="100%" />
</div>

## Overview

Muslimku is designed as a daily spiritual companion that keeps prayer schedules, Qur'an reading,
audio recitation, adzan reminders, bookmarks, and user preferences in one app.

This repository is the main source of truth for the project and is structured so development can
continue cleanly across features, releases, and future platform support.

## Why Muslimku

<table>
  <tr>
    <td width="33%">
      <h3>Prayer First</h3>
      <p>Built around daily prayer flow with adzan reminders, configurable offsets, location-aware schedules, and qibla support.</p>
    </td>
    <td width="33%">
      <h3>Qur'an Focused</h3>
      <p>Surah browsing, tafsir, reader mode, bookmarks, reading progress, and integrated audio are organized for everyday use.</p>
    </td>
    <td width="33%">
      <h3>Release Ready</h3>
      <p>APK variants are published through GitHub Releases so users can choose a build that matches their device and storage capacity.</p>
    </td>
  </tr>
</table>

## Core Experience

| Area | What users can do |
| --- | --- |
| Authentication | Sign In, Sign Up, Google Sign-In, email verification, forgot password, forgot username, guest mode |
| Home Dashboard | See prayer times, next prayer countdown, daily ayah, last read, and quick actions |
| Qur'an | Browse surahs, open detail pages, read ayat, view tafsir, play audio, bookmark passages |
| Adzan | Get local prayer reminders, choose adzan sound, set offsets, enable pre-reminders, use qibla compass |
| Audio | Browse qari options, play recitation, use audio controls, and manage listening flow |
| Search | Search verses, open results in reader, bookmark from results, share verses |
| Sync | Save bookmarks and reading progress locally and sync to cloud for signed-in users |
| Settings | Manage account, audio, notifications, Qur'an settings, app preferences, and security flows |

## Main Features

<table>
  <tr>
    <td width="50%" valign="top">
      <h3>Spiritual Daily Flow</h3>
      <ul>
        <li>Prayer times and next prayer countdown</li>
        <li>Daily ayah and last read continuation</li>
        <li>Adzan reminder scheduling</li>
        <li>Qibla compass and location support</li>
      </ul>
    </td>
    <td width="50%" valign="top">
      <h3>Reading and Audio</h3>
      <ul>
        <li>Surah list, detail, and reader</li>
        <li>Tafsir, bookmark, copy, and share</li>
        <li>Recitation playback and qari selection</li>
        <li>Search and quick access to ayah results</li>
      </ul>
    </td>
  </tr>
</table>

### Authentication

- Sign In with email and password
- Sign Up flow
- email verification
- Forgot Password
- Forgot Username
- Google Sign-In
- guest mode
- logout and session handling

### Home

- greeting and user location
- prayer time card
- next prayer countdown
- last read Qur'an card
- daily ayah
- quick actions to Qur'an, Adzan, Audio, and Search

### Qur'an

- surah list
- surah detail
- ayah reader
- tafsir
- copy and share ayah
- bookmark ayah
- last read tracking
- audio playback

### Adzan

- local adzan notifications
- adzan sound selection
- pre-reminder support
- prayer time offsets
- manual and automatic location flow
- qibla compass
- adzan test sound action

### Audio

- qari list
- recitation playback
- playback progress
- play, pause, next, previous
- speed controls

### Search

- verse search
- open results in reader
- bookmark from search result
- share from search result

### Settings and Security

- account settings
- change password
- notification settings
- Qur'an settings
- audio settings
- about screen
- lock boundary
- biometric and PIN-related flows

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
- Firebase Analytics
- Google Sign-In
- just_audio
- flutter_local_notifications
- geolocator
- flutter_compass
- local_auth
- shared_preferences
- flutter_secure_storage

## Branding

Muslimku branding in this project uses the official asset stored in:

- [`assets/Logo/Logo Muslimku.png`](assets/Logo/Logo%20Muslimku.png)

The same logo is used for:

- README branding
- app icon
- native splash screen
- in-app brand components

## Download Options

Android builds are published through GitHub Releases so users can choose the APK size that best
fits their device.

| Build type | Best for | Notes |
| --- | --- | --- |
| `universal` | users who want maximum compatibility | largest file size |
| `arm64-v8a` | most modern Android phones | recommended for most users |
| `armeabi-v7a` | devices that need a smaller package | usually the smallest Android phone build |
| `x86_64` | Android emulator | not for regular phones |

Latest releases:

- <https://github.com/saferill/Muslimku/releases>

### Quick Download Picks

<p>
  <a href="https://github.com/saferill/Muslimku/releases/latest">
    <img src="https://img.shields.io/badge/Universal%20APK-Max%20Compatibility-111827?style=for-the-badge&logo=android&logoColor=white" alt="Universal APK" />
  </a>
  <a href="https://github.com/saferill/Muslimku/releases/latest">
    <img src="https://img.shields.io/badge/arm64--v8a-Recommended-0D3B24?style=for-the-badge&logo=android&logoColor=white" alt="arm64-v8a" />
  </a>
  <a href="https://github.com/saferill/Muslimku/releases/latest">
    <img src="https://img.shields.io/badge/armeabi--v7a-Smaller%20Size-7A5C1B?style=for-the-badge&logo=android&logoColor=white" alt="armeabi-v7a" />
  </a>
</p>

## Release Strategy

Muslimku uses GitHub Actions to build Android release variants automatically. This makes the
repository suitable both as a source backup and as a simple public delivery channel for testers
or early users.

Release flow:

1. push source updates to `main`
2. create or move a version tag
3. GitHub Actions builds Android variants
4. release assets are uploaded to GitHub Releases

## Run Locally

Make sure Flutter SDK and the Android toolchain are installed.

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

Universal release build:

```bash
flutter build apk --release
```

Split-per-ABI release builds:

```bash
flutter build apk --release --split-per-abi
```

## Firebase Setup

Sensitive Firebase files are not stored in this repository.

After cloning the project, prepare:

1. `android/app/google-services.json`
2. `ios/Runner/GoogleService-Info.plist` for iOS if needed
3. any required Firebase project secrets or configuration

Guides:

- [docs/firebase_auth_setup.md](docs/firebase_auth_setup.md)
- [docs/release_checklist.md](docs/release_checklist.md)

## GitHub Actions Release Flow

Android releases can be built automatically from GitHub Actions.

Workflow:

- [`.github/workflows/android-release.yml`](.github/workflows/android-release.yml)

Required GitHub secret:

- `ANDROID_GOOGLE_SERVICES_JSON`

That secret should contain the full content of `android/app/google-services.json`.

## iPhone Note

This repository also keeps the iOS project structure, but iPhone distribution does not happen
through APK files or standard GitHub Release downloads.

The proper delivery path for iPhone users is:

1. TestFlight
2. App Store

For real iOS distribution you still need:

- an Apple Developer account
- signing certificates
- provisioning profiles
- App Store Connect setup

## Local Backup Notes

Before deleting your local project folder, make sure:

1. your latest commit has been pushed to GitHub
2. Firebase configuration files are stored safely outside the repo
3. important secrets are stored in GitHub or Firebase, not only on the laptop

## Repository

- GitHub: <https://github.com/saferill/Muslimku>
- Releases: <https://github.com/saferill/Muslimku/releases>

## Project Status

<table>
  <tr>
    <td width="33%">
      <h3>Codebase</h3>
      <p>Feature-based Flutter structure with shared core, service, and settings modules.</p>
    </td>
    <td width="33%">
      <h3>Distribution</h3>
      <p>Android APK variants are published through GitHub Releases for easier device coverage.</p>
    </td>
    <td width="33%">
      <h3>Platform Direction</h3>
      <p>Android is the active delivery path, while iOS remains prepared for future TestFlight or App Store release flow.</p>
    </td>
  </tr>
</table>
