
import 'package:cloud_firestore/cloud_firestore.dart';

import '../admin/admin_data.dart';

class ModulDetailService {
  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  // Mengambil detail materi dan kuis dari Firestore
  Future<Modul> ambilModul(String modulId) async {
    final modulRef = _db.collection('moduls').doc(modulId);

    final modulDoc = await modulRef.get();

    if (!modulDoc.exists) {
      throw Exception('Modul tidak ditemukan');
    }

    final data = modulDoc.data()!;

    final modul = Modul(
      data['title']?.toString() ?? '',
    );

    final materiSnapshot = await modulRef
        .collection('materi')
        .orderBy('order')
        .get();

    for (final doc in materiSnapshot.docs) {
      final item = doc.data();

      modul.materi.add(
        Materi(
          item['title']?.toString() ?? '',
          item['body']?.toString() ?? '',
        ),
      );
    }

    final soalSnapshot = await modulRef
        .collection('soal')
        .orderBy('order')
        .get();

    for (final doc in soalSnapshot.docs) {
      final item = doc.data();

      final pilihan = List<String>.from(
        item['options'] ?? <String>[],
      );

      modul.quiz.add(
        Question(
          item['text']?.toString() ?? '',
          [
            for (final jawaban in pilihan)
              Option(jawaban),
          ],
          correct: (item['correct'] as num?)?.toInt() ?? 0,
        ),
      );
    }

    return modul;
  }

  // Menyimpan judul, teks materi, dan soal
  Future<void> simpanModul(
    String modulId,
    Modul modul,
  ) async {
    final judul = modul.title.trim();

    if (judul.isEmpty || judul.length > 100) {
      throw Exception(
        'Judul modul harus berisi 1–100 karakter.',
      );
    }

    if (modul.materi.any(
      (m) =>
          m.title.trim().isEmpty ||
          m.body.length > 10000 ||
          m.title.length > 200,
    )) {
      throw Exception(
        'Periksa judul dan isi setiap materi.',
      );
    }

    for (final q in modul.quiz) {
      if (q.text.trim().isEmpty ||
          q.text.length > 1000 ||
          q.options.length != 4 ||
          q.correct < 0 ||
          q.correct >= q.options.length ||
          q.options.any(
            (o) =>
                o.text.trim().isEmpty ||
                o.text.length > 500,
          )) {
        throw Exception(
          'Setiap soal harus memiliki pertanyaan, '
          '4 pilihan teks, dan jawaban benar.',
        );
      }
    }

    // Media belum didukung dalam penyimpanan ini
    if (modul.cover != null ||
        modul.materi.any(
          (m) => m.images.isNotEmpty || m.videos.isNotEmpty,
        ) ||
        modul.quiz.any(
          (q) =>
              q.image != null ||
              q.options.any((o) => o.image != null),
        )) {
      throw Exception(
        'Penyimpanan gambar/video belum didukung. '
        'Gunakan teks materi dan soal terlebih dahulu.',
      );
    }

    final modulRef =
        _db.collection('moduls').doc(modulId);

    final materiRef = modulRef.collection('materi');
    final soalRef = modulRef.collection('soal');

    final materiLama = await materiRef.get();
    final soalLama = await soalRef.get();

    // Menjaga jumlah operasi dalam batas batch
    final operasi = 1 +
        materiLama.docs.length +
        soalLama.docs.length +
        modul.materi.length +
        modul.quiz.length;

    if (operasi > 400) {
      throw Exception(
        'Data terlalu banyak untuk satu kali penyimpanan.',
      );
    }

    final batch = _db.batch();

    // Hanya ubah title, jangan menimpa createdAt
    batch.update(modulRef, {
      'title': judul,
    });

    // Hapus subdokumen lama
    for (final doc in materiLama.docs) {
      batch.delete(doc.reference);
    }

    for (final doc in soalLama.docs) {
      batch.delete(doc.reference);
    }

    // Simpan materi sesuai urutan
    for (var i = 0; i < modul.materi.length; i++) {
      final m = modul.materi[i];

      final id =
          'materi-${(i + 1).toString().padLeft(2, '0')}';

      batch.set(materiRef.doc(id), {
        'title': m.title.trim(),
        'body': m.body.trim(),
        'order': i + 1,
      });
    }

    // Simpan soal sesuai urutan
    for (var i = 0; i < modul.quiz.length; i++) {
      final q = modul.quiz[i];

      final id =
          'soal-${(i + 1).toString().padLeft(2, '0')}';

      batch.set(soalRef.doc(id), {
        'text': q.text.trim(),
        'options': [
          for (final o in q.options) o.text.trim(),
        ],
        'correct': q.correct,
        'order': i + 1,
      });
    }

    await batch.commit();
  }
}
