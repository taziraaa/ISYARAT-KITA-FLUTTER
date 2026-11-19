import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';
import '../widgets.dart';
import 'login.dart';

// ───────────────────────── Profile ─────────────────────────

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return PageBody(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        const TabTitle('Profile'),
        const SizedBox(height: 18),
        const Center(child: AvatarCircle(size: 88, iconSize: 60)),
        const SizedBox(height: 18),
        Center(
          child: Text(s.name,
              style: AppText.base(size: 22, weight: FontWeight.w700)),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(s.email,
              style: AppText.base(size: 15, color: AppColors.body)),
        ),
        const SizedBox(height: 10),
        const Center(child: PillChip('PELAJAR BISINDO', size: 11, upper: true)),
        const SizedBox(height: 26),
        const ProgressCard(),
        const SizedBox(height: 20),
        TintCard(
          radius: 14,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Teruskan langkah baikmu', style: AppText.section()),
              const SizedBox(height: 12),
              Text(
                s.allDone
                    ? 'Semua modul selesai. Ulangi materi kapan pun kamu mau.'
                    : '${s.completed} modul selesai. Lanjutkan Modul ${s.current.number} untuk membuka ${s.completed + 1 < modules.length ? modules[s.completed + 1].title : 'modul berikutnya'}.',
                style: AppText.bodyText(size: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        OutlinedCard(
          radius: 16,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Column(
            children: [
              _MenuRow(
                title: 'Edit Profil',
                subtitle: 'Ubah nama dan alamat email',
                icon: Icons.manage_accounts_outlined,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const EditProfileScreen())),
              ),
              const Divider(height: 1, color: AppColors.border),
              InkWell(
                onTap: () => _confirmLogout(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    children: [
                      const Icon(Icons.logout, size: 24, color: AppColors.error),
                      const SizedBox(width: 12),
                      Text('Keluar',
                          style: AppText.base(
                              size: 16,
                              weight: FontWeight.w700,
                              color: AppColors.error)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Center(
          child: Text('IsyaratKita • Belajar untuk saling mengerti',
              style: AppText.base(size: 13, color: AppColors.body)),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  const _MenuRow(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppText.base(size: 16, weight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: AppText.base(size: 13, color: AppColors.body)),
                  ],
                ),
              ),
              Icon(icon, size: 24, color: AppColors.primary),
            ],
          ),
        ),
      );
}

Future<void> _confirmLogout(BuildContext context) {
  return showDialog(
    context: context,
    barrierColor: kScrim,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.logout, size: 28, color: AppColors.primary),
            const SizedBox(height: 18),
            Text('Keluar dari akun?',
                style: AppText.base(size: 22, weight: FontWeight.w700)),
            const SizedBox(height: 14),
            Text(
              'Progres belajarmu tetap tersimpan. Kamu akan kembali ke Login dan perlu masuk lagi untuk mengakses aplikasi.',
              style: AppText.bodyText(size: 15),
            ),
            const SizedBox(height: 22),
            PrimaryButton('Ya, Keluar', onTap: () {
              Navigator.of(ctx).pop();
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false);
            }),
            const SizedBox(height: 12),
            OutlineButtonX('Batal', onTap: () => Navigator.of(ctx).pop()),
          ],
        ),
      ),
    ),
  );
}

// ───────────────────────── Edit profile ─────────────────────────

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    // Safe: AppScope is above the Navigator, so it is available here.
    final s = (context.getInheritedWidgetOfExactType<AppScope>())!.notifier!;
    _name = TextEditingController(text: s.name);
    _email = TextEditingController(text: s.email);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const BackHeader('Edit Profil'),
            Expanded(
              child: PageBody(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  const SizedBox(height: 8),
                  const Center(
                      child: AvatarCircle(size: 96, iconSize: 66, ring: true)),
                  const SizedBox(height: 18),
                  Center(
                    child: GestureDetector(
                      onTap: () {}, // TODO: image picker
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.camera_alt_outlined,
                              size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('Ubah foto profil',
                              style: AppText.link(size: 14)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text('Perbarui informasi yang tampil di akunmu.',
                      style: AppText.bodyText(size: 15)),
                  const SizedBox(height: 18),
                  AppField(
                      label: 'Nama lengkap',
                      hint: 'Masukkan nama lengkap',
                      controller: _name),
                  const SizedBox(height: 18),
                  AppField(
                      label: 'Alamat email',
                      hint: 'Masukkan alamat email',
                      controller: _email,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  const InfoBox(
                    icon: Icons.verified_user_outlined,
                    text: 'Perubahan profil tidak mengubah progres belajarmu.',
                  ),
                  const SizedBox(height: 34),
                  PrimaryButton('Simpan Perubahan', onTap: () {
                    s.updateProfile(_name.text.trim().isEmpty
                        ? s.name
                        : _name.text.trim(),
                        _email.text.trim().isEmpty
                            ? s.email
                            : _email.text.trim());
                    Navigator.of(context).pop();
                  }),
                  const SizedBox(height: 12),
                  OutlineButtonX('Batal',
                      onTap: () => Navigator.of(context).pop()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
