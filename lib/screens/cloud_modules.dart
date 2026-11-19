
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/modul_service.dart';

class CloudModulesScreen extends StatefulWidget {
  final bool isAdmin;

  const CloudModulesScreen({
    super.key,
    required this.isAdmin,
  });

  @override
  State<CloudModulesScreen> createState() =>
      _CloudModulesScreenState();
}

class _CloudModulesScreenState
    extends State<CloudModulesScreen> {

  final ModulService service = ModulService();

  // FORM TAMBAH DAN EDIT MODUL
  Future<void> bukaForm({
    String? id,
    String titleAwal = '',
    String descriptionAwal = '',
  }) async {
    final titleController =
        TextEditingController(text: titleAwal);

    final descriptionController =
        TextEditingController(text: descriptionAwal);

    bool sedangMenyimpan = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                id == null
                    ? 'Tambah Modul'
                    : 'Edit Modul',
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
                  onPressed: sedangMenyimpan
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: sedangMenyimpan
                      ? null
                      : () async {
                          final title =
                              titleController.text.trim();
                          final description =
                              descriptionController.text.trim();

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

                            ScaffoldMessenger.of(dialogContext)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Gagal menyimpan: $e',
                                ),
                              ),
                            );

                            setDialogState(() {
                              sedangMenyimpan = false;
                            });
                          }
                        },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      titleController.dispose();
      descriptionController.dispose();
    });
  }

  // HAPUS MODUL
  Future<void> hapusModul(String id) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Modul?'),
        content: const Text(
          'Modul yang dihapus tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
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
        SnackBar(content: Text('Gagal menghapus: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isAdmin
              ? 'Kelola Modul Online'
              : 'Modul Online',
        ),
      ),

      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              onPressed: () => bukaForm(),
              child: const Icon(Icons.add),
            )
          : null,

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
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

              final title =
                  data['title']?.toString() ?? '';

              final description =
                  data['description']?.toString() ?? '';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
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
                            }

                            if (value == 'delete') {
                              hapusModul(document.id);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit Modul'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Hapus Modul'),
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
    );
  }
}
