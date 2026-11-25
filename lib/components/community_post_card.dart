import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/community_post.dart';

// ═══════════════════════════════════════════════════════════════════════════
// CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════

/// Wikimedia Commons user-agent required when loading images.
const _kCommonsHeaders = {
  'User-Agent': 'WildSpot/1.0 (educational; SDG 15 species observation)',
};

/// Duration of the bounce (scale) micro-interaction on Like tap.
const _kBounceMs = Duration(milliseconds: 180);

/// Report option list – ordered per UX spec.
const _kReportOptions = [
  'Harassment or hate speech',
  'Promotes environmental harm',
  'Fake or stolen photo',
  'Spam or irrelevant content',
  'Something else',
];

// ═══════════════════════════════════════════════════════════════════════════
// MOCK COMMENT DATA (until backend is wired)
// ═══════════════════════════════════════════════════════════════════════════

class _MockComment {
  const _MockComment({
    required this.author,
    required this.body,
    required this.timeAgo,
  });
  final String author;
  final String body;
  final String timeAgo;
}

/// Per-post mock comment lists.
///
/// Each entry's list length **must equal** the corresponding post's
/// `commentCount` in the mock repository — this is the single source of
/// truth that keeps the card counter and the bottom-sheet list in sync.
const _kPostComments = <String, List<_MockComment>>{
  // ── Following feed ──────────────────────────────────────────────────────

  // f1 → commentCount: 7
  'f1': [
    _MockComment(author: 'Raka M.', body: 'The leaf pattern matches perfectly. Definitely Pongo abelii.', timeAgo: '1h'),
    _MockComment(author: 'Sari W.', body: 'I spotted one near the same canopy trail last week.', timeAgo: '55m'),
    _MockComment(author: 'Dimas P.', body: 'Incredible shot — the infant grip is so clear.', timeAgo: '50m'),
    _MockComment(author: 'Ayu L.', body: 'The facial disc confirms adult female. Great documentation.', timeAgo: '45m'),
    _MockComment(author: 'Farhan Y.', body: 'Please submit to the Leuser monitoring programme!', timeAgo: '40m'),
    _MockComment(author: 'Melati K.', body: 'Which trail was this near? I am doing a transect next week.', timeAgo: '30m'),
    _MockComment(author: 'Budi S.', body: 'Tagged for the IUCN SSC database — thank you for sharing.', timeAgo: '15m'),
  ],

  // f2 → commentCount: 6
  'f2': [
    _MockComment(author: 'Intan P.', body: 'The petal count and lobing match Rafflesia arnoldii perfectly.', timeAgo: '4h'),
    _MockComment(author: 'Yoga S.', body: 'How large was the bloom? The Batang Palupuh record is 107 cm.', timeAgo: '3h'),
    _MockComment(author: 'Citra D.', body: 'Please alert the ranger station so they can rope off the area.', timeAgo: '2h'),
    _MockComment(author: 'Raka M.', body: 'The haustorial network on the host vine is visible — nice!', timeAgo: '1h'),
    _MockComment(author: 'Sari W.', body: 'I will try to visit before it closes. How many days left?', timeAgo: '45m'),
    _MockComment(author: 'Farhan Y.', body: 'Confirmed ID — adding to the Sumatera flora watch list.', timeAgo: '20m'),
  ],

  // f3 → commentCount: 3
  'f3': [
    _MockComment(author: 'Dimas P.', body: 'Cookeina speciosa is my favourite forest cup fungus!', timeAgo: '22h'),
    _MockComment(author: 'Melati K.', body: 'The scarlet colour is so vivid — good substrate choice for the photo.', timeAgo: '18h'),
    _MockComment(author: 'Ayu L.', body: 'Leaving dead wood in situ is exactly the right call.', timeAgo: '10h'),
  ],

  // f4 → commentCount: 2
  'f4': [
    _MockComment(author: 'Budi S.', body: 'That pale underside is diagnostic for Presbytis thomasi. Confirmed!', timeAgo: '5h'),
    _MockComment(author: 'Intan P.', body: 'The Bukit Lawang forest edge is a reliable spot for kedih.', timeAgo: '3h'),
  ],

  // f5 → commentCount: 14
  'f5': [
    _MockComment(author: 'Sari W.', body: 'Yes! My transect numbers dropped 40 % this season near Besitang.', timeAgo: '2h 50m'),
    _MockComment(author: 'Raka M.', body: 'Could be linked to the new road clearing south of the buffer zone.', timeAgo: '2h 40m'),
    _MockComment(author: 'Dimas P.', body: 'Helmeted hornbill or other species? The trend differs by species.', timeAgo: '2h 30m'),
    _MockComment(author: 'Ayu L.', body: 'I recorded five species in January; only two in October.', timeAgo: '2h 20m'),
    _MockComment(author: 'Farhan Y.', body: 'Worth cross-referencing with the eBird data for the same corridor.', timeAgo: '2h 10m'),
    _MockComment(author: 'Melati K.', body: 'The fruit crop failure this year may also be a factor.', timeAgo: '2h'),
    _MockComment(author: 'Yoga S.', body: 'Have you reported this to the BBTNGL monitoring team?', timeAgo: '1h 50m'),
    _MockComment(author: 'Intan P.', body: 'Same pattern near Way Kambas last season — regional phenomenon?', timeAgo: '1h 40m'),
    _MockComment(author: 'Citra D.', body: 'Hornbill counts tend to follow fruiting cycles. Check phenology data.', timeAgo: '1h 30m'),
    _MockComment(author: 'Budi S.', body: 'I will compile my transect logs and share next week.', timeAgo: '1h 20m'),
    _MockComment(author: 'Sari W.', body: 'Great — a shared dataset would be really valuable.', timeAgo: '1h 10m'),
    _MockComment(author: 'Raka M.', body: 'Is there a WildSpot group for Sumatera bird monitoring?', timeAgo: '1h'),
    _MockComment(author: 'Dimas P.', body: 'Not yet, but this thread is a good reason to start one!', timeAgo: '45m'),
    _MockComment(author: 'Ayu L.', body: 'I will post a proposal for a hornbill watch group this week.', timeAgo: '20m'),
  ],

  // f6 → commentCount: 9
  'f6': [
    _MockComment(author: 'Farhan Y.', body: 'Early morning around 06:00–08:00 is best — lower temp and more activity.', timeAgo: '6h'),
    _MockComment(author: 'Melati K.', body: 'I always go at dawn. The beetles are most active before the heat.', timeAgo: '5h'),
    _MockComment(author: 'Yoga S.', body: 'A polarising filter helps cut the iridescent glare at midday.', timeAgo: '4h'),
    _MockComment(author: 'Intan P.', body: 'Try overcast days — softer light and beetles are still active.', timeAgo: '3h'),
    _MockComment(author: 'Citra D.', body: 'Which family? Buprestidae timings differ from Scarabaeidae.', timeAgo: '2h 30m'),
    _MockComment(author: 'Budi S.', body: 'A macro ring flash removes shadows at any time of day.', timeAgo: '2h'),
    _MockComment(author: 'Sari W.', body: 'I have had great luck at 07:30 near flowering Ficus trees.', timeAgo: '1h 30m'),
    _MockComment(author: 'Raka M.', body: 'Late afternoon works too — the golden light is beautiful.', timeAgo: '1h'),
    _MockComment(author: 'Dimas P.', body: 'Thanks everyone — will try dawn tomorrow!', timeAgo: '30m'),
  ],

  // ── Discovery feed ──────────────────────────────────────────────────────

  // d1 → commentCount: 5
  'd1': [
    _MockComment(author: 'Yoga S.', body: 'Nepenthes sumatrana confirmed — the lid shape is diagnostic.', timeAgo: '55m'),
    _MockComment(author: 'Farhan Y.', body: 'Lowland populations are under severe collection pressure. Good call obscuring.', timeAgo: '50m'),
    _MockComment(author: 'Melati K.', body: 'The peristome colouring looks especially vivid here.', timeAgo: '40m'),
    _MockComment(author: 'Budi S.', body: 'Is this near the Aek Nauli seed bank corridor?', timeAgo: '30m'),
    _MockComment(author: 'Citra D.', body: 'Adding to my Nepenthes watch map — thank you for sharing!', timeAgo: '10m'),
  ],

  // d2 → commentCount: 8
  'd2': [
    _MockComment(author: 'Intan P.', body: 'The dorsal scaling pattern matches adult male. Impressive size!', timeAgo: '2h 50m'),
    _MockComment(author: 'Sari W.', body: 'How far did it travel across the open ground?', timeAgo: '2h 30m'),
    _MockComment(author: 'Raka M.', body: 'Standing still was definitely the right move — great discipline.', timeAgo: '2h'),
    _MockComment(author: 'Dimas P.', body: 'Which zone of the park? Loh Liang or Kampung Komodo?', timeAgo: '1h 40m'),
    _MockComment(author: 'Ayu L.', body: 'The tail position suggests it was actively thermoregulating.', timeAgo: '1h 20m'),
    _MockComment(author: 'Farhan Y.', body: 'Please report to BTNK rangers so they can track the individual.', timeAgo: '1h'),
    _MockComment(author: 'Melati K.', body: 'Sharing without coordinates was the responsible choice here.', timeAgo: '45m'),
    _MockComment(author: 'Yoga S.', body: 'One of the best Komodo observation posts I have seen on WildSpot.', timeAgo: '20m'),
  ],

  // d3 → commentCount: 4
  'd3': [
    _MockComment(author: 'Citra D.', body: 'The secondary flight feathers eye-spots are unmistakable. Confirmed!', timeAgo: '7h'),
    _MockComment(author: 'Budi S.', body: 'Great argus is so rarely photographed on the forest floor. Excellent!', timeAgo: '5h'),
    _MockComment(author: 'Intan P.', body: 'Was it displaying or just foraging? The tail posture matters.', timeAgo: '3h'),
    _MockComment(author: 'Sari W.', body: 'Bukit Lawang seems to be having a great season for pheasants.', timeAgo: '1h'),
  ],

  // d4 → commentCount: 6
  'd4': [
    _MockComment(author: 'Raka M.', body: 'Young males start ranging independently around age 7–8. This looks right.', timeAgo: '11h'),
    _MockComment(author: 'Dimas P.', body: 'The cheek pad development will be fascinating to follow over time.', timeAgo: '10h'),
    _MockComment(author: 'Ayu L.', body: 'No approach is exactly the right protocol — well done.', timeAgo: '8h'),
    _MockComment(author: 'Farhan Y.', body: 'Please note the GPS area even if obscured, for the Leuser database.', timeAgo: '6h'),
    _MockComment(author: 'Melati K.', body: 'The mid-canopy travel route suggests a healthy corridor here.', timeAgo: '4h'),
    _MockComment(author: 'Yoga S.', body: 'Tagged for the PanEco Sumatran orangutan monitoring project.', timeAgo: '2h'),
  ],

  // d5 → commentCount: 11
  'd5': [
    _MockComment(author: 'Citra D.', body: 'Use the IUCN Redlist reporting portal and submit with an obscured 10 km grid cell.', timeAgo: '1h 50m'),
    _MockComment(author: 'Budi S.', body: 'I always inform the nearest ranger post verbally before posting anything.', timeAgo: '1h 40m'),
    _MockComment(author: 'Intan P.', body: 'The WWF-Indonesia team also accepts direct reports via email.', timeAgo: '1h 30m'),
    _MockComment(author: 'Sari W.', body: 'Never post bloom coordinates publicly — collectors monitor these feeds.', timeAgo: '1h 20m'),
    _MockComment(author: 'Raka M.', body: 'The obscured grid system built into WildSpot was designed for exactly this.', timeAgo: '1h 10m'),
    _MockComment(author: 'Dimas P.', body: 'You can also use the Rafflesia Network mailing list for trusted reporting.', timeAgo: '1h'),
    _MockComment(author: 'Ayu L.', body: 'Mark it as sensitive species in the post settings — extra protection layer.', timeAgo: '50m'),
    _MockComment(author: 'Farhan Y.', body: 'Great question — this should be pinned as community guidance.', timeAgo: '40m'),
    _MockComment(author: 'Melati K.', body: 'I support making this a community protocol page.', timeAgo: '30m'),
    _MockComment(author: 'Yoga S.', body: 'The BBKSDA Sumatera Barat office can verify new sites confidentially.', timeAgo: '20m'),
    _MockComment(author: 'Citra D.', body: 'Thank you all — I will follow the grid + ranger protocol.', timeAgo: '5m'),
  ],

  // d6 → commentCount: 23
  'd6': [
    _MockComment(author: 'Budi S.', body: 'Wood anemone (Anemone nemorosa) is my top indicator for ancient woodland.', timeAgo: '4h 50m'),
    _MockComment(author: 'Intan P.', body: 'For Sumatran primary forest I would add Dipterocarpus oblongifolius.', timeAgo: '4h 40m'),
    _MockComment(author: 'Sari W.', body: 'Giant forest fungi like Phlebopus marginatus are strong indicators here.', timeAgo: '4h 30m'),
    _MockComment(author: 'Raka M.', body: 'Rafflesia or Rhizanthes presence almost certainly means primary forest.', timeAgo: '4h 20m'),
    _MockComment(author: 'Dimas P.', body: 'Hornbill presence at fruiting fig trees is a reliable proxy.', timeAgo: '4h 10m'),
    _MockComment(author: 'Ayu L.', body: 'Strangler figs with intact buttress roots suggest undisturbed canopy.', timeAgo: '4h'),
    _MockComment(author: 'Farhan Y.', body: 'The litter layer depth and millipede diversity are good soil indicators.', timeAgo: '3h 50m'),
    _MockComment(author: 'Melati K.', body: 'Pitcher plant density (Nepenthes spp.) is a strong ultramafic forest marker.', timeAgo: '3h 40m'),
    _MockComment(author: 'Yoga S.', body: 'Sun-bear claw marks on large Shorea trees indicate undisturbed territory.', timeAgo: '3h 30m'),
    _MockComment(author: 'Citra D.', body: 'Intact epiphyte communities with Asplenium nidus signal no logging history.', timeAgo: '3h 20m'),
    _MockComment(author: 'Budi S.', body: 'Damar resin tapping scars are a quick proxy for secondary vs primary status.', timeAgo: '3h 10m'),
    _MockComment(author: 'Intan P.', body: 'The presence of Amorphophallus titanum correlates with low disturbance zones.', timeAgo: '3h'),
    _MockComment(author: 'Sari W.', body: 'High lichen cover on bark usually means clean air and old-growth conditions.', timeAgo: '2h 50m'),
    _MockComment(author: 'Raka M.', body: 'Multi-layered canopy with emergents above 50 m is visually diagnostic.', timeAgo: '2h 40m'),
    _MockComment(author: 'Dimas P.', body: 'Primate diversity — especially gibbons + macaques + langurs together — is key.', timeAgo: '2h 30m'),
    _MockComment(author: 'Ayu L.', body: 'Intact riparian ferns along permanent streams indicate low sediment input.', timeAgo: '2h 20m'),
    _MockComment(author: 'Farhan Y.', body: 'Large-diameter standing dead trees (snags) show no salvage logging history.', timeAgo: '2h 10m'),
    _MockComment(author: 'Melati K.', body: 'Fallen log fruiting bodies from Ganoderma are great slow-decay indicators.', timeAgo: '2h'),
    _MockComment(author: 'Yoga S.', body: 'Tiger pugmarks near water sources confirm functional apex predator presence.', timeAgo: '1h 50m'),
    _MockComment(author: 'Citra D.', body: 'What a list — this thread is turning into a field guide!', timeAgo: '1h 30m'),
    _MockComment(author: 'Budi S.', body: 'Should we compile these into a WildSpot checklist document?', timeAgo: '1h 10m'),
    _MockComment(author: 'Intan P.', body: 'Yes! I can format it and post it as a community resource.', timeAgo: '45m'),
    _MockComment(author: 'Sari W.', body: 'Please do — this is exactly the kind of knowledge WildSpot should preserve.', timeAgo: '15m'),
  ],
};

/// Returns the mock comment list for [postId], falling back to an empty list.
/// The list length always equals the post's [CommunityPost.commentCount].
List<_MockComment> _commentsFor(String postId) =>
    _kPostComments[postId] ?? const [];

// ═══════════════════════════════════════════════════════════════════════════
// PUBLIC CARD WIDGET  –  auto-selects variant from post.imageUrl
// ═══════════════════════════════════════════════════════════════════════════

/// Renders an [ObservationCard] when [post.imageUrl] is non-null, otherwise
/// a [DiscussionCard].  Both share the same interaction layer.
class CommunityPostCard extends StatelessWidget {
  const CommunityPostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onAuthorTap,
  });

  final CommunityPost post;

  /// Called when the user likes / unlikes.  Parent owns state.
  final VoidCallback? onLike;
  final VoidCallback? onAuthorTap;

  @override
  Widget build(BuildContext context) {
    if (post.imageUrl != null) {
      return ObservationCard(
        post: post,
        onLike: onLike,
        onAuthorTap: onAuthorTap,
      );
    }
    return DiscussionCard(
      post: post,
      onLike: onLike,
      onAuthorTap: onAuthorTap,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// OBSERVATION CARD  –  photo-centric layout
// ═══════════════════════════════════════════════════════════════════════════

/// A photo-backed sighting post.  Double-tapping the image area triggers Like.
class ObservationCard extends StatefulWidget {
  const ObservationCard({
    super.key,
    required this.post,
    this.onLike,
    this.onAuthorTap,
  });

  final CommunityPost post;
  final VoidCallback? onLike;
  final VoidCallback? onAuthorTap;

  @override
  State<ObservationCard> createState() => _ObservationCardState();
}

class _ObservationCardState extends State<ObservationCard> {
  void _showDiscuss() => _DiscussSheet.show(context, widget.post);
  void _showReport() => _ReportSheet.show(context, widget.post);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // M3 card with margin + elevation for spatial contrast against page bg.
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(WsRadius.md),
      ),
      clipBehavior: Clip.antiAlias,
      color: cs.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Author row ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 4, 0),
            child: _AuthorRow(
              post: widget.post,
              onAuthorTap: widget.onAuthorTap,
              onReportTap: _showReport,
            ),
          ),
          // ── Body text ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Text(widget.post.body, style: text.bodyMedium),
          ),
          // ── Observation image: padded + rounded inside the card ───────
          if (widget.post.imageUrl != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(WsRadius.md),
                child: GestureDetector(
                  onDoubleTap: widget.onLike,
                  child: _ObservationImage(url: widget.post.imageUrl!),
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
          // ── Action bar ────────────────────────────────────────────────
          _PostActionBar(
            isLiked: widget.post.isConfirmed,
            likeCount: widget.post.confirmCount,
            commentCount: widget.post.commentCount,
            onLike: widget.onLike,
            onDiscuss: _showDiscuss,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DISCUSSION CARD  –  text-only layout (no image)
// ═══════════════════════════════════════════════════════════════════════════

/// A text-only community question / field-note post.
class DiscussionCard extends StatefulWidget {
  const DiscussionCard({
    super.key,
    required this.post,
    this.onLike,
    this.onAuthorTap,
  });

  final CommunityPost post;
  final VoidCallback? onLike;
  final VoidCallback? onAuthorTap;

  @override
  State<DiscussionCard> createState() => _DiscussionCardState();
}

class _DiscussionCardState extends State<DiscussionCard> {
  void _showDiscuss() => _DiscussSheet.show(context, widget.post);
  void _showReport() => _ReportSheet.show(context, widget.post);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // M3 card with margin + elevation for spatial contrast against page bg.
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(WsRadius.md),
      ),
      clipBehavior: Clip.antiAlias,
      color: cs.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Author row ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 4, 0),
            child: _AuthorRow(
              post: widget.post,
              onAuthorTap: widget.onAuthorTap,
              onReportTap: _showReport,
            ),
          ),
          // ── Body text (double-tap to like on text cards) ──────────────
          GestureDetector(
            onDoubleTap: widget.onLike,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Text(widget.post.body, style: text.bodyMedium),
            ),
          ),
          // ── Action bar ────────────────────────────────────────────────
          _PostActionBar(
            isLiked: widget.post.isConfirmed,
            likeCount: widget.post.confirmCount,
            commentCount: widget.post.commentCount,
            onLike: widget.onLike,
            onDiscuss: _showDiscuss,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED PRIVATE COMPONENTS
// ═══════════════════════════════════════════════════════════════════════════

// ─── Author row ─────────────────────────────────────────────────────────────

class _AuthorRow extends StatelessWidget {
  const _AuthorRow({
    required this.post,
    required this.onReportTap,
    this.onAuthorTap,
  });

  final CommunityPost post;
  final VoidCallback onReportTap;
  final VoidCallback? onAuthorTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar
        GestureDetector(
          onTap: onAuthorTap,
          child: _NetworkAvatar(url: post.authorAvatarUrl, size: 40),
        ),
        const SizedBox(width: 10),
        // Name + meta
        Expanded(
          child: GestureDetector(
            onTap: onAuthorTap,
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.authorName,
                  style: text.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${post.timeAgo} · ${post.locationLabel}',
                  style: text.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        // ── Kebab menu → PopupMenuButton ──────────────────────────────
        PopupMenuButton<_PostMenuAction>(
          icon: Icon(Icons.more_vert, color: cs.onSurfaceVariant),
          tooltip: 'More options',
          onSelected: (action) {
            if (action == _PostMenuAction.report) onReportTap();
          },
          itemBuilder: (ctx) => [
            PopupMenuItem(
              value: _PostMenuAction.report,
              child: Row(
                children: [
                  Icon(Icons.flag_outlined, size: 20, color: cs.error),
                  const SizedBox(width: 10),
                  Text('Report', style: text.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

enum _PostMenuAction { report }

// ─── Animated Like button ────────────────────────────────────────────────────

/// Icon-only Like button with a bounce (scale) micro-interaction on tap.
/// Shows a small like counter next to the heart icon for social proof.
class _LikeButton extends StatefulWidget {
  const _LikeButton({
    required this.isLiked,
    required this.likeCount,
    this.onLike,
  });
  final bool isLiked;
  final int likeCount;
  final VoidCallback? onLike;

  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _kBounceMs);
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.35)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.35, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_ctrl);
  }

  @override
  void didUpdateWidget(_LikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Fire bounce when an external gesture (double-tap on image/body) triggers
    // Like — fulfills Shneiderman Rule 4: Offer Informative Feedback.
    if (!oldWidget.isLiked && widget.isLiked) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    _ctrl.forward(from: 0);
    widget.onLike?.call();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final liked = widget.isLiked;
    final iconColor = liked ? cs.error : cs.onSurfaceVariant;

    return InkWell(
      onTap: _handleTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Icon(
                liked ? Icons.favorite : Icons.favorite_border,
                size: 22,
                color: iconColor,
              ),
            ),
            if (widget.likeCount > 0) ...[
              const SizedBox(width: 4),
              Text(
                '${widget.likeCount}',
                style: text.labelSmall?.copyWith(color: iconColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Comment button ──────────────────────────────────────────────────────────

/// Icon + counter comment button, symmetric with [_LikeButton].
class _CommentButton extends StatelessWidget {
  const _CommentButton({required this.commentCount, required this.onTap});
  final int commentCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 22,
              color: cs.onSurfaceVariant,
            ),
            if (commentCount > 0) ...[
              const SizedBox(width: 4),
              Text(
                '$commentCount',
                style: text.labelSmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Post action bar ─────────────────────────────────────────────────────────

/// Like + Comment on the left; Share flush to the right.
/// Both interactive elements show counters for social proof (Rule 5).
class _PostActionBar extends StatelessWidget {
  const _PostActionBar({
    required this.isLiked,
    required this.likeCount,
    required this.commentCount,
    required this.onDiscuss,
    this.onLike,
  });

  final bool isLiked;
  final int likeCount;
  final int commentCount;
  final VoidCallback? onLike;
  final VoidCallback onDiscuss;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 4, 4),
      child: Row(
        children: [
          // ── LEFT group: Like + Comment ─────────────────────────────
          _LikeButton(
            isLiked: isLiked,
            likeCount: likeCount,
            onLike: onLike,
          ),
          const SizedBox(width: 4),
          _CommentButton(
            commentCount: commentCount,
            onTap: onDiscuss,
          ),
          // ── SPACER ─────────────────────────────────────────────────
          const Spacer(),
          // ── RIGHT: Share ───────────────────────────────────────────
          IconButton(
            onPressed: () => _onShare(context),
            tooltip: 'Share',
            icon: Icon(Icons.share_outlined, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  void _onShare(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share is not available yet.')),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DISCUSS BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════════

class _DiscussSheet extends StatefulWidget {
  const _DiscussSheet({required this.post});
  final CommunityPost post;

  static void show(BuildContext context, CommunityPost post) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _DiscussSheet(post: post),
    );
  }

  @override
  State<_DiscussSheet> createState() => _DiscussSheetState();
}

class _DiscussSheetState extends State<_DiscussSheet> {
  final _ctrl = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final nowHasText = _ctrl.text.trim().isNotEmpty;
      if (nowHasText != _hasText) setState(() => _hasText = nowHasText);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<bool> _confirmDiscard() async {
    if (!_hasText) return true;
    final keep = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Discard comment?'),
        content: const Text('Your draft will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Keep Editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return keep != true;
  }

  void _send() {
    _ctrl.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // Total comment count: mock list length (until backend is wired).
    final totalComments = widget.post.commentCount;
    final headerTitle = totalComments > 0
        ? 'Comments ($totalComments)'
        : 'Comments';

    return PopScope(
      canPop: !_hasText,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _confirmDiscard();
        if (shouldPop && context.mounted) Navigator.of(context).pop();
      },
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, scrollCtrl) {
          // Single source of truth: list length == post.commentCount.
          final comments = _commentsFor(widget.post.id);
          return Column(
            children: [
              // ── Comment list ───────────────────────────────────────
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  children: [
                    // Header: "Comments (N)" — count matches card counter.
                    Text(headerTitle, style: text.titleMedium),
                    const SizedBox(height: 12),
                    for (final c in comments) ...[
                      _CommentTile(comment: c),
                      const Divider(height: 1),
                    ],
                    if (comments.isEmpty)
                      Center(
                        child: Text(
                          'Be the first to comment.',
                          style: text.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // ── Sticky comment input ───────────────────────────────
              ColoredBox(
                color: cs.surface,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 8,
                    top: 8,
                    bottom: MediaQuery.viewInsetsOf(context).bottom + 8,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          minLines: 1,
                          maxLines: 4,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            hintText: 'Add a comment…',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: _hasText ? _send : null,
                        tooltip: 'Send',
                        icon: const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Comment tile ─────────────────────────────────────────────────────────────

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});
  final _MockComment comment;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: cs.secondaryContainer,
            child: Icon(
              Icons.person_outline,
              size: 18,
              color: cs.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.author,
                      style: text.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      comment.timeAgo,
                      style: text.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.body, style: text.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// REPORT BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════════

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({required this.post});
  final CommunityPost post;

  static void show(BuildContext context, CommunityPost post) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _ReportSheet(post: post),
    );
  }

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  String? _selected;
  final _otherCtrl = TextEditingController();
  bool _otherHasText = false;

  @override
  void initState() {
    super.initState();
    _otherCtrl.addListener(() {
      final has = _otherCtrl.text.trim().isNotEmpty;
      if (has != _otherHasText) setState(() => _otherHasText = has);
    });
  }

  @override
  void dispose() {
    _otherCtrl.dispose();
    super.dispose();
  }

  bool get _isValid {
    if (_selected == null) return false;
    if (_selected == 'Something else') return _otherHasText;
    return true;
  }

  void _submit() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Report submitted. Thank you for helping keep WildSpot safe.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final inset = MediaQuery.viewInsetsOf(context).bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + inset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Report this post', style: text.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Help us keep WildSpot safe and accurate.',
            style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          RadioGroup<String>(
            groupValue: _selected,
            onChanged: (val) => setState(() => _selected = val),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final option in _kReportOptions) ...[
                  RadioListTile<String>(
                    value: option,
                    title: Text(option, style: text.bodyMedium),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                  if (option == 'Something else' &&
                      _selected == 'Something else') ...[
                    const SizedBox(height: 4),
                    TextField(
                      controller: _otherCtrl,
                      maxLength: 200,
                      maxLines: 3,
                      minLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Please describe the issue…',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _isValid ? _submit : null,
            child: const Text('Submit report'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SUPPORTING WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

// ─── Network avatar ──────────────────────────────────────────────────────────

class _NetworkAvatar extends StatelessWidget {
  const _NetworkAvatar({required this.url, required this.size});
  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: cs.surfaceContainerHighest,
      child: ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          cacheWidth: (size * 2).toInt(),
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.person_outline,
            size: size * 0.6,
            color: cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ─── Observation image ───────────────────────────────────────────────────────

class _ObservationImage extends StatelessWidget {
  const _ObservationImage({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cacheWidth = (MediaQuery.sizeOf(context).width *
            MediaQuery.devicePixelRatioOf(context))
        .toInt();

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        headers: _kCommonsHeaders,
        cacheWidth: cacheWidth,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return ColoredBox(color: cs.surfaceContainerHighest);
        },
        errorBuilder: (context, error, stackTrace) => ColoredBox(
          color: cs.surfaceContainerHighest,
          child: Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: cs.onSurfaceVariant,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
