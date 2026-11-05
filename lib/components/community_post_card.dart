import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/community_post.dart';
import 'post_interaction_bar.dart';
import 'discovery_card.dart';

/// User-Agent yang diminta Wikimedia saat gambar Commons dimuat.
const _kCommonsHeaders = {
  'User-Agent': 'WildSpot/1.0 (educational; SDG 15 species observation)',
};

/// Satu kartu observasi di feed komunitas.
class CommunityPostCard extends StatelessWidget {
  const CommunityPostCard({
    super.key,
    required this.post,
    this.onConfirmId,
    this.onFieldNotes,
    this.onReport,
    this.onAuthorTap,
  });

  final CommunityPost post;
  final VoidCallback? onConfirmId;
  final VoidCallback? onFieldNotes;
  final VoidCallback? onReport;
  final VoidCallback? onAuthorTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AuthorRow(post: post, onAuthorTap: onAuthorTap),
          const SizedBox(height: 10),
          Text(post.body, style: bodyStyle),
          if (post.imageUrl != null) ...[
            const SizedBox(height: 12),
            _ObservationImage(url: post.imageUrl!),
          ],
          const SizedBox(height: 4),
          PostInteractionBar(
            confirmCount: post.confirmCount,
            fieldNoteCount: post.fieldNoteCount,
            isConfirmed: post.isConfirmed,
            isReported: post.isReported,
            onConfirmId: onConfirmId,
            onFieldNotes: onFieldNotes,
            onReport: onReport,
          ),
        ],
      ),
    );
  }
}

class _AuthorRow extends StatelessWidget {
  const _AuthorRow({required this.post, this.onAuthorTap});

  final CommunityPost post;
  final VoidCallback? onAuthorTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onAuthorTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NetworkAvatar(url: post.authorAvatarUrl, size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.authorName,
                  style: text.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${post.timeAgo} · ${post.locationLabel}',
                  style: text.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (post.isLocationObscured) ...[
                  const SizedBox(height: 2),
                  Text('Location obscured', style: text.bodySmall),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          DiscoveryCategoryBadge(category: post.category.label),
        ],
      ),
    );
  }
}

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

class _ObservationImage extends StatelessWidget {
  const _ObservationImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cacheWidth =
        (MediaQuery.sizeOf(context).width *
                MediaQuery.devicePixelRatioOf(context))
            .toInt();

    return ClipRRect(
      borderRadius: const BorderRadius.all(WsRadius.md),
      child: AspectRatio(
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
      ),
    );
  }
}
