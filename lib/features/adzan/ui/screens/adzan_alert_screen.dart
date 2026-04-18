import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

class AdzanAlertScreen extends StatefulWidget {
  const AdzanAlertScreen({
    super.key,
    this.payload,
  });

  final String? payload;

  @override
  State<AdzanAlertScreen> createState() => _AdzanAlertScreenState();
}

class _AdzanAlertScreenState extends State<AdzanAlertScreen> {
  bool _muted = false;

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependenciesScope.of(context);
    final prayerName = _prayerNameFromPayload(widget.payload);
    final location = dependencies.authController.state.currentLocation;
    final timeLabel = TimeOfDay.now().format(context);
    final isReminder = (widget.payload ?? '').startsWith('reminder:');

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Color(0xFF193B29),
              Color(0xFF0E1C15),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 32),
                Text(
                  isReminder ? 'PENGINGAT SALAT' : 'WAKTU ADZAN',
                  style: const TextStyle(
                    color: AppColors.tertiarySoft,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  prayerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 54,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$location • $timeLabel',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primarySoft.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _muted
                        ? Icons.volume_off_rounded
                        : Icons.notifications_active_rounded,
                    color: AppColors.primarySoft,
                    size: 54,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  prayerName == 'Subuh'
                      ? '"Salat lebih baik daripada tidur."'
                      : '"Mari menuju salat, mari menuju kemenangan."',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _muted
                      ? 'Suara adzan sudah dibisukan. Kamu masih bisa membuka aplikasi atau menunda pengingat.'
                      : 'Ambil jeda sejenak untuk kembali menenangkan hati dan menyiapkan diri menuju salat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 15,
                    height: 1.55,
                  ),
                ),
                const Spacer(),
                PrimaryButton(
                  label: 'Tunda 5 Menit',
                  icon: Icons.snooze_rounded,
                  onPressed: () async {
                    await dependencies.adzanController.stopActiveAlert();
                    await dependencies.adzanController.snoozePrayerAlert(
                      prayerName: prayerName,
                    );
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: PrimaryButton(
                        label: _muted ? 'Sudah Dibisukan' : 'Bisukan',
                        isSecondary: true,
                        icon: Icons.volume_off_rounded,
                        onPressed: _muted
                            ? null
                            : () async {
                                await dependencies.adzanController
                                    .stopActiveAlert();
                                if (!mounted) return;
                                setState(() => _muted = true);
                                context.showAppSnack(
                                  'Suara adzan dibisukan untuk alert ini.',
                                );
                              },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Berhenti',
                        isSecondary: true,
                        icon: Icons.stop_circle_outlined,
                        onPressed: () async {
                          await dependencies.adzanController.stopActiveAlert();
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Buka Aplikasi',
                  isSecondary: true,
                  icon: Icons.open_in_new_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 20),
                Text(
                  'Geser ke atas untuk menutup layar ini',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    letterSpacing: 1.2,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _prayerNameFromPayload(String? value) {
    if ((value ?? '').isEmpty) return 'Waktu Salat';
    final parts = value!.split(':');
    if (parts.length < 2) return 'Waktu Salat';
    return parts[1];
  }
}
