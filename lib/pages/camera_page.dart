import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_theme.dart';

// ---- Data statis & placeholder ----------------------------------------------
const _previewImage =
    'https://images.unsplash.com/photo-1448375240586-882707db888b?w=1200&q=80';

class _Category {
  const _Category(this.label, {this.icon, this.imageIcon});
  final String label;
  final IconData? icon;
  final ImageProvider? imageIcon;
}

const _categories = [
  _Category('Flora', icon: Icons.eco_outlined),
  _Category('Fauna', icon: Icons.pets_outlined),
  _Category('Fungi', imageIcon: AssetImage('assets/mushroom.png')),
];

// ---- Page ----------------------------------------------------------------

/// Halaman kamera.
///
/// Struktur: satu [Stack] berisi (1) layer preview kamera 3:4 dan (2) kontrol
/// yang masing-masing berdiri sendiri (floating) dengan permukaan solid +
/// elevasi. Karena itu setiap kontrol tetap terbaca bila nanti digeser ke atas
/// preview kamera yang asli — cukup ubah posisinya di [build].
///
/// Seluruh warna berasal dari `ColorScheme` / `app_theme.dart`.
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  static const double _topPadding = 16;
  static const double _backBarHeight = 48;
  static const double _bottomReserve = 40;
  static const double _coordsHeight = 20;
  static const double _coordsGap = 12;
  static const double _margin = 16;
  static const double _sectionGap = 20;
  static const double _chipRowHeight = 44;
  static const double _controlsGap = 28;
  static const double _controlsWidth = 268;

  /// Default: "Plant" aktif, sesuai mockup.
  int _selected = 1;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Latar halaman terang -> ikon status bar gelap.
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: LayoutBuilder(builder: (context, c) {
            final w = c.maxWidth;
            final h = c.maxHeight;

            const controlsHeight =
                _chipRowHeight + _controlsGap + _ShutterButton.size;
            const coordsBlock = _coordsHeight + _coordsGap;
            const topArea = _topPadding + _backBarHeight;

            // Preview 3:4 sebesar yang muat (lebar layar atau sisa tinggi),
            // dengan ruang kosong di bawah (_bottomReserve) agar seluruh
            // kelompok tidak menempel ke bawah.
            final maxPreviewH = h -
                topArea -
                _bottomReserve -
                coordsBlock -
                _sectionGap -
                controlsHeight;
            final previewW =
                (maxPreviewH * 3 / 4).clamp(0.0, w - 2 * _margin).toDouble();
            final previewH = previewW * 4 / 3;

            // Kelompok koordinat + preview + kontrol: sebagian besar sisa
            // ruang vertikal diberikan ke bawah, sehingga kelompok naik.
            final clusterH =
                coordsBlock + previewH + _sectionGap + controlsHeight;
            final free = h - topArea - clusterH;
            final clusterTop = topArea + (free > 0 ? free * 0.35 : 0);

            final previewTop = clusterTop + coordsBlock;
            final chipsTop = previewTop + previewH + _sectionGap;
            final controlsTop = chipsTop + _chipRowHeight + _controlsGap;

            return Stack(
              children: [
                // Layer 1: preview kamera 3:4 (placeholder)
                Positioned(
                  left: (w - previewW) / 2,
                  top: previewTop,
                  width: previewW,
                  height: previewH,
                  child: const _CameraPreview(),
                ),

                // Layer 2: kontrol floating
                const Positioned(
                  top: _topPadding,
                  left: 0,
                  right: 0,
                  height: _backBarHeight,
                  child: _TopBar(),
                ),
                Positioned(
                  top: clusterTop,
                  left: 0,
                  right: 0,
                  height: _coordsHeight,
                  child: const _CoordinateLabel(text: '45.4215° N, 75.6972° W'),
                ),
                Positioned(
                  top: chipsTop,
                  left: 0,
                  right: 0,
                  height: _chipRowHeight,
                  child: _CategoryChips(
                    selected: _selected,
                    onSelected: (i) => setState(() => _selected = i),
                  ),
                ),
                Positioned(
                  top: controlsTop,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: _controlsWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _FloatingIconButton(
                            icon: const Icon(Icons.flash_off),
                            tooltip: 'Flash',
                            onPressed: () {},
                          ),
                          _ShutterButton(onPressed: () {}),
                          _FloatingIconButton(
                            icon: const Icon(Icons.cameraswitch_outlined),
                            tooltip: 'Flip kamera',
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// ---- Preview kamera -----------------------------------------------------------

/// Pengganti feed kamera (rasio ditentukan parent, 3:4), tanpa bayangan.
/// Ganti [Image.network] dengan widget preview kamera yang asli.
class _CameraPreview extends StatelessWidget {
  const _CameraPreview();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: const BorderRadius.all(WsRadius.xl),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _previewImage,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                ColoredBox(color: cs.surfaceContainerHigh),
          ),
          // Grid 3x3 seperti kamera HP.
          CustomPaint(
            painter: _GridPainter(cs.surfaceContainerLowest.withAlpha(90)),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var i = 1; i <= 2; i++) {
      final dx = size.width * i / 3;
      final dy = size.height * i / 3;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.color != color;
}

// ---- Top bar: back ------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        // Hanya chevron: tanpa lingkaran & bayangan (IconButton standar M3).
        child: IconButton(
          onPressed: () => Navigator.maybePop(context),
          tooltip: 'Kembali',
          iconSize: 32,
          icon: const Icon(Icons.chevron_left),
        ),
      ),
    );
  }
}

/// Koordinat sebagai teks saja (hijau primary, mono), tepat di atas preview.
class _CoordinateLabel extends StatelessWidget {
  const _CoordinateLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Koordinat $text',
      child: Center(
        child: Text(
          text,
          style: context.wsMono.stat.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: cs.primary,
          ),
        ),
      ),
    );
  }
}

// ---- Kategori ---------------------------------------------------------------------

/// Pilihan kategori (single-select) memakai M3 [ChoiceChip]. Permukaan solid +
/// elevasi supaya tetap terbaca di atas preview kamera.
class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _categories.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Builder(builder: (context) {
                final isActive = i == selected;
                final fg = isActive ? cs.onPrimary : cs.onSurface;
                final category = _categories[i];
                return ChoiceChip(
                  avatar: category.imageIcon != null
                      ? ImageIcon(category.imageIcon, size: 18, color: fg)
                      : Icon(category.icon, size: 18, color: fg),
                  label: Text(category.label),
                  labelStyle: tt.labelLarge!.copyWith(color: fg),
                  selected: isActive,
                  showCheckmark: false,
                  onSelected: (_) => onSelected(i),
                  selectedColor: cs.primary,
                  backgroundColor: cs.surfaceContainerLowest,
                  surfaceTintColor: Colors.transparent,
                  shadowColor: cs.shadow,
                  elevation: 2,
                  pressElevation: 2,
                  side: BorderSide(color: isActive ? cs.primary : cs.outline),
                  shape: const StadiumBorder(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

// ---- Tombol floating ------------------------------------------------------------

/// Tonal icon button M3 (secondaryContainer, solid) 52dp dengan bayangan lembut,
/// dipakai untuk flash dan flip kamera.
class _FloatingIconButton extends StatelessWidget {
  const _FloatingIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final Widget icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: WsShadow.card(context),
      ),
      child: IconButton.filledTonal(
        onPressed: onPressed,
        tooltip: tooltip,
        iconSize: 24,
        style: IconButton.styleFrom(fixedSize: const Size.square(52)),
        icon: icon,
      ),
    );
  }
}

/// Tombol shutter: cincin primary + isi primary, dengan celah solid
/// (surfaceContainerLowest) agar tetap jelas di atas preview kamera.
class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.onPressed});

  static const double size = 84;
  static const double _ring = 4;
  static const double _inner = 64;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: 'Ambil foto',
      child: Semantics(
        button: true,
        label: 'Ambil foto',
        child: Material(
          color: cs.surfaceContainerLowest,
          elevation: 3,
          shadowColor: cs.shadow,
          surfaceTintColor: Colors.transparent,
          shape: CircleBorder(side: BorderSide(color: cs.primary, width: _ring)),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: size,
              height: size,
              child: Center(
                child: Container(
                  width: _inner,
                  height: _inner,
                  decoration:
                      BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}