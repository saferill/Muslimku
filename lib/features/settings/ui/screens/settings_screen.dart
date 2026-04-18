import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../di/injection.dart';
import '../../../../routes/route_names.dart';
import '../../../../shared/components/bottom_sheets/location_bottom_sheet.dart';
import '../widgets/settings_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dependencies = AppDependenciesScope.of(context);
    final authController = dependencies.authController;
    final settings = dependencies.settingsController;

    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        authController,
        dependencies.audioController,
        dependencies.notificationController,
        dependencies.quranController,
        dependencies.securityController,
      ]),
      builder: (context, _) {
        final state = settings.state;
        final security = dependencies.securityController;
        final notificationController = dependencies.notificationController;

        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 34,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.12),
                      child: Text(
                        state.user.initials,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            state.user.fullName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.isGuest
                                ? 'Mode tamu • ${state.interfaceLanguage}'
                                : '${state.user.memberSince} • ${state.interfaceLanguage}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (notificationController.hasUnread)
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.tertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 26),
                _Section(
                  title: 'Akun',
                  children: <Widget>[
                    SettingsTile(
                      icon: Icons.person_outline_rounded,
                      title: state.isGuest ? 'Sign In / Sign Up' : 'Edit Profil',
                      subtitle: state.isGuest
                          ? 'Masuk untuk sinkronisasi cloud dan multi-device'
                          : state.user.email,
                      onTap: () => Navigator.of(context).pushNamed(
                        state.isGuest ? RouteNames.login : RouteNames.account,
                      ),
                    ),
                    if (!state.isGuest)
                      SettingsTile(
                        icon: Icons.lock_reset_rounded,
                        title: 'Ubah Password',
                        onTap: () => Navigator.of(context)
                            .pushNamed(RouteNames.changePassword),
                      ),
                    if (!state.isGuest)
                      SettingsTile(
                        icon: Icons.sync_rounded,
                        title: 'Sinkronkan Data Cloud',
                        subtitle:
                            '${settings.bookmarkCount} bookmark - ${settings.noteCount} note',
                        onTap: () async {
                          await settings.syncCloudData();
                          if (!context.mounted) return;
                          context.showAppSnack('Sinkronisasi cloud selesai.');
                        },
                      ),
                    if (!state.isGuest)
                      SettingsTile(
                        icon: Icons.delete_forever_outlined,
                        title: 'Hapus Akun',
                        subtitle: 'Hapus akun dan data cloud permanen',
                        onTap: () => Navigator.of(context)
                            .pushNamed(RouteNames.deleteAccount),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _Section(
                  title: 'Ibadah',
                  children: <Widget>[
                    SettingsTile(
                      icon: Icons.notifications_active_rounded,
                      title: 'Pengaturan Notifikasi',
                      subtitle: dependencies.adzanController.masterEnabled
                          ? 'Adzan alerts aktif'
                          : 'Adzan alerts nonaktif',
                      onTap: () => Navigator.of(context)
                          .pushNamed(RouteNames.notificationSettings),
                    ),
                    SettingsTile(
                      icon: Icons.translate_rounded,
                      title: 'Bahasa Antarmuka',
                      subtitle: state.interfaceLanguage,
                      onTap: () => _showLanguageSheet(context),
                    ),
                    SettingsTile(
                      icon: Icons.location_on_outlined,
                      title: 'Lokasi Salat Saat Ini',
                      subtitle: state.currentLocation,
                      onTap: () => _showPrayerLocationSheet(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Section(
                  title: 'Qur\'an & Audio',
                  children: <Widget>[
                    SettingsTile(
                      icon: Icons.menu_book_rounded,
                      title: 'Pengaturan Qur\'an',
                      subtitle: state.translation,
                      onTap: () => Navigator.of(context)
                          .pushNamed(RouteNames.quranSettings),
                    ),
                    SettingsTile(
                      icon: Icons.headphones_rounded,
                      title: 'Pengaturan Audio',
                      subtitle:
                          '${state.quranReciter} - ${settings.downloadedAudioCount} offline',
                      onTap: () => Navigator.of(context)
                          .pushNamed(RouteNames.audioSettings),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Section(
                  title: 'Kelola Data',
                  children: <Widget>[
                    SettingsTile(
                      icon: Icons.ios_share_rounded,
                      title: 'Ekspor Data Lokal',
                      subtitle:
                          'Bookmark, notes, settings, recent search, playlist',
                      onTap: () => _exportLocalData(context),
                    ),
                    SettingsTile(
                      icon: Icons.file_download_done_rounded,
                      title: 'Impor Data Lokal',
                      subtitle: 'Tempel JSON hasil ekspor untuk restore',
                      onTap: () => _showImportDialog(context),
                    ),
                    SettingsTile(
                      icon: Icons.cleaning_services_rounded,
                      title: 'Bersihkan Cache',
                      subtitle:
                          'Bersihkan recent search, inbox, dan cache reader',
                      onTap: () async {
                        await settings.clearOperationalCache();
                        if (!context.mounted) return;
                        context.showAppSnack('Cache operasional dibersihkan.');
                      },
                    ),
                    SettingsTile(
                      icon: Icons.folder_delete_outlined,
                      title: 'Hapus Unduhan',
                      subtitle:
                          '${settings.downloadedAudioCount} audio offline akan dihapus',
                      onTap: () async {
                        await settings.clearDownloads();
                        if (!context.mounted) return;
                        context.showAppSnack('Semua unduhan audio dihapus.');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Section(
                  title: 'Keamanan',
                  children: <Widget>[
                    SettingsTile(
                      icon: Icons.pin_outlined,
                      title: security.pinEnabled
                          ? 'Ubah PIN'
                          : 'Atur PIN Keamanan',
                      subtitle: security.pinEnabled
                          ? 'PIN aktif untuk membuka aplikasi'
                          : 'Tambahkan PIN untuk kunci aplikasi',
                      onTap: () => _showPinDialog(context),
                    ),
                    SettingsTile(
                      icon: Icons.fingerprint_rounded,
                      title: 'Biometrik',
                      subtitle: security.biometricsAvailable
                          ? (security.biometricsEnabled
                              ? 'Biometric unlock aktif'
                              : 'Gunakan sidik jari atau wajah untuk membuka aplikasi')
                          : 'Biometrik belum tersedia di perangkat ini',
                      onTap: () {
                        if (!security.pinEnabled) {
                          context.showAppSnack(
                            'Atur PIN keamanan dulu sebelum mengaktifkan biometrik.',
                          );
                          return;
                        }
                        if (!security.biometricsAvailable) {
                          context.showAppSnack(
                            'Biometrik belum tersedia di perangkat ini.',
                          );
                          return;
                        }
                        security.setBiometricsEnabled(
                          !security.biometricsEnabled,
                        );
                        context.showAppSnack(
                          security.biometricsEnabled
                              ? 'Biometrik diaktifkan.'
                              : 'Biometrik dinonaktifkan.',
                        );
                      },
                      trailing: Switch.adaptive(
                        value: security.biometricsEnabled,
                        onChanged: security.pinEnabled &&
                                security.biometricsAvailable
                            ? (value) => security.setBiometricsEnabled(value)
                            : null,
                      ),
                    ),
                    SettingsTile(
                      icon: Icons.timer_outlined,
                      title: 'Auto Lock',
                      subtitle:
                          'Kunci app setelah ${security.autoLockMinutes} menit di background',
                      onTap: () => _showAutoLockSheet(context),
                    ),
                    SettingsTile(
                      icon: Icons.lock_clock_rounded,
                      title: 'Kunci Sekarang',
                      subtitle: 'Kunci aplikasi saat ini juga',
                      onTap: () {
                        if (!security.pinEnabled) {
                          context.showAppSnack(
                            'Atur PIN keamanan dulu untuk memakai fitur ini.',
                          );
                          return;
                        }
                        security.lockNow();
                        context.showAppSnack('Aplikasi dikunci.');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Section(
                  title: 'Bantuan',
                  children: <Widget>[
                    SettingsTile(
                      icon: Icons.help_outline_rounded,
                      title: 'FAQ',
                      subtitle: 'Masalah umum tentang akun, sync, dan audio',
                      onTap: () => _showFaq(context),
                    ),
                    SettingsTile(
                      icon: Icons.support_agent_rounded,
                      title: 'Hubungi Dukungan',
                      subtitle: AppConstants.supportEmail,
                      onTap: () => _contactSupport(context),
                    ),
                    SettingsTile(
                      icon: Icons.bug_report_outlined,
                      title: 'Laporkan Bug',
                      subtitle:
                          'Kirim laporan bug lewat email atau share sheet',
                      onTap: () => _reportBug(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Section(
                  title: 'Tentang',
                  children: <Widget>[
                    SettingsTile(
                      icon: Icons.cloud_outlined,
                      title: 'Status Sistem',
                      subtitle: 'Empty, offline, and error previews',
                      onTap: () => Navigator.of(context)
                          .pushNamed(RouteNames.systemStates),
                    ),
                    SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: 'Tentang Muslimku',
                      subtitle:
                          '${AppConstants.appVersion} - ${AppConstants.appBuild}',
                      onTap: () =>
                          Navigator.of(context).pushNamed(RouteNames.about),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (state.isGuest)
                  FilledButton.icon(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(RouteNames.login),
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Sign In untuk Sinkronisasi'),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context)
                        .pushNamed(RouteNames.logoutConfirmation),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Keluar'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPinDialog(BuildContext context) async {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();
    final security = AppDependenciesScope.of(context).securityController;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(security.pinEnabled ? 'Ubah PIN' : 'Atur PIN Keamanan'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'PIN',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'Konfirmasi PIN',
                    counterText: '',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            if (security.pinEnabled)
              TextButton(
                onPressed: () async {
                  await security.disablePin();
                  if (!dialogContext.mounted) return;
                  Navigator.of(dialogContext).pop();
                  if (!context.mounted) return;
                  context.showAppSnack('PIN keamanan dinonaktifkan.');
                },
                child: const Text('Nonaktifkan PIN'),
              ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                final pin = pinController.text.trim();
                final confirm = confirmController.text.trim();
                if (pin.length < 4 || pin != confirm) {
                  if (!context.mounted) return;
                  context.showAppSnack('PIN minimal 4 digit dan harus sama.');
                  return;
                }
                await security.configurePin(pin);
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                if (!context.mounted) return;
                context.showAppSnack('PIN keamanan diperbarui.');
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAutoLockSheet(BuildContext context) async {
    final security = AppDependenciesScope.of(context).securityController;
    const options = <int>[1, 2, 5, 10, 15];
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: options.map((minutes) {
              final selected = minutes == security.autoLockMinutes;
              return ListTile(
                title: Text('$minutes menit'),
                trailing: selected
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                      )
                    : null,
                onTap: () async {
                  await security.setAutoLockMinutes(minutes);
                  if (!sheetContext.mounted) return;
                  Navigator.of(sheetContext).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _showLanguageSheet(BuildContext context) async {
    final dependencies = AppDependenciesScope.of(context);
    final settings = dependencies.settingsController;
    final current = settings.state.interfaceLanguage;
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: AppConstants.interfaceLanguages.map((language) {
              final selected = language == current;
              return ListTile(
                title: Text(language),
                trailing: selected
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                      )
                    : null,
                onTap: () {
                  settings.updateLanguage(language);
                  Navigator.of(sheetContext).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _showPrayerLocationSheet(BuildContext context) async {
    final dependencies = AppDependenciesScope.of(context);
    final auth = dependencies.authController;
    final adzan = dependencies.adzanController;

    await showModalBottomSheet<void>(
      context: context,
      builder: (_) {
        return LocationBottomSheet(
          currentValue: auth.state.currentLocation,
          onAutoDetect: () async {
            final permissionMessage = await auth.enableLocation();
            final gpsMessage = await adzan.detectAndSyncCurrentLocation();
            if (!context.mounted) return;
            context.showAppSnack(
              gpsMessage ?? permissionMessage ?? 'Lokasi salat diperbarui.',
            );
          },
          onSelected: (value) async {
            auth.updateLocation(value);
            await adzan.syncLocation(value);
            if (!context.mounted) return;
            context.showAppSnack('Lokasi salat diperbarui ke $value.');
          },
        );
      },
    );
  }

  Future<void> _exportLocalData(BuildContext context) async {
    final settings = AppDependenciesScope.of(context).settingsController;
    final data = await settings.exportDataJson();
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Ekspor Data JSON',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: SingleChildScrollView(
                    child: SelectableText(data),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: data));
                          if (!sheetContext.mounted) return;
                          Navigator.of(sheetContext).pop();
                          context.showAppSnack('JSON ekspor disalin.');
                        },
                        icon: const Icon(Icons.copy_rounded),
                        label: const Text('Salin'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          await SharePlus.instance.share(
                            ShareParams(
                              text: data,
                              subject: 'Muslimku local data export',
                            ),
                          );
                        },
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('Bagikan'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showImportDialog(BuildContext context) async {
    final controller = TextEditingController();
    final settings = AppDependenciesScope.of(context).settingsController;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Impor Data Lokal'),
          content: SizedBox(
            width: 520,
            child: TextField(
              controller: controller,
              maxLines: 12,
              decoration: const InputDecoration(
                hintText: 'Tempel JSON ekspor di sini',
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                final message = await settings.importDataJson(controller.text);
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                if (!context.mounted || message == null) return;
                context.showAppSnack(message);
              },
              child: const Text('Impor'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _contactSupport(BuildContext context) async {
    const subject = 'Muslimku Support Request';
    final body =
        'Halo tim Muslimku,\n\nSaya butuh bantuan terkait aplikasi.\n\n'
        'Versi: ${AppConstants.appVersion} (${AppConstants.appBuild})\n'
        'Masalah saya:\n- ';
    final launched = await _launchMailClient(
      email: AppConstants.supportEmail,
      subject: subject,
      body: body,
    );
    if (launched) return;

    await Clipboard.setData(
      const ClipboardData(text: AppConstants.supportEmail),
    );
    await SharePlus.instance.share(
      ShareParams(
        text: '$body\n\nEmail tujuan: ${AppConstants.supportEmail}',
        subject: subject,
      ),
    );
    if (!context.mounted) return;
    context.showAppSnack(
      'Aplikasi email tidak tersedia. Template support dibagikan.',
    );
  }

  Future<void> _reportBug(BuildContext context) async {
    final dependencies = AppDependenciesScope.of(context);
    final state = dependencies.authController.state;
    final bugReport = '''
Bug report Muslimku

Versi app: ${AppConstants.appVersion} (${AppConstants.appBuild})
Mode: ${state.isGuest ? 'Guest' : 'Authenticated'}
Lokasi: ${state.currentLocation}
Bahasa: ${state.interfaceLanguage}
Qari: ${state.quranReciter}
Masalah:
- 

Langkah reproduksi:
1. 
2. 
3. 

Hasil yang diharapkan:
- 

Hasil aktual:
- 
''';
    final launched = await _launchMailClient(
      email: AppConstants.supportEmail,
      subject: 'Muslimku Bug Report',
      body: bugReport,
    );
    if (launched) return;

    await SharePlus.instance.share(
      ShareParams(
        text: bugReport,
        subject: 'Muslimku Bug Report',
      ),
    );
    if (!context.mounted) return;
    context.showAppSnack(
      'Aplikasi email tidak tersedia. Template bug report dibagikan.',
    );
  }

  Future<void> _showFaq(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('FAQ'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _FaqEntry(
                  question: 'Kenapa bookmark guest tidak sync?',
                  answer:
                      'Mode guest hanya menyimpan data lokal di perangkat. Sign In diperlukan untuk sinkronisasi cloud.',
                ),
                _FaqEntry(
                  question: 'Bagaimana mengaktifkan adzan lokal?',
                  answer:
                      'Buka Adzan atau Notification Settings, aktifkan master adzan, lalu beri izin notifikasi.',
                ),
                _FaqEntry(
                  question: 'Apakah audio Quran bisa offline?',
                  answer:
                      'Bisa. Buka Audio screen, unduh surah, lalu file akan tersedia untuk pemutaran lokal.',
                ),
                _FaqEntry(
                  question: 'Bagaimana memindahkan data ke perangkat lain?',
                  answer:
                      'Gunakan Export Local Data di Settings lalu Import Local Data di perangkat tujuan.',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _launchMailClient({
    required String email,
    required String subject,
    required String body,
  }) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: <String, String>{
        'subject': subject,
        'body': body,
      },
    );
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _FaqEntry extends StatelessWidget {
  const _FaqEntry({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(answer, style: const TextStyle(height: 1.45)),
        ],
      ),
    );
  }
}
