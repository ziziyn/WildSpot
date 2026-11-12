import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
 
import '../core/app_theme.dart';
 
import 'login_page.dart';
 
// ===========================================================================
// ASSETS
// ===========================================================================
 
const _kForestImage = 'assets/forest.jpeg';
 
// ===========================================================================
// WELCOME SCREEN
// ===========================================================================
 
const _kSeenWelcomeKey = 'seen_welcome';
 
/// Gerbang awal: Welcome hanya tampil saat pertama kali aplikasi dibuka.
/// Pada pembukaan berikutnya user langsung diarahkan ke LoginScreen
/// (shortcut untuk pengguna yang sering memakai aplikasi).
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
 
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}
 
class _WelcomeScreenState extends State<WelcomeScreen> {
  late final Future<bool> _seenFuture = _loadSeen();
 
  Future<bool> _loadSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_kSeenWelcomeKey) ?? false;
    } catch (_) {
      return false;
    }
  }
 
  Future<void> _markSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kSeenWelcomeKey, true);
    } catch (_) {}
  }
 
  void _getStarted() {
    _markSeen();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _seenFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(backgroundColor: context.wsBrand.forest);
        }
        if (snapshot.data!) {
          return const LoginScreen();
        }
        return _WelcomeView(onGetStarted: _getStarted);
      },
    );
  }
}
 
class _WelcomeView extends StatelessWidget {
  const _WelcomeView({required this.onGetStarted});
 
  final VoidCallback onGetStarted;
 
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final brand = context.wsBrand;
 
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // -----------------------------------------------------------------
          // FOREST BACKGROUND
          // -----------------------------------------------------------------
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
 
          // -----------------------------------------------------------------
          // GRADIENT OVERLAY
          // -----------------------------------------------------------------
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
 
          // -----------------------------------------------------------------
          // CONTENT
          // -----------------------------------------------------------------
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Branding
                  const SizedBox(height: 100),
 
                  const Center(child: _Brand()),
 
                  const SizedBox(height: 120),
 
                  // -----------------------------------------------------------------
                  // HEADLINE
                  // -----------------------------------------------------------------
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
 
                  // -----------------------------------------------------------------
                  // SUBTITLE
                  // -----------------------------------------------------------------
                  Text(
                    'Join a community dedicated\n'
                    'to protecting nature through\n'
                    'real observations.',
                    style: text.bodyLarge?.copyWith(
                      color: scheme.onPrimary.withAlpha(220),
                      fontSize: 19,
                      height: 1.35,
                    ),
                  ),
 
                  const SizedBox(height: 120),
 
                  // -----------------------------------------------------------------
                  // GET STARTED BUTTON
                  // -----------------------------------------------------------------
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: onGetStarted,
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
                          const Icon(Icons.arrow_forward_rounded, size: 22),
                        ],
                      ),
                    ),
                  ),
 
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
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