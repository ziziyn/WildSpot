import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../components/bottom_nav.dart';
import '../components/community_post_card.dart';
import '../components/custom_app_bar.dart';
import '../models/community_post.dart';
import '../models/species_category.dart';
import '../pages/profile_page.dart';
import '../pages/settings_page.dart';
import '../repositories/community_repository.dart';

const double _kTabBarHeight = 48;
const double _kFilterBarHeight = 56;
const double _kPinnedHeaderHeight = _kTabBarHeight + _kFilterBarHeight;

/// Ruang di ujung feed supaya pos terakhir tidak tertutup FAB.
const double _kFeedClearance = 88;

/// Feed komunitas: tab Following / Discovery dan filter taksonomi tetap
/// terkunci di atas saat daftar digulir.
class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key, required this.repository, this.onTabChanged});

  final CommunityRepository repository;

  /// Mengganti tab bottom nav di [AppShell]. Null bila halaman berdiri sendiri.
  final ValueChanged<int>? onTabChanged;

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  late List<CommunityPost> _following;
  late List<CommunityPost> _discovery;

  SpeciesCategory _category = SpeciesCategory.all;
  bool _fabVisible = true;

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

  bool _onUserScroll(UserScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    final show = notification.direction != ScrollDirection.reverse;
    if (show != _fabVisible) setState(() => _fabVisible = show);
    return false;
  }

  List<CommunityPost> _filtered(List<CommunityPost> posts) {
    if (_category == SpeciesCategory.all) return posts;
    return [
      for (final post in posts)
        if (post.category == _category) post,
    ];
  }

  void _replace(CommunityPost post, CommunityPost Function(CommunityPost) map) {
    CommunityPost? mapped(CommunityPost current) =>
        current.id == post.id ? map(current) : null;

    setState(() {
      _following = [
        for (final current in _following) mapped(current) ?? current,
      ];
      _discovery = [
        for (final current in _discovery) mapped(current) ?? current,
      ];
    });
  }

  void _confirmId(CommunityPost post) {
    _replace(post, (current) {
      final confirmed = !current.isConfirmed;
      final nextCount = confirmed
          ? current.confirmCount + 1
          : current.confirmCount == 0
          ? 0
          : current.confirmCount - 1;
      return current.copyWith(isConfirmed: confirmed, confirmCount: nextCount);
    });
  }

  Future<void> _addFieldNote(CommunityPost post) async {
    final note = TextEditingController();
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final text = Theme.of(sheetContext).textTheme;
        final inset = MediaQuery.viewInsetsOf(sheetContext).bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + inset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Field Notes', style: text.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Record habitat, behavior, or uncertainty. Do not add a finer location.',
                style: text.bodyMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: note,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                style: text.bodyMedium,
                decoration: const InputDecoration(
                  hintText: 'What did you observe?',
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    Navigator.of(sheetContext).pop(note.text.trim().isNotEmpty),
                child: const Text('Save note'),
              ),
            ],
          ),
        );
      },
    );
    note.dispose();
    if (saved == true && mounted) {
      _replace(
        post,
        (current) =>
            current.copyWith(fieldNoteCount: current.fieldNoteCount + 1),
      );
    }
  }

  Future<void> _reportDisturbance(CommunityPost post) async {
    if (post.isReported) {
      _replace(post, (current) => current.copyWith(isReported: false));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final text = Theme.of(dialogContext).textTheme;
        return AlertDialog(
          title: Text('Report', style: text.titleLarge),
          content: Text(
            'Report habitat disturbance near ${post.locationLabel}? The exact coordinates stay hidden.',
            style: text.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Report'),
            ),
          ],
        );
      },
    );
    if (confirmed == true && mounted) {
      _replace(post, (current) => current.copyWith(isReported: true));
    }
  }

  void _openSearch() {
    final posts = [..._following, ..._discovery];
    showSearch<void>(
      context: context,
      delegate: _CommunitySearchDelegate(
        posts: posts,
        onConfirmId: _confirmId,
        onFieldNotes: _addFieldNote,
        onReport: _reportDisturbance,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Community',
        onSearchTap: _openSearch,
        onNotificationTap: () {},
        onSettingsTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const SettingsPage())),
        onProfileTap: () => Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => const ProfilePage())),
      ),
      body: NotificationListener<UserScrollNotification>(
        onNotification: _onUserScroll,
        child: NestedScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
                sliver: SliverPersistentHeader(
                  pinned: true,
                  delegate: _PinnedCommunityHeader(
                    tabController: _tabCtrl,
                    activeCategory: _category,
                    onSelected: (category) =>
                        setState(() => _category = category),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabCtrl,
            children: [
              _CommunityFeed(
                posts: _filtered(_following),
                onConfirmId: _confirmId,
                onFieldNotes: _addFieldNote,
                onReport: _reportDisturbance,
              ),
              _CommunityFeed(
                posts: _filtered(_discovery),
                onConfirmId: _confirmId,
                onFieldNotes: _addFieldNote,
                onReport: _reportDisturbance,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 4,
        onTap: (index) {
          if (index == 4) return;
          widget.onTabChanged?.call(index);
        },
      ),
      floatingActionButton: IgnorePointer(
        ignoring: !_fabVisible,
        child: AnimatedSlide(
          offset: _fabVisible ? Offset.zero : const Offset(0, 2),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: AnimatedOpacity(
            opacity: _fabVisible ? 1 : 0,
            duration: const Duration(milliseconds: 220),
            child: FloatingActionButton.extended(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post Sighting is not available yet.'),
                  ),
                );
              },
              tooltip: 'Post Sighting',
              icon: const Icon(Icons.add_location_alt_outlined),
              label: Text(
                'Post Sighting',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CommunityFeed extends StatelessWidget {
  const _CommunityFeed({
    required this.posts,
    required this.onConfirmId,
    required this.onFieldNotes,
    required this.onReport,
  });

  final List<CommunityPost> posts;
  final ValueChanged<CommunityPost> onConfirmId;
  final ValueChanged<CommunityPost> onFieldNotes;
  final ValueChanged<CommunityPost> onReport;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            if (posts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No sightings in this category yet.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final post = posts[index];
                  return CommunityPostCard(
                    key: ValueKey(post.id),
                    post: post,
                    onConfirmId: () => onConfirmId(post),
                    onFieldNotes: () => onFieldNotes(post),
                    onReport: () => onReport(post),
                  );
                }, childCount: posts.length),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: _kFeedClearance)),
          ],
        );
      },
    );
  }
}

class _PinnedCommunityHeader extends SliverPersistentHeaderDelegate {
  _PinnedCommunityHeader({
    required this.tabController,
    required this.activeCategory,
    required this.onSelected,
  });

  final TabController tabController;
  final SpeciesCategory activeCategory;
  final ValueChanged<SpeciesCategory> onSelected;

  @override
  double get minExtent => _kPinnedHeaderHeight;

  @override
  double get maxExtent => _kPinnedHeaderHeight;

  @override
  bool shouldRebuild(_PinnedCommunityHeader oldDelegate) =>
      oldDelegate.activeCategory != activeCategory ||
      oldDelegate.tabController != tabController;

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
        child: Column(
          children: [
            SizedBox(
              height: _kTabBarHeight,
              child: TabBar(
                controller: tabController,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(color: cs.primary, width: 2),
                ),
                labelColor: cs.primary,
                unselectedLabelColor: cs.onSurfaceVariant,
                labelStyle: text.labelLarge?.copyWith(color: cs.primary),
                unselectedLabelStyle: text.labelLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                dividerColor: cs.outlineVariant,
                tabs: const [
                  Tab(text: 'Following'),
                  Tab(text: 'Discovery'),
                ],
              ),
            ),
            SizedBox(
              height: _kFilterBarHeight,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  for (final category in SpeciesCategory.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category.label),
                        selected: activeCategory == category,
                        onSelected: (_) => onSelected(category),
                        showCheckmark: false,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunitySearchDelegate extends SearchDelegate<void> {
  _CommunitySearchDelegate({
    required this.posts,
    required this.onConfirmId,
    required this.onFieldNotes,
    required this.onReport,
  });

  final List<CommunityPost> posts;
  final ValueChanged<CommunityPost> onConfirmId;
  final ValueChanged<CommunityPost> onFieldNotes;
  final ValueChanged<CommunityPost> onReport;

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
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _results(context);

  @override
  Widget buildSuggestions(BuildContext context) => _results(context);

  Widget _results(BuildContext context) {
    final needle = query.trim().toLowerCase();
    final hits = needle.isEmpty
        ? posts
        : [
            for (final post in posts)
              if (_matches(post, needle)) post,
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
          onConfirmId: () {
            onConfirmId(post);
            close(context, null);
          },
          onFieldNotes: () => _resume(context, () => onFieldNotes(post)),
          onReport: () => _resume(context, () => onReport(post)),
        );
      },
    );
  }

  void _resume(BuildContext context, VoidCallback action) {
    close(context, null);
    WidgetsBinding.instance.addPostFrameCallback((_) => action());
  }

  bool _matches(CommunityPost post, String needle) {
    return post.body.toLowerCase().contains(needle) ||
        post.authorName.toLowerCase().contains(needle) ||
        post.locationLabel.toLowerCase().contains(needle) ||
        post.category.label.toLowerCase().contains(needle);
  }
}
