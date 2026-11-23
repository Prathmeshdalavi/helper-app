import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../domain/auth_args.dart';
import 'widgets/auth_field.dart';
import 'widgets/brand_wordmark.dart';

/// Shown to a first-time user after they enter their number. The next screen
/// is OTP verification.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, required this.args});

  final AuthArgs args;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _name = TextEditingController();
  final _email = TextEditingController();
  bool _accepted = false;
  bool _emailTouched = false;

  @override
  void initState() {
    super.initState();
    _name.addListener(_refresh);
    _email.addListener(() {
      _emailTouched = true;
      _refresh();
    });
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  bool get _nameOk => _name.text.trim().length >= 2;
  bool get _emailOk => _email.text.isEmpty || _emailRe.hasMatch(_email.text);
  bool get _valid => _nameOk && _emailOk && _accepted;

  String get _pretty =>
      '+91 ${widget.args.phone.substring(0, 5)} ${widget.args.phone.substring(5)}';

  void _continue() {
    if (!_valid) return;
    FocusScope.of(context).unfocus();
    context.push(
      Routes.otp,
      extra: AuthArgs(
        phone: widget.args.phone,
        name: _name.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        isNewUser: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, size: 22),
                  ),
                  const Expanded(child: Center(child: BrandWordmark(size: 22))),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.lavender.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_add_alt_1_rounded,
                          size: 30,
                          color: AppColors.lavender,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'Create your account',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        "Looks like you're new here. Tell us a bit about you.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B6577),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const _Label('Mobile number'),
                    _PhoneRow(pretty: _pretty, onEdit: () => context.pop()),
                    const SizedBox(height: 18),
                    const _Label('Full name'),
                    AuthField(
                      controller: _name,
                      hint: 'Enter your full name',
                      icon: Icons.person_outline_rounded,
                      keyboardType: TextInputType.name,
                      capitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      formatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
                        LengthLimitingTextInputFormatter(60),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const _Label('Email (optional)'),
                    AuthField(
                      controller: _email,
                      hint: 'you@example.com',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      error: _emailTouched && !_emailOk,
                    ),
                    if (_emailTouched && !_emailOk)
                      const Padding(
                        padding: EdgeInsets.only(top: 6, left: 4),
                        child: Text(
                          'Enter a valid email address',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFD64560),
                          ),
                        ),
                      ),
                    const SizedBox(height: 22),
                    _TermsRow(
                      accepted: _accepted,
                      onChanged: (v) => setState(() => _accepted = v),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: FilledButton(
                  onPressed: _valid ? _continue : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: AppColors.lavender,
                    disabledBackgroundColor: AppColors.lavender.withValues(
                      alpha: 0.35,
                    ),
                    disabledForegroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4B4458),
        ),
      ),
    );
  }
}

/// The number they already entered, shown read-only with an edit shortcut.
class _PhoneRow extends StatelessWidget {
  const _PhoneRow({required this.pretty, required this.onEdit});

  final String pretty;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5FB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3DFEA)),
      ),
      child: Row(
        children: [
          const Text('🇮🇳', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(child: Text(pretty, style: const TextStyle(fontSize: 16))),
          GestureDetector(
            onTap: onEdit,
            child: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: AppColors.lavender,
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsRow extends StatelessWidget {
  const _TermsRow({required this.accepted, required this.onChanged});

  final bool accepted;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    TextSpan link(String t) => TextSpan(
      text: t,
      style: const TextStyle(
        decoration: TextDecoration.underline,
        color: AppColors.deepPlum,
      ),
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!accepted),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            key: const ValueKey('terms-checkbox'),
            duration: const Duration(milliseconds: 150),
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: accepted ? AppColors.lavender : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: accepted ? AppColors.lavender : const Color(0xFFC9C3D6),
                width: 1.5,
              ),
            ),
            child: accepted
                ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Color(0xFF6B6577),
                ),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  link('Terms of use'),
                  const TextSpan(text: ' and '),
                  link('Privacy policy'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
