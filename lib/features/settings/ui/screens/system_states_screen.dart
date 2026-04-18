import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../../quran/ui/screens/quran_screen.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';

class SystemStatesScreen extends StatelessWidget {
  const SystemStatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Status Sistem')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            _StateCard(
              title: 'Belum ada yang disimpan',
              description:
                  'Mulai perjalanan ibadah dengan menyimpan ayat dan doa yang ingin kamu buka lagi nanti.',
              icon: Icons.bookmark_border_rounded,
              actionLabel: 'Buka Quran',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const QuranScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _StateCard(
              title: 'Koneksi terputus',
              description:
                  'Kami kesulitan menjangkau server. Periksa internet lalu coba lagi.',
              icon: Icons.wifi_off_rounded,
              actionLabel: 'Retry',
              color: AppColors.error,
              onPressed: () => context.showAppSnack(
                'Retry dipicu. Jika jaringan sudah kembali, data akan dimuat ulang saat layar terkait dibuka.',
              ),
            ),
            const SizedBox(height: 16),
            _StateCard(
              title: 'Ibadah tetap bisa dilanjutkan.',
              description:
                  'Kamu sedang offline, tetapi konten yang sudah tersedia tetap bisa dibuka dari perangkat ini.',
              icon: Icons.cloud_off_rounded,
              actionLabel: 'Lanjut Offline',
              onPressed: () {
                Navigator.of(context).pop();
                context.showAppSnack('Mode offline lokal tetap tersedia.');
              },
            ),
          ],
        ),
      ),
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
