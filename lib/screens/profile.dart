import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../cloud_auth_gate.dart';
import '../components/firebase_progress_card.dart';
import '../theme.dart';
import '../widgets.dart';

// ───────────────────────── PROFILE ─────────────────────────

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text('Silakan login terlebih dahulu.'),
      );
    }

    return PageBody(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        const TabTitle('Profile'),
        const SizedBox(height: 18),

        const Center(
          child: AvatarCircle(
            size: 88,
            iconSize: 60,
          ),
        ),

        const SizedBox(height: 18),

        // NAMA USER DARI FIRESTORE
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Gagal memuat nama pengguna.'),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final nama = snapshot.data?.data()?['name']?.toString() ??
                'Pengguna IsyaratKita';

            return Center(
              child: Text(
                nama,
                textAlign: TextAlign.center,
                style: AppText.base(
                  size: 22,
                  weight: FontWeight.w700,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 12),

        // EMAIL DARI FIREBASE AUTHENTICATION
        Center(
          child: Text(
            user.email ?? '',
            style: AppText.base(
              size: 15,
              color: AppColors.body,
            ),
          ),
        ),

        const SizedBox(height: 10),

        const Center(
          child: PillChip(
            'PELAJAR BISINDO',
            size: 11,
            upper: true,
          ),
        ),

        const SizedBox(height: 26),

        // PROGRES DARI CLOUD FIRESTORE
        const FirebaseProgressCard(),

        const SizedBox(height: 20),

        // INFORMASI PROGRES
        TintCard(
          radius: 14,
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Teruskan langkah baikmu',
                style: AppText.section(),
              ),
              const SizedBox(height: 12),
              Text(
                'Pantau perkembangan belajarmu melalui '
                'hasil kuis yang tersimpan di akun Firebase.',
                style: AppText.bodyText(size: 14),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // MENU PROFIL
        OutlinedCard(
          radius: 16,
          padding: const EdgeInsets.fromLTRB(
            16,
            4,
            16,
            4,
          ),
          child: Column(
            children: [
              _MenuRow(
                title: 'Edit Profil',
                subtitle: 'Informasi akun pengguna',
                icon: Icons.manage_accounts_outlined,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
              const Divider(
                height: 1,
                color: AppColors.border,
              ),
              InkWell(
                onTap: () => _confirmLogout(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.logout,
                        size: 24,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Keluar',
                        style: AppText.base(
                          size: 16,
                          weight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        Center(
          child: Text(
            'IsyaratKita • Belajar untuk saling mengerti',
            textAlign: TextAlign.center,
            style: AppText.base(
              size: 13,
              color: AppColors.body,
            ),
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── MENU ROW ─────────────────────────

class _MenuRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        child: Row(
          children: [
            const SizedBox(width: 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.base(
                      size: 16,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppText.base(
                      size: 13,
                      color: AppColors.body,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              icon,
              size: 24,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── LOGOUT ─────────────────────────

Future<void> _confirmLogout(
  BuildContext context,
) async {
  final konfirmasi = await showDialog<bool>(
    context: context,
    barrierColor: kScrim,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.logout,
              size: 28,
              color: AppColors.primary,
            ),
            const SizedBox(height: 18),
            Text(
              'Keluar dari akun?',
              style: AppText.base(
                size: 22,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Progres belajarmu tetap tersimpan '
              'di Firebase. Kamu perlu login kembali '
              'untuk mengakses aplikasi.',
              style: AppText.bodyText(size: 15),
            ),
            const SizedBox(height: 22),
            PrimaryButton(
              'Ya, Keluar',
              onTap: () => Navigator.pop(ctx, true),
            ),
            const SizedBox(height: 12),
            OutlineButtonX(
              'Batal',
              onTap: () => Navigator.pop(ctx, false),
            ),
          ],
        ),
      ),
    ),
  );

  if (konfirmasi != true || !context.mounted) {
    return;
  }

  try {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.of(
      context,
      rootNavigator: true,
    ).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const CloudAuthGate(),
      ),
      (route) => false,
    );
  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gagal logout: $e'),
      ),
    );
  }
}

// ───────────────────────── EDIT PROFILE ─────────────────────────

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Silakan login kembali.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const BackHeader('Edit Profil'),
            Expanded(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Gagal membaca informasi akun.',
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final nama = snapshot.data?.data()?['name']?.toString() ??
                      'Pengguna IsyaratKita';

                  return PageBody(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      24,
                    ),
                    children: [
                      const SizedBox(height: 8),
                      const Center(
                        child: AvatarCircle(
                          size: 96,
                          iconSize: 66,
                          ring: true,
                        ),
                      ),
                      const SizedBox(height: 26),
                      Text(
                        'Informasi akun yang tersimpan '
                        'di Firebase.',
                        style: AppText.bodyText(
                          size: 15,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Nama lengkap',
                        style: AppText.label(),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: nama,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Alamat email',
                        style: AppText.label(),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: user.email ?? '',
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const InfoBox(
                        icon: Icons.info_outline,
                        text: 'Perubahan nama dan email '
                            'belum diaktifkan. '
                            'Data ditampilkan dari Firebase.',
                      ),
                      const SizedBox(height: 34),
                      PrimaryButton(
                        'Kembali ke Profil',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
