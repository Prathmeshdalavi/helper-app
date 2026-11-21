import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'scene_kit.dart';

/// An original golden puppy hopping, wagging and chasing a bouncing ball.
class PetPainter extends ScenePainter {
  PetPainter(super.f, super.repaint);

  static const _fur = Color(0xFFEDB679);
  static const _furLight = Color(0xFFF7D2A4);
  static const _furDark = Color(0xFFB7743D);
  static const _cream = Color(0xFFFFF3E0);
  static const _ink = Color(0xFF2B2230);

  static const _ballX = 252.0;
  static const _ground = 348.0;

  double get _bounce => math.sin(f.run * 3.2).abs();
  double get _ballY => _ground - 16 - 108 * _bounce * f.a;

  @override
  void draw(Canvas canvas) {
    backdropBlob(canvas, const Color(0xFFFFE2C2));
    _ground_(canvas);
    _bone(canvas);

    final hop = (0.5 + 0.5 * math.sin(f.run * 6.4)) * 6 * f.a;
    canvas.save();
    canvas.translate(-14, -hop);
    _tail(canvas);
    _body(canvas);
    _head(canvas);
    canvas.restore();

    _ball(canvas);
    _hearts(canvas);
  }

  void _ground_(Canvas canvas) {
    final patch = Rect.fromCenter(
      center: const Offset(150, 350),
      width: 270,
      height: 40,
    );
    canvas.drawOval(
      patch,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFD6EDD8), Color(0x00D6EDD8)],
        ).createShader(patch),
    );
    floorShadow(canvas, const Offset(136, 350), 170, 16, alpha: 0.2);
    final blade = Paint()
      ..color = const Color(0xFF9CCB9F)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 16; i++) {
      final x = 24 + i * 17.0 + rand(i * 1.9) * 8;
      final y = 352 + rand(i * 3.1) * 6;
      final lean = (rand(i * 5.7) - 0.5) * 6;
      canvas.drawLine(
        Offset(x, y),
        Offset(x + lean, y - 8 - rand(i * 1.0) * 5),
        blade,
      );
    }
  }

  void _bone(Canvas canvas) {
    const c = Offset(44, 346);
    final paint = Paint()..color = _cream;
    final shade = Paint()..color = const Color(0xFFE8D2B0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: 38, height: 9),
        const Radius.circular(4.5),
      ),
      paint,
    );
    for (final dx in [-19.0, 19.0]) {
      for (final dy in [-4.0, 4.0]) {
        canvas.drawCircle(c.translate(dx, dy), 5.5, paint);
      }
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c.translate(0, 3), width: 36, height: 3),
        const Radius.circular(1.5),
      ),
      shade,
    );
  }

  void _tail(Canvas canvas) {
    final wag = math.sin(f.run * 14) * 0.45 * f.a;
    canvas.save();
    canvas.translate(200, 296);
    canvas.rotate(-0.9 + wag);
    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(8, -28, -2, -54);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 15
        ..strokeCap = StrokeCap.round
        ..color = _fur,
    );
    canvas.drawCircle(const Offset(-2, -54), 8.5, Paint()..color = _furDark);
    canvas.restore();
  }

  void _body(Canvas canvas) {
    // Hind haunches.
    for (final x in [92.0, 208.0]) {
      final r = Rect.fromCenter(center: Offset(x, 318), width: 64, height: 58);
      canvas.drawOval(
        r,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.3, -0.4),
            colors: [_furLight, _fur],
          ).createShader(r),
      );
    }
    // Torso.
    final torso = Rect.fromCenter(
      center: const Offset(150, 290),
      width: 126,
      height: 136,
    );
    canvas.drawOval(
      torso,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_furLight, _fur],
        ).createShader(torso),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(150, 305), width: 68, height: 90),
      Paint()..color = _cream,
    );
    // Front legs and paws.
    for (final x in [122.0, 178.0]) {
      final leg = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, 322), width: 26, height: 46),
        const Radius.circular(13),
      );
      canvas.drawRRect(leg, Paint()..color = _fur);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, 346), width: 34, height: 18),
        Paint()..color = _cream,
      );
      for (final dx in [-6.0, 0.0, 6.0]) {
        canvas.drawLine(
          Offset(x + dx, 342),
          Offset(x + dx, 349),
          Paint()
            ..color = const Color(0xFFE8D2B0)
            ..strokeWidth = 1.4
            ..strokeCap = StrokeCap.round,
        );
      }
    }
    // Collar and tag.
    final collar = Rect.fromCenter(
      center: const Offset(150, 232),
      width: 84,
      height: 18,
    );
    canvas.drawOval(collar, Paint()..color = const Color(0xFF7458BE));
    canvas.drawOval(
      collar.deflate(3),
      Paint()..color = const Color(0xFF8E73D2),
    );
    final swing = math.sin(f.run * 6.4 + 1) * 0.3 * f.a;
    canvas.save();
    canvas.translate(150, 238);
    canvas.rotate(swing);
    canvas.drawCircle(
      const Offset(0, 12),
      8,
      Paint()..color = const Color(0xFFFFD36B),
    );
    canvas.drawCircle(
      const Offset(-2, 10),
      2.4,
      Paint()..color = Colors.white.withValues(alpha: 0.7),
    );
    canvas.restore();
  }

  void _head(Canvas canvas) {
    final ballDx = (_ballX + 14 - 150) / 110;
    final ballDy = (_ballY - 170) / 140;
    final tilt = (_bounce - 0.4) * 0.2 * f.a;

    canvas.save();
    canvas.translate(150, 232);
    canvas.rotate(tilt);
    canvas.translate(-150, -232);

    // Head.
    const hc = Offset(150, 168);
    canvas.drawCircle(
      hc.translate(0, 4),
      64,
      Paint()..color = Colors.black.withValues(alpha: 0.1),
    );
    canvas.drawCircle(
      hc,
      64,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.4),
          colors: [_furLight, _fur],
        ).createShader(Rect.fromCircle(center: hc, radius: 64)),
    );

    // Floppy ears.
    for (final side in [-1.0, 1.0]) {
      final swing =
          math.sin(f.run * 6.4 + side) * 0.16 * f.a +
          math.cos(f.run * 3.2) * 0.05 * f.a;
      canvas.save();
      canvas.translate(150 + side * 52, 130);
      canvas.rotate(-side * (0.3 + swing));
      final ear = RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(0, 30), width: 40, height: 78),
        const Radius.circular(20),
      );
      canvas.drawRRect(
        ear,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFC98650), _furDark],
          ).createShader(ear.outerRect),
      );
      canvas.drawRRect(
        ear.deflate(7),
        Paint()..color = Colors.white.withValues(alpha: 0.1),
      );
      canvas.restore();
    }

    // Eye patch.
    canvas.drawCircle(
      const Offset(178, 154),
      23,
      Paint()..color = _furDark.withValues(alpha: 0.92),
    );

    // Muzzle.
    final muzzle = Rect.fromCenter(
      center: const Offset(150, 192),
      width: 76,
      height: 58,
    );
    canvas.drawOval(
      muzzle,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.2, -0.5),
          colors: [Color(0xFFFFFFFF), _cream],
        ).createShader(muzzle),
    );

    // Mouth and tongue.
    final open = 0.5 + 0.5 * math.sin(f.run * 8);
    final mouthOpen = 5 + open * 4 * f.a;
    canvas.drawPath(
      Path()
        ..moveTo(135, 204)
        ..quadraticBezierTo(150, 204 + mouthOpen * 2.6, 165, 204)
        ..quadraticBezierTo(150, 202, 135, 204)
        ..close(),
      Paint()..color = const Color(0xFF6A2F3B),
    );
    final tongue = RRect.fromRectAndRadius(
      Rect.fromLTWH(143, 204, 14, 8 + mouthOpen * 1.4),
      const Radius.circular(7),
    );
    canvas.drawRRect(tongue, Paint()..color = const Color(0xFFFF8FA6));
    canvas.drawLine(
      const Offset(150, 206),
      Offset(150, 206 + 5 + mouthOpen),
      Paint()
        ..color = const Color(0xFFE5677F)
        ..strokeWidth = 1.2,
    );
    final smile = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = _ink;
    canvas.drawPath(
      Path()
        ..moveTo(150, 190)
        ..lineTo(150, 198),
      smile,
    );
    canvas.drawPath(
      Path()
        ..moveTo(150, 198)
        ..quadraticBezierTo(142, 206, 133, 200),
      smile,
    );
    canvas.drawPath(
      Path()
        ..moveTo(150, 198)
        ..quadraticBezierTo(158, 206, 167, 200),
      smile,
    );

    // Nose.
    final nose = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(150, 184), width: 25, height: 16),
      const Radius.circular(8),
    );
    canvas.drawRRect(nose, Paint()..color = const Color(0xFF3A2A2F));
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(145, 180), width: 8, height: 4),
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );

    // Cheeks.
    for (final x in [108.0, 192.0]) {
      canvas.drawCircle(
        Offset(x, 188),
        10,
        Paint()
          ..color = const Color(0xFFFF9FB2).withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }

    // Eyes, tracking the ball, with a blink every few seconds.
    final blinkPhase = (f.t % 3.4);
    final blink = blinkPhase < 0.14
        ? math.sin(blinkPhase / 0.14 * math.pi)
        : 0.0;
    for (final x in [126.0, 174.0]) {
      canvas.save();
      canvas.translate(x, 156);
      canvas.scale(1, 1 - 0.9 * blink);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 19, height: 23),
        Paint()..color = _ink,
      );
      final look = Offset(
        (ballDx * 3.2).clamp(-3.0, 3.0).toDouble(),
        (ballDy * 3.2).clamp(-3.0, 3.0).toDouble(),
      );
      canvas.drawCircle(
        look.translate(-3, -4.5),
        3.6,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        look.translate(3, 4),
        1.8,
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
      canvas.restore();
    }
    // Brows.
    for (final x in [126.0, 174.0]) {
      canvas.drawCircle(
        Offset(x, 133 - 2 * f.a * _bounce),
        4.2,
        Paint()..color = _cream.withValues(alpha: 0.9),
      );
    }
    canvas.restore();
  }

  void _ball(Canvas canvas) {
    final h = _bounce * f.a;
    final squash = h < 0.07 ? 1 - (0.07 - h) * 2.6 : 1.0;
    final p = Offset(_ballX, _ballY);

    // Shadow shrinks as the ball rises.
    floorShadow(
      canvas,
      const Offset(_ballX, 350),
      44 * (1 - h * 0.55),
      9 * (1 - h * 0.4),
      alpha: 0.26 * (1 - h * 0.5),
    );

    canvas.save();
    canvas.translate(p.dx, p.dy + (1 - squash) * 16);
    canvas.scale(1 + (1 - squash) * 0.9, squash);
    canvas.rotate(f.run * 4);
    const r = 16.0;
    final rect = Rect.fromCircle(center: Offset.zero, radius: r);
    canvas.drawCircle(
      Offset.zero,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.4, -0.5),
          colors: [Color(0xFFFFB9CB), Color(0xFFE5607F)],
        ).createShader(rect),
    );
    canvas.save();
    canvas.clipPath(Path()..addOval(rect));
    canvas.drawPath(
      Path()
        ..moveTo(-r, -2)
        ..quadraticBezierTo(0, 8, r, -2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = Colors.white.withValues(alpha: 0.85),
    );
    canvas.restore();
    canvas.drawCircle(
      const Offset(-5, -6),
      3.5,
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );
    canvas.restore();
  }

  void _hearts(Canvas canvas) {
    for (var k = 0; k < 4; k++) {
      final life = (f.run * 0.45 + k * 0.25) % 1;
      final x = 136 + math.sin(life * 5 + k * 2) * 22 + (k - 1.5) * 14;
      final y = 96 - life * 62;
      _heart(
        canvas,
        Offset(x, y),
        5 + 3 * rand(k * 4.4),
        f.a * math.sin(life * math.pi),
      );
    }
  }

  void _heart(Canvas canvas, Offset p, double s, double alpha) {
    if (alpha <= 0.02) return;
    final path = Path()
      ..moveTo(p.dx, p.dy + s)
      ..cubicTo(
        p.dx - s * 2,
        p.dy - s * 0.2,
        p.dx - s * 0.9,
        p.dy - s * 1.6,
        p.dx,
        p.dy - s * 0.5,
      )
      ..cubicTo(
        p.dx + s * 0.9,
        p.dy - s * 1.6,
        p.dx + s * 2,
        p.dy - s * 0.2,
        p.dx,
        p.dy + s,
      )
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = const Color(0xFFFF6B8B).withValues(alpha: alpha),
    );
  }
}
