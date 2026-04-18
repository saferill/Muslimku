import 'package:flutter/material.dart';

import '../data/demo_content.dart';
import '../theme/muslimku_theme.dart';
import 'common_widgets.dart';
import 'detail_screens.dart';

class InteractiveQuranListScreen extends StatefulWidget {
  const InteractiveQuranListScreen({super.key});

  @override
  State<InteractiveQuranListScreen> createState() =>
      _InteractiveQuranListScreenState();
}

class _InteractiveQuranListScreenState
    extends State<InteractiveQuranListScreen> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredSurahs = surahs.where((surah) {
      final query = _query.trim().toLowerCase();
      if (query.isEmpty) return true;
      return surah.name.toLowerCase().contains(query) ||
          surah.meaning.toLowerCase().contains(query) ||
          surah.number.toString().contains(query);
    }).toList();

    return DetailScaffold(
      title: 'Al-Qur\'an',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [
                  MuslimKuColors.primaryContainer.withValues(alpha: 0.88),
                  MuslimKuColors.primary.withValues(alpha: 0.65),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Terakhir Dibaca',
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: Colors.white70)),
                const SizedBox(height: 8),
                Text(
                  'Surah Al-Kahf',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ayat 45 \u2022 Lanjut 2 hari lalu',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SearchField(
            hint: 'Cari Surah, Juz, atau Ayat...',
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            suffixIcon: _query.isEmpty
                ? const Icon(Icons.tune_rounded)
                : IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            '${filteredSurahs.length} surah ditemukan',
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: 16),
          ...filteredSurahs.map(
            (surah) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SurahTile(
                surah: surah,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (_) => const QuranReaderScreen()),
                ),
              ),
            ),
          ),
          if (filteredSurahs.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SurfaceCard(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Tidak ada surah yang cocok dengan pencarian Anda.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class InteractiveQuranSearchScreen extends StatefulWidget {
  const InteractiveQuranSearchScreen({super.key});

  @override
  State<InteractiveQuranSearchScreen> createState() =>
      _InteractiveQuranSearchScreenState();
}

class _InteractiveQuranSearchScreenState
    extends State<InteractiveQuranSearchScreen> {
  late final TextEditingController _searchController;
  String _query = 'Sabar';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: _query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredResults = searchResults.where((result) {
      final query = _query.trim().toLowerCase();
      if (query.isEmpty) return true;
      return result.surah.toLowerCase().contains(query) ||
          result.reference.toLowerCase().contains(query) ||
          result.translation.toLowerCase().contains(query);
    }).toList();

    return DetailScaffold(
      title: 'Pencarian',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchField(
            hint: 'Cari Surah, Ayat, atau Kata Kunci...',
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            suffixIcon: _query.isEmpty
                ? const Icon(Icons.search_rounded)
                : IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  _query.trim().isEmpty
                      ? 'Semua hasil'
                      : 'Hasil untuk "$_query"',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: MuslimKuColors.surfaceLow,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${filteredResults.length} kecocokan',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FilterChipPill(label: 'Semua Hasil', active: true),
                const SizedBox(width: 10),
                FilterChipPill(
                    label:
                        _query.trim().isEmpty ? 'Isi semua' : 'Kata "$_query"'),
                const SizedBox(width: 10),
                const FilterChipPill(label: 'Terjemahan'),
                const SizedBox(width: 10),
                const FilterChipPill(label: 'Nama Surah'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...filteredResults.map(
            (result) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: SurfaceCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const TafsirScreen()),
                ),
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result.surah,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: MuslimKuColors.primary,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(result.reference,
                                  style:
                                      Theme.of(context).textTheme.labelMedium),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: MuslimKuColors.surfaceLow,
                          child: Icon(Icons.arrow_outward_rounded,
                              size: 18, color: MuslimKuColors.textSoft),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      result.arabic,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontSize: 30, height: 1.7),
                    ),
                    const SizedBox(height: 14),
                    Text(result.translation,
                        style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
          ),
          if (filteredResults.isEmpty)
            SurfaceCard(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Belum ada hasil yang cocok dengan kata kunci tersebut.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }
}
