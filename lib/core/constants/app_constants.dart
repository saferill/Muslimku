class AppConstants {
  static const appName = 'Muslimku';
  static const logoAssetPath = 'assets/Logo/Logo Muslimku.png';
  static const appVersion = '2.4.0';
  static const appBuild = 'Build 82';
  static const supportEmail = 'moch.syafrilramadhani@yahoo.com';
  static const dailyAyah =
      '"So remember Me; I will remember you..." - Al-Baqarah 2:152';

  static const popularLocations = <String>[
    'Jakarta, Indonesia',
    'Bandung, Indonesia',
    'Surabaya, Indonesia',
    'Semarang, Indonesia',
    'Yogyakarta, Indonesia',
    'Medan, Indonesia',
    'Palembang, Indonesia',
    'Makassar, Indonesia',
    'Denpasar, Indonesia',
    'Balikpapan, Indonesia',
    'Banjarmasin, Indonesia',
    'Banda Aceh, Indonesia',
    'Kuala Lumpur, Malaysia',
    'Makkah, Arab Saudi',
  ];

  static const adzanSounds = <String>[
    'Adzan A1',
    'Adzan A2',
    'Adzan A3',
    'Adzan A4',
    'Adzan A5',
    'Adzan A6',
    'AlAdhan A7',
    'Adzan A8',
    'Adzan A9',
    'Adzan A10',
    'Adzan A11',
  ];

  static const defaultRegularAdzanSound = 'AlAdhan A7';
  static const defaultFajrAdzanSound = 'AlAdhan A7';

  static const adzanRawResourceNames = <String, String>{
    'Adzan A1': 'adhan_a1',
    'Adzan A2': 'adhan_a2',
    'Adzan A3': 'adhan_a3',
    'Adzan A4': 'adhan_a4',
    'Adzan A5': 'adhan_a5',
    'Adzan A6': 'adhan_a6',
    'AlAdhan A7': 'adhan_a7',
    'Adzan A8': 'adhan_a8',
    'Adzan A9': 'adhan_a9',
    'Adzan A10': 'adhan_a10',
    'Adzan A11': 'adhan_a11_mansour_al_zahrani',
  };

  static const adzanAssetPaths = <String, String>{
    'Adzan A1': 'assets/audio/adhan/adhan_a1.mp3',
    'Adzan A2': 'assets/audio/adhan/adhan_a2.mp3',
    'Adzan A3': 'assets/audio/adhan/adhan_a3.mp3',
    'Adzan A4': 'assets/audio/adhan/adhan_a4.mp3',
    'Adzan A5': 'assets/audio/adhan/adhan_a5.mp3',
    'Adzan A6': 'assets/audio/adhan/adhan_a6.mp3',
    'AlAdhan A7': 'assets/audio/adhan/adhan_a7.mp3',
    'Adzan A8': 'assets/audio/adhan/adhan_a8.mp3',
    'Adzan A9': 'assets/audio/adhan/adhan_a9.mp3',
    'Adzan A10': 'assets/audio/adhan/adhan_a10.mp3',
    'Adzan A11': 'assets/audio/adhan/adhan_a11_mansour_al_zahrani.mp3',
  };

  static String normalizeAdzanSound(
    String? value, {
    bool fajr = false,
  }) {
    final fallback = fajr ? defaultFajrAdzanSound : defaultRegularAdzanSound;
    if (adzanSounds.contains(value)) {
      return value!;
    }
    return fallback;
  }

  static const quranReciters = <String>[
    'Abdullah Al-Juhany',
    'Abdul Muhsin Al-Qasim',
    'Abdurrahman As-Sudais',
    'Ibrahim Al-Dossari',
    'Misyari Rasyid Al-Afasi',
    'Yasser Al-Dosari',
  ];

  static const quranReciterIds = <String, String>{
    'Abdullah Al-Juhany': '01',
    'Abdul Muhsin Al-Qasim': '02',
    'Abdurrahman As-Sudais': '03',
    'Ibrahim Al-Dossari': '04',
    'Misyari Rasyid Al-Afasi': '05',
    'Yasser Al-Dosari': '06',
  };

  static const interfaceLanguages = <String>[
    'Bahasa Indonesia',
    'English',
  ];

  static const translationOptions = <String>[
    'Indonesia (Kemenag RI)',
    'English (Muhammad Asad)',
  ];
}
