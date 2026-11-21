import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Mutable animation state for one scene, owned by the carousel.
class SceneFrame {
  double t = 0; // seconds since start
  double a = 0; // 0..1 activity, ramps up fast when the scene is on screen
  double b = 0; // 0..1 slow activity (e.g. water filling)
  double run = 0; // integral of [a] over time: drives smooth start/stop motion
}

/// Base for every scene. Scenes are drawn in a 300x380 design space that is
/// scaled to fit, and repaint whenever [repaint] (the shared clock) ticks.
abstract class ScenePainter extends CustomPainter {
  ScenePainter(this.f, Listenable repaint) : super(repaint: repaint);

  final SceneFrame f;

  static const designW = 300.0;
  static const designH = 380.0;

  void draw(Canvas canvas);

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width / designW, size.height / designH);
    canvas.save();
    canvas.translate(
      (size.width - designW * s) / 2,
      (size.height - designH * s) / 2,
    );
    canvas.scale(s);
    draw(canvas);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Stable pseudo-random number in [0, 1) for a given input.
double rand(double v) {
  final x = math.sin(v * 12.9898) * 43758.5453;
  return x - x.floorToDouble();
}

/// Smooth 0..1 ramp between [e0] and [e1].
double smooth(double e0, double e1, double x) {
  final t = ((x - e0) / (e1 - e0)).clamp(0.0, 1.0).toDouble();
  return t * t * (3 - 2 * t);
}

void floorShadow(
  Canvas canvas,
  Offset c,
  double w,
  double h, {
  double alpha = 0.22,
}) {
  canvas.drawOval(
    Rect.fromCenter(center: c, width: w, height: h),
    Paint()
      ..color = Colors.black.withValues(alpha: alpha)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
  );
}

/// Soft pastel glow behind a scene.
void backdropBlob(
  Canvas canvas,
  Color color, {
  Offset c = const Offset(150, 170),
  double r = 138,
}) {
  canvas.drawCircle(
    c,
    r,
    Paint()
      ..shader = RadialGradient(
        colors: [color.withValues(alpha: 0.6), color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: c, radius: r)),
  );
}

/// Four-point twinkle.
void drawSparkle(
  Canvas canvas,
  Offset p,
  double size, {
  Color color = Colors.white,
  double alpha = 1,
}) {
  if (size <= 0.3 || alpha <= 0) return;
  canvas.drawCircle(
    p,
    size * 0.95,
    Paint()
      ..color = color.withValues(alpha: 0.28 * alpha)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.5),
  );
  final path = Path()
    ..moveTo(p.dx, p.dy - size)
    ..quadraticBezierTo(p.dx, p.dy, p.dx + size, p.dy)
    ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy + size)
    ..quadraticBezierTo(p.dx, p.dy, p.dx - size, p.dy)
    ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy - size)
    ..close();
  canvas.drawPath(path, Paint()..color = color.withValues(alpha: alpha));
}

/// Iridescent soap bubble.
void drawBubble(Canvas canvas, Offset p, double r, {double alpha = 1}) {
  if (alpha <= 0.01) return;
  canvas.drawCircle(
    p,
    r,
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        colors: [
          Colors.white.withValues(alpha: 0.06 * alpha),
          const Color(0xFFBFE6FF).withValues(alpha: 0.28 * alpha),
          const Color(0xFFE8C9FF).withValues(alpha: 0.42 * alpha),
        ],
        stops: const [0, 0.7, 1],
      ).createShader(Rect.fromCircle(center: p, radius: r)),
  );
  canvas.drawCircle(
    p,
    r,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.75 * alpha),
  );
  canvas.drawCircle(
    p.translate(-r * 0.38, -r * 0.38),
    r * 0.22,
    Paint()..color = Colors.white.withValues(alpha: 0.9 * alpha),
  );
}
