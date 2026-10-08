import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// ---- Warna & data tiruan ----------------------------------------------
const _bg = Color(0xFF1A211E);
const _card = Color(0xFF212A26);
const _green = Color(0xFF4CD964);
const _orange = Color(0xFFE07B12);
const _muted = Color(0xFFA9B3AE);

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
  static const double _maxExtent = 0.95;

  final ValueNotifier<double> _extent = ValueNotifier(_initialExtent);

  @override
  void dispose() {
    _extent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final h = c.maxHeight;
      return Stack(
        children: [
          // Latar belakang peta/gambar
          Positioned.fill(
            child: Image.network(
              _mapImage,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF2A332F)),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(90),
                    Colors.black.withAlpha(30),
                    _bg.withAlpha(200),
                  ],
                ),
              ),
            ),
          ),

          // Marker "Waste Dump"
          Positioned(top: h * 0.22, right: 70, child: const _WasteMarker()),

          // Search bar
          const Positioned(top: 16, left: 16, right: 16, child: _SearchBar()),

          // Tombol aksi mengambang (mengikuti tinggi sheet)
          ValueListenableBuilder<double>(
            valueListenable: _extent,
            builder: (_, e, child) => Positioned(
              right: 16,
              bottom: (h * e + 12).clamp(0.0, h - 220),
              child: child!,
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MapFab(icon: Icons.my_location, tooltip: 'Lokasi saya'),
                SizedBox(height: 12),
                _MapFab(icon: Icons.layers_outlined, tooltip: 'Layers'),
                SizedBox(height: 12),
                _MapFab(
                  icon: Icons.warning_amber_rounded,
                  tooltip: 'Alert',
                  color: _orange,
                ),
              ],
            ),
          ),

          // Bottom sheet yang bisa di-drag dan di-scroll
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (n) {
              _extent.value = n.extent;
              return false;
            },
            child: DraggableScrollableSheet(
              initialChildSize: _initialExtent,
              minChildSize: _minExtent,
              maxChildSize: _maxExtent,
              builder: (context, scrollController) =>
                  _DetailSheet(controller: scrollController),
            ),
          ),
        ],
      );
    });
  }
}

// ---- Bagian atas -----------------------------------------------------------
class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2A332F).withAlpha(235),
      borderRadius: BorderRadius.circular(28),
      child: const TextField(
        style: TextStyle(color: Colors.white),
        cursorColor: _green,
        decoration: InputDecoration(
          hintText: 'Search species or region...',
          hintStyle: TextStyle(color: _muted),
          prefixIcon: Icon(Icons.search, color: _muted),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _MapFab extends StatelessWidget {
  const _MapFab({required this.icon, required this.tooltip, this.color});

  final IconData icon;
  final String tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: FloatingActionButton(
        heroTag: tooltip,
        tooltip: tooltip,
        elevation: 2,
        shape: const CircleBorder(),
        backgroundColor: color ?? const Color(0xFF1F2824),
        foregroundColor: Colors.white,
        onPressed: () {},
        child: Icon(icon, size: 24),
      ),
    );
  }
}

class _WasteMarker extends StatelessWidget {
  const _WasteMarker();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _orange.withAlpha(60),
            border: Border.all(color: _orange, width: 2),
          ),
          child: const Icon(Icons.warning_amber_rounded, color: _orange),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(180),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text('Waste Dump',
              style: TextStyle(color: Colors.white, fontSize: 10)),
        ),
      ],
    );
  }
}

// ---- Sheet ---------------------------------------------------------------------
class _DetailSheet extends StatelessWidget {
  const _DetailSheet({required this.controller});
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: const [
          _GrabHandle(),
          SizedBox(height: 12),
          _SheetHeader(),
          SizedBox(height: 16),
          _StatsRow(),
          SizedBox(height: 16),
          _TrendCard(),
          SizedBox(height: 20),
          Text('NEARBY DISCOVERIES',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14)),
          SizedBox(height: 12),
          _DiscoveryList(),
        ],
      ),
    );
  }
}

class _GrabHandle extends StatelessWidget {
  const _GrabHandle();
  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Blackwood Forest',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800)),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.verified_user_outlined, size: 16, color: _green),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text('Protected Area • Active Monitoring',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: _muted, fontSize: 13)),
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
            color: _green.withAlpha(40),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _green.withAlpha(120)),
          ),
          child: const Text('Healthy',
              style: TextStyle(
                  color: _green, fontWeight: FontWeight.w700, fontSize: 13)),
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

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _muted, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Chart ---------------------------------------------------------------------
class _TrendCard extends StatelessWidget {
  const _TrendCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 16, 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Row(
              children: [
                Icon(Icons.show_chart, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text('WEEKLY BIODIVERSITY TREND',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14)),
                ),
                Icon(Icons.info_outline, color: _muted, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 170, child: LineChart(_chartData())),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: _green, label: 'Biodiversity Index'),
              SizedBox(width: 16),
              _LegendDot(color: _orange, label: 'Disturbance Level'),
            ],
          ),
        ],
      ),
    );
  }

  LineChartData _chartData() {
    const labelStyle = TextStyle(color: _muted, fontSize: 11);
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
            const FlLine(color: Colors.white10, strokeWidth: 1),
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
        _line(_biodiversity, _green, 90),
        _line(_disturbance, _orange, 70),
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
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}

// ---- Nearby discoveries -------------------------------------------------------
class _DiscoveryList extends StatelessWidget {
  const _DiscoveryList();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 124,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _discoveries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final d = _discoveries[i];
          return SizedBox(
            width: 96,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    d.imageUrl,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 96,
                      height: 96,
                      color: _card,
                      child: const Icon(Icons.image_not_supported_outlined,
                          color: _muted),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(d.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _muted, fontSize: 12)),
              ],
            ),
          );
        },
      ),
    );
  }
}