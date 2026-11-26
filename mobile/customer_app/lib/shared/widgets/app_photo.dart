import 'package:material_ui/material_ui.dart';

/// A bundled photo that fills its parent. Falls back to a flat colour if the
/// asset is missing so a bad path never crashes a screen.
class AppPhoto extends StatelessWidget {
  const AppPhoto(
    this.asset, {
    super.key,
    this.alignment = Alignment.center,
    this.cacheWidth = 800,
    this.fallback = const Color(0xFFFCEBE2),
  });

  final String asset;
  final Alignment alignment;

  /// Decode at roughly this width to keep memory low.
  final int cacheWidth;
  final Color fallback;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      fit: BoxFit.cover,
      alignment: alignment,
      cacheWidth: cacheWidth,
      gaplessPlayback: true,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stack) => ColoredBox(color: fallback),
    );
  }
}
