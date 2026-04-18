import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../di/injection.dart';
import '../../../../routes/route_names.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({
    super.key,
    this.onExploreQuran,
  });

  final VoidCallback? onExploreQuran;

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependenciesScope.of(context);
    final quranController = dependencies.quranController;
    final authController = dependencies.authController;

    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[quranController, authController]),
        builder: (context, _) {
          final bookmarks = quranController.bookmarks;

          if (quranController.isBootstrapping) {
            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: 6,
              itemBuilder: (context, index) => Container(
                height: 120,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            );
          }

          if (bookmarks.isEmpty) {
            return SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: <Widget>[
                  Container(
                    height: 240,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLow,
                      borderRadius: BorderRadius.circular(36),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.06),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 140,
                          height: 140,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.bookmark_border_rounded,
                            size: 64,
                            color: AppColors.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Belum ada bookmark',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    authController.state.isGuest
                        ? 'Bookmark tamu hanya tersimpan lokal. Login untuk sinkronisasi cloud.'
                        : 'Mulai simpan ayat yang ingin kamu baca lagi nanti.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.55,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 26),
                  PrimaryButton(
                    label: 'Explore Quran',
                    icon: Icons.menu_book_rounded,
                    onPressed: onExploreQuran ??
                        () => Navigator.of(context).pushNamedAndRemoveUntil(
                              RouteNames.bootstrap,
                              (_) => false,
                            ),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: <Widget>[
                if (authController.state.isGuest)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.tertiarySoft.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Mode tamu: bookmark tersimpan lokal saja. Login untuk sinkronisasi antar perangkat.',
                    ),
                  ),
                ...bookmarks.map(
                  (bookmark) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(18),
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
                                  '${bookmark.surahName} • Ayat ${bookmark.ayahNumber}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  final surah = quranController
                                      .surahs()
                                      .where(
                                        (item) => item.number == bookmark.surahNumber,
                                      )
                                      .first;
                                  await quranController.ensureSurahLoaded(surah.number);
                                  final ayah = quranController
                                      .ayahsFor(surah.number)
                                      .where(
                                        (item) => item.number == bookmark.ayahNumber,
                                      )
                                      .first;
                                  await quranController.toggleBookmark(
                                    surah: surah,
                                    ayah: ayah,
                                  );
                                },
                                icon: const Icon(Icons.delete_outline_rounded),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            bookmark.arabic,
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 22, height: 1.8),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            bookmark.translation,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                final surah = quranController
                                    .surahs()
                                    .where((item) => item.number == bookmark.surahNumber)
                                    .first;
                                Navigator.of(context).pushNamed(
                                  RouteNames.reader,
                                  arguments: surah,
                                );
                              },
                              icon: const Icon(Icons.menu_book_rounded),
                              label: const Text('Buka Reader'),
                            ),
                          ),
                        ],
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
}


