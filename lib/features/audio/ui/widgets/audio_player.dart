import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';

class AudioPlayerCard extends StatelessWidget {
  const AudioPlayerCard({
    super.key,
    required this.title,
    required this.artist,
    required this.isPlaying,
    required this.progress,
    required this.speed,
    required this.shuffleEnabled,
    required this.repeatEnabled,
    required this.sleepLabel,
    required this.onToggle,
    required this.onSeek,
    required this.onNext,
    required this.onPrevious,
    required this.onSpeedSelected,
    required this.onShuffleToggle,
    required this.onRepeatToggle,
    required this.onSleepSelected,
    required this.onMinimize,
    required this.onStop,
  });

  final String title;
  final String artist;
  final bool isPlaying;
  final double progress;
  final double speed;
  final bool shuffleEnabled;
  final bool repeatEnabled;
  final String sleepLabel;
  final VoidCallback onToggle;
  final ValueChanged<double> onSeek;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final ValueChanged<double> onSpeedSelected;
  final ValueChanged<bool> onShuffleToggle;
  final ValueChanged<bool> onRepeatToggle;
  final ValueChanged<Duration?> onSleepSelected;
  final VoidCallback onMinimize;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: <Widget>[
          Container(
            height: 240,
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Center(
              child: Icon(
                Icons.graphic_eq_rounded,
                size: 90,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            artist,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.primary),
          ),
          const SizedBox(height: 18),
          Slider(
            value: progress.clamp(0, 1),
            onChanged: onSeek,
            activeColor: AppColors.primary,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              PopupMenuButton<double>(
                onSelected: onSpeedSelected,
                itemBuilder: (context) {
                  const values = <double>[0.75, 1.0, 1.25, 1.5];
                  return values
                      .map(
                        (value) => PopupMenuItem<double>(
                          value: value,
                          child: Text('${value.toStringAsFixed(2)}x'),
                        ),
                      )
                      .toList();
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.speed_rounded),
                    const SizedBox(height: 4),
                    Text('${speed.toStringAsFixed(2)}x'),
                  ],
                ),
              ),
              IconButton(
                onPressed: onPrevious,
                icon: const Icon(Icons.skip_previous_rounded, size: 34),
              ),
              Container(
                width: 82,
                height: 82,
                decoration: const BoxDecoration(
                  gradient: AppColors.heroGradient,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
              ),
              IconButton(
                onPressed: onNext,
                icon: const Icon(Icons.skip_next_rounded, size: 34),
              ),
              IconButton(
                onPressed: onStop,
                icon: const Icon(Icons.stop_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: FilterChip(
                  label: const Text('Acak'),
                  selected: shuffleEnabled,
                  onSelected: onShuffleToggle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilterChip(
                  label: const Text('Ulangi'),
                  selected: repeatEnabled,
                  onSelected: onRepeatToggle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: PopupMenuButton<Duration?>(
                  onSelected: onSleepSelected,
                  itemBuilder: (context) => const <PopupMenuEntry<Duration?>>[
                    PopupMenuItem<Duration?>(
                      value: Duration(minutes: 15),
                      child: Text('Tidur 15 menit'),
                    ),
                    PopupMenuItem<Duration?>(
                      value: Duration(minutes: 30),
                      child: Text('Tidur 30 menit'),
                    ),
                    PopupMenuItem<Duration?>(
                      value: Duration(minutes: 60),
                      child: Text('Tidur 60 menit'),
                    ),
                    PopupMenuItem<Duration?>(
                      value: null,
                      child: Text('Matikan Timer Tidur'),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLow,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.nightlight_round_rounded),
                        const SizedBox(width: 8),
                        Expanded(child: Text(sleepLabel)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onMinimize,
                  icon: const Icon(Icons.expand_more_rounded),
                  label: const Text('Minimalkan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
