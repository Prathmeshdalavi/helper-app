import 'package:material_ui/material_ui.dart';

import '../../app/app_theme.dart';

/// Soft lavender wash with two faint colour glows, used behind auth screens.
/// Deliberately quiet: it should never compete with the form on top.
class AuthBackdrop extends StatelessWidget {
  const AuthBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF1EAFC), Color(0xFFFFFCFB), Colors.white],
              stops: [0, 0.45, 1],
            ),
          ),
        ),
        Positioned(
          top: -90,
          right: -80,
          child: _Glow(size: 280, color: AppColors.lavender, alpha: 0.22),
        ),
        Positioned(
          top: 120,
          left: -110,
          child: _Glow(size: 240, color: AppColors.softRose, alpha: 0.2),
        ),
        child,
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color, required this.alpha});

  final double size;
  final Color color;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: alpha),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
