import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

class AdzanAlertScreen extends StatelessWidget {
  const AdzanAlertScreen({
    super.key,
    this.payload,
  });

  final String? payload;

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependenciesScope.of(context);
    final prayerName = _prayerNameFromPayload(payload);
    final location = dependencies.authController.state.currentLocation;
    final timeLabel = TimeOfDay.now().format(context);

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
                  (payload ?? '').startsWith('reminder:')
                      ? 'PRAYER REMINDER'
                      : 'NOW CALLING TO PRAYER',
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
                    '$location - $timeLabel',
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
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: AppColors.primarySoft,
                    size: 54,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  prayerName == 'Subuh'
                      ? '"Prayer is better than sleep."'
                      : '"Come to prayer, come to success."',
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
                  'Take a moment to reconnect with the Divine and find peace in your heart.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 15,
                    height: 1.55,
                  ),
                ),
                const Spacer(),
                PrimaryButton(
                  label: 'Snooze for 5 mins',
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
                        label: 'Mute',
                        isSecondary: true,
                        icon: Icons.volume_off_rounded,
                        onPressed: () async {
                          await dependencies.adzanController.stopActiveAlert();
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Stop',
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
                  label: 'Open App',
                  isSecondary: true,
                  icon: Icons.open_in_new_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 20),
                Text(
                  'Swipe up to dismiss',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    letterSpacing: 1.6,
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
    if ((value ?? '').isEmpty) return 'Prayer Time';
    final parts = value!.split(':');
    if (parts.length < 2) return 'Prayer Time';
    return parts[1];
  }
}
