import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/app_theme.dart';

// ---- Data tiruan -------------------------------------------------------

const _mapImage =
    'https://images.unsplash.com/photo-1448375240586-882707db888b?w=900&q=80';

const _discoveries = [
  _Discovery('Monarch',
      'https://images.unsplash.com/photo-1568526381923-caf3fd520382?w=300&q=80'),
  _Discovery('Red Cap',
      'https://images.unsplash.com/photo-1504545102780-26774c1bb073?w=300&q=80'),
  _Discovery('Blue Jay',
      'https://images.unsplash.com/photo-1444464666168-49d633b86797?w=300&q=80'),
];

const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _biodiversity = [65.0, 62.0, 68.0, 72.0, 70.0, 75.0, 78.0];
const _disturbance = [12.0, 16.0, 9.0, 6.0, 11.0, 7.0, 5.0];

class _Discovery {
  const _Discovery(this.name, this.imageUrl);
  final String name;
  final String imageUrl;
}

// ---- Screen --------------------------------------------------------------
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const double _minExtent = 0.40;
  static const double _initialExtent = 0.58;

  /// Batas atas bila konten lebih tinggi dari layar (layar kecil): di kasus
  /// ini saja sheet boleh di-scroll.
  static const double _hardMaxExtent = 0.95;

  final ValueNotifier<double> _extent = ValueNotifier(_initialExtent);

  /// Tinggi konten sheet (px), diukur setelah layout. Sheet hanya bisa ditarik
  /// sampai seluruh konten terlihat — tidak ada ruang kosong di bawahnya.
  double? _contentHeight;

  void _onContentHeight(double height) {
    if (_contentHeight != null && (_contentHeight! - height).abs() < 0.5) {
      return;
    }
    setState(() => _contentHeight = height);
  }

  @override
  void dispose() {
    _extent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LayoutBuilder(builder: (context, c) {
      final h = c.maxHeight;
      final maxExtent = _contentHeight == null
          ? _hardMaxExtent
          : (_contentHeight! / h).clamp(0.0, _hardMaxExtent);
      final minExtent = math.min(_minExtent, maxExtent);
      final initialExtent = math.min(_initialExtent, maxExtent);
      return Stack(
        children: [
          // Latar belakang peta/gambar
          Positioned.fill(
            child: Image.network(
              _mapImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) =>
                  ColoredBox(color: cs.inverseSurface),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    cs.shadow.withAlpha(90),
                    cs.shadow.withAlpha(30),
                    cs.surface.withAlpha(200),
                  ],
                ),
              ),
            ),
          ),

          // Search bar
          const Positioned(top: 16, left: 16, right: 16, child: _SearchBar()),

          // Kontrol peta (mengikuti tinggi sheet)
          ValueListenableBuilder<double>(
            valueListenable: _extent,
            builder: (_, e, child) => Positioned(
              right: 16,
              bottom: (h * e + 12).clamp(0.0, h - 200),
              child: child!,
            ),
            child: const _MapActions(),
          ),

          // Bottom sheet yang bisa di-drag dan di-scroll
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (n) {
              _extent.value = n.extent;
              return false;
            },
            child: DraggableScrollableSheet(
              initialChildSize: initialExtent,
              minChildSize: minExtent,
              maxChildSize: maxExtent,
              builder: (context, scrollController) => _DetailSheet(
                controller: scrollController,
                onContentHeight: _onContentHeight,
              ),
            ),
          ),
        ],
      );
    });
  }
}

// ---- Bagian atas -----------------------------------------------------------

/// Search bar M3. Warna solid (surfaceContainerLowest, opacity 100%) dan
/// elevasi diatur di `searchBarTheme` (core/app_theme.dart).
class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return const SearchBar(
      hintText: 'Search species or region...',
      leading: Icon(Icons.search),
    );
  }
}

/// Kontrol utilitas peta ("Lokasi saya" dan "Layers"), memakai tonal icon
/// button M3. Halaman ini tidak memiliki FAB.
class _MapActions extends StatelessWidget {
  const _MapActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          onPressed: () {},
          tooltip: 'Lokasi saya',
          icon: const Icon(Icons.my_location),
        ),
        const SizedBox(height: 12),
        IconButton.filledTonal(
          onPressed: () {},
          tooltip: 'Layers',
          icon: const Icon(Icons.layers_outlined),
        ),
      ],
    );
  }
}

// ---- Sheet ---------------------------------------------------------------

/// Sheet utama: latar `surface` (sama dengan latar halaman Home), kartu di
/// dalamnya putih (surfaceContainerLowest) seperti kartu di Home, sehingga
/// kartu terpisah jelas dari latar sheet. Pemisah dari peta memakai bayangan
/// lembut di tepi atas.
///
/// Tinggi konten diukur dan dilaporkan lewat [onContentHeight] agar sheet
/// berhenti tepat saat seluruh konten sudah terlihat.
class _DetailSheet extends StatefulWidget {
  const _DetailSheet({required this.controller, required this.onContentHeight});
  final ScrollController controller;
  final ValueChanged<double> onContentHeight;

  @override
  State<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<_DetailSheet> {
  final GlobalKey _contentKey = GlobalKey();

  void _measure() {
    final box = _contentKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) widget.onContentHeight(box.size.height);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _measure();
    });
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: WsRadius.xl),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withAlpha(50),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ListView(
        controller: widget.controller,
        padding: EdgeInsets.zero,
        children: [
          Padding(
            key: _contentKey,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _GrabHandle(),
                const SizedBox(height: 12),
                const _SheetHeader(),
                const SizedBox(height: 16),
                const _StatsRow(),
                const SizedBox(height: 16),
                const _TrendCard(),
                const SizedBox(height: 20),
                Text('Nearby Discoveries',
                    style: tt.titleLarge!
                        .copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                const _DiscoveryList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GrabHandle extends StatelessWidget {
  const _GrabHandle();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        width: 32,
        height: 4,
        decoration: BoxDecoration(
          color: cs.outlineVariant,
          borderRadius: const BorderRadius.all(WsRadius.pill),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Blackwood Forest',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleLarge!
                      .copyWith(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.verified_user_outlined,
                      size: 16, color: cs.primary),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text('Protected Area • Active Monitoring',
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodySmall!.copyWith(fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: const BorderRadius.all(WsRadius.pill),
          ),
          child: Text('Healthy',
              style: tt.labelLarge!.copyWith(color: cs.onPrimary)),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
            child: _StatCard(
                icon: Icons.monitor_heart_outlined,
                label: 'Ecosystem Health',
                value: '84%')),
        SizedBox(width: 12),
        Expanded(
            child: _StatCard(
                icon: Icons.trending_up,
                label: 'Species Activity',
                value: '+12%')),
      ],
    );
  }
}

/// Dekorasi kartu yang sama dengan kartu di Home
/// (surfaceContainerLowest + outlineVariant + WsShadow.card).
BoxDecoration _cardDecoration(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  return BoxDecoration(
    color: cs.surfaceContainerLowest,
    borderRadius: const BorderRadius.all(WsRadius.lg),
    border: Border.all(color: cs.outlineVariant),
    boxShadow: WsShadow.card(context),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(context),
      child: Row(
        children: [
          Icon(icon, color: cs.primary, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.labelMedium),
                const SizedBox(height: 2),
                Text(value, style: context.wsMono.stat.copyWith(fontSize: 20)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Chart ---------------------------------------------------------------
class _TrendCard extends StatelessWidget {
  const _TrendCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 16, 12),
      decoration: _cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              children: [
                Icon(Icons.show_chart, color: cs.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Weekly Biodiversity Trend',
                      style: tt.titleLarge!.copyWith(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 170, child: LineChart(_chartData(context))),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: cs.primary, label: 'Biodiversity Index'),
              const SizedBox(width: 16),
              _LegendDot(
                  color: context.wsBrand.amber, label: 'Disturbance Level'),
            ],
          ),
        ],
      ),
    );
  }

  LineChartData _chartData(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelSmall;
    return LineChartData(
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: 80,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 20,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: cs.outlineVariant, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 20,
            reservedSize: 28,
            getTitlesWidget: (v, meta) => SideTitleWidget(
              meta: meta,
              child: Text(v.toInt().toString(), style: labelStyle),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 26,
            getTitlesWidget: (v, meta) {
              final i = v.toInt();
              if (i < 0 || i >= _days.length) return const SizedBox.shrink();
              return SideTitleWidget(
                meta: meta,
                child: Text(_days[i], style: labelStyle),
              );
            },
          ),
        ),
      ),
      lineBarsData: [
        _line(_biodiversity, cs.primary, 90),
        _line(_disturbance, context.wsBrand.amber, 70),
      ],
    );
  }

  LineChartBarData _line(List<double> values, Color color, int topAlpha) {
    return LineChartBarData(
      spots: [
        for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i])
      ],
      isCurved: true,
      color: color,
      barWidth: 2,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withAlpha(topAlpha), color.withAlpha(5)],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}

// ---- Nearby discoveries -------------------------------------------------------
class _DiscoveryItem extends StatelessWidget {
  const _DiscoveryItem({required this.discovery});

  final _Discovery discovery;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return SizedBox(
      width: 96,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(WsRadius.md),
            child: Image.network(
              discovery.imageUrl,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 96,
                height: 96,
                color: cs.surfaceContainerHigh,
                child: Icon(Icons.image_not_supported_outlined,
                    color: cs.onSurfaceVariant),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(discovery.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.labelMedium!.copyWith(color: cs.onSurface)),
        ],
      ),
    );
  }
}

class _DiscoveryList extends StatelessWidget {
  const _DiscoveryList();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 124,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _discoveries.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _DiscoveryItem(discovery: _discoveries[i]),
      ),
    );
  }
}
