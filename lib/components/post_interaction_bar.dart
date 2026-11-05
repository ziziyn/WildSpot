import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Aksi konservasi di bawah observasi: konfirmasi identitas, catatan lapangan,
/// dan laporan gangguan habitat.
///
/// Widget murni. Target sentuh tiap aksi mengikuti [iconButtonTheme] global.
class PostInteractionBar extends StatelessWidget {
  const PostInteractionBar({
    super.key,
    required this.confirmCount,
    required this.fieldNoteCount,
    required this.isConfirmed,
    required this.isReported,
    this.onConfirmId,
    this.onFieldNotes,
    this.onReport,
  });

  final int confirmCount;
  final int fieldNoteCount;
  final bool isConfirmed;
  final bool isReported;

  final VoidCallback? onConfirmId;
  final VoidCallback? onFieldNotes;
  final VoidCallback? onReport;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: isConfirmed
                ? Icons.verified_rounded
                : Icons.help_outline_rounded,
            label: 'Confirm ID',
            tooltip: 'Confirm ID / Help Identify',
            count: confirmCount,
            color: isConfirmed ? cs.primary : cs.onSurfaceVariant,
            onTap: onConfirmId,
          ),
        ),
        Expanded(
          child: _ActionButton(
            icon: Icons.edit_note_outlined,
            label: 'Field Notes',
            tooltip: 'Field Notes',
            count: fieldNoteCount,
            color: cs.onSurfaceVariant,
            onTap: onFieldNotes,
          ),
        ),
        Expanded(
          child: _ActionButton(
            icon: isReported ? Icons.report_rounded : Icons.report_outlined,
            label: 'Report',
            tooltip: 'Report habitat disturbance',
            color: isReported ? cs.error : cs.onSurfaceVariant,
            onTap: onReport,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.color,
    this.count,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final Color color;
  final int? count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final countLabel = (count != null && count! > 0) ? _format(count!) : null;
    final semanticsLabel = countLabel != null
        ? '$tooltip, $countLabel'
        : tooltip;

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(WsRadius.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (countLabel != null) ...[
                const SizedBox(width: 4),
                Text(
                  countLabel,
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: color),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _format(int n) {
    if (n < 1000) return '$n';
    return '${(n / 1000).toStringAsFixed(1)}k';
  }
}
