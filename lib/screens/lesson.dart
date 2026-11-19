import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'cloud_quiz.dart';
import '../theme.dart';
import '../widgets.dart';

class LessonScreen extends StatelessWidget {
  final String? moduleId;
  final int? moduleIndex;

  const LessonScreen({
    super.key,
    this.moduleId,
    this.moduleIndex,
  }) : assert(
          moduleId != null || moduleIndex != null,
          'Harus mengisi moduleId atau moduleIndex',
        );

  String get id {
    if (moduleId != null) return moduleId!;

    return 'modul-${((moduleIndex ?? 0) + 1).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final modulRef = FirebaseFirestore.instance.collection('moduls').doc(id);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const BackHeader('Materi Pembelajaran'),
            Expanded(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: modulRef.snapshots(),
                builder: (context, modulSnapshot) {
                  if (modulSnapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Gagal memuat data modul.',
                      ),
                    );
                  }

                  if (!modulSnapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final modulData = modulSnapshot.data!.data();

                  if (modulData == null) {
                    return const Center(
                      child: Text(
                        'Modul tidak ditemukan.',
                      ),
                    );
                  }

                  final judul = modulData['title']?.toString() ?? 'Modul';

                  final deskripsi = modulData['description']?.toString() ?? '';

                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: modulRef
                        .collection('materi')
                        .orderBy('order')
                        .snapshots(),
                    builder: (context, materiSnapshot) {
                      if (materiSnapshot.hasError) {
                        return Center(
                          child: Text(
                            'Gagal memuat materi: '
                            '${materiSnapshot.error}',
                          ),
                        );
                      }

                      if (!materiSnapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final daftarMateri = materiSnapshot.data!.docs;

                      return PageBody(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          0,
                          20,
                          24,
                        ),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: PillChip(
                              judul.toUpperCase(),
                              size: 11,
                              upper: true,
                            ),
                          ),

                          const SizedBox(height: 14),

                          Text(
                            judul,
                            style: AppText.base(
                              size: 28,
                              weight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),

                          const SizedBox(height: 14),

                          Text(
                            deskripsi,
                            style: AppText.bodyText(
                              size: 15,
                            ),
                          ),

                          const SizedBox(height: 20),

                          OutlinedCard(
                            radius: 14,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${daftarMateri.length} materi tersedia',
                                  style: AppText.base(
                                    size: 14,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Materi dibaca langsung '
                                  'dari Cloud Firestore.',
                                  style: AppText.caption(),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          if (daftarMateri.isEmpty)
                            const InfoBox(
                              icon: Icons.info_outline,
                              text: 'Belum ada materi pada '
                                  'modul ini. Admin perlu '
                                  'menambahkan materi.',
                            ),

                          for (var i = 0; i < daftarMateri.length; i++)
                            _MateriSection(
                              number: i + 1,
                              title:
                                  daftarMateri[i].data()['title']?.toString() ??
                                      '',
                              body:
                                  daftarMateri[i].data()['body']?.toString() ??
                                      '',
                            ),

                          const SizedBox(height: 20),

                          const TipCard(
                            title: 'Petunjuk Belajar',
                            text: 'Pelajari materi dengan '
                                'saksama sebelum mengerjakan '
                                'kuis pembelajaran.',
                          ),

                          const SizedBox(height: 20),

                          // Tombol kuis akan dihubungkan
                          // pada tahap berikutnya.
                          PrimaryButton(
                            'Kuis Pembelajaran',
                            trailing: Icons.arrow_forward,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => CloudQuizScreen(
                                    modulId: id,
                                    modulTitle: judul,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
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

class _MateriSection extends StatelessWidget {
  final int number;
  final String title;
  final String body;

  const _MateriSection({
    required this.number,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: OutlinedCard(
        radius: 14,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MATERI $number',
              style: AppText.eyebrow(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppText.base(
                size: 20,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: AppText.bodyText(
                size: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
