import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app_theme.dart';
import 'layouts/main_layout.dart';
import 'pages/explore_page.dart';
import 'pages/observation_page.dart';
import 'pages/camera_page.dart';

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

class WildspotApp extends StatelessWidget {
  const WildspotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WildSpot',
      debugShowCheckedModeBanner: false,
      theme: buildWsTheme(),
      home: const CameraPage(), //SWITCH HEREEEE
    );
  }
}

/// Memegang state tab aktif.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 1;

  static const _titles = [
    'Home',
    'Explore Wildlife',
    'Observation',
    'Missions',
    'Community',
  ];

  Widget _pageFor(int index) {
    if (index == 1) return const ExploreScreen();
    if (index == 2) return const ObservationScreen();

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
