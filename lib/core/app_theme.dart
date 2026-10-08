import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  WildSpot Design Tokens
// ─────────────────────────────────────────────

/// Palet warna bertema hutan yang dalam dan desaturasi.
abstract final class WsColors {
  // Backgrounds
  static const bgDeep    = Color(0xFF0F1511);
  static const bgBase    = Color(0xFF131A16);
  static const bgSurface = Color(0xFF1A211E);
  static const bgCard    = Color(0xFF1E2922);
  static const bgCardAlt = Color(0xFF243020);

  // Accent — hijau hutan
  static const green      = Color(0xFF4CD964);
  static const greenDim   = Color(0xFF2E6B40);
  static const greenFaint = Color(0xFF1A3324);

  // Amber — highlight misi/streaking
  static const amber      = Color(0xFFE07B12);
  static const amberFaint = Color(0xFF3D2208);

  // Text
  static const textPrimary = Color(0xFFEAF2EC);
  static const textMuted   = Color(0xFF8A9E93);
  static const textDim     = Color(0xFF5A6E62);

  // Lain-lain
  static const divider = Color(0x14FFFFFF);
}

/// Radius sudut organik & lembut.
abstract final class WsRadius {
  static const sm   = Radius.circular(10);
  static const md   = Radius.circular(16);
  static const lg   = Radius.circular(20);
  static const xl   = Radius.circular(24);
  static const pill = Radius.circular(100);
}

/// Shadow halus bertema alam.
abstract final class WsShadow {
  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withAlpha(60),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> greenGlow = [
    BoxShadow(
      color: WsColors.green.withAlpha(35),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}

// ─────────────────────────────────────────────
//  Typography — font lokal tanpa package eksternal
// ─────────────────────────────────────────────

abstract final class WsText {
  static const _sora    = 'Sora';
  static const _dmSans  = 'DM Sans';
  static const _ibmMono = 'IBM Plex Mono';

  /// Display / hero heading (Sora).
  static TextStyle display({
    double size = 28,
    Color color = WsColors.textPrimary,
    FontWeight weight = FontWeight.w700,
  }) =>
      TextStyle(fontFamily: _sora, fontSize: size, color: color, fontWeight: weight);

  /// Heading section (Sora).
  static TextStyle heading({
    double size = 18,
    Color color = WsColors.textPrimary,
    FontWeight weight = FontWeight.w600,
  }) =>
      TextStyle(fontFamily: _sora, fontSize: size, color: color, fontWeight: weight);

  /// Body teks sehari-hari (DM Sans).
  static TextStyle body({
    double size = 14,
    Color color = WsColors.textPrimary,
    FontWeight weight = FontWeight.w400,
  }) =>
      TextStyle(fontFamily: _dmSans, fontSize: size, color: color, fontWeight: weight);

  /// Label kecil / caption (DM Sans).
  static TextStyle label({
    double size = 12,
    Color color = WsColors.textMuted,
    FontWeight weight = FontWeight.w500,
  }) =>
      TextStyle(fontFamily: _dmSans, fontSize: size, color: color, fontWeight: weight);

  /// Angka / stat monospace (IBM Plex Mono).
  static TextStyle mono({
    double size = 22,
    Color color = WsColors.textPrimary,
    FontWeight weight = FontWeight.w700,
  }) =>
      TextStyle(fontFamily: _ibmMono, fontSize: size, color: color, fontWeight: weight);
}

// ─────────────────────────────────────────────
//  ThemeData factory
// ─────────────────────────────────────────────

ThemeData buildWsTheme() {
  return ThemeData.dark(useMaterial3: true).copyWith(
    scaffoldBackgroundColor: WsColors.bgBase,
    colorScheme: const ColorScheme.dark(
      primary: WsColors.green,
      surface: WsColors.bgSurface,
      onSurface: WsColors.textPrimary,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontFamily: 'DM Sans', color: WsColors.textPrimary),
      bodySmall:  TextStyle(fontFamily: 'DM Sans', color: WsColors.textMuted),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: WsColors.bgSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
  );
}
