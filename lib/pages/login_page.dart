import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../components/auth.widget.dart';
import '../main.dart';
import 'register_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AppShell()),
      (route) => false,
    );
  }

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
              const TextSpan(text: 'Welcome '),
              TextSpan(
                text: 'Back',
                style: TextStyle(color: brand.forest),
              ),
            ],
          ),
        ),
      ),
      subtitle: 'Log in to continue your journey\nwith WildSpot.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthField(
              label: 'Email',
              hint: 'Enter your email',
              icon: Icons.mail_outline_rounded,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: _validateEmail,
            ),

            const SizedBox(height: 16),

            AuthField(
              label: 'Password',
              hint: 'Enter your password',
              icon: Icons.lock_outline_rounded,
              controller: _passwordController,
              obscure: _obscurePassword,
              onToggleObscure: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleLogin(),
              validator: _validatePassword,
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Forgot password?',
                  style: text.labelLarge?.copyWith(color: brand.forest),
                ),
              ),
            ),

            const SizedBox(height: 18),

            PrimaryButton(label: 'Log In', onPressed: _handleLogin),

            const SizedBox(height: 20),

            const OrDivider(),

            const SizedBox(height: 20),

            GoogleButton(onPressed: () {}),
          ],
        ),
      ),
      footer: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: SwitchLink(
          prompt: "Don't have an account?",
          action: 'Sign up',
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            );
          },
        ),
      ),
    );
  }
}
