import 'dart:async';

import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../domain/auth_args.dart';
import '../../../shared/widgets/auth_backdrop.dart';
import 'widgets/brand_wordmark.dart';
import '../../../shared/widgets/glow_badge.dart';

const _otpLength = 4;
const _resendSeconds = 15;

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.args});

  final AuthArgs args;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _timer;
  int _remaining = _resendSeconds;
  bool _verifying = false;
  String? _error;

  String get _pretty =>
      '+91 ${widget.args.phone.substring(0, 5)} ${widget.args.phone.substring(5)}';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _remaining = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 1) {
        t.cancel();
      }
      if (mounted) setState(() => _remaining = (_remaining - 1).clamp(0, 99));
    });
  }

  void _onChanged() {
    setState(() => _error = null);
    if (_controller.text.length == _otpLength) _verify();
  }

  Future<void> _verify() async {
    if (_verifying) return;
    setState(() => _verifying = true);
    FocusScope.of(context).unfocus();
    // TODO(auth): call POST /auth/verify-otp. Demo: any code except 0000 works.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    if (_controller.text == '0000') {
      // Clear first: the controller listener resets the error state.
      _controller.clear();
      setState(() {
        _verifying = false;
        _error = 'Incorrect OTP. Please try again.';
      });
      _focus.requestFocus();
      return;
    }
    context.go(Routes.success, extra: widget.args);
  }

  void _resend() {
    // TODO(auth): call POST /auth/send-otp.
    _controller.clear();
    _startTimer();
    _focus.requestFocus();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = _controller.text;
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
              const SizedBox(height: 48),
              const GlowBadge(icon: Icons.lock_rounded),
              const SizedBox(height: 20),
              const Text(
                'Enter OTP',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sent to $_pretty',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF5E5E5E),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 15,
                      color: AppColors.lavender,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _focus.requestFocus(),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Hidden field that actually receives the keystrokes.
                    Opacity(
                      opacity: 0,
                      child: SizedBox(
                        width: 1,
                        height: 1,
                        child: TextField(
                          controller: _controller,
                          focusNode: _focus,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          enableInteractiveSelection: false,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(_otpLength),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < _otpLength; i++) ...[
                          if (i > 0) const SizedBox(width: 10),
                          _OtpBox(
                            char: i < text.length ? text[i] : null,
                            active:
                                i == text.length.clamp(0, _otpLength - 1) &&
                                !_verifying,
                            error: _error != null,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              if (_verifying)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: AppColors.lavender,
                  ),
                )
              else if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(
                    color: Color(0xFFD64560),
                    fontSize: 13,
                  ),
                )
              else if (_remaining > 0)
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7C7C7C),
                    ),
                    children: [
                      const TextSpan(text: 'Resend available in  '),
                      TextSpan(
                        text: '$_remaining s',
                        style: const TextStyle(
                          color: AppColors.deepPlum,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              else
                GestureDetector(
                  onTap: _resend,
                  child: const Text(
                    'Resend OTP',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lavender,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.char,
    required this.active,
    required this.error,
  });

  final String? char;
  final bool active;
  final bool error;

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFD64560);
    final accent = error ? red : AppColors.lavender;
    final filled = char != null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      width: 54,
      height: 68,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? const Color(0xFFFEF8F5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active || error
              ? accent
              : filled
              ? AppColors.lavender.withValues(alpha: 0.35)
              : const Color(0xFFFCE8DD),
          width: active || error ? 1.8 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (active || error ? accent : const Color(0xFFEA580C))
                .withValues(alpha: active || error ? 0.22 : 0.07),
            blurRadius: active || error ? 14 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        char ?? '•',
        style: TextStyle(
          fontSize: filled ? 28 : 20,
          fontWeight: FontWeight.w700,
          color: filled ? AppColors.deepPlum : const Color(0xFFBDBDBD),
        ),
      ),
    );
  }
}
