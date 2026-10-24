import 'package:flutter/material.dart';

import '../components/custom_app_bar.dart';
import '../components/bottom_nav.dart';
import '../pages/profile_page.dart';
import '../pages/settings_page.dart';

/// Wrapper reusable: Custom App Bar + [body] + Bottom Navigation Bar.
class MainLayout extends StatelessWidget {
  const MainLayout({
    super.key,
    required this.body,
    required this.title,
    required this.currentIndex,
    required this.onTabChanged,
  });

  final Widget body;
  final String title;
  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: title,
        onNotificationTap: () {},
        onSettingsTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
        ),
        onProfileTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
        ),
      ),
      body: body,
      bottomNavigationBar: BottomNav(
        currentIndex: currentIndex,
        onTap: onTabChanged,
      ),
    );
  }
}