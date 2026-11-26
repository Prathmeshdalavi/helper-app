import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../domain/auth_args.dart';
import '../../../shared/widgets/auth_backdrop.dart';
import 'widgets/auth_field.dart';
import 'widgets/brand_wordmark.dart';
import '../../../shared/widgets/glow_badge.dart';

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
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Scaffold(
      backgroundColor: Colors.white,
      body: AuthBackdrop(
        child: SafeArea(
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
                    const Expanded(
                      child: Center(child: BrandWordmark(size: 22)),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Column(
                    children: [
                      const _Steps(),
                      const SizedBox(height: 10),
                      const GlowBadge(
                        icon: Icons.person_add_alt_1_rounded,
                        size: 60,
                      ),
                      const Text(
                        'Create your account',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Looks like you're new here. Tell us a bit about you.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5E5E5E),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _Reveal(
                        child: _FormCard(
                          children: [
                            const _Label('Mobile number'),
                            _PhoneRow(
                              pretty: _pretty,
                              onEdit: () => context.pop(),
                            ),
                            const SizedBox(height: 16),
                            const _Label('Full name'),
                            AuthField(
                              controller: _name,
                              hint: 'Enter your full name',
                              icon: Icons.person_outline_rounded,
                              keyboardType: TextInputType.name,
                              capitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              valid: _nameOk,
                              formatters: [
                                FilteringTextInputFormatter.deny(
                                  RegExp(r'[0-9]'),
                                ),
                                LengthLimitingTextInputFormatter(60),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const _Label('Email (optional)'),
                            AuthField(
                              controller: _email,
                              hint: 'you@example.com',
                              icon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              error: _emailTouched && !_emailOk,
                              valid: _email.text.isNotEmpty && _emailOk,
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _TermsRow(
                        accepted: _accepted,
                        onChanged: (v) => setState(() => _accepted = v),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: _valid
                            ? [
                                BoxShadow(
                                  color: AppColors.lavender.withValues(
                                    alpha: 0.35,
                                  ),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : const [],
                      ),
                      child: SizedBox(
                        height: 52,
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _valid ? _continue : null,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            backgroundColor: AppColors.lavender,
                            disabledBackgroundColor: AppColors.lavender
                                .withValues(alpha: 0.35),
                            disabledForegroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Continue'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (!keyboardOpen) ...[
                      const SizedBox(height: 12),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 13,
                            color: Color(0xFF7C7C7C),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Your details are safe and never shared',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7C7C7C),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Step 1 of 2" progress: details, then OTP.
class _Steps extends StatelessWidget {
  const _Steps();

  @override
  Widget build(BuildContext context) {
    Widget bar(bool done) => Expanded(
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: done
              ? AppColors.lavender
              : AppColors.lavender.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
    const small = TextStyle(fontSize: 11, fontWeight: FontWeight.w600);
    return Column(
      children: [
        Row(children: [bar(true), const SizedBox(width: 6), bar(false)]),
        const SizedBox(height: 6),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your details',
              style: TextStyle(color: AppColors.lavender, fontSize: 11),
            ),
            Text('Verify OTP', style: TextStyle(color: Color(0xFF7C7C7C))),
          ],
        ),
      ].map((w) => DefaultTextStyle.merge(style: small, child: w)).toList(),
    );
  }
}

/// Fades and slides its child up the first time it appears.
class _Reveal extends StatelessWidget {
  const _Reveal({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 18),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFDF0E9)),
        boxShadow: [
          BoxShadow(
            color: AppColors.lavender.withValues(alpha: 0.10),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
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
          color: Color(0xFF4F4F4F),
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
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF8F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFCE8DD)),
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
                color: accepted ? AppColors.lavender : const Color(0xFFFAD5C2),
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
                  color: Color(0xFF5E5E5E),
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
