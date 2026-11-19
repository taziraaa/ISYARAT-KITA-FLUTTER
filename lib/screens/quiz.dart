import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';
import '../widgets.dart';
import 'lesson.dart';

// ───────────────────────── Quiz ─────────────────────────

class QuizScreen extends StatefulWidget {
  final int moduleIndex;
  const QuizScreen({super.key, required this.moduleIndex});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _q = 0;
  final List<int> _answers = List.filled(quizQuestions.length, -1);

  bool get _isLast => _q == quizQuestions.length - 1;
  int get _selected => _answers[_q];

  void _next() {
    if (_selected < 0) return;
    if (_isLast) {
      AppScope.of(context).finishModule(widget.moduleIndex);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => ResultScreen(
              moduleIndex: widget.moduleIndex, answers: List.of(_answers))));
    } else {
      setState(() => _q++);
    }
  }

  void _back() {
    if (_q > 0) {
      setState(() => _q--);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = quizQuestions[_q];
    final total = quizQuestions.length;
    return PopScope(
      canPop: _q == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                child: Row(
                  children: [
                    InkResponse(
                      onTap: _back,
                      radius: 24,
                      child: const Icon(Icons.arrow_back,
                          size: 24, color: AppColors.ink),
                    ),
                    const SizedBox(width: 28),
                    Text('Kuis Modul ${widget.moduleIndex + 1}',
                        style: AppText.appBar()),
                  ],
                ),
              ),
              Expanded(
                child: PageBody(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pertanyaan ${_q + 1} dari $total',
                            style: AppText.base(
                                size: 14,
                                weight: FontWeight.w700,
                                color: AppColors.primary)),
                        Text(_isLast ? 'Soal terakhir' : 'Sapaan dasar',
                            style: AppText.caption()),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ProgressBar((_q + 1) / total),
                    const SizedBox(height: 18),
                    Text(question.prompt,
                        style: AppText.base(
                            size: 24, weight: FontWeight.w700, height: 1.3)),
                    const SizedBox(height: 16),
                    SignImage(question.image),
                    const SizedBox(height: 16),
                    Text('Pilih satu jawaban yang paling sesuai.',
                        style: AppText.caption()),
                    const SizedBox(height: 14),
                    for (var i = 0; i < question.options.length; i++) ...[
                      _OptionTile(
                        label: question.options[i],
                        selected: _selected == i,
                        onTap: () => setState(() => _answers[_q] = i),
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 6),
                    Opacity(
                      opacity: _selected < 0 ? 0.5 : 1,
                      child: PrimaryButton(
                        _isLast ? 'Selesaikan Kuis' : 'Berikutnya',
                        trailing: _isLast ? Icons.check : Icons.arrow_forward,
                        onTap: _next,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _OptionTile(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? AppColors.tint : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            height: 54,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? AppColors.primary : Colors.white,
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    child: selected
                        ? Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle))
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(label,
                        style: AppText.base(
                            size: 15,
                            weight:
                                selected ? FontWeight.w700 : FontWeight.w500)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

// ───────────────────────── Result ─────────────────────────

class ResultScreen extends StatelessWidget {
  final int moduleIndex;
  final List<int> answers;
  const ResultScreen(
      {super.key, required this.moduleIndex, required this.answers});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final m = modules[moduleIndex];

    var correct = 0;
    int? firstWrong;
    for (var i = 0; i < quizQuestions.length; i++) {
      if (answers[i] == quizQuestions[i].answer) {
        correct++;
      } else {
        firstWrong ??= i;
      }
    }
    final wrong = quizQuestions.length - correct;
    final score = (correct / quizQuestions.length * 100).round();
    final verdict =
        score >= 90 ? 'Sangat bagus!' : (score >= 70 ? 'Bagus!' : 'Terus berlatih!');

    final nextIndex = moduleIndex + 1;
    final hasNext = nextIndex < modules.length;
    final lockedNumbers = [
      for (var i = 0; i < modules.length; i++)
        if (s.statusOf(i) == ModuleStatus.locked) i + 1
    ];
    String? lockedNote;
    if (hasNext) {
      lockedNote = 'Modul ${nextIndex + 1} kini terbuka.';
      if (lockedNumbers.length == 1) {
        lockedNote += ' Modul ${lockedNumbers.first} masih terkunci.';
      } else if (lockedNumbers.length > 1) {
        lockedNote +=
            ' Modul ${lockedNumbers.first}–${lockedNumbers.last} masih terkunci.';
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const BackHeader('Hasil Kuis'),
            Expanded(
              child: PageBody(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  const SizedBox(height: 6),
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: AppColors.tint),
                      child: const Icon(Icons.workspace_premium_outlined,
                          size: 36, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text('Hebat, ${s.firstName}!',
                        style: AppText.h2()),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Modul ${m.number} selesai: ${m.title}',
                      textAlign: TextAlign.center,
                      style: AppText.base(size: 15, color: AppColors.body),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                      child: PillChip('MODUL SELESAI', size: 11, upper: true)),
                  const SizedBox(height: 20),
                  // Score card
                  TintCard(
                    radius: 18,
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                    child: Column(
                      children: [
                        Text('SKOR KUIS KAMU',
                            style: AppText.eyebrow(
                                color: AppColors.primary, size: 12)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text('$score',
                                style: AppText.base(
                                    size: 56,
                                    weight: FontWeight.w800,
                                    color: AppColors.primary)),
                            const SizedBox(width: 6),
                            Text('/ 100',
                                style: AppText.base(
                                    size: 24,
                                    weight: FontWeight.w600,
                                    color: AppColors.primary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(verdict,
                            style: AppText.base(
                                size: 15, weight: FontWeight.w700)),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(child: _Stat('$correct', 'Benar')),
                            const SizedBox(width: 12),
                            Expanded(child: _Stat('$wrong', 'Salah')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const ProgressCard(),
                  const SizedBox(height: 18),
                  if (firstWrong != null)
                    _ReviewCard(
                        number: firstWrong + 1,
                        question: quizQuestions[firstWrong],
                        given: answers[firstWrong])
                  else
                    const InfoBox(
                        icon: Icons.verified_outlined,
                        text: 'Semua jawabanmu benar. Pertahankan!'),
                  const SizedBox(height: 16),
                  if (lockedNote != null) ...[
                    Text(lockedNote, style: AppText.caption()),
                    const SizedBox(height: 10),
                  ],
                  if (hasNext)
                    PrimaryButton(
                      'Modul ${nextIndex + 1}: ${modules[nextIndex].title}',
                      trailing: Icons.arrow_forward,
                      onTap: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) =>
                                  LessonScreen(moduleIndex: nextIndex))),
                    ),
                  const SizedBox(height: 12),
                  OutlineButtonX('Ulangi Kuis',
                      onTap: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) =>
                                  QuizScreen(moduleIndex: moduleIndex)))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: AppText.base(size: 22, weight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(label, style: AppText.caption()),
          ],
        ),
      );
}

class _ReviewCard extends StatelessWidget {
  final int number;
  final QuizQuestion question;
  final int given;
  const _ReviewCard(
      {required this.number, required this.question, required this.given});

  @override
  Widget build(BuildContext context) => OutlinedCard(
        radius: 14,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.replay, size: 22, color: AppColors.primary),
              const SizedBox(width: 10),
              Text('Ulasan jawaban • Soal $number', style: AppText.label()),
            ]),
            const SizedBox(height: 14),
            Text('Isyarat pada soal berarti “${question.meaning}”',
                style: AppText.base(size: 14, color: AppColors.body)),
            const SizedBox(height: 14),
            Text('Jawabanmu: ${question.options[given]}',
                style: AppText.base(
                    size: 13, weight: FontWeight.w500, color: AppColors.error)),
            const SizedBox(height: 14),
            Text('Jawaban benar: ${question.options[question.answer]}',
                style: AppText.base(
                    size: 13,
                    weight: FontWeight.w700,
                    color: AppColors.primary)),
            const SizedBox(height: 14),
            Text(question.tip, style: AppText.caption()),
          ],
        ),
      );
}
