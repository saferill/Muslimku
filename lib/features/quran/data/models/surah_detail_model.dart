import 'ayah_model.dart';
import 'surah_model.dart';
import 'tafsir_entry_model.dart';

class SurahDetailModel {
  const SurahDetailModel({
    required this.surah,
    required this.ayahs,
    required this.tafsir,
  });

  final SurahModel surah;
  final List<AyahModel> ayahs;
  final List<TafsirEntryModel> tafsir;
}
