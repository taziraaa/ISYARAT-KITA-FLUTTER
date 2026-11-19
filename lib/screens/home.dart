import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/firebase_progress_card.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets.dart';
import 'lesson.dart';

// MODEL MODUL UNTUK BERANDA
class _HomeModule {
  final String id;
  final String title;
  final String description;

  const _HomeModule({
    required this.id,
    required this.title,
    required this.description,
  });
}

// ───────────────────────── BERANDA ─────────────────────────

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text('Silakan login terlebih dahulu.'),
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, userSnapshot) {
        if (userSnapshot.hasError) {
          return const Center(
            child: Text('Gagal memuat profil pengguna.'),
          );
        }

        if (!userSnapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final nama =
            userSnapshot.data!.data()?['name']?.toString() ?? 'Pengguna';

        final namaDepan =
            nama.trim().isEmpty ? 'Pengguna' : nama.trim().split(' ').first;

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('moduls').snapshots(),
          builder: (context, modulSnapshot) {
            if (modulSnapshot.hasError) {
              return const Center(
                child: Text('Gagal memuat daftar modul.'),
              );
            }

            if (!modulSnapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final documents = modulSnapshot.data!.docs.toList();

            // Modul bawaan tampil lebih dahulu
            documents.sort((a, b) {
              final aBawaan = RegExp(r'^modul-\d+$').hasMatch(a.id);
              final bBawaan = RegExp(r'^modul-\d+$').hasMatch(b.id);

              if (aBawaan && !bBawaan) return -1;
              if (!aBawaan && bBawaan) return 1;

              if (aBawaan && bBawaan) {
                return a.id.compareTo(b.id);
              }

              return (a.data()['title'] ?? '').toString().compareTo(
                    (b.data()['title'] ?? '').toString(),
                  );
            });

            final daftarModul = [
              for (final doc in documents)
                _HomeModule(
                  id: doc.id,
                  title: doc.data()['title']?.toString() ?? 'Tanpa Judul',
                  description: doc.data()['description']?.toString() ?? '',
                ),
            ];

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('progress')
                  .snapshots(),
              builder: (context, progressSnapshot) {
                if (progressSnapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Gagal memuat progres belajar.',
                    ),
                  );
                }

                if (!progressSnapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final sudahDikerjakan = progressSnapshot.data!.docs
                    .where(
                      (doc) => doc.data()['lastScore'] is num,
                    )
                    .map((doc) => doc.id)
                    .toSet();

                return _HomeContent(
                  namaDepan: namaDepan,
                  daftarModul: daftarModul,
                  sudahDikerjakan: sudahDikerjakan,
                );
              },
            );
          },
        );
      },
    );
  }
}

// ───────────────────────── KONTEN BERANDA ─────────────────────────

class _HomeContent extends StatelessWidget {
  final String namaDepan;
  final List<_HomeModule> daftarModul;
  final Set<String> sudahDikerjakan;

  const _HomeContent({
    required this.namaDepan,
    required this.daftarModul,
    required this.sudahDikerjakan,
  });

  void _bukaModul(
    BuildContext context,
    _HomeModule modul,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          moduleId: modul.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cari modul pertama yang kuisnya
    // belum dikerjakan.
    _HomeModule? modulAktif;

    for (final modul in daftarModul) {
      if (!sudahDikerjakan.contains(modul.id)) {
        modulAktif = modul;
        break;
      }
    }

    // Jika semua kuis pernah dikerjakan,
    // pilih modul pertama untuk diulang.
    final semuaDikerjakan = daftarModul.isNotEmpty && modulAktif == null;

    if (modulAktif == null && daftarModul.isNotEmpty) {
      modulAktif = daftarModul.first;
    }

    final modulLain = daftarModul
        .where((modul) => modul.id != modulAktif?.id)
        .take(2)
        .toList();

    final jumlahDikerjakan = daftarModul
        .where(
          (modul) => sudahDikerjakan.contains(modul.id),
        )
        .length;

    final nomorAktif =
        modulAktif == null ? 0 : daftarModul.indexOf(modulAktif) + 1;

    return PageBody(
      padding: const EdgeInsets.fromLTRB(
        20,
        14,
        20,
        24,
      ),
      children: [
        // HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const LogoLockup(),
            GestureDetector(
              onTap: () => MainShell.goToTab(context, 3),
              child: const AvatarCircle(
                size: 44,
                iconSize: 32,
                ring: true,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        Text(
          'Selamat datang, $namaDepan',
          style: AppText.base(
            size: 15,
            color: AppColors.body,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Yuk, belajar lagi!',
          style: AppText.h2(),
        ),

        const SizedBox(height: 6),

        Text(
          'Satu isyarat, selangkah lebih dekat.',
          style: AppText.base(
            size: 14,
            color: AppColors.body,
          ),
        ),

        const SizedBox(height: 20),

        // PROGRES DARI FIREBASE
        const FirebaseProgressCard(),

        const SizedBox(height: 20),

        // MODUL YANG DIREKOMENDASIKAN
        if (modulAktif != null)
          TintCard(
            radius: 18,
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                      ),
                      child: Text(
                        semuaDikerjakan
                            ? 'BELAJAR KEMBALI'
                            : 'REKOMENDASI BELAJAR',
                        style: AppText.eyebrow(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.menu_book_outlined,
                      size: 26,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 4,
                  ),
                  child: Text(
                    'MODUL $nomorAktif',
                    style: AppText.base(
                      size: 12,
                      weight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 4,
                  ),
                  child: Text(
                    modulAktif.title,
                    style: AppText.base(
                      size: 22,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 4,
                  ),
                  child: Text(
                    modulAktif.description.isEmpty
                        ? 'Pelajari materi BISINDO '
                            'pada modul ini.'
                        : modulAktif.description,
                    style: AppText.base(
                      size: 14,
                      color: AppColors.body,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                PrimaryButton(
                  semuaDikerjakan ? 'Ulangi Belajar' : 'Lanjutkan Belajar',
                  trailing: Icons.arrow_forward,
                  onTap: () => _bukaModul(
                    context,
                    modulAktif!,
                  ),
                ),
              ],
            ),
          ),

        if (modulAktif == null)
          const InfoBox(
            icon: Icons.info_outline,
            text: 'Belum ada modul pembelajaran tersedia.',
          ),

        const SizedBox(height: 22),

        // DAFTAR MODUL
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Modul belajarmu',
              style: AppText.section(),
            ),
            GestureDetector(
              onTap: () => MainShell.goToTab(context, 1),
              child: Text(
                'Lihat semua',
                style: AppText.link(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          '$jumlahDikerjakan dari '
          '${daftarModul.length} modul '
          'sudah dikerjakan kuisnya.',
          style: AppText.caption(),
        ),

        const SizedBox(height: 14),

        if (modulLain.isNotEmpty)
          Row(
            children: [
              for (var k = 0; k < modulLain.length; k++) ...[
                if (k > 0) const SizedBox(width: 12),
                Expanded(
                  child: _MiniModuleCard(
                    modul: modulLain[k],
                    number: daftarModul.indexOf(modulLain[k]) + 1,
                    sudahDikerjakan: sudahDikerjakan.contains(
                      modulLain[k].id,
                    ),
                    onTap: () => _bukaModul(
                      context,
                      modulLain[k],
                    ),
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }
}

// ───────────────────────── KARTU MODUL KECIL ─────────────────────────

class _MiniModuleCard extends StatelessWidget {
  final _HomeModule modul;
  final int number;
  final bool sudahDikerjakan;
  final VoidCallback onTap;

  const _MiniModuleCard({
    required this.modul,
    required this.number,
    required this.sudahDikerjakan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedCard(
      radius: 14,
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: SizedBox(
        height: 110,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Modul $number',
                  style: AppText.base(
                    size: 12,
                    weight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Icon(
                  sudahDikerjakan
                      ? Icons.check_circle_outline
                      : Icons.menu_book_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Text(
                modul.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.base(
                  size: 15,
                  weight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              sudahDikerjakan ? 'Kuis sudah dikerjakan' : 'Belum dikerjakan',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.base(
                size: 12,
                color: AppColors.body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
