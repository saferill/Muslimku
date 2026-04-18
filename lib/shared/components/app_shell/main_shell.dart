import 'package:flutter/material.dart';

import '../../../core/constants/colors.dart';
import '../../../features/adzan/ui/screens/adzan_screen.dart';
import '../../../features/audio/ui/screens/audio_screen.dart';
import '../../../features/home/ui/screens/home_screen.dart';
import '../../../features/notification/ui/notification_screen.dart';
import '../../../features/quran/ui/screens/bookmarks_screen.dart';
import '../../../features/quran/ui/screens/quran_screen.dart';
import '../../../features/search/ui/screens/search_screen.dart';
import '../../../features/settings/ui/screens/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        onOpenQuran: () => setState(() => _index = 1),
        onOpenSearch: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
        ),
        onOpenAdzan: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const AdzanScreen()),
        ),
        onOpenAudio: () => setState(() => _index = 2),
        onOpenNotifications: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const NotificationScreen()),
        ),
      ),
      const QuranScreen(),
      const AudioScreen(),
      BookmarksScreen(
        onExploreQuran: () => setState(() => _index = 1),
      ),
      const SettingsScreen(),
    ];

    final items = <({IconData icon, String label})>[
      (icon: Icons.home_rounded, label: 'Beranda'),
      (icon: Icons.menu_book_rounded, label: 'Qur\'an'),
      (icon: Icons.headphones_rounded, label: 'Audio'),
      (icon: Icons.bookmark_rounded, label: 'Bookmark'),
      (icon: Icons.settings_rounded, label: 'Pengaturan'),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(32),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: List<Widget>.generate(
              items.length,
              (index) {
                final item = items[index];
                final selected = _index == index;
                return Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => setState(() => _index = index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary.withValues(alpha: 0.12)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.icon,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
