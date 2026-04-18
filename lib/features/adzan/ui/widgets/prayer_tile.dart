import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../data/models/prayer_time_model.dart';

class PrayerTile extends StatelessWidget {
  const PrayerTile({
    super.key,
    required this.prayer,
    required this.enabled,
    required this.onToggle,
    this.onTest,
  });

  final PrayerTimeModel prayer;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onTest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: prayer.isActive ? Colors.white : AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(24),
        border: prayer.isActive
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.2))
            : null,
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 24,
            backgroundColor: prayer.isActive
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.surfaceHigh,
            child: Icon(
              prayer.icon,
              color:
                  prayer.isActive ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  prayer.name,
                  style: TextStyle(
                    fontSize: prayer.isActive ? 20 : 18,
                    fontWeight: FontWeight.w800,
                    color: prayer.isActive
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  prayer.formatted,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              if (onTest != null)
                IconButton(
                  onPressed: onTest,
                  icon: const Icon(Icons.volume_up_rounded),
                  tooltip: 'Tes suara',
                ),
              Switch(
                value: enabled,
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.28),
                onChanged: onToggle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
