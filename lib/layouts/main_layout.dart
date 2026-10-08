import 'package:flutter/material.dart';

import '../components/custom_app_bar.dart';
import '../components/bottom_nav.dart';

/// Wrapper reusable: Custom App Bar + [body] + Bottom Navigation Bar.
class MainLayout extends StatelessWidget {
  const MainLayout({
    super.key,
    required this.body,
    required this.title,
    required this.currentIndex,
    required this.onTabChanged,
    this.profileImageUrl = kDefaultProfileImage,
  });

  final Widget body;
  final String title;
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final String profileImageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: title,
        profileImageUrl: profileImageUrl,
        onFilterTap: () {},
        onNotificationTap: () {},
        onSettingsTap: () {},
        onProfileTap: () {},
      ),
      body: body,
      bottomNavigationBar: BottomNav(
        currentIndex: currentIndex,
        onTap: onTabChanged,
      ),
    );
  }
}