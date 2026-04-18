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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const <Widget>[
                      MuslimkuBrand(
                        logoSize: 34,
                        textSize: 24,
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.white70,
                        child: Icon(Icons.person_outline, color: AppColors.primary),
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
                              label: 'Location',
                            ),
                            SizedBox(width: 12),
                            _PermissionMiniCard(
                              color: AppColors.tertiary,
                              icon: Icons.notifications_active_outlined,
                              label: 'Alerts',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Digital Sanctuary',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            height: 1.12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Untuk memberikan jadwal salat dan arah kiblat yang akurat, Muslimku memerlukan akses lokasi dan notifikasi.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.55,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          label: 'Aktifkan Lokasi',
                          icon: Icons.near_me_outlined,
                          onPressed: () async {
                            final message = await authController.enableLocation();
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
                          child: const Text('Nanti saja'),
                        ),
                        const SizedBox(height: 8),
                        PrimaryButton(
                          label: 'Lanjut',
                          onPressed: authController.markPermissionsSeen,
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
