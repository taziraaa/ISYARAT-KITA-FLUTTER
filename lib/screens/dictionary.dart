import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';
import '../widgets.dart';
import '../asset_video_player.dart';
import '../admin/admin_data.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  static const _letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  final _controller = TextEditingController();
  String _letter = 'A';

  String get _query => _controller.text.trim();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open(Word w) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => WordDetailScreen(word: w)));

  @override
  Widget build(BuildContext context) {
    final searching = _query.isNotEmpty;
    final results = searching
        ? dictionary
            .where((w) => w.word.toLowerCase().contains(_query.toLowerCase()))
            .toList()
        : dictionary.where((w) => w.letter == _letter).toList();

    return PageBody(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        const TabTitle('Kamus BISINDO'),
        const SizedBox(height: 4),
        Text('Temukan kosakata, pahami isyaratnya.',
            style: AppText.bodyText(size: 15)),
        const SizedBox(height: 20),
        _SearchField(
          controller: _controller,
          onChanged: (_) => setState(() {}),
          onClear: () => setState(_controller.clear),
        ),
        const SizedBox(height: 16),
        if (!searching) ...[
          Text('Pilih huruf A–Z',
              style: AppText.base(size: 14, weight: FontWeight.w700)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final l in _letters.split(''))
                _LetterTile(
                  letter: l,
                  selected: l == _letter,
                  onTap: () => setState(() => _letter = l),
                ),
            ],
          ),
          const SizedBox(height: 26),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(searching ? 'Hasil untuk “$_query”' : 'Kosakata huruf $_letter',
                style: AppText.section()),
            Text('${results.length} kata', style: AppText.caption()),
          ],
        ),
        const SizedBox(height: 14),
        if (results.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                searching
                    ? 'Kosakata tidak ditemukan.'
                    : 'Belum ada kosakata untuk huruf $_letter.',
                style: AppText.caption(),
              ),
            ),
          ),
        for (final w in results) ...[
          _WordTile(word: w, onTap: () => _open(w)),
          const SizedBox(height: 10),
        ],
        if (searching && results.isNotEmpty) ...[
          const SizedBox(height: 6),
          TintCard(
            radius: 14,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Belajar mengeja ${results.first.word.toUpperCase()}',
                    style: AppText.label()),
                const SizedBox(height: 12),
                Text(
                  'Lihat empat huruf dan contoh gestur terpisah di detail kata.',
                  style: AppText.base(size: 14, height: 1.5),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(results.first.spaced,
                      style: AppText.base(
                          size: 12,
                          weight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 3)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  const _SearchField(
      {required this.controller,
      required this.onChanged,
      required this.onClear});

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.isNotEmpty;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.tint,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
            color: hasText ? AppColors.primary : AppColors.tintBorder,
            width: hasText ? 1.5 : 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.search, size: 26, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: AppColors.primary,
              style: AppText.base(size: 16, color: AppColors.ink),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Cari kosakata...',
                hintStyle: AppText.base(size: 16, color: AppColors.body),
                isCollapsed: true,
              ),
            ),
          ),
          if (hasText)
            InkResponse(
              onTap: onClear,
              child: const Icon(Icons.close, size: 24, color: AppColors.primary),
            ),
        ],
      ),
    );
  }
}


class _LetterTile extends StatelessWidget {
  final String letter;
  final bool selected;
  final VoidCallback onTap;

  const _LetterTile({
    required this.letter,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: adminStore,
      builder: (context, _) {
        SignAsset? signAsset;

        for (final item in adminStore.assets) {
          if (item.key.toUpperCase() == letter.toUpperCase()) {
            signAsset = item;
            break;
          }
        }

        final path = signAsset?.path;
        final bytes = signAsset?.bytes;
        final isVideo = signAsset?.isVideo == true;

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? AppColors.primary
                    : AppColors.border,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (bytes != null)
                        Image.memory(
                          bytes,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              _letterFallback(),
                        )
                      else if (path != null && !isVideo)
                        Image.asset(
                          path,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              _letterFallback(),
                        )
                      else
                        _letterFallback(),
                      if (isVideo)
                        const Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            size: 34,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    letter,
                    style: AppText.base(
                      size: 18,
                      weight: FontWeight.w800,
                      color: selected ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _letterFallback() {
    return Container(
      color: AppColors.tint,
      alignment: Alignment.center,
      child: Text(
        letter,
        style: AppText.base(
          size: 32,
          weight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }
}


class _WordTile extends StatelessWidget {
  final Word word;
  final VoidCallback onTap;
  const _WordTile({required this.word, required this.onTap});

  @override
  Widget build(BuildContext context) => OutlinedCard(
        radius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.tint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(word.letter,
                  style: AppText.base(
                      size: 22,
                      weight: FontWeight.w700,
                      color: AppColors.primary)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(word.word,
                      style: AppText.base(size: 17, weight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(word.subtitle, style: AppText.caption()),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 26, color: AppColors.primary),
          ],
        ),
      );
}

// ───────────────────────── Word detail ─────────────────────────

class WordDetailScreen extends StatelessWidget {
  final Word word;
  const WordDetailScreen({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    final letters = word.word.toUpperCase().replaceAll(' ', '').split('');
    final n = letters.length;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const BackHeader('Detail Kata'),
            Expanded(
              child: PageBody(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: PillChip(
                        '${word.category.toUpperCase()} • EJAAN',
                        size: 11,
                        upper: true),
                  ),
                  const SizedBox(height: 14),
                  Text(word.word.toUpperCase(),
                      style: AppText.base(
                          size: 36, weight: FontWeight.w800, height: 1.1)),
                  const SizedBox(height: 14),
                  Text(word.spaced,
                      style: AppText.base(
                          size: 18,
                          weight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 4)),
                  const SizedBox(height: 10),
                  Text(
                    'Ikuti urutan ${n == 4 ? 'empat' : '$n'} huruf berikut. Setiap huruf memiliki contoh gesturnya sendiri.',
                    style: AppText.bodyText(size: 15),
                  ),
                  const SizedBox(height: 18),
                  LayoutBuilder(builder: (context, c) {
                    const gap = 14.0;
                    final w = (c.maxWidth - gap) / 2;
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        for (final l in letters)
                          SizedBox(width: w, child: _LetterCard(letter: l)),
                      ],
                    );
                  }),
                  const SizedBox(height: 22),
                  TipCard(
                    title: 'Tips mengeja',
                    text:
                        'Eja ${letters.join(' → ')} dengan tempo konsisten. Beri jeda singkat antarahuruf dan pastikan kedua tangan terlihat jelas.',
                  ),
                  const SizedBox(height: 22),
                  OutlineButtonX('Kembali ke Kamus',
                      onTap: () => Navigator.of(context).pop()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class _LetterCard extends StatelessWidget {
  final String letter;

  const _LetterCard({required this.letter});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: adminStore,
      builder: (context, _) {
        SignAsset? signAsset;

        for (final item in adminStore.assets) {
          if (item.key.toUpperCase() == letter.toUpperCase()) {
            signAsset = item;
            break;
          }
        }

        final path = signAsset?.path;
        final bytes = signAsset?.bytes;
        final isVideo = signAsset?.isVideo == true;

        Widget media;

        if (isVideo && path != null) {
          media = ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AssetVideoPlayer(assetPath: path),
          );
        } else {
          media = AspectRatio(
            aspectRatio: 157 / 159,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: bytes != null
                  ? Image.memory(
                      bytes,
                      fit: BoxFit.contain,
                      width: double.infinity,
                    )
                  : path != null
                      ? Image.asset(
                          path,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) =>
                              _fallbackLetter(),
                        )
                      : (spellAssets[letter] != null
                          ? SignImage(
                              spellAssets[letter]!,
                              radius: 12,
                            )
                          : _fallbackLetter()),
            ),
          );
        }

        return OutlinedCard(
          radius: 14,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    letter,
                    style: AppText.base(
                      size: 24,
                      weight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'EJAAN',
                    style: AppText.eyebrow(size: 11),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              media,
            ],
          ),
        );
      },
    );
  }

  Widget _fallbackLetter() {
    return Container(
      color: AppColors.tint,
      alignment: Alignment.center,
      child: Text(
        letter,
        style: AppText.base(
          size: 48,
          weight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

