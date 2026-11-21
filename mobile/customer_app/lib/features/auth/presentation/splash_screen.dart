import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import 'widgets/brand_wordmark.dart';

/// Solid brand-colour splash, then on to login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // TODO(auth): if a token exists in TokenStorage, go straight to home.
    _timer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) context.go(Routes.login);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.lavender,
      body: Center(child: BrandWordmark(size: 46, color: Colors.white)),
    );
  }
}
