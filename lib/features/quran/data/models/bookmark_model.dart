class BookmarkModel {
  const BookmarkModel({
    required this.verseKey,
    required this.surahNumber,
    required this.surahName,
    required this.surahArabic,
    required this.ayahNumber,
    required this.arabic,
    required this.translation,
    required this.updatedAtEpochMs,
  });

  final String verseKey;
  final int surahNumber;
  final String surahName;
  final String surahArabic;
  final int ayahNumber;
  final String arabic;
  final String translation;
  final int updatedAtEpochMs;

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      verseKey: json['verseKey'] as String,
      surahNumber: (json['surahNumber'] ?? 0) as int,
      surahName: (json['surahName'] ?? '') as String,
      surahArabic: (json['surahArabic'] ?? '') as String,
      ayahNumber: (json['ayahNumber'] ?? 0) as int,
      arabic: (json['arabic'] ?? '') as String,
      translation: (json['translation'] ?? '') as String,
      updatedAtEpochMs: (json['updatedAtEpochMs'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'verseKey': verseKey,
      'surahNumber': surahNumber,
      'surahName': surahName,
      'surahArabic': surahArabic,
      'ayahNumber': ayahNumber,
      'arabic': arabic,
      'translation': translation,
      'updatedAtEpochMs': updatedAtEpochMs,
    };
  }
}
