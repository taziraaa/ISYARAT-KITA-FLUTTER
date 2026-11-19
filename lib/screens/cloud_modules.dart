import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/migrasi_modul_service.dart';
import '../services/modul_service.dart';

class CloudModulesScreen extends StatefulWidget {
  final bool isAdmin;

  const CloudModulesScreen({
    super.key,
    required this.isAdmin,
  });

  @override
  State<CloudModulesScreen> createState() => _CloudModulesScreenState();
}

class _CloudModulesScreenState extends State<CloudModulesScreen> {
  final ModulService service = ModulService();

  bool sedangMigrasi = false;

  // FORM TAMBAH DAN EDIT MODUL
  Future<void> bukaForm({
    String? id,
    String titleAwal = '',
    String descriptionAwal = '',
  }) async {
    if (!widget.isAdmin) return;

    final titleController = TextEditingController(text: titleAwal);

    final descriptionController = TextEditingController(text: descriptionAwal);

    bool sedangMenyimpan = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(
            id == null ? 'Tambah Modul' : 'Edit Modul',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  maxLength: 100,
                  decoration: const InputDecoration(
                    labelText: 'Judul Modul',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLength: 1000,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi Modul',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed:
                  sedangMenyimpan ? null : () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: sedangMenyimpan
                  ? null
                  : () async {
                      final title = titleController.text.trim();

                      final description = descriptionController.text.trim();

                      if (title.isEmpty) return;

                      setDialogState(() {
                        sedangMenyimpan = true;
                      });

                      try {
                        if (id == null) {
                          await service.tambahModul(
                            title: title,
                            description: description,
                          );
                        } else {
                          await service.ubahModul(
                            id: id,
                            title: title,
                            description: description,
                          );
                        }

                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                      } catch (e) {
                        if (!dialogContext.mounted) return;

                        setDialogState(() {
                          sedangMenyimpan = false;
                        });

                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Gagal menyimpan: $e',
                            ),
                          ),
                        );
                      }
                    },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      titleController.dispose();
      descriptionController.dispose();
    });
  }

  // HAPUS MODUL
  Future<void> hapusModul(String id) async {
    if (!widget.isAdmin) return;

    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Modul?'),
        content: const Text(
          'Modul yang dihapus tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (yakin != true) return;

    try {
      await service.hapusModul(id);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus: $e'),
        ),
      );
    }
  }

  // MIGRASI LIMA MODUL LAMA
  Future<void> migrasiModulLama() async {
    if (!widget.isAdmin || sedangMigrasi) return;

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Migrasi Modul Lama'),
        content: const Text(
          'Tambahkan lima modul bawaan IsyaratKita '
          'ke Cloud Firestore tanpa menimpa data '
          'modul yang sudah ada?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Mulai Migrasi'),
          ),
        ],
      ),
    );

    if (konfirmasi != true || !mounted) return;

    setState(() {
      sedangMigrasi = true;
    });

    try {
      final jumlah = await MigrasiModulService().migrasiModulBawaan();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Migrasi selesai. $jumlah modul ditambahkan.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Migrasi gagal: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          sedangMigrasi = false;
        });
      }
    }
  }

  // TAMPILAN HALAMAN MODUL ONLINE
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isAdmin ? 'Kelola Modul Online' : 'Modul Online',
        ),
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: () => bukaForm(),
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          // TOMBOL MIGRASI KHUSUS ADMIN
          if (widget.isAdmin)
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton.icon(
                onPressed: sedangMigrasi ? null : migrasiModulLama,
                icon: const Icon(
                  Icons.cloud_upload_outlined,
                ),
                label: Text(
                  sedangMigrasi ? 'Sedang migrasi...' : 'Migrasi 5 Modul Lama',
                ),
              ),
            ),

          // DAFTAR MODUL FIRESTORE
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: service.getModuls(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Gagal memuat modul: ${snapshot.error}',
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final documents = snapshot.data!.docs;

                if (documents.isEmpty) {
                  return const Center(
                    child: Text('Belum ada modul online.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final document = documents[index];
                    final data = document.data();

                    final title = data['title']?.toString() ?? '';

                    final description = data['description']?.toString() ?? '';

                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.menu_book_outlined,
                        ),
                        title: Text(title),
                        subtitle: Text(description),
                        trailing: widget.isAdmin
                            ? PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    bukaForm(
                                      id: document.id,
                                      titleAwal: title,
                                      descriptionAwal: description,
                                    );
                                  } else if (value == 'delete') {
                                    hapusModul(document.id);
                                  }
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text(
                                      'Edit Modul',
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text(
                                      'Hapus Modul',
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
