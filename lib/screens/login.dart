import 'package:flutter/material.dart';

import '../admin/admin_data.dart';
import '../admin/admin_screens.dart';
import '../main.dart';
import '../theme.dart';
import '../widgets.dart';

// Demo credentials – replace with real auth.
const _demoEmail = 'andi@email.com';
const _demoPassword = 'bisindo123';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _error = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    // Akun admin masuk ke Dashboard Admin (alur user di bawah tidak berubah).
    if (_email.text.trim().toLowerCase() == adminEmail &&
        _password.text == adminPassword) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminShell()));
      return;
    }
    final ok = _email.text.trim().toLowerCase() == _demoEmail &&
        _password.text == _demoPassword;
    if (ok) {
      setState(() => _error = false);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShell()));
    } else {
      setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LogoLockup(),
                const SizedBox(height: 56),
                Text('Selamat datang!',
                    style: AppText.base(size: 30, weight: FontWeight.w700)),
                const SizedBox(height: 14),
                Text(
                  'Langkah kecil untuk saling mengerti. Masuk untuk melanjutkan belajar BISINDO.',
                  style: AppText.bodyText(size: 16),
                ),
                const SizedBox(height: 28),
                if (_error) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.errorBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 22, color: AppColors.error),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Email atau kata sandi salah. Periksa kembali dan coba lagi.',
                            style: AppText.base(
                                size: 14, color: AppColors.error, height: 1.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                ],
                AppField(
                  label: 'Alamat email',
                  hint: 'Masukkan alamat email',
                  controller: _email,
                  error: _error,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 22),
                AppField(
                  label: 'Kata sandi',
                  hint: 'Masukkan kata sandi',
                  controller: _password,
                  error: _error,
                  obscure: _obscure,
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.body),
                  ),
                ),
                const SizedBox(height: 22),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {},
                    child: Text('Lupa kata sandi?', style: AppText.link(size: 14)),
                  ),
                ),
                const SizedBox(height: 14),
                PrimaryButton('Masuk Sekarang',
                    trailing: Icons.arrow_forward, onTap: _submit),
                const SizedBox(height: 22),
                Center(
                  child: Text.rich(TextSpan(children: [
                    TextSpan(
                        text: 'Belum punya akun? ',
                        style: AppText.base(size: 15, color: AppColors.body)),
                    TextSpan(
                        text: 'Daftar Gratis',
                        style: AppText.base(
                            size: 15,
                            weight: FontWeight.w700,
                            color: AppColors.primary)),
                  ])),
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    const Icon(Icons.verified_user_outlined,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('Progres belajarmu tersimpan di akunmu.',
                        style: AppText.base(size: 13, color: AppColors.body)),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
