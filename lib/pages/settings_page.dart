import 'package:flutter/material.dart';

import '../components/user_avatar.dart';
import '../components/verified_name.dart';
import '../core/app_theme.dart';
import '../core/user_scope.dart';

// ─────────────────────────────────────────────
//  Data menu — semua teks ada di satu tempat
// ─────────────────────────────────────────────

class _SettingsItem {
  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;
}

class _SettingsGroup {
  const _SettingsGroup({
    required this.title,
    required this.items,
    this.isolated = false,
  });

  final String title;
  final List<_SettingsItem> items;

  /// True untuk grup aksi krusial (Log Out): diberi jarak ekstra di atasnya.
  final bool isolated;
}

/// Bentuk kartu bersama: sudut dari token + garis tipis `outlineVariant`
/// supaya batas kartu jelas terhadap background scaffold.
RoundedRectangleBorder _cardShape(ColorScheme cs) => RoundedRectangleBorder(
      borderRadius: const BorderRadius.all(WsRadius.lg),
      side: BorderSide(color: cs.outlineVariant, width: 1),
    );

// ─────────────────────────────────────────────
//  Page
// ─────────────────────────────────────────────

/// Halaman pengaturan. Dibuka sebagai halaman penuh lewat `Navigator.push`
/// (tanpa bottom nav), mengikuti pola halaman Camera.
///
/// Data profil dan aksi Log Out diteruskan lewat parameter; belum ada state
/// atau logika bisnis di halaman ini.
class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    this.joinedLabel = 'Joined October 2023',
    this.appVersion = 'v2.4.0 • Build 102',
    this.onLogOut,
  });

  final String joinedLabel;
  final String appVersion;

  /// Dipanggil setelah pengguna menekan konfirmasi Log Out.
  final VoidCallback? onLogOut;

  // TODO: ganti dengan navigasi ke halaman masing-masing.
  static void _noop() {}

  Future<void> _confirmLogOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final cs = Theme.of(dialogContext).colorScheme;
        final tt = Theme.of(dialogContext).textTheme;
        return AlertDialog(
          title: Text('Log Out?', style: tt.titleLarge?.copyWith(fontSize: 20)),
          content: Text(
            'You will be signed out of your Ranger account.',
            style: tt.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: cs.error,
                foregroundColor: cs.onError,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) onLogOut?.call();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    final groups = <_SettingsGroup>[
      const _SettingsGroup(
        title: 'Personal Information',
        items: [
          _SettingsItem(
            icon: Icons.person_outline,
            title: 'Account Details',
            subtitle: 'Manage your profile and linked accounts',
            onTap: _noop,
          ),
          _SettingsItem(
            icon: Icons.shield_outlined,
            title: 'Privacy & Security',
            subtitle: 'Control who sees your observations',
            onTap: _noop,
          ),
        ],
      ),
      const _SettingsGroup(
        title: 'App Preferences',
        items: [
          _SettingsItem(
            icon: Icons.location_on_outlined,
            title: 'Location Permissions',
            subtitle: 'Always active for accurate logging',
            onTap: _noop,
          ),
          _SettingsItem(
            icon: Icons.notifications_none,
            title: 'Push Notifications',
            subtitle: 'Alerts for nearby species and missions',
            onTap: _noop,
          ),
          _SettingsItem(
            icon: Icons.palette_outlined,
            title: 'App Appearance',
            subtitle: 'Light Mode (Active)',
            onTap: _noop,
          ),
          _SettingsItem(
            icon: Icons.smartphone_outlined,
            title: 'System & Storage',
            subtitle: 'Offline maps and cache management',
            onTap: _noop,
          ),
        ],
      ),
      const _SettingsGroup(
        title: 'Support & Legal',
        items: [
          _SettingsItem(
            icon: Icons.info_outline,
            title: 'About WildSpot',
            onTap: _noop,
          ),
        ],
      ),
      _SettingsGroup(
        title: 'Account Actions',
        isolated: true,
        items: [
          _SettingsItem(
            icon: Icons.logout,
            title: 'Log Out',
            subtitle: 'Sign out of your Ranger account',
            isDestructive: true,
            onTap: () => _confirmLogOut(context),
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          // Batas lebar supaya tidak melebar di layar lebar (Chrome / tablet).
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _ProfileCard(joinedLabel: joinedLabel),
                for (final group in groups) _SettingsSection(group: group),
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Column(
                    children: [
                      Text(
                        'WildSpot $appVersion',
                        textAlign: TextAlign.center,
                        style: tt.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Contributing to SDG 15: Life on Land through citizen science.',
                        textAlign: TextAlign.center,
                        style: tt.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Profil
// ─────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.joinedLabel});

  final String joinedLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final user = context.currentUser;

    return Card(
      margin: EdgeInsets.zero,
      shape: _cardShape(cs),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const UserAvatar(size: UserAvatarSize.medium),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  VerifiedName(
                    name: user.name,
                    isVerified: user.isVerified,
                    fontSize: 18,
                    iconSize: 16,
                  ),
                  const SizedBox(height: 4),
                  Text(joinedLabel, style: tt.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Satu kategori = subheader (di luar) + satu Card
// ─────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.group});

  final _SettingsGroup group;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final items = group.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, group.isolated ? 48 : 32, 16, 8),
          child: Semantics(
            header: true,
            child: Text(
              group.title,
              style: tt.labelLarge?.copyWith(color: cs.primary),
            ),
          ),
        ),
        // Warna surfaceContainer dan elevasi berasal dari cardTheme;
        // bentuk + border dari _cardShape.
        Card(
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: _cardShape(cs),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                // indent 56 = padding 16 + ikon 24 + jarak 16, sejajar teks.
                if (i > 0) const Divider(height: 1, indent: 56, endIndent: 16),
                _SettingsTile(item: items[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.item});

  final _SettingsItem item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Aksi destruktif: hanya ikon dan judul berwarna error.
    // Subtitle tetap onSurfaceVariant (warna diset eksplisit).
    final accent = item.isDestructive ? cs.error : null;
    final subtitle = item.subtitle;

    return ListTile(
      onTap: item.onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(item.icon, color: accent ?? cs.primary),
      title: Text(
        item.title,
        style: tt.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: accent,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
      // Log Out adalah aksi, bukan navigasi, jadi tanpa chevron.
      trailing: item.isDestructive
          ? null
          : Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
    );
  }
}
