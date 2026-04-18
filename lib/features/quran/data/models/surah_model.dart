class SurahModel {
  const SurahModel({
    required this.number,
    required this.name,
    required this.meaning,
    required this.arabic,
    required this.ayahCount,
    required this.origin,
    this.description = '',
    this.fullAudioUrls = const <String, String>{},
  });

  final int number;
  final String name;
  final String meaning;
  final String arabic;
  final int ayahCount;
  final String origin;
  final String description;
  final Map<String, String> fullAudioUrls;

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    final rawAudio =
        (json['audioFull'] ?? json['fullAudioUrls'] ?? const <String, dynamic>{})
            as Map;
    return SurahModel(
      number: _toInt(json['nomor'] ?? json['number']),
      name: (json['namaLatin'] ?? json['nama_latin'] ?? json['nameLatin'] ?? '')
          as String,
      meaning: (json['arti'] ?? json['meaning'] ?? '') as String,
      arabic: (json['nama'] ?? json['arabic'] ?? '') as String,
      ayahCount: _toInt(json['jumlahAyat'] ?? json['ayahCount']),
      origin: (json['tempatTurun'] ?? json['origin'] ?? '') as String,
      description: (json['deskripsi'] ?? json['description'] ?? '') as String,
      fullAudioUrls: rawAudio.map(
        (key, value) => MapEntry('$key', '$value'),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'nomor': number,
      'namaLatin': name,
      'arti': meaning,
      'nama': arabic,
      'jumlahAyat': ayahCount,
      'tempatTurun': origin,
      'deskripsi': description,
      'audioFull': fullAudioUrls,
    };
  }

  String? audioUrlForReciter(String reciterId) {
    final exact = fullAudioUrls[reciterId];
    if ((exact ?? '').isNotEmpty) return exact;
    for (final url in fullAudioUrls.values) {
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
