import 'package:flutter/material.dart';

const String kDefaultProfileImage =
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.profileImageUrl = kDefaultProfileImage,
    this.onNotificationTap,
    this.onSettingsTap,
    this.onProfileTap,
  });

  final String title;
  final String profileImageUrl;
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
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white24,
            backgroundImage: NetworkImage(profileImageUrl),
            onBackgroundImageError: (error, stack) {},
          ),
        ),
      ],
    );
  }
}