import 'package:flutter/material.dart';

import '../components/auth_widget.dart';
import '../core/app_theme.dart';

import 'package:wild_spot/main.dart';

import 'login_page.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // =========================================================================
  // REGISTER
  // =========================================================================

  void _handleRegister() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AppShell()),
      (route) => false,
    );
  }

  // =========================================================================
  // VALIDATION
  // =========================================================================

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email wajib diisi';
    }

    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

    if (!valid) {
      return 'Format email tidak valid';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }

    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }

    return null;
  }

  // =========================================================================
  // UI
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final brand = context.wsBrand;

    return AuthScaffold(
      title: Padding(
        padding: const EdgeInsets.only(top: 28),
        child: Text.rich(
          TextSpan(
            style: text.displayMedium?.copyWith(fontSize: 35),
            children: [
              const TextSpan(text: 'Create an '),
              TextSpan(
                text: 'Account',
                style: TextStyle(color: brand.forest),
              ),
            ],
          ),
        ),
      ),

      subtitle: 'Join WildSpot and start making\na difference for nature.',

      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthField(
              label: 'Name',
              hint: 'Enter your name',
              icon: Icons.person_outline_rounded,
              controller: _nameController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama wajib diisi';
                }

                return null;
              },
            ),

            const SizedBox(height: 11),

            AuthField(
              label: 'Email',
              hint: 'Enter your email',
              icon: Icons.mail_outline_rounded,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: _validateEmail,
            ),

            const SizedBox(height: 11),

            AuthField(
              label: 'Password',
              hint: 'Create a password',
              icon: Icons.lock_outline_rounded,
              controller: _passwordController,
              obscure: _obscurePassword,
              onToggleObscure: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              textInputAction: TextInputAction.next,
              validator: _validatePassword,
            ),

            const SizedBox(height: 11),

            AuthField(
              label: 'Confirm Password',
              hint: 'Confirm your password',
              icon: Icons.lock_outline_rounded,
              controller: _confirmController,
              obscure: _obscureConfirm,
              onToggleObscure: () {
                setState(() {
                  _obscureConfirm = !_obscureConfirm;
                });
              },
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleRegister(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Konfirmasi password wajib diisi';
                }

                if (value != _passwordController.text) {
                  return 'Password tidak cocok';
                }

                return null;
              },
            ),

            const SizedBox(height: 17),

            PrimaryButton(label: 'Sign Up', onPressed: _handleRegister),

            const SizedBox(height: 15),

            const OrDivider(),

            const SizedBox(height: 15),

            GoogleButton(onPressed: () {}),
          ],
        ),
      ),

      footer: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: SwitchLink(
          prompt: "Already have an account?",
          action: 'Log in',
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
        ),
      ),
    );
  }
}
