import 'package:flutter/material.dart';

class _NavItem {
  const _NavItem(this.label, this.icon, this.activeIcon);
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

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
    _NavItem('Map', Icons.map_outlined, Icons.map),
    _NavItem('Observation', Icons.visibility_outlined, Icons.visibility),
    _NavItem('Missions', Icons.track_changes, Icons.track_changes),
    _NavItem('Community', Icons.people_outline, Icons.people),
  ];

  static const _green = Color(0xFF4CD964);
  static const _inactive = Color(0xFFB5BDB9);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1A211E),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.white10)),
          ),
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final selected = i == currentIndex;
              final color = selected ? _green : _inactive;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(selected ? item.activeIcon : item.icon,
                          color: color, size: 26),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}