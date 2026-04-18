import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/utils/helpers.dart';
import '../../../../di/injection.dart';
import '../../data/models/ayah_model.dart';
import '../../data/models/surah_model.dart';
import '../widgets/ayah_tile.dart';
import '../widgets/reader_controls.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({
    super.key,
    this.surah,
  });

  final SurahModel? surah;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  bool _requested = false;
  bool _showTranslation = true;
  bool _showTafsir = false;
  double _fontScale = 1.0;
  bool _initializedReaderSettings = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initializedReaderSettings) return;
    final authState = AppDependenciesScope.of(context).authController.state;
    _showTranslation = authState.readerShowTranslation;
    _showTafsir = authState.readerShowTafsir;
    _fontScale = authState.readerFontScale;
    _initializedReaderSettings = true;
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependenciesScope.of(context);
    final authController = dependencies.authController;
    final authState = authController.state;
    final quranController = dependencies.quranController;
    final audioController = dependencies.audioController;
    final current = widget.surah ??
        (quranController.surahs().isNotEmpty
            ? quranController.surahs().first
            : null);

    if (!_requested && current != null) {
      _requested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        quranController.ensureSurahLoaded(current.number);
      });
    }

    final ayahs =
        current == null ? const [] : quranController.ayahsFor(current.number);

    return Scaffold(
      appBar: AppBar(title: Text(current?.name ?? 'Reader Qur\'an')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: <Widget>[
            ReaderControls(
              showTranslation: _showTranslation,
              showTafsir: _showTafsir,
              fontScale: _fontScale,
              onToggleTranslation: (value) {
                setState(() => _showTranslation = value);
                authController.updateReaderShowTranslation(value);
              },
              onToggleTafsir: (value) {
                setState(() => _showTafsir = value);
                authController.updateReaderShowTafsir(value);
              },
              onFontScaleChanged: (value) {
                setState(() => _fontScale = value);
                authController.updateReaderFontScale(value);
              },
              onPlayAll: current == null
                  ? () {}
                  : () =>
                      audioController.playSurah(surahNumber: current.number),
            ),
            const SizedBox(height: 18),
            if (quranController.error != null && ayahs.isEmpty)
              Column(
                children: <Widget>[
                  Text(
                    quranController.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: current == null
                        ? null
                        : () =>
                            quranController.ensureSurahLoaded(current.number),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              )
            else if (ayahs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              ...ayahs.map(
                (ayah) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AyahTile(
                    ayah: ayah,
                    bookmarked: quranController.isBookmarked(ayah.verseKey),
                    highlighted: quranController.isHighlighted(ayah.verseKey),
                    note: quranController.noteFor(ayah.verseKey),
                    fontScale: _fontScale,
                    showTranslation: _showTranslation,
                    showTafsir: _showTafsir,
                    translationText:
                        _translationForAyah(ayah, authState.translation),
                    onBookmark: current == null
                        ? () {}
                        : () => quranController.toggleBookmark(
                              surah: current,
                              ayah: ayah,
                            ),
                    onPlay: () {
                      audioController.playAyah(ayah);
                      if (current != null) {
                        quranController.markLastRead(
                            surah: current, ayah: ayah);
                      }
                    },
                    onCopy: () async {
                      await Clipboard.setData(
                        ClipboardData(
                          text:
                              '${ayah.arabic}\n${_translationForAyah(ayah, authState.translation)}\n(${ayah.verseKey})',
                        ),
                      );
                      if (!context.mounted) return;
                      context.showAppSnack('Ayat disalin.');
                    },
                    onShare: () async {
                      await SharePlus.instance.share(
                        ShareParams(
                          text:
                              '${ayah.arabic}\n${_translationForAyah(ayah, authState.translation)}\n${current?.name ?? ayah.surahName} ${ayah.number} (${ayah.verseKey})',
                        ),
                      );
                    },
                    onHighlight: () async {
                      final highlighted = await quranController.toggleHighlight(
                        ayah.verseKey,
                      );
                      if (!context.mounted) return;
                      context.showAppSnack(
                        highlighted
                            ? 'Ayat ditandai.'
                            : 'Tanda highlight dihapus.',
                      );
                    },
                    onNote: () async {
                      final note = await _openNoteDialog(
                        context: context,
                        initialValue: quranController.noteFor(ayah.verseKey),
                      );
                      if (note == null) return;
                      await quranController.saveNote(
                        verseKey: ayah.verseKey,
                        note: note,
                      );
                      if (!context.mounted) return;
                      context.showAppSnack(
                        note.trim().isEmpty
                            ? 'Catatan dihapus.'
                            : 'Catatan disimpan.',
                      );
                    },
                    onOpen: current == null
                        ? null
                        : () => quranController.markLastRead(
                              surah: current,
                              ayah: ayah,
                            ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<String?> _openNoteDialog({
    required BuildContext context,
    required String initialValue,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Catatan Ayat'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Tulis refleksi atau catatanmu...',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(''),
              child: const Text('Hapus'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return result;
  }

  String _translationForAyah(AyahModel ayah, String translationPreference) {
    if (translationPreference == 'English (Muhammad Asad)' &&
        (ayah.translationEnglish ?? '').trim().isNotEmpty) {
      return ayah.translationEnglish!;
    }
    return ayah.translation;
  }
}
