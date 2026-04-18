import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/colors.dart';
import '../../shared/widgets/brand/muslimku_logo.dart';
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
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: AppColors.tertiarySoft.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -100,
              bottom: -120,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft.withValues(alpha: 0.08),
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
                      width: 178,
                      height: 178,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(48),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 36,
                            offset: Offset(0, 20),
                          ),
                        ],
                      ),
                      child: const MuslimkuLogo(
                        size: 154,
                        padding: 8,
                        radius: 36,
                        backgroundColor: Colors.white,
                        borderColor: Colors.transparent,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const MuslimkuBrand(
                      center: true,
                      logoSize: 42,
                      textColor: Colors.white,
                      textSize: 38,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sahabat ibadah digital untuk adzan, Al-Qur\'an, dan perjalanan spiritual yang lebih terarah.',
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
                      '${AppConstants.appVersion} • 14 Ramadan 1445 AH',
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
