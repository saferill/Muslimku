import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../di/injection.dart';

class QuranSettingsScreen extends StatelessWidget {
  const QuranSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependenciesScope.of(context);
    final settings = dependencies.settingsController;

    return AnimatedBuilder(
      animation: dependencies.authController,
      builder: (context, _) {
        final state = settings.state;
        return Scaffold(
          appBar: AppBar(title: const Text('Pengaturan Qur\'an')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: <Widget>[
                SwitchListTile(
                  title: const Text('Tampilkan Terjemahan Otomatis'),
                  subtitle:
                      const Text('Reader menampilkan terjemahan otomatis'),
                  value: state.readerShowTranslation,
                  onChanged: settings.updateReaderShowTranslation,
                ),
                SwitchListTile(
                  title: const Text('Tampilkan Tafsir Otomatis'),
                  subtitle: const Text('Reader menampilkan tafsir otomatis'),
                  value: state.readerShowTafsir,
                  onChanged: settings.updateReaderShowTafsir,
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text('Skala Font Arab'),
                  subtitle: Text(
                      'Ukuran saat ini ${(state.readerFontScale * 100).round()}%'),
                ),
                Slider(
                  value: state.readerFontScale,
                  min: 0.9,
                  max: 1.6,
                  divisions: 7,
                  onChanged: settings.updateReaderFontScale,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Terjemahan',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Pilihan ini dipakai di reader dan hasil pencarian ketika tersedia.',
                ),
                const SizedBox(height: 12),
                ...AppConstants.translationOptions.map((translation) {
                  final selected = settings.state.translation == translation;
                  return ListTile(
                    title: Text(translation),
                    trailing: Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                    ),
                    onTap: () => settings.updateTranslation(translation),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
