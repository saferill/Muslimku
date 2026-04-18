import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/colors.dart';
import '../../../../di/injection.dart';
import '../../../../routes/route_names.dart';
import '../../../adzan/data/models/prayer_time_model.dart';
import '../../../quran/data/models/ayah_model.dart';
import '../../../quran/data/models/reading_progress_model.dart';
import '../../../quran/data/models/surah_model.dart';
import '../../../quran/logic/quran_controller.dart';
import '../widgets/daily_ayah.dart';
import '../widgets/prayer_card.dart';
import '../widgets/quick_actions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onOpenQuran,
    required this.onOpenAudio,
    required this.onOpenAdzan,
    required this.onOpenSearch,
    required this.onOpenNotifications,
  });

  final VoidCallback onOpenQuran;
  final VoidCallback onOpenAudio;
  final VoidCallback onOpenAdzan;
  final VoidCallback onOpenSearch;
  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependenciesScope.of(context);

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[
          dependencies.authController,
          dependencies.quranController,
        ]),
        builder: (context, _) {
          final state = dependencies.authController.state;
          final quranController = dependencies.quranController;
          final lastRead = quranController.lastRead;
          final dailySurah = _findSurah(quranController.surahs(), 2);
          final dailyAyah = _findDailyAyah(quranController, dailySurah);

          if (dailySurah != null &&
              quranController.detailFor(dailySurah.number) == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              quranController.ensureSurahLoaded(dailySurah.number);
            });
          }

          return StreamBuilder<DateTime>(
            stream: Stream<DateTime>.periodic(
              const Duration(seconds: 1),
              (_) => DateTime.now().toUtc(),
            ),
            builder: (context, snapshot) {
              final nowUtc = snapshot.data ?? DateTime.now().toUtc();
              final prayerSnapshot = dependencies.adzanController.snapshotFor(
                locationLabel: state.currentLocation,
                nowUtc: nowUtc,
              );

              return SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Assalamu\'alaikum, ${state.user.firstName}',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.8,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: <Widget>[
                                  _pill(prayerSnapshot.location.label),
                                  if (state.isGuest) _pill('Guest Mode'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: onOpenNotifications,
                          icon: const Icon(Icons.notifications_none_rounded),
                        ),
                      ],
                    ),
                    if (state.isGuest) ...<Widget>[
                      const SizedBox(height: 16),
                      _GuestBanner(
                        onLogin: () =>
                            Navigator.of(context).pushNamed(RouteNames.login),
                      ),
                    ],
                    const SizedBox(height: 28),
                    PrayerCard(snapshot: prayerSnapshot),
                    const SizedBox(height: 24),
                    QuickActions(
                      onOpenQuran: onOpenQuran,
                      onOpenAudio: onOpenAudio,
                      onOpenAdzan: onOpenAdzan,
                      onOpenSearch: onOpenSearch,
                    ),
                    const SizedBox(height: 24),
                    _LastReadCard(
                      progress: lastRead,
                      surah: lastRead == null
                          ? null
                          : _findSurah(
                              quranController.surahs(), lastRead.surahNumber),
                    ),
                    const SizedBox(height: 16),
                    DailyAyahCard(
                      ayah: dailyAyah,
                      surah: dailySurah,
                      bookmarked: dailyAyah != null &&
                          quranController.isBookmarked(dailyAyah.verseKey),
                      onOpen: dailySurah == null
                          ? null
                          : () => Navigator.of(context).pushNamed(
                                RouteNames.reader,
                                arguments: dailySurah,
                              ),
                      onBookmark: (dailySurah == null || dailyAyah == null)
                          ? null
                          : () => quranController.toggleBookmark(
                                surah: dailySurah,
                                ayah: dailyAyah,
                              ),
                      onShare: (dailySurah == null || dailyAyah == null)
                          ? null
                          : () => SharePlus.instance.share(
                                ShareParams(
                                  text:
                                      '${dailyAyah.arabic}\n${dailyAyah.translation}\n${dailySurah.name} ${dailyAyah.number}',
                                ),
                              ),
                    ),
                    const SizedBox(height: 16),
                    _ExploreBanner(snapshot: prayerSnapshot),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  SurahModel? _findSurah(List<SurahModel> surahs, int number) {
    for (final surah in surahs) {
      if (surah.number == number) return surah;
    }
    return surahs.isEmpty ? null : surahs.first;
  }

  AyahModel? _findDailyAyah(
    QuranController quranController,
    SurahModel? surah,
  ) {
    if (surah == null) return null;
    final ayahs = quranController.ayahsFor(surah.number);
    for (final ayah in ayahs) {
      if (ayah.number == 152) return ayah;
    }
    return ayahs.isNotEmpty ? ayahs.first : null;
  }

  Widget _pill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _GuestBanner extends StatelessWidget {
  const _GuestBanner({
    required this.onLogin,
  });

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.tertiarySoft.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Text(
              'Login atau daftar untuk sinkronisasi cloud, backup bookmark, dan akses multi-device.',
              style: TextStyle(height: 1.45),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: onLogin,
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}

class _LastReadCard extends StatelessWidget {
  const _LastReadCard({
    required this.progress,
    required this.surah,
  });

  final ReadingProgressModel? progress;
  final SurahModel? surah;

  @override
  Widget build(BuildContext context) {
    final currentProgress = progress;
    final currentSurah = surah;
    final hasData = currentProgress != null && currentSurah != null;

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: hasData
          ? () => Navigator.of(context).pushNamed(
                RouteNames.reader,
                arguments: currentSurah,
              )
          : null,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const <Widget>[
                Text(
                  'BACAAN TERAKHIR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                    color: AppColors.secondary,
                  ),
                ),
                Icon(Icons.auto_stories_rounded, color: AppColors.secondary),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              hasData ? currentSurah.name : 'Belum ada bacaan terakhir',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              hasData
                  ? 'Ayat ${currentProgress.ayahNumber} • ${currentProgress.verseKey}'
                  : 'Mulai membaca Al-Qur\'an untuk menyimpan progres.',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: hasData
                    ? (currentProgress.ayahNumber / currentSurah.ayahCount)
                    : 0,
                backgroundColor: AppColors.surfaceHigh,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreBanner extends StatelessWidget {
  const _ExploreBanner({
    required this.snapshot,
  });

  final PrayerSnapshotModel snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B2B1A), Color(0xFF17452C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          const Text(
            'Keindahan Zikir',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kiblat ${snapshot.qiblaBearing.toStringAsFixed(0)}° • ${snapshot.distanceToMakkahKm.toStringAsFixed(0)} km ke Makkah',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}


