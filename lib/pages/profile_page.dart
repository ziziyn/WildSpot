import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../components/custom_app_bar.dart' show kDefaultProfileImage;
import '../components/discovery_card.dart';
import '../core/app_theme.dart';
import 'camera_page.dart';

// ═══════════════════════════════════════════════════════════════════
//  MOCK DATA — ganti dengan data dari repository/API
// ═══════════════════════════════════════════════════════════════════

class _ProfileData {
  const _ProfileData({
    required this.name,
    required this.rankTitle,
    required this.level,
    required this.bio,
    required this.logs,
    required this.rank,
    required this.badges,
  });

  final String name;
  final String rankTitle;
  final int level;
  final String bio;
  final int logs;
  final int rank;
  final int badges;
}

const _kProfile = _ProfileData(
  name: 'Alex Ranger',
  rankTitle: 'EXPERT SCOUT',
  level: 24,
  bio: 'Passionate naturalist exploring the temperate forests of the UK. '
      'Documenting biodiversity one sprout at a time.',
  logs: 142,
  rank: 38,
  badges: 12,
);

class _JournalEntry {
  const _JournalEntry({
    required this.category,
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.location,
  });

  final String category;
  final String imageUrl;
  final String title;
  final DateTime date;
  final String location;
}

// Bukan const karena DateTime tidak punya const constructor.
// URL gambar = placeholder; ganti dengan foto observasi user.
final _kJournalEntries = <_JournalEntry>[
  _JournalEntry(
    category: 'Flora',
    imageUrl:
        'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?w=600&q=80',
    title: 'Rare Forest Fern',
    date: DateTime(2023, 10, 24),
    location: 'Sherwood North',
  ),
  _JournalEntry(
    category: 'Fauna',
    imageUrl:
        'https://images.unsplash.com/photo-1470093851219-69951fcbb533?w=600&q=80',
    title: 'Metallic Jewel Beetle',
    date: DateTime(2023, 10, 22),
    location: 'Old Oak Glade',
  ),
  _JournalEntry(
    category: 'Flora',
    imageUrl:
        'https://images.unsplash.com/photo-1490750967868-88aa4486c946?w=600&q=80',
    title: 'Wild Forest Flower',
    date: DateTime(2023, 10, 20),
    location: 'East Brook Bank',
  ),
  _JournalEntry(
    category: 'Fungi',
    imageUrl:
        'https://images.unsplash.com/photo-1504545102780-26774c1bb073?w=600&q=80',
    title: 'Red-Capped Mushroom',
    date: DateTime(2023, 10, 18),
    location: 'Whispering Pines',
  ),
];

const _kMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Judul kartu selalu Title Case: 'wild forest flower' → 'Wild Forest Flower'
/// (huruf setelah spasi atau tanda hubung juga kapital: 'Red-Capped').
String _toTitleCase(String s) => s.trim().toLowerCase().replaceAllMapped(
      RegExp(r'(^|[\s\-])(\p{L})', unicode: true),
      (m) => '${m[1]}${m[2]!.toUpperCase()}',
    );

/// 'Oct 24, 2023' — tanpa dependency intl.
String _formatDate(DateTime d) => '${_kMonths[d.month - 1]} ${d.day}, ${d.year}';

const _kMissionLine =
    'Contributing to SDG 15: Life on Land through community science.';

// ═══════════════════════════════════════════════════════════════════
//  PROFILE PAGE
// ═══════════════════════════════════════════════════════════════════

/// Halaman profil Ranger: avatar, bio, statistik, dan My Journal.
///
/// Dibuka dari avatar di kanan atas [CustomAppBar] (lewat [MainLayout]).
/// Halaman ini di-push di atas shell, jadi tidak memakai bottom nav.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.avatarUrl = kDefaultProfileImage});

  final String avatarUrl;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
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

  /// Kartu Add Entry → membuka kamera untuk merekam penemuan baru.
  Widget _buildAddEntryCard(BuildContext context) {
    return AspectRatio(
      aspectRatio: 388 / 350,
      child: _AddEntryCard(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const CameraPage()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = _kJournalEntries;
    final addInGrid = entries.length.isOdd;

    return Scaffold(
      // Warna, tinggi bayangan, dan gaya judul berasal dari appBarTheme.
      appBar: AppBar(
        toolbarHeight: 64,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          tooltip: 'Kembali',
          icon: const Icon(Icons.chevron_left, size: 30),
        ),
        title: const Text('Ranger Profile'),
        actions: [
          IconButton(
            onPressed: () {}, // TODO: buka halaman pengaturan
            tooltip: 'Pengaturan',
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── ① Avatar, nama, badge, bio
            SliverToBoxAdapter(
              child: _ProfileHeader(
                avatarUrl: widget.avatarUrl,
                data: _kProfile,
                // TODO: buka layar Edit Profile (foto, nama, bio sekaligus)
                onEditProfile: () {},
              ),
            ),

            // ── ② Stats
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: _StatsCard(data: _kProfile),
              ),
            ),

            // ── ③ My Journal header
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: _JournalHeader(),
              ),
            ),

            // ── ③ My Journal grid
            // Kartu Add Entry ikut masuk grid hanya bila jumlah entri ganjil
            // (mengisi slot kosong di baris terakhir). Bila genap, ia berdiri
            // sendiri di bawah grid supaya tidak ada ruang kosong setinggi
            // kartu entri sebelum footer.
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.74,
                ),
                delegate: SliverChildBuilderDelegate(
                  childCount: entries.length + (addInGrid ? 1 : 0),
                  (context, index) {
                    if (index == entries.length) {
                      return Align(
                        alignment: Alignment.topCenter,
                        child: _buildAddEntryCard(context),
                      );
                    }
                    final e = entries[index];
                    return DiscoveryCard(
                      size: DiscoveryCardSize.compact,
                      category: e.category,
                      imageUrl: e.imageUrl,
                      title: _toTitleCase(e.title),
                      chipPosition: DiscoveryChipPosition.topRight,
                      showCategoryIcon: true,
                      details: [
                        DiscoveryDetail(
                          icon: Icons.schedule_rounded,
                          text: _formatDate(e.date),
                        ),
                        DiscoveryDetail(
                          icon: Icons.location_on_outlined,
                          text: e.location,
                        ),
                      ],
                      onTap: () {}, // TODO: buka detail entri
                    );
                  },
                ),
              ),
            ),
            if (!addInGrid)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Expanded(child: _buildAddEntryCard(context)),
                      const SizedBox(width: 12),
                      const Expanded(child: SizedBox.shrink()),
                    ],
                  ),
                ),
              ),

            // ── ④ Footer
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: _ProfileFooter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ① HEADER
// ═══════════════════════════════════════════════════════════════════

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.avatarUrl,
    required this.data,
    required this.onEditProfile,
  });

  final String avatarUrl;
  final _ProfileData data;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final brand = context.wsBrand;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        children: [
          _Avatar(url: avatarUrl),
          const SizedBox(height: 16),

          Text(
            data.name,
            textAlign: TextAlign.center,
            style: tt.displayMedium!.copyWith(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 10),

          // badge peringkat + level
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(
                icon: Icons.track_changes,
                label: data.rankTitle,
                fill: cs.primaryContainer,
                border: cs.primary.withAlpha(80),
                foreground: cs.onPrimaryContainer,
              ),
              _InfoPill(
                label: 'LEVEL ${data.level}',
                fill: brand.amberFaint,
                border: brand.amber.withAlpha(60),
                foreground: brand.amber,
              ),
            ],
          ),
          const SizedBox(height: 14),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              data.bio,
              textAlign: TextAlign.center,
              style: tt.bodyMedium!.copyWith(
                fontSize: 15,
                height: 1.45,
                color: cs.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Satu pintu untuk mengubah foto, nama, dan bio.
          FilledButton.icon(
            onPressed: onEditProfile,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit Profile'),
            style: FilledButton.styleFrom(
              backgroundColor: cs.primaryContainer,
              foregroundColor: cs.onPrimaryContainer,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(WsRadius.md)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: tt.bodyMedium!.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // 50 (radius) *2 + 3 (jarak) *2 + 3 (cincin) *2 = 112
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: cs.primary, width: 3),
        boxShadow: WsShadow.greenGlow(context),
      ),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: cs.surfaceContainer,
        backgroundImage: NetworkImage(url),
        onBackgroundImageError: (error, stack) {},
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.label,
    required this.fill,
    required this.border,
    required this.foreground,
    this.icon,
  });

  final String label;
  final Color fill;
  final Color border;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: const BorderRadius.all(WsRadius.pill),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: foreground),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: tt.labelMedium!.copyWith(
              fontSize: 12,
              color: foreground,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ② STATS CARD
// ═══════════════════════════════════════════════════════════════════

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.data});

  final _ProfileData data;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest, // sama dengan kartu Home
        borderRadius: const BorderRadius.all(WsRadius.lg),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: WsShadow.card(context),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ProfileStat(
              icon: Icons.show_chart_rounded,
              label: 'LOGS',
              value: '${data.logs}',
            ),
          ),
          const _StatDivider(),
          Expanded(
            child: _ProfileStat(
              icon: Icons.trending_up_rounded,
              label: 'RANK',
              value: '${data.rank}',
            ),
          ),
          const _StatDivider(),
          Expanded(
            child: _ProfileStat(
              icon: Icons.emoji_events_outlined,
              label: 'BADGES',
              value: '${data.badges}',
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: cs.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              value,
              style: context.wsMono.stat.copyWith(
                fontSize: 24,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: tt.labelMedium!.copyWith(
            fontSize: 11,
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: Theme.of(context).colorScheme.outlineVariant,
      );
}

// ═══════════════════════════════════════════════════════════════════
//  ③ MY JOURNAL
// ═══════════════════════════════════════════════════════════════════

class _JournalHeader extends StatelessWidget {
  const _JournalHeader();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.menu_book_rounded, color: cs.primary, size: 24),
        const SizedBox(width: 10),
        Text(
          'My Journal',
          style: tt.titleLarge!.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}

/// Kartu "Add Entry" dengan border putus-putus.
class _AddEntryCard extends StatelessWidget {
  const _AddEntryCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(WsRadius.lg),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: cs.primary.withAlpha(150),
            radius: WsRadius.lg.x,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_outlined, size: 32, color: cs.primary),
                const SizedBox(height: 10),
                Text(
                  'ADD ENTRY',
                  style: tt.labelMedium!.copyWith(
                    fontSize: 13,
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    this.strokeWidth = 1.4,
    this.dashLength = 6,
    this.gapLength = 5,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(strokeWidth / 2),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth ||
      old.dashLength != dashLength ||
      old.gapLength != gapLength;
}

// ═══════════════════════════════════════════════════════════════════
//  ④ FOOTER
// ═══════════════════════════════════════════════════════════════════

class _ProfileFooter extends StatelessWidget {
  const _ProfileFooter();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Text(
      _kMissionLine,
      textAlign: TextAlign.center,
      style: tt.bodyMedium!.copyWith(
        fontSize: 13,
        height: 1.4,
        color: cs.onSurfaceVariant,
      ),
    );
  }
}