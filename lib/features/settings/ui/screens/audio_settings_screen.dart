import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../di/injection.dart';

class AudioSettingsScreen extends StatelessWidget {
  const AudioSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependenciesScope.of(context);
    final settings = dependencies.settingsController;
    final audio = dependencies.audioController;

    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        dependencies.authController,
        audio,
      ]),
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Pengaturan Audio')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              children: <Widget>[
                _section(
                  title: 'Qari Default',
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      initialValue: audio.currentReciter,
                      decoration:
                          const InputDecoration(labelText: 'Qari Default'),
                      items: AppConstants.quranReciters
                          .map(
                            (reciter) => DropdownMenuItem<String>(
                              value: reciter,
                              child: Text(reciter),
                            ),
                          )
                          .toList(),
                      onChanged: (value) async {
                        if (value == null) return;
                        settings.updateReciter(value);
                        await audio.previewReciter(value);
                        if (!context.mounted) return;
                        context.showAppSnack('Qari default diperbarui.');
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () async {
                          await audio.previewReciter(audio.currentReciter);
                          if (!context.mounted) return;
                          if ((audio.error ?? '').isNotEmpty) {
                            context.showAppSnack(audio.error!);
                            return;
                          }
                          context.showAppSnack(
                            'Preview qari ${audio.currentReciter} diputar.',
                          );
                        },
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Tes Qari'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _section(
                  title: 'Pemutaran',
                  children: <Widget>[
                    SwitchListTile.adaptive(
                      title: const Text('Shuffle'),
                      subtitle: const Text('Putar daftar secara acak'),
                      value: audio.shuffleEnabled,
                      onChanged: audio.setShuffleEnabled,
                    ),
                    SwitchListTile.adaptive(
                      title: const Text('Ulangi Saat Ini'),
                      subtitle:
                          const Text('Ulangi surah/ayat yang sedang diputar'),
                      value: audio.repeatEnabled,
                      onChanged: audio.setRepeatEnabled,
                    ),
                    ListTile(
                      title: const Text('Kecepatan Pemutaran'),
                      subtitle: Text(
                        '${audio.speed.toStringAsFixed(2)}x kecepatan pemutaran',
                      ),
                    ),
                    Slider(
                      value: audio.speed,
                      min: 0.75,
                      max: 1.5,
                      divisions: 6,
                      label: '${audio.speed.toStringAsFixed(2)}x',
                      onChanged: (value) => audio.setSpeed(value),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _section(
                  title: 'Unduhan',
                  children: <Widget>[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Surah Terunduh'),
                      subtitle: Text(
                        '${audio.downloadedSurahs.length} file tersedia offline',
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Penyimpanan Lokal'),
                      subtitle: const Text(
                        'Unduhan audio disimpan lokal di perangkat ini dan tidak ikut sinkronisasi cloud.',
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: audio.downloadedSurahs.isEmpty
                          ? null
                          : () async {
                              await settings.clearDownloads();
                              if (!context.mounted) return;
                              context
                                  .showAppSnack('Semua unduhan audio dihapus.');
                            },
                      icon: const Icon(Icons.delete_sweep_rounded),
                      label: const Text('Hapus Unduhan'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _section(
                  title: 'Daftar Putar',
                  children: <Widget>[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Item Daftar Putar'),
                      subtitle: Text(
                          '${audio.playlistSurahs.length} surah tersimpan'),
                    ),
                    OutlinedButton.icon(
                      onPressed: audio.playlistSurahs.isEmpty
                          ? null
                          : () async {
                              await settings.clearPlaylist();
                              if (!context.mounted) return;
                              context.showAppSnack(
                                  'Playlist berhasil dikosongkan.');
                            },
                      icon: const Icon(Icons.playlist_remove_rounded),
                      label: const Text('Kosongkan Playlist'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _section({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
