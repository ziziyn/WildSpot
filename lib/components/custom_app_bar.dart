import 'package:flutter/material.dart';

import 'user_avatar.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Enum: Active-page identifiers for M3 State-Layer icon toggle
// ─────────────────────────────────────────────────────────────────────────────

/// Identifies which top-level page is currently active so that the
/// corresponding AppBar icon can switch between its outlined (idle) and
/// filled (active) variants — following the M3 Navigation State Layer
/// iconography convention.
enum AppBarActivePage { notifications, settings, none }

// ─────────────────────────────────────────────────────────────────────────────
//  CustomAppBar
// ─────────────────────────────────────────────────────────────────────────────

/// A pixel-perfect, Material 3–compliant AppBar for WildSpot.
///
/// Design decisions:
/// - All colours are resolved from [Theme.of(context).colorScheme] — zero
///   hardcoded values, satisfying Single Source of Truth / DRY.
/// - Icons follow the M3 "outlined = idle, filled = active" State Layer
///   convention, driven by [activePage].
/// - The notification [Badge] (small dot) is rendered only when
///   [hasUnreadNotifications] is `true`, using the M3 native [Badge] widget
///   whose colour is drawn from [ColorScheme.error] (high-attention signal) —
///   implementing Don Norman's *Signifier* principle without hardcoding.
/// - Touch targets are guaranteed ≥ 48 × 48 dp by the global
///   [IconButtonThemeData] in `app_theme.dart` (Fitts's Law / WCAG 2.5.5).
///   This widget must NOT override that theme locally.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.onSearchTap,
    this.onNotificationTap,
    this.onSettingsTap,
    this.onProfileTap,
    this.hasUnreadNotifications = true,
    this.activePage = AppBarActivePage.none,
  });

  /// The screen title shown in the leading area.
  final String title;

  /// When set, shows a search icon before the other actions.
  final VoidCallback? onSearchTap;

  /// Callback when the notification bell is tapped.
  final VoidCallback? onNotificationTap;

  /// Callback when the settings gear is tapped.
  final VoidCallback? onSettingsTap;

  /// Callback when the profile avatar is tapped.
  final VoidCallback? onProfileTap;

  /// When `true`, renders a small M3 [Badge] dot on the notification icon
  /// (Don Norman — Signifier principle: an unread-state visual cue).
  final bool hasUnreadNotifications;

  /// Controls which icon renders in its *filled* (active) variant.
  /// Defaults to [AppBarActivePage.none] (all icons in outlined/idle state).
  final AppBarActivePage activePage;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      actions: [
        if (onSearchTap != null)
          IconButton(
            onPressed: onSearchTap,
            tooltip: 'Search',
            icon: const Icon(Icons.search),
          ),
        _NotificationButton(
          onTap: onNotificationTap,
          hasUnread: hasUnreadNotifications,
          isActive: activePage == AppBarActivePage.notifications,
        ),
        _SettingsButton(
          onTap: onSettingsTap,
          isActive: activePage == AppBarActivePage.settings,
        ),
        _ProfileButton(onTap: onProfileTap),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Private sub-widgets  (SRP: each button owns its own icon logic)
// ─────────────────────────────────────────────────────────────────────────────

/// Notification bell with an optional M3 [Badge] dot.
class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    required this.onTap,
    required this.hasUnread,
    required this.isActive,
  });

  final VoidCallback? onTap;
  final bool hasUnread;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    // M3 State Layer iconography: filled = active destination, outlined = idle.
    final iconData = isActive
        ? Icons
              .notifications // filled — active state
        : Icons.notifications_none_outlined; // outlined — idle state

    // Badge membungkus widget Icon secara langsung agar posisinya akurat
    // menempel di pojok kanan atas ikon lonceng, bukan di luar kotak touch target.
    final iconWidget = Badge(
      isLabelVisible: hasUnread,
      backgroundColor: Theme.of(context).colorScheme.error,
      smallSize: 8,
      child: Icon(iconData),
    );

    return IconButton(
      onPressed: onTap,
      tooltip: 'Notifications',
      icon: iconWidget,
    );
  }
}

/// Settings gear icon.
class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.onTap, required this.isActive});

  final VoidCallback? onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final icon = isActive
        ? Icons
              .settings // filled — active state
        : Icons.settings_outlined; // outlined — idle state

    return IconButton(onPressed: onTap, tooltip: 'Settings', icon: Icon(icon));
  }
}

/// Profile avatar button.
///
/// Uses [ExcludeSemantics] to suppress the duplicate accessibility label that
/// [UserAvatar] itself may already emit, and re-declares a single clean
/// [Semantics] node via [IconButton]'s tooltip.
class _ProfileButton extends StatelessWidget {
  const _ProfileButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: 'Profile',
      // Wrap avatar in ExcludeSemantics so the screen reader reads only the
      // parent IconButton's tooltip ("Profile"), never a duplicate label.
      icon: ExcludeSemantics(
        child: const UserAvatar(size: UserAvatarSize.small),
      ),
    );
  }
}
