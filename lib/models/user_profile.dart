import 'package:flutter/foundation.dart';

/// Foto profil sementara sampai user punya foto sendiri.
const String kDefaultProfileImage =
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80';

/// Data akun yang tampil di banyak tempat (app bar, Profile, Settings).
///
/// Immutable: untuk mengubah, buat salinan lewat [copyWith] lalu kirim ke
/// `UserController.update`.
@immutable
class UserProfile {
  const UserProfile({
    required this.name,
    this.avatarUrl,
    this.isVerified = false,
  });

  final String name;

  /// Null → avatar menampilkan inisial nama.
  final String? avatarUrl;

  final bool isVerified;

  /// Data contoh. TODO: ganti dengan data dari auth/API setelah login.
  static const demo = UserProfile(
    name: 'Alex Ranger',
    avatarUrl: kDefaultProfileImage,
    isVerified: true,
  );

  /// Huruf pertama nama (kapital); '?' kalau nama kosong.
  String get initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return String.fromCharCode(trimmed.runes.first).toUpperCase();
  }

  UserProfile copyWith({String? name, String? avatarUrl, bool? isVerified}) =>
      UserProfile(
        name: name ?? this.name,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        isVerified: isVerified ?? this.isVerified,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          other.name == name &&
          other.avatarUrl == avatarUrl &&
          other.isVerified == isVerified;

  @override
  int get hashCode => Object.hash(name, avatarUrl, isVerified);
}
