import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../di/injection.dart';
import '../../../../routes/route_names.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../quran/ui/screens/quran_screen.dart';

class SystemStatesScreen extends StatelessWidget {
  const SystemStatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependenciesScope.of(context);
    final quranController = dependencies.quranController;
    final notificationController = dependencies.notificationController;
    final adzanController = dependencies.adzanController;

    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        quranController,
        notificationController,
        adzanController,
      ]),
      builder: (context, _) {
        final hasBookmarks = quranController.bookmarks.isNotEmpty;
        final hasNotifications = notificationController.items.isNotEmpty;
        final hasAdzanError = (adzanController.error ?? '').isNotEmpty;

        return Scaffold(
          appBar: AppBar(title: const Text('Status Sistem')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: <Widget>[
                _StateCard(
                  title: hasBookmarks
                      ? '${quranController.bookmarks.length} bookmark tersimpan'
                      : 'Belum ada bookmark tersimpan',
                  description: hasBookmarks
                      ? 'Bookmark, highlight, dan catatan lokalmu sudah tersedia. Kamu bisa membukanya kembali kapan saja.'
                      : 'Mulai perjalanan ibadah dengan menyimpan ayat dan doa yang ingin kamu buka lagi nanti.',
                  icon: hasBookmarks
                      ? Icons.bookmark_added_rounded
                      : Icons.bookmark_border_rounded,
                  actionLabel: hasBookmarks ? 'Buka Bookmark' : 'Buka Qur\'an',
                  onPressed: () {
                    if (hasBookmarks) {
                      Navigator.of(context).pushNamed(RouteNames.bookmarks);
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const QuranScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _StateCard(
                  title: hasAdzanError
                      ? 'Jadwal adzan perlu diperbarui'
                      : 'Jadwal adzan lokal aktif',
                  description: hasAdzanError
                      ? adzanController.error!
                      : 'Notifikasi adzan lokal tersusun di perangkat ini. Kamu bisa menjadwalkan ulang jika lokasi atau metode perhitungan berubah.',
                  icon: hasAdzanError
                      ? Icons.error_outline_rounded
                      : Icons.schedule_rounded,
                  actionLabel: 'Segarkan Jadwal',
                  color: hasAdzanError ? AppColors.error : AppColors.primary,
                  onPressed: () async {
                    await adzanController.scheduleUpcomingNotifications();
                    if (!context.mounted) return;
                    context.showAppSnack(
                      adzanController.error == null
                          ? 'Jadwal adzan berhasil diperbarui.'
                          : adzanController.error!,
                    );
                  },
                ),
                const SizedBox(height: 16),
                _StateCard(
                  title: hasNotifications
                      ? '${notificationController.items.length} notifikasi tersedia'
                      : 'Belum ada notifikasi tersimpan',
                  description: hasNotifications
                      ? 'Pusat notifikasi menyimpan pengingat adzan, reminder, dan refleksi ayat harian yang aktif di perangkat ini.'
                      : 'Saat ada pengingat adzan, refleksi ayat harian, atau reminder lokal, semuanya akan tampil di pusat notifikasi.',
                  icon: hasNotifications
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_none_rounded,
                  actionLabel:
                      hasNotifications ? 'Buka Notifikasi' : 'Muat Ulang Inbox',
                  onPressed: () async {
                    if (hasNotifications) {
                      Navigator.of(context).pushNamed(RouteNames.notifications);
                      return;
                    }
                    await notificationController.reload();
                    if (!context.mounted) return;
                    context.showAppSnack(
                      'Pusat notifikasi lokal dimuat ulang.',
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.actionLabel,
    required this.onPressed,
    this.color = AppColors.primary,
  });

  final String title;
  final String description;
  final IconData icon;
  final String actionLabel;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              height: 1.55,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: actionLabel,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
