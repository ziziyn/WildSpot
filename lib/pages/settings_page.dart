import 'package:flutter/material.dart';

import '../core/app_theme.dart';

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
    this.userName = 'Alex Ranger',
    this.joinedLabel = 'Joined October 2023',
    this.badgeLabel = 'PRO RANGER',
    this.appVersion = 'v2.4.0 • Build 102',
    this.onLogOut,
  });

  final String userName;
  final String joinedLabel;
  final String badgeLabel;
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
                _ProfileCard(
                  name: userName,
                  joinedLabel: joinedLabel,
                  badgeLabel: badgeLabel,
                ),
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
  const _ProfileCard({
    required this.name,
    required this.joinedLabel,
    required this.badgeLabel,
  });

  final String name;
  final String joinedLabel;
  final String badgeLabel;

  /// Huruf pertama nama (huruf besar) untuk avatar; '?' kalau nama kosong.
  String get _initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return String.fromCharCode(trimmed.runes.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      shape: _cardShape(cs),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: cs.primaryContainer,
              // Dekoratif: nama sudah dibaca di sebelahnya.
              child: ExcludeSemantics(
                child: Text(
                  _initial,
                  style: tt.titleLarge?.copyWith(
                    fontSize: 22,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleLarge?.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(joinedLabel, style: tt.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: const BorderRadius.all(WsRadius.pill),
              ),
              child: Text(
                badgeLabel,
                style: tt.labelSmall?.copyWith(
                  color: cs.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
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
