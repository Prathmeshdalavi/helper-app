import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../data/demo_instant.dart';

/// A calm, painted street map with the customer's pin and nearby helpers.
/// It is artwork, not real map data.
class InstantMap extends StatefulWidget {
  const InstantMap({super.key, required this.selected});

  final InstantHelper selected;

  @override
  State<InstantMap> createState() => _InstantMapState();
}

class _InstantMapState extends State<InstantMap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();

  static const _you = Offset(0.52, 0.46);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final size = Size(box.maxWidth, box.maxHeight);
        Offset at(double x, double y) =>
            Offset(x * size.width, y * size.height);
        final you = at(_you.dx, _you.dy);
        final target = at(widget.selected.mapX, widget.selected.mapY);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: CustomPaint(painter: _StreetsPainter())),
            // Dashed route from the chosen helper to the customer.
            Positioned.fill(
              child: TweenAnimationBuilder<Offset>(
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeOutCubic,
                tween: Tween(begin: target, end: target),
                builder: (context, p, _) => CustomPaint(
                  painter: _RoutePainter(from: p, to: you),
                ),
              ),
            ),
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (context, _) => CustomPaint(
                  painter: _PulsePainter(center: you, t: _pulse.value),
                ),
              ),
            ),
            for (final h in DemoInstant.helpers.where((h) => !h.isBest))
              _marker(h, at(h.mapX, h.mapY)),
            _marker(DemoInstant.helpers.first, at(0.30, 0.66)),
          ],
        );
      },
    );
  }

  Widget _marker(InstantHelper h, Offset p) {
    final on =
        h.id == widget.selected.id || (widget.selected.isBest && h.isBest);
    const base = 34.0;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      left: p.dx - base / 2,
      top: p.dy - base / 2,
      width: base,
      height: base,
      child: AnimatedScale(
        scale: on ? 1.18 : 0.9,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: on ? 1 : 0.7,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: on ? AppColors.lavender : AppInk.hairline,
                width: on ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              h.isBest ? Icons.bolt_rounded : Icons.person_rounded,
              size: 18,
              color: AppColors.lavender,
            ),
          ),
        ),
      ),
    );
  }
}

class _StreetsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFEDECF3),
    );

    // Water along the top left.
    final water = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.42, 0)
      ..quadraticBezierTo(
        size.width * 0.30,
        size.height * 0.16,
        size.width * 0.12,
        size.height * 0.20,
      )
      ..quadraticBezierTo(
        size.width * 0.04,
        size.height * 0.22,
        0,
        size.height * 0.30,
      )
      ..close();
    canvas.drawPath(water, Paint()..color = const Color(0xFFDADCEB));

    // Blocks.
    final block = Paint()..color = const Color(0xFFE5E4EE);
    final rnd = math.Random(7);
    const cols = 7;
    const rows = 5;
    final cw = size.width / cols;
    final ch = size.height / rows;
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if (rnd.nextDouble() < 0.28) continue;
        final rect = Rect.fromLTWH(c * cw + 7, r * ch + 7, cw - 14, ch - 14);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(5)),
          block,
        );
      }
    }

    // Main roads.
    final road = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 9;
    canvas.drawLine(
      Offset(-10, size.height * 0.80),
      Offset(size.width + 10, size.height * 0.34),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.40, -10),
      Offset(size.width * 0.62, size.height + 10),
      road..strokeWidth = 7,
    );
    final thin = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0, size.height * 0.52),
      Offset(size.width, size.height * 0.62),
      thin,
    );
    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.40),
      Offset(size.width * 0.28, size.height + 10),
      thin,
    );
    canvas.drawLine(
      Offset(size.width * 0.84, -10),
      Offset(size.width * 0.92, size.height + 10),
      thin,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoutePainter extends CustomPainter {
  _RoutePainter({required this.from, required this.to});

  final Offset from;
  final Offset to;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.lavender.withValues(alpha: 0.55)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final d = to - from;
    final len = d.distance;
    if (len < 1) return;
    final dir = d / len;
    for (var t = 22.0; t < len - 22; t += 11) {
      canvas.drawLine(from + dir * t, from + dir * math.min(t + 5, len), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePainter old) =>
      old.from != from || old.to != to;
}

class _PulsePainter extends CustomPainter {
  _PulsePainter({required this.center, required this.t});

  final Offset center;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final ring = Paint()
      ..color = AppColors.lavender.withValues(alpha: 0.22 * (1 - t))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 14 + 34 * t, ring);
    canvas.drawCircle(
      center,
      14,
      Paint()..color = AppColors.lavender.withValues(alpha: 0.16),
    );
    canvas.drawCircle(center, 8.5, Paint()..color = Colors.white);
    canvas.drawCircle(center, 6, Paint()..color = AppColors.lavender);
  }

  @override
  bool shouldRepaint(covariant _PulsePainter old) => old.t != t;
}
