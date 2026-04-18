import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../di/injection.dart';
import '../../../shared/widgets/brand/muslimku_logo.dart';
import '../../../shared/widgets/buttons/primary_button.dart';
import '../widgets/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _index = 0;

  static const _pages = <Map<String, String>>[
    {
      'badge': 'JADWAL SALAT',
      'title': 'Adzan tepat waktu',
      'description':
          'Notifikasi yang lebih tenang dan fokus untuk membantu kamu menjaga ritme ibadah harian.',
      'accent': 'Subuh • 04:32',
      'panelTitle': 'Jadwal salat yang terarah',
      'panelSubtitle':
          'Pantau waktu salat, hitung mundur, dan pengingat adzan dari satu tempat.',
    },
    {
      'badge': 'PENGALAMAN QURAN',
      'title': 'Baca Al-Qur\'an nyaman',
      'description':
          'Lingkungan baca yang bersih dan fokus agar murajaah, tafsir, dan audio terasa lebih nyaman.',
      'accent': 'Bacaan terakhir • Al-Kahf',
      'panelTitle': 'Reader yang tenang',
      'panelSubtitle':
          'Lanjutkan bacaan terakhir, simpan bookmark, dan dengarkan murottal saat dibutuhkan.',
    },
    {
      'badge': 'REFLEKSI HARIAN',
      'title': 'Ibadah lebih terarah',
      'description':
          'Satu aplikasi untuk salat, Al-Qur\'an, audio, dan pengaturan spiritual yang lebih rapi.',
      'accent': 'Ramadan • Dirancang dengan niat baik',
      'panelTitle': 'Satu ruang ibadah digital',
      'panelSubtitle':
          'Dirancang untuk menemani kebiasaan ibadah sehari-hari dengan tampilan yang lebih hangat.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final authController = AppDependenciesScope.of(context).authController;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const MuslimkuBrand(
                    logoSize: 34,
                    textSize: 24,
                  ),
                  TextButton(
                    onPressed: authController.completeOnboarding,
                    child: const Text('Lewati'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return OnboardingPage(
                      badge: page['badge']!,
                      title: page['title']!,
                      description: page['description']!,
                      accentLabel: page['accent']!,
                      panelTitle: page['panelTitle']!,
                      panelSubtitle: page['panelSubtitle']!,
                      icon: switch (index) {
                        0 => Icons.schedule_rounded,
                        1 => Icons.menu_book_rounded,
                        _ => Icons.auto_awesome_rounded,
                      },
                      accentColor: switch (index) {
                        0 => AppColors.primary,
                        1 => AppColors.secondary,
                        _ => AppColors.tertiary,
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: List<Widget>.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    margin: const EdgeInsets.only(right: 8),
                    height: 8,
                    width: _index == index ? 34 : 8,
                    decoration: BoxDecoration(
                      color: _index == index
                          ? AppColors.primary
                          : AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: _index == _pages.length - 1 ? 'Mulai' : 'Lanjut',
                icon: Icons.arrow_forward,
                onPressed: () {
                  if (_index == _pages.length - 1) {
                    authController.completeOnboarding();
                    return;
                  }
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
