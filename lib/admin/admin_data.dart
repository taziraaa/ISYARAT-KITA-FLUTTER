import 'package:flutter/foundation.dart';

import '../data.dart';

// Akun admin demo (ganti dengan autentikasi sungguhan nanti).
const adminEmail = 'admin@isyaratkita.id';
const adminPassword = 'admin123';

class SignAsset {
  String key; // huruf (A) atau kata (Apel)
  String? path; // asset bawaan aplikasi
  Uint8List? bytes; // gambar yang diunggah admin
  SignAsset(this.key, {this.path, this.bytes});
  bool get isVideo => (path ?? '').endsWith('.mp4');
  bool get isLetter => key.length == 1;
}

class Option {
  String text;
  Uint8List? image;
  Option([this.text = '', this.image]);
}

class Question {
  String text;
  Uint8List? image;
  List<Option> options;
  int correct;
  Question(this.text, this.options, {this.correct = 0, this.image});
  Question copy() => Question(text, [for (final o in options) Option(o.text, o.image)],
      correct: correct, image: image);
}

class Materi {
  String title;
  String body;
  List<Uint8List> images;
  List<String> videos; // nama file video
  Materi(this.title, this.body, {List<Uint8List>? images, List<String>? videos})
      : images = images ?? [],
        videos = videos ?? [];
  Materi copy() => Materi(title, body, images: [...images], videos: [...videos]);
}

class Modul {
  String title;
  Uint8List? cover;
  List<Materi> materi;
  List<Question> quiz;
  Modul(this.title, {this.cover, List<Materi>? materi, List<Question>? quiz})
      : materi = materi ?? [],
        quiz = quiz ?? [];
  Modul copy() => Modul(title,
      cover: cover,
      materi: [for (final m in materi) m.copy()],
      quiz: [for (final q in quiz) q.copy()]);
}

class Donation {
  final String name, email, phone;
  final int amount;
  final DateTime date;
  final bool paid; // hanya paid == true yang dihitung & ditampilkan
  Donation(this.name, this.email, this.phone, this.amount, this.date, this.paid);
}

const _files = [
  'A.jpeg', 'B.png', 'C.png', 'D.png', 'E.png', 'F.png', 'G.png', 'H.png',
  'I.png', 'J.mp4', 'K.png', 'L.png','M.png','N.png','O.png', 'P.png', 'Q.png', 'R.mp4', 'S.png',
  'T.png', 'U.png', 'V.png', 'W.png', 'X.png', 'Y.mp4', 'Z.png',
];

class AdminStore extends ChangeNotifier {
  final assets = <SignAsset>[
    for (final f in _files) SignAsset(f.split('.').first, path: 'assets/images/$f')
  ];

  final moduls = <Modul>[
    for (final m in modules)
      Modul(m.title, materi: [
        for (var i = 1; i <= 3; i++)
          Materi('Materi $i', 'Isi materi $i untuk modul ${m.number}.'),
      ], quiz: [
        if (m.number == 2)
          for (final q in quizQuestions.take(3))
            Question(q.prompt, [for (final o in q.options) Option(o)],
                correct: q.answer),
      ])
  ];

  late final donations = <Donation>[
    _d('Budi Santoso', 'budi@email.com', '081234567890', 50000, 2, true),
    _d('Siti Aminah', 'siti@email.com', '082111222333', 100000, 5, true),
    _d('Rizky Pratama', 'rizky@email.com', '085700001111', 25000, 12, true),
    _d('Dewi Lestari', 'dewi@email.com', '081355667788', 200000, 40, true),
    _d('Agus Salim', 'agus@email.com', '087811223344', 75000, 70, true),
    _d('Maya Putri', 'maya@email.com', '081900112233', 150000, 150, true),
    _d('Hendra Wijaya', 'hendra@email.com', '089600998877', 500000, 300, true),
    _d('Tono (belum bayar)', 'tono@email.com', '081200000000', 300000, 1, false),
  ];

  Donation _d(String n, String e, String p, int a, int daysAgo, bool paid) =>
      Donation(n, e, p, a, DateTime.now().subtract(Duration(days: daysAgo)), paid);

  void changed() => notifyListeners();
}

final adminStore = AdminStore();

String rp(int n) =>
    'Rp ${n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';

String tgl(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
