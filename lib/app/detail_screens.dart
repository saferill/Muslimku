import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_session.dart';
import '../data/demo_content.dart';
import '../data/location_catalog.dart';
import '../services/location_service.dart';
import '../services/spiritual_guidance_service.dart';
import '../theme/muslimku_theme.dart';
import 'common_widgets.dart';

class DetailScaffold extends StatelessWidget {
  const DetailScaffold({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title,
                                    style: theme.textTheme.headlineSmall),
                                if (subtitle != null)
                                  Text(subtitle!,
                                      style: theme.textTheme.labelMedium),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QiblaCompassScreen extends StatelessWidget {
  const QiblaCompassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = AppSessionScope.of(context);
    final snapshot = SpiritualGuidanceService.buildSnapshot(
      location: session.selectedLocation,
      nowUtc: DateTime.now().toUtc(),
    );
    final cardinal =
        SpiritualGuidanceService.cardinalDirection(snapshot.qiblaBearing);
    final distanceLabel =
        '${snapshot.distanceToMakkahKm.toStringAsFixed(0)} km';

    return Scaffold(
      backgroundColor: MuslimKuColors.surface,
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 140),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.arrow_back_rounded),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Muslimku',
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    color: MuslimKuColors.primary,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.settings_rounded),
                                color: MuslimKuColors.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text('Kiblat',
                              style: theme.textTheme.displaySmall
                                  ?.copyWith(fontSize: 42)),
                          const SizedBox(height: 8),
                          Text(
                            'TEMUKAN ARAH KIBLAT',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: MuslimKuColors.textSoft,
                              letterSpacing: 2.2,
                            ),
                          ),
                          const SizedBox(height: 30),
                          _CompassVisual(
                            bearingDegrees: snapshot.qiblaBearing,
                            cardinal: cardinal,
                          ),
                          const SizedBox(height: 28),
                          SurfaceCard(
                            padding: const EdgeInsets.all(24),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 0,
                                  right: -10,
                                  bottom: 0,
                                  child: Center(
                                    child: Icon(
                                      Icons.mosque_rounded,
                                      size: 110,
                                      color: MuslimKuColors.primary
                                          .withValues(alpha: 0.08),
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 42,
                                          height: 42,
                                          decoration: BoxDecoration(
                                            color: MuslimKuColors.primary
                                                .withValues(alpha: 0.10),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.location_on_rounded,
                                            color: MuslimKuColors.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Lokasi Saat Ini',
                                              style: theme.textTheme.labelLarge
                                                  ?.copyWith(
                                                color: MuslimKuColors.primary,
                                                letterSpacing: 1.6,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              session.currentLocation,
                                              style: theme.textTheme.titleLarge,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    const Divider(),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Jarak ke Makkah',
                                                style: theme
                                                    .textTheme.labelMedium
                                                    ?.copyWith(
                                                  letterSpacing: 1.6,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                distanceLabel,
                                                style: theme
                                                    .textTheme.headlineSmall
                                                    ?.copyWith(fontSize: 30),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: MuslimKuColors
                                                .primaryContainer
                                                .withValues(alpha: 0.10),
                                            borderRadius:
                                                BorderRadius.circular(18),
                                          ),
                                          child: Text(
                                            '$cardinal • ${snapshot.qiblaBearing.round()}°',
                                            style: theme.textTheme.labelLarge
                                                ?.copyWith(
                                              color: MuslimKuColors
                                                  .primaryContainer,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: MuslimKuColors.primary
                                  .withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: MuslimKuColors.primary
                                    .withValues(alpha: 0.10),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_rounded,
                                    color: MuslimKuColors.primary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Letakkan perangkat secara datar dan jauh dari benda logam agar arah lebih akurat.',
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(color: MuslimKuColors.text),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SafeArea(
                        minimum: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                        child: GlassBar(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _QiblaBottomItem(
                                icon: Icons.home_rounded,
                                label: 'Beranda',
                                onTap: () => Navigator.of(context).pop(),
                              ),
                              const _QiblaBottomItem(
                                icon: Icons.schedule_rounded,
                                label: 'Salat',
                              ),
                              const _QiblaActiveBottomItem(
                                  icon: Icons.explore_rounded),
                              const _QiblaBottomItem(
                                icon: Icons.auto_stories_rounded,
                                label: 'Doa',
                              ),
                              const _QiblaBottomItem(
                                icon: Icons.person_rounded,
                                label: 'Profil',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({
    super.key,
    required this.initialLocation,
  });

  final String initialLocation;

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  late final TextEditingController _searchController;
  String _query = '';
  bool _detectingLocation = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredLocations = kKnownLocations.where((location) {
      if (_query.isEmpty) return true;
      final needle = _query.toLowerCase();
      final haystack = '${location.label} ${location.country}'.toLowerCase();
      return haystack.contains(needle);
    }).toList();
    final recentLocations = kRecentLocations.map(lookupLocation).toList();

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Pilih Lokasi',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(color: MuslimKuColors.primary),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SearchField(
                              hint: 'Cari kota atau wilayah...',
                              controller: _searchController,
                              onChanged: (value) =>
                                  setState(() => _query = value),
                              suffixIcon: _query.isEmpty
                                  ? const Icon(Icons.tune_rounded)
                                  : IconButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _query = '');
                                      },
                                      icon: const Icon(Icons.close_rounded),
                                    ),
                            ),
                            const SizedBox(height: 18),
                            SurfaceCard(
                              color: MuslimKuColors.primaryContainer,
                              padding: const EdgeInsets.all(20),
                              onTap: _detectingLocation
                                  ? null
                                  : _detectNearestLocation,
                              child: Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(Icons.my_location_rounded,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _detectingLocation
                                              ? 'Mendeteksi lokasi...'
                                              : 'Deteksi Lokasi Saya',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(color: Colors.white),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Gunakan lokasi default terdekat untuk jadwal salat.',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded,
                                      color: Colors.white70),
                                ],
                              ),
                            ),
                            const SizedBox(height: 22),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Kota Populer',
                                    style: theme.textTheme.titleLarge),
                                Text(
                                  '${filteredLocations.length} hasil',
                                  style: theme.textTheme.labelMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final wide = constraints.maxWidth > 520;
                                final crossAxisCount = wide ? 3 : 2;
                                return GridView.count(
                                  crossAxisCount: crossAxisCount,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 1.05,
                                  children: filteredLocations
                                      .map(
                                        (location) => _CityCard(
                                          label:
                                              location.label.split(',').first,
                                          subtitle: location.country,
                                          icon:
                                              location.label.contains('Makkah')
                                                  ? Icons.mosque_rounded
                                                  : Icons.location_city_rounded,
                                          onTap: () => Navigator.of(context)
                                              .pop(location.label),
                                        ),
                                      )
                                      .toList(),
                                );
                              },
                            ),
                            const SizedBox(height: 22),
                            Text('Pencarian Terakhir',
                                style: theme.textTheme.titleLarge),
                            const SizedBox(height: 10),
                            ...recentLocations.map(
                              (location) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _RecentLocationTile(
                                  city: location.label.split(',').first,
                                  country: location.country,
                                  onTap: () =>
                                      Navigator.of(context).pop(location.label),
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            SurfaceCard(
                              color: MuslimKuColors.surfaceLow,
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Lokasi Saat Ini',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                  color:
                                                      MuslimKuColors.primary),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          widget.initialLocation,
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                        const SizedBox(height: 12),
                                        FilledButton(
                                          onPressed: () => Navigator.of(context)
                                              .pop(widget.initialLocation),
                                          child:
                                              const Text('Gunakan Lokasi Ini'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.08),
                                          blurRadius: 18,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.map_rounded,
                                        color: MuslimKuColors.primary,
                                        size: 42),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _detectNearestLocation() async {
    setState(() => _detectingLocation = true);
    final result = await AppLocationService.detectNearestSupportedLocation();
    if (!mounted) return;
    setState(() => _detectingLocation = false);

    if (!result.success || result.location == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              result.message ?? 'Tidak bisa mendeteksi lokasi saat ini.',
            ),
          ),
        );
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(result.message!)),
      );
    Navigator.of(context).pop(result.location!.label);
  }
}

class AdzanSoundScreen extends StatelessWidget {
  const AdzanSoundScreen({
    super.key,
    required this.initialSelection,
  });

  final String initialSelection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Notifikasi Adzan',
                            style: theme.textTheme.titleLarge
                                ?.copyWith(color: MuslimKuColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text('Suara Adzan',
                          style: theme.textTheme.displaySmall
                              ?.copyWith(fontSize: 40)),
                      const SizedBox(height: 6),
                      Text(
                        'Pilih muadzin favorit untuk notifikasi',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: MuslimKuColors.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      Column(
                        children: [
                          _AdzanSoundTile(
                            icon: Icons.graphic_eq_rounded,
                            title: kAdzanSoundOptions[0],
                            subtitle:
                                'Nuansa Masjidil Haram yang penuh ketenangan',
                            selected: initialSelection == kAdzanSoundOptions[0],
                            onTap: () => Navigator.of(context)
                                .pop(kAdzanSoundOptions[0]),
                          ),
                          const SizedBox(height: 12),
                          _AdzanSoundTile(
                            icon: Icons.mosque_rounded,
                            title: kAdzanSoundOptions[1],
                            subtitle: 'Karakter lembut ala Masjid Nabawi',
                            selected: initialSelection == kAdzanSoundOptions[1],
                            onTap: () => Navigator.of(context)
                                .pop(kAdzanSoundOptions[1]),
                          ),
                          const SizedBox(height: 12),
                          _AdzanSoundTile(
                            icon: Icons.travel_explore_rounded,
                            title: kAdzanSoundOptions[2],
                            subtitle:
                                'Resonansi klasik untuk nuansa bersejarah',
                            selected: initialSelection == kAdzanSoundOptions[2],
                            onTap: () => Navigator.of(context)
                                .pop(kAdzanSoundOptions[2]),
                          ),
                          const SizedBox(height: 12),
                          _AdzanSoundTile(
                            icon: Icons.blur_on_rounded,
                            title: kAdzanSoundOptions[3],
                            subtitle:
                                'Nada halus untuk pengingat yang minimalis',
                            selected: initialSelection == kAdzanSoundOptions[3],
                            onTap: () => Navigator.of(context)
                                .pop(kAdzanSoundOptions[3]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SurfaceCard(
                        color: MuslimKuColors.surfaceLow,
                        padding: const EdgeInsets.all(24),
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: -24,
                              right: -20,
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                size: 140,
                                color: MuslimKuColors.primary
                                    .withValues(alpha: 0.08),
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  'حَيَّ عَلَى الصَّلَاةِ',
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    color: MuslimKuColors.primary,
                                    fontSize: 34,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '"Bergegaslah menuju salat"',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdzanSoundTile extends StatelessWidget {
  const _AdzanSoundTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      color: MuslimKuColors.surface,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: selected
                  ? MuslimKuColors.primaryContainer
                  : MuslimKuColors.surfaceLow,
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                color: selected ? Colors.white : MuslimKuColors.textSecondary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: MuslimKuColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.play_circle_fill_rounded,
              color: selected
                  ? MuslimKuColors.primary
                  : MuslimKuColors.textSecondary,
            ),
          ),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? MuslimKuColors.primary
                    : MuslimKuColors.outlineVariant,
                width: 2,
              ),
              color: selected ? MuslimKuColors.primary : Colors.transparent,
            ),
            child: selected
                ? const Center(
                    child: Icon(Icons.circle, size: 8, color: Colors.white))
                : null,
          ),
        ],
      ),
    );
  }
}

class QuranListScreen extends StatelessWidget {
  const QuranListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DetailScaffold(
      title: 'Al-Qur\'an',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [
                  MuslimKuColors.primaryContainer.withValues(alpha: 0.88),
                  MuslimKuColors.primary.withValues(alpha: 0.65),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Terakhir Dibaca',
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: Colors.white70)),
                const SizedBox(height: 8),
                Text(
                  'Surah Al-Kahf',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text('Ayat 45 • Lanjut 2 hari lalu',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SearchField(hint: 'Cari Surah, Juz, atau Ayat...'),
          const SizedBox(height: 24),
          ...surahs.map(
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
    );
  }
}

class _CityCard extends StatelessWidget {
  const _CityCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: MuslimKuColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: MuslimKuColors.primary),
          ),
          const Spacer(),
          Text(label, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _RecentLocationTile extends StatelessWidget {
  const _RecentLocationTile({
    required this.city,
    required this.country,
    required this.onTap,
  });

  final String city;
  final String country;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: MuslimKuColors.surfaceLow,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.history_rounded, color: MuslimKuColors.textSoft),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(city, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(country, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          Icon(Icons.arrow_outward_rounded, color: MuslimKuColors.textSoft),
        ],
      ),
    );
  }
}

class QuranReaderScreen extends StatelessWidget {
  const QuranReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: MuslimKuColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Stack(
                  children: [
                    ListView(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 140),
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Surah Al-Mulk',
                                      style: theme.textTheme.headlineSmall),
                                  Text('Surah 67 • 30 Ayat',
                                      style: theme.textTheme.labelMedium),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                    builder: (_) => const QuranSearchScreen()),
                              ),
                              icon: const Icon(Icons.search_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Column(
                          children: [
                            Text(
                              'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                              textDirection: TextDirection.rtl,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: MuslimKuColors.primary,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 14),
                            Container(
                              width: 52,
                              height: 4,
                              decoration: BoxDecoration(
                                color: MuslimKuColors.primaryFixedDim
                                    .withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        ...ayahs.map(
                          (ayah) => Padding(
                            padding: const EdgeInsets.only(bottom: 36),
                            child: SurfaceCard(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: MuslimKuColors.surfaceLow,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      ayah.number.toString(),
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                              color: MuslimKuColors.primary),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    ayah.arabic,
                                    textDirection: TextDirection.rtl,
                                    textAlign: TextAlign.right,
                                    style:
                                        theme.textTheme.headlineSmall?.copyWith(
                                      fontSize: 34,
                                      height: 1.8,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Text(ayah.translation,
                                      style: theme.textTheme.titleMedium),
                                  const SizedBox(height: 8),
                                  Text('Sahih International',
                                      style: theme.textTheme.labelMedium),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SafeArea(
                        minimum: const EdgeInsets.all(18),
                        child: GlassBar(
                          child: Row(
                            children: [
                              IconButton(
                                  onPressed: () {},
                                  icon:
                                      const Icon(Icons.skip_previous_rounded)),
                              Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      MuslimKuColors.primaryContainer,
                                      MuslimKuColors.primary
                                    ],
                                  ),
                                ),
                                child: const Icon(Icons.play_arrow_rounded,
                                    color: Colors.white, size: 32),
                              ),
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.skip_next_rounded)),
                              const Spacer(),
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.format_size_rounded)),
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.translate_rounded)),
                              IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                      Icons.bookmark_border_rounded)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuranSearchScreen extends StatelessWidget {
  const QuranSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DetailScaffold(
      title: 'Pencarian',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SearchField(
              hint: 'Cari Surah, Ayat, atau Kata Kunci...',
              initialValue: 'Sabar'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Hasil untuk "Sabar"',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: MuslimKuColors.surfaceLow,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('12 kecocokan',
                    style: Theme.of(context).textTheme.labelMedium),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                FilterChipPill(label: 'Semua Hasil', active: true),
                SizedBox(width: 10),
                FilterChipPill(label: 'Hanya Terjemahan'),
                SizedBox(width: 10),
                FilterChipPill(label: 'Teks Arab'),
                SizedBox(width: 10),
                FilterChipPill(label: 'Nama Surah'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ...searchResults.map(
            (result) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: SurfaceCard(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result.surah,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: MuslimKuColors.primary),
                              ),
                              const SizedBox(height: 4),
                              Text(result.reference,
                                  style:
                                      Theme.of(context).textTheme.labelMedium),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: MuslimKuColors.surfaceLow,
                          child: Icon(Icons.bookmark_border_rounded,
                              size: 18, color: MuslimKuColors.textSoft),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      result.arabic,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontSize: 30, height: 1.7),
                    ),
                    const SizedBox(height: 14),
                    Text(result.translation,
                        style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TafsirScreen extends StatelessWidget {
  const TafsirScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DetailScaffold(
      title: 'Al-Baqarah: 255',
      subtitle: 'Ayatul Kursi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SurfaceCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontSize: 34, height: 1.8),
                ),
                const SizedBox(height: 18),
                const Divider(),
                const SizedBox(height: 14),
                Text(
                  '"Allah, tidak ada Tuhan selain Dia, Yang Maha Hidup, Yang terus-menerus mengurus..."',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SurfaceCard(
            color: MuslimKuColors.surfaceLow,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: MuslimKuColors.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('Tafsir Ibn Kathir',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(color: MuslimKuColors.primary)),
                  ],
                ),
                const SizedBox(height: 22),
                ...tafsirParagraphs.map(
                  (paragraph) => Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Text(paragraph, style: theme.textTheme.bodyLarge),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AudioPlayerScreen extends StatelessWidget {
  const AudioPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DetailScaffold(
      title: 'Sedang Diputar',
      child: Column(
        children: [
          SurfaceCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        MuslimKuColors.primaryContainer.withValues(alpha: 0.95),
                        MuslimKuColors.primary.withValues(alpha: 0.70),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Center(
                          child: Icon(Icons.auto_stories_rounded,
                              size: 120,
                              color: Colors.white.withValues(alpha: 0.15)),
                        ),
                      ),
                      Positioned(
                        left: 24,
                        right: 24,
                        bottom: 24,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Surah',
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(color: Colors.white70)),
                                  const SizedBox(height: 8),
                                  Text('Al-Mulk',
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(color: Colors.white)),
                                ],
                              ),
                            ),
                            Text(
                              'سورة الملك',
                              textDirection: TextDirection.rtl,
                              style: theme.textTheme.headlineSmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Text('Mishary Rashid Alafasy',
                    style:
                        theme.textTheme.headlineSmall?.copyWith(fontSize: 28)),
                const SizedBox(height: 6),
                Text('6:42 • The Sovereignty',
                    style: theme.textTheme.bodyMedium),
                const SizedBox(height: 24),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: 0.33,
                    minHeight: 8,
                    backgroundColor: MuslimKuColors.surfaceContainer,
                    color: MuslimKuColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('02:14',
                        style: TextStyle(
                            color: MuslimKuColors.textSoft,
                            fontWeight: FontWeight.w600)),
                    Text('06:42',
                        style: TextStyle(
                            color: MuslimKuColors.textSoft,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shuffle_rounded,
                        color: MuslimKuColors.textSoft, size: 28),
                    const SizedBox(width: 24),
                    const Icon(Icons.skip_previous_rounded,
                        color: MuslimKuColors.primary, size: 40),
                    const SizedBox(width: 18),
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            MuslimKuColors.primaryContainer,
                            MuslimKuColors.primary
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                MuslimKuColors.primary.withValues(alpha: 0.25),
                            blurRadius: 24,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.pause_rounded,
                          color: Colors.white, size: 42),
                    ),
                    const SizedBox(width: 18),
                    const Icon(Icons.skip_next_rounded,
                        color: MuslimKuColors.primary, size: 40),
                    const SizedBox(width: 24),
                    Icon(Icons.repeat_rounded,
                        color: MuslimKuColors.textSoft, size: 28),
                  ],
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Expanded(
                        child: ChipButton(
                            icon: Icons.playlist_add_rounded,
                            label: 'Antrian')),
                    SizedBox(width: 12),
                    Expanded(
                        child: ChipButton(
                            icon: Icons.share_rounded, label: 'Bagikan')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.initialProfile,
  });

  final ProfileData initialProfile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _fullNameController =
        TextEditingController(text: widget.initialProfile.fullName);
    _emailController = TextEditingController(text: widget.initialProfile.email);
    _phoneController = TextEditingController(text: widget.initialProfile.phone);
    _bioController = TextEditingController(text: widget.initialProfile.bio);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _deriveInitials(_fullNameController.text);

    return Scaffold(
      backgroundColor: MuslimKuColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Stack(
                  children: [
                    ListView(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 140),
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ubah Profil',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: MuslimKuColors.primary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Muslimku',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: MuslimKuColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Column(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 136,
                                  height: 136,
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(
                                      color: MuslimKuColors.primary
                                          .withValues(alpha: 0.10),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.05),
                                        blurRadius: 24,
                                        offset: const Offset(0, 12),
                                      ),
                                    ],
                                  ),
                                  child: ProfileAvatar(
                                      initials: initials, size: 124),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 4,
                                  child: Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: MuslimKuColors.primaryContainer,
                                      boxShadow: [
                                        BoxShadow(
                                          color: MuslimKuColors.primary
                                              .withValues(alpha: 0.20),
                                          blurRadius: 16,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.photo_camera_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(_fullNameController.text,
                                style: theme.textTheme.headlineSmall),
                            const SizedBox(height: 6),
                            Text(
                              'Bergabung sejak ${widget.initialProfile.memberSince}',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(letterSpacing: 0.2),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _ProfileFieldCard(
                          label: 'Nama Lengkap',
                          child: TextField(
                            controller: _fullNameController,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(fontSize: 24),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _ProfileFieldCard(
                          label: 'Alamat Email',
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    filled: false,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: theme.textTheme.titleMedium,
                                ),
                              ),
                              Icon(
                                Icons.verified_rounded,
                                color: MuslimKuColors.primary
                                    .withValues(alpha: 0.45),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _ProfileFieldCard(
                          label: 'Nomor Telepon',
                          child: TextField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _ProfileFieldCard(
                          label: 'Bio / Motto Pribadi',
                          trailing: Text(
                            '${_bioController.text.length}/200',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: MuslimKuColors.textSoft,
                            ),
                          ),
                          child: TextField(
                            controller: _bioController,
                            maxLines: 3,
                            maxLength: 200,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              counterText: '',
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: MuslimKuColors.surfaceLow,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: MuslimKuColors.primary
                                      .withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.shield_moon_rounded,
                                  color: MuslimKuColors.primary,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Privasi Terjaga',
                                        style: theme.textTheme.titleMedium),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Data profil Anda tetap berada di aplikasi ini dan hanya dipakai untuk mempersonalisasi pengalaman Muslimku.',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              MuslimKuColors.background.withValues(alpha: 0),
                              MuslimKuColors.background.withValues(alpha: 0.92),
                              MuslimKuColors.background,
                            ],
                          ),
                        ),
                        child: SafeArea(
                          top: false,
                          child: SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: MuslimKuColors.primary,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: _saveProfile,
                              icon: const Icon(Icons.check_circle_rounded),
                              label: const Text('Simpan Perubahan'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveProfile() {
    Navigator.of(context).pop(
      widget.initialProfile.copyWith(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        bio: _bioController.text.trim(),
      ),
    );
  }

  String _deriveInitials(String value) {
    final parts = value
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .take(2)
        .toList();
    if (parts.isEmpty) return widget.initialProfile.initials;
    return parts.map((part) => part.substring(0, 1).toUpperCase()).join();
  }
}

class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: SurfaceCard(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: MuslimKuColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: MuslimKuColors.primary,
                size: 42,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Keluar dari Muslimku?',
              style: theme.textTheme.headlineSmall?.copyWith(fontSize: 32),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Anda akan kembali ke awal aplikasi dan sesi demo saat ini akan diakhiri.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: MuslimKuColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                onPressed: onConfirm,
                child: const Text('Keluar'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: MuslimKuColors.textSoft,
                  side: BorderSide(
                      color: MuslimKuColors.outline.withValues(alpha: 0.50)),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                onPressed: onCancel,
                child: const Text('Batal'),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Semoga damai menyertai Anda',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileFieldCard extends StatelessWidget {
  const _ProfileFieldCard({
    required this.label,
    required this.child,
    this.trailing,
  });

  final String label;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: MuslimKuColors.primary,
                      letterSpacing: 1.4,
                    ),
              ),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _CompassVisual extends StatelessWidget {
  const _CompassVisual({
    required this.bearingDegrees,
    required this.cardinal,
  });

  final double bearingDegrees;
  final String cardinal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                color: MuslimKuColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: MuslimKuColors.primary.withValues(alpha: 0.06),
                    blurRadius: 80,
                    spreadRadius: 14,
                  ),
                ],
              ),
            ),
            Container(
              width: 288,
              height: 288,
              decoration: BoxDecoration(
                color: MuslimKuColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                    color: MuslimKuColors.surfaceContainer, width: 8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: CustomPaint(
                        painter: _CompassDialPainter(),
                      ),
                    ),
                  ),
                  const _CompassCardinals(),
                  Transform.rotate(
                    angle: bearingDegrees * math.pi / 180,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: MuslimKuColors.primary,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: MuslimKuColors.primary
                                    .withValues(alpha: 0.22),
                                blurRadius: 20,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.mosque_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: 4,
                          height: 112,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                MuslimKuColors.primary,
                                MuslimKuColors.primaryContainer,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        Container(
                          width: 10,
                          height: 42,
                          decoration: BoxDecoration(
                            color: MuslimKuColors.primaryContainer
                                .withValues(alpha: 0.16),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(999),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: MuslimKuColors.surfaceHighest,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      '${bearingDegrees.toInt()}°',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: MuslimKuColors.primary,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cardinal,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: MuslimKuColors.textSoft,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompassCardinals extends StatelessWidget {
  const _CompassCardinals();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: MuslimKuColors.textSoft,
        );

    return Stack(
      children: [
        Positioned(
            top: 22,
            left: 0,
            right: 0,
            child: Center(child: Text('N', style: style))),
        Positioned(
            bottom: 22,
            left: 0,
            right: 0,
            child: Center(child: Text('S', style: style))),
        Positioned(
            left: 24,
            top: 0,
            bottom: 0,
            child: Center(child: Text('W', style: style))),
        Positioned(
            right: 24,
            top: 0,
            bottom: 0,
            child: Center(child: Text('E', style: style))),
      ],
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final ringPaint = Paint()
      ..color = MuslimKuColors.outline.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(center, radius - 14, ringPaint);

    for (var i = 0; i < 60; i++) {
      final angle = (math.pi * 2 * i / 60) - math.pi / 2;
      final isMajor = i % 15 == 0;
      final isMedium = i % 5 == 0;
      final tickLength = isMajor
          ? 16.0
          : isMedium
              ? 10.0
              : 6.0;
      final tickPaint = Paint()
        ..color = isMajor
            ? MuslimKuColors.primary.withValues(alpha: 0.25)
            : MuslimKuColors.outline.withValues(alpha: isMedium ? 0.28 : 0.16)
        ..strokeWidth = isMajor ? 2.2 : 1.4
        ..strokeCap = StrokeCap.round;

      final start = Offset(
        center.dx + math.cos(angle) * (radius - 30 - tickLength),
        center.dy + math.sin(angle) * (radius - 30 - tickLength),
      );
      final end = Offset(
        center.dx + math.cos(angle) * (radius - 30),
        center.dy + math.sin(angle) * (radius - 30),
      );

      canvas.drawLine(start, end, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QiblaBottomItem extends StatelessWidget {
  const _QiblaBottomItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final item = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: MuslimKuColors.textSoft, size: 22),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: MuslimKuColors.textSoft,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );

    if (onTap == null) return item;

    return GestureDetector(onTap: onTap, child: item);
  }
}

class _QiblaActiveBottomItem extends StatelessWidget {
  const _QiblaActiveBottomItem({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: MuslimKuColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: MuslimKuColors.primary.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
