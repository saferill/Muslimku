import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
    required this.onOpenQuran,
    required this.onOpenAudio,
    required this.onOpenAdzan,
    required this.onOpenSearch,
  });

  final VoidCallback onOpenQuran;
  final VoidCallback onOpenAudio;
  final VoidCallback onOpenAdzan;
  final VoidCallback onOpenSearch;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _ActionBubble(
          icon: Icons.menu_book_rounded,
          label: 'Qur\'an',
          onTap: onOpenQuran,
        ),
        _ActionBubble(
          icon: Icons.headphones_rounded,
          label: 'Audio',
          onTap: onOpenAudio,
        ),
        _ActionBubble(
          icon: Icons.notifications_active_rounded,
          label: 'Adzan',
          onTap: onOpenAdzan,
        ),
        _ActionBubble(
          icon: Icons.search_rounded,
          label: 'Cari',
          onTap: onOpenSearch,
        ),
      ],
    );
  }
}

class _ActionBubble extends StatelessWidget {
  const _ActionBubble({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 18,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Icon(icon, color: AppColors.primary, size: 30),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
