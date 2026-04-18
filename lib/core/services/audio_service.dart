import 'dart:async';
import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;
  bool get hasSource => _player.audioSource != null;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;
  double get speed => _player.speed;
  LoopMode get loopMode => _player.loopMode;
  bool get shuffleModeEnabled => _player.shuffleModeEnabled;

  Future<void> warmup() async {}

  Future<void> playUrl({
    required String url,
    required String title,
    required String artist,
    String? album,
  }) async {
    await _player.setAudioSource(
      AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: url,
          title: title,
          artist: artist,
          album: album,
        ),
      ),
    );
    await _player.play();
  }

  Future<void> playAsset({
    required String assetPath,
    required String title,
    required String artist,
  }) async {
    await _player.setAudioSource(
      AudioSource.asset(
        assetPath,
        tag: MediaItem(
          id: assetPath,
          title: title,
          artist: artist,
        ),
      ),
    );
    await _player.play();
  }

  Future<void> playFile({
    required File file,
    required String title,
    required String artist,
    String? album,
  }) async {
    await _player.setAudioSource(
      AudioSource.file(
        file.path,
        tag: MediaItem(
          id: file.path,
          title: title,
          artist: artist,
          album: album,
        ),
      ),
    );
    await _player.play();
  }

  Future<void> toggle() async {
    if (_player.playing) {
      await _player.pause();
      return;
    }
    await _player.play();
  }

  Future<void> pause() => _player.pause();

  Future<void> stop() => _player.stop();

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> setSpeed(double value) => _player.setSpeed(value);

  Future<void> setLoopMode(LoopMode mode) => _player.setLoopMode(mode);

  Future<void> setShuffleModeEnabled(bool value) =>
      _player.setShuffleModeEnabled(value);

  Future<void> dispose() => _player.dispose();
}
