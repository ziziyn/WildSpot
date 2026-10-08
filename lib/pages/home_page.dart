
import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../layouts/main_layout.dart';
import 'explore_page.dart';

// ═══════════════════════════════════════════════════════════════════
//  MOCK DATA
// ═══════════════════════════════════════════════════════════════════

class _DiscoveryData {
  const _DiscoveryData({
    required this.category,
    required this.imageUrl,
    required this.distance,
    required this.name,
    required this.avatarUrl,
    required this.author,
    required this.timeAgo,
  });
  final String category;
  final String imageUrl;
  final String distance;
  final String name;
  final String avatarUrl;
  final String author;
  final String timeAgo;
}

const _kNearbyDiscoveries = [
  _DiscoveryData(
    category: 'Fauna',
    imageUrl:
        'https://images.unsplash.com/photo-1568526381923-caf3fd520382?w=600&q=80',
    distance: '0.8 km away',
    name: 'MONARCH',
    avatarUrl:
        'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=100&q=80',
    author: 'Elena Woods',
    timeAgo: '12m ago',
  ),
  _DiscoveryData(
    category: 'Fungi',
    imageUrl:
        'https://images.unsplash.com/photo-1504545102780-26774c1bb073?w=600&q=80',
    distance: '1.2 km away',
    name: 'RED-CAPPED',
    avatarUrl:
        'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=100&q=80',
    author: 'Marcus Moss',
    timeAgo: '45m ago',
  ),
  _DiscoveryData(
    category: 'Fauna',
    imageUrl:
        'https://images.unsplash.com/photo-1444464666168-49d633b86797?w=600&q=80',
    distance: '2.5 km away',
    name: 'BLUE JAY',
    avatarUrl:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&q=80',
    author: 'Sarah Leaf',
    timeAgo: '2h ago',
  ),
];

// ═══════════════════════════════════════════════════════════════════
//  HOME PAGE
// ═══════════════════════════════════════════════════════════════════

/// Halaman beranda WildSpot — dibungkus [MainLayout] sehingga
/// CustomAppBar dan BottomNav sudah tersedia secara otomatis.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── top padding (app bar sudah ada di MainLayout)
          const SliverToBoxAdapter(child: SizedBox(height: 4)),

          // ── ① Greeting
          const SliverToBoxAdapter(child: _GreetingSection()),

          // ── ② Your Discoveries stats
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: _DiscoveriesCard(),
            ),
          ),

          // ── ③ Active Mission
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _ActiveMissionCard(),
            ),
          ),

          // ── ④ Nearby Discoveries header
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: _NearbyHeader(),
            ),
          ),

          // ── ④ Nearby Discoveries grid
          _NearbyDiscoveriesGrid(items: _kNearbyDiscoveries),

          // ── Load more + bottom breathing room
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: _LoadMoreButton(),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ① GREETING SECTION
// ═══════════════════════════════════════════════════════════════════

class _GreetingSection extends StatelessWidget {
  const _GreetingSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Hello, Ranger 👋"
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Hello, Ranger ',
                  style: WsText.display(size: 30, weight: FontWeight.w700),
                ),
                const TextSpan(
                  text: '👋',
                  style: TextStyle(fontSize: 28),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'The forest is waiting for your observations today.',
            style: WsText.body(
              size: 14,
              color: WsColors.textMuted,
              weight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ② YOUR DISCOVERIES CARD
// ═══════════════════════════════════════════════════════════════════

class _DiscoveriesCard extends StatelessWidget {
  const _DiscoveriesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: WsColors.bgCard,
        borderRadius: const BorderRadius.all(WsRadius.lg),
        border: Border.all(color: WsColors.divider),
        boxShadow: WsShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your Discoveries',
                  style: WsText.heading(size: 16, weight: FontWeight.w700)),
              GestureDetector(
                onTap: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('VIEW ALL',
                        style: WsText.label(
                            size: 12,
                            color: WsColors.green,
                            weight: FontWeight.w700)),
                    const SizedBox(width: 2),
                    const Icon(Icons.chevron_right,
                        color: WsColors.green, size: 18),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 3 stat columns
          const Row(
            children: [
              Expanded(
                child: _StatColumn(
                  icon: Icons.eco_outlined,
                  iconColor: WsColors.green,
                  label: 'Total',
                  value: '128',
                ),
              ),
              _VerticalDivider(),
              Expanded(
                child: _StatColumn(
                  icon: Icons.location_on_outlined,
                  iconColor: WsColors.green,
                  label: 'Spots',
                  value: '42',
                ),
              ),
              _VerticalDivider(),
              Expanded(
                child: _StatColumn(
                  icon: Icons.trending_up_rounded,
                  iconColor: WsColors.green,
                  label: 'Rank',
                  value: '#12',
                  valueMono: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: WsColors.divider, height: 1),
          const SizedBox(height: 12),

          // Community Impact row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: WsColors.amberFaint,
                  borderRadius: const BorderRadius.all(WsRadius.sm),
                  border: Border.all(color: WsColors.amber.withAlpha(60)),
                ),
                child: const Icon(Icons.people_alt_outlined,
                    color: WsColors.amber, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('COMMUNITY IMPACT',
                      style: WsText.label(
                          size: 10,
                          color: WsColors.textDim,
                          weight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('CONSERVATION HERO',
                      style: WsText.heading(
                          size: 13,
                          color: WsColors.textPrimary,
                          weight: FontWeight.w800)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('CONTRIBUTIONS',
                      style: WsText.label(
                          size: 10,
                          color: WsColors.textDim,
                          weight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('+4 THIS WEEK',
                      style: WsText.mono(
                        size: 13,
                        color: WsColors.green,
                        weight: FontWeight.w700,
                      )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueMono = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool valueMono;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 6),
        Text(label, style: WsText.label(size: 11, color: WsColors.textMuted)),
        const SizedBox(height: 3),
        valueMono
            ? Text(value,
                style: WsText.mono(
                  size: 20,
                  color: WsColors.textPrimary,
                  weight: FontWeight.w700,
                ))
            : Text(value,
                style: WsText.mono(size: 20, color: WsColors.textPrimary)),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 52,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: WsColors.divider,
      );
}

// ═══════════════════════════════════════════════════════════════════
//  ③ ACTIVE MISSION CARD
// ═══════════════════════════════════════════════════════════════════

class _ActiveMissionCard extends StatelessWidget {
  const _ActiveMissionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: WsColors.bgCardAlt,
        borderRadius: const BorderRadius.all(WsRadius.lg),
        border: Border.all(color: WsColors.greenDim.withAlpha(100)),
        boxShadow: WsShadow.greenGlow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── header row
          Row(
            children: [
              const Icon(Icons.military_tech_outlined,
                  color: WsColors.amber, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Active Mission',
                  style: WsText.heading(
                      size: 15,
                      color: WsColors.textPrimary,
                      weight: FontWeight.w800),
                ),
              ),
              // STREAKING badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: WsColors.amberFaint,
                  borderRadius: const BorderRadius.all(WsRadius.pill),
                  border: Border.all(color: WsColors.amber.withAlpha(80)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department_rounded,
                        color: WsColors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text('STREAKING',
                        style: WsText.label(
                            size: 10,
                            color: WsColors.amber,
                            weight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── mission name
          Text(
            'Native Pollinator Census',
            style: WsText.heading(
                size: 18,
                color: WsColors.textPrimary,
                weight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Identify 5 different pollinator species in your local area.',
            style: WsText.body(size: 13, color: WsColors.textMuted),
          ),

          const SizedBox(height: 16),

          // ── progress row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress',
                  style: WsText.label(
                      size: 12,
                      color: WsColors.textMuted,
                      weight: FontWeight.w500)),
              Text('3/5 (60%)',
                  style: WsText.mono(
                    size: 12,
                    color: WsColors.green,
                    weight: FontWeight.w600,
                  )),
            ],
          ),
          const SizedBox(height: 8),

          // ── progress bar
          _ProgressBar(progress: 0.60),

          const SizedBox(height: 16),

          // ── CTA button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: WsColors.textPrimary,
                side: const BorderSide(color: WsColors.divider, width: 1.5),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(WsRadius.md)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text('View Mission Details',
                  style: WsText.body(
                      size: 14,
                      color: WsColors.textPrimary,
                      weight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final total = constraints.maxWidth;
        return Container(
          height: 8,
          width: total,
          decoration: BoxDecoration(
            color: WsColors.bgBase,
            borderRadius: const BorderRadius.all(WsRadius.pill),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              width: total * progress.clamp(0.0, 1.0),
              height: 8,
              decoration: BoxDecoration(
                color: WsColors.green,
                borderRadius: const BorderRadius.all(WsRadius.pill),
                boxShadow: [
                  BoxShadow(
                    color: WsColors.green.withAlpha(80),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ④ NEARBY DISCOVERIES
// ═══════════════════════════════════════════════════════════════════

class _NearbyHeader extends StatelessWidget {
  const _NearbyHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: WsColors.greenFaint,
            shape: BoxShape.circle,
            border: Border.all(color: WsColors.green.withAlpha(120), width: 1.5),
          ),
          child: const Icon(Icons.radar, color: WsColors.green, size: 13),
        ),
        const SizedBox(width: 8),
        Text('Nearby Discoveries',
            style: WsText.heading(size: 17, weight: FontWeight.w700)),
        const Spacer(),
        Text('Within 5km',
            style: WsText.label(
                size: 12, color: WsColors.textMuted, weight: FontWeight.w500)),
      ],
    );
  }
}

/// SliverGrid 2-kolom untuk Nearby Discoveries.
class _NearbyDiscoveriesGrid extends StatelessWidget {
  const _NearbyDiscoveriesGrid({required this.items});
  final List<_DiscoveryData> items;

  @override
  Widget build(BuildContext context) {
    // Jika jumlah ganjil, item terakhir full-width
    final pairs = (items.length / 2).ceil();
    final widgets = <Widget>[];

    for (int row = 0; row < pairs; row++) {
      final left = row * 2;
      final right = left + 1;
      final hasRight = right < items.length;

      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _DiscoveryTile(data: items[left])),
              if (hasRight) ...[
                const SizedBox(width: 12),
                Expanded(child: _DiscoveryTile(data: items[right])),
              ] else
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate(widgets),
    );
  }
}

class _DiscoveryTile extends StatelessWidget {
  const _DiscoveryTile({required this.data});
  final _DiscoveryData data;

  /// Warna chip sesuai kategori.
  static Color _chipColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'fungi':
        return const Color(0xFFE07B12);
      case 'flora':
        return const Color(0xFF2CB67D);
      default:
        return WsColors.green; // fauna
    }
  }

  @override
  Widget build(BuildContext context) {
    final chip = _chipColor(data.category);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── foto dengan overlay
        ClipRRect(
          borderRadius: const BorderRadius.all(WsRadius.lg),
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // gambar
                Image.network(
                  data.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    color: WsColors.bgCard,
                    child: const Icon(Icons.image_not_supported_outlined,
                        color: WsColors.textDim),
                  ),
                ),
                // gradient overlay bawah
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.45, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha(180),
                      ],
                    ),
                  ),
                ),
                // kategori chip (atas-kiri)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: chip.withAlpha(200),
                      borderRadius: const BorderRadius.all(WsRadius.pill),
                    ),
                    child: Text(data.category,
                        style: WsText.label(
                            size: 11,
                            color: Colors.white,
                            weight: FontWeight.w700)),
                  ),
                ),
                // jarak (bawah-kiri)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on,
                          color: WsColors.green, size: 13),
                      const SizedBox(width: 3),
                      Text(data.distance,
                          style: WsText.label(
                              size: 11,
                              color: Colors.white,
                              weight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // ── nama spesies
        Text(
          data.name,
          style: WsText.heading(
              size: 14, color: WsColors.textPrimary, weight: FontWeight.w800),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 5),

        // ── avatar + author + waktu
        Row(
          children: [
            CircleAvatar(
              radius: 11,
              backgroundColor: WsColors.bgCard,
              backgroundImage: NetworkImage(data.avatarUrl),
              onBackgroundImageError: (error, stack) {},
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(data.author,
                  style: WsText.label(
                      size: 11,
                      color: WsColors.textMuted,
                      weight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.access_time_rounded,
                size: 11, color: WsColors.textDim),
            const SizedBox(width: 3),
            Text(data.timeAgo,
                style: WsText.label(
                    size: 11,
                    color: WsColors.textDim,
                    weight: FontWeight.w400)),
          ],
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  LOAD MORE BUTTON
// ═══════════════════════════════════════════════════════════════════

class _LoadMoreButton extends StatelessWidget {
  const _LoadMoreButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: WsColors.textMuted,
          side: const BorderSide(color: WsColors.divider, width: 1.2),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(WsRadius.md)),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(
          'LOAD MORE NEARBY SPOTS',
          style: WsText.label(
            size: 12,
            color: WsColors.textMuted,
            weight: FontWeight.w700,
          ).copyWith(letterSpacing: 1.2),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SHELL WRAPPER — dipakai oleh main.dart
// ═══════════════════════════════════════════════════════════════════

/// Membungkus [HomePage] di dalam [MainLayout] dengan index tab 0.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _titles = [
    'WildSpot',
    'Explore Wildlife',
    'Observation',
    'Missions',
    'Community',
  ];

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: _titles[_index],
      currentIndex: _index,
      onTabChanged: (i) => setState(() => _index = i),
      body: _index == 0
          ? const HomePage()
          : _index == 1
              ? const ExploreScreen()
              : Center(
                  child: Text(
                    '${_titles[_index]} — coming soon',
                    style: WsText.body(color: WsColors.textMuted),
                  ),
                ),
    );
  }
}
