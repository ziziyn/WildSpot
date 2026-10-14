import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import '../core/app_theme.dart';

/// Radius bingkai viewfinder (lebih besar dari token WsRadius).
const double _frameRadius = 48;

/// Permukaan gelap transparan dengan efek blur (glass).
/// Dipakai oleh tombol bulat, pill kategori, dan label indikator.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(WsRadius.pill),
    this.padding,
    this.color,
    this.borderColor,
    this.blur = 12,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: WsShadow.card(context),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? cs.surfaceDim.withAlpha(150),
              borderRadius: borderRadius,
              border: Border.all(
                color: borderColor ?? cs.onSurface.withAlpha(30),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Tombol bulat transparan gelap (Flash, Flip, Focus).
class CircleOverlayButton extends StatelessWidget {
  const CircleOverlayButton({
    super.key,
    required this.icon,
    this.size = 48,
    this.iconSize = 22,
    this.tooltip,
    this.onPressed,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final String? tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final button = GestureDetector(
      onTap: onPressed,
      child: GlassSurface(
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: iconSize, color: cs.onSurface),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// Label berbentuk pill dengan ikon hijau dan teks monospace.
class InfoPill extends StatelessWidget {
  const InfoPill({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GlassSurface(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.primary),
          const SizedBox(width: 8),
          Text(
            text,
            style: context.wsMono.stat.copyWith(fontSize: 12, fontWeight: FontWeight.w600)
                .copyWith(letterSpacing: 0.4, height: 16 / 12),
          ),
        ],
      ),
    );
  }
}

/// Tombol pill kategori (bird / plant / insect). [isActive] = lebih terang.
class CategoryPill extends StatelessWidget {
  const CategoryPill({
    super.key,
    this.icon,
    this.imageIcon,
    required this.label,
    this.isActive = false,
    this.onTap,
  }) : assert(icon != null || imageIcon != null,
            'Isi icon atau imageIcon');

  final IconData? icon;

  /// Icon dari aset gambar (mis. AssetImage('assets/wing.png')).
  final ImageProvider? imageIcon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: GlassSurface(
        color: isActive ? cs.onSurface.withAlpha(48) : null,
        borderColor: isActive ? cs.primary : null,
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (imageIcon != null)
                ImageIcon(imageIcon, size: 20, color: cs.primary)
              else
                Icon(icon, size: 20, color: cs.primary),
              const SizedBox(width: 8),
              Text(label, style: tt.bodyMedium!.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tombol shutter putih besar dengan cincin luar.
class ShutterButton extends StatelessWidget {
  const ShutterButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 88,
        height: 88,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border:
              Border.all(color: cs.onSurface.withAlpha(70), width: 2),
        ),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: WsShadow.card(context),
          ),
          child: Icon(Icons.photo_camera_outlined,
              size: 30, color: cs.surfaceDim),
        ),
      ),
    );
  }
}

/// Tanda crosshair kecil di tengah viewfinder.
class CrosshairMark extends StatelessWidget {
  const CrosshairMark({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: cs.primary.withAlpha(150), width: 1.5),
      ),
      child: Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          color: cs.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Kotak thumbnail galeri (Library).
class LibraryButton extends StatelessWidget {
  const LibraryButton({super.key, required this.imageUrl, this.onTap});

  final String imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(WsRadius.md),
          border:
              Border.all(color: cs.onSurface.withAlpha(70), width: 1.5),
          boxShadow: WsShadow.card(context),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: cs.surfaceContainer),
            ),
            Container(color: Colors.black.withAlpha(70)),
            Center(
              child: Icon(Icons.image_outlined,
                  size: 22, color: cs.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kontrol dengan label kecil di bawahnya (Library, Focus).
class LabeledControl extends StatelessWidget {
  const LabeledControl({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: 8),
        Text(
          label,
          style: tt.labelMedium!.copyWith(fontSize: 12, fontWeight: FontWeight.w600).copyWith(
            shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
          ),
        ),
      ],
    );
  }
}

/// Bingkai viewfinder: border tipis membulat + empat sudut hijau.
class ViewfinderFrame extends StatelessWidget {
  const ViewfinderFrame({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(28),
              borderRadius: BorderRadius.circular(_frameRadius),
              border: Border.all(color: cs.onSurface.withAlpha(36)),
            ),
          ),
        ),
        CustomPaint(
          painter: CornerBracketsPainter(color: cs.primary),
        ),
      ],
    );
  }
}

class CornerBracketsPainter extends CustomPainter {
  const CornerBracketsPainter({
    required this.color,
    this.armLength = 30,
    this.strokeWidth = 2.5,
  });

  final Color color;
  final double armLength;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final inset = strokeWidth / 2;
    final l = inset;
    final t = inset;
    final r = size.width - inset;
    final b = size.height - inset;
    final a = armLength;

    final path = Path()
      // kiri atas
      ..moveTo(l, t + a)
      ..lineTo(l, t)
      ..lineTo(l + a, t)
      // kanan atas
      ..moveTo(r - a, t)
      ..lineTo(r, t)
      ..lineTo(r, t + a)
      // kiri bawah
      ..moveTo(l, b - a)
      ..lineTo(l, b)
      ..lineTo(l + a, b)
      // kanan bawah
      ..moveTo(r - a, b)
      ..lineTo(r, b)
      ..lineTo(r, b - a);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CornerBracketsPainter old) =>
      old.color != color ||
      old.armLength != armLength ||
      old.strokeWidth != strokeWidth;
}

/// Tombol pill lebar berwarna hijau (Submit).
class PrimaryPillButton extends StatelessWidget {
  const PrimaryPillButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    const shape = StadiumBorder();
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(WsRadius.pill),
        boxShadow: WsShadow.greenGlow(context),
      ),
      child: Material(
        color: cs.primary,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          customBorder: shape,
          child: SizedBox(
            height: 64,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22, color: cs.surfaceDim),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: tt.bodyMedium!.copyWith(
                    fontSize: 16,
                    color: cs.surfaceDim,
                    fontWeight: FontWeight.w700,
                  ).copyWith(letterSpacing: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}