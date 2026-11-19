# IsyaratKita (Flutter)

1. Put this folder anywhere, then generate the platform folders once:
   `flutter create . --org com.isyaratkita --project-name isyarat_kita`
   (keeps lib/, pubspec.yaml and assets/ as they are)
2. `flutter pub get`
3. `flutter run`

Requires Flutter 3.24+ (Dart 3.3+). Font: Plus Jakarta Sans via google_fonts
(needs internet on first run; bundle the .ttf files for offline use).

Demo login: andi@email.com / bisindo123  (anything else shows the error state)


## Dashboard Admin (baru)

Login di halaman Login yang sama:
- Admin: `admin@isyaratkita.id` / `admin123`  -> Dashboard Admin
- User : `andi@email.com` / `bisindo123`      -> Beranda user (tidak berubah)

Setelah `flutter pub get` (ada paket baru: image_picker), jalankan `flutter run`.

File admin ada di `lib/admin/`:
- `admin_data.dart`    model + data contoh (asset, modul, donasi) di memori
- `admin_screens.dart` Dashboard, Kelola Asset, Kelola Modul (materi + kuis), Laporan Donasi, Logout

Data admin masih disimpan di memori (hilang saat aplikasi ditutup).
File yang diubah: `lib/screens/login.dart` (cabang login admin), `pubspec.yaml` (image_picker), README.
