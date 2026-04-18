import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../di/injection.dart';
import '../widgets/audio_player.dart';

class AudioScreen extends StatelessWidget {
  const AudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppDependenciesScope.of(context).audioController;

    return Scaffold(
      appBar: AppBar(title: const Text('Audio Qur\'an')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final currentSurah = controller.currentSurah;
          final sleepLabel = controller.sleepTimerRemainingSeconds == null
              ? 'Timer tidur mati'
              : 'Tidur dalam ${controller.sleepTimerRemainingSeconds! ~/ 60}:${(controller.sleepTimerRemainingSeconds! % 60).toString().padLeft(2, '0')}';

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  AppColors.primary.withValues(alpha: 0.12),
                  AppColors.background,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: <Widget>[
                  AudioPlayerCard(
                    title: currentSurah?.name ?? 'Pilih Surah',
                    artist: controller.currentReciter,
                    isPlaying: controller.isPlaying,
                    progress: controller.progress,
                    speed: controller.speed,
                    shuffleEnabled: controller.shuffleEnabled,
                    repeatEnabled: controller.repeatEnabled,
                    sleepLabel: sleepLabel,
                    onToggle: controller.toggle,
                    onSeek: controller.seek,
                    onNext: controller.next,
                    onPrevious: controller.previous,
                    onStop: controller.stop,
                    onSpeedSelected: controller.setSpeed,
                    onShuffleToggle: controller.setShuffleEnabled,
                    onRepeatToggle: controller.setRepeatEnabled,
                    onSleepSelected: controller.setSleepTimer,
                    onMinimize: () => Navigator.of(context).maybePop(),
                  ),
                  if (controller.error != null) ...<Widget>[
                    const SizedBox(height: 16),
                    Text(
                      controller.error!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    'DAFTAR QARI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: AppConstants.quranReciters.map((reciter) {
                      final selected = controller.currentReciter == reciter;
                      return ChoiceChip(
                        label: Text(reciter),
                        selected: selected,
                        onSelected: (_) => controller.previewReciter(reciter),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  if (controller.playlistSurahs.isNotEmpty) ...<Widget>[
                    Row(
                      children: <Widget>[
                        const Expanded(
                          child: Text(
                            'PLAYLIST',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.6,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: controller.clearPlaylist,
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...controller.playlistSurahs.map(
                      (surah) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _MiniAudioTile(
                          title: surah.name,
                          subtitle: 'Tersimpan di playlist',
                          trailingIcon: Icons.remove_circle_outline_rounded,
                          onTap: () =>
                              controller.playSurah(surahNumber: surah.number),
                          onTrailingTap: () =>
                              controller.removeFromPlaylist(surah.number),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (controller.downloadedSurahs.isNotEmpty) ...<Widget>[
                    const Text(
                      'UNDUHAN LOKAL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...controller.downloadedSurahs.map(
                      (surah) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _MiniAudioTile(
                          title: surah.name,
                          subtitle: 'Tersedia offline',
                          trailingIcon: Icons.delete_outline_rounded,
                          onTap: () =>
                              controller.playSurah(surahNumber: surah.number),
                          onTrailingTap: () =>
                              controller.removeDownload(surah.number),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  const Text(
                    'DAFTAR SURAH',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...controller.surahs.take(40).map(
                        (surah) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundColor:
                                      AppColors.primary.withValues(alpha: 0.12),
                                  child: Text(
                                    '${surah.number}',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        surah.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${surah.meaning} • ${surah.ayahCount} ayat',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => controller.playSurah(
                                      surahNumber: surah.number),
                                  icon: const Icon(
                                      Icons.play_circle_fill_rounded),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final message = await controller
                                        .downloadSurah(surah.number);
                                    if (!context.mounted || message == null)
                                      return;
                                    context.showAppSnack(message);
                                  },
                                  icon: Icon(
                                    controller.isDownloaded(surah.number)
                                        ? Icons.download_done_rounded
                                        : controller.isDownloading(surah.number)
                                            ? Icons.downloading_rounded
                                            : Icons.download_rounded,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    if (controller.isInPlaylist(surah.number)) {
                                      await controller
                                          .removeFromPlaylist(surah.number);
                                      if (!context.mounted) return;
                                      context.showAppSnack(
                                          'Dihapus dari playlist.');
                                      return;
                                    }
                                    await controller
                                        .addToPlaylist(surah.number);
                                    if (!context.mounted) return;
                                    context.showAppSnack(
                                        'Ditambahkan ke playlist.');
                                  },
                                  icon: Icon(
                                    controller.isInPlaylist(surah.number)
                                        ? Icons.playlist_add_check_rounded
                                        : Icons.playlist_add_rounded,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MiniAudioTile extends StatelessWidget {
  const _MiniAudioTile({
    required this.title,
    required this.subtitle,
    required this.trailingIcon,
    required this.onTap,
    required this.onTrailingTap,
  });

  final String title;
  final String subtitle;
  final IconData trailingIcon;
  final VoidCallback onTap;
  final VoidCallback onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.library_music_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onTrailingTap,
              icon: Icon(trailingIcon),
            ),
          ],
        ),
      ),
    );
  }
}
