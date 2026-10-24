import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  Brand tokens (non-M3 colors) — ThemeExtension
// ─────────────────────────────────────────────

/// Brand colors with no native Material 3 role.
///
/// This is the single source of truth for the brand green (also used as the
/// M3 seed) and the amber accent used for missions/streaks.
/// Access via `context.wsBrand`.
@immutable
class WsBrandColors extends ThemeExtension<WsBrandColors> {
  const WsBrandColors({
    required this.forest,
    required this.amber,
    required this.amberFaint,
    required this.sun,
  });

  /// Forest green — M3 seed color and AppBar background.
  final Color forest;

  /// Amber highlight for missions / streaks.
  final Color amber;

  /// Amber container tone.
  final Color amberFaint;

  /// Bright golden tone for the weather sun and its glow.
  final Color sun;

  static const light = WsBrandColors(
    forest: Color(0xFF2E6B40),
    amber: Color(0xFFB85C00),
    amberFaint: Color(0xFFFFEDD8),
    sun: Color(0xFFF2A900),
  );

  @override
  WsBrandColors copyWith({
    Color? forest,
    Color? amber,
    Color? amberFaint,
    Color? sun,
  }) =>
      WsBrandColors(
        forest: forest ?? this.forest,
        amber: amber ?? this.amber,
        amberFaint: amberFaint ?? this.amberFaint,
        sun: sun ?? this.sun,
      );

  @override
  WsBrandColors lerp(ThemeExtension<WsBrandColors>? other, double t) {
    if (other is! WsBrandColors) return this;
    return WsBrandColors(
      forest: Color.lerp(forest, other.forest, t)!,
      amber: Color.lerp(amber, other.amber, t)!,
      amberFaint: Color.lerp(amberFaint, other.amberFaint, t)!,
      sun: Color.lerp(sun, other.sun, t)!,
    );
  }
}

// ─────────────────────────────────────────────
//  Monospace typography — ThemeExtension
// ─────────────────────────────────────────────

/// Monospace (IBM Plex Mono) styles for numbers / stats, which have no slot
/// in the standard M3 [TextTheme]. Access via `context.wsMono`.
@immutable
class WsMonoText extends ThemeExtension<WsMonoText> {
  const WsMonoText({required this.stat});

  /// Stat / numeric display (22sp, w700).
  final TextStyle stat;

  static const String fontFamily = 'IBM Plex Mono';

  /// Builds the extension with colors derived from the given [ColorScheme].
  factory WsMonoText.fromColorScheme(ColorScheme scheme) => WsMonoText(
        stat: TextStyle(
          fontFamily: fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      );

  @override
  WsMonoText copyWith({TextStyle? stat}) => WsMonoText(stat: stat ?? this.stat);

  @override
  WsMonoText lerp(ThemeExtension<WsMonoText>? other, double t) {
    if (other is! WsMonoText) return this;
    return WsMonoText(stat: TextStyle.lerp(stat, other.stat, t)!);
  }
}

// ─────────────────────────────────────────────
//  Context accessors
// ─────────────────────────────────────────────

extension WsThemeContext on BuildContext {
  WsMonoText get wsMono => Theme.of(this).extension<WsMonoText>()!;
  WsBrandColors get wsBrand => Theme.of(this).extension<WsBrandColors>()!;
}

// ─────────────────────────────────────────────
//  Non-color design tokens
// ─────────────────────────────────────────────

/// Soft, organic corner radii.
abstract final class WsRadius {
  static const sm   = Radius.circular(10);
  static const md   = Radius.circular(16);
  static const lg   = Radius.circular(20);
  static const xl   = Radius.circular(24);
  static const pill = Radius.circular(100);
}

/// Soft nature-themed shadows, resolved from the active theme.
abstract final class WsShadow {
  static List<BoxShadow> card(BuildContext context) => [
        BoxShadow(
          color: Theme.of(context).colorScheme.shadow.withAlpha(60),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> greenGlow(BuildContext context) => [
        BoxShadow(
          color: context.wsBrand.forest.withAlpha(35),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
}

// ─────────────────────────────────────────────
//  ThemeData factory
// ─────────────────────────────────────────────

const _fontSora   = 'Sora';
const _fontDmSans = 'DM Sans';

ThemeData buildWsTheme() {
  const brand = WsBrandColors.light;

  final colorScheme = ColorScheme.fromSeed(
    seedColor: brand.forest,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,

    // ── Typography (Sora / DM Sans) ─────────────────────────────────────
    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontFamily: _fontSora,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      displayMedium: TextStyle(
        fontFamily: _fontSora,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      bodyLarge: TextStyle(
        fontFamily: _fontDmSans,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: _fontDmSans,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontFamily: _fontDmSans,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: TextStyle(
        fontFamily: _fontDmSans,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      labelMedium: TextStyle(
        fontFamily: _fontDmSans,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
      ),
      labelSmall: TextStyle(
        fontFamily: _fontDmSans,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
      ),
    ),

    // ── Card ────────────────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: colorScheme.surfaceContainer,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(WsRadius.lg),
      ),
    ),

    // ── App Bar ─────────────────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      backgroundColor: brand.forest,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      scrolledUnderElevation: 4,
      shadowColor: colorScheme.shadow.withAlpha(0x42), // == Colors.black26
      foregroundColor: colorScheme.onPrimary,          // == white in M3 light
      titleTextStyle: TextStyle(
        fontFamily: _fontSora,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: colorScheme.onPrimary,
      ),
    ),

    // ── Divider ─────────────────────────────────────────────────────────
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant,
      thickness: 1,
    ),

    // ── Navigation Bar (bottom nav, dipakai semua halaman) ─────────────
    // Solid primary agar kontras tinggi terhadap konten (pasangan AppBar).
    // Tab aktif ditandai pill putih transparan (state layer onPrimary), bukan
    // primaryContainer, supaya tidak bentrok dengan warna container lain.
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      backgroundColor: colorScheme.primary,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shadowColor: colorScheme.shadow,
      indicatorColor: colorScheme.onPrimary.withAlpha(0x38),
      indicatorShape: const StadiumBorder(),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 24,
          color: selected
              ? colorScheme.onPrimary
              : colorScheme.onPrimary.withAlpha(0xB3),
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontFamily: _fontDmSans,
          fontSize: 11,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected
              ? colorScheme.onPrimary
              : colorScheme.onPrimary.withAlpha(0xB3),
        );
      }),
    ),

    // ── Floating Action Button ──────────────────────────────────────────
    // Satu warna FAB untuk seluruh app, tanpa warna per-instance.
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      elevation: 3,
    ),

    // ── Search Bar (M3 SearchBar) ───────────────────────────────────────
    // Solid & opaque (tanpa transparansi) supaya terbaca di atas peta/foto.
    searchBarTheme: SearchBarThemeData(
      backgroundColor: WidgetStatePropertyAll(colorScheme.surfaceContainerLowest),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      elevation: const WidgetStatePropertyAll(3),
      shadowColor: WidgetStatePropertyAll(colorScheme.shadow),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
    ),

    // ── Extensions ──────────────────────────────────────────────────────
    extensions: <ThemeExtension<dynamic>>[
      brand,
      WsMonoText.fromColorScheme(colorScheme),
    ],
  );
}