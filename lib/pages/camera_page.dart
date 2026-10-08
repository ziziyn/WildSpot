import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/reusable_camera_widgets.dart';
import '../core/app_theme.dart';

// ---- Data statis & placeholder ----------------------------------------------
const _backgroundImage =
    'https://images.unsplash.com/photo-1448375240586-882707db888b?w=1200&q=80';
const _avatarImage =
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80';
const _libraryImage =
    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=200&q=80';

class _Category {
  const _Category(this.label, {this.icon, this.imageIcon});
  final String label;
  final IconData? icon;
  final ImageProvider? imageIcon;
}

const _categories = [
  // Icon burung memakai aset hasil import (assets/wing.png)
  _Category('bird', imageIcon: AssetImage('assets/wing.png')),
  _Category('plant', icon: Icons.eco_outlined),
  _Category('insect', icon: Icons.bug_report_outlined),
];

// ---- Page ----------------------------------------------------------------
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  // Default: "plant" aktif, sesuai mockup.
  int _selected = 1;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: WsColors.bgBase,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Pengganti feed kamera
            Positioned.fill(
              child: Image.network(
                _backgroundImage,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: WsColors.bgCard),
              ),
            ),
            const Positioned.fill(child: _Scrim()),

            // UI overlay
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const _Header(),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 358,
                      child: Stack(
                        children: [
                          const Positioned(
                              top: 0, left: 0, child: _TopLeftControls()),
                          const Positioned(
                              top: 0, right: 0, child: _TopRightIndicators()),
                          Positioned(
                            top: 90,
                            left: 0,
                            right: 0,
                            height: 268,
                            child: _Viewfinder(
                              selected: _selected,
                              onSelected: (i) => setState(() => _selected = i),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    PrimaryPillButton(
                      label: 'SUBMIT DISCOVERY LOG',
                      icon: Icons.check,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Latar gelap di atas & bawah foto ---------------------------------------
class _Scrim extends StatelessWidget {
  const _Scrim();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.22, 0.55, 1],
          colors: [
            Colors.black.withAlpha(190),
            Colors.black.withAlpha(30),
            Colors.black.withAlpha(40),
            Colors.black.withAlpha(200),
          ],
        ),
      ),
    );
  }
}

// ---- Header (tanpa AppBar) ----------------------------------------------------
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.maybePop(context),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(Icons.chevron_left,
                        size: 32, color: WsColors.textPrimary),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Record Discovery',
                    style: WsText.heading(size: 18, weight: FontWeight.w700),
                  ),
                ),
              ),
              // Foto profil: bulat sempurna dengan cincin putih
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: WsColors.textPrimary,
                  boxShadow: WsShadow.card,
                ),
                child: ClipOval(
                  child: Image.network(
                    _avatarImage,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 36,
                      height: 36,
                      color: WsColors.bgSurface,
                      child: const Icon(Icons.person,
                          size: 20, color: WsColors.textMuted),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---- Kontrol kiri atas -----------------------------------------------------------
class _TopLeftControls extends StatelessWidget {
  const _TopLeftControls();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleOverlayButton(
            icon: Icons.flash_off, tooltip: 'Flash', onPressed: () {}),
        const SizedBox(height: 14),
        CircleOverlayButton(
            icon: Icons.refresh, tooltip: 'Flip kamera', onPressed: () {}),
      ],
    );
  }
}

// ---- Indikator kanan atas ----------------------------------------------------------
class _TopRightIndicators extends StatelessWidget {
  const _TopRightIndicators();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        InfoPill(
            icon: Icons.location_on_outlined, text: '45.4215° N, 75.6972° W'),
        SizedBox(height: 9),
        InfoPill(icon: Icons.schedule, text: '19.19.51'),
      ],
    );
  }
}

// ---- Viewfinder + kontrol kamera ---------------------------------------------------
class _Viewfinder extends StatelessWidget {
  const _Viewfinder({required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Bingkai & sudut hijau
        const Positioned(
            left: 48, right: 48, top: 0, bottom: 0, child: ViewfinderFrame()),

        // Teks klasifikasi
        const Positioned(
            top: 16, left: 56, right: 56, child: _ClassifyHeading()),

        // Pill kategori
        Positioned(
          top: 53,
          left: 4,
          right: 4,
          child: Row(
            children: [
              for (var i = 0; i < _categories.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(
                  child: CategoryPill(
                    icon: _categories[i].icon,
                    imageIcon: _categories[i].imageIcon,
                    label: _categories[i].label,
                    isActive: i == selected,
                    onTap: () => onSelected(i),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Crosshair + shutter
        const Positioned(
            top: 117, left: 0, right: 0, child: Center(child: CrosshairMark())),
        Positioned(
          top: 144,
          left: 0,
          right: 0,
          child: Center(child: ShutterButton(onTap: () {})),
        ),

        // Library (kiri) & Focus (kanan)
        Positioned(
          left: 0,
          top: 151,
          child: LabeledControl(
            label: 'Library',
            child: LibraryButton(imageUrl: _libraryImage, onTap: () {}),
          ),
        ),
        Positioned(
          right: 0,
          top: 151,
          child: LabeledControl(
            label: 'Focus',
            child: CircleOverlayButton(
              icon: Icons.filter_center_focus,
              size: 54,
              iconSize: 26,
              tooltip: 'Focus',
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }
}

class _ClassifyHeading extends StatelessWidget {
  const _ClassifyHeading();

  @override
  Widget build(BuildContext context) {
    final eyebrow = WsText.label(
      size: 11,
      color: WsColors.textPrimary.withAlpha(200),
      weight: FontWeight.w700,
    ).copyWith(
      letterSpacing: 1.6,
      height: 16 / 11,
      shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
    );

    Widget hairline() => Expanded(
        child: Container(
            height: 1, color: WsColors.textPrimary.withAlpha(60)));

    return Column(
      children: [
        Row(
          children: [
            hairline(),
            const SizedBox(width: 8),
            Text('CLASSIFY SPECIMEN', style: eyebrow),
            const SizedBox(width: 8),
            hairline(),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'AUTO-DETECT ACTIVE',
          style: eyebrow.copyWith(
            fontSize: 9,
            height: 12 / 9,
            color: WsColors.green,
          ),
        ),
      ],
    );
  }
}