import 'package:flutter/material.dart';
import 'cloud_modules.dart';
import '../data.dart';
import '../theme.dart';
import '../widgets.dart';
import 'lesson.dart';

/// Shared tap behaviour: open the lesson, or show the "locked" sheet.
void onModuleTap(BuildContext context, int index) {
  final s = AppScope.of(context);
  if (s.statusOf(index) == ModuleStatus.locked) {
    showLockedSheet(context, index);
  } else {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => LessonScreen(moduleIndex: index)));
  }
}

class ModulesScreen extends StatelessWidget {
  const ModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return PageBody(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        const TabTitle('Modul Pembelajaran'),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.cloud_outlined),
          label: const Text('Lihat Modul Online'),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CloudModulesScreen(
                  isAdmin: false,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          s.allDone
              ? 'Semua modul selesai. Pilih materi mana pun untuk berlatih kembali.'
              : 'Mulai dari dasar, lalu lanjutkan satu per satu.',
          style: AppText.bodyText(size: 15),
        ),
        const SizedBox(height: 20),
        const ProgressCard(),
        const SizedBox(height: 20),
        if (s.allDone) ...[
          TintCard(
            radius: 10,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.verified_outlined,
                    size: 22, color: AppColors.primary),
                const SizedBox(width: 12),
                Text('5/5 selesai • Semua modul bebas diakses',
                    style: AppText.base(size: 14, weight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        for (var i = 0; i < modules.length; i++) ...[
          _ModuleCard(index: i),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final int index;
  const _ModuleCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final m = modules[index];
    final status = s.statusOf(index);
    final active = status == ModuleStatus.active;
    final locked = status == ModuleStatus.locked;
    final done = status == ModuleStatus.done;

    final chip = done ? 'Selesai' : (active ? 'Sedang dipelajari' : 'Terkunci');
    final action = done
        ? 'Ulangi materi'
        : (active ? 'Lanjutkan →' : 'Selesaikan Modul ${m.number - 1}');

    return OutlinedCard(
      radius: 14,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      borderColor: active ? AppColors.primary : AppColors.border,
      borderWidth: active ? 1.5 : 1,
      onTap: () => onModuleTap(context, index),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: locked ? AppColors.field : AppColors.tint,
                ),
                child: done
                    ? const Icon(Icons.check,
                        size: 22, color: AppColors.primary)
                    : locked
                        ? const Icon(Icons.lock_outline,
                            size: 22, color: AppColors.ink)
                        : Text('${m.number}',
                            style: AppText.base(
                                size: 20,
                                weight: FontWeight.w700,
                                color: AppColors.primary)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MODUL ${m.number}', style: AppText.eyebrow(size: 11)),
                    const SizedBox(height: 4),
                    Text(m.title,
                        style: AppText.base(size: 16, weight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(m.subtitle,
                        style: AppText.base(size: 12, color: AppColors.body)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PillChip(chip),
              Text(action,
                  style: locked
                      ? AppText.base(size: 13, weight: FontWeight.w600)
                      : AppText.link()),
            ],
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Locked bottom sheet ─────────────────────────

Future<void> showLockedSheet(BuildContext context, int index) {
  final s = AppScope.of(context);
  final m = modules[index];
  final cur = s.current;
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    barrierColor: kScrim,
    isScrollControlled: true,
    showDragHandle: false,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.lock_outline,
                    size: 28, color: AppColors.primary),
                InkResponse(
                  onTap: () => Navigator.pop(ctx),
                  child:
                      const Icon(Icons.close, size: 24, color: AppColors.ink),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text('Belajar selangkah demi selangkah',
                style: AppText.base(size: 22, weight: FontWeight.w700)),
            const SizedBox(height: 14),
            Text(
              'Modul ${m.number}: ${m.title} masih terkunci. Selesaikan materi dan kuis Modul ${cur.number} untuk membukanya.',
              style: AppText.bodyText(size: 15),
            ),
            const SizedBox(height: 16),
            const InfoBox(
              icon: Icons.alt_route,
              text:
                  'Modul berikutnya terbuka satu per satu. Setelah 5/5 selesai, semua modul bebas diulang.',
            ),
            const SizedBox(height: 20),
            PrimaryButton('Lanjutkan Modul ${cur.number}', onTap: () {
              Navigator.pop(ctx);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => LessonScreen(moduleIndex: s.currentIndex)));
            }),
            const SizedBox(height: 14),
            OutlineButtonX('Nanti saja', onTap: () => Navigator.pop(ctx)),
          ],
        ),
      ),
    ),
  );
}
