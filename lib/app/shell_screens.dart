import 'dart:async';

import 'package:flutter/material.dart';

import 'app_session.dart';
import '../data/demo_content.dart';
import '../services/location_service.dart';
import '../services/spiritual_guidance_service.dart';
import '../theme/muslimku_theme.dart';
import 'common_widgets.dart';
import 'detail_screens.dart';
import 'interactive_quran_screens.dart';

PrayerScheduleSnapshot _buildPrayerSnapshot(AppSessionController session) {
  return SpiritualGuidanceService.buildSnapshot(
    location: session.selectedLocation,
    nowUtc: DateTime.now().toUtc(),
  );
}

List<PrayerData> _buildPrayerRows(PrayerScheduleSnapshot snapshot) {
  return snapshot.prayers
      .map(
        (prayer) => PrayerData(
          name: prayer.name,
          time: SpiritualGuidanceService.formatPrayerTime(prayer.time),
          icon: prayer.icon,
          isActive: prayer.isActive,
        ),
      )
      .toList();
}

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.onRestartFlow,
  });

  final Future<void> Function() onRestartFlow;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeDashboardScreen(onGoToTab: _setIndex),
      const QuranHubScreen(),
      const AdzanScreen(),
      SettingsScreen(
        onRestartFlow: widget.onRestartFlow,
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          Positioned.fill(
            child: IndexedStack(index: _index, children: pages),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: FloatingBottomBar(
                currentIndex: _index,
                onChanged: _setIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setIndex(int value) {
    setState(() => _index = value);
  }
}

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key, required this.onGoToTab});

  final ValueChanged<int> onGoToTab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = AppSessionScope.of(context);

    return StreamBuilder<int>(
      stream: Stream<int>.periodic(const Duration(seconds: 1), (tick) => tick),
      initialData: 0,
      builder: (context, _) {
        final snapshot = _buildPrayerSnapshot(session);
        final prayerRows = _buildPrayerRows(snapshot);

        return SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShellHeader(),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            MuslimKuColors.primaryContainer,
                            MuslimKuColors.primary
                          ],
                        ),
                        borderRadius: BorderRadius.circular(34),
                        boxShadow: [
                          BoxShadow(
                            color:
                                MuslimKuColors.primary.withValues(alpha: 0.20),
                            blurRadius: 34,
                            offset: const Offset(0, 22),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.location_on_rounded,
                                            color: Colors.white
                                                .withValues(alpha: 0.85),
                                            size: 16),
                                        const SizedBox(width: 6),
                                        Text(
                                          session.currentLocation,
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      snapshot.nextPrayer.name,
                                      style: theme.textTheme.displaySmall
                                          ?.copyWith(
                                        color: Colors.white,
                                        fontSize: 42,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Dimulai dalam',
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(color: Colors.white70),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    SpiritualGuidanceService.formatCountdown(
                                      snapshot.remaining,
                                    ),
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: prayerRows.map((prayer) {
                              final active = prayer.isActive;
                              return Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: active
                                          ? Colors.white.withValues(alpha: 0.18)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      border: active
                                          ? Border.all(color: Colors.white24)
                                          : null,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          prayer.name,
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                            color: active
                                                ? Colors.white
                                                : Colors.white54,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          prayer.time,
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                            color: active
                                                ? Colors.white
                                                : Colors.white54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: QuickActionTile(
                            icon: Icons.menu_book_rounded,
                            label: 'Al-Qur\'an',
                            onTap: () => onGoToTab(1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: QuickActionTile(
                            icon: Icons.explore_rounded,
                            label: 'Kiblat',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) => const QiblaCompassScreen()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: QuickActionTile(
                            icon: Icons.volunteer_activism_rounded,
                            label: 'Doa',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) => const TafsirScreen()),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SectionHeading(
                      title: 'Lanjutkan Membaca',
                      action: TextButton(
                        onPressed: () => onGoToTab(1),
                        child: const Text('Lihat semua'),
                      ),
                    ),
                    SurfaceCard(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rekomendasi Jumat',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: MuslimKuColors.primary,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text('Surah Al-Kahf',
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(fontSize: 30)),
                                const SizedBox(height: 4),
                                Text('Ayat 15 dari 110',
                                    style: theme.textTheme.bodyMedium),
                                const SizedBox(height: 18),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: 0.13,
                                    minHeight: 8,
                                    backgroundColor:
                                        MuslimKuColors.surfaceContainer,
                                    color: MuslimKuColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor:
                                        MuslimKuColors.primaryContainer,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 14),
                                  ),
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                        builder: (_) =>
                                            const QuranReaderScreen()),
                                  ),
                                  child: const Text('Lanjutkan'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'الكهف',
                                textDirection: TextDirection.rtl,
                                style: theme.textTheme.displaySmall
                                    ?.copyWith(fontSize: 38),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  color: MuslimKuColors.surfaceLow,
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: const Icon(Icons.auto_stories_rounded,
                                    color: MuslimKuColors.primary, size: 36),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const SectionHeading(title: 'Renungan Harian'),
                    SurfaceCard(
                      color: MuslimKuColors.surfaceLow,
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        children: [
                          Icon(Icons.format_quote_rounded,
                              color: MuslimKuColors.primary
                                  .withValues(alpha: 0.35),
                              size: 40),
                          const SizedBox(height: 12),
                          Text(
                            'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
                            textDirection: TextDirection.rtl,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: MuslimKuColors.primary,
                              fontSize: 34,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '"Sesungguhnya bersama kesulitan ada kemudahan."',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 6),
                          Text('Surah Ash-Sharh 94:5',
                              style: theme.textTheme.labelMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class QuranHubScreen extends StatelessWidget {
  const QuranHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShellHeader(),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: MuslimKuColors.primaryContainer,
                    borderRadius: BorderRadius.circular(34),
                    boxShadow: [
                      BoxShadow(
                        color: MuslimKuColors.primary.withValues(alpha: 0.14),
                        blurRadius: 30,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Terakhir Dibaca',
                        style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white70, letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Al-Kahf',
                        style: theme.textTheme.displaySmall
                            ?.copyWith(color: Colors.white, fontSize: 40),
                      ),
                      const SizedBox(height: 4),
                      Text('Ayat 45 • Juz 15',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70)),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: 0.41,
                          minHeight: 8,
                          backgroundColor: Colors.white24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: MuslimKuColors.primary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 14),
                            ),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) => const QuranReaderScreen()),
                            ),
                            child: const Text('Lanjutkan'),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white30),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 14),
                            ),
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) => const AudioPlayerScreen()),
                            ),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('Dengarkan'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: FeatureBentoCard(
                        icon: Icons.list_rounded,
                        title: 'Surah',
                        subtitle: '114 Surah',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                              builder: (_) =>
                                  const InteractiveQuranListScreen()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          FeatureMiniCard(
                            icon: Icons.search_rounded,
                            title: 'Cari',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) =>
                                      const InteractiveQuranSearchScreen()),
                            ),
                          ),
                          const SizedBox(height: 12),
                          FeatureMiniCard(
                            icon: Icons.bookmark_rounded,
                            title: 'Tafsir',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) => const TafsirScreen()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SectionHeading(
                  title: 'Bimbingan Spiritual',
                  action: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const InteractiveQuranSearchScreen()),
                    ),
                    child: const Text('Lihat semua'),
                  ),
                ),
                SurfaceCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً',
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: MuslimKuColors.primary,
                          fontSize: 30,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '"Our Lord, give us in this world that which is good and in the Hereafter that which is good."',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text('Surah Al-Baqarah • 201',
                          style: theme.textTheme.labelMedium),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                ...surahs.take(2).map(
                      (surah) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SurahTile(
                          surah: surah,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                                builder: (_) => const QuranReaderScreen()),
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AdzanScreen extends StatelessWidget {
  const AdzanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = AppSessionScope.of(context);

    return StreamBuilder<int>(
      stream: Stream<int>.periodic(const Duration(seconds: 1), (tick) => tick),
      initialData: 0,
      builder: (context, _) {
        final snapshot = _buildPrayerSnapshot(session);
        final prayerRows = _buildPrayerRows(snapshot);

        return SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShellHeader(),
                    const SizedBox(height: 24),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Salat Berikutnya',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: MuslimKuColors.primary,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(snapshot.nextPrayer.name,
                              style: theme.textTheme.displaySmall
                                  ?.copyWith(fontSize: 56)),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.schedule_rounded,
                                  size: 16, color: MuslimKuColors.textSoft),
                              const SizedBox(width: 6),
                              Text(
                                SpiritualGuidanceService.formatPrayerTime(
                                  snapshot.nextPrayer.time,
                                ),
                                style: theme.textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: MuslimKuColors.primaryFixed,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${SpiritualGuidanceService.formatCountdown(snapshot.remaining)} tersisa',
                              style: theme.textTheme.labelLarge
                                  ?.copyWith(color: MuslimKuColors.text),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    SurfaceCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeading(
                            title: 'Jadwal Harian',
                            action: Text(session.currentLocation,
                                style: theme.textTheme.labelMedium),
                          ),
                          const SizedBox(height: 10),
                          ...prayerRows.map(
                            (prayer) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: PrayerRow(prayer: prayer),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SurfaceCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Preferensi Adzan',
                              style: theme.textTheme.titleLarge),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Notifikasi Adzan',
                                        style: theme.textTheme.titleMedium),
                                    const SizedBox(height: 4),
                                    Text('Putar Adzan lengkap saat waktunya',
                                        style: theme.textTheme.bodyMedium),
                                  ],
                                ),
                              ),
                              Switch(
                                value: session.adzanAlerts,
                                activeThumbColor: Colors.white,
                                activeTrackColor: MuslimKuColors.primary,
                                onChanged: session.setAdzanAlerts,
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Pilihan Suara',
                            style: theme.textTheme.labelLarge
                                ?.copyWith(letterSpacing: 1.4),
                          ),
                          const SizedBox(height: 14),
                          SelectableOption(
                            icon: Icons.mosque_rounded,
                            label: 'Makkah (Masjid al-Haram)',
                            selected: session.adzanAudio ==
                                'Makkah (Masjid al-Haram)',
                            onTap: () => session
                                .updateAdzanAudio('Makkah (Masjid al-Haram)'),
                          ),
                          const SizedBox(height: 10),
                          SelectableOption(
                            icon: Icons.mosque_outlined,
                            label: 'Madinah (Masjid Nabawi)',
                            selected:
                                session.adzanAudio == 'Madinah (Masjid Nabawi)',
                            onTap: () => session
                                .updateAdzanAudio('Madinah (Masjid Nabawi)'),
                          ),
                          const SizedBox(height: 10),
                          SelectableOption(
                            icon: Icons.graphic_eq_rounded,
                            label: 'Nada lembut modern',
                            selected:
                                session.adzanAudio == 'Nada lembut modern',
                            onTap: () =>
                                session.updateAdzanAudio('Nada lembut modern'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'أَقِمِ الصَّلَاةَ لِدُلُوكِ الشَّمْسِ',
                            textDirection: TextDirection.rtl,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: MuslimKuColors.primary
                                  .withValues(alpha: 0.45),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '"Dirikanlah salat saat matahari tergelincir..." (17:78)',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.onRestartFlow,
  });

  final Future<void> Function() onRestartFlow;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = AppSessionScope.of(context);

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShellHeader(),
                const SizedBox(height: 24),
                Text('Pengaturan', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Sesuaikan suaka digitalmu sesuai perjalananmu.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                SurfaceCard(
                  padding: const EdgeInsets.all(22),
                  onTap: _openEditProfile,
                  child: Row(
                    children: [
                      ProfileAvatar(
                        initials: session.profile.initials,
                        size: 66,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.profile.fullName,
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(fontSize: 22),
                            ),
                            const SizedBox(height: 4),
                            Text(session.profile.email,
                                style: theme.textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _openEditProfile,
                        style: TextButton.styleFrom(
                          foregroundColor: MuslimKuColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        icon: const Icon(Icons.edit_rounded, size: 16),
                        label: const Text('Ubah'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SettingsSection(
                  icon: Icons.palette_rounded,
                  title: 'Tampilan',
                  children: [
                    SettingArrowRow(
                      title: 'Warna Aksen',
                      subtitle: 'Hijau tenang khas',
                      bottomPadding: 0,
                      onTap: () => _showAccentInfo(),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: MuslimKuColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: MuslimKuColors.primary
                                      .withValues(alpha: 0.20),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.chevron_right_rounded,
                              color: MuslimKuColors.textSoft),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SettingsSection(
                  icon: Icons.location_on_rounded,
                  title: 'Lokasi',
                  iconBackground: MuslimKuColors.primaryFixed,
                  children: [
                    SettingArrowRow(
                      title: 'Lokasi Salat',
                      subtitle: session.currentLocation,
                      bottomPadding: 0,
                      onTap: () => _pickLocation(session),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SettingsSection(
                  icon: Icons.notifications_active_rounded,
                  title: 'Notifikasi',
                  iconBackground: MuslimKuColors.tertiarySoft,
                  children: [
                    SettingSwitchRow(
                      title: 'Peringatan Adzan',
                      subtitle: 'Notifikasi setiap waktu salat',
                      value: session.adzanAlerts,
                      onChanged: session.setAdzanAlerts,
                    ),
                    SettingSwitchRow(
                      title: 'Ayat Harian',
                      subtitle: 'Terima kutipan spiritual pagi',
                      value: session.dailyVerses,
                      onChanged: session.setDailyVerses,
                      bottomPadding: 0,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SettingsSection(
                  icon: Icons.volume_up_rounded,
                  title: 'Pengaturan Audio',
                  iconBackground: MuslimKuColors.surfaceHigh,
                  children: [
                    SettingArrowRow(
                      title: 'Qari Al-Qur\'an',
                      subtitle: session.quranReciter,
                      onTap: () => _pickChoice(
                        title: 'Pilih Qari Al-Qur\'an',
                        options: kQuranReciterOptions,
                        currentValue: session.quranReciter,
                        onSelected: session.updateQuranReciter,
                      ),
                    ),
                    SettingArrowRow(
                      title: 'Audio Adzan',
                      subtitle: session.adzanAudio,
                      bottomPadding: 0,
                      onTap: () => _pickAdzanAudio(session),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SettingsSection(
                  icon: Icons.language_rounded,
                  title: 'Bahasa',
                  iconBackground: MuslimKuColors.surfaceHighest,
                  children: [
                    SettingArrowRow(
                      title: 'Antarmuka Aplikasi',
                      subtitle: session.interfaceLanguage,
                      onTap: () => _pickChoice(
                        title: 'Bahasa Antarmuka',
                        options: kInterfaceLanguageOptions,
                        currentValue: session.interfaceLanguage,
                        onSelected: session.updateInterfaceLanguage,
                      ),
                    ),
                    SettingArrowRow(
                      title: 'Terjemahan Al-Qur\'an',
                      subtitle: session.translation,
                      bottomPadding: 0,
                      onTap: () => _pickChoice(
                        title: 'Terjemahan Al-Qur\'an',
                        options: kTranslationOptions,
                        currentValue: session.translation,
                        onSelected: session.updateTranslation,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SurfaceCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
                  onTap: () => _showLogoutConfirmation(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_rounded,
                          color: Color(0xFFBA1A1A)),
                      const SizedBox(width: 10),
                      Text(
                        'Keluar',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: const Color(0xFFBA1A1A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Muslimku v2.4.0 (Build 892)',
                    style: theme.textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openEditProfile() async {
    final session = AppSessionScope.of(context);
    final updated = await Navigator.of(context).push<ProfileData>(
      MaterialPageRoute<ProfileData>(
        builder: (_) => EditProfileScreen(initialProfile: session.profile),
      ),
    );

    if (updated == null) return;
    session.updateProfile(updated);
  }

  Future<void> _showLogoutConfirmation() {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.16),
      builder: (dialogContext) {
        return LogoutConfirmationDialog(
          onCancel: () => Navigator.of(dialogContext).pop(),
          onConfirm: () async {
            Navigator.of(dialogContext).pop();
            await widget.onRestartFlow();
          },
        );
      },
    );
  }

  Future<void> _pickLocation(AppSessionController session) async {
    final updated = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) =>
            SelectLocationScreen(initialLocation: session.currentLocation),
      ),
    );

    if (updated == null) return;
    session.updateLocation(updated);
    final hasPermission = await AppLocationService.hasLocationPermission();
    session.setLocationPermissionEnabled(hasPermission);
  }

  Future<void> _pickAdzanAudio(AppSessionController session) async {
    final updated = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => AdzanSoundScreen(initialSelection: session.adzanAudio),
      ),
    );

    if (updated == null) return;
    session.updateAdzanAudio(updated);
  }

  Future<void> _pickChoice({
    required String title,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) async {
    final selection = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: SurfaceCard(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                ...options.map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SelectableOption(
                      icon: Icons.checklist_rounded,
                      label: option,
                      selected: option == currentValue,
                      onTap: () => Navigator.of(bottomSheetContext).pop(option),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selection == null) return;
    onSelected(selection);
  }

  void _showAccentInfo() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
              'Desain baru memakai aksen hijau khas Muslimku sebagai warna utama aplikasi.'),
        ),
      );
  }
}
