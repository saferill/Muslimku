class TafsirEntryModel {
  const TafsirEntryModel({
    required this.surahNumber,
    required this.ayahNumber,
    required this.text,
  });

  final int surahNumber;
  final int ayahNumber;
  final String text;

  String get verseKey => '$surahNumber:$ayahNumber';

  factory TafsirEntryModel.fromJson(
    int surahNumber,
    Map<String, dynamic> json,
  ) {
    return TafsirEntryModel(
      surahNumber: surahNumber,
      ayahNumber: (json['ayat'] ?? json['nomorAyat'] ?? 0) as int,
      text: (json['teks'] ?? json['text'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'text': text,
    };
  }
}
