import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../layouts/main_layout.dart';
import 'explore_page.dart';

// ═══════════════════════════════════════════════════════════════════
//  ACCENT KHUSUS HALAMAN INI
//  Warna aksen yang tidak punya padanan di ColorScheme; nilainya sama
//  persis dengan desain awal (screenshot) agar tampilan tidak berubah.
// ═══════════════════════════════════════════════════════════════════

const _kMedalRibbon = Color(0xFFD32F2F); // pita merah medali
const _kMedalStar = Color(0xFFFFB300); // bintang kuning medali
const _kFlame = Color(0xFFFF6D00); // api oranye badge STREAKING
const _kChipFungi = Color(0xFFE07B12); // chip kategori Fungi
const _kChipFlora = Color(0xFF2CB67D); // chip kategori Flora

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

          // ── ① Greeting + cuaca lokal
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

          // ── ④ Nearby Discoveries carousel (horizontal)
          const SliverToBoxAdapter(
            child: _NearbyDiscoveriesCarousel(items: _kNearbyDiscoveries),
          ),

          // ── Load more + bottom breathing room
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 32),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Hello," — label kecil di atas
                Text(
                  'Hello,',
                  style: tt.bodyMedium!.copyWith(
                    fontSize: 15,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                // "Ranger 👋" — display besar di bawah
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Ranger ',
                        style: tt.displayMedium!.copyWith(fontSize: 32, fontWeight: FontWeight.w800),
                      ),
                      const TextSpan(
                        text: '👋',
                        style: TextStyle(fontSize: 30),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'The forest is waiting for your observations today.',
                  style: tt.bodyMedium!.copyWith(
                    fontSize: 14,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const LocalWeatherWidget(),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  LOCAL WEATHER WIDGET
// ═══════════════════════════════════════════════════════════════════

/// Ringkasan cuaca lokal. Saat ini memakai data statis; nilai default
/// bisa diganti lewat constructor ketika sumber data cuaca sudah ada.
class LocalWeatherWidget extends StatelessWidget {
  const LocalWeatherWidget({
    super.key,
    this.temperature = '28°C',
    this.condition = 'Sunny',
    this.icon = Icons.wb_sunny_rounded,
  });

  final String temperature;
  final String condition;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: const BorderRadius.all(WsRadius.xl),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: cs.onSurface, size: 30),
          const SizedBox(height: 6),
          Text(
            temperature,
            style: tt.titleLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            condition,
            style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest, // surface putih bersih
        borderRadius: const BorderRadius.all(WsRadius.lg),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: WsShadow.card(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your Discoveries',
                  style: tt.titleLarge!.copyWith(fontSize: 16, fontWeight: FontWeight.w700)),
              GestureDetector(
                onTap: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('VIEW ALL',
                        style: tt.labelMedium!.copyWith(
                            fontSize: 12,
                            color: cs.primary,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(width: 2),
                    Icon(Icons.chevron_right,
                        color: cs.primary, size: 18),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 3 stat columns
          Row(
            children: [
              Expanded(
                child: _StatColumn(
                  icon: Icons.eco_outlined,
                  iconColor: cs.primary,
                  label: 'Total',
                  value: '128',
                ),
              ),
              const _VerticalDivider(),
              Expanded(
                child: _StatColumn(
                  icon: Icons.location_on_outlined,
                  iconColor: cs.primary,
                  label: 'Spots',
                  value: '42',
                ),
              ),
              const _VerticalDivider(),
              Expanded(
                child: _StatColumn(
                  icon: Icons.trending_up_rounded,
                  iconColor: cs.primary,
                  label: 'Rank',
                  value: '#12',
                  valueMono: true,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(color: cs.outlineVariant, height: 1),
          const SizedBox(height: 12),

          // Community Impact row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.wsBrand.amberFaint,
                  borderRadius: const BorderRadius.all(WsRadius.sm),
                  border: Border.all(color: context.wsBrand.amber.withAlpha(60)),
                ),
                child: Icon(Icons.people_alt_outlined,
                    color: context.wsBrand.amber, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('COMMUNITY IMPACT',
                      style: tt.labelMedium!.copyWith(
                          fontSize: 10,
                          color: cs.outline,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('CONSERVATION HERO',
                      style: tt.titleLarge!.copyWith(
                          fontSize: 13,
                          color: cs.onSurface,
                          fontWeight: FontWeight.w800)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('CONTRIBUTIONS',
                      style: tt.labelMedium!.copyWith(
                          fontSize: 10,
                          color: cs.outline,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('+4 THIS WEEK',
                      style: context.wsMono.stat.copyWith(
                        fontSize: 13,
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 6),
        Text(label, style: tt.labelMedium!.copyWith(fontSize: 11, color: cs.onSurfaceVariant)),
        const SizedBox(height: 3),
        valueMono
            ? Text(value,
                style: context.wsMono.stat.copyWith(
                  fontSize: 20,
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                ))
            : Text(value,
                style: context.wsMono.stat.copyWith(fontSize: 20, color: cs.onSurface)),
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
        color: Theme.of(context).colorScheme.outlineVariant,
      );
}

// ═══════════════════════════════════════════════════════════════════
//  ③ ACTIVE MISSION CARD
// ═══════════════════════════════════════════════════════════════════

class _ActiveMissionCard extends StatelessWidget {
  const _ActiveMissionCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.primary, // hijau hutan solid
        borderRadius: const BorderRadius.all(WsRadius.lg),
        boxShadow: WsShadow.greenGlow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── header row
          Row(
            children: [
              // Medali 2 warna: ribbon merah (atas) + bintang kuning (bawah)
              SizedBox(
                width: 22,
                height: 22,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // ribbon merah — clip bagian atas 38%
                    ClipRect(
                      child: Align(
                        alignment: Alignment.topCenter,
                        heightFactor: 0.38,
                        child: const Icon(Icons.military_tech,
                            color: _kMedalRibbon, size: 22),
                      ),
                    ),
                    // bintang kuning — clip bagian bawah 62%
                    ClipRect(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        heightFactor: 0.62,
                        child: const Icon(Icons.military_tech,
                            color: _kMedalStar, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Active Mission',
                  style: tt.titleLarge!.copyWith(
                      fontSize: 15, color: cs.onPrimary, fontWeight: FontWeight.w800),
                ),
              ),
              // STREAKING badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.onPrimary.withAlpha(30),
                  borderRadius: const BorderRadius.all(WsRadius.pill),
                  border: Border.all(color: cs.onPrimary.withAlpha(60)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department_rounded,
                        color: _kFlame, size: 14),
                    const SizedBox(width: 4),
                    Text('STREAKING',
                        style: tt.labelMedium!.copyWith(
                            fontSize: 10,
                            color: cs.onPrimary,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── mission name
          Text(
            'Native Pollinator Census',
            style: tt.titleLarge!.copyWith(
                fontSize: 18, color: cs.onPrimary, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Identify 5 different pollinator species in your local area.',
            style: tt.bodyMedium!.copyWith(fontSize: 13, color: cs.onPrimary.withAlpha(200)),
          ),

          const SizedBox(height: 16),

          // ── progress row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress',
                  style: tt.labelMedium!.copyWith(
                      fontSize: 12,
                      color: cs.onPrimary.withAlpha(180),
                      fontWeight: FontWeight.w500)),
              Text('3/5 (60%)',
                  style: context.wsMono.stat.copyWith(
                    fontSize: 12,
                    color: cs.onPrimary,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
          const SizedBox(height: 8),

          // ── progress bar (fill putih kontras di atas primary gelap)
          _ProgressBar(
            progress: 0.60,
            trackColor: cs.onPrimary.withAlpha(40),
            fillColor: cs.onPrimary.withAlpha(230),
          ),

          const SizedBox(height: 16),

          // ── CTA button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: cs.primaryContainer,
                foregroundColor: cs.onPrimaryContainer,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(WsRadius.md)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text('View Mission Details',
                  style: tt.bodyMedium!.copyWith(
                      fontSize: 14,
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.progress,
    this.trackColor,
    this.fillColor,
  });
  final double progress;
  final Color? trackColor;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fill = fillColor ?? cs.primary;
    return LayoutBuilder(
      builder: (context, constraints) {
        final total = constraints.maxWidth;
        return Container(
          height: 8,
          width: total,
          decoration: BoxDecoration(
            color: trackColor ?? cs.surface,
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
                color: fill,
                borderRadius: const BorderRadius.all(WsRadius.pill),
                boxShadow: [
                  BoxShadow(
                    color: fill.withAlpha(100),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            shape: BoxShape.circle,
            border: Border.all(color: cs.primary.withAlpha(120), width: 1.5),
          ),
          child: Icon(Icons.radar, color: cs.primary, size: 13),
        ),
        const SizedBox(width: 8),
        Text('Nearby Discoveries',
            style: tt.titleLarge!.copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
        const Spacer(),
        Text('Within 5km',
            style: tt.labelMedium!.copyWith(
                fontSize: 12, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

/// Carousel horizontal untuk Nearby Discoveries.
/// Lebar tiap kartu 75% lebar layar agar kartu berikutnya selalu
/// mengintip dan menjadi petunjuk bahwa daftar bisa digeser.
class _NearbyDiscoveriesCarousel extends StatelessWidget {
  const _NearbyDiscoveriesCarousel({required this.items});

  final List<_DiscoveryData> items;

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.sizeOf(context).width * 0.75;

    return SizedBox(
      height: cardWidth * 1.05,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        // Clip.none agar shadow kartu tidak terpotong batas tinggi list.
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) => SizedBox(
          width: cardWidth,
          child: _DiscoveryTile(data: items[index]),
        ),
      ),
    );
  }
}

class _DiscoveryTile extends StatelessWidget {
  const _DiscoveryTile({required this.data});

  final _DiscoveryData data;

  /// Warna chip sesuai kategori.
  static Color _chipColor(String cat, ColorScheme cs) {
    switch (cat.toLowerCase()) {
      case 'fungi':
        return _kChipFungi;
      case 'flora':
        return _kChipFlora;
      default:
        return cs.primary; // fauna
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final chip = _chipColor(data.category, cs);
    final onImage = cs.surfaceContainerLowest; // putih, teks di atas foto

    return Container(
      // kartu putih rounded dengan shadow — memisah dari scaffold pastel
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: const BorderRadius.all(WsRadius.xl),
        boxShadow: WsShadow.card(context),
      ),
      clipBehavior: Clip.antiAlias, // gambar otomatis clip ke sudut kartu
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── foto dengan overlay; mengisi sisa tinggi kartu
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // gambar
                Image.network(
                  data.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    color: cs.surfaceContainer,
                    child: Icon(Icons.image_not_supported_outlined,
                        color: cs.outline),
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
                        cs.shadow.withAlpha(180),
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
                        style: tt.labelMedium!.copyWith(
                            fontSize: 11,
                            color: onImage,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                // jarak (bawah-kiri)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, color: onImage, size: 13),
                      const SizedBox(width: 3),
                      Text(data.distance,
                          style: tt.labelMedium!.copyWith(
                              fontSize: 11,
                              color: onImage,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── teks section di dalam kartu, dengan padding internal
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // nama spesies
                Text(
                  data.name,
                  style: tt.titleLarge!.copyWith(
                      fontSize: 14,
                      color: cs.onSurface,
                      fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // avatar + author + waktu
                Row(
                  children: [
                    CircleAvatar(
                      radius: 11,
                      backgroundColor: cs.surfaceContainer,
                      backgroundImage: NetworkImage(data.avatarUrl),
                      onBackgroundImageError: (error, stack) {},
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(data.author,
                          style: tt.labelMedium!.copyWith(
                              fontSize: 11,
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.access_time_rounded,
                        size: 11, color: cs.outline),
                    const SizedBox(width: 3),
                    Text(data.timeAgo,
                        style: tt.labelMedium!.copyWith(
                            fontSize: 11,
                            color: cs.outline,
                            fontWeight: FontWeight.w400)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () {},
        style: FilledButton.styleFrom(
          backgroundColor: cs.primary, // hijau pekat
          foregroundColor: cs.surfaceContainerLowest,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(WsRadius.md)),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(
          'LOAD MORE NEARBY SPOTS',
          style: tt.labelMedium!.copyWith(
            fontSize: 12,
            color: cs.surfaceContainerLowest,
            fontWeight: FontWeight.w700,
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
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
                    style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
    );
  }
}
