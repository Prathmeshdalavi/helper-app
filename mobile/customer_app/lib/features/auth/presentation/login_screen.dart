import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import 'widgets/brand_wordmark.dart';
import 'widgets/hero_carousel.dart';

/// Phone-number entry. One screen serves both login and sign up: the backend
/// decides which it is after the OTP is verified.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  bool get _valid => _controller.text.length == 10;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _proceed() {
    if (!_valid) return;
    FocusScope.of(context).unfocus();
    context.push(Routes.otp, extra: _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const Expanded(child: HeroCarousel()),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              children: [
                const BrandWordmark(size: 48),
                const SizedBox(height: 10),
                const Text(
                  'Trusted Home Helpers',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    const _CountryBox(),
                    const SizedBox(width: 10),
                    Expanded(child: _phoneField()),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _valid ? _proceed : null,
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
                    child: const Text('Proceed'),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 18),
              child: Column(
                children: [
                  const Text(
                    'By proceeding, I accept the',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B6577)),
                  ),
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B6577),
                      ),
                      children: [
                        _link('Terms of use'),
                        const TextSpan(text: ' & '),
                        _link('Privacy policy'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextSpan _link(String text) => TextSpan(
    text: text,
    style: const TextStyle(
      decoration: TextDecoration.underline,
      color: AppColors.deepPlum,
    ),
  );

  Widget _phoneField() {
    return Container(
      height: 52,
      padding: const EdgeInsets.only(left: 14, right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3DFEA)),
      ),
      child: Row(
        children: [
          const Text('+91', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _proceed(),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: const TextStyle(fontSize: 16),
              cursorColor: AppColors.lavender,
              decoration: const InputDecoration(
                hintText: 'Enter mobile number',
                hintStyle: TextStyle(color: Color(0xFF9A94A5)),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: _controller.clear,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFFE3E1E8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }
}

/// Country selector. Only India for now, so it is display-only.
class _CountryBox extends StatelessWidget {
  const _CountryBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      width: 62,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3DFEA)),
      ),
      child: const FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🇮🇳', style: TextStyle(fontSize: 20)),
            SizedBox(width: 2),
            Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }
}
