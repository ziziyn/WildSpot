import 'package:flutter/material.dart';

import 'user_avatar.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.onNotificationTap,
    this.onSettingsTap,
    this.onProfileTap,
  });

  final String title;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onProfileTap;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      foregroundColor: Colors.white,            // semua ikon & teks inherit putih
      surfaceTintColor: Colors.transparent,
      elevation: 2,                             // pemisah elevasi halus dari halaman
      shadowColor: Colors.black26,              // bayangan lembut pemisah
      toolbarHeight: 64,
      titleSpacing: 16,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,              // judul putih di atas hijau
              fontWeight: FontWeight.w700,
            ),
      ),
      actions: [
        IconButton(
          onPressed: onNotificationTap,
          tooltip: 'Notifikasi',
          icon: const Icon(Icons.notifications_none),
        ),
        IconButton(
          onPressed: onSettingsTap,
          tooltip: 'Pengaturan',
          icon: const Icon(Icons.settings_outlined),
        ),
        IconButton(
          onPressed: onProfileTap,
          tooltip: 'Profil',
          padding: const EdgeInsets.only(right: 8),
          icon: const UserAvatar(size: UserAvatarSize.small),
        ),
      ],
    );
  }
}