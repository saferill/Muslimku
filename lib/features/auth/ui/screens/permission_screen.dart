import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../di/injection.dart';
import '../../../../shared/widgets/brand/muslimku_logo.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/cards/glass_card.dart';

class RouteAwarePermissionScreen extends StatelessWidget {
  const RouteAwarePermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = AppDependenciesScope.of(context).authController;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(color: AppColors.background),
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: AppColors.primarySoft.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: AppColors.tertiarySoft.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: <Widget>[
                  Row(
                    children: const <Widget>[
                      MuslimkuBrand(
                        logoSize: 34,
                        textSize: 24,
                      ),
                    ],
                  ),
                  const Spacer(),
                  GlassCard(
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: const <Widget>[
                            _PermissionMiniCard(
                              color: AppColors.primary,
                              icon: Icons.location_on_outlined,
                              label: 'Lokasi',
                            ),
                            SizedBox(width: 12),
                            _PermissionMiniCard(
                              color: AppColors.tertiary,
                              icon: Icons.notifications_active_outlined,
                              label: 'Notifikasi',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Siapkan pengalaman ibadahmu',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            height: 1.12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Agar jadwal salat, arah kiblat, dan pengingat adzan bekerja dengan akurat, Muslimku memerlukan akses lokasi dan notifikasi.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.55,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLow,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Column(
                            children: <Widget>[
                              _PermissionReasonRow(
                                icon: Icons.schedule_rounded,
                                title: 'Jadwal lebih akurat',
                                subtitle:
                                    'Lokasi membantu Muslimku menghitung waktu salat sesuai tempatmu berada.',
                              ),
                              SizedBox(height: 12),
                              _PermissionReasonRow(
                                icon: Icons.alarm_rounded,
                                title: 'Pengingat tetap berjalan',
                                subtitle:
                                    'Notifikasi dipakai untuk adzan, reminder awal, dan refleksi ayat harian.',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          label: 'Aktifkan Lokasi',
                          icon: Icons.near_me_outlined,
                          onPressed: () async {
                            final message =
                                await authController.enableLocation();
                            if (context.mounted && message != null) {
                              context.showAppSnack(message);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        PrimaryButton(
                          label: 'Aktifkan Notifikasi',
                          icon: Icons.notifications_outlined,
                          isSecondary: true,
                          onPressed: () async {
                            final message =
                                await authController.enableNotifications();
                            if (context.mounted && message != null) {
                              context.showAppSnack(message);
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: authController.markPermissionsSeen,
                          child: const Text('Lanjut tanpa izin dulu'),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionMiniCard extends StatelessWidget {
  const _PermissionMiniCard({
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: <Widget>[
            Icon(icon, color: color, size: 34),
            const SizedBox(height: 10),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionReasonRow extends StatelessWidget {
  const _PermissionReasonRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
