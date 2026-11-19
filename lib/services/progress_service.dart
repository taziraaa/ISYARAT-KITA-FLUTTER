import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProgressService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> simpanNilai({
    required String modulId,
    required int nilai,
    required int jumlahSoal,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    if (nilai < 0 || nilai > 100 || jumlahSoal <= 0) {
      throw Exception('Data nilai tidak valid.');
    }

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('progress')
        .doc(modulId)
        .set({
      'lastScore': nilai,
      'totalQuestions': jumlahSoal,
      'lastAttemptAt': FieldValue.serverTimestamp(),
    });
  }
}
