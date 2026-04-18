class SearchResultModel {
  const SearchResultModel({
    required this.type,
    required this.score,
    required this.relevance,
    required this.surahNumber,
    required this.surahName,
    required this.surahArabic,
    required this.ayahNumber,
    this.arabic,
    this.transliteration,
    this.translation,
    this.translationEnglish,
    this.tafsirText,
  });

  final String type;
  final double score;
  final String relevance;
  final int surahNumber;
  final String surahName;
  final String surahArabic;
  final int ayahNumber;
  final String? arabic;
  final String? transliteration;
  final String? translation;
  final String? translationEnglish;
  final String? tafsirText;

  String get verseKey => '$surahNumber:$ayahNumber';

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(
      (json['data'] ?? json['ayat'] ?? json) as Map,
    );
    return SearchResultModel(
      type: (json['tipe'] ?? '') as String,
      score: _toDouble(json['skor']),
      relevance: (json['relevansi'] ?? '') as String,
      surahNumber: _toInt(data['id_surat']),
      surahName: (data['nama_surat'] ?? '') as String,
      surahArabic: (data['nama_surat_arab'] ?? '') as String,
      ayahNumber: _toInt(data['nomor_ayat']),
      arabic: data['teks_arab'] as String?,
      transliteration: data['teks_latin'] as String?,
      translation: data['terjemahan_id'] as String?,
      translationEnglish: data['terjemahan_en'] as String?,
      tafsirText: data['isi'] as String?,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }
}
