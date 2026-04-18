import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../di/injection.dart';
import '../../../../routes/route_names.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../logic/adzan_controller.dart';
import '../../data/models/prayer_time_model.dart';
import '../widgets/prayer_tile.dart';

class AdzanScreen extends StatelessWidget {
  const AdzanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependenciesScope.of(context);
    final authController = dependencies.authController;
    final adzanController = dependencies.adzanController;
    final audioController = dependencies.audioController;
    final state = authController.state;

    if (adzanController.locationLabel != state.currentLocation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        adzanController.syncLocation(state.currentLocation);
      });
    }

    return Scaffold(
      body: AnimatedBuilder(
        animation:
            Listenable.merge(<Listenable>[authController, adzanController]),
        builder: (context, _) {
          return StreamBuilder<DateTime>(
            stream: Stream<DateTime>.periodic(
              const Duration(seconds: 1),
              (_) => DateTime.now().toUtc(),
            ),
            builder: (context, snapshot) {
              final nowUtc = snapshot.data ?? DateTime.now().toUtc();
              final prayerSnapshot = adzanController.snapshotFor(
                locationLabel: authController.state.currentLocation,
                nowUtc: nowUtc,
              );

              return SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Expanded(
                          child: Text(
                            'Adzan',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.8,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context)
                              .pushNamed(RouteNames.adzanAlert),
                          icon: const Icon(Icons.notifications_active_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${prayerSnapshot.location.label} • ${prayerSnapshot.nextPrayer.name} berikutnya dalam ${prayerSnapshot.remaining.inMinutes} menit',
                      style: const TextStyle(
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (adzanController.error != null) ...<Widget>[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.errorSoft.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          adzanController.error!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    _QiblaCompassCard(snapshot: prayerSnapshot),
                    const SizedBox(height: 16),
                    _LocationCard(
                      currentLocation: authController.state.currentLocation,
                      onAutoDetect: () async {
                        final permissionMessage =
                            await authController.enableLocation();
                        final gpsMessage = await adzanController
                            .detectAndSyncCurrentLocation();
                        if (!context.mounted) return;
                        context.showAppSnack(
                          gpsMessage ??
                              permissionMessage ??
                              'Lokasi berhasil diperbarui.',
                        );
                      },
                      onLocationChanged: (value) {
                        authController.updateLocation(value);
                        adzanController.syncLocation(value);
                      },
                      onManualLocationChanged: (value) async {
                        final message =
                            await adzanController.syncCustomLocation(
                          value,
                        );
                        authController
                            .updateLocation(adzanController.locationLabel);
                        if (!context.mounted || message == null) return;
                        context.showAppSnack(message);
                      },
                    ),
                    const SizedBox(height: 16),
                    _SchedulingCard(
                      controller: adzanController,
                      onPreviewRegular: () {
                        audioController
                            .playAdhanAsset(adzanController.regularSound)
                            .then((_) {
                          if (!context.mounted) return;
                          context.showAppSnack(
                            audioController.error ??
                                'Preview adzan reguler diputar.',
                          );
                        });
                      },
                      onPreviewFajr: () {
                        audioController
                            .playAdhanAsset(adzanController.fajrSound)
                            .then((_) {
                          if (!context.mounted) return;
                          context.showAppSnack(
                            audioController.error ??
                                'Preview adzan Subuh diputar.',
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    ...prayerSnapshot.prayers.map(
                      (prayer) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PrayerTile(
                          prayer: prayer,
                          enabled: adzanController.prayerEnabled(prayer.name),
                          onToggle: (value) => adzanController.setPrayerEnabled(
                              prayer.name, value),
                          onTest: () {
                            final sound = prayer.name == 'Subuh'
                                ? adzanController.fajrSound
                                : adzanController.regularSound;
                            audioController.playAdhanAsset(sound).then((_) {
                              if (!context.mounted) return;
                              context.showAppSnack(
                                audioController.error ??
                                    'Preview ${prayer.name} diputar.',
                              );
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      label: adzanController.masterEnabled
                          ? 'Jadwalkan Ulang Notifikasi'
                          : 'Aktifkan Notifikasi Adzan',
                      icon: Icons.alarm_rounded,
                      loading: adzanController.scheduling,
                      onPressed: () async {
                        if (!adzanController.masterEnabled) {
                          await adzanController.setMasterEnabled(true);
                        } else {
                          await adzanController.scheduleUpcomingNotifications();
                        }
                        if (!context.mounted) return;
                        context.showAppSnack(
                          'Jadwal adzan lokal diperbarui untuk beberapa hari ke depan.',
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _LocationCard extends StatefulWidget {
  const _LocationCard({
    required this.currentLocation,
    required this.onAutoDetect,
    required this.onLocationChanged,
    required this.onManualLocationChanged,
  });

  final String currentLocation;
  final Future<void> Function() onAutoDetect;
  final ValueChanged<String> onLocationChanged;
  final Future<void> Function(String) onManualLocationChanged;

  @override
  State<_LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<_LocationCard> {
  final TextEditingController _manualController = TextEditingController();

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'LOKASI',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: widget.currentLocation,
            decoration: const InputDecoration(
              labelText: 'Pilih kota preset',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            items: AppConstants.popularLocations
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              widget.onLocationChanged(value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _manualController,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              labelText: 'Cari kota, alamat, atau koordinat',
              hintText: 'Contoh: Solo / -7.566, 110.816',
              prefixIcon: Icon(Icons.travel_explore_rounded),
            ),
            onSubmitted: (value) {
              final normalized = value.trim();
              if (normalized.isEmpty) return;
              widget.onManualLocationChanged(normalized);
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final normalized = _manualController.text.trim();
                if (normalized.isEmpty) return;
                widget.onManualLocationChanged(normalized);
              },
              icon: const Icon(Icons.search_rounded),
              label: const Text('Gunakan hasil pencarian manual'),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: widget.onAutoDetect,
            icon: const Icon(Icons.my_location_rounded),
            label: const Text('Deteksi Otomatis'),
          ),
        ],
      ),
    );
  }
}

class _SchedulingCard extends StatelessWidget {
  const _SchedulingCard({
    required this.controller,
    required this.onPreviewRegular,
    required this.onPreviewFajr,
  });

  final AdzanController controller;
  final VoidCallback onPreviewRegular;
  final VoidCallback onPreviewFajr;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'PENGATURAN NOTIFIKASI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Switch(
                value: controller.masterEnabled,
                onChanged: controller.setMasterEnabled,
              ),
            ],
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: controller.regularSound,
            decoration: const InputDecoration(
              labelText: 'Suara Adzan Reguler',
              prefixIcon: Icon(Icons.music_note_rounded),
            ),
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
              controller.setRegularSound(value);
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onPreviewRegular,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Tes reguler'),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: controller.fajrSound,
            decoration: const InputDecoration(
              labelText: 'Suara Subuh',
              prefixIcon: Icon(Icons.dark_mode_outlined),
            ),
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
              controller.setFajrSound(value);
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onPreviewFajr,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Tes subuh'),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Offset ${controller.offsetMinutes} menit',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Slider(
            value: controller.offsetMinutes.toDouble(),
            min: -10,
            max: 10,
            divisions: 20,
            label: '${controller.offsetMinutes}',
            onChanged: (value) => controller.setOffsetMinutes(value.round()),
          ),
          Text(
            'Pre-reminder ${controller.preReminderMinutes} menit',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Slider(
            value: controller.preReminderMinutes.toDouble(),
            min: 0,
            max: 30,
            divisions: 6,
            label: '${controller.preReminderMinutes}',
            onChanged: (value) =>
                controller.setPreReminderMinutes(value.round()),
          ),
          Text(
            'Volume tes ${(controller.volume * 100).round()}%',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Slider(
            value: controller.volume,
            min: 0.2,
            max: 1.0,
            divisions: 8,
            onChanged: controller.setVolume,
          ),
        ],
      ),
    );
  }
}

class _QiblaCompassCard extends StatelessWidget {
  const _QiblaCompassCard({
    required this.snapshot,
  });

  final PrayerSnapshotModel snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(28),
      ),
      child: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, compassSnapshot) {
          final heading = compassSnapshot.data?.heading ?? 0;
          final qiblaAngle = (snapshot.qiblaBearing - heading + 360) % 360;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'KIBLAT REALTIME',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                      ),
                      Transform.rotate(
                        angle: qiblaAngle * math.pi / 180,
                        child: const Icon(
                          Icons.navigation_rounded,
                          size: 110,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Arah kiblat ${snapshot.qiblaBearing.toStringAsFixed(0)}° • arah perangkat ${heading.toStringAsFixed(0)}°',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${snapshot.distanceToMakkahKm.toStringAsFixed(0)} km menuju Makkah',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
