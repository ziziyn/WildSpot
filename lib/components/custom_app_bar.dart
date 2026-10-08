import 'package:flutter/material.dart';

const String kDefaultProfileImage =
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.profileImageUrl = kDefaultProfileImage,
    this.onFilterTap,
    this.onNotificationTap,
    this.onSettingsTap,
    this.onProfileTap,
  });

  final String title;
  final String profileImageUrl;
  final VoidCallback? onFilterTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onProfileTap;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1A211E),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 64,
      titleSpacing: 16,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          onPressed: onFilterTap,
          tooltip: 'Filter',
          icon: const Icon(Icons.filter_alt_outlined, color: Colors.white),
        ),
        IconButton(
          onPressed: onNotificationTap,
          tooltip: 'Notifikasi',
          icon: const Icon(Icons.notifications_none, color: Colors.white),
        ),
        IconButton(
          onPressed: onSettingsTap,
          tooltip: 'Pengaturan',
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 16),
          child: GestureDetector(
            onTap: onProfileTap,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF2A332F),
              backgroundImage: NetworkImage(profileImageUrl),
              onBackgroundImageError: (_, __) {},
            ),
          ),
        ),
      ],
    );
  }
}