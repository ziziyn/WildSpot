import 'package:flutter/material.dart';

import '../components/custom_app_bar.dart' show kDefaultProfileImage;
import '../components/discovery_card.dart';
import '../core/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════
//  MOCK DATA — ganti dengan data dari repository/API
// ═══════════════════════════════════════════════════════════════════

class _ProfileData {
  const _ProfileData({
    required this.name,
    required this.isVerified,
    required this.bio,
    required this.logs,
    required this.rank,
    required this.badges,
  });

  final String name;
  final bool isVerified;
  final String bio;
  final int logs;
  final int rank;
  final int badges;
}

const _kProfile = _ProfileData(
  name: 'Alex Ranger',
  isVerified: true,
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

// Tiga log yang di-pin user (tampil satu baris di profil).
// Bukan const karena DateTime tidak punya const constructor.
// URL gambar = placeholder; ganti dengan foto observasi user.
final _kPinnedLogs = <_JournalEntry>[
  _JournalEntry(
    category: 'Flora',
    imageUrl: 'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?w=600&q=80',
    title: 'Rare Forest Fern',
    date: DateTime(2023, 10, 24),
    location: 'Sherwood North',
  ),
  _JournalEntry(
    category: 'Fauna',
    imageUrl: 'https://images.unsplash.com/photo-1470093851219-69951fcbb533?w=600&q=80',
    title: 'Metallic Jewel Beetle',
    date: DateTime(2023, 10, 22),
    location: 'Old Oak Glade',
  ),
  _JournalEntry(
    category: 'Fungi',
    imageUrl: 'https://images.unsplash.com/photo-1504545102780-26774c1bb073?w=600&q=80',
    title: 'Red-Capped Mushroom',
    date: DateTime(2023, 10, 18),
    location: 'Whispering Pines',
  ),
];

class _DiscussionPost {
  const _DiscussionPost({
    required this.title,
    required this.excerpt,
    required this.replies,
    required this.likes,
    required this.timeAgo,
  });

  final String title;
  final String excerpt;
  final int replies;
  final int likes;
  final String timeAgo;
}

// Post milik user ini; ganti dengan data dari repository/API.
const _kDiscussionPosts = <_DiscussionPost>[
  _DiscussionPost(
    title: 'Chanterelle or false chanterelle?',
    excerpt: 'Found a cluster near the old oak at Sherwood North. The gills '
        'look blunt and forked, but the orange is very deep. Thoughts?',
    replies: 14,
    likes: 32,
    timeAgo: '2h ago',
  ),
  _DiscussionPost(
    title: 'Best time of day to spot jewel beetles',
    excerpt: 'Caught my first one around midday on a sunny oak trunk. Curious '
        'whether anyone has better luck early in the morning.',
    replies: 8,
    likes: 21,
    timeAgo: '1d ago',
  ),
  _DiscussionPost(
    title: 'My ancient woodland indicator checklist',
    excerpt: 'Sharing the plants I look for to tell old woodland from newer '
        'plantings: bluebell, wood anemone, dog\'s mercury and more.',
    replies: 23,
    likes: 57,
    timeAgo: '4d ago',
  ),
];

const _kMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Judul kartu selalu Title Case: 'wild forest flower' → 'Wild Forest Flower'
/// (huruf setelah spasi atau tanda hubung juga kapital: 'Red-Capped').
String _toTitleCase(String s) => s.trim().toLowerCase().replaceAllMapped(
  RegExp(r'(^|[\s\-])(\p{L})', unicode: true),
  (m) => '${m[1]}${m[2]!.toUpperCase()}',
);

/// 'Oct 24, 2023' — tanpa dependency intl.
String _formatDate(DateTime d) =>
    '${_kMonths[d.month - 1]} ${d.day}, ${d.year}';

const _kMissionLine =
    'Contributing to SDG 15: Life on Land through community science.';

// ═══════════════════════════════════════════════════════════════════
//  PROFILE PAGE
// ═══════════════════════════════════════════════════════════════════

/// Halaman profil Ranger: avatar, bio, statistik, Journal (3 pinned logs),
/// dan Discussions (post milik user).
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

  @override
  Widget build(BuildContext context) {
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

            // ── ③ Journal header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
                child: _SectionHeader(
                  icon: Icons.menu_book_rounded,
                  title: 'Journal',
                  // TODO: buka halaman penuh Journal
                  onViewMore: () {},
                ),
              ),
            ),

            // ── ③ Pinned logs (3 kartu dalam satu baris)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _PinnedLogsRow(entries: _kPinnedLogs),
              ),
            ),

            // ── ④ Discussions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 8, 4),
                child: _SectionHeader(
                  icon: Icons.forum_outlined,
                  title: 'Discussions',
                  // TODO: buka halaman penuh Discussions
                  onViewMore: () {},
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _DiscussionList(posts: _kDiscussionPosts),
              ),
            ),

            // ── ⑤ Footer
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
//  ① HEADER (avatar di tengah, nama + verified, bio rata tengah)
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

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar di tengah
                _Avatar(url: avatarUrl, radius: 50),
                const SizedBox(height: 14),

                // Nama + tanda verified (Material 3: Icons.verified)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        data.name,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: tt.displayMedium!.copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    if (data.isVerified) ...[
                      const SizedBox(width: 6),
                      Tooltip(
                        message: 'Verified',
                        child: Icon(Icons.verified,
                            size: 22, color: brand.amber),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),

                // Bio rata tengah
                Text(
                  data.bio,
                  maxLines: 4,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodyMedium!.copyWith(
                    fontSize: 14,
                    height: 1.4,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Edit Profile: hanya ikon pena (tanpa latar) di pojok kanan atas,
        // tepat di bawah ikon Pengaturan. Kotak sentuh 48dp berpusat 28dp
        // dari tepi kanan (satu sumbu dengan Pengaturan).
        Positioned(
          top: 0,
          right: 4,
          child: IconButton(
            onPressed: onEditProfile,
            tooltip: 'Edit Profile',
            icon: const Icon(Icons.edit_outlined, size: 20),
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, this.radius = 50});

  final String url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // diameter total = radius*2 + 3 (jarak) *2 + 3 (cincin) *2 = radius*2 + 12
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: cs.primary, width: 3),
        boxShadow: WsShadow.greenGlow(context),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: cs.surfaceContainer,
        backgroundImage: NetworkImage(url),
        onBackgroundImageError: (error, stack) {},
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
              icon: Icons.photo_camera_outlined,
              label: 'LOGS',
              value: '${data.logs}',
            ),
          ),
          const _StatDivider(),
          Expanded(
            child: _ProfileStat(
              icon: Icons.leaderboard_outlined,
              label: 'RANK',
              value: '${data.rank}',
            ),
          ),
          const _StatDivider(),
          Expanded(
            child: _ProfileStat(
              icon: Icons.workspace_premium_outlined,
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
//  ③ JOURNAL
// ═══════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.onViewMore,
  });

  final IconData icon;
  final String title;
  final VoidCallback onViewMore;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: cs.primary, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: tt.titleLarge!.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
        ),
        TextButton(
          onPressed: onViewMore,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: const Text('View More'),
        ),
      ],
    );
  }
}

/// 3 pinned logs dalam satu baris. Lebar kartu dibagi rata; tinggi mengikuti
/// rasio foto + footer ([DiscoveryCardSize.mini]).
class _PinnedLogsRow extends StatelessWidget {
  const _PinnedLogsRow({required this.entries});

  final List<_JournalEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < entries.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: DiscoveryCard(
              size: DiscoveryCardSize.mini,
              category: entries[i].category,
              imageUrl: entries[i].imageUrl,
              title: _toTitleCase(entries[i].title),
              chipPosition: DiscoveryChipPosition.topRight,
              imageAspectRatio: 1,
              details: [
                DiscoveryDetail(
                  icon: Icons.schedule_rounded,
                  text: _formatDate(entries[i].date),
                ),
              ],
              onTap: () {}, // TODO: buka detail entri
            ),
          ),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ④ DISCUSSIONS
// ═══════════════════════════════════════════════════════════════════

class _DiscussionList extends StatelessWidget {
  const _DiscussionList({required this.posts});

  final List<_DiscussionPost> posts;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < posts.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _DiscussionCard(
            post: posts[i],
            onTap: () {}, // TODO: buka detail diskusi
          ),
        ],
      ],
    );
  }
}

class _DiscussionCard extends StatelessWidget {
  const _DiscussionCard({required this.post, required this.onTap});

  final _DiscussionPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(WsRadius.lg),
        boxShadow: WsShadow.card(context),
      ),
      // Material sebagai latar supaya ripple InkWell terlihat di atas kartu.
      child: Material(
        color: cs.surfaceContainerLowest,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(WsRadius.lg),
          side: BorderSide(color: cs.outlineVariant),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleLarge!.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  post.excerpt,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodyMedium!.copyWith(
                    fontSize: 13,
                    height: 1.4,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _PostMeta(
                      icon: Icons.chat_bubble_outline_rounded,
                      value: '${post.replies}',
                    ),
                    const SizedBox(width: 16),
                    _PostMeta(
                      icon: Icons.favorite_border_rounded,
                      value: '${post.likes}',
                    ),
                    const Spacer(),
                    Text(
                      post.timeAgo,
                      style: tt.labelMedium!.copyWith(
                        fontSize: 11,
                        color: cs.outline,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PostMeta extends StatelessWidget {
  const _PostMeta({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: 5),
        Text(
          value,
          style: tt.labelMedium!.copyWith(
            fontSize: 12,
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ⑤ FOOTER
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
