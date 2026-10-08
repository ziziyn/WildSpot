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
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: WsShadow.card,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? WsColors.bgDeep.withAlpha(150),
              borderRadius: borderRadius,
              border: Border.all(
                color: borderColor ?? WsColors.textPrimary.withAlpha(30),
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
    final button = GestureDetector(
      onTap: onPressed,
      child: GlassSurface(
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: iconSize, color: WsColors.textPrimary),
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
    return GlassSurface(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: WsColors.green),
          const SizedBox(width: 8),
          Text(
            text,
            style: WsText.mono(size: 12, weight: FontWeight.w600)
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
    return GestureDetector(
      onTap: onTap,
      child: GlassSurface(
        color: isActive ? WsColors.textPrimary.withAlpha(48) : null,
        borderColor: isActive ? WsColors.green : null,
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (imageIcon != null)
                ImageIcon(imageIcon, size: 20, color: WsColors.green)
              else
                Icon(icon, size: 20, color: WsColors.green),
              const SizedBox(width: 8),
              Text(label, style: WsText.body(size: 14, weight: FontWeight.w600)),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 88,
        height: 88,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border:
              Border.all(color: WsColors.textPrimary.withAlpha(70), width: 2),
        ),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: WsShadow.card,
          ),
          child: const Icon(Icons.photo_camera_outlined,
              size: 30, color: WsColors.bgDeep),
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
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: WsColors.green.withAlpha(150), width: 1.5),
      ),
      child: Container(
        width: 4,
        height: 4,
        decoration: const BoxDecoration(
          color: WsColors.green,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(WsRadius.md),
          border:
              Border.all(color: WsColors.textPrimary.withAlpha(70), width: 1.5),
          boxShadow: WsShadow.card,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: WsColors.bgCard),
            ),
            Container(color: Colors.black.withAlpha(70)),
            const Center(
              child: Icon(Icons.image_outlined,
                  size: 22, color: WsColors.textPrimary),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: 8),
        Text(
          label,
          style: WsText.label(size: 12, weight: FontWeight.w600).copyWith(
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
    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(28),
              borderRadius: BorderRadius.circular(_frameRadius),
              border: Border.all(color: WsColors.textPrimary.withAlpha(36)),
            ),
          ),
        ),
        const CustomPaint(
          painter: CornerBracketsPainter(color: WsColors.green),
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
    const shape = StadiumBorder();
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(WsRadius.pill),
        boxShadow: WsShadow.greenGlow,
      ),
      child: Material(
        color: WsColors.green,
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
                Icon(icon, size: 22, color: WsColors.bgDeep),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: WsText.body(
                    size: 16,
                    color: WsColors.bgDeep,
                    weight: FontWeight.w700,
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