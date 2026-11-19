import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data.dart';
import 'screens/dictionary.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/modules.dart';
import 'screens/profile.dart';
import 'theme.dart';
import 'widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const IsyaratKitaApp());
}

class IsyaratKitaApp extends StatefulWidget {
  const IsyaratKitaApp({super.key});

  @override
  State<IsyaratKitaApp> createState() => _IsyaratKitaAppState();
}

class _IsyaratKitaAppState extends State<IsyaratKitaApp> {
  final _state = AppState();

  @override
  Widget build(BuildContext context) => AppScope(
        state: _state,
        child: MaterialApp(
          title: 'IsyaratKita',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(),
          home: const LoginScreen(),
        ),
      );
}

/// Bottom navigation shell: Beranda · Modul · Kamus · Profile.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  /// Lets child screens (e.g. "Lihat semua") switch tabs.
  static void goToTab(BuildContext context, int i) =>
      context.findAncestorStateOfType<_MainShellState>()?._select(i);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _select(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _index,
            children: const [
              HomeScreen(),
              ModulesScreen(),
              DictionaryScreen(),
              ProfileScreen(),
            ],
          ),
        ),
        bottomNavigationBar: AppBottomNav(index: _index, onTap: _select),
      );
}
