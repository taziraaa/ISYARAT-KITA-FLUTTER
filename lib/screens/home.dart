import 'package:flutter/material.dart';

import '../data.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets.dart';
import 'lesson.dart';
import 'modules.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final cur = s.current;
    // Two small cards: the modules that are not the current one.
    final others = [
      for (var i = 0; i < modules.length; i++)
        if (i != s.currentIndex) i
    ].take(2).toList();

    return PageBody(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const LogoLockup(),
            GestureDetector(
              onTap: () => MainShell.goToTab(context, 3),
              child: const AvatarCircle(size: 44, iconSize: 32, ring: true),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text('Selamat pagi, ${s.firstName}',
            style: AppText.base(size: 15, color: AppColors.body)),
        const SizedBox(height: 6),
        Text('Yuk, belajar lagi!', style: AppText.h2()),
        const SizedBox(height: 6),
        Text('Satu isyarat, selangkah lebih dekat.',
            style: AppText.base(size: 14, color: AppColors.body)),
        const SizedBox(height: 20),
        const ProgressCard(),
        const SizedBox(height: 20),
        // Hero: current module
        TintCard(
          radius: 18,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text('SEDANG DIPELAJARI',
                        style: AppText.eyebrow(color: AppColors.primary)),
                  ),
                  const Icon(Icons.menu_book_outlined,
                      size: 26, color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text('MODUL ${cur.number}',
                    style: AppText.base(
                        size: 12,
                        weight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.4)),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(cur.title,
                    style: AppText.base(size: 22, weight: FontWeight.w700)),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'Kenali sapaan dan ungkapan untuk percakapan sehari-hari.',
                  style: AppText.base(size: 14, color: AppColors.body, height: 1.5),
                ),
              ),
              const SizedBox(height: 14),
              PrimaryButton('Lanjutkan Belajar',
                  trailing: Icons.arrow_forward,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => LessonScreen(moduleIndex: s.currentIndex)))),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Modul belajarmu', style: AppText.section()),
            GestureDetector(
              onTap: () => MainShell.goToTab(context, 1),
              child: Text('Lihat semua', style: AppText.link()),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            for (var k = 0; k < others.length; k++) ...[
              if (k > 0) const SizedBox(width: 12),
              Expanded(child: _MiniModuleCard(index: others[k])),
            ],
          ],
        ),
      ],
    );
  }
}

class _MiniModuleCard extends StatelessWidget {
  final int index;
  const _MiniModuleCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final m = modules[index];
    final status = s.statusOf(index);
    final done = status == ModuleStatus.done;
    final locked = status == ModuleStatus.locked;
    return OutlinedCard(
      radius: 14,
      padding: const EdgeInsets.all(14),
      onTap: () => onModuleTap(context, index),
      child: SizedBox(
        height: 94,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Modul ${m.number}',
                    style: AppText.base(
                        size: 12,
                        weight: FontWeight.w700,
                        color: AppColors.primary)),
                Icon(
                    done
                        ? Icons.check
                        : (locked ? Icons.lock_outline : Icons.menu_book_outlined),
                    size: 20,
                    color: AppColors.primary),
              ],
            ),
            const SizedBox(height: 10),
            Text(m.title.replaceFirst('Pengenalan ', 'Pengenalan\n'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.base(size: 15, weight: FontWeight.w700, height: 1.35)),
            const Spacer(),
            Text(done ? 'Selesai' : (locked ? 'Terkunci' : 'Sedang dipelajari'),
                style: AppText.base(size: 12, color: AppColors.body)),
          ],
        ),
      ),
    );
  }
}
