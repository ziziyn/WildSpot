import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app_theme.dart';
import 'core/user_scope.dart';
import 'layouts/main_layout.dart';
import 'pages/home_page.dart';
import 'pages/explore_page.dart';
import 'pages/observation_page.dart';
import 'pages/welcome_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const WildspotApp());
}

class WildspotApp extends StatefulWidget {
  const WildspotApp({super.key});

  @override
  State<WildspotApp> createState() => _WildspotAppState();
}

class _WildspotAppState extends State<WildspotApp> {
  // Satu sumber data user untuk seluruh app (avatar, nama, status verified).
  final _user = UserController();

  @override
  void dispose() {
    _user.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // UserScope di atas MaterialApp supaya semua route ikut terjangkau.
    return UserScope(
      controller: _user,
      child: MaterialApp(
        title: 'WildSpot',
        debugShowCheckedModeBanner: false,
        theme: buildWsTheme(),
        // Aplikasi dimulai dari halaman Welcome/Login
        home: const WelcomeScreen(),
      ),
    );
  }
}

/// Shell utama aplikasi.
/// Setelah login berhasil, user masuk ke sini.
/// Bottom navigation dan halaman lainnya tetap terhubung.
class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  static const _titles = [
    'WildSpot',
    'Explore Wildlife',
    'Observation',
    'Missions',
    'Community',
  ];
  Widget _pageFor(int index) {
    if (index == 0) {
      return const HomePage();
    }
    if (index == 1) {
      return const ExploreScreen();
    }
    if (index == 2) {
      return const ObservationScreen();
    }
    return Center(child: Text('${_titles[index]} (coming soon)'));
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: _titles[_index],
      currentIndex: _index,
      onTabChanged: (index) {
        setState(() {
          _index = index;
        });
      },
      body: _pageFor(_index),
    );
  }
}
