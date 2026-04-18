import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';

class ReaderControls extends StatelessWidget {
  const ReaderControls({
    super.key,
    required this.showTranslation,
    required this.showTafsir,
    required this.fontScale,
    required this.onToggleTranslation,
    required this.onToggleTafsir,
    required this.onFontScaleChanged,
    required this.onPlayAll,
  });

  final bool showTranslation;
  final bool showTafsir;
  final double fontScale;
  final ValueChanged<bool> onToggleTranslation;
  final ValueChanged<bool> onToggleTafsir;
  final ValueChanged<double> onFontScaleChanged;
  final VoidCallback onPlayAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Kontrol Reader',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              TextButton.icon(
                onPressed: onPlayAll,
                icon: const Icon(Icons.play_circle_fill_rounded),
                label: const Text('Putar Semua'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: showTranslation,
            onChanged: onToggleTranslation,
            contentPadding: EdgeInsets.zero,
            title: const Text('Tampilkan Terjemahan'),
          ),
          SwitchListTile(
            value: showTafsir,
            onChanged: onToggleTafsir,
            contentPadding: EdgeInsets.zero,
            title: const Text('Tampilkan Tafsir'),
          ),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              const Icon(Icons.format_size_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              const Text('Ukuran Font Arab'),
              Expanded(
                child: Slider(
                  value: fontScale,
                  min: 0.9,
                  max: 1.6,
                  divisions: 7,
                  onChanged: onFontScaleChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
