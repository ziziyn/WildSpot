import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app_theme.dart';
import 'pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Status bar transparan agar nuansa alam terasa lebih immersive
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
      // HomeScreen sudah memegang state tab + MainLayout di dalamnya
      home: const HomeScreen(),
    );
  }
}