import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../di/injection.dart';
import '../../../../routes/route_names.dart';
import '../../data/models/surah_model.dart';

class SurahDetailScreen extends StatefulWidget {
  const SurahDetailScreen({
    super.key,
    this.surah,
  });

  final SurahModel? surah;

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  bool _requested = false;

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependenciesScope.of(context);
    final controller = dependencies.quranController;
    final audioController = dependencies.audioController;
    final fallbackSurah = controller.surahs().isNotEmpty ? controller.surahs().first : null;
    final current = widget.surah ?? fallbackSurah;

    if (!_requested && current != null) {
      _requested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.ensureSurahLoaded(current.number);
      });
    }

    final detail = current == null ? null : controller.detailFor(current.number);

    return Scaffold(
      appBar: AppBar(title: Text(current?.name ?? 'Surah')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: current == null
              ? const Center(child: Text('Surah tidak ditemukan'))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppColors.heroGradient,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            current.arabic,
                            style: const TextStyle(
                              fontSize: 36,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            current.name,
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${current.meaning} • ${current.ayahCount} ayat • ${current.origin}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Ringkasan surah',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _cleanDescription(current.description),
                      style: const TextStyle(
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (detail == null)
                      const LinearProgressIndicator()
                    else
                      Text(
                        '${detail.ayahs.length} ayat • ${detail.tafsir.length} tafsir tersedia',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      ),
                    const Spacer(),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => audioController.playSurah(
                              surahNumber: current.number,
                            ),
                            icon: const Icon(Icons.play_circle_fill_rounded),
                            label: const Text('Putar Audio Penuh'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => Navigator.of(context).pushNamed(
                              RouteNames.reader,
                              arguments: current,
                            ),
                            icon: const Icon(Icons.menu_book_rounded),
                            label: const Text('Buka Reader'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  String _cleanDescription(String value) {
    if (value.trim().isEmpty) {
      return 'Ringkasan surah akan muncul setelah data detail tersedia.';
    }
    return value.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&quot;', '"');
  }
}


