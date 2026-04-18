class ReadingProgressModel {
  const ReadingProgressModel({
    required this.surahNumber,
    required this.surahName,
    required this.surahArabic,
    required this.ayahNumber,
    required this.verseKey,
    required this.updatedAtEpochMs,
  });

  final int surahNumber;
  final String surahName;
  final String surahArabic;
  final int ayahNumber;
  final String verseKey;
  final int updatedAtEpochMs;

  factory ReadingProgressModel.fromJson(Map<String, dynamic> json) {
    return ReadingProgressModel(
      surahNumber: (json['surahNumber'] ?? 0) as int,
      surahName: (json['surahName'] ?? '') as String,
      surahArabic: (json['surahArabic'] ?? '') as String,
      ayahNumber: (json['ayahNumber'] ?? 0) as int,
      verseKey: (json['verseKey'] ?? '') as String,
      updatedAtEpochMs: (json['updatedAtEpochMs'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'surahNumber': surahNumber,
      'surahName': surahName,
      'surahArabic': surahArabic,
      'ayahNumber': ayahNumber,
      'verseKey': verseKey,
      'updatedAtEpochMs': updatedAtEpochMs,
    };
  }
}
