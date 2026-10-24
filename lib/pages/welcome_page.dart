import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../components/auth_widget.dart';

import 'login_page.dart';
import 'register_page.dart';

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
          // -----------------------------------------------------------------
          // FOREST BACKGROUND
          // -----------------------------------------------------------------
          Image.asset(
            _kForestImage,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) {
              return ColoredBox(color: brand.forest);
            },
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
                  // Branding moved slightly lower.
                  const SizedBox(height: 100),

                  const Center(child: _Brand()),

                  // Controlled spacing instead of Spacer.
                  const SizedBox(height: 120),

                  // -----------------------------------------------------------------
                  // HEADLINE
                  // -----------------------------------------------------------------
                  Text(
                    'Discover\nBiodiversity\nAround You',
                    style: text.displayMedium?.copyWith(
                      color: scheme.onPrimary,
                      fontSize: 30,
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
                      fontSize: 18,
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 120),

                  // ----------------------------------------------------------------
                  // LOGIN
                  // -----------------------------------------------------------------
                  PrimaryButton(
                    label: 'Log in with Email',
                    icon: Icons.mail_outline_rounded,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  // -----------------------------------------------------------------
                  // GOOGLE
                  // -----------------------------------------------------------------
                  GoogleButton(onPressed: () {}),

                  const SizedBox(height: 16),

                  // -----------------------------------------------------------------
                  // REGISTER
                  // -----------------------------------------------------------------
                  Center(
                    child: SwitchLink(
                      prompt: "Don't have an account?",
                      action: 'Sign up',
                      promptColor: scheme.onPrimary,
                      actionColor: scheme.primaryContainer,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
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
        Icon(Icons.eco_rounded, size: 68, color: scheme.primaryContainer),

        const SizedBox(height: 4),

        // -------------------------------------------------------------------
        // WILDSPOT
        // -------------------------------------------------------------------
        Text.rich(
          TextSpan(
            style: text.displayMedium?.copyWith(
              fontSize: 48,
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
          'EXPLORE  •  OBSERVE  •  PROTECT',
          style: text.labelSmall?.copyWith(
            color: scheme.onPrimary,
            fontSize: 12,
            letterSpacing: 3.5,
          ),
        ),
      ],
    );
  }
}
