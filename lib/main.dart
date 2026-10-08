import 'package:flutter/material.dart';

import 'layouts/main_layout.dart';
import 'pages/explore_page.dart';

void main() => runApp(const WildspotApp());

class WildspotApp extends StatelessWidget {
  const WildspotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wildspot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A211E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4CD964),
          surface: Color(0xFF1A211E),
        ),
      ),
      home: const AppShell(),
    );
  }
}

/// Memegang state tab aktif (StatefulWidget sederhana).
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 1; // Map aktif, sesuai mockup

  static const _titles = [
    'Home',
    'Explore Wildlife',
    'Observation',
    'Missions',
    'Community',
  ];

  Widget _pageFor(int index) {
    if (index == 1) return const ExploreScreen();
    // Placeholder untuk halaman lain.
    return Center(child: Text('${_titles[index]} (coming soon)'));
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: _titles[_index],
      currentIndex: _index,
      onTabChanged: (i) => setState(() => _index = i),
      body: _pageFor(_index),
    );
  }
}