import 'package:flutter/material.dart';

class _NavItem {
  const _NavItem(this.label, this.icon, this.activeIcon);
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// Bottom navigation bar bersama untuk semua halaman.
///
/// Memakai Material 3 [NavigationBar]; seluruh warna, tinggi, indicator dan
/// tipografi diatur terpusat di `navigationBarTheme` (core/app_theme.dart).
///
/// Tab aktif: pill putih transparan + ikon terisi (bukan primaryContainer).
class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItem('Home', Icons.home_outlined, Icons.home),
    _NavItem('Explore', Icons.map_outlined, Icons.map),
    _NavItem('Observation', Icons.visibility_outlined, Icons.visibility),
    _NavItem('Missions', Icons.track_changes, Icons.track_changes),
    _NavItem('Community', Icons.people_outline, Icons.people),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: [
        for (final item in _items)
          NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.activeIcon),
            label: item.label,
          ),
      ],
    );
  }
}
