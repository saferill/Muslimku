import 'package:flutter/foundation.dart';

import '../../../core/storage/local_storage.dart';
import '../../quran/data/models/surah_model.dart';
import '../../quran/logic/quran_controller.dart';

class SearchController extends ChangeNotifier {
  SearchController({
    required QuranController quranController,
    required LocalStorage storage,
  })  : _quranController = quranController,
        _storage = storage {
    _hydrate();
  }

  static const _recentSearchesKey = 'search.recent_queries.v1';

  final QuranController _quranController;
  final LocalStorage _storage;

  List<String> _recentSearches = const <String>[];

  List<String> get recentSearches => List<String>.unmodifiable(_recentSearches);

  Future<void> _hydrate() async {
    await _storage.init();
    _recentSearches = _storage.getStringList(_recentSearchesKey) ??
        <String>['Al-Mulk', 'Al-Kahf', 'Ayat Kursi'];
    notifyListeners();
  }

  Future<void> reload() => _hydrate();

  List<SurahModel> search(String query) {
    return _quranController.surahs(query: query);
  }

  Future<void> addRecentSearch(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return;
    _recentSearches = <String>[
      normalized,
      ..._recentSearches.where(
        (item) => item.toLowerCase() != normalized.toLowerCase(),
      ),
    ].take(8).toList();
    await _storage.setStringList(_recentSearchesKey, _recentSearches);
    notifyListeners();
  }

  Future<void> clearRecentSearches() async {
    _recentSearches = const <String>[];
    await _storage.setStringList(_recentSearchesKey, _recentSearches);
    notifyListeners();
  }
}
