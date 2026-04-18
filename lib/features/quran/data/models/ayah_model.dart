class AyahModel {
  const AyahModel({
    required this.surahNumber,
    required this.surahName,
    required this.number,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    this.translationEnglish,
    this.audioUrls = const <String, String>{},
    this.tafsir,
  });

  final int surahNumber;
  final String surahName;
  final int number;
  final String arabic;
  final String transliteration;
  final String translation;
  final String? translationEnglish;
  final Map<String, String> audioUrls;
  final String? tafsir;

  String get verseKey => '$surahNumber:$number';

  factory AyahModel.fromJson({
    required int surahNumber,
    required String surahName,
    required Map<String, dynamic> json,
    String? tafsir,
  }) {
    final rawAudio =
        (json['audio'] ?? json['audioUrls'] ?? const <String, dynamic>{}) as Map;
    return AyahModel(
      surahNumber: surahNumber,
      surahName: surahName,
      number: _toInt(json['nomorAyat'] ?? json['number']),
      arabic: (json['teksArab'] ?? json['arabic'] ?? '') as String,
      transliteration:
          (json['teksLatin'] ?? json['transliteration'] ?? '') as String,
      translation:
          (json['teksIndonesia'] ?? json['translation'] ?? '') as String,
      translationEnglish:
          (json['terjemahan_en'] ?? json['translationEnglish']) as String?,
      audioUrls: rawAudio.map(
        (key, value) => MapEntry('$key', '$value'),
      ),
      tafsir: tafsir,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'surahNumber': surahNumber,
      'surahName': surahName,
      'number': number,
      'arabic': arabic,
      'transliteration': transliteration,
      'translation': translation,
      'translationEnglish': translationEnglish,
      'audioUrls': audioUrls,
      'tafsir': tafsir,
    };
  }

  String? audioUrlForReciter(String reciterId) {
    final exact = audioUrls[reciterId];
    if ((exact ?? '').isNotEmpty) return exact;
    for (final url in audioUrls.values) {
      if (url.isNotEmpty) return url;
    }
    return null;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}
