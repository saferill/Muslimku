import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../shared/widgets/loaders/orb_loader.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: AppColors.tertiarySoft.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  children: <Widget>[
                    const Spacer(),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.primarySoft,
                        size: 56,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Muslimku',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Digital sanctuary for prayer, Qur\'an, and reflection.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    const OrbLoader(),
                    const SizedBox(height: 18),
                    Text(
                      '14 Ramadan 1445 AH',
                      style: TextStyle(
                        color: AppColors.primarySoft.withValues(alpha: 0.78),
                        fontSize: 11,
                        letterSpacing: 2.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
