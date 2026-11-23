import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../data/session.dart';
import '../domain/auth_args.dart';

/// Shown right after OTP verification, then moves on to home.
class SuccessScreen extends ConsumerStatefulWidget {
  const SuccessScreen({super.key, this.args});

  final AuthArgs? args;

  @override
  ConsumerState<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends ConsumerState<SuccessScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      final args = widget.args;
      if (args != null) {
        ref
            .read(sessionProvider.notifier)
            .signIn(name: args.name, phone: args.phone);
      }
      context.go(Routes.home);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1B8A4B);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                builder: (context, v, child) =>
                    Transform.scale(scale: v, child: child),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFFCDF6DE),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                "You're all set!",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 22),
              Container(
                width: 190,
                height: 1,
                color: AppColors.deepPlum.withValues(alpha: 0.08),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 20,
                    color: AppColors.softRose,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.args?.isNewUser == true &&
                            widget.args!.firstName.isNotEmpty
                        ? 'Welcome to HerCare, ${widget.args!.firstName}'
                        : 'Welcome to HerCare',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Add your address to see helpers near you.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF6B6577)),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.softRose.withValues(alpha: 0.18),
                      AppColors.lavender.withValues(alpha: 0.12),
                    ],
                  ),
                ),
                child: const Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 13),
                    children: [
                      TextSpan(
                        text: 'Verified helpers',
                        style: TextStyle(
                          color: AppColors.lavender,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(text: ' at your doorstep'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
