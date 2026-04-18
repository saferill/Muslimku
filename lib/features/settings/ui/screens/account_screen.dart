import 'package:flutter/material.dart';

import '../../../../core/utils/helpers.dart';
import '../../../../di/injection.dart';
import '../../../../routes/route_names.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _bioController;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final user = AppDependenciesScope.of(context).settingsController.state.user;
    _nameController = TextEditingController(text: user.fullName);
    _emailController = TextEditingController(text: user.email);
    _bioController = TextEditingController(text: user.bio);
    _initialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppDependenciesScope.of(context).settingsController;
    final isGuest = settings.state.isGuest;

    return Scaffold(
      appBar: AppBar(title: const Text('Akun')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            if (isGuest) ...<Widget>[
              const Text(
                'Fitur akun penuh membutuhkan login.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Ke Login',
                onPressed: () =>
                    Navigator.of(context).pushNamed(RouteNames.login),
              ),
              const SizedBox(height: 24),
            ],
            AppTextField(
              controller: _nameController,
              label: 'Nama Lengkap',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _emailController,
              label: 'Alamat Email',
              icon: Icons.mail_outline_rounded,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Jika email diubah, link verifikasi akan dikirim ke email baru. Sampai diverifikasi, email login lama tetap dipakai.',
                style: TextStyle(color: Colors.grey, height: 1.4),
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _bioController,
              label: 'Bio',
              icon: Icons.edit_note_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: 22),
            PrimaryButton(
              label: 'Perbarui Profil',
              onPressed: isGuest
                  ? null
                  : () async {
                      final message = await settings.updateProfile(
                        UserModel(
                          uid: settings.state.user.uid,
                          username: settings.state.user.username,
                          fullName: _nameController.text.trim(),
                          email: _emailController.text.trim(),
                          phone: settings.state.user.phone,
                          bio: _bioController.text.trim(),
                          memberSince: settings.state.user.memberSince,
                          isGuest: settings.state.user.isGuest,
                        ),
                      );
                      if (!context.mounted || message == null) return;
                      context.showAppSnack(message);
                      final lowerMessage = message.toLowerCase();
                      if (lowerMessage.contains('berhasil') ||
                          lowerMessage.contains('dikirim')) {
                        Navigator.of(context).pop();
                      }
                    },
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Ubah Password',
              isSecondary: true,
              icon: Icons.lock_reset_rounded,
              onPressed: isGuest
                  ? null
                  : () =>
                  Navigator.of(context).pushNamed(RouteNames.changePassword),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Hapus Akun',
              isSecondary: true,
              icon: Icons.delete_forever_rounded,
              onPressed: isGuest
                  ? null
                  : () =>
                  Navigator.of(context).pushNamed(RouteNames.deleteAccount),
            ),
          ],
        ),
      ),
    );
  }
}
