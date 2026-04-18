import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../di/injection.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  static const _calculationMethods = <String>[
    'Muslim World League',
    'Kementerian Agama RI',
    'Umm al-Qura',
    'Egyptian General Authority',
  ];

  static const _madhabs = <String>[
    'Shafi\'i',
    'Hanafi',
    'Maliki',
    'Hanbali',
  ];

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependenciesScope.of(context);
    final settings = dependencies.settingsController;
    final adzan = dependencies.adzanController;
    final audio = dependencies.audioController;

    return AnimatedBuilder(
      animation:
          Listenable.merge(<Listenable>[
            dependencies.authController,
            adzan,
            audio,
          ]),
      builder: (context, _) {
        final state = settings.state;
        return Scaffold(
          appBar: AppBar(title: const Text('Pengaturan Notifikasi')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              children: <Widget>[
                _section(
                  title: 'Master',
                  children: <Widget>[
                    SwitchListTile.adaptive(
                      title: const Text('Notifikasi Adzan Utama'),
                      subtitle: const Text(
                        'Aktifkan atau matikan semua adzan lokal dan background scheduler.',
                      ),
                      value: adzan.masterEnabled,
                      onChanged: (value) async {
                        settings.setAdzanAlerts(value);
                        await adzan.setMasterEnabled(value);
                      },
                    ),
                    SwitchListTile.adaptive(
                      title: const Text('Ayat Harian'),
                      subtitle: const Text(
                        'Tampilkan refleksi ayat harian di pusat notifikasi.',
                      ),
                      value: state.dailyVerses,
                      onChanged: settings.setDailyVerses,
                    ),
                    SwitchListTile.adaptive(
                      title: const Text('Getar'),
                      subtitle: const Text(
                        'Gunakan getaran saat pengingat adzan masuk.',
                      ),
                      value: adzan.vibrationEnabled,
                      onChanged: adzan.setVibrationEnabled,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _section(
                  title: 'Prayer Delivery',
                  children: <Widget>[
                    ListTile(
                      title: const Text('Pre-reminder'),
                      subtitle: Text(
                          '${adzan.preReminderMinutes} menit sebelum adzan'),
                    ),
                    Slider(
                      value: adzan.preReminderMinutes.toDouble(),
                      min: 0,
                      max: 30,
                      divisions: 6,
                      label: '${adzan.preReminderMinutes}',
                      onChanged: (value) =>
                          adzan.setPreReminderMinutes(value.round()),
                    ),
                    ListTile(
                      title: const Text('Offset Time'),
                      subtitle: Text(
                        '${adzan.offsetMinutes >= 0 ? '+' : ''}${adzan.offsetMinutes} menit dari jadwal kalkulasi',
                      ),
                    ),
                    Slider(
                      value: adzan.offsetMinutes.toDouble(),
                      min: -10,
                      max: 10,
                      divisions: 20,
                      label: '${adzan.offsetMinutes}',
                      onChanged: (value) =>
                          adzan.setOffsetMinutes(value.round()),
                    ),
                    ListTile(
                      title: const Text('Preview Volume'),
                      subtitle: Text(
                        '${(adzan.volume * 100).round()}% untuk test sound dalam aplikasi',
                      ),
                    ),
                    Slider(
                      value: adzan.volume,
                      min: 0.2,
                      max: 1,
                      divisions: 8,
                      onChanged: adzan.setVolume,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _section(
                  title: 'Per Prayer',
                  children: <Widget>[
                    ...const <String>[
                      'Subuh',
                      'Zuhur',
                      'Asar',
                      'Magrib',
                      'Isya'
                    ].map(
                      (prayer) => SwitchListTile.adaptive(
                        title: Text(prayer),
                        subtitle: Text('Aktifkan notifikasi untuk $prayer'),
                        value: adzan.prayerEnabled(prayer),
                        onChanged: (value) =>
                            adzan.setPrayerEnabled(prayer, value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _section(
                  title: 'Quiet Hours',
                  children: <Widget>[
                    SwitchListTile.adaptive(
                      title: const Text('Jendela Jangan Ganggu'),
                      subtitle: const Text(
                        'Jangan jadwalkan notifikasi baru selama jam tenang.',
                      ),
                      value: adzan.quietHoursEnabled,
                      onChanged: adzan.setQuietHoursEnabled,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: adzan.quietStartHour,
                            decoration:
                                const InputDecoration(labelText: 'Mulai'),
                            items: List<DropdownMenuItem<int>>.generate(
                              24,
                              (index) => DropdownMenuItem<int>(
                                value: index,
                                child: Text(_formatHour(index)),
                              ),
                            ),
                            onChanged: (value) {
                              if (value == null) return;
                              adzan.setQuietWindow(startHour: value);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: adzan.quietEndHour,
                            decoration:
                                const InputDecoration(labelText: 'Selesai'),
                            items: List<DropdownMenuItem<int>>.generate(
                              24,
                              (index) => DropdownMenuItem<int>(
                                value: index,
                                child: Text(_formatHour(index)),
                              ),
                            ),
                            onChanged: (value) {
                              if (value == null) return;
                              adzan.setQuietWindow(endHour: value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _section(
                  title: 'Prayer Method',
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      initialValue: adzan.calculationMethod,
                      decoration: const InputDecoration(
                        labelText: 'Metode Perhitungan',
                      ),
                      items: _calculationMethods
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        adzan.setCalculationMethod(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: adzan.madhab,
                      decoration: const InputDecoration(
                        labelText: 'Madhab / Metode Asar',
                      ),
                      items: _madhabs
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        adzan.setMadhab(value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _section(
                  title: 'Sounds',
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      initialValue: adzan.regularSound,
                      decoration:
                          const InputDecoration(labelText: 'Suara Reguler'),
                      items: AppConstants.adzanSounds
                          .map(
                            (sound) => DropdownMenuItem<String>(
                              value: sound,
                              child: Text(sound),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        adzan.setRegularSound(value);
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () async {
                          await audio.playAdhanAsset(adzan.regularSound);
                          if (!context.mounted) return;
                          if ((audio.error ?? '').isNotEmpty) {
                            context.showAppSnack(audio.error!);
                            return;
                          }
                          context.showAppSnack('Preview adzan reguler diputar.');
                        },
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Tes reguler'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: adzan.fajrSound,
                      decoration:
                          const InputDecoration(labelText: 'Suara Subuh'),
                      items: AppConstants.adzanSounds
                          .map(
                            (sound) => DropdownMenuItem<String>(
                              value: sound,
                              child: Text(sound),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        adzan.setFajrSound(value);
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () async {
                          await audio.playAdhanAsset(adzan.fajrSound);
                          if (!context.mounted) return;
                          if ((audio.error ?? '').isNotEmpty) {
                            context.showAppSnack(audio.error!);
                            return;
                          }
                          context.showAppSnack('Preview adzan Subuh diputar.');
                        },
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Tes subuh'),
                      ),
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

  static String _formatHour(int hour) {
    final normalized = hour.clamp(0, 23);
    return '${normalized.toString().padLeft(2, '0')}:00';
  }
}
