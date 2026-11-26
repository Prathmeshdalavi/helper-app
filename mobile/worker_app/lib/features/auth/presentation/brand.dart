import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';

/// Text wordmark. Swap for the real logo asset later.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({
    super.key,
    this.size = 36,
    this.color = AppColors.lavender,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
    'HerExpert',
    style: TextStyle(
      fontSize: size,
      height: 1,
      fontWeight: FontWeight.w700,
      letterSpacing: -size * 0.03,
      color: color,
    ),
  );
}
