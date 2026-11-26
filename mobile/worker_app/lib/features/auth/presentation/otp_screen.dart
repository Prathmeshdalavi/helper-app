import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../shared/widgets/code_field.dart';
import '../../../shared/widgets/ui.dart';
import '../../onboarding/data/kyc_store.dart';
import '../data/auth_repository.dart';
import '../data/session.dart';
import '../domain/auth_args.dart';

const _resendSeconds = 20;

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.args});

  final AuthArgs args;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _code = TextEditingController();
  Timer? _timer;
  int _remaining = _resendSeconds;
  bool _verifying = false;
  bool _wrong = false;

  @override
  void initState() {
    super.initState();
    _code.addListener(_onChanged);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _remaining = _resendSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) t.cancel();
    });
  }

  void _onChanged() {
    if (_code.text.isNotEmpty && _wrong) setState(() => _wrong = false);
    if (_code.text.length == 4) _verify();
  }

  Future<void> _verify() async {
    if (_verifying) return;
    setState(() => _verifying = true);
    final repo = ref.read(authRepositoryProvider);
    final phone = widget.args.phone;
    final ok = await repo.verifyOtp(phone, _code.text);
    if (!mounted) return;
    if (!ok) {
      _code.clear();
      setState(() {
        _verifying = false;
        _wrong = true;
      });
      return;
    }
    FocusScope.of(context).unfocus();
    if (repo.isRegistered(phone)) {
      ref
          .read(sessionProvider.notifier)
          .signIn(phone: phone, name: 'Lakshmi Pawar', area: 'Thane West');
      ref.read(kycProvider.notifier).seedVerified();
      context.go(Routes.home);
    } else {
      ref.read(sessionProvider.notifier).signIn(phone: phone);
      context.go(Routes.language, extra: true);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Verify number',
      children: [
        const SizedBox(height: 24),
        const Center(child: IconTile(Icons.lock_rounded, size: 80)),
        const SizedBox(height: 18),
        const Text(
          'Enter OTP',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Sent to ${widget.args.pretty}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textMuted),
        ),
        const SizedBox(height: 28),
        CodeField(controller: _code, label: 'One time password', error: _wrong),
        const SizedBox(height: 22),
        Center(
          child: _verifying
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                )
              : _wrong
              ? const Text(
                  'Incorrect OTP. Try again.',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : _remaining > 0
              ? Text(
                  'Resend in $_remaining s',
                  style: const TextStyle(color: AppColors.textMuted),
                )
              : TextButton(
                  onPressed: () {
                    _code.clear();
                    setState(_startTimer);
                    ref.read(authRepositoryProvider).sendOtp(widget.args.phone);
                  },
                  child: const Text('Resend OTP'),
                ),
        ),
      ],
    );
  }
}
