import 'package:flutter/material.dart';

import '../core/app_theme.dart';

// ═══════════════════════════════════════════════════════════════════
//  DISCOVERY CARD — kartu reusable (Home "Nearby", Profile "My Journal", dst.)
//
//  Ukuran kartu (lebar/tinggi) ditentukan oleh PARENT (SizedBox, grid cell,
//  dll.). Kepadatan isi (radius, font, padding) diatur lewat
//  [DiscoveryCardSize]. Foto otomatis mengisi sisa tinggi kartu; bila parent
//  tidak punya tinggi pasti (mis. di ListView), isi [imageAspectRatio].
// ═══════════════════════════════════════════════════════════════════

// Warna Fungi (cokelat, palet Bark) — satu-satunya warna kategori tanpa
// padanan di ColorScheme / WsBrandColors.
const _kChipFungi = Color(0xFF7A5C3E);

/// Warna chip untuk sebuah kategori:
/// Flora → hijau (primary), Fauna → oranye (brand.amber), Fungi → cokelat.
/// Kategori tidak dikenal memakai primary.
Color discoveryCategoryColor(
  String category,
  ColorScheme cs,
  WsBrandColors brand,
) {
  switch (category.toLowerCase()) {
    case 'fauna':
      return brand.amber;
    case 'fungi':
      return _kChipFungi;
    case 'flora':
    default:
      return cs.primary;
  }
}

/// Ikon kecil untuk chip kategori (dipakai bila `showCategoryIcon: true`).
IconData discoveryCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'fungi':
      return Icons.spa_outlined;
    case 'flora':
      return Icons.eco_outlined;
    default:
      return Icons.pets_outlined;
  }
}

/// Preset kepadatan kartu.
///
/// * [regular] — persis tampilan awal Nearby Discoveries di Home.
/// * [compact] — versi lebih kecil untuk grid 2 kolom (My Journal).
enum DiscoveryCardSize {
  regular(
    radius: WsRadius.xl,
    inset: 8,
    chipPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    chipFont: 11,
    footerPadding: EdgeInsets.fromLTRB(10, 10, 10, 12),
    titleFont: 14,
    metaFont: 11,
    metaIcon: 11,
    avatarRadius: 11,
    labelFont: 11,
    labelIcon: 13,
  ),
  compact(
    radius: WsRadius.lg,
    inset: 8,
    chipPadding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    chipFont: 10,
    footerPadding: EdgeInsets.fromLTRB(12, 10, 12, 12),
    titleFont: 14,
    metaFont: 12,
    metaIcon: 14,
    avatarRadius: 10,
    labelFont: 10,
    labelIcon: 12,
  );

  const DiscoveryCardSize({
    required this.radius,
    required this.inset,
    required this.chipPadding,
    required this.chipFont,
    required this.footerPadding,
    required this.titleFont,
    required this.metaFont,
    required this.metaIcon,
    required this.avatarRadius,
    required this.labelFont,
    required this.labelIcon,
  });

  final Radius radius;
  final double inset;
  final EdgeInsets chipPadding;
  final double chipFont;
  final EdgeInsets footerPadding;
  final double titleFont;
  final double metaFont;
  final double metaIcon;
  final double avatarRadius;
  final double labelFont;
  final double labelIcon;
}

/// Posisi chip kategori di atas foto.
enum DiscoveryChipPosition { topLeft, topRight }

/// Baris penulis (avatar + nama + waktu) — dipakai di Home.
@immutable
class DiscoveryAuthor {
  const DiscoveryAuthor({
    required this.avatarUrl,
    required this.name,
    required this.timeAgo,
  });

  final String avatarUrl;
  final String name;
  final String timeAgo;
}

/// Satu baris detail (ikon + teks) — dipakai di My Journal (tanggal, lokasi).
@immutable
class DiscoveryDetail {
  const DiscoveryDetail({required this.icon, required this.text});

  final IconData icon;
  final String text;
}

class DiscoveryCard extends StatelessWidget {
  const DiscoveryCard({
    super.key,
    required this.category,
    required this.imageUrl,
    required this.title,
    this.imageLabel,
    this.author,
    this.details = const [],
    this.size = DiscoveryCardSize.regular,
    this.chipPosition = DiscoveryChipPosition.topLeft,
    this.showCategoryIcon = false,
    this.imageAspectRatio,
    this.onTap,
  });

  /// 'Fauna' | 'Flora' | 'Fungi' — menentukan warna chip.
  final String category;
  final String imageUrl;
  final String title;

  /// Teks di kiri-bawah foto (dengan ikon lokasi), mis. jarak. Bila diisi,
  /// gradient gelap ditambahkan di bawah foto agar teks terbaca.
  final String? imageLabel;

  /// Baris avatar + penulis + waktu di bawah judul.
  final DiscoveryAuthor? author;

  /// Baris ikon + teks di bawah judul (tanggal, lokasi, dst.).
  final List<DiscoveryDetail> details;

  final DiscoveryCardSize size;
  final DiscoveryChipPosition chipPosition;
  final bool showCategoryIcon;

  /// Null → foto mengisi sisa tinggi kartu (parent harus punya tinggi pasti).
  /// Diisi → foto memakai rasio ini dan kartu menyesuaikan tinggi isinya.
  final double? imageAspectRatio;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final m = size;
    final chip = discoveryCategoryColor(category, cs, context.wsBrand);
    final onImage = cs.surfaceContainerLowest; // putih, teks di atas foto

    // ── foto + overlay
    final photo = Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => Container(
            color: cs.surfaceContainer,
            child: Icon(Icons.image_not_supported_outlined, color: cs.outline),
          ),
        ),
        if (imageLabel != null)
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.45, 1.0],
                colors: [Colors.transparent, cs.shadow.withAlpha(180)],
              ),
            ),
          ),
        // chip kategori
        Positioned(
          top: m.inset,
          left: chipPosition == DiscoveryChipPosition.topLeft ? m.inset : null,
          right:
              chipPosition == DiscoveryChipPosition.topRight ? m.inset : null,
          child: Container(
            padding: m.chipPadding,
            decoration: BoxDecoration(
              color: chip.withAlpha(200),
              borderRadius: const BorderRadius.all(WsRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showCategoryIcon) ...[
                  Icon(discoveryCategoryIcon(category),
                      size: m.chipFont + 2, color: onImage),
                  const SizedBox(width: 4),
                ],
                Text(category,
                    style: tt.labelMedium!.copyWith(
                        fontSize: m.chipFont,
                        color: onImage,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
        // label kiri-bawah (mis. jarak)
        if (imageLabel != null)
          Positioned(
            bottom: m.inset,
            left: m.inset,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, color: onImage, size: m.labelIcon),
                const SizedBox(width: 3),
                Text(imageLabel!,
                    style: tt.labelMedium!.copyWith(
                        fontSize: m.labelFont,
                        color: onImage,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
      ],
    );

    final hasBoundedPhoto = imageAspectRatio != null;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.all(m.radius),
        boxShadow: WsShadow.card(context),
      ),
      clipBehavior: Clip.antiAlias, // foto ikut terpotong sudut kartu
      child: Stack(
        children: [
          Column(
            mainAxisSize: hasBoundedPhoto ? MainAxisSize.min : MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasBoundedPhoto)
                AspectRatio(aspectRatio: imageAspectRatio!, child: photo)
              else
                Expanded(child: photo),

              // ── teks di dalam kartu
              Padding(
                padding: m.footerPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: tt.titleLarge!.copyWith(
                          fontSize: m.titleFont,
                          color: cs.onSurface,
                          fontWeight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (author != null) ...[
                      const SizedBox(height: 6),
                      _AuthorRow(author: author!, size: m),
                    ],
                    for (final d in details) ...[
                      const SizedBox(height: 6),
                      _DetailRow(detail: d, size: m),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Ink di atas konten supaya ripple tidak tertutup foto.
          if (onTap != null)
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(onTap: onTap),
              ),
            ),
        ],
      ),
    );
  }
}

class _AuthorRow extends StatelessWidget {
  const _AuthorRow({required this.author, required this.size});

  final DiscoveryAuthor author;
  final DiscoveryCardSize size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        CircleAvatar(
          radius: size.avatarRadius,
          backgroundColor: cs.surfaceContainer,
          backgroundImage: NetworkImage(author.avatarUrl),
          onBackgroundImageError: (error, stack) {},
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(author.name,
              style: tt.labelMedium!.copyWith(
                  fontSize: size.metaFont,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 4),
        Icon(Icons.access_time_rounded, size: size.metaIcon, color: cs.outline),
        const SizedBox(width: 3),
        Text(author.timeAgo,
            style: tt.labelMedium!.copyWith(
                fontSize: size.metaFont,
                color: cs.outline,
                fontWeight: FontWeight.w400)),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.detail, required this.size});

  final DiscoveryDetail detail;
  final DiscoveryCardSize size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(detail.icon, size: size.metaIcon, color: cs.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(detail.text,
              style: tt.labelMedium!.copyWith(
                  fontSize: size.metaFont,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}