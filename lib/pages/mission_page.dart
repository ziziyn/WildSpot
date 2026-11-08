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

  // Batas misi aktif agar pengguna tetap fokus.
  static const int _maxActiveMissions = 3;

  // Active Missions. Misi pertama mengikuti Home Page.
  // Data sementara sampai tersedia integrasi API missions.
  // Daftar ini bisa berisi lebih dari satu misi aktif.
  static const List<_ActiveMission> _initialActiveMissions = [
    _ActiveMission(
      title: 'Native Pollinator Census',
      description:
          'Identify 5 different pollinator species in your local area.',
      completed: 3,
      target: 5,
      rewardBadge: 'Ecosystem Researcher',
      streaking: true,
    ),
    _ActiveMission(
      title: 'Fungi Foray',
      description: 'Find and document 4 different fungi species.',
      completed: 1,
      target: 4,
      rewardBadge: 'Mushroom Specialist',
    ),
    _ActiveMission(
      title: 'Marine Life Survey',
      description: 'Find and document 5 different marine species.',
      completed: 1,
      target: 5,
      rewardBadge: 'Ocean Explorer',
    ),
  ];

  // Salinan yang bisa berubah, misalnya saat misi dilepas (Abandon).
  final List<_ActiveMission> _activeMissions = List.of(_initialActiveMissions);

  // Recommended Missions.
  // Data sementara sampai tersedia integrasi API missions.
  static const List<_MissionItem> _recommendedMissions = [
    _MissionItem(
      title: 'Butterfly Explorer',
      description: 'Find and observe 5 different butterfly species.',
      icon: Icons.flutter_dash,
      rewardBadge: 'Butterfly Hunter',
    ),
    _MissionItem(
      title: 'Wildflower Watch',
      description: 'Find and observe 5 wildflower species.',
      icon: Icons.local_florist_outlined,
      rewardBadge: 'Wildflower Keeper',
    ),
    _MissionItem(
      title: 'Forest Guardian',
      description: 'Identify 10 different tree species.',
      icon: Icons.forest_outlined,
      rewardBadge: 'Nature Ambassador',
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
                child: _showBadges ? _badgesPanel() : _activeMissionsSection(),
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
                      limitReached:
                          _activeMissions.length >= _maxActiveMissions,
                      maxActive: _maxActiveMissions,
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
  // ACTIVE MISSIONS
  // Mendukung satu atau lebih misi aktif.
  // Desain tiap kartu mengikuti _ActiveMissionCard Home Page.
  // ============================================================

  Widget _activeMissionsSection() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Belum ada misi aktif.
    if (_activeMissions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: const BorderRadius.all(WsRadius.lg),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Text(
          'No active missions yet. Start one from the Recommended list below.',
          textAlign: TextAlign.center,
          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Jumlah misi aktif ditampilkan jika lebih dari satu.
        if (_activeMissions.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 2),
            child: Text(
              '${_activeMissions.length} of $_maxActiveMissions active missions',
              style: tt.labelMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        // Misi pertama memakai kartu penuh (sama dengan Home Page).
        _activeMission(_activeMissions.first),

        // Misi lainnya ditampilkan ringkas agar halaman tidak terlalu panjang.
        for (int i = 1; i < _activeMissions.length; i++) ...[
          const SizedBox(height: 10),
          _compactMission(_activeMissions[i]),
        ],
      ],
    );
  }

  // ============================================================
  // COMPACT ACTIVE MISSION
  // Baris ringkas untuk misi aktif kedua dan seterusnya.
  // Ketuk untuk membuka detail misi.
  // ============================================================

  Widget _compactMission(_ActiveMission mission) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label:
          '${mission.title}, ${mission.completed} of ${mission.target} completed',
      child: Material(
        color: cs.primary,
        borderRadius: const BorderRadius.all(WsRadius.lg),
        child: InkWell(
          borderRadius: const BorderRadius.all(WsRadius.lg),
          onTap: () => _showMissionDetails(mission),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.titleSmall?.copyWith(
                          color: cs.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _ProgressBar(
                              progress: mission.progress,
                              trackColor: cs.onPrimary.withAlpha(40),
                              fillColor: cs.onPrimary.withAlpha(230),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${mission.completed}/${mission.target}',
                            style: context.wsMono.stat.copyWith(
                              fontSize: 12,
                              color: cs.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                Icon(
                  Icons.chevron_right_rounded,
                  color: cs.onPrimary.withAlpha(200),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _activeMission(_ActiveMission mission) {
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
              if (mission.streaking)
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
            mission.title,
            style: tt.titleLarge!.copyWith(
              fontSize: 18,
              color: cs.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            mission.description,
            style: tt.bodyMedium!.copyWith(
              fontSize: 13,
              color: cs.onPrimary.withAlpha(200),
            ),
          ),

          const SizedBox(height: 10),

          // Badge yang akan didapat dari misi ini
          _RewardChip(
            badge: mission.rewardBadge,
            foreground: cs.onPrimary,
            background: cs.onPrimary.withAlpha(30),
            border: cs.onPrimary.withAlpha(60),
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
                '${mission.completed}/${mission.target} (${mission.percent}%)',
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
            progress: mission.progress,
            trackColor: cs.onPrimary.withAlpha(40),
            fillColor: cs.onPrimary.withAlpha(230),
          ),

          const SizedBox(height: 16),

          // CTA button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _showMissionDetails(mission),
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

  void _showMissionDetails(_ActiveMission mission) {
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
                  mission.title,
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  mission.description,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                _RewardChip(
                  badge: mission.rewardBadge,
                  foreground: cs.primary,
                  background: cs.primary.withAlpha(24),
                  border: cs.primary.withAlpha(60),
                ),
                const SizedBox(height: 16),
                Text('Mission Progress', style: tt.titleSmall),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: mission.progress,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(20),
                ),
                const SizedBox(height: 8),
                Text(
                  '${mission.completed} of ${mission.target} observations completed (${mission.percent}%)',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),

                // Jalan keluar jika pengguna tidak ingin melanjutkan misi.
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _confirmAbandon(mission);
                    },
                    style: TextButton.styleFrom(foregroundColor: cs.error),
                    child: const Text('Abandon Mission'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // ABANDON MISSION
  // Dialog konfirmasi sebelum misi dilepas.
  // ============================================================

  Future<void> _confirmAbandon(_ActiveMission mission) async {
    final cs = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Leave this mission?'),
          content: Text('Your progress in "${mission.title}" will be lost.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: cs.error,
                foregroundColor: cs.onError,
              ),
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _activeMissions.remove(mission);
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${mission.title} removed.')));
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

    const List<_BadgeItem> badges = [
      // 12 Earned Badges
      _BadgeItem(
        title: 'Nature Explorer',
        description: 'Awarded for exploring and documenting biodiversity.',
        icon: Icons.explore_rounded,
        mission: 'First Steps in Nature',
        earnedAt: 'January 2026',
      ),
      _BadgeItem(
        title: 'Mountain Tracker',
        description: 'Awarded for documenting species in mountain habitats.',
        icon: Icons.landscape_rounded,
        mission: 'Highland Survey',
        earnedAt: 'January 2026',
      ),
      _BadgeItem(
        title: 'Forest Guardian',
        description: 'Awarded for observing biodiversity in forests.',
        icon: Icons.forest_rounded,
        mission: 'Forest Canopy Watch',
        earnedAt: 'February 2026',
      ),
      _BadgeItem(
        title: 'Flora Explorer',
        description: 'Awarded for identifying different plant species.',
        icon: Icons.local_florist_rounded,
        mission: 'Plant ID Challenge',
        earnedAt: 'February 2026',
      ),
      _BadgeItem(
        title: 'Wildlife Tracker',
        description: 'Awarded for documenting different animal species.',
        icon: Icons.pets_rounded,
        mission: 'Backyard Wildlife Log',
        earnedAt: 'March 2026',
      ),
      _BadgeItem(
        title: 'Fungi Finder',
        description: 'Awarded for discovering and documenting fungi.',
        icon: Icons.park_rounded,
        mission: 'Mushroom Trail Walk',
        earnedAt: 'March 2026',
      ),
      _BadgeItem(
        title: 'Bird Watcher',
        description: 'Awarded for observing and identifying bird species.',
        icon: Icons.flutter_dash_rounded,
        mission: 'Dawn Bird Count',
        earnedAt: 'April 2026',
      ),
      _BadgeItem(
        title: 'Insect Observer',
        description: 'Awarded for documenting different insect species.',
        icon: Icons.bug_report_rounded,
        mission: 'Insect Safari',
        earnedAt: 'April 2026',
      ),
      _BadgeItem(
        title: 'Nature Photographer',
        description: 'Awarded for contributing quality observation photos.',
        icon: Icons.camera_alt_rounded,
        mission: 'Photo Observation Week',
        earnedAt: 'May 2026',
      ),
      _BadgeItem(
        title: 'Habitat Discoverer',
        description: 'Awarded for exploring different natural habitats.',
        icon: Icons.public_rounded,
        mission: 'Habitat Hopper',
        earnedAt: 'May 2026',
      ),
      _BadgeItem(
        title: 'Species Collector',
        description: 'Awarded for documenting a variety of species.',
        icon: Icons.collections_bookmark_rounded,
        mission: '50 Species Challenge',
        earnedAt: 'June 2026',
      ),
      _BadgeItem(
        title: 'Biodiversity Champion',
        description: 'Awarded for outstanding biodiversity contributions.',
        icon: Icons.military_tech_rounded,
        mission: 'Biodiversity Month',
        earnedAt: 'June 2026',
      ),

      // 8 Locked Badges
      // Urutan: misi aktif, misi rekomendasi, lalu misi coming soon
      _BadgeItem(
        title: 'Ecosystem Researcher',
        description: 'Contribute observations to biodiversity research.',
        icon: Icons.biotech_rounded,
        mission: 'Native Pollinator Census',
        earnedAt: null,
      ),
      _BadgeItem(
        title: 'Mushroom Specialist',
        description: 'Discover and identify more fungi species.',
        icon: Icons.eco_rounded,
        mission: 'Fungi Foray',
        earnedAt: null,
      ),
      _BadgeItem(
        title: 'Ocean Explorer',
        description: 'Discover and document marine biodiversity.',
        icon: Icons.waves_rounded,
        mission: 'Marine Life Survey',
        earnedAt: null,
      ),
      _BadgeItem(
        title: 'Butterfly Hunter',
        description: 'Observe and document butterfly species.',
        icon: Icons.air_rounded,
        mission: 'Butterfly Explorer',
        earnedAt: null,
      ),
      _BadgeItem(
        title: 'Wildflower Keeper',
        description: 'Identify different wildflower species.',
        icon: Icons.filter_vintage_rounded,
        mission: 'Wildflower Watch',
        earnedAt: null,
      ),
      _BadgeItem(
        title: 'Nature Ambassador',
        description: 'Become an active contributor to nature conservation.',
        icon: Icons.workspace_premium_rounded,
        mission: 'Forest Guardian',
        earnedAt: null,
      ),
      _BadgeItem(
        title: 'River Guardian',
        description: 'Explore biodiversity around freshwater habitats.',
        icon: Icons.water_rounded,
        mission: null,
        earnedAt: null,
      ),
      _BadgeItem(
        title: 'Rare Species Finder',
        description: 'Discover and document rare species.',
        icon: Icons.search_rounded,
        mission: null,
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
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) => _badgeTile(badges[index]),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BADGE TILE
  // Earned: warna penuh + centang + tanggal.
  // Locked: warna redup + gembok + misi yang harus diselesaikan.
  // ============================================================

  Widget _badgeTile(_BadgeItem badge) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isEarned = badge.earnedAt != null;

    final missionText = isEarned
        ? 'From: ${badge.mission}'
        : (badge.mission != null
              ? 'Complete: ${badge.mission}'
              : 'Mission coming soon');

    return Semantics(
      button: true,
      label:
          '${badge.title}, ${isEarned ? 'earned ${badge.earnedAt}' : 'locked'}',
      child: InkWell(
        borderRadius: const BorderRadius.all(WsRadius.md),
        onTap: () => _showBadgeDetails(badge),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isEarned
                ? cs.primary.withAlpha(24)
                : cs.surfaceContainerHighest.withAlpha(110),
            borderRadius: const BorderRadius.all(WsRadius.md),
            border: Border.all(
              color: isEarned ? cs.primary.withAlpha(150) : cs.outlineVariant,
              width: isEarned ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _BadgeIcon(icon: badge.icon, earned: isEarned, size: 52),
              const SizedBox(height: 8),

              Text(
                badge.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isEarned ? cs.onSurface : cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),

              _BadgeStatusPill(earned: isEarned),
              const SizedBox(height: 5),

              if (isEarned)
                Text(
                  badge.earnedAt!,
                  textAlign: TextAlign.center,
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),

              // Hubungan badge dengan misi
              Text(
                missionText,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.labelSmall?.copyWith(
                  fontSize: 10.5,
                  color: isEarned
                      ? cs.primary
                      : cs.onSurfaceVariant.withAlpha(200),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BADGE DETAILS
  // Menjelaskan badge didapat dari misi mana.
  // ============================================================

  void _showBadgeDetails(_BadgeItem badge) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isEarned = badge.earnedAt != null;

    // Jika misi penghubung sedang aktif, tampilkan progresnya.
    _ActiveMission? active;
    for (final m in _activeMissions) {
      if (m.title == badge.mission) active = m;
    }

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
                  child: _BadgeIcon(
                    icon: badge.icon,
                    earned: isEarned,
                    size: 84,
                  ),
                ),
                const SizedBox(height: 14),
                Center(child: _BadgeStatusPill(earned: isEarned)),
                const SizedBox(height: 14),
                Text(
                  badge.title,
                  style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  badge.description,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 16),

                // Relasi Badge - Mission
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: const BorderRadius.all(WsRadius.md),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEarned
                            ? 'Earned from mission'
                            : 'Unlocked by mission',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.flag_rounded, color: cs.primary, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              badge.mission ?? 'Mission coming soon',
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isEarned) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Completed in ${badge.earnedAt}',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ] else if (active != null) ...[
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: active.progress,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${active.completed} of ${active.target} observations completed (${active.percent}%)',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
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
// ACTIVE MISSION DATA
// ============================================================
class _ActiveMission {
  const _ActiveMission({
    required this.title,
    required this.description,
    required this.completed,
    required this.target,
    required this.rewardBadge,
    this.streaking = false,
  });

  final String title;
  final String description;
  final int completed;
  final int target;
  final String rewardBadge;
  final bool streaking;

  double get progress => target == 0 ? 0 : completed / target;
  int get percent => (progress * 100).round();
}

// ============================================================
// BADGE DATA
// mission = misi yang memberikan badge ini (null jika belum tersedia).
// ============================================================
class _BadgeItem {
  const _BadgeItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.mission,
    required this.earnedAt,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? mission;
  final String? earnedAt;
}

// ============================================================
// BADGE ICON
// Earned: lingkaran berwarna.
// Locked: lingkaran abu-abu.
// ============================================================
class _BadgeIcon extends StatelessWidget {
  const _BadgeIcon({
    required this.icon,
    required this.earned,
    required this.size,
  });

  final IconData icon;
  final bool earned;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: earned ? cs.primary : cs.outlineVariant.withAlpha(90),
              boxShadow: earned
                  ? [
                      BoxShadow(
                        color: cs.primary.withAlpha(80),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              size: size * 0.52,
              color: earned ? cs.onPrimary : cs.onSurfaceVariant.withAlpha(120),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BADGE STATUS PILL (Earned / Locked)
// ============================================================
class _BadgeStatusPill extends StatelessWidget {
  const _BadgeStatusPill({required this.earned});

  final bool earned;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: earned ? cs.primary : Colors.transparent,
        borderRadius: const BorderRadius.all(WsRadius.pill),
        border: earned ? null : Border.all(color: cs.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            earned ? Icons.check_circle_rounded : Icons.lock_rounded,
            size: 13,
            color: earned ? cs.onPrimary : cs.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            earned ? 'Earned' : 'Locked',
            style: tt.labelMedium?.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: earned ? cs.onPrimary : cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// REWARD CHIP
// Menampilkan badge yang akan didapat dari sebuah misi.
// ============================================================
class _RewardChip extends StatelessWidget {
  const _RewardChip({
    required this.badge,
    required this.foreground,
    required this.background,
    required this.border,
  });

  final String badge;
  final Color foreground;
  final Color background;
  final Color border;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.all(WsRadius.pill),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium_rounded, size: 14, color: foreground),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              '$badge badge',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.labelMedium?.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
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
    required this.rewardBadge,
  });

  final String title;
  final String description;
  final IconData icon;
  final String rewardBadge;
}
// ============================================================
// RECOMMENDED MISSION CARD
// ============================================================

class _RecommendedMissionCard extends StatelessWidget {
  const _RecommendedMissionCard({
    required this.mission,
    required this.limitReached,
    required this.maxActive,
  });

  final _MissionItem mission;
  final bool limitReached;
  final int maxActive;

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

                const SizedBox(height: 8),

                _RewardChip(
                  badge: mission.rewardBadge,
                  foreground: cs.primary,
                  background: cs.primary.withAlpha(24),
                  border: cs.primary.withAlpha(60),
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

                const SizedBox(height: 12),

                _RewardChip(
                  badge: mission.rewardBadge,
                  foreground: cs.primary,
                  background: cs.primary.withAlpha(24),
                  border: cs.primary.withAlpha(60),
                ),

                const SizedBox(height: 18),

                // Pesan jika batas misi aktif sudah tercapai
                if (limitReached) ...[
                  Text(
                    'You already have $maxActive active missions. '
                    'Complete or leave one before starting a new mission.',
                    style: tt.bodySmall?.copyWith(color: cs.error),
                  ),
                  const SizedBox(height: 12),
                ],

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: limitReached
                        ? null
                        : () {
                            Navigator.pop(sheetContext);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${mission.title} selected.'),
                              ),
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
