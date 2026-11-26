import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../shared/widgets/motion.dart';
import 'brand.dart';

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
    _timer = Timer(const Duration(milliseconds: 1400), () {
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
      backgroundColor: AppColors.softLavender,
      body: Center(
        child: Reveal(
          index: 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BrandWordmark(size: 46),
              SizedBox(height: 10),
              Text(
                'Your work, your way',
                style: TextStyle(fontSize: 15, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
