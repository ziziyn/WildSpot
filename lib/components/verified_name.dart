import 'package:flutter/material.dart';

import '../core/app_theme.dart';

/// Nama user + ikon verified di sebelah kanannya. Dipakai di Profile Page dan
/// Settings supaya tampilannya selalu sama; hanya ukurannya yang berbeda.
class VerifiedName extends StatelessWidget {
  const VerifiedName({
    super.key,
    required this.name,
    this.isVerified = false,
    this.fontSize = 18,
    this.iconSize = 16,
    this.maxLines = 1,
    this.textAlign,
  });

  final String name;
  final bool isVerified;
  final double fontSize;
  final double iconSize;
  final int maxLines;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            name,
            maxLines: maxLines,
            textAlign: textAlign,
            overflow: TextOverflow.ellipsis,
            style: tt.displayMedium!.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
        ),
        if (isVerified) ...[
          const SizedBox(width: 6),
          Tooltip(
            message: 'Verified',
            child: Icon(
              Icons.verified,
              size: iconSize,
              color: context.wsBrand.amber,
            ),
          ),
        ],
      ],
    );
  }
}
