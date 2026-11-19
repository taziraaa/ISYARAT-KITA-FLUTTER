import 'package:cloud_firestore/cloud_firestore.dart';

class ModulService {
  final CollectionReference<Map<String, dynamic>> _moduls =
      FirebaseFirestore.instance.collection('moduls');

  // READ: mengambil modul secara real-time
  Stream<QuerySnapshot<Map<String, dynamic>>> getModuls() {
    return _moduls.snapshots();
  }

  // CREATE: menambahkan modul baru
  Future<void> tambahModul({
    required String title,
    required String description,
  }) async {
    await _moduls.add({
      'title': title.trim(),
      'description': description.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // UPDATE: memperbarui modul
  Future<void> ubahModul({
    required String id,
    required String title,
    required String description,
  }) async {
    await _moduls.doc(id).update({
      'title': title.trim(),
      'description': description.trim(),
    });
  }

  // DELETE: menghapus modul
  Future<void> hapusModul(String id) async {
    await _moduls.doc(id).delete();
  }
}
