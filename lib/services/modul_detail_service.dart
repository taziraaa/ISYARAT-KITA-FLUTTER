import 'package:cloud_firestore/cloud_firestore.dart';

import '../admin/admin_data.dart';

class ModulDetailService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Membaca detail modul dari Firestore
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

    // Mengambil materi pembelajaran
    final materiSnapshot =
        await modulRef.collection('materi').orderBy('order').get();

    for (final doc in materiSnapshot.docs) {
      final materiData = doc.data();

      modul.materi.add(
        Materi(
          materiData['title']?.toString() ?? '',
          materiData['body']?.toString() ?? '',
        ),
      );
    }

    // Mengambil soal kuis
    final soalSnapshot =
        await modulRef.collection('soal').orderBy('order').get();

    for (final doc in soalSnapshot.docs) {
      final soalData = doc.data();

      final pilihan = List<String>.from(
        soalData['options'] ?? <String>[],
      );

      final jawabanBenar = (soalData['correct'] as num?)?.toInt() ?? 0;

      modul.quiz.add(
        Question(
          soalData['text']?.toString() ?? '',
          [
            for (final pilihanJawaban in pilihan) Option(pilihanJawaban),
          ],
          correct: jawabanBenar,
        ),
      );
    }

    return modul;
  }
}
