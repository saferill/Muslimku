import 'package:flutter/material.dart';

class OnboardingStepData {
  const OnboardingStepData({
    required this.title,
    required this.highlight,
    required this.description,
    required this.icon,
    required this.caption,
  });

  final String title;
  final String highlight;
  final String description;
  final IconData icon;
  final String caption;
}

class PrayerData {
  const PrayerData({
    required this.name,
    required this.time,
    required this.icon,
    this.isActive = false,
  });

  final String name;
  final String time;
  final IconData icon;
  final bool isActive;
}

class SurahData {
  const SurahData({
    required this.number,
    required this.name,
    required this.meaning,
    required this.arabic,
    required this.ayahs,
  });

  final int number;
  final String name;
  final String meaning;
  final String arabic;
  final int ayahs;
}

class AyahData {
  const AyahData({
    required this.number,
    required this.arabic,
    required this.translation,
  });

  final int number;
  final String arabic;
  final String translation;
}

class SearchResultData {
  const SearchResultData({
    required this.surah,
    required this.reference,
    required this.arabic,
    required this.translation,
  });

  final String surah;
  final String reference;
  final String arabic;
  final String translation;
}

class ProfileData {
  const ProfileData({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.bio,
    required this.memberSince,
  });

  final String fullName;
  final String email;
  final String phone;
  final String bio;
  final String memberSince;

  String get initials {
    final parts = fullName
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .take(2)
        .toList();
    if (parts.isEmpty) return 'MK';
    return parts.map((part) => part.substring(0, 1).toUpperCase()).join();
  }

  ProfileData copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? bio,
    String? memberSince,
  }) {
    return ProfileData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      memberSince: memberSince ?? this.memberSince,
    );
  }
}

const onboardingSteps = <OnboardingStepData>[
  OnboardingStepData(
    title: 'Jangan Lewatkan',
    highlight: 'Momen Spiritual',
    description:
        'Terima pengingat adzan yang lembut dan tepat waktu sesuai lokasi Anda, di mana pun berada.',
    icon: Icons.notifications_active_rounded,
    caption: 'Salat Berikutnya \u2022 Asar 15:24',
  ),
  OnboardingStepData(
    title: 'Ayat Suci,',
    highlight: 'Pemahaman Mendalam',
    description:
        'Rasakan Al-Qur\'an dengan antarmuka tenang untuk membaca, merenung, dan tafsir.',
    icon: Icons.auto_stories_rounded,
    caption: 'Hikmah Harian \u2022 Renungkan setiap ayat',
  ),
  OnboardingStepData(
    title: 'Indah',
    highlight: 'Lantunan Audio',
    description:
        'Dengarkan qari terkenal dalam pemutar fokus dan mendalam untuk kekhusyukan.',
    icon: Icons.headphones_rounded,
    caption: 'Sedang Diputar \u2022 Surah Ar-Rahman',
  ),
];

const prayers = <PrayerData>[
  PrayerData(name: 'Subuh', time: '04:32 AM', icon: Icons.wb_twilight_outlined),
  PrayerData(name: 'Zuhur', time: '11:58 AM', icon: Icons.light_mode_outlined),
  PrayerData(name: 'Asar', time: '03:14 PM', icon: Icons.sunny, isActive: true),
  PrayerData(name: 'Magrib', time: '06:02 PM', icon: Icons.wb_sunny_outlined),
  PrayerData(name: 'Isya', time: '07:15 PM', icon: Icons.nightlight_round),
];

const surahs = <SurahData>[
  SurahData(
    number: 1,
    name: 'Al-Fatihah',
    meaning: 'Pembukaan',
    arabic: '\u0627\u0644\u0641\u0627\u062a\u062d\u0629',
    ayahs: 7,
  ),
  SurahData(
    number: 2,
    name: 'Al-Baqarah',
    meaning: 'Sapi Betina',
    arabic: '\u0627\u0644\u0628\u0642\u0631\u0629',
    ayahs: 286,
  ),
  SurahData(
    number: 3,
    name: 'Ali \'Imran',
    meaning: 'Keluarga Imran',
    arabic: '\u0622\u0644 \u0639\u0645\u0631\u0627\u0646',
    ayahs: 200,
  ),
  SurahData(
    number: 4,
    name: 'An-Nisa',
    meaning: 'Para Wanita',
    arabic: '\u0627\u0644\u0646\u0633\u0627\u0621',
    ayahs: 176,
  ),
  SurahData(
    number: 5,
    name: 'Al-Ma\'idah',
    meaning: 'Hidangan',
    arabic: '\u0627\u0644\u0645\u0627\u0626\u062f\u0629',
    ayahs: 120,
  ),
  SurahData(
    number: 6,
    name: 'Al-An\'am',
    meaning: 'Binatang Ternak',
    arabic: '\u0627\u0644\u0623\u0646\u0639\u0627\u0645',
    ayahs: 165,
  ),
];

const ayahs = <AyahData>[
  AyahData(
    number: 1,
    arabic:
        '\u062a\u064e\u0628\u064e\u0627\u0631\u064e\u0643\u064e \u0627\u0644\u0651\u064e\u0630\u0650\u064a '
        '\u0628\u0650\u064a\u064e\u062f\u0650\u0647\u0650 \u0627\u0644\u0652\u0645\u064f\u0644\u0652\u0643\u064f '
        '\u0648\u064e\u0647\u064f\u0648\u064e \u0639\u064e\u0644\u064e\u0649\u0670 \u0643\u064f\u0644\u0651\u0650 '
        '\u0634\u064e\u064a\u0652\u0621\u064d \u0642\u064e\u062f\u0650\u064a\u0631\u064c',
    translation:
        'Maha Suci Dia yang di tangan-Nya segala kerajaan, dan Dia Mahakuasa atas segala sesuatu.',
  ),
  AyahData(
    number: 2,
    arabic:
        '\u0627\u0644\u0651\u064e\u0630\u0650\u064a \u062e\u064e\u0644\u064e\u0642\u064e \u0627\u0644\u0652\u0645\u064e'
        '\u0648\u0652\u062a\u064e \u0648\u064e\u0627\u0644\u0652\u062d\u064e\u064a\u064e\u0627\u0629\u064e '
        '\u0644\u0650\u064a\u064e\u0628\u0652\u0644\u064f\u0648\u064e\u0643\u064f\u0645\u0652 \u0623\u064e'
        '\u064a\u064f\u0651\u0643\u064f\u0645\u0652 \u0623\u064e\u062d\u0652\u0633\u064e\u0646\u064f '
        '\u0639\u064e\u0645\u064e\u0644\u064b\u0627',
    translation:
        'Yang menciptakan mati dan hidup untuk menguji kamu siapa di antara kamu yang terbaik amalnya.',
  ),
  AyahData(
    number: 3,
    arabic:
        '\u0627\u0644\u0651\u064e\u0630\u0650\u064a \u062e\u064e\u0644\u064e\u0642\u064e \u0633\u064e\u0628\u0652'
        '\u0639\u064e \u0633\u064e\u0645\u064e\u0627\u0648\u064e\u0627\u062a\u064d \u0637\u0650\u0628\u064e\u0627'
        '\u0642\u064b\u0627 \u0645\u064e\u0627 \u062a\u064e\u0631\u064e\u0649 \u0641\u0650\u064a \u062e\u064e'
        '\u0644\u0652\u0642\u0650 \u0627\u0644\u0631\u0651\u064e\u062d\u0652\u0645\u064e\u0646\u0650 \u0645\u0650'
        '\u0646 \u062a\u064e\u0641\u064e\u0627\u0648\u064f\u062a\u064d',
    translation:
        'Yang menciptakan tujuh langit berlapis-lapis. Kamu tidak akan melihat pada ciptaan Yang Maha Pengasih sesuatu yang tidak seimbang.',
  ),
];

const searchResults = <SearchResultData>[
  SearchResultData(
    surah: 'Al-Baqarah',
    reference: 'Surah 2 : Ayat 153',
    arabic:
        '\u064a\u064e\u0627 \u0623\u064e\u064a\u064f\u0651\u0647\u064e\u0627 \u0627\u0644\u0651\u064e\u0630\u0650'
        '\u064a\u0646\u064e \u0622\u0645\u064e\u0646\u064f\u0648\u0627 \u0627\u0633\u0652\u062a\u064e\u0639\u0650'
        '\u064a\u0646\u064f\u0648\u0627 \u0628\u0650\u0627\u0644\u0635\u0651\u064e\u0628\u0652\u0631\u0650 '
        '\u0648\u064e\u0627\u0644\u0635\u0651\u064e\u0644\u064e\u0627\u0629\u0650',
    translation:
        'Wahai orang-orang yang beriman, mintalah pertolongan dengan sabar dan salat.',
  ),
  SearchResultData(
    surah: 'Az-Zumar',
    reference: 'Surah 39 : Ayat 10',
    arabic:
        '\u0625\u0650\u0646\u0651\u064e\u0645\u064e\u0627 \u064a\u064f\u0648\u064e\u0641\u0651\u064e\u0649 '
        '\u0627\u0644\u0635\u0651\u064e\u0627\u0628\u0650\u0631\u064f\u0648\u0646\u064e \u0623\u064e\u062c\u0652'
        '\u0631\u064e\u0647\u064f\u0645\u0652 \u0628\u0650\u063a\u064e\u064a\u0652\u0631\u0650 \u062d\u0650\u0633'
        '\u064e\u0627\u0628\u064d',
    translation:
        'Sesungguhnya hanya orang-orang yang bersabarlah yang dicukupkan pahala mereka tanpa batas.',
  ),
  SearchResultData(
    surah: 'Al-Balad',
    reference: 'Surah 90 : Ayat 17',
    arabic:
        '\u0648\u064e\u062a\u064e\u0648\u064e\u0627\u0635\u064e\u0648\u0652\u0627 \u0628\u0650\u0627\u0644'
        '\u0635\u0651\u064e\u0628\u0652\u0631\u0650 \u0648\u064e\u062a\u064e\u0648\u064e\u0627\u0635\u064e\u0648'
        '\u0652\u0627 \u0628\u0650\u0627\u0644\u0652\u0645\u064e\u0631\u0652\u062d\u064e\u0645\u064e\u0629\u0650',
    translation:
        'Dan saling menasihati untuk kesabaran dan saling menasihati untuk kasih sayang.',
  ),
];

const tafsirParagraphs = <String>[
  'Ini termasuk ayat terbesar dalam Kitab Allah, menegaskan keesaan-Nya, kehidupan-Nya, dan kuasa pemeliharaan-Nya atas seluruh ciptaan.',
  'Hanya Allah yang berhak disembah. Segala selain-Nya bergantung, terbatas, dan pada akhirnya fana.',
  'Frasa "Yang Maha Hidup, Yang terus-menerus mengurus" menunjukkan kesempurnaan yang tidak tersentuh oleh tidur, lelah, atau kekurangan.',
  'Ayat ini juga mengajarkan bahwa setiap jiwa dan kekuasaan sepenuhnya milik Allah, dan tidak ada syafaat kecuali dengan izin-Nya.',
];

const demoProfile = ProfileData(
  fullName: 'Ahmad Abdullah',
  email: 'ahmad.abd@email.com',
  phone: '+62 812 3456 7890',
  bio:
      'Mencari ketenangan melalui zikir dan pengabdian. Terus belajar, selalu bersyukur.',
  memberSince: 'Ramadan 1445',
);
