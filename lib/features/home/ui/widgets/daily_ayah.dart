import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/colors.dart';
import '../../../quran/data/models/ayah_model.dart';
import '../../../quran/data/models/surah_model.dart';

class DailyAyahCard extends StatelessWidget {
  const DailyAyahCard({
    super.key,
    this.ayah,
    this.surah,
    this.bookmarked = false,
    this.onOpen,
    this.onBookmark,
    this.onShare,
  });

  final AyahModel? ayah;
  final SurahModel? surah;
  final bool bookmarked;
  final VoidCallback? onOpen;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final hasData = ayah != null && surah != null;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -6,
            top: -8,
            child: Icon(
              Icons.format_quote_rounded,
              size: 90,
              color: AppColors.tertiary.withValues(alpha: 0.06),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'DAILY AYAH',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                        color: AppColors.tertiary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onBookmark,
                    icon: Icon(
                      bookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                hasData ? ayah!.translation : AppConstants.dailyAyah,
                style: const TextStyle(
                  fontSize: 20,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hasData ? '${surah!.name} ${ayah!.number}' : 'Al-Baqarah 2:152',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              if (onOpen != null) ...<Widget>[
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    TextButton.icon(
                      onPressed: onOpen,
                      icon: const Icon(Icons.menu_book_rounded),
                      label: const Text('Buka Reader'),
                    ),
                    const SizedBox(width: 8),
                    if (onShare != null)
                      TextButton.icon(
                        onPressed: onShare,
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('Bagikan'),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
