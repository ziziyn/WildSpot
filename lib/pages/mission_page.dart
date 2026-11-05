import 'package:flutter/material.dart';

import '../core/app_theme.dart';

// Warna medali dan streak sama dengan Home Page.
const _kMedalRibbon = Color(0xFFD32F2F);
const _kMedalStar = Color(0xFFFFB300);
const _kFlame = Color(0xFFFF6D00);

class MissionPage extends StatefulWidget {
  const MissionPage({super.key});

  @override
  State<MissionPage> createState() => _MissionPageState();
}

class _MissionPageState extends State<MissionPage> {
  bool _showBadges = false;
  bool _showAll = false;

  // Active Mission mengikuti Home Page.
  static const String _activeMissionTitle = 'Native Pollinator Census';

  static const String _activeMissionDescription =
      'Identify 5 different pollinator species in your local area.';

  static const int _completed = 3;
  static const int _target = 5;
  static const double _progress = 0.60;

  // Recommended Missions.
  // Data sementara sampai tersedia integrasi API missions.
  static const List<_MissionItem> _recommendedMissions = [
    _MissionItem(
      title: 'Butterfly Explorer',
      description: 'Find and observe 5 different butterfly species.',
      icon: Icons.flutter_dash,
    ),
    _MissionItem(
      title: 'Wildflower Watch',
      description: 'Find and observe 5 wildflower species.',
      icon: Icons.local_florist_outlined,
    ),
    _MissionItem(
      title: 'Forest Guardian',
      description: 'Identify 10 different tree species.',
      icon: Icons.forest_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ColoredBox(
      color: cs.surface,
      child: SafeArea(
        top: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Rank and Badges
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(child: _rankAndBadges()),
            ),

            // Tabs
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              sliver: SliverToBoxAdapter(child: _tabs()),
            ),

            // Active Mission / My Badges
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              sliver: SliverToBoxAdapter(
                child: _showBadges ? _badgesPanel() : _activeMission(),
              ),
            ),

            // Recommended Missions
            if (!_showBadges) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                sliver: SliverToBoxAdapter(child: _recommendedHeader()),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return _RecommendedMissionCard(
                      mission: _recommendedMissions[index],
                    );
                  }, childCount: _showAll ? _recommendedMissions.length : 2),
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // RANK AND BADGES
  // ============================================================

  Widget _rankAndBadges() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: const BorderRadius.all(WsRadius.lg),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.workspace_premium_outlined,
                  color: cs.primary,
                  size: 22,
                ),
                const SizedBox(height: 4),
                Text(
                  'Badges',
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                Text(
                  '12',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),

          Container(height: 40, width: 1, color: cs.outlineVariant),

          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.trending_up_rounded, color: cs.primary, size: 22),
                const SizedBox(height: 4),
                Text(
                  'Rank',
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                Text(
                  '#12',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // ============================================================
  // TABS
  // ============================================================

  Widget _tabs() {
    final cs = Theme.of(context).colorScheme;

    return Container(
      height: 42,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: const BorderRadius.all(WsRadius.pill),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          _tabButton('Active Missions', false),
          _tabButton('My Badges', true),
        ],
      ),
    );
  }

  Widget _tabButton(String label, bool badges) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final selected = _showBadges == badges;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: InkWell(
          borderRadius: const BorderRadius.all(WsRadius.pill),
          onTap: () {
            setState(() {
              _showBadges = badges;
              _showAll = false;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? cs.primary : Colors.transparent,
              borderRadius: const BorderRadius.all(WsRadius.pill),
            ),
            child: Text(
              label,
              style: tt.labelMedium?.copyWith(
                fontSize: 12.5,
                color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ACTIVE MISSION
  // Desain mengikuti _ActiveMissionCard Home Page.
  // ============================================================

  Widget _activeMission() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: const BorderRadius.all(WsRadius.lg),
        boxShadow: WsShadow.greenGlow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Medali dua warna
              SizedBox(
                width: 22,
                height: 22,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRect(
                      child: Align(
                        alignment: Alignment.topCenter,
                        heightFactor: 0.38,
                        child: const Icon(
                          Icons.military_tech,
                          color: _kMedalRibbon,
                          size: 22,
                        ),
                      ),
                    ),
                    ClipRect(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        heightFactor: 0.62,
                        child: const Icon(
                          Icons.military_tech,
                          color: _kMedalStar,
                          size: 22,
                        ),
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
                    fontSize: 15,
                    color: cs.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              // STREAKING badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cs.onPrimary.withAlpha(30),
                  borderRadius: const BorderRadius.all(WsRadius.pill),
                  border: Border.all(color: cs.onPrimary.withAlpha(60)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: _kFlame,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'STREAKING',
                      style: tt.labelMedium!.copyWith(
                        fontSize: 10,
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Mission name
          Text(
            _activeMissionTitle,
            style: tt.titleLarge!.copyWith(
              fontSize: 18,
              color: cs.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            _activeMissionDescription,
            style: tt.bodyMedium!.copyWith(
              fontSize: 13,
              color: cs.onPrimary.withAlpha(200),
            ),
          ),

          const SizedBox(height: 16),

          // Progress row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: tt.labelMedium!.copyWith(
                  fontSize: 12,
                  color: cs.onPrimary.withAlpha(180),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$_completed/$_target (60%)',
                style: context.wsMono.stat.copyWith(
                  fontSize: 12,
                  color: cs.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Progress bar sama dengan Home Page
          _ProgressBar(
            progress: _progress,
            trackColor: cs.onPrimary.withAlpha(40),
            fillColor: cs.onPrimary.withAlpha(230),
          ),

          const SizedBox(height: 16),

          // CTA button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _showMissionDetails,
              style: FilledButton.styleFrom(
                backgroundColor: cs.primaryContainer,
                foregroundColor: cs.onPrimaryContainer,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(WsRadius.md),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                'Continue Mission',
                style: tt.bodyMedium!.copyWith(
                  fontSize: 14,
                  color: cs.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MISSION DETAILS
  // ============================================================

  void _showMissionDetails() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: cs.surface,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _activeMissionTitle,
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  _activeMissionDescription,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                Text('Mission Progress', style: tt.titleSmall),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _progress,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(20),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_completed of $_target observations completed (60%)',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // RECOMMENDED HEADER
  // ============================================================

  Widget _recommendedHeader() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            'Recommended',
            style: tt.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        TextButton(
          onPressed: () {
            setState(() {
              _showAll = !_showAll;
            });
          },
          child: Text(
            _showAll ? 'Show Less' : 'View All',
            style: tt.labelMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        Icon(Icons.chevron_right_rounded, color: cs.primary, size: 19),
      ],
    );
  }

  // ============================================================
  // MY BADGES
  // ============================================================

  Widget _badgesPanel() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    const badges = [
      // 12 Earned Badges
      (
        title: 'Nature Explorer',
        description: 'Awarded for exploring and documenting biodiversity.',
        icon: Icons.explore_rounded,
        earnedAt: 'January 2026',
      ),
      (
        title: 'Mountain Tracker',
        description: 'Awarded for documenting species in mountain habitats.',
        icon: Icons.landscape_rounded,
        earnedAt: 'January 2026',
      ),
      (
        title: 'Forest Guardian',
        description: 'Awarded for observing biodiversity in forests.',
        icon: Icons.forest_rounded,
        earnedAt: 'February 2026',
      ),
      (
        title: 'Flora Explorer',
        description: 'Awarded for identifying different plant species.',
        icon: Icons.local_florist_rounded,
        earnedAt: 'February 2026',
      ),
      (
        title: 'Wildlife Tracker',
        description: 'Awarded for documenting different animal species.',
        icon: Icons.pets_rounded,
        earnedAt: 'March 2026',
      ),
      (
        title: 'Fungi Finder',
        description: 'Awarded for discovering and documenting fungi.',
        icon: Icons.park_rounded,
        earnedAt: 'March 2026',
      ),
      (
        title: 'Bird Watcher',
        description: 'Awarded for observing and identifying bird species.',
        icon: Icons.flutter_dash_rounded,
        earnedAt: 'April 2026',
      ),
      (
        title: 'Insect Observer',
        description: 'Awarded for documenting different insect species.',
        icon: Icons.bug_report_rounded,
        earnedAt: 'April 2026',
      ),
      (
        title: 'Nature Photographer',
        description: 'Awarded for contributing quality observation photos.',
        icon: Icons.camera_alt_rounded,
        earnedAt: 'May 2026',
      ),
      (
        title: 'Habitat Discoverer',
        description: 'Awarded for exploring different natural habitats.',
        icon: Icons.public_rounded,
        earnedAt: 'May 2026',
      ),
      (
        title: 'Species Collector',
        description: 'Awarded for documenting a variety of species.',
        icon: Icons.collections_bookmark_rounded,
        earnedAt: 'June 2026',
      ),
      (
        title: 'Biodiversity Champion',
        description: 'Awarded for outstanding biodiversity contributions.',
        icon: Icons.military_tech_rounded,
        earnedAt: 'June 2026',
      ),

      // 8 Locked Badges
      (
        title: 'Ocean Explorer',
        description: 'Discover and document marine biodiversity.',
        icon: Icons.waves_rounded,
        earnedAt: null,
      ),
      (
        title: 'Wildflower Keeper',
        description: 'Identify different wildflower species.',
        icon: Icons.filter_vintage_rounded,
        earnedAt: null,
      ),
      (
        title: 'Mushroom Specialist',
        description: 'Discover and identify more fungi species.',
        icon: Icons.eco_rounded,
        earnedAt: null,
      ),
      (
        title: 'Butterfly Hunter',
        description: 'Observe and document butterfly species.',
        icon: Icons.air_rounded,
        earnedAt: null,
      ),
      (
        title: 'River Guardian',
        description: 'Explore biodiversity around freshwater habitats.',
        icon: Icons.water_rounded,
        earnedAt: null,
      ),
      (
        title: 'Rare Species Finder',
        description: 'Discover and document rare species.',
        icon: Icons.search_rounded,
        earnedAt: null,
      ),
      (
        title: 'Ecosystem Researcher',
        description: 'Contribute observations to biodiversity research.',
        icon: Icons.biotech_rounded,
        earnedAt: null,
      ),
      (
        title: 'Nature Ambassador',
        description: 'Become an active contributor to nature conservation.',
        icon: Icons.workspace_premium_rounded,
        earnedAt: null,
      ),
    ];
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: const BorderRadius.all(WsRadius.lg),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Your Badges',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              RichText(
                text: TextSpan(
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  children: [
                    TextSpan(
                      text: '12',
                      style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const TextSpan(text: ' of 20 badges earned'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: badges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.00,
            ),
            itemBuilder: (context, index) {
              final badge = badges[index];
              final isEarned = badge.earnedAt != null;

              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.wsBrand.forest.withAlpha(18),
                  borderRadius: const BorderRadius.all(WsRadius.md),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      badge.icon,
                      color: isEarned ? cs.primary : cs.onSurfaceVariant,
                      size: 35,
                    ),
                    const SizedBox(height: 8),

                    Text(
                      badge.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (isEarned) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primary.withAlpha(30),
                          borderRadius: const BorderRadius.all(WsRadius.pill),
                        ),
                        child: Text(
                          'Earned',
                          style: tt.labelMedium?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        badge.earnedAt!,
                        textAlign: TextAlign.center,
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.lock_rounded,
                        color: cs.onSurfaceVariant,
                        size: 20,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Locked',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// RECOMMENDED MISSION DATA
// ============================================================
class _MissionItem {
  const _MissionItem({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}
// ============================================================
// RECOMMENDED MISSION CARD
// ============================================================

class _RecommendedMissionCard extends StatelessWidget {
  const _RecommendedMissionCard({required this.mission});

  final _MissionItem mission;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: const BorderRadius.all(WsRadius.lg),
        border: Border.all(color: cs.outlineVariant.withAlpha(100)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Mission Icon
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: context.wsBrand.forest.withAlpha(18),
              borderRadius: const BorderRadius.all(WsRadius.md),
            ),
            child: Icon(mission.icon, color: cs.primary, size: 38),
          ),

          const SizedBox(width: 12),

          // Mission Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  mission.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Start Mission Button
          FilledButton(
            onPressed: () => _showMissionDetails(context, mission),
            style: FilledButton.styleFrom(
              backgroundColor: cs.primaryContainer,
              foregroundColor: cs.onPrimaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(WsRadius.pill),
              ),
              minimumSize: const Size(0, 42),
              tapTargetSize: MaterialTapTargetSize.padded,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Start Mission',
                  style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 3),
                const Icon(Icons.chevron_right_rounded, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMissionDetails(BuildContext context, _MissionItem mission) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: cs.surface,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: context.wsBrand.forest.withAlpha(18),
                      borderRadius: const BorderRadius.all(WsRadius.lg),
                    ),
                    child: Icon(mission.icon, color: cs.primary, size: 46),
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  mission.title,
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),

                const SizedBox(height: 8),

                Text(
                  mission.description,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${mission.title} selected.')),
                      );
                    },
                    child: const Text('Start Mission'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// PROGRESS BAR
// Mengikuti implementasi Home Page.
// ============================================================

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress, this.trackColor, this.fillColor});

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
