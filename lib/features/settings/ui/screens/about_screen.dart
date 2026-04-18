import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/helpers.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Muslimku')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Text(
                'Muslimku ${AppConstants.appVersion}\n${AppConstants.appBuild}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Muslimku dibuat untuk pengalaman ibadah yang lebih tenang, jelas, dan terarah. Aplikasi ini mencakup pembacaan Qur\'an, jadwal adzan, audio, bookmark, pencarian, notifikasi, dan preferensi yang bisa tersinkron ke cloud.',
              style: TextStyle(height: 1.6),
            ),
            const SizedBox(height: 18),
            _card(
              title: 'Syarat Layanan',
              body:
                  'Dengan menggunakan Muslimku, kamu menyetujui penggunaan data lokal dan sinkronisasi akun sesuai pengaturan yang kamu aktifkan.',
            ),
            const SizedBox(height: 12),
            _card(
              title: 'Kebijakan Privasi',
              body:
                  'Data mode tamu tetap lokal. Saat login, bookmark, last read, dan preferensi penting dapat disinkronkan ke cloud akunmu.',
            ),
            const SizedBox(height: 12),
            _card(
              title: 'Dukungan',
              body:
                  'Hubungi ${AppConstants.supportEmail} untuk bantuan atau gunakan menu Laporkan Bug dari Pengaturan.',
              trailing: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  FilledButton.icon(
                    onPressed: () async {
                      final uri = Uri(
                        scheme: 'mailto',
                        path: AppConstants.supportEmail,
                        queryParameters: const <String, String>{
                          'subject': 'Muslimku Support Request',
                        },
                      );
                      final launched = await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                      if (launched || !context.mounted) return;
                      context.showAppSnack('Aplikasi email tidak tersedia.');
                    },
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Email Dukungan'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(
                        const ClipboardData(text: AppConstants.supportEmail),
                      );
                      if (!context.mounted) return;
                      context.showAppSnack('Email support disalin.');
                    },
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Salin Email'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({
    required String title,
    required String body,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              height: 1.55,
              color: AppColors.textSecondary,
            ),
          ),
          if (trailing != null) ...<Widget>[
            const SizedBox(height: 16),
            trailing,
          ],
        ],
      ),
    );
  }
}
