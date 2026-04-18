import 'dart:async';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../di/injection.dart';
import '../../../../routes/route_names.dart';
import '../../../quran/data/models/search_result_model.dart';
import '../../../quran/data/models/surah_model.dart';
import '../../../quran/logic/quran_controller.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final SpeechToText _speech = SpeechToText();
  Timer? _debounce;
  bool _speechReady = false;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _initializeSpeech() async {
    final ready = await _speech.initialize();
    if (!mounted) return;
    setState(() => _speechReady = ready);
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependenciesScope.of(context);
    final quranController = dependencies.quranController;
    final searchController = dependencies.searchController;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[quranController, searchController]),
        builder: (context, _) {
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              children: <Widget>[
                const Text(
                  'Pencarian',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _controller,
                  onChanged: (value) {
                    _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 350), () {
                      quranController.search(value);
                    });
                    setState(() {});
                  },
                  onSubmitted: (value) {
                    searchController.addRecentSearch(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari surah, ayat, atau topik...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _controller.text.isEmpty
                        ? IconButton(
                            onPressed: _speechReady ? _toggleVoiceSearch : null,
                            icon: Icon(
                              _listening
                                  ? Icons.mic_rounded
                                  : Icons.mic_none_rounded,
                            ),
                          )
                        : IconButton(
                            onPressed: () {
                              _debounce?.cancel();
                              _controller.clear();
                              quranController.search('');
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: <Widget>[
                    const Expanded(
                      child: Text(
                        'Pencarian terbaru',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                    if (searchController.recentSearches.isNotEmpty)
                      TextButton(
                        onPressed: searchController.clearRecentSearches,
                        child: const Text('Hapus'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                ...searchController.recentSearches.map(
                  (item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.history_rounded),
                    title: Text(item),
                    onTap: () {
                      _controller.text = item;
                      quranController.search(item);
                      searchController.addRecentSearch(item);
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Hasil pencarian',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                if (quranController.isSearching)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (quranController.searchError != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: <Widget>[
                        const Text(
                          'Pencarian online sedang bermasalah. Coba lagi atau gunakan kata kunci lain.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.error),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () => quranController.search(_controller.text),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  )
                else if (_controller.text.isNotEmpty &&
                    quranController.searchResults.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Hasil tidak ditemukan',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                else
                  ...quranController.searchResults.map(
                    (result) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () async {
                          final surah = _findSurah(
                            quranController.surahs(),
                            result.surahNumber,
                          );
                          if (surah == null) return;
                          await searchController.addRecentSearch(_controller.text);
                          if (!context.mounted) return;
                          Navigator.of(context).pushNamed(
                            RouteNames.reader,
                            arguments: surah,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      '${result.surahName} • Ayat ${result.ayahNumber}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    result.surahArabic,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 22,
                                    ),
                                  ),
                                ],
                              ),
                              if ((result.arabic ?? '').isNotEmpty) ...<Widget>[
                                const SizedBox(height: 12),
                                Text(
                                  result.arabic!,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    height: 1.8,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Text(
                                result.translation ??
                                    result.tafsirText ??
                                    result.relevance,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: <Widget>[
                                  ActionChip(
                                    label: const Text('Buka'),
                                    avatar: const Icon(
                                      Icons.menu_book_rounded,
                                      size: 18,
                                    ),
                                    onPressed: () async {
                                      final surah = _findSurah(
                                        quranController.surahs(),
                                        result.surahNumber,
                                      );
                                      if (surah == null) return;
                                      await searchController.addRecentSearch(
                                        _controller.text,
                                      );
                                      if (!context.mounted) return;
                                      Navigator.of(context).pushNamed(
                                        RouteNames.reader,
                                        arguments: surah,
                                      );
                                    },
                                  ),
                                  ActionChip(
                                    label: const Text('Simpan'),
                                    avatar: const Icon(
                                      Icons.bookmark_rounded,
                                      size: 18,
                                    ),
                                    onPressed: () => _bookmarkResult(
                                      quranController: quranController,
                                      result: result,
                                    ),
                                  ),
                                  ActionChip(
                                    label: const Text('Bagikan'),
                                    avatar: const Icon(
                                      Icons.share_rounded,
                                      size: 18,
                                    ),
                                    onPressed: () => SharePlus.instance.share(
                                      ShareParams(
                                        text:
                                            '${result.arabic ?? ''}\n${result.translation ?? result.tafsirText ?? result.relevance}\n${result.surahName} ${result.ayahNumber}',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  SurahModel? _findSurah(List<SurahModel> surahs, int number) {
    return surahs.where((item) => item.number == number).firstOrNull;
  }

  Future<void> _bookmarkResult({
    required QuranController quranController,
    required SearchResultModel result,
  }) async {
    final surah = _findSurah(quranController.surahs(), result.surahNumber);
    if (surah == null) return;
    await quranController.ensureSurahLoaded(surah.number);
    final ayah = quranController
        .ayahsFor(surah.number)
        .where((entry) => entry.number == result.ayahNumber)
        .firstOrNull;
    if (ayah == null || !mounted) return;
    final saved = await quranController.toggleBookmark(surah: surah, ayah: ayah);
    if (!mounted) return;
    context.showAppSnack(saved ? 'Bookmark disimpan.' : 'Bookmark dihapus.');
  }

  Future<void> _toggleVoiceSearch() async {
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }

    final started = await _speech.listen(
      onResult: (result) {
        _controller.text = result.recognizedWords;
        AppDependenciesScope.of(context)
            .quranController
            .search(result.recognizedWords);
        if (result.finalResult) {
          AppDependenciesScope.of(context)
              .searchController
              .addRecentSearch(result.recognizedWords);
          if (mounted) setState(() => _listening = false);
        } else if (mounted) {
          setState(() {});
        }
      },
    );
    if (!mounted) return;
    setState(() => _listening = started);
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
