import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../data/models/ayah_model.dart';

class AyahTile extends StatelessWidget {
  const AyahTile({
    super.key,
    required this.ayah,
    required this.bookmarked,
    required this.highlighted,
    required this.note,
    required this.fontScale,
    required this.showTranslation,
    required this.showTafsir,
    required this.onBookmark,
    required this.onPlay,
    required this.onCopy,
    required this.onShare,
    required this.onHighlight,
    required this.onNote,
    this.onOpen,
  });

  final AyahModel ayah;
  final bool bookmarked;
  final bool highlighted;
  final String note;
  final double fontScale;
  final bool showTranslation;
  final bool showTafsir;
  final VoidCallback onBookmark;
  final VoidCallback onPlay;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onHighlight;
  final VoidCallback onNote;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: highlighted
              ? AppColors.tertiarySoft.withValues(alpha: 0.18)
              : Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: highlighted
              ? Border.all(
                  color: AppColors.tertiary.withValues(alpha: 0.25),
                  width: 1.2,
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    '${ayah.number}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onPlay,
                  icon: const Icon(Icons.play_circle_outline_rounded),
                ),
                IconButton(
                  onPressed: onCopy,
                  icon: const Icon(Icons.copy_rounded),
                ),
                IconButton(
                  onPressed: onBookmark,
                  icon: Icon(
                    bookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                ayah.arabic,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 26 * fontScale,
                  height: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (ayah.transliteration.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                ayah.transliteration,
                style: const TextStyle(
                  height: 1.5,
                  color: AppColors.secondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (showTranslation) ...<Widget>[
              const SizedBox(height: 14),
              Text(
                ayah.translation,
                style: const TextStyle(
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (showTafsir &&
                (ayah.tafsir ?? '').trim().isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLow,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  ayah.tafsir!,
                  style: const TextStyle(
                    height: 1.55,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
            if (note.trim().isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  note,
                  style: const TextStyle(
                    height: 1.55,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                ActionChip(
                  label: const Text('Share'),
                  avatar: const Icon(Icons.share_rounded, size: 18),
                  onPressed: onShare,
                ),
                ActionChip(
                  label: Text(highlighted ? 'Unhighlight' : 'Highlight'),
                  avatar: Icon(
                    highlighted
                        ? Icons.highlight_remove_rounded
                        : Icons.highlight_alt_rounded,
                    size: 18,
                  ),
                  onPressed: onHighlight,
                ),
                ActionChip(
                  label: Text(note.trim().isEmpty ? 'Add Note' : 'Edit Note'),
                  avatar: const Icon(Icons.edit_note_rounded, size: 18),
                  onPressed: onNote,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
