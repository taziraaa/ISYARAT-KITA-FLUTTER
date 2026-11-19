import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';
import '../widgets.dart';
import 'quiz.dart';

// NOTE: the design only contains lesson content for Modul 2, so every
// module re-uses it. Swap in per-module content when you have it.
class LessonScreen extends StatelessWidget {
  final int moduleIndex;
  const LessonScreen({super.key, required this.moduleIndex});

  @override
  Widget build(BuildContext context) {
    final m = modules[moduleIndex];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            BackHeader('Materi Modul ${m.number}'),
            Expanded(
              child: PageBody(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: PillChip(m.title.toUpperCase(),
                        size: 11, upper: true),
                  ),
                  const SizedBox(height: 14),
                  Text('Mulai percakapan dengan hangat',
                      style: AppText.base(
                          size: 28, weight: FontWeight.w700, height: 1.25)),
                  const SizedBox(height: 14),
                  Text(
                    'Kenali sapaan, ungkapan terima kasih, dan cara menanyakan kabar dalam BISINDO.',
                    style: AppText.bodyText(size: 15),
                  ),
                  const SizedBox(height: 20),
                  OutlinedCard(
                    radius: 14,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Materi 3 dari 3 • Siap latihan',
                            style: AppText.base(
                                size: 14, weight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        const ProgressBar(1),
                        const SizedBox(height: 12),
                        Text('Baca ulang contoh, lalu uji pemahamanmu.',
                            style: AppText.caption()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _Section(
                    title: 'Menyapa dengan “Halo”',
                    image: 'assets/images/sign_halo.png',
                    body:
                        'Awali dengan kontak mata dan ekspresi ramah. Perhatikan bentuk tangan, posisi, dan arah gerak pada contoh. Beri jeda agar lawan bicara siap merespons.',
                  ),
                  const _Section(
                    title: 'Mengucapkan “Terima kasih”',
                    image: 'assets/images/sign_terima_kasih.png',
                    body:
                        'Gunakan ungkapan ini setelah menerima bantuan. Amati posisi awal dan akhir gerak; lakukan dengan tempo nyaman. Ekspresi wajah membantu menyampaikan ketulusan.',
                  ),
                  const _Section(
                    title: 'Bertanya “Apa kabar?”',
                    image: 'assets/images/sign_apa_kabar.png',
                    body:
                        'Setelah menyapa, tanyakan kabar dan tunggu jawaban. Gunakan ekspresi bertanya secara natural. Isyarat dapat berbeda antardaerah; ikuti variasi yang digunakan komunitas Tuli setempat.',
                  ),
                  const TipCard(
                    title: 'Latihan kecil sebelum kuis',
                    text:
                        'Coba urutan: Halo → Apa kabar? → Terima kasih. Perhatikan kedua tangan dan ekspresi, bukan hanya bentuk jari. Ulangi perlahan di depan cermin.',
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text('10 pertanyaan • Pilih satu jawaban per soal',
                        style: AppText.caption()),
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton('Mulai Kuis',
                      trailing: Icons.arrow_forward,
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) =>
                                  QuizScreen(moduleIndex: moduleIndex)))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String image;
  final String body;
  const _Section(
      {required this.title, required this.image, required this.body});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppText.base(size: 20, weight: FontWeight.w700)),
            const SizedBox(height: 14),
            SignImage(image),
            const SizedBox(height: 12),
            Text(body, style: AppText.bodyText(size: 15)),
          ],
        ),
      );
}
