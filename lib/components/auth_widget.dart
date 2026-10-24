import 'package:flutter/material.dart';

import '../core/app_theme.dart';

// ===========================================================================
// AUTH SCAFFOLD
// ===========================================================================

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    required this.footer,
  });

  final Widget title;
  final String subtitle;
  final Widget form;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        Transform.translate(
                          offset: const Offset(-15, 25),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            alignment: Alignment.centerLeft,
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 30,
                            ),
                            color: scheme.onSurface,
                            onPressed: () {
                              Navigator.of(context).maybePop();
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        title,

                        const SizedBox(height: 10),

                        Text(
                          subtitle,
                          style: text.bodyLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontSize: 18,
                            height: 1.35,
                          ),
                        ),

                        const SizedBox(height: 28),

                        form,

                        const Spacer(),

                        const SizedBox(height: 24),

                        Center(child: footer),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// AUTH FIELD
// ===========================================================================

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscure = false,
    this.onToggleObscure,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.onSubmitted,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;

  final bool obscure;
  final VoidCallback? onToggleObscure;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;

  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final forest = context.wsBrand.forest;

    OutlineInputBorder border(Color color) {
      return OutlineInputBorder(
        borderRadius: const BorderRadius.all(WsRadius.md),
        borderSide: BorderSide(color: color),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: text.labelLarge),

        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          validator: validator,
          onFieldSubmitted: onSubmitted,
          style: text.bodyLarge,
          cursorColor: forest,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
            filled: true,
            fillColor: scheme.surfaceContainer,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            prefixIcon: Icon(icon, color: scheme.onSurfaceVariant),
            suffixIcon: onToggleObscure == null
                ? null
                : IconButton(
                    onPressed: onToggleObscure,
                    icon: Icon(
                      obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
            enabledBorder: border(scheme.outlineVariant),
            focusedBorder: border(forest),
            errorBorder: border(scheme.error),
            focusedErrorBorder: border(scheme.error),
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// PRIMARY BUTTON
// ===========================================================================

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final brand = context.wsBrand;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(WsRadius.md),
        boxShadow: WsShadow.greenGlow(context),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: brand.forest,
            foregroundColor: scheme.onPrimary,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(WsRadius.md),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: scheme.onPrimary, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// GOOGLE BUTTON
// ===========================================================================

class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  static const googleIcon = 'assets/icon.png';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: scheme.surface,
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outlineVariant),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(WsRadius.md),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              googleIcon,
              width: 22,
              height: 22,
              errorBuilder: (_, _, _) {
                return Icon(
                  Icons.g_mobiledata_rounded,
                  size: 28,
                  color: scheme.onSurface,
                );
              },
            ),
            const SizedBox(width: 12),
            Text(
              'Continue with Google',
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// OR DIVIDER
// ===========================================================================

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(child: Divider(color: scheme.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'or continue with',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ),
        Expanded(child: Divider(color: scheme.outlineVariant)),
      ],
    );
  }
}

// ===========================================================================
// SWITCH LINK
// ===========================================================================

class SwitchLink extends StatelessWidget {
  const SwitchLink({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
    this.promptColor,
    this.actionColor,
  });

  final String prompt;
  final String action;
  final VoidCallback onTap;

  final Color? promptColor;
  final Color? actionColor;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final accent = actionColor ?? context.wsBrand.forest;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(prompt, style: text.bodyMedium?.copyWith(color: promptColor)),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Text(action, style: text.labelLarge?.copyWith(color: accent)),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 16, color: accent),
            ],
          ),
        ),
      ],
    );
  }
}
