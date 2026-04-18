import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../di/injection.dart';
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
      'badge': 'SPIRITUAL ACCURACY',
      'title': 'Adzan tepat waktu',
      'description':
          'Stay connected to your prayers with precise notifications and a calm, elegant rhythm throughout the day.',
      'emoji': '🕌',
      'accent': 'Fajr • 04:32',
    },
    {
      'badge': 'QURAN EXPERIENCE',
      'title': 'Baca Al-Qur\'an nyaman',
      'description':
          'Experience a clean and distraction-free reading environment designed for reflection and consistency.',
      'emoji': '📖',
      'accent': 'Last read • Al-Kahf',
    },
    {
      'badge': 'QUIET REFLECTION',
      'title': 'Ibadah lebih terarah',
      'description':
          'Everything you need for your spiritual journey in one focused, polished, and serene application.',
      'emoji': '✨',
      'accent': 'Ramadan • Crafted with intention',
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
                  const Text(
                    'Muslimku',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      authController.completeOnboarding();
                    },
                    child: const Text('Skip'),
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
                      imageEmoji: page['emoji']!,
                      accentLabel: page['accent']!,
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
                label: _index == _pages.length - 1 ? 'Get Started' : 'Next',
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
