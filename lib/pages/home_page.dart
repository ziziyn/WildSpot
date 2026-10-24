import 'package:flutter/material.dart';

import '../components/discovery_card.dart';
import '../components/stats_row.dart';
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
enum WeatherKind {
  sunny,
  cloudy,
  rainy,
  night;

  /// Maps a free-form condition string (e.g. OpenWeatherMap's `weather[0].main`:
  /// "Clear", "Clouds", "Rain", "Drizzle", "Thunderstorm", "Snow", "Mist"...)
  /// to a [WeatherKind].
  ///
  /// [isNight] turns clear skies into [night]. Rain or clouds at night keep
  /// their own look. Unknown strings fall back to [cloudy], which is neutral.
  static WeatherKind fromCondition(String condition, {bool isNight = false}) {
    final c = condition.toLowerCase();
    if (c.contains('night')) return night;
    if (c.contains('rain') ||
        c.contains('drizzle') ||
        c.contains('thunder') ||
        c.contains('storm')) {
      return rainy;
    }
    if (c.contains('clear') || c.contains('sun')) {
      return isNight ? night : sunny;
    }
    return cloudy;
  }
}

@immutable
class _WeatherStyle {
  const _WeatherStyle({
    required this.icon,
    required this.fill,
    required this.border,
    required this.glow,
    required this.iconGradient,
    required this.onFill,
    required this.onFillVariant,
  });

  final IconData icon;
  final Color fill;
  final Color border;
  final Color glow;
  final List<Color> iconGradient; // highlight → mid → shade
  final Color onFill;
  final Color onFillVariant;
}

/// Stateless weather pill. It renders only what it is given, and it never
/// fetches data itself.
///
/// ── HOW TO HOOK UP A REAL API (e.g. OpenWeatherMap) ─────────────────────────
///
/// 1. Fetch in a repository/service layer, never in this widget:
///      GET https://api.openweathermap.org/data/2.5/weather
///          ?lat=..&lon=..&units=metric&appid=KEY
///
/// 2. Parse the JSON into a plain model in your data layer:
///      final main  = json['weather'][0]['main'] as String;   // "Clear", "Rain"
///      final icon  = json['weather'][0]['icon'] as String;   // "01d" / "01n"
///      final temp  = (json['main']['temp'] as num).round();  // °C with metric
///      → WeatherData(
///          temperature: '$temp°C',
///          condition: main,
///          isNight: icon.endsWith('n'),
///        )
///
/// 3. Expose it through your state management (Provider/Riverpod/Bloc/etc.) and
///    pass the fields in where the widget is placed, for example:
///      final w = ref.watch(weatherProvider);            // Riverpod example
///      return w.when(
///        data: (d) => LocalWeatherWidget(
///          temperature: d.temperature,
///          condition: d.condition,
///          isNight: d.isNight,
///        ),
///        loading: () => const LocalWeatherWidget(),     // or a placeholder
///        error: (_, __) => const SizedBox.shrink(),
///      );
///
/// Loading and error handling belong to the parent, so this widget stays pure.
/// Keep the API key out of source control, for example with `--dart-define`.
class LocalWeatherWidget extends StatelessWidget {
  const LocalWeatherWidget({
    super.key,
    this.temperature = '28°C',
    this.condition = 'Sunny',
    this.isNight = false,
    this.icon,
  });

  /// Preformatted temperature, e.g. '28°C'.
  final String temperature;

  /// Condition text, shown as-is and used to pick the style.
  final String condition;

  /// True after sunset. Turns clear skies into the moonlit style.
  final bool isNight;

  /// Optional icon override. When null, the icon comes from the weather style.
  final IconData? icon;

  /// Single place that decides how each [WeatherKind] looks.
  static _WeatherStyle _styleFor(
    WeatherKind kind,
    ColorScheme cs,
    WsBrandColors brand,
  ) {
    // Cool, moody variant shared by cloudy and rainy. It derives from the
    // scheme's tertiary role, a blue-teal that M3 generates from the seed.
    _WeatherStyle cool(IconData icon) => _WeatherStyle(
          icon: icon,
          fill: cs.tertiaryContainer.withAlpha(200),
          border: cs.tertiary.withAlpha(60),
          glow: cs.tertiary.withAlpha(70),
          iconGradient: [
            Color.lerp(cs.tertiary, cs.onTertiary, 0.45)!,
            cs.tertiary,
            Color.lerp(cs.tertiary, cs.onTertiaryContainer, 0.5)!,
          ],
          onFill: cs.onTertiaryContainer,
          onFillVariant: cs.onTertiaryContainer.withAlpha(200),
        );

    return switch (kind) {
      WeatherKind.sunny => _WeatherStyle(
          icon: Icons.wb_sunny_rounded,
          fill: brand.amberFaint.withAlpha(200),
          border: brand.amber.withAlpha(50),
          glow: brand.sun.withAlpha(90),
          iconGradient: [
            Color.lerp(brand.sun, cs.surfaceContainerLowest, 0.4)!,
            brand.sun,
            brand.amber,
          ],
          onFill: cs.onSurface,
          onFillVariant: cs.onSurfaceVariant,
        ),
      WeatherKind.cloudy => cool(Icons.cloud_rounded),
      WeatherKind.rainy => cool(Icons.water_drop_rounded),
      WeatherKind.night => _WeatherStyle(
          icon: Icons.nightlight_round,
          fill: cs.inverseSurface,
          border: cs.tertiary.withAlpha(90),
          glow: cs.tertiary.withAlpha(70),
          iconGradient: [
            cs.tertiaryContainer,
            Color.lerp(cs.tertiaryContainer, cs.tertiary, 0.5)!,
            cs.tertiary,
          ],
          onFill: cs.onInverseSurface,
          onFillVariant: cs.onInverseSurface.withAlpha(200),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final kind = WeatherKind.fromCondition(condition, isNight: isNight);
    final style = _styleFor(kind, cs, context.wsBrand);

    return Semantics(
      label: '$condition, $temperature',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: style.fill,
          borderRadius: const BorderRadius.all(WsRadius.pill),
          border: Border.all(color: style.border),
          boxShadow: [
            BoxShadow(color: style.glow, blurRadius: 22, spreadRadius: 1),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ShaderMask paints the gradient through the icon, so the icon
            // itself must stay opaque white.
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => RadialGradient(
                center: const Alignment(-0.3, -0.4),
                radius: 0.9,
                colors: style.iconGradient,
                stops: const [0.0, 0.65, 1.0],
              ).createShader(bounds),
              child: Icon(icon ?? style.icon, color: Colors.white, size: 36),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  temperature,
                  style: tt.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: style.onFill,
                  ),
                ),
                Text(
                  condition,
                  style: tt.labelMedium?.copyWith(
                    fontSize: 12,
                    color: style.onFillVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
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
          const StatsRow(
            items: [
              StatItemData(
                icon: Icons.eco_outlined,
                label: 'Total',
                value: '128',
              ),
              StatItemData(
                icon: Icons.location_on_outlined,
                label: 'Spots',
                value: '42',
              ),
              StatItemData(
                icon: Icons.trending_up_rounded,
                label: 'Rank',
                value: '#12',
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
        itemBuilder: (context, index) {
          final data = items[index];
          return SizedBox(
            width: cardWidth,
            child: DiscoveryCard(
              category: data.category,
              imageUrl: data.imageUrl,
              title: data.name,
              imageLabel: data.distance,
              author: DiscoveryAuthor(
                avatarUrl: data.avatarUrl,
                name: data.author,
                timeAgo: data.timeAgo,
              ),
            ),
          );
        },
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
