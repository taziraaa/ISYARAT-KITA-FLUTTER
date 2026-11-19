
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets.dart';

class FirebaseProgressCard extends StatelessWidget {
  const FirebaseProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Text('Silakan login terlebih dahulu.');
    }

    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('moduls')
          .snapshots(),
      builder: (context, modulSnapshot) {
        if (modulSnapshot.hasError) {
          return const Text('Gagal membaca daftar modul.');
        }

        if (!modulSnapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final daftarModul = modulSnapshot.data!.docs;
        final totalModul = daftarModul.length;

        final semuaIdModul = daftarModul
            .map((doc) => doc.id)
            .toSet();

        return StreamBuilder<
            QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('progress')
              .snapshots(),
          builder: (context, progressSnapshot) {
            if (progressSnapshot.hasError) {
              return const Text(
                'Gagal membaca progres belajar.',
              );
            }

            if (!progressSnapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final daftarProgress = progressSnapshot
                .data!.docs
                .where(
                  (doc) => semuaIdModul.contains(doc.id),
                )
                .where(
                  (doc) =>
                      doc.data()['lastScore'] is num,
                )
                .toList();

            final dikerjakan = daftarProgress.length;

            final persen = totalModul == 0
                ? 0
                : (dikerjakan / totalModul * 100)
                    .round();

            int? nilaiTerakhir;

            if (daftarProgress.isNotEmpty) {
              daftarProgress.sort((a, b) {
                final aTanggal =
                    a.data()['lastAttemptAt'];
                final bTanggal =
                    b.data()['lastAttemptAt'];

                final aWaktu = aTanggal is Timestamp
                    ? aTanggal.millisecondsSinceEpoch
                    : 0;

                final bWaktu = bTanggal is Timestamp
                    ? bTanggal.millisecondsSinceEpoch
                    : 0;

                return bWaktu.compareTo(aWaktu);
              });

              nilaiTerakhir =
                  (daftarProgress.first
                          .data()['lastScore']
                      as num)
                      .toInt();
            }

            return OutlinedCard(
              radius: 16,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Progres Belajar',
                          style: AppText.section(),
                        ),
                      ),
                      Text(
                        '$persen%',
                        style: AppText.base(
                          size: 22,
                          weight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  ProgressBar(
                    totalModul == 0
                        ? 0
                        : dikerjakan / totalModul,
                  ),

                  const SizedBox(height: 14),

                  Text(
                    '$dikerjakan dari $totalModul modul '
                    'sudah dikerjakan kuisnya.',
                    style: AppText.bodyText(
                      size: 14,
                    ),
                  ),

                  if (nilaiTerakhir != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Nilai kuis terakhir: '
                      '$nilaiTerakhir/100',
                      style: AppText.base(
                        size: 14,
                        weight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  Text(
                    'Progres dihitung berdasarkan '
                    'kuis yang sudah dikerjakan.',
                    style: AppText.caption(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
