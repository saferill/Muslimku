import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/storage/local_storage.dart';
import 'models/ayah_model.dart';
import 'models/bookmark_model.dart';
import 'models/reading_progress_model.dart';
import 'models/search_result_model.dart';
import 'models/surah_detail_model.dart';
import 'models/surah_model.dart';
import 'models/tafsir_entry_model.dart';
import 'quran_api.dart';

class QuranRepository {
  QuranRepository({
    required QuranApi api,
    required LocalStorage storage,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _api = api,
        _storage = storage,
        _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  static const _bookmarksKey = 'quran.bookmarks.v1';
  static const _lastReadKey = 'quran.last_read.v1';
  static const _notesKey = 'quran.notes.v1';
  static const _highlightsKey = 'quran.highlights.v1';

  final QuranApi _api;
  final LocalStorage _storage;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  List<SurahModel>? _cachedSurahs;
  final Map<int, SurahDetailModel> _detailCache = <int, SurahDetailModel>{};

  Future<List<SurahModel>> fetchSurahs() async {
    if (_cachedSurahs != null) return _cachedSurahs!;
    final response = await _api.fetchSurahList();
    final data = List<Map<String, dynamic>>.from(response['data'] as List);
    _cachedSurahs = data.map(SurahModel.fromJson).toList();
    return _cachedSurahs!;
  }

  Future<SurahDetailModel> fetchSurahDetail(int number) async {
    final cached = _detailCache[number];
    if (cached != null) return cached;

    final detailResponse = await _api.fetchSurahDetail(number);
    final tafsirResponse = await _api.fetchTafsir(number);

    final detailData = Map<String, dynamic>.from(detailResponse['data'] as Map);
    final tafsirData = Map<String, dynamic>.from(tafsirResponse['data'] as Map);

    final surah = SurahModel.fromJson(detailData);
    final tafsirEntries = List<Map<String, dynamic>>.from(
      tafsirData['tafsir'] as List? ?? const <Map<String, dynamic>>[],
    ).map((entry) => TafsirEntryModel.fromJson(number, entry)).toList();

    final tafsirMap = <String, String>{
      for (final item in tafsirEntries) item.verseKey: item.text,
    };

    final ayahs = List<Map<String, dynamic>>.from(
      detailData['ayat'] as List? ?? const <Map<String, dynamic>>[],
    )
        .map(
          (entry) => AyahModel.fromJson(
            surahNumber: surah.number,
            surahName: surah.name,
            json: entry,
            tafsir: tafsirMap['${surah.number}:${entry['nomorAyat']}'],
          ),
        )
        .toList();

    final detail = SurahDetailModel(
      surah: surah,
      ayahs: ayahs,
      tafsir: tafsirEntries,
    );
    _detailCache[number] = detail;
    return detail;
  }

  Future<List<SearchResultModel>> search(String query) async {
    if (query.trim().isEmpty) return const <SearchResultModel>[];
    final response = await _api.search(query: query.trim());
    final payload = response['hasil'] ?? response['data'] ?? response['results'];
    final raw = List<Map<String, dynamic>>.from(
      payload as List? ?? const <Map<String, dynamic>>[],
    );
    return raw.map(SearchResultModel.fromJson).toList();
  }

  Future<List<BookmarkModel>> loadBookmarks() async {
    final local = _readLocalBookmarks();
    final user = _auth.currentUser;
    if (user == null) return _sortBookmarks(local.values);

    final remoteSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .get();

    final merged = <String, BookmarkModel>{...local};
    for (final doc in remoteSnapshot.docs) {
      final bookmark = BookmarkModel.fromJson(doc.data());
      final existing = merged[bookmark.verseKey];
      if (existing == null ||
          bookmark.updatedAtEpochMs > existing.updatedAtEpochMs) {
        merged[bookmark.verseKey] = bookmark;
      }
    }

    await _persistBookmarks(merged.values.toList());
    await _pushBookmarksToCloud(merged.values.toList());
    return _sortBookmarks(merged.values);
  }

  Future<bool> toggleBookmark({
    required SurahModel surah,
    required AyahModel ayah,
  }) async {
    final bookmarks = _readLocalBookmarks();
    final exists = bookmarks.containsKey(ayah.verseKey);

    if (exists) {
      bookmarks.remove(ayah.verseKey);
    } else {
      bookmarks[ayah.verseKey] = BookmarkModel(
        verseKey: ayah.verseKey,
        surahNumber: surah.number,
        surahName: surah.name,
        surahArabic: surah.arabic,
        ayahNumber: ayah.number,
        arabic: ayah.arabic,
        translation: ayah.translation,
        updatedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
      );
    }

    await _persistBookmarks(bookmarks.values.toList());

    final user = _auth.currentUser;
    if (user != null) {
      final ref = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('bookmarks')
          .doc(ayah.verseKey.replaceAll(':', '_'));
      if (exists) {
        await ref.delete();
      } else {
        await ref.set(bookmarks[ayah.verseKey]!.toJson());
      }
    }

    return !exists;
  }

  Future<void> saveLastRead({
    required SurahModel surah,
    required AyahModel ayah,
  }) async {
    final progress = ReadingProgressModel(
      surahNumber: surah.number,
      surahName: surah.name,
      surahArabic: surah.arabic,
      ayahNumber: ayah.number,
      verseKey: ayah.verseKey,
      updatedAtEpochMs: DateTime.now().millisecondsSinceEpoch,
    );
    await _storage.setJsonMap(_lastReadKey, progress.toJson());

    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('reading')
          .doc('last_read')
          .set(progress.toJson());
    }
  }

  Future<ReadingProgressModel?> loadLastRead() async {
    final local = _storage.getJsonMap(_lastReadKey);
    final localProgress =
        local == null ? null : ReadingProgressModel.fromJson(local);

    final user = _auth.currentUser;
    if (user == null) return localProgress;

    final remote = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('reading')
        .doc('last_read')
        .get();
    if (!remote.exists) return localProgress;

    final remoteProgress = ReadingProgressModel.fromJson(remote.data()!);
    if (localProgress == null ||
        remoteProgress.updatedAtEpochMs >= localProgress.updatedAtEpochMs) {
      await _storage.setJsonMap(_lastReadKey, remoteProgress.toJson());
      return remoteProgress;
    }
    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('reading')
        .doc('last_read')
        .set(localProgress.toJson());
    return localProgress;
  }

  Future<void> syncLocalDataToCloud() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _pushBookmarksToCloud(_readLocalBookmarks().values.toList());
    final lastRead = _storage.getJsonMap(_lastReadKey);
    if (lastRead != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('reading')
          .doc('last_read')
          .set(lastRead);
    }
  }

  Map<String, String> loadNotes() {
    final raw = _storage.getString(_notesKey);
    if ((raw ?? '').isEmpty) return <String, String>{};
    final decoded = Map<String, dynamic>.from(
      _storage.getJsonMap(_notesKey) ?? const <String, dynamic>{},
    );
    return decoded.map((key, value) => MapEntry(key, '$value'));
  }

  Future<void> saveNote({
    required String verseKey,
    required String note,
  }) async {
    final notes = loadNotes();
    if (note.trim().isEmpty) {
      notes.remove(verseKey);
    } else {
      notes[verseKey] = note.trim();
    }
    await _storage.setJsonMap(_notesKey, notes);
  }

  Set<String> loadHighlights() {
    final items = _storage.getStringList(_highlightsKey) ?? const <String>[];
    return items.toSet();
  }

  Future<bool> toggleHighlight(String verseKey) async {
    final highlights = loadHighlights();
    final exists = highlights.contains(verseKey);
    if (exists) {
      highlights.remove(verseKey);
    } else {
      highlights.add(verseKey);
    }
    await _storage.setStringList(_highlightsKey, highlights.toList());
    return !exists;
  }

  Map<String, BookmarkModel> _readLocalBookmarks() {
    final items = _storage.getJsonList(_bookmarksKey);
    return <String, BookmarkModel>{
      for (final item in items)
        BookmarkModel.fromJson(item).verseKey: BookmarkModel.fromJson(item),
    };
  }

  Future<void> _persistBookmarks(List<BookmarkModel> bookmarks) {
    return _storage.setJsonList(
      _bookmarksKey,
      bookmarks.map((bookmark) => bookmark.toJson()).toList(),
    );
  }

  Future<void> _pushBookmarksToCloud(List<BookmarkModel> bookmarks) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final collection =
        _firestore.collection('users').doc(user.uid).collection('bookmarks');

    for (final bookmark in bookmarks) {
      await collection
          .doc(bookmark.verseKey.replaceAll(':', '_'))
          .set(bookmark.toJson());
    }
  }

  List<BookmarkModel> _sortBookmarks(Iterable<BookmarkModel> values) {
    final sorted = values.toList()
      ..sort((a, b) => b.updatedAtEpochMs.compareTo(a.updatedAtEpochMs));
    return sorted;
  }
}
