import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/storage/local_storage.dart';
import '../../quran/data/models/ayah_model.dart';
import '../../quran/data/models/surah_model.dart';
import '../../quran/logic/quran_controller.dart';

class AudioController extends ChangeNotifier {
  AudioController({
    required AudioService service,
    required NotificationService notificationService,
    required QuranController quranController,
    required LocalStorage storage,
  })  : _service = service,
        _notificationService = notificationService,
        _quranController = quranController,
        _storage = storage {
    _bindStreams();
    unawaited(_hydrate());
  }

  static const _downloadsKey = 'audio.downloads.v1';
  static const _playlistKey = 'audio.playlist.v1';
  static const _reciterKey = 'audio.current_reciter';
  static const _speedKey = 'audio.speed';
  static const _shuffleKey = 'audio.shuffle_enabled';
  static const _repeatKey = 'audio.repeat_enabled';

  final AudioService _service;
  final NotificationService _notificationService;
  final QuranController _quranController;
  final LocalStorage _storage;

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  double _progress = 0;
  bool _isPlaying = false;
  bool _loading = false;
  bool _hydrated = false;
  bool _shuffleEnabled = false;
  bool _repeatEnabled = false;
  double _speed = 1.0;
  String _currentReciter = AppConstants.quranReciters[4];
  int _currentSurahNumber = 67;
  String? _error;
  final Map<String, String> _downloadedPaths = <String, String>{};
  final Set<String> _downloadingKeys = <String>{};
  List<int> _playlist = const <int>[];
  Timer? _sleepTimer;
  DateTime? _sleepUntil;

  bool get hydrated => _hydrated;
  bool get isPlaying => _isPlaying;
  bool get loading => _loading;
  bool get shuffleEnabled => _shuffleEnabled;
  bool get repeatEnabled => _repeatEnabled;
  double get progress => _progress;
  double get speed => _speed;
  String get currentReciter => _currentReciter;
  String? get error => _error;
  List<SurahModel> get surahs => _quranController.surahs();
  List<SurahModel> get playlistSurahs => _playlist
      .map((number) =>
          surahs.where((surah) => surah.number == number).firstOrNull)
      .whereType<SurahModel>()
      .toList();
  List<SurahModel> get downloadedSurahs =>
      surahs.where((surah) => isDownloaded(surah.number)).toList();
  int? get sleepTimerRemainingSeconds {
    final until = _sleepUntil;
    if (until == null) return null;
    final remaining = until.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : null;
  }

  SurahModel? get currentSurah {
    for (final surah in surahs) {
      if (surah.number == _currentSurahNumber) return surah;
    }
    return surahs.isEmpty ? null : surahs.first;
  }

  Future<void> _hydrate() async {
    await _storage.init();
    _currentReciter =
        _storage.getString(_reciterKey) ?? AppConstants.quranReciters[4];
    _speed = _storage.getDouble(_speedKey) ?? 1.0;
    _shuffleEnabled = _storage.getBool(_shuffleKey) ?? false;
    _repeatEnabled = _storage.getBool(_repeatKey) ?? false;
    _playlist = _storage
        .getJsonList(_playlistKey)
        .map((entry) => (entry['surahNumber'] ?? 0) as int)
        .where((value) => value > 0)
        .toList();
    _downloadedPaths.clear();
    final rawDownloads = _storage.getString(_downloadsKey);
    if ((rawDownloads ?? '').isNotEmpty) {
      final decoded = jsonDecode(rawDownloads!) as Map<String, dynamic>;
      _downloadedPaths.addAll(
        decoded.map(
          (key, value) => MapEntry(key, value as String),
        ),
      );
    }
    await _service.setSpeed(_speed);
    await _service.setLoopMode(_repeatEnabled ? LoopMode.one : LoopMode.off);
    await _service.setShuffleModeEnabled(_shuffleEnabled);
    await _service.warmup();
    _hydrated = true;
    notifyListeners();
  }

  Future<void> reload() async {
    _hydrated = false;
    notifyListeners();
    await _hydrate();
  }

  Future<void> previewReciter(String reciter) async {
    _currentReciter = reciter;
    await _persist();
    notifyListeners();
    await playSurah(surahNumber: 1);
  }

  Future<void> playSurah({int? surahNumber}) async {
    final targetNumber = surahNumber ?? _currentSurahNumber;
    _currentSurahNumber = targetNumber;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final detail = await _quranController.ensureSurahLoaded(targetNumber);
      final surah = detail?.surah;
      if (surah == null) {
        throw Exception('Detail surah tidak tersedia.');
      }

      final downloadedFile = await _downloadedFileFor(targetNumber);
      if (downloadedFile != null && await downloadedFile.exists()) {
        await _service.playFile(
          file: downloadedFile,
          title: surah.name,
          artist: _currentReciter,
          album: 'Muslimku Quran Offline',
        );
      } else {
        final reciterId = _quranController.reciterIdForName(_currentReciter);
        final audioUrl = surah.audioUrlForReciter(reciterId);
        if (audioUrl == null || audioUrl.isEmpty) {
          throw Exception('Audio untuk qari ini belum tersedia.');
        }
        await _service.playUrl(
          url: audioUrl,
          title: surah.name,
          artist: _currentReciter,
          album: 'Muslimku Quran',
        );
      }
    } catch (error) {
      _error = _friendlyAudioError(error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> playAyah(AyahModel ayah) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final reciterId = _quranController.reciterIdForName(_currentReciter);
      final audioUrl = ayah.audioUrlForReciter(reciterId);
      if (audioUrl == null || audioUrl.isEmpty) {
        throw Exception('Audio ayat tidak tersedia.');
      }
      _currentSurahNumber = ayah.surahNumber;
      await _service.playUrl(
        url: audioUrl,
        title: '${ayah.surahName} ${ayah.number}',
        artist: _currentReciter,
        album: 'Muslimku Quran',
      );
    } catch (error) {
      _error = _friendlyAudioError(error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> playAdhanAsset(String soundName) async {
    final normalized = AppConstants.normalizeAdzanSound(soundName);
    final rawResource = AppConstants.adzanRawResourceNames[normalized];
    final assetPath = AppConstants.adzanAssetPaths[normalized];
    if (rawResource == null) return;
    _error = null;
    _loading = true;
    notifyListeners();
    try {
      final previewed = await _notificationService.previewAdhanSound(
        soundRawResource: rawResource,
        volume: 1.0,
      );
      if (!previewed) {
        if ((assetPath ?? '').isEmpty) {
          throw Exception('Asset adzan belum tersedia.');
        }
        await _service.playAsset(
          assetPath: assetPath!,
          title: normalized,
          artist: 'Adhan',
        );
      }
    } catch (error) {
      _error = _friendlyAudioError(error);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  bool isDownloaded(int surahNumber) =>
      _downloadedPaths.containsKey(_downloadKeyFor(surahNumber));

  bool isDownloading(int surahNumber) =>
      _downloadingKeys.contains(_downloadKeyFor(surahNumber));

  bool isInPlaylist(int surahNumber) => _playlist.contains(surahNumber);

  Future<String?> downloadSurah(int surahNumber) async {
    final key = _downloadKeyFor(surahNumber);
    if (_downloadingKeys.contains(key)) {
      return 'Download sedang berjalan.';
    }

    final detail = await _quranController.ensureSurahLoaded(surahNumber);
    final surah = detail?.surah;
    if (surah == null) return 'Detail surah tidak tersedia.';

    final reciterId = _quranController.reciterIdForName(_currentReciter);
    final audioUrl = surah.audioUrlForReciter(reciterId);
    if (audioUrl == null || audioUrl.isEmpty) {
      return 'Audio untuk qari ini belum tersedia.';
    }

    _downloadingKeys.add(key);
    _error = null;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse(audioUrl));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Download gagal (${response.statusCode}).');
      }

      final directory = await _downloadsDirectory();
      final file = File('${directory.path}/$key.mp3');
      await file.writeAsBytes(response.bodyBytes, flush: true);
      _downloadedPaths[key] = file.path;
      await _persist();
      return '${surah.name} berhasil diunduh.';
    } catch (error) {
      _error = _friendlyAudioError(error);
      return _error;
    } finally {
      _downloadingKeys.remove(key);
      notifyListeners();
    }
  }

  Future<void> removeDownload(int surahNumber) async {
    final key = _downloadKeyFor(surahNumber);
    final path = _downloadedPaths.remove(key);
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await _persist();
    notifyListeners();
  }

  Future<void> clearAllDownloads() async {
    final paths = _downloadedPaths.values.toList();
    _downloadedPaths.clear();
    for (final path in paths) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await _persist();
    notifyListeners();
  }

  Future<void> addToPlaylist(int surahNumber) async {
    if (_playlist.contains(surahNumber)) return;
    _playlist = <int>[..._playlist, surahNumber];
    await _persist();
    notifyListeners();
  }

  Future<void> removeFromPlaylist(int surahNumber) async {
    _playlist = _playlist.where((item) => item != surahNumber).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> clearPlaylist() async {
    _playlist = const <int>[];
    await _persist();
    notifyListeners();
  }

  Future<void> toggle() async {
    if (!_service.hasSource) {
      await playSurah(surahNumber: _currentSurahNumber);
      return;
    }
    await _service.toggle();
  }

  Future<void> stop() async {
    await _service.stop();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> seek(double value) async {
    final duration = _service.duration;
    if (duration == Duration.zero) return;
    final millis = (duration.inMilliseconds * value).round();
    await _service.seek(Duration(milliseconds: millis));
  }

  Future<void> next() async {
    final items = _queueItems();
    if (items.isEmpty) return;
    final currentIndex =
        items.indexWhere((item) => item.number == _currentSurahNumber);
    if (currentIndex == -1) {
      await playSurah(surahNumber: items.first.number);
      return;
    }

    if (_shuffleEnabled) {
      final random = math.Random();
      await playSurah(
        surahNumber: items[random.nextInt(items.length)].number,
      );
      return;
    }

    final nextIndex = currentIndex + 1;
    if (nextIndex >= items.length) {
      await stop();
      return;
    }
    await playSurah(surahNumber: items[nextIndex].number);
  }

  Future<void> previous() async {
    final items = _queueItems();
    if (items.isEmpty) return;
    final currentIndex =
        items.indexWhere((item) => item.number == _currentSurahNumber);
    final previousIndex = currentIndex <= 0 ? 0 : currentIndex - 1;
    await playSurah(surahNumber: items[previousIndex].number);
  }

  Future<void> setSpeed(double value) async {
    _speed = value;
    await _service.setSpeed(value);
    await _persist();
    notifyListeners();
  }

  Future<void> setShuffleEnabled(bool value) async {
    _shuffleEnabled = value;
    await _service.setShuffleModeEnabled(value);
    await _persist();
    notifyListeners();
  }

  Future<void> setRepeatEnabled(bool value) async {
    _repeatEnabled = value;
    await _service.setLoopMode(value ? LoopMode.one : LoopMode.off);
    await _persist();
    notifyListeners();
  }

  void setSleepTimer(Duration? duration) {
    _sleepTimer?.cancel();
    if (duration == null) {
      _sleepUntil = null;
      notifyListeners();
      return;
    }

    _sleepUntil = DateTime.now().add(duration);
    _sleepTimer = Timer(duration, () async {
      await stop();
      _sleepUntil = null;
      notifyListeners();
    });
    notifyListeners();
  }

  void _bindStreams() {
    _positionSubscription = _service.positionStream.listen((position) {
      final total = _service.duration.inMilliseconds;
      _progress =
          total <= 0 ? 0 : position.inMilliseconds.clamp(0, total) / total;
      notifyListeners();
    });
    _durationSubscription = _service.durationStream.listen((_) {
      notifyListeners();
    });
    _playerStateSubscription = _service.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed) {
        if (_repeatEnabled) {
          unawaited(playSurah(surahNumber: _currentSurahNumber));
        } else {
          unawaited(next());
        }
      }
      notifyListeners();
    });
  }

  List<SurahModel> _queueItems() {
    return playlistSurahs.isNotEmpty ? playlistSurahs : surahs;
  }

  String _downloadKeyFor(int surahNumber) {
    final reciterId = _quranController.reciterIdForName(_currentReciter);
    return '${reciterId}_$surahNumber';
  }

  Future<File?> _downloadedFileFor(int surahNumber) async {
    final path = _downloadedPaths[_downloadKeyFor(surahNumber)];
    if ((path ?? '').isEmpty) return null;
    return File(path!);
  }

  Future<Directory> _downloadsDirectory() async {
    final base = await getApplicationDocumentsDirectory();
    final directory = Directory('${base.path}/audio_downloads');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  String _friendlyAudioError(Object error) {
    final message = error.toString();
    if (message.contains('has not been initialized')) {
      return 'Pemutar audio belum siap. Coba buka ulang halaman audio.';
    }
    if (message.contains('Audio untuk qari ini belum tersedia.')) {
      return 'Audio untuk qari ini belum tersedia. Coba pilih qari lain.';
    }
    if (message.contains('Source error')) {
      return 'Sumber audio tidak bisa dimuat sekarang. Coba lagi sebentar.';
    }
    return message;
  }

  Future<void> _persist() async {
    await _storage.setString(_reciterKey, _currentReciter);
    await _storage.setDouble(_speedKey, _speed);
    await _storage.setBool(_shuffleKey, _shuffleEnabled);
    await _storage.setBool(_repeatKey, _repeatEnabled);
    await _storage.setString(_downloadsKey, jsonEncode(_downloadedPaths));
    await _storage.setJsonList(
      _playlistKey,
      _playlist
          .map((surahNumber) => <String, dynamic>{'surahNumber': surahNumber})
          .toList(),
    );
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _service.dispose();
    super.dispose();
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
