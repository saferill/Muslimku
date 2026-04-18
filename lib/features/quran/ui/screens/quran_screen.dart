import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../di/injection.dart';
import '../../../../routes/route_names.dart';
import '../../../audio/ui/screens/audio_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppDependenciesScope.of(context).quranController;

    return Scaffold(
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final surahs = controller.surahs(query: _searchController.text);

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Expanded(
                      child: Text(
                        'Jelajahi Al-Qur\'an',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AudioScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.headphones_rounded),
                    ),
                    IconButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(RouteNames.bookmarks),
                      icon: const Icon(Icons.bookmark_border_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'AL-QUR\'AN AL-KAREEM',
                  style: TextStyle(
                    color: AppColors.tertiary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  decoration: InputDecoration(
                    hintText: 'Cari surah, ayat, atau topik',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(RouteNames.reader),
                      icon: const Icon(Icons.auto_stories_rounded),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (controller.isBootstrapping)
                  ...List<Widget>.generate(
                    6,
                    (index) => Container(
                      height: 92,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  )
                else if (controller.error != null)
                  Column(
                    children: <Widget>[
                      Text(
                        controller.error!,
                        style: const TextStyle(color: AppColors.error),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: controller.bootstrap,
                        child: const Text('Retry'),
                      ),
                    ],
                  )
                else if (surahs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No data',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                else
                  ...surahs.map(
                    (surah) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => Navigator.of(context).pushNamed(
                          RouteNames.surahDetail,
                          arguments: surah,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 22,
                                backgroundColor:
                                    AppColors.primary.withValues(alpha: 0.12),
                                child: Text(
                                  '${surah.number}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      surah.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${surah.meaning} • ${surah.ayahCount} ayat • ${surah.origin}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                surah.arabic,
                                style: const TextStyle(
                                  fontSize: 26,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
