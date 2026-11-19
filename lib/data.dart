import 'package:flutter/foundation.dart';

// ───────────────────────── State ─────────────────────────

class AppState extends ChangeNotifier {
  String name = 'Andi Pratama';
  String email = 'andi@email.com';

  /// Number of finished modules (design starts at 1 of 5 = 20%).
  int completed = 1;

  String get firstName => name.split(' ').first;
  int get percent => (completed / modules.length * 100).round();
  bool get allDone => completed >= modules.length;

  /// Index (0-based) of the module being studied.
  int get currentIndex => completed.clamp(0, modules.length - 1);

  ModuleItem get current => modules[currentIndex];

  ModuleStatus statusOf(int i) {
    if (i < completed) return ModuleStatus.done;
    if (i == completed) return ModuleStatus.active;
    return ModuleStatus.locked;
  }

  void finishModule(int index) {
    if (index + 1 > completed) {
      completed = index + 1;
      notifyListeners();
    }
  }

  void updateProfile(String newName, String newEmail) {
    name = newName;
    email = newEmail;
    notifyListeners();
  }
}

// ───────────────────────── Modules ─────────────────────────

enum ModuleStatus { done, active, locked }

class ModuleItem {
  final int number;
  final String title;
  final String subtitle;
  const ModuleItem(this.number, this.title, this.subtitle);
}

const modules = <ModuleItem>[
  ModuleItem(1, 'Pengenalan Abjad A–Z', '26 huruf • 3 materi'),
  ModuleItem(2, 'Kosa Kata & Sapaan Dasar', 'Sapaan sehari-hari • 3 materi'),
  ModuleItem(3, 'Angka & Waktu', 'Angka, hari, dan waktu • 3 materi'),
  ModuleItem(4, 'Hubungan Keluarga', 'Keluarga dan teman • 3 materi'),
  ModuleItem(5, 'Percakapan Sederhana', 'Percakapan sehari-hari • 3 materi'),
];

// ───────────────────────── Quiz ─────────────────────────

class QuizQuestion {
  final String prompt;
  final String image;
  final List<String> options;
  final int answer;
  final String meaning; // used in the review card
  final String tip;
  const QuizQuestion({
    required this.prompt,
    required this.image,
    required this.options,
    required this.answer,
    required this.meaning,
    this.tip = 'Perhatikan ekspresi bertanya, bukan hanya posisi tangan.',
  });
}

// NOTE: only 3 gesture illustrations exist in the design export, so the
// ten questions re-use them. Replace `image` with real assets later.
const quizQuestions = <QuizQuestion>[
  QuizQuestion(
    prompt: 'Apa arti isyarat pada gambar ini?',
    image: 'assets/images/quiz_halo.png',
    options: ['Halo', 'Maaf', 'Terima kasih', 'Selamat malam'],
    answer: 0,
    meaning: 'Halo',
  ),
  QuizQuestion(
    prompt: 'Apa arti isyarat pada gambar ini?',
    image: 'assets/images/quiz_terima_kasih.png',
    options: ['Selamat pagi', 'Terima kasih', 'Apa kabar?', 'Sampai jumpa'],
    answer: 1,
    meaning: 'Terima kasih',
  ),
  QuizQuestion(
    prompt: 'Apa arti isyarat pada gambar ini?',
    image: 'assets/images/sign_apa_kabar.png',
    options: ['Maaf', 'Halo', 'Apa kabar?', 'Terima kasih'],
    answer: 2,
    meaning: 'Apa kabar?',
  ),
  QuizQuestion(
    prompt: 'Sapaan apa yang ditunjukkan pada gambar?',
    image: 'assets/images/quiz_halo.png',
    options: ['Halo', 'Maaf', 'Terima kasih', 'Selamat malam'],
    answer: 0,
    meaning: 'Halo',
  ),
  QuizQuestion(
    prompt: 'Apa arti isyarat pada gambar ini?',
    image: 'assets/images/quiz_terima_kasih.png',
    options: ['Terima kasih', 'Halo', 'Maaf', 'Apa kabar?'],
    answer: 0,
    meaning: 'Terima kasih',
  ),
  QuizQuestion(
    prompt: 'Apa arti isyarat pada gambar ini?',
    image: 'assets/images/sign_halo.png',
    options: ['Sampai jumpa', 'Halo', 'Selamat pagi', 'Maaf'],
    answer: 1,
    meaning: 'Halo',
  ),
  QuizQuestion(
    prompt: 'Apa arti isyarat pada gambar ini?',
    image: 'assets/images/sign_apa_kabar.png',
    options: ['Selamat pagi', 'Halo', 'Apa kabar?', 'Terima kasih'],
    answer: 2,
    meaning: 'Apa kabar?',
  ),
  QuizQuestion(
    prompt: 'Sapaan apa yang ditunjukkan pada gambar?',
    image: 'assets/images/sign_terima_kasih.png',
    options: ['Maaf', 'Terima kasih', 'Halo', 'Selamat malam'],
    answer: 1,
    meaning: 'Terima kasih',
  ),
  QuizQuestion(
    prompt: 'Apa arti isyarat pada gambar ini?',
    image: 'assets/images/sign_halo.png',
    options: ['Halo', 'Apa kabar?', 'Maaf', 'Sampai jumpa'],
    answer: 0,
    meaning: 'Halo',
  ),
  QuizQuestion(
    prompt: 'Apa arti isyarat pada gambar ini?',
    image: 'assets/images/quiz_terima_kasih.png',
    options: ['Selamat pagi', 'Terima kasih', 'Apa kabar?', 'Sampai jumpa'],
    answer: 1,
    meaning: 'Terima kasih',
  ),
];

// ───────────────────────── Dictionary ─────────────────────────

class Word {
  final String word;
  final String category;
  final bool spelling; // shows "• Ejaan A P E L" in the subtitle
  const Word(this.word, this.category, {this.spelling = false});

  String get letter => word[0].toUpperCase();
  String get spaced => word.toUpperCase().split('').join(' ');
  String get subtitle => spelling ? '$category • Ejaan $spaced' : category;
}

const dictionary = <Word>[
  Word('Adik', 'Keluarga'),
  Word('Air', 'Benda sehari-hari'),
  Word('Aku', 'Kata ganti'),
  Word('Anak', 'Keluarga'),
  Word('Apa', 'Kata tanya'),
  Word('Apel', 'Buah', spelling: true),
  Word('Bapak', 'Keluarga'),
  Word('Buku', 'Benda sehari-hari'),
  Word('Ibu', 'Keluarga'),
  Word('Ini', 'Kata tunjuk'),
  Word('Kakak', 'Keluarga'),
  Word('Kamu', 'Kata ganti'),
  Word('Maaf', 'Ungkapan'),
  Word('Makan', 'Kata kerja'),
  Word('Saya', 'Kata ganti'),
  Word('Selamat pagi', 'Sapaan'),
  Word('Terima kasih', 'Ungkapan'),
  Word('Tolong', 'Ungkapan'),
];

/// Spelling illustrations available in the design export.
const spellAssets = <String, String>{
  'A': 'assets/images/spell_a.png',
  'P': 'assets/images/spell_p.png',
  'E': 'assets/images/spell_e.png',
  'L': 'assets/images/spell_l.png',
};
