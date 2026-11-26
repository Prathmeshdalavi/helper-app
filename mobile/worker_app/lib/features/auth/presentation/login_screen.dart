import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../data/auth_repository.dart';
import '../domain/auth_args.dart';
import 'brand.dart';
import 'login_hero.dart';

/// Phone-number entry. New and returning experts start the same way.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phone = TextEditingController();
  bool _sending = false;

  bool get _valid => _phone.text.length == 10;

  @override
  void initState() {
    super.initState();
    _phone.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_valid || _sending) return;
    FocusScope.of(context).unfocus();
    setState(() => _sending = true);
    final phone = _phone.text;
    await ref.read(authRepositoryProvider).sendOtp(phone);
    if (!mounted) return;
    setState(() => _sending = false);
    context.push(Routes.otp, extra: AuthArgs(phone: phone));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card,
      body: Column(
        children: [
          const Expanded(child: LoginHero()),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 14),
              child: Column(
                children: [
                  const BrandWordmark(),
                  const SizedBox(height: 6),
                  const Text(
                    'Work with HerCare',
                    style: TextStyle(fontSize: 15, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _phone,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _send(),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter mobile number',
                      prefixIcon: Padding(
                        padding: EdgeInsets.fromLTRB(16, 0, 10, 0),
                        child: Text(
                          '+91',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      prefixIconConstraints: BoxConstraints(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _valid ? _send : null,
                      child: _sending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: AppColors.white,
                              ),
                            )
                          : const Text('Get OTP'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'By continuing you accept the Terms of use and Privacy policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
