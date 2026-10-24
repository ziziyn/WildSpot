import 'package:flutter/material.dart';

import '../core/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════
//  STATS ROW — baris statistik 3 kolom yang dipakai bersama
//  (Home "Your Discoveries" dan Profile).
//
//  Hanya baris kolom + pemisah vertikal yang dibagikan. Kartu pembungkus
//  (padding, border, shadow, header, dst.) tetap milik halaman masing-masing.
// ═══════════════════════════════════════════════════════════════════

/// Data satu statistik. Semua dipassing dari halaman.
@immutable
class StatItemData {
  const StatItemData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

/// Susunan isi satu kolom statistik.
enum StatLayout {
  /// Ikon di atas, lalu label, lalu angka (Home).
  stacked(dividerHeight: 52),

  /// Ikon di kiri angka, label di bawahnya (Profile).
  inline(dividerHeight: 44);

  const StatLayout({required this.dividerHeight});

  /// Tinggi garis pemisah antar-kolom.
  final double dividerHeight;
}

class StatsRow extends StatelessWidget {
  const StatsRow({
    super.key,
    required this.items,
    this.layout = StatLayout.stacked,
  });

  final List<StatItemData> items;
  final StatLayout layout;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            Container(
              width: 1,
              height: layout.dividerHeight,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: cs.outlineVariant,
            ),
          Expanded(child: _StatItem(data: items[i], layout: layout)),
        ],
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.data, required this.layout});

  final StatItemData data;
  final StatLayout layout;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final icon = Icon(data.icon, color: cs.primary, size: 22);

    return switch (layout) {
      StatLayout.stacked => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: 6),
            Text(
              data.label,
              style: tt.labelMedium!.copyWith(
                fontSize: 11,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              data.value,
              style: context.wsMono.stat.copyWith(
                fontSize: 20,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      StatLayout.inline => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(width: 8),
                Text(
                  data.value,
                  style: context.wsMono.stat.copyWith(
                    fontSize: 24,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              data.label,
              style: tt.labelMedium!.copyWith(
                fontSize: 11,
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
    };
  }
}
