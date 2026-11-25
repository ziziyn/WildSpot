import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../components/bottom_nav.dart';
import '../components/community_post_card.dart';
import '../components/custom_app_bar.dart';
import '../models/community_post.dart';
import '../pages/profile_page.dart';
import '../pages/settings_page.dart';
import '../repositories/community_repository.dart';

// ═══════════════════════════════════════════════════════════════════════════
// LAYOUT CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════

/// Height of the sticky TabBar row (shared pinned header).
const double _kTabBarHeight = 48.0;

/// Height of the hide-on-scroll filter chip bar (Discovery only).
const double _kFilterBarHeight = 48.0;

/// Bottom clearance so the last post is never obscured by FAB + BottomNav.
const double _kFeedClearance = 96.0;

// ═══════════════════════════════════════════════════════════════════════════
// GEO-FILTER SERVICE  –  abstraction layer, GPS-ready
// ═══════════════════════════════════════════════════════════════════════════

/// Lightweight location abstraction — GPS-ready.
///
/// Swap [_deviceLat] / [_deviceLon] with a real `Geolocator.getCurrentPosition()`
/// call once the `geolocator` package is added to pubspec.yaml.
class _GeoFilterState {
  _GeoFilterState._();

  /// Simulated device position (Medan, Sumatera Utara).
  static const double _deviceLat = 3.595;
  static const double _deviceLon = 98.672;

  /// Threshold: posts within 300 km of device appear in the Near You feed.
  static const double _radiusKm = 300.0;

  static double? distanceKm(CommunityPost post) {
    final lat2 = post.publicLatitude;
    final lon2 = post.publicLongitude;
    if (lat2 == null || lon2 == null) return null;
    return _haversineKm(_deviceLat, _deviceLon, lat2, lon2);
  }

  static bool isNearDevice(CommunityPost post) {
    final d = distanceKm(post);
    return d != null && d <= _radiusKm;
  }

  static double _haversineKm(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.pow(math.sin(dLon / 2), 2);
    return r * 2 * math.asin(math.sqrt(a));
  }

  static double _rad(double deg) => deg * math.pi / 180.0;
}

// ═══════════════════════════════════════════════════════════════════════════
// PAGE WIDGET
// ═══════════════════════════════════════════════════════════════════════════

class CommunityPage extends StatefulWidget {
  const CommunityPage({
    super.key,
    required this.repository,
    this.onTabChanged,
  });

  final CommunityRepository repository;
  final ValueChanged<int>? onTabChanged;

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  late List<CommunityPost> _following;
  late List<CommunityPost> _discovery;

  bool _nearYou = false;
  bool _discussionsOnly = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _following = widget.repository.fetchFollowing();
    _discovery = widget.repository.fetchDiscovery();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  // ── State mutations ────────────────────────────────────────────────────────

  void _replace(CommunityPost post, CommunityPost Function(CommunityPost) map) {
    CommunityPost? mapped(CommunityPost c) =>
        c.id == post.id ? map(c) : null;
    setState(() {
      _following = [for (final c in _following) mapped(c) ?? c];
      _discovery = [for (final c in _discovery) mapped(c) ?? c];
    });
  }

  void _toggleLike(CommunityPost post) {
    _replace(post, (current) {
      final liked = !current.isConfirmed;
      return current.copyWith(
        isConfirmed: liked,
        confirmCount: liked
            ? current.confirmCount + 1
            : (current.confirmCount == 0 ? 0 : current.confirmCount - 1),
      );
    });
  }

  // ── Discovery filter pipeline ──────────────────────────────────────────────

  List<CommunityPost> get _filteredDiscovery {
    var posts = _discovery;
    if (_nearYou) posts = posts.where(_GeoFilterState.isNearDevice).toList();
    if (_discussionsOnly) {
      posts = posts.where((p) => p.imageUrl == null).toList();
    }
    return posts;
  }

  // ── Search ─────────────────────────────────────────────────────────────────

  void _openSearch() {
    showSearch<void>(
      context: context,
      delegate: _CommunitySearchDelegate(
        posts: [..._following, ..._discovery],
        onLike: _toggleLike,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Community',
        onSearchTap: _openSearch,
        onNotificationTap: () {},
        onSettingsTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
        ),
        onProfileTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
        ),
      ),
      body: NestedScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverPersistentHeader(
              pinned: true,
              // Shared header = TabBar only (48dp).
              // Filter chips live inside each tab's feed.
              delegate: _PinnedCommunityHeader(tabController: _tabCtrl),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            // Following — clean chronological feed, no filter row.
            _CommunityFeed(
              posts: _following,
              onLike: _toggleLike,
            ),
            // Discovery — has hide-on-scroll filter chip bar.
            _CommunityFeed(
              posts: _filteredDiscovery,
              onLike: _toggleLike,
              nearYouActive: _nearYou,
              discussionsOnly: _discussionsOnly,
              isNearYouFilter: _nearYou,
              isDiscussionsFilter: _discussionsOnly,
              onNearYouToggle: () => setState(() => _nearYou = !_nearYou),
              onDiscussionsToggle: () =>
                  setState(() => _discussionsOnly = !_discussionsOnly),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 4,
        onTap: (index) {
          if (index == 4) return;
          widget.onTabChanged?.call(index);
        },
      ),
      // ── Regular FAB — icon only, no label ─────────────────────────────────
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton(
          onPressed: _onFabPressed,
          tooltip: 'Post Sighting',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _onFabPressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post Sighting is not available yet.')),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PINNED HEADER DELEGATE  –  TabBar only (48dp)
// ═══════════════════════════════════════════════════════════════════════════

class _PinnedCommunityHeader extends SliverPersistentHeaderDelegate {
  _PinnedCommunityHeader({required this.tabController});

  final TabController tabController;

  @override
  double get minExtent => _kTabBarHeight;

  @override
  double get maxExtent => _kTabBarHeight;

  @override
  bool shouldRebuild(_PinnedCommunityHeader old) =>
      old.tabController != tabController;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Material(
      color: cs.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: cs.outlineVariant)),
        ),
        child: SizedBox(
          height: _kTabBarHeight,
          child: TabBar(
            controller: tabController,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(color: cs.primary, width: 2),
            ),
            labelColor: cs.primary,
            unselectedLabelColor: cs.onSurfaceVariant,
            labelStyle: text.labelLarge?.copyWith(color: cs.primary),
            unselectedLabelStyle:
                text.labelLarge?.copyWith(color: cs.onSurfaceVariant),
            dividerColor: cs.outlineVariant,
            tabs: const [
              Tab(text: 'Following'),
              Tab(text: 'Discovery'),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FEED WIDGET  –  with optional permanent filter chip bar
// ═══════════════════════════════════════════════════════════════════════════

class _CommunityFeed extends StatelessWidget {
  const _CommunityFeed({
    required this.posts,
    required this.onLike,
    this.nearYouActive = false,
    this.discussionsOnly = false,
    this.isNearYouFilter = false,
    this.isDiscussionsFilter = false,
    this.onNearYouToggle,
    this.onDiscussionsToggle,
  });

  final List<CommunityPost> posts;
  final ValueChanged<CommunityPost> onLike;
  final bool nearYouActive;
  final bool discussionsOnly;
  final bool isNearYouFilter;
  final bool isDiscussionsFilter;
  final VoidCallback? onNearYouToggle;
  final VoidCallback? onDiscussionsToggle;

  bool get hasFilterBar => onNearYouToggle != null;

  @override
  Widget build(BuildContext context) {
    // Builder is required so that NestedScrollView.sliverOverlapAbsorberHandleFor
    // receives the correct inner BuildContext from the TabBarView body.
    return Builder(
      builder: (ctx) => ColoredBox(
        color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // Absorbs the 48dp TabBar overlap so content starts at the right
            // vertical position inside the NestedScrollView.
            SliverOverlapInjector(
              handle:
                  NestedScrollView.sliverOverlapAbsorberHandleFor(ctx),
            ),
            // ── Pinned filter chip bar (Discovery only) ───────────────
            // Lives inside the CustomScrollView as a pinned SliverPersistentHeader
            // so it stays at the top while the list scrolls beneath it.
            if (hasFilterBar)
              SliverPersistentHeader(
                pinned: true,
                delegate: _FilterBarDelegate(
                  nearYouActive: nearYouActive,
                  discussionsOnly: discussionsOnly,
                  onNearYouToggle: onNearYouToggle!,
                  onDiscussionsToggle: onDiscussionsToggle!,
                ),
              ),
            // ── Post list / empty state ───────────────────────────────
            if (posts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(ctx),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = posts[index];
                    return CommunityPostCard(
                      key: ValueKey(post.id),
                      post: post,
                      onLike: () => onLike(post),
                    );
                  },
                  childCount: posts.length,
                ),
              ),
            const SliverToBoxAdapter(
                child: SizedBox(height: _kFeedClearance)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    if (isNearYouFilter) return const _NearYouEmptyState();
    if (isDiscussionsFilter) return const _DiscussionsEmptyState();
    return Center(
      child: Text(
        'No sightings here yet.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FILTER BAR DELEGATE  –  SliverPersistentHeaderDelegate, 48dp, pinned
// ═══════════════════════════════════════════════════════════════════════════

/// Renders the "Near You" + "Discussions" chip row as a pinned sliver header
/// inside the Discovery feed's CustomScrollView.
///
/// Placing it inside the scroll view (not outside) is the correct pattern
/// for NestedScrollView: it respects overlap absorption and stays pinned
/// below the shared TabBar while the post list scrolls underneath.
class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  const _FilterBarDelegate({
    required this.nearYouActive,
    required this.discussionsOnly,
    required this.onNearYouToggle,
    required this.onDiscussionsToggle,
  });

  final bool nearYouActive;
  final bool discussionsOnly;
  final VoidCallback onNearYouToggle;
  final VoidCallback onDiscussionsToggle;

  @override
  double get minExtent => _kFilterBarHeight;

  @override
  double get maxExtent => _kFilterBarHeight;

  @override
  bool shouldRebuild(_FilterBarDelegate old) =>
      old.nearYouActive != nearYouActive ||
      old.discussionsOnly != discussionsOnly;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      elevation: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: cs.outlineVariant)),
        ),
        child: SizedBox(
          height: _kFilterBarHeight,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // ── Near You ────────────────────────────────────────
                FilterChip(
                  showCheckmark: false,
                  avatar: Icon(
                    nearYouActive
                        ? Icons.near_me
                        : Icons.near_me_outlined,
                    size: 16,
                    color: nearYouActive
                        ? cs.onSecondaryContainer
                        : cs.onSurfaceVariant,
                  ),
                  label: const Text('Near You'),
                  selected: nearYouActive,
                  onSelected: (_) => onNearYouToggle(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 0),
                  labelPadding:
                      const EdgeInsets.only(left: 2, right: 6),
                ),
                const SizedBox(width: 8),
                // ── Discussions ──────────────────────────────────────
                FilterChip(
                  showCheckmark: false,
                  avatar: Icon(
                    Icons.forum_outlined,
                    size: 16,
                    color: discussionsOnly
                        ? cs.onSecondaryContainer
                        : cs.onSurfaceVariant,
                  ),
                  label: const Text('Discussions'),
                  selected: discussionsOnly,
                  onSelected: (_) => onDiscussionsToggle(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 0),
                  labelPadding:
                      const EdgeInsets.only(left: 2, right: 6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NEAR YOU EMPTY STATE
// ═══════════════════════════════════════════════════════════════════════════

class _NearYouEmptyState extends StatelessWidget {
  const _NearYouEmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off_outlined,
                size: 64, color: cs.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'No sightings nearby',
              style: text.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "We couldn't find any posts within your current radius. "
              'Be the first to share a sighting!',
              style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DISCUSSIONS EMPTY STATE
// ═══════════════════════════════════════════════════════════════════════════

class _DiscussionsEmptyState extends StatelessWidget {
  const _DiscussionsEmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forum_outlined,
                size: 64, color: cs.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'No discussions found',
              style: text.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'No text posts in this area yet. Start the conversation!',
              style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SEARCH DELEGATE
// ═══════════════════════════════════════════════════════════════════════════

class _CommunitySearchDelegate extends SearchDelegate<void> {
  _CommunitySearchDelegate({required this.posts, required this.onLike});

  final List<CommunityPost> posts;
  final ValueChanged<CommunityPost> onLike;

  @override
  String get searchFieldLabel => 'Search sightings';

  @override
  List<Widget>? buildActions(BuildContext context) {
    if (query.isEmpty) return null;
    return [
      IconButton(
        onPressed: () => query = '',
        tooltip: 'Clear',
        icon: const Icon(Icons.close),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        onPressed: () => close(context, null),
        tooltip: 'Back',
        icon: const Icon(Icons.arrow_back),
      );

  @override
  Widget buildResults(BuildContext context) => _results(context);

  @override
  Widget buildSuggestions(BuildContext context) => _results(context);

  Widget _results(BuildContext context) {
    final needle = query.trim().toLowerCase();
    final hits = needle.isEmpty
        ? posts
        : [
            for (final p in posts)
              if (_matches(p, needle)) p,
          ];

    if (hits.isEmpty) {
      return Center(
        child: Text(
          'No matching sightings.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: _kFeedClearance),
      itemCount: hits.length,
      itemBuilder: (context, index) {
        final post = hits[index];
        return CommunityPostCard(
          key: ValueKey(post.id),
          post: post,
          onLike: () => onLike(post),
        );
      },
    );
  }

  bool _matches(CommunityPost post, String needle) =>
      post.body.toLowerCase().contains(needle) ||
      post.authorName.toLowerCase().contains(needle) ||
      post.locationLabel.toLowerCase().contains(needle);
}
