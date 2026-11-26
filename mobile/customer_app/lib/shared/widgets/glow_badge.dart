import 'package:material_ui/material_ui.dart';

import '../../app/app_theme.dart';

/// Gradient icon badge with two slow rings radiating outward. Shared by the
/// auth screens so they feel like one flow.
class GlowBadge extends StatefulWidget {
  const GlowBadge({super.key, required this.icon, this.size = 68});

  final IconData icon;
  final double size;

  @override
  State<GlowBadge> createState() => _GlowBadgeState();
}

class _GlowBadgeState extends State<GlowBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = widget.size * 1.76;
    return SizedBox(
      width: box,
      height: box,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          Widget ring(double phase) {
            final t = (_c.value + phase) % 1;
            return Transform.scale(
              scale: 0.62 + t * 0.38,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.lavender.withValues(alpha: 0.28 * (1 - t)),
                    width: 1.5,
                  ),
                ),
              ),
            );
          }

          return Stack(
            alignment: Alignment.center,
            children: [
              ring(0),
              ring(0.5),
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF29768), AppColors.lavender],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.lavender.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  widget.icon,
                  size: widget.size * 0.44,
                  color: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
