import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/user_scope.dart';
import '../models/user_profile.dart';

/// Ukuran avatar yang dipakai di seluruh app.
enum UserAvatarSize {
  /// App bar.
  small(diameter: 32),

  /// Kartu profil di Settings.
  medium(diameter: 48),

  /// Header Profile Page — satu-satunya ukuran dengan ring dan glow.
  large(diameter: 100, hasRing: true);

  const UserAvatarSize({required this.diameter, this.hasRing = false});

  final double diameter;
  final bool hasRing;
}

/// Foto profil user — satu widget untuk semua halaman.
///
/// Secara default membaca user aktif dari `UserScope`. Isi [profile] untuk
/// menampilkan user lain. Bila foto kosong, sedang dimuat, atau gagal dimuat,
/// yang tampil adalah inisial nama.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.size = UserAvatarSize.medium,
    this.profile,
  });

  final UserAvatarSize size;
  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final user = profile ?? context.currentUser;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final diameter = size.diameter;
    final url = user.avatarUrl;

    final initial = ColoredBox(
      color: cs.primaryContainer,
      child: Center(
        child: Text(
          user.initial,
          style: tt.titleLarge?.copyWith(
            fontSize: diameter * 0.45,
            color: cs.onPrimaryContainer,
          ),
        ),
      ),
    );

    Widget avatar = SizedBox.square(
      dimension: diameter,
      child: ClipOval(
        child: url == null
            ? initial
            : Image.network(
                url,
                fit: BoxFit.cover,
                // Decode sesuai ukuran tampil, bukan ukuran asli gambar.
                cacheWidth:
                    (diameter * MediaQuery.devicePixelRatioOf(context)).round(),
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
                    (wasSynchronouslyLoaded || frame != null) ? child : initial,
                errorBuilder: (context, error, stackTrace) => initial,
              ),
      ),
    );

    if (size.hasRing) {
      avatar = Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: cs.primary, width: 3),
          boxShadow: WsShadow.greenGlow(context),
        ),
        child: avatar,
      );
    }

    return Semantics(
      image: true,
      label: 'Profile photo of ${user.name}',
      child: ExcludeSemantics(child: avatar),
    );
  }
}
