import 'package:material_ui/material_ui.dart';

import '../../../../app/app_theme.dart';

/// Text wordmark for the app name. Swap for the real logo asset later.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.size = 44, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      'HerCare',
      style: TextStyle(
        fontSize: size,
        height: 1,
        fontWeight: FontWeight.w800,
        letterSpacing: -size * 0.04,
        color: color ?? AppColors.lavender,
      ),
    );
  }
}
