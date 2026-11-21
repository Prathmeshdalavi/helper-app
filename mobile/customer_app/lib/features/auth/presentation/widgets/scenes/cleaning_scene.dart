import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'scene_kit.dart';

/// A mop sweeping back and forth across a tiled floor, wiping away grime and
/// leaving a wet shine, with a bucket of suds beside it.
class CleaningPainter extends ScenePainter {
  CleaningPainter(super.f, super.repaint);

  static const _grime = <(Offset, double, double)>[
    (Offset(85, 250), 24, 8),
    (Offset(150, 305), 28, 9),
    (Offset(215, 262), 22, 7),
    (Offset(112, 335), 32, 10),
    (Offset(205, 334), 26, 9),
    (Offset(250, 300), 18, 6),
  ];

  /// Where the mop head is on the floor at run-time [r].
  Offset _pos(double r) =>
      Offset(150 + math.sin(r * 1.5) * 62, 288 + math.sin(r * 0.75) * 28);

  @override
  void draw(Canvas canvas) {
    backdropBlob(canvas, const Color(0xFFDCCBFA));

    final floor = Path()
      ..moveTo(36, 188)
      ..lineTo(264, 188)
      ..lineTo(335, 372)
      ..lineTo(-35, 372)
      ..close();

    canvas.save();
    canvas.clipPath(floor);
    _floorSurface(canvas);
    _drawGrime(canvas);
    _trail(canvas);
    canvas.restore();

    _mop(canvas);
    _bucket(canvas);
    _bubbles(canvas);
    _sparkles(canvas);
  }

  void _floorSurface(Canvas canvas) {
    final rect = const Rect.fromLTRB(-40, 188, 340, 372);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00EFEAF8), Color(0xFFE6DFF4), Color(0xFFD3CAE9)],
          stops: [0, 0.35, 1],
        ).createShader(rect),
    );
    final line = Paint()
      ..color = const Color(0xFF30283D).withValues(alpha: 0.08)
      ..strokeWidth = 1.2;
    final hi = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..strokeWidth = 1.2;
    for (var k = 1; k <= 7; k++) {
      final y = 188 + 184 * math.pow(k / 7, 1.6);
      canvas.drawLine(
        Offset(-40, y.toDouble()),
        Offset(340, y.toDouble()),
        line,
      );
      canvas.drawLine(
        Offset(-40, y.toDouble() + 1.4),
        Offset(340, y.toDouble() + 1.4),
        hi,
      );
    }
    for (var i = -4; i <= 4; i++) {
      canvas.drawLine(
        Offset(150 + i * 38.0, 188),
        Offset(150 + i * 61.7, 372),
        line,
      );
    }
  }

  void _drawGrime(Canvas canvas) {
    final cyc = (f.run / 9) % 1;
    for (var i = 0; i < _grime.length; i++) {
      final g = _grime[i];
      final s = (g.$1.dx - 60) / 200 * 0.5;
      final cleaned = smooth(s, s + 0.15, cyc) * (1 - smooth(0.9, 1, cyc));
      final dirty = 1 - cleaned;
      if (dirty <= 0.02) continue;
      final p = Paint()
        ..color = const Color(0xFF8A6F5A).withValues(alpha: 0.38 * dirty)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.2);
      canvas.drawOval(
        Rect.fromCenter(center: g.$1, width: g.$2 * 2, height: g.$3 * 2),
        p,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: g.$1.translate(g.$2 * 0.5, -g.$3 * 0.3),
          width: g.$2 * 1.2,
          height: g.$3 * 1.3,
        ),
        p,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: g.$1.translate(-g.$2 * 0.45, g.$3 * 0.2),
          width: g.$2 * 1.0,
          height: g.$3 * 1.2,
        ),
        p,
      );
    }
  }

  void _trail(Canvas canvas) {
    for (var k = 0; k < 17; k++) {
      final p = _pos(f.run - k * 0.1);
      final alpha = (1 - k / 17) * 0.55 * f.a;
      canvas.drawOval(
        Rect.fromCenter(center: p.translate(0, 6), width: 86, height: 18),
        Paint()..color = Colors.white.withValues(alpha: alpha),
      );
    }
  }

  void _mop(Canvas canvas) {
    final hp = _pos(f.run);
    final vel = math.cos(f.run * 1.5) * f.a;
    final lean = -0.32 + vel * 0.16;

    floorShadow(canvas, hp.translate(0, 24), 98, 16, alpha: 0.2);

    // Strands trail behind the direction of travel.
    for (var i = 0; i < 24; i++) {
      final x = -39 + i * 3.4;
      final len = 26 + rand(i * 1.7) * 9;
      final ang = -vel * 0.42 + math.sin(f.run * 5 + i * 0.6) * 0.07 * f.a;
      final base = hp.translate(x, 8);
      final end =
          base + Offset(math.sin(ang) * len, math.cos(ang) * len * 0.62);
      canvas.drawLine(
        base,
        end,
        Paint()
          ..color = (i.isEven ? Colors.white : const Color(0xFFDCEBFF))
          ..strokeWidth = 4.4
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        base.translate(0, 1),
        end.translate(0, 1),
        Paint()
          ..color = const Color(0xFF8D7FB0).withValues(alpha: 0.18)
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round,
      );
    }

    // Head frame.
    final frame = RRect.fromRectAndRadius(
      Rect.fromCenter(center: hp.translate(0, 4), width: 92, height: 15),
      const Radius.circular(7.5),
    );
    canvas.drawRRect(
      frame.shift(const Offset(0, 2)),
      Paint()..color = Colors.black.withValues(alpha: 0.2),
    );
    canvas.drawRRect(
      frame,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFB9A2EE), Color(0xFF7458BE)],
        ).createShader(frame.outerRect),
    );
    canvas.drawLine(
      hp.translate(-38, 0),
      hp.translate(38, 0),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );

    // Handle.
    final from = hp.translate(0, -3);
    final to = hp + Offset(math.sin(lean) * 200, -math.cos(lean) * 200);
    final dir = (to - from) / (to - from).distance;
    canvas.drawLine(
      from,
      to,
      Paint()
        ..color = const Color(0xFFC99A66)
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      from.translate(-1.6, 0),
      to.translate(-1.6, 0),
      Paint()
        ..color = const Color(0xFFEBCDA4)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      to - dir * 46,
      to,
      Paint()
        ..color = const Color(0xFF5B45A0)
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round,
    );
  }

  void _bucket(Canvas canvas) {
    const cx = 58.0;
    const topY = 268.0;
    const botY = 336.0;

    floorShadow(canvas, const Offset(cx, botY + 4), 80, 14, alpha: 0.25);

    final body = Path()
      ..moveTo(cx - 36, topY)
      ..lineTo(cx + 36, topY)
      ..lineTo(cx + 26, botY)
      ..quadraticBezierTo(cx, botY + 8, cx - 26, botY)
      ..close();
    canvas.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF8E73D2), Color(0xFFB9A2EE), Color(0xFF7458BE)],
          stops: [0, 0.45, 1],
        ).createShader(body.getBounds()),
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx - 20, topY + 6)
        ..lineTo(cx - 12, topY + 6)
        ..lineTo(cx - 10, botY - 6)
        ..lineTo(cx - 16, botY - 6)
        ..close(),
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );

    // Rim and water.
    final rim = Rect.fromCenter(
      center: const Offset(cx, topY),
      width: 76,
      height: 16,
    );
    canvas.drawOval(rim, Paint()..color = const Color(0xFF6B4FB5));
    final water = rim.deflate(3);
    canvas.drawOval(
      water,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFBDE8FF), Color(0xFF6FB7F0)],
        ).createShader(water),
    );
    for (var k = 0; k < 2; k++) {
      final ph = (f.run * 0.5 + k * 0.5) % 1;
      canvas.drawOval(
        Rect.fromCenter(
          center: const Offset(cx, topY),
          width: 20 + ph * 38,
          height: 4 + ph * 8,
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.white.withValues(alpha: 0.6 * (1 - ph)),
      );
    }
    for (var i = 0; i < 6; i++) {
      final bx = cx - 24 + rand(i * 2.1) * 48;
      final by = topY + (rand(i * 4.3) - 0.5) * 5;
      drawBubble(canvas, Offset(bx, by), 3 + rand(i * 7.7) * 3.5);
    }

    // Handle.
    canvas.drawPath(
      Path()
        ..moveTo(cx - 35, topY - 1)
        ..quadraticBezierTo(cx, topY - 56, cx + 35, topY - 1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF9A94AF),
    );
  }

  void _bubbles(Canvas canvas) {
    for (var i = 0; i < 7; i++) {
      final life = (f.run * 0.18 + rand(i * 1.3)) % 1;
      final x =
          58 +
          (rand(i * 3.3) - 0.5) * 30 +
          math.sin(life * 6 + i) * 10 +
          (i % 3 - 1) * 8 * life;
      final y = 262 - 150 * life;
      drawBubble(
        canvas,
        Offset(x, y),
        4 + 5 * rand(i * 2.1),
        alpha: f.a * math.sin(life * math.pi),
      );
    }
    for (var i = 0; i < 5; i++) {
      final life = (f.run * 0.4 + i * 0.2) % 1;
      final p = _pos(f.run - 0.2 - i * 0.25);
      drawBubble(
        canvas,
        Offset(p.dx + (rand(i * 5.5) - 0.5) * 24, p.dy - 8 - life * 46),
        3 + 4 * rand(i * 9.2),
        alpha: f.a * math.sin(life * math.pi),
      );
    }
  }

  void _sparkles(Canvas canvas) {
    for (var k = 0; k < 6; k++) {
      final p = _pos(f.run - 0.3 - k * 0.35);
      final tw = math.max(0.0, math.sin(f.t * 6 + k * 1.9));
      drawSparkle(
        canvas,
        p.translate((rand(k * 3.7) - 0.5) * 30, -6 - rand(k * 1.3) * 10),
        9 * tw * f.a,
        color: const Color(0xFFFFFFFF),
        alpha: f.a,
      );
    }
  }
}
