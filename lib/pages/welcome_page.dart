import 'package:flutter/material.dart';
 
import '../core/app_theme.dart';
 
import 'login_page.dart';
 
// ===========================================================================
// ASSETS
// ===========================================================================
 
const _kForestImage = 'assets/forest.jpeg';
 
// ===========================================================================
// WELCOME SCREEN
// ===========================================================================
 
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
 
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final brand = context.wsBrand;
 
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // FOREST BACKGROUND — tidak diubah
          ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Color(0x99000000),
              BlendMode.darken,
            ),
            child: Image.asset(
              _kForestImage,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return ColoredBox(color: brand.forest);
              },
            ),
          ),
 
          // GRADIENT OVERLAY — tidak diubah
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scheme.shadow.withAlpha(40),
                  scheme.shadow.withAlpha(120),
                  scheme.shadow.withAlpha(210),
                ],
                stops: const [0, 0.5, 1],
              ),
            ),
          ),
 
          // CONTENT
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxHeight < 760;
 
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        // CHANGED: spaceBetween -> start, so the button
                        // follows the content instead of sitting at the bottom
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: isCompact ? 48 : 68),
 
                              // Branding — tidak diubah
                              const Center(child: _Brand()),
 
                              SizedBox(height: isCompact ? 54 : 72),
 
                              // HEADLINE — tidak diubah
                              Text(
                                'Discover\nBiodiversity\nAround You',
                                style: text.displayMedium?.copyWith(
                                  color: scheme.onPrimary,
                                  fontSize: 31,
                                  fontWeight: FontWeight.w800,
                                  height: 1.05,
                                ),
                              ),
 
                              const SizedBox(height: 16),
 
                              // SUBTITLE — deskripsi diperbarui
                              Text(
                                'Identify local flora and fauna, record '
                                'your observations, and take part in '
                                'conservation missions with the community.',
                                style: text.bodyLarge?.copyWith(
                                  color: scheme.onPrimary.withAlpha(220),
                                  fontSize: 19,
                                  height: 1.35,
                                ),
                              ),
 
                              SizedBox(height: isCompact ? 30 : 38),
 
                              // STATISTIK KOMUNITAS — tanpa container
                              const _WelcomeStatistics(),
 
                              SizedBox(height: isCompact ? 30 : 38),
 
                              // SDG 15 — tanpa container
                              const _SdgInformation(),
 
                              SizedBox(height: isCompact ? 28 : 36),
                            ],
                          ),
 
                          // GET STARTED — style dan navigasi tidak diubah
                          Padding(
                            padding: const EdgeInsets.only(bottom: 34),
                            child: SizedBox(
                              width: double.infinity,
                              height: 58,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: scheme.primaryContainer,
                                  foregroundColor: scheme.onPrimaryContainer,
                                  elevation: 2,
                                  shape: const StadiumBorder(),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Get Started',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
 
// ===========================================================================
// WELCOME STATISTICS
// ===========================================================================
 
class _WelcomeStatistics extends StatelessWidget {
  const _WelcomeStatistics();
 
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
 
    return Row(
      children: [
        Expanded(
          child: _WelcomeStatItem(
            icon: Icons.eco_rounded,
            value: '1,248+',
            label: 'Species Recorded',
            iconColor: scheme.primaryContainer,
          ),
        ),
        Container(
          width: 1,
          height: 64,
          margin: const EdgeInsets.symmetric(horizontal: 7),
          color: scheme.onPrimary.withAlpha(100),
        ),
        const Expanded(
          child: _WelcomeStatItem(
            icon: Icons.camera_alt_rounded,
            value: '5,320+',
            label: 'Observations Shared',
            iconColor: Color(0xFFFFB52E),
          ),
        ),
        Container(
          width: 1,
          height: 64,
          margin: const EdgeInsets.symmetric(horizontal: 7),
          color: scheme.onPrimary.withAlpha(100),
        ),
        Expanded(
          child: _WelcomeStatItem(
            icon: Icons.groups_rounded,
            value: '3,410+',
            label: 'Community Members',
            iconColor: scheme.primaryContainer,
          ),
        ),
      ],
    );
  }
}
 
class _WelcomeStatItem extends StatelessWidget {
  const _WelcomeStatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });
 
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
 
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
 
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 27, color: iconColor),
        const SizedBox(height: 7),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(
            color: scheme.onPrimary.withAlpha(220),
            fontSize: 10.5,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
 
// ===========================================================================
// SDG 15 INFORMATION — tanpa container
// ===========================================================================
 
class _SdgInformation extends StatelessWidget {
  const _SdgInformation();
 
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
 
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 72,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '15',
                style: TextStyle(
                  color: Color(0xFF8BE34D),
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              const Icon(
                Icons.forest_rounded,
                color: Color(0xFF8BE34D),
                size: 39,
              ),
            ],
          ),
        ),
        Container(
          width: 1,
          height: 66,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          color: scheme.onPrimary.withAlpha(150),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SDG 15 – Life on Land',
                style: TextStyle(
                  color: scheme.onPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Supporting the conservation of terrestrial ecosystems and biodiversity.',
                style: TextStyle(
                  color: scheme.onPrimary.withAlpha(220),
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
 
// ===========================================================================
// BRAND
// ===========================================================================
 
class _Brand extends StatelessWidget {
  const _Brand();
 
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
 
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // -------------------------------------------------------------------
        // ICON
        // -------------------------------------------------------------------
        Icon(Icons.eco_rounded, size: 69, color: scheme.primaryContainer),
        const SizedBox(height: 4),
 
        // -------------------------------------------------------------------
        // WILDSPOT
        // -------------------------------------------------------------------
        Text.rich(
          TextSpan(
            style: text.displayMedium?.copyWith(
              fontSize: 45,
              fontWeight: FontWeight.w800,
              color: scheme.onPrimary,
              height: 1,
            ),
            children: [
              const TextSpan(text: 'Wild'),
              TextSpan(
                text: 'Spot',
                style: TextStyle(color: scheme.primaryContainer),
              ),
            ],
          ),
        ),
 
        const SizedBox(height: 5),
 
        // -------------------------------------------------------------------
        // TAGLINE
        // -------------------------------------------------------------------
        Text(
          'EXPLORE  \u2022  OBSERVE  \u2022  PROTECT',
          style: text.labelSmall?.copyWith(
            color: scheme.onPrimary,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            letterSpacing: 3.5,
          ),
        ),
      ],
    );
  }
}