import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../data/models/ayah_model.dart';
import '../data/models/bookmark_model.dart';
import '../data/models/reading_progress_model.dart';
import '../data/models/search_result_model.dart';
import '../data/models/surah_detail_model.dart';
import '../data/models/surah_model.dart';
import '../data/quran_repository.dart';

class QuranController extends ChangeNotifier {
  QuranController(this._repository) {
    bootstrap();
  }

  final QuranRepository _repository;

  bool _bootstrapping = false;
  bool _searching = false;
  String? _error;
  String? _searchError;
  List<SurahModel> _surahs = const <SurahModel>[];
  final Map<int, SurahDetailModel> _details = <int, SurahDetailModel>{};
  List<SearchResultModel> _searchResults = const <SearchResultModel>[];
  List<BookmarkModel> _bookmarks = const <BookmarkModel>[];
  Map<String, String> _notes = const <String, String>{};
  Set<String> _highlights = const <String>{};
  ReadingProgressModel? _lastRead;

  bool get isBootstrapping => _bootstrapping;
  bool get isSearching => _searching;
  String? get error => _error;
  String? get searchError => _searchError;
  List<SearchResultModel> get searchResults => _searchResults;
  List<BookmarkModel> get bookmarks => _bookmarks;
  Map<String, String> get notes => _notes;
  Set<String> get highlights => _highlights;
  ReadingProgressModel? get lastRead => _lastRead;

  Future<void> bootstrap() async {
    if (_bootstrapping) return;
    _bootstrapping = true;
    _error = null;
    notifyListeners();
    try {
      _surahs = await _repository.fetchSurahs();
      _bookmarks = await _repository.loadBookmarks();
      _lastRead = await _repository.loadLastRead();
      _notes = _repository.loadNotes();
      _highlights = _repository.loadHighlights();
    } catch (error) {
      _error = error.toString();
    } finally {
      _bootstrapping = false;
      notifyListeners();
    }
  }

  Future<void> reloadLocalData() async {
    _bookmarks = await _repository.loadBookmarks();
    _lastRead = await _repository.loadLastRead();
    _notes = _repository.loadNotes();
    _highlights = _repository.loadHighlights();
    notifyListeners();
  }

  Future<void> clearCachedDetails() async {
    _details.clear();
    notifyListeners();
  }

  List<SurahModel> surahs({String query = ''}) {
    if (query.trim().isEmpty) return _surahs;
    final normalized = query.toLowerCase().trim();
    return _surahs.where((surah) {
      return surah.name.toLowerCase().contains(normalized) ||
          surah.meaning.toLowerCase().contains(normalized) ||
          surah.number.toString() == normalized;
    }).toList();
  }

  Future<SurahDetailModel?> ensureSurahLoaded(int surahNumber) async {
    final cached = _details[surahNumber];
    if (cached != null) return cached;

    try {
      final detail = await _repository.fetchSurahDetail(surahNumber);
      _details[surahNumber] = detail;
      notifyListeners();
      return detail;
    } catch (error) {
      _error = error.toString();
      notifyListeners();
      return null;
    }
  }

  SurahDetailModel? detailFor(int surahNumber) => _details[surahNumber];

  List<AyahModel> ayahsFor(int surahNumber) {
    return _details[surahNumber]?.ayahs ?? const <AyahModel>[];
  }

  Future<void> search(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      _searchResults = const <SearchResultModel>[];
      _searchError = null;
      notifyListeners();
      return;
    }
    _searching = true;
    _searchError = null;
    notifyListeners();
    try {
      final remoteResults = await _repository.search(normalized);
      if (remoteResults.isNotEmpty) {
        _searchResults = remoteResults;
      } else {
        _searchResults = _fallbackSearch(normalized);
      }
    } catch (error) {
      _searchResults = _fallbackSearch(normalized);
      if (_searchResults.isEmpty) {
        _searchError = error.toString();
      } else {
        _searchError = null;
      }
    } finally {
      _searching = false;
      notifyListeners();
    }
  }

  bool isBookmarked(String verseKey) {
    return _bookmarks.any((bookmark) => bookmark.verseKey == verseKey);
  }

  bool isHighlighted(String verseKey) => _highlights.contains(verseKey);

  String noteFor(String verseKey) => _notes[verseKey] ?? '';

  Future<bool> toggleBookmark({
    required SurahModel surah,
    required AyahModel ayah,
  }) async {
    final saved = await _repository.toggleBookmark(surah: surah, ayah: ayah);
    _bookmarks = await _repository.loadBookmarks();
    notifyListeners();
    return saved;
  }

  Future<void> markLastRead({
    required SurahModel surah,
    required AyahModel ayah,
  }) async {
    await _repository.saveLastRead(surah: surah, ayah: ayah);
    _lastRead = await _repository.loadLastRead();
    notifyListeners();
  }

  Future<void> syncCloudData() async {
    await _repository.syncLocalDataToCloud();
    _bookmarks = await _repository.loadBookmarks();
    _lastRead = await _repository.loadLastRead();
    notifyListeners();
  }

  Future<void> saveNote({
    required String verseKey,
    required String note,
  }) async {
    await _repository.saveNote(verseKey: verseKey, note: note);
    _notes = _repository.loadNotes();
    notifyListeners();
  }

  Future<bool> toggleHighlight(String verseKey) async {
    final highlighted = await _repository.toggleHighlight(verseKey);
    _highlights = _repository.loadHighlights();
    notifyListeners();
    return highlighted;
  }

  String reciterIdForName(String name) {
    return AppConstants.quranReciterIds[name] ?? '05';
  }

  List<SearchResultModel> _fallbackSearch(String query) {
    final normalized = query.toLowerCase();
    return _surahs.where((surah) {
      return surah.name.toLowerCase().contains(normalized) ||
          surah.meaning.toLowerCase().contains(normalized) ||
          surah.arabic.contains(query) ||
          surah.number.toString() == normalized;
    }).map((surah) {
      return SearchResultModel(
        type: 'surah',
        score: 1,
        relevance: 'Hasil dari daftar surah',
        surahNumber: surah.number,
        surahName: surah.name,
        surahArabic: surah.arabic,
        ayahNumber: 1,
        translation: surah.meaning,
        tafsirText: surah.description,
      );
    }).toList();
  }
}
