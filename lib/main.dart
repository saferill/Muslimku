import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'app.dart';
import 'core/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeCriticalServices();

  runApp(const MuslimkuApp());

  unawaited(_initializeDeferredServices());
}

Future<void> _initializeCriticalServices() async {
  if (!kIsWeb) {
    try {
      await JustAudioBackground.init(
        androidNotificationChannelId: 'muslimku.audio',
        androidNotificationChannelName: 'Muslimku Audio',
        androidNotificationOngoing: true,
      ).timeout(const Duration(seconds: 8));
    } catch (error) {
      debugPrint('JustAudioBackground init skipped: $error');
    }
  }

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    try {
      await Firebase.initializeApp().timeout(const Duration(seconds: 8));
    } catch (error) {
      debugPrint('Firebase initialization skipped: $error');
    }
  }
}

Future<void> _initializeDeferredServices() async {
  try {
    await AuthService.ensureInitialized().timeout(const Duration(seconds: 8));
  } catch (error) {
    debugPrint('Auth service initialization skipped: $error');
  }
}
