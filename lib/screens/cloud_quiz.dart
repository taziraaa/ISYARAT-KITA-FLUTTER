import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/progress_service.dart';
import '../theme.dart';
import '../widgets.dart';

// MODEL SOAL ONLINE
class OnlineQuestion {
  final String text;
  final List<String> options;
  final int correct;

  OnlineQuestion({
    required this.text,
    required this.options,
    required this.correct,
  });

  factory OnlineQuestion.fromMap(
    Map<String, dynamic> data,
  ) {
    final options = List<String>.from(
      data['options'] ?? <String>[],
    );

    final correct = (data['correct'] as num?)?.toInt() ?? -1;

    if (options.length != 4 ||
        correct < 0 ||
        correct >= options.length ||
        (data['text'] ?? '').toString().trim().isEmpty) {
      throw const FormatException(
        'Format soal tidak valid.',
      );
    }

    return OnlineQuestion(
      text: data['text'].toString(),
      options: options,
      correct: correct,
    );
  }
}

class CloudQuizScreen extends StatefulWidget {
  final String modulId;
  final String modulTitle;

  const CloudQuizScreen({
    super.key,
    required this.modulId,
    required this.modulTitle,
  });

  @override
  State<CloudQuizScreen> createState() => _CloudQuizScreenState();
}

class _CloudQuizScreenState extends State<CloudQuizScreen> {
  late final Future<List<OnlineQuestion>> _futureSoal;

  final List<int> _jawaban = [];

  int _nomor = 0;
  bool _menyimpan = false;
  bool _selesai = false;

  int _nilaiAkhir = 0;
  int _jumlahBenar = 0;

  @override
  void initState() {
    super.initState();
    _futureSoal = _ambilSoal();
  }

  // MEMBACA SOAL DARI FIRESTORE
  Future<List<OnlineQuestion>> _ambilSoal() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('moduls')
        .doc(widget.modulId)
        .collection('soal')
        .orderBy('order')
        .get();

    return [
      for (final doc in snapshot.docs) OnlineQuestion.fromMap(doc.data()),
    ];
  }

  // BERPINDAH SOAL DAN MENYIMPAN HASIL
  Future<void> _berikutnya(
    List<OnlineQuestion> soal,
  ) async {
    if (_menyimpan || _jawaban[_nomor] < 0) return;

    if (_nomor < soal.length - 1) {
      setState(() => _nomor++);
      return;
    }

    int benar = 0;

    for (var i = 0; i < soal.length; i++) {
      if (_jawaban[i] == soal[i].correct) {
        benar++;
      }
    }

    final nilai = (benar / soal.length * 100).round();

    setState(() => _menyimpan = true);

    try {
      await ProgressService().simpanNilai(
        modulId: widget.modulId,
        nilai: nilai,
        jumlahSoal: soal.length,
      );

      if (!mounted) return;

      setState(() {
        _jumlahBenar = benar;
        _nilaiAkhir = nilai;
        _selesai = true;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan nilai: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _menyimpan = false);
      }
    }
  }

  // MENGULANG KUIS
  void _ulangi(int jumlahSoal) {
    setState(() {
      _jawaban
        ..clear()
        ..addAll(List.filled(jumlahSoal, -1));

      _nomor = 0;
      _selesai = false;
      _nilaiAkhir = 0;
      _jumlahBenar = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const BackHeader('Kuis Pembelajaran'),
            Expanded(
              child: FutureBuilder<List<OnlineQuestion>>(
                future: _futureSoal,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Gagal memuat soal:\n'
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final soal = snapshot.data!;

                  if (soal.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada soal untuk modul ini.',
                      ),
                    );
                  }

                  // INISIALISASI JAWABAN
                  if (_jawaban.length != soal.length) {
                    _jawaban
                      ..clear()
                      ..addAll(
                        List.filled(soal.length, -1),
                      );
                  }

                  if (_selesai) {
                    return _hasilKuis(soal);
                  }

                  return _tampilanSoal(soal);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TAMPILAN PERTANYAAN
  Widget _tampilanSoal(
    List<OnlineQuestion> soal,
  ) {
    final pertanyaan = soal[_nomor];

    final terakhir = _nomor == soal.length - 1;

    return PageBody(
      padding: const EdgeInsets.fromLTRB(
        20,
        10,
        20,
        24,
      ),
      children: [
        Text(
          widget.modulTitle,
          style: AppText.appBar(),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pertanyaan ${_nomor + 1} dari ${soal.length}',
              style: AppText.base(
                size: 14,
                weight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            Text(
              terakhir ? 'Soal terakhir' : 'Kuis BISINDO',
              style: AppText.caption(),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ProgressBar(
          (_nomor + 1) / soal.length,
        ),
        const SizedBox(height: 24),
        Text(
          pertanyaan.text,
          style: AppText.base(
            size: 24,
            weight: FontWeight.w700,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Pilih satu jawaban yang paling sesuai.',
          style: AppText.caption(),
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < pertanyaan.options.length; i++) ...[
          _PilihanJawaban(
            label: pertanyaan.options[i],
            selected: _jawaban[_nomor] == i,
            onTap: () {
              if (_menyimpan) return;

              setState(() {
                _jawaban[_nomor] = i;
              });
            },
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 14),
        if (_menyimpan)
          const Center(
            child: CircularProgressIndicator(),
          ),
        Opacity(
          opacity: _jawaban[_nomor] < 0 || _menyimpan ? 0.5 : 1,
          child: PrimaryButton(
            terakhir ? 'Selesaikan Kuis' : 'Berikutnya',
            trailing: terakhir ? Icons.check : Icons.arrow_forward,
            onTap: () {
              if (_jawaban[_nomor] >= 0 && !_menyimpan) {
                _berikutnya(soal);
              }
            },
          ),
        ),
        if (_nomor > 0) ...[
          const SizedBox(height: 12),
          OutlineButtonX(
            'Soal Sebelumnya',
            onTap: () {
              if (_menyimpan) return;

              setState(() => _nomor--);
            },
          ),
        ],
      ],
    );
  }

  // HALAMAN HASIL KUIS
  Widget _hasilKuis(
    List<OnlineQuestion> soal,
  ) {
    return PageBody(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        24,
      ),
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.tint,
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              size: 36,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'Kuis Selesai!',
            style: AppText.h2(),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            widget.modulTitle,
            textAlign: TextAlign.center,
            style: AppText.bodyText(),
          ),
        ),
        const SizedBox(height: 24),
        TintCard(
          radius: 18,
          child: Column(
            children: [
              Text(
                'SKOR KUIS KAMU',
                style: AppText.eyebrow(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$_nilaiAkhir / 100',
                style: AppText.base(
                  size: 48,
                  weight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _StatHasil(
                      '$_jumlahBenar',
                      'Benar',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatHasil(
                      '${soal.length - _jumlahBenar}',
                      'Salah',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const InfoBox(
          icon: Icons.cloud_done_outlined,
          text: 'Nilai terakhir berhasil disimpan '
              'ke Cloud Firestore.',
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          'Ulangi Kuis',
          trailing: Icons.replay,
          onTap: () => _ulangi(soal.length),
        ),
        const SizedBox(height: 14),
        OutlineButtonX(
          'Kembali ke Materi',
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

// KARTU PILIHAN JAWABAN
class _PilihanJawaban extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PilihanJawaban({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.tint : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: AppColors.primary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: AppText.base(
                    size: 15,
                    weight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// RINGKASAN NILAI
class _StatHasil extends StatelessWidget {
  final String value;
  final String label;

  const _StatHasil(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppText.base(
              size: 22,
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppText.caption(),
          ),
        ],
      ),
    );
  }
}
