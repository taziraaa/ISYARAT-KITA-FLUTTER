import 'package:cloud_firestore/cloud_firestore.dart';

import '../data.dart';

class MigrasiModulService {
  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  Future<int> migrasiModulBawaan() async {
    final collection = _db.collection('moduls');

    int berhasil = 0;

    for (final modul in modules) {
      final id =
          'modul-${modul.number.toString().padLeft(2, '0')}';

      final document = collection.doc(id);

      // Periksa apakah modul sudah ada
      final snapshot = await document.get();

      // Jangan menimpa modul yang sudah tersimpan
      if (snapshot.exists) {
        continue;
      }

      // Menyimpan modul lama ke Cloud Firestore
      await document.set({
        'title': modul.title,
        'description': modul.subtitle,
        'createdAt': FieldValue.serverTimestamp(),
      });

      berhasil++;
    }

    return berhasil;
  }
}
