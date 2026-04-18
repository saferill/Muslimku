import 'dart:convert';

import '../../../core/storage/local_storage.dart';
import '../../../shared/models/user_model.dart';
import '../../adzan/logic/adzan_controller.dart';
import '../../audio/logic/audio_controller.dart';
import '../../auth/logic/auth_controller.dart';
import '../../auth/logic/auth_state.dart';
import '../../notification/logic/notification_controller.dart';
import '../../quran/logic/quran_controller.dart';
import '../../search/logic/search_controller.dart';

class SettingsController {
  SettingsController({
    required AuthController authController,
    required LocalStorage storage,
    required QuranController quranController,
    required AudioController audioController,
    required SearchController searchController,
    required NotificationController notificationController,
    required AdzanController adzanController,
  })  : _authController = authController,
        _storage = storage,
        _quranController = quranController,
        _audioController = audioController,
        _searchController = searchController,
        _notificationController = notificationController,
        _adzanController = adzanController;

  final AuthController _authController;
  final LocalStorage _storage;
  final QuranController _quranController;
  final AudioController _audioController;
  final SearchController _searchController;
  final NotificationController _notificationController;
  final AdzanController _adzanController;

  AuthState get state => _authController.state;

  int get bookmarkCount => _quranController.bookmarks.length;
  int get noteCount => _quranController.notes.length;
  int get highlightCount => _quranController.highlights.length;
  int get downloadedAudioCount => _audioController.downloadedSurahs.length;
  int get playlistCount => _audioController.playlistSurahs.length;
  int get notificationCount => _notificationController.items.length;

  Future<String?> updateProfile(UserModel user) =>
      _authController.updateProfile(user);
  void setAdzanAlerts(bool value) => _authController.setAdzanAlerts(value);
  void setDailyVerses(bool value) => _authController.setDailyVerses(value);
  void updateTranslation(String value) =>
      _authController.updateTranslation(value);
  void updateReaderShowTranslation(bool value) =>
      _authController.updateReaderShowTranslation(value);
  void updateReaderShowTafsir(bool value) =>
      _authController.updateReaderShowTafsir(value);
  void updateReaderFontScale(double value) =>
      _authController.updateReaderFontScale(value);
  void updateReciter(String value) => _authController.updateQuranReciter(value);
  void updateAdzanAudio(String value) =>
      _authController.updateAdzanAudio(value);
  void updateThemeMode(String value) => _authController.updateThemeMode(value);
  void updateLanguage(String value) =>
      _authController.updateInterfaceLanguage(value);
  Future<void> signOut() => _authController.signOut();
  Future<String?> deleteAccount({String? currentPassword}) =>
      _authController.deleteAccount(currentPassword: currentPassword);

  Future<String> exportDataJson() async {
    await _storage.init();
    final payload = <String, dynamic>{
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'localStorage': _storage.dumpAll(),
      'summary': <String, dynamic>{
        'bookmarks': bookmarkCount,
        'notes': noteCount,
        'highlights': highlightCount,
        'downloads': downloadedAudioCount,
        'playlist': playlistCount,
        'notifications': notificationCount,
      },
    };
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<String?> importDataJson(String raw) async {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return 'Format JSON tidak valid.';
      }
      final localStorageData = decoded['localStorage'];
      if (localStorageData is! Map) {
        return 'Data ekspor tidak berisi localStorage.';
      }

      await _storage.importDump(
        Map<String, dynamic>.from(localStorageData),
        clearExisting: false,
      );
      await _authController.reloadLocalPreferences();
      await _adzanController.reload();
      await _audioController.reload();
      await _searchController.reload();
      await _notificationController.reload();
      await _quranController.reloadLocalData();
      return 'Data berhasil diimpor.';
    } catch (_) {
      return 'JSON impor tidak bisa dibaca.';
    }
  }

  Future<void> clearOperationalCache() async {
    await _searchController.clearRecentSearches();
    await _notificationController.clearAll();
    await _quranController.clearCachedDetails();
  }

  Future<void> clearDownloads() => _audioController.clearAllDownloads();

  Future<void> clearPlaylist() => _audioController.clearPlaylist();

  Future<void> syncCloudData() => _quranController.syncCloudData();
}
