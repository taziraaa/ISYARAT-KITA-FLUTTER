import 'dart:typed_data';
import '../screens/cloud_modules.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/modul_detail_service.dart';
import '../screens/login.dart';
import '../theme.dart';
import '../widgets.dart';
import 'admin_data.dart';
import '../asset_video_player.dart';

// ───────────────────────── Helper umum ─────────────────────────

Future<Uint8List?> _pickImage() async {
  final x = await ImagePicker().pickImage(source: ImageSource.gallery);
  return x?.readAsBytes();
}

void _snack(BuildContext c, String m) => ScaffoldMessenger.of(c)
    .showSnackBar(SnackBar(content: Text(m), backgroundColor: AppColors.ink));

Future<bool> _confirm(
    BuildContext c, String title, String msg, String yes) async {
  final r = await showDialog<bool>(
    context: c,
    barrierColor: kScrim,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppText.base(size: 22, weight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text(msg, style: AppText.bodyText()),
              const SizedBox(height: 22),
              PrimaryButton(yes, onTap: () => Navigator.pop(ctx, true)),
              const SizedBox(height: 12),
              OutlineButtonX('Batal', onTap: () => Navigator.pop(ctx, false)),
            ]),
      ),
    ),
  );
  return r ?? false;
}

/// Kolom teks dengan label, gaya sama seperti AppField tetapi memakai initialValue.
Widget _fld(String label, String initial, ValueChanged<String> onChanged,
    {String hint = '', int maxLines = 1}) {
  OutlineInputBorder b(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c, width: 1.5));
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: AppText.label()),
    const SizedBox(height: 8),
    TextFormField(
      initialValue: initial,
      onChanged: onChanged,
      maxLines: maxLines,
      style: AppText.base(color: AppColors.body),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppText.base(color: AppColors.muted),
        filled: true,
        fillColor: AppColors.field,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: b(AppColors.border),
        focusedBorder: b(AppColors.primary),
        border: b(AppColors.border),
      ),
    ),
  ]);
}

class _Pic extends StatelessWidget {
  final Uint8List? bytes;
  final String? asset;
  final bool video;
  final double size;
  const _Pic({this.bytes, this.asset, this.video = false, this.size = 56});

  @override
  Widget build(BuildContext context) {
    Widget icon(IconData i) =>
        Icon(i, color: AppColors.primary, size: size * .45);
    Widget child = icon(Icons.image_outlined);
    if (bytes != null) {
      child =
          Image.memory(bytes!, fit: BoxFit.cover, width: size, height: size);
    } else if (video) {
      child = icon(Icons.play_circle_outline);
    } else if (asset != null) {
      child = Image.asset(asset!,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (_, __, ___) => icon(Icons.broken_image_outlined));
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
          width: size,
          height: size,
          color: AppColors.tint,
          alignment: Alignment.center,
          child: child),
    );
  }
}

Widget _iconBtn(IconData i, VoidCallback f, {Color c = AppColors.primary}) =>
    InkResponse(
        onTap: f,
        radius: 22,
        child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(i, size: 22, color: c)));

Widget _sheet(BuildContext ctx, List<Widget> children) => Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children),
      ),
    );

Future<T?> _showSheet<T>(BuildContext c, WidgetBuilder b) =>
    showModalBottomSheet<T>(
      context: c,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      barrierColor: kScrim,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: b,
    );

// ───────────────────────── Shell ─────────────────────────

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});
  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _i = 0;
  static const _nav = <(IconData, String)>[
    (Icons.dashboard_outlined, 'Dashboard'),
    (Icons.photo_library_outlined, 'Asset'),
    (Icons.menu_book_outlined, 'Modul'),
    (Icons.volunteer_activism_outlined, 'Donasi'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: ListenableBuilder(
            listenable: adminStore,
            builder: (_, __) => IndexedStack(index: _i, children: [
              _Dashboard(onGo: (i) => setState(() => _i = i)),
              const _AssetTab(),
              const _ModulTab(),
              const _DonasiTab(),
            ]),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border))),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 72,
              child: Row(children: [
                for (var k = 0; k < _nav.length; k++)
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _i = k),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 58,
                              height: 32,
                              decoration: BoxDecoration(
                                  color: _i == k
                                      ? AppColors.tint
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16)),
                              child: Icon(_nav[k].$1,
                                  size: 24,
                                  color: _i == k
                                      ? AppColors.primary
                                      : AppColors.navIcon),
                            ),
                            const SizedBox(height: 4),
                            Text(_nav[k].$2,
                                style: AppText.base(
                                    size: 12,
                                    weight: _i == k
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: _i == k
                                        ? AppColors.primary
                                        : AppColors.navIcon)),
                          ]),
                    ),
                  ),
              ]),
            ),
          ),
        ),
      );
}

// ───────────────────────── Dashboard ─────────────────────────

int _total(List<Donation> l) =>
    l.where((d) => d.paid).fold(0, (a, d) => a + d.amount);

class _Dashboard extends StatelessWidget {
  final ValueChanged<int> onGo;
  const _Dashboard({required this.onGo});

  Widget _stat(String v, String l) => Expanded(
        child: OutlinedCard(
          radius: 14,
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(v,
                style: AppText.base(
                    size: 20,
                    weight: FontWeight.w800,
                    color: AppColors.primary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(l, style: AppText.caption()),
          ]),
        ),
      );

  Widget _menu(IconData i, String t, String s, int tab) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: OutlinedCard(
          radius: 14,
          onTap: () => onGo(tab),
          child: Row(children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                  color: AppColors.tint,
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(i, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t,
                        style: AppText.base(size: 16, weight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(s, style: AppText.caption()),
                  ]),
            ),
            const Icon(Icons.chevron_right, color: AppColors.primary),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final s = adminStore;
    return PageBody(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        children: [
          const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LogoLockup(),
                PillChip('ADMIN', size: 11, upper: true),
              ]),
          const SizedBox(height: 18),
          Text('Selamat datang, Admin',
              style: AppText.base(color: AppColors.body)),
          const SizedBox(height: 6),
          Text('Dashboard Admin', style: AppText.h2()),
          const SizedBox(height: 18),
          Row(children: [
            _stat('${s.assets.length}', 'Asset'),
            const SizedBox(width: 10),
            _stat('${s.moduls.length}', 'Modul'),
            const SizedBox(width: 10),
            _stat(rp(_total(s.donations)), 'Total donasi'),
          ]),
          const SizedBox(height: 22),
          Text('Menu utama', style: AppText.section()),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            icon: const Icon(Icons.cloud_outlined),
            label: const Text('Kelola Modul Online'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CloudModulesScreen(
                    isAdmin: true,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          _menu(Icons.photo_library_outlined, 'Kelola Asset',
              'Gambar gestur untuk halaman Kamus', 1),
          _menu(Icons.menu_book_outlined, 'Kelola Modul',
              'Modul, materi, dan kuis BISINDO', 2),
          _menu(Icons.volunteer_activism_outlined, 'Laporan Donasi',
              'Pantau donasi yang berhasil masuk', 3),
          const SizedBox(height: 10),
          OutlinedCard(
            radius: 14,
            onTap: () async {
              if (await _confirm(
                      context,
                      'Keluar dari akun?',
                      'Kamu akan kembali ke halaman Login dan perlu masuk lagi.',
                      'Ya, Keluar') &&
                  context.mounted) {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false);
              }
            },
            child: Row(children: [
              const Icon(Icons.logout, color: AppColors.error),
              const SizedBox(width: 12),
              Text('Keluar',
                  style: AppText.base(
                      size: 16,
                      weight: FontWeight.w700,
                      color: AppColors.error)),
            ]),
          ),
        ]);
  }
}

// ───────────────────────── Kelola Asset ─────────────────────────

class _AssetTab extends StatefulWidget {
  const _AssetTab();
  @override
  State<_AssetTab> createState() => _AssetTabState();
}

class _AssetTabState extends State<_AssetTab> {
  String _q = '';

  void _form({SignAsset? edit}) {
    var key = edit?.key ?? '';
    Uint8List? bytes = edit?.bytes;
    _showSheet(
        context,
        (ctx) => StatefulBuilder(builder: (ctx, set) {
              return _sheet(ctx, [
                Text(edit == null ? 'Tambah Asset' : 'Edit Asset',
                    style: AppText.section()),
                const SizedBox(height: 16),
                _fld('Huruf atau kata', key, (v) => key = v,
                    hint: 'Contoh: A atau Apel'),
                const SizedBox(height: 16),
                Row(children: [
                  _Pic(
                      bytes: bytes,
                      asset: edit?.path,
                      video: edit?.isVideo ?? false,
                      size: 72),
                  const SizedBox(width: 14),
                  Expanded(
                    child: OutlineButtonX('Pilih gambar', onTap: () async {
                      final b = await _pickImage();
                      if (b != null) set(() => bytes = b);
                    }),
                  ),
                ]),
                const SizedBox(height: 20),
                PrimaryButton('Simpan', onTap: () {
                  if (key.trim().isEmpty || (bytes == null && edit == null)) {
                    _snack(ctx, 'Isi huruf/kata dan pilih gambar dulu.');
                    return;
                  }
                  if (edit != null) {
                    edit.key = key.trim();
                    if (bytes != null) {
                      edit.bytes = bytes;
                      edit.path = null;
                    }
                  } else {
                    adminStore.assets.add(SignAsset(key.trim(), bytes: bytes));
                  }
                  adminStore.changed();
                  Navigator.pop(ctx);
                }),
              ]);
            }));
  }

  @override
  Widget build(BuildContext context) {
    final list = adminStore.assets
        .where((a) => a.key.toLowerCase().contains(_q.toLowerCase()))
        .toList()
      ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));
    return PageBody(children: [
      const TabTitle('Kelola Asset'),
      Text('Gambar gestur tangan untuk halaman Kamus.',
          style: AppText.bodyText()),
      const SizedBox(height: 16),
      PrimaryButton('Tambah Asset', trailing: Icons.add, onTap: () => _form()),
      const SizedBox(height: 14),
      Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            color: AppColors.tint,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.tintBorder)),
        child: Row(children: [
          const Icon(Icons.search, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() => _q = v),
              style: AppText.base(),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  hintText: 'Cari huruf atau kata...',
                  hintStyle: AppText.base(color: AppColors.body)),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 16),
      Text('${list.length} asset', style: AppText.caption()),
      const SizedBox(height: 10),
      for (final a in list)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: OutlinedCard(
            radius: 14,
            padding: const EdgeInsets.all(12),
            onTap: a.isVideo
                ? () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Video Huruf ${a.key}'),
                        content: SizedBox(
                          width: 400,
                          child: AssetVideoPlayer(
                            assetPath: a.path!,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Tutup'),
                          ),
                        ],
                      ),
                    );
                  }
                : null,
            child: Row(
              children: [
                _Pic(
                  bytes: a.bytes,
                  asset: a.path,
                  video: a.isVideo,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.key,
                        style: AppText.base(
                          size: 17,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${a.isLetter ? 'Huruf' : 'Kata'} • ${a.isVideo ? 'Video' : 'Gambar'}',
                        style: AppText.caption(),
                      ),
                    ],
                  ),
                ),
                _iconBtn(
                  Icons.edit_outlined,
                  () => _form(edit: a),
                ),
                _iconBtn(
                  Icons.delete_outline,
                  () async {
                    if (await _confirm(
                      context,
                      'Hapus asset ${a.key}?',
                      'Asset ini akan hilang dari halaman Kamus.',
                      'Ya, Hapus',
                    )) {
                      adminStore.assets.remove(a);
                      adminStore.changed();
                    }
                  },
                  c: AppColors.error,
                ),
              ],
            ),
          ),
        ),
    ]);
  }
}

// ───────────────────────── Kelola Modul ─────────────────────────

class _ModulTab extends StatelessWidget {
  const _ModulTab();

  @override
  Widget build(BuildContext context) {
    return const CloudModulesScreen(
      isAdmin: true,
    );
  }
}


class ModulEditor extends StatefulWidget {
  final int? index;
  final String? modulId;

  const ModulEditor({
    super.key,
    this.index,
    this.modulId,
  });

  @override
  State<ModulEditor> createState() =>
      _ModulEditorState();
}

class _ModulEditorState extends State<ModulEditor> {
  final ModulDetailService detailService =
      ModulDetailService();

  late Modul d;

  bool _loading = false;
  bool _saving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();

    // Mode editor lokal lama
    d = widget.index == null
        ? Modul('')
        : adminStore.moduls[widget.index!].copy();

    // Mode editor online
    if (widget.modulId != null) {
      _loading = true;
      _loadModulOnline();
    }
  }

  Future<void> _loadModulOnline() async {
    try {
      final hasil = await detailService.ambilModul(
        widget.modulId!,
      );

      if (!mounted) return;

      setState(() {
        d = hasil;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadError = e.toString();
        _loading = false;
      });
    }
  }

  
Future<void> _save() async {
  if (_saving) return;

  if (d.title.trim().isEmpty) {
    _snack(context, 'Judul modul wajib diisi.');
    return;
  }

  // Mode Firestore
  if (widget.modulId != null) {
    setState(() => _saving = true);

    try {
      await detailService.simpanModul(
        widget.modulId!,
        d,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Materi dan kuis berhasil disimpan.',
          ),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
    return;
  }

  // Mode lokal lama tetap dipertahankan
  if (widget.index == null) {
    adminStore.moduls.add(d);
  } else {
    adminStore.moduls[widget.index!] = d;
  }

  adminStore.changed();

  if (!mounted) return;
  Navigator.pop(context);
}


  Widget _materiCard(Materi m) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: OutlinedCard(
          radius: 14,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text('Materi ${d.materi.indexOf(m) + 1}',
                      style: AppText.eyebrow(color: AppColors.primary))),
              _iconBtn(Icons.delete_outline,
                  () => setState(() => d.materi.remove(m)),
                  c: AppColors.error),
            ]),
            _fld('Judul materi', m.title, (v) => m.title = v),
            const SizedBox(height: 12),
            _fld('Isi materi', m.body, (v) => m.body = v, maxLines: 5),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final b in m.images)
                Stack(children: [
                  _Pic(bytes: b, size: 64),
                  Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                          onTap: () => setState(() => m.images.remove(b)),
                          child: const CircleAvatar(
                              radius: 9,
                              backgroundColor: AppColors.error,
                              child: Icon(Icons.close,
                                  size: 12, color: Colors.white)))),
                ]),
              for (final v in m.videos)
                InputChip(
                    label: Text(v, style: AppText.base(size: 12)),
                    avatar: const Icon(Icons.videocam_outlined, size: 18),
                    onDeleted: () => setState(() => m.videos.remove(v))),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.image_outlined, size: 18),
                  label: const Text('Gambar'),
                  onPressed: () async {
                    final b = await _pickImage();
                    if (b != null) setState(() => m.images.add(b));
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.videocam_outlined, size: 18),
                  label: const Text('Video'),
                  onPressed: () async {
                    final x = await ImagePicker()
                        .pickVideo(source: ImageSource.gallery);
                    if (x != null) setState(() => m.videos.add(x.name));
                  },
                ),
              ),
            ]),
          ]),
        ),
      );

  void _questionForm({Question? edit}) {
    final q =
        edit?.copy() ?? Question('', [Option(), Option(), Option(), Option()]);
    _showSheet(
        context,
        (ctx) => StatefulBuilder(builder: (ctx, set) {
              return _sheet(ctx, [
                Text(edit == null ? 'Tambah Soal' : 'Edit Soal',
                    style: AppText.section()),
                const SizedBox(height: 16),
                _fld('Pertanyaan', q.text, (v) => q.text = v, maxLines: 2),
                const SizedBox(height: 12),
                Row(children: [
                  _Pic(bytes: q.image, size: 56),
                  const SizedBox(width: 12),
                  Expanded(
                      child: OutlineButtonX('Gambar soal', onTap: () async {
                    final b = await _pickImage();
                    if (b != null) set(() => q.image = b);
                  })),
                ]),
                const SizedBox(height: 16),
                Text('Pilihan jawaban (ketuk lingkaran untuk jawaban benar)',
                    style: AppText.caption()),
                const SizedBox(height: 8),
                for (var i = 0; i < q.options.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(children: [
                      _iconBtn(
                          q.correct == i
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          () => set(() => q.correct = i)),
                      Expanded(
                        child: TextFormField(
                          initialValue: q.options[i].text,
                          onChanged: (v) => q.options[i].text = v,
                          decoration: InputDecoration(
                            hintText: 'Jawaban ${String.fromCharCode(65 + i)}',
                            filled: true,
                            fillColor: AppColors.field,
                            isDense: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.border)),
                          ),
                        ),
                      ),
                      if (q.options[i].image != null)
                        _Pic(bytes: q.options[i].image, size: 36),
                      _iconBtn(Icons.image_outlined, () async {
                        final b = await _pickImage();
                        if (b != null) set(() => q.options[i].image = b);
                      }),
                    ]),
                  ),
                const SizedBox(height: 12),
                PrimaryButton('Simpan Soal', onTap: () {
                  if (q.text.trim().isEmpty ||
                      q.options.any(
                          (o) => o.text.trim().isEmpty && o.image == null)) {
                    _snack(ctx, 'Isi pertanyaan dan semua pilihan jawaban.');
                    return;
                  }
                  setState(() {
                    if (edit == null) {
                      d.quiz.add(q);
                    } else {
                      d.quiz[d.quiz.indexOf(edit)] = q;
                    }
                  });
                  Navigator.pop(ctx);
                }),
              ]);
            }));
  }

  @override
Widget build(BuildContext context) => _loading
    ? const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      )
    : _loadError != null
        ? Scaffold(
            appBar: AppBar(
              title: const Text('Gagal memuat modul'),
            ),
            body: Center(
              child: Text(_loadError!),
            ),
          )
        : DefaultTabController(        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(children: [
              BackHeader(widget.index == null ? 'Tambah Modul' : 'Edit Modul'),
              TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.body,
                indicatorColor: AppColors.primary,
                labelStyle: AppText.base(weight: FontWeight.w700),
                tabs: const [Tab(text: 'Materi'), Tab(text: 'Kuis')],
              ),
              Expanded(
                child: TabBarView(children: [
                  PageBody(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      children: [
                        _fld('Judul modul', d.title, (v) => d.title = v,
                            hint: 'Contoh: Angka & Waktu'),
                        const SizedBox(height: 14),
                        Row(children: [
                          _Pic(bytes: d.cover, size: 64),
                          const SizedBox(width: 14),
                          Expanded(
                              child: OutlineButtonX(
                                  d.cover == null
                                      ? 'Tambah sampul'
                                      : 'Ganti sampul', onTap: () async {
                            final b = await _pickImage();
                            if (b != null) setState(() => d.cover = b);
                          })),
                        ]),
                        const SizedBox(height: 20),
                        for (final m in d.materi) _materiCard(m),
                        OutlineButtonX('Tambah Materi',
                            onTap: () =>
                                setState(() => d.materi.add(Materi('', '')))),
                        const SizedBox(height: 16),
                        PrimaryButton('Simpan Perubahan', onTap: _save),
                      ]),
                  PageBody(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      children: [
                        for (var i = 0; i < d.quiz.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: OutlinedCard(
                              radius: 14,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Expanded(
                                          child: Text('Soal ${i + 1}',
                                              style: AppText.eyebrow(
                                                  color: AppColors.primary))),
                                      _iconBtn(Icons.edit_outlined,
                                          () => _questionForm(edit: d.quiz[i])),
                                      _iconBtn(
                                          Icons.delete_outline,
                                          () => setState(
                                              () => d.quiz.removeAt(i)),
                                          c: AppColors.error),
                                    ]),
                                    Text(d.quiz[i].text,
                                        style: AppText.base(
                                            weight: FontWeight.w700)),
                                    const SizedBox(height: 8),
                                    for (var k = 0;
                                        k < d.quiz[i].options.length;
                                        k++)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Row(children: [
                                          Icon(
                                              d.quiz[i].correct == k
                                                  ? Icons.check_circle
                                                  : Icons.circle_outlined,
                                              size: 18,
                                              color: d.quiz[i].correct == k
                                                  ? AppColors.primary
                                                  : AppColors.muted),
                                          const SizedBox(width: 8),
                                          Expanded(
                                              child: Text(
                                                  d.quiz[i].options[k].text,
                                                  style: AppText.caption())),
                                        ]),
                                      ),
                                  ]),
                            ),
                          ),
                        if (d.quiz.isEmpty)
                          Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text('Belum ada soal.',
                                  style: AppText.caption())),
                        OutlineButtonX('Tambah Soal',
                            onTap: () => _questionForm()),
                        const SizedBox(height: 16),
                        PrimaryButton('Simpan Perubahan', onTap: _save),
                      ]),
                ]),
              ),
            ]),
          ),
        ),
      );
}

// ───────────────────────── Laporan Donasi ─────────────────────────

class _DonasiTab extends StatefulWidget {
  const _DonasiTab();
  @override
  State<_DonasiTab> createState() => _DonasiTabState();
}

class _DonasiTabState extends State<_DonasiTab> {
  static const _filters = [
    ('Minggu ini', 7),
    ('Bulan ini', 30),
    ('3 bulan lalu', 90),
    ('1 tahun lalu', 365)
  ];
  int _f = 1;
  bool _asc = false;

  @override
  Widget build(BuildContext context) {
    final cut = DateTime.now().subtract(Duration(days: _filters[_f].$2));
    final list = adminStore.donations
        .where((d) => d.paid && d.date.isAfter(cut))
        .toList()
      ..sort((a, b) =>
          _asc ? a.amount.compareTo(b.amount) : b.amount.compareTo(a.amount));
    return PageBody(children: [
      const TabTitle('Laporan Donasi'),
      Text('Hanya donasi yang pembayarannya sudah berhasil.',
          style: AppText.bodyText()),
      const SizedBox(height: 16),
      TintCard(
        radius: 16,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('TOTAL DONASI • ${_filters[_f].$1.toUpperCase()}',
              style: AppText.eyebrow(color: AppColors.primary)),
          const SizedBox(height: 8),
          Text(rp(_total(list)),
              style: AppText.base(
                  size: 30, weight: FontWeight.w800, color: AppColors.primary)),
          const SizedBox(height: 4),
          Text('${list.length} donasi masuk', style: AppText.caption()),
        ]),
      ),
      const SizedBox(height: 16),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (var i = 0; i < _filters.length; i++)
          ChoiceChip(
            label: Text(_filters[i].$1),
            selected: _f == i,
            onSelected: (_) => setState(() => _f = i),
            selectedColor: AppColors.primary,
            labelStyle: AppText.base(
                size: 13,
                weight: FontWeight.w600,
                color: _f == i ? Colors.white : AppColors.primary),
            backgroundColor: AppColors.field,
            side: const BorderSide(color: AppColors.border),
            showCheckmark: false,
          ),
      ]),
      const SizedBox(height: 14),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Donasi masuk', style: AppText.section()),
        GestureDetector(
          onTap: () => setState(() => _asc = !_asc),
          child: Row(children: [
            Icon(_asc ? Icons.arrow_upward : Icons.arrow_downward,
                size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(_asc ? 'Terkecil' : 'Terbesar', style: AppText.link()),
          ]),
        ),
      ]),
      const SizedBox(height: 12),
      if (list.isEmpty)
        Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
                child: Text('Belum ada donasi pada periode ini.',
                    style: AppText.caption()))),
      for (final d in list)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: OutlinedCard(
            radius: 14,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.name,
                          style:
                              AppText.base(size: 16, weight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(d.email, style: AppText.caption()),
                      Text(d.phone, style: AppText.caption()),
                    ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(rp(d.amount),
                    style: AppText.base(
                        size: 16,
                        weight: FontWeight.w800,
                        color: AppColors.primary)),
                const SizedBox(height: 4),
                Text(tgl(d.date), style: AppText.caption()),
              ]),
            ]),
          ),
        ),
    ]);
  }
}
