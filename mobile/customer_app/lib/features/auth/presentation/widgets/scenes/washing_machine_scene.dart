import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'scene_kit.dart';

class _Cloth {
  const _Cloth(
    this.light,
    this.dark,
    this.w,
    this.h,
    this.rho,
    this.phase,
    this.pile,
  );

  final Color light;
  final Color dark;
  final double w;
  final double h;
  final double rho; // orbit radius while tumbling
  final double phase;
  final Offset pile; // resting spot at the bottom of the drum
}

const _clothes = <_Cloth>[
  _Cloth(
    Color(0xFFB79CF0),
    Color(0xFF8064C8),
    40,
    28,
    44,
    0.0,
    Offset(-26, 40),
  ),
  _Cloth(Color(0xFFF6B7CB), Color(0xFFE18AA7), 36, 26, 36, 1.7, Offset(10, 46)),
  _Cloth(Color(0xFFFFFFFF), Color(0xFFD9D4EA), 38, 27, 50, 3.1, Offset(-4, 30)),
  _Cloth(Color(0xFF9ADFD0), Color(0xFF4FB8A4), 34, 24, 40, 4.4, Offset(28, 36)),
  _Cloth(
    Color(0xFFFFE3A1),
    Color(0xFFF2B84B),
    30,
    22,
    30,
    5.4,
    Offset(-34, 22),
  ),
];

/// A tilting-style washing machine that fills with water and tumbles clothes.
class WashingMachinePainter extends ScenePainter {
  WashingMachinePainter(super.f, super.repaint);

  static const _body = Rect.fromLTWH(20, 10, 260, 340);
  static const _c = Offset(150, 219); // door centre
  static const _r = 92.0; // chrome ring radius
  static const _g = 70.0; // glass radius

  @override
  void draw(Canvas canvas) {
    _floorShadow(canvas);
    canvas.translate(
      math.sin(f.t * 52) * 0.8 * f.a,
      math.cos(f.t * 61) * 0.6 * f.a,
    );
    _drawBody(canvas);
    _drawPanel(canvas);
    _drawDoor(canvas);
    _drawBottom(canvas);
  }

  double get _angle => f.run * 3.6;

  // -- body ----------------------------------------------------------------

  void _floorShadow(Canvas canvas) {
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(150, 368), width: 250, height: 22),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }

  void _drawBody(Canvas canvas) {
    final rr = RRect.fromRectAndRadius(_body, const Radius.circular(30));
    canvas.drawRRect(
      rr.shift(const Offset(0, 6)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.drawRRect(
      rr,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), Color(0xFFF0ECF8), Color(0xFFDAD4EA)],
        ).createShader(_body),
    );
    // Cylindrical side shading gives the body its volume.
    canvas.drawRRect(
      rr,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.10),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withValues(alpha: 0.14),
          ],
          stops: const [0, 0.14, 0.82, 1],
        ).createShader(_body),
    );
    // Bright rim along the top edge.
    canvas.drawRRect(
      rr.deflate(1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.white.withValues(alpha: 0)],
        ).createShader(_body),
    );
  }

  // -- control panel -------------------------------------------------------

  void _drawPanel(Canvas canvas) {
    final top = _body.top;
    final on = f.a > 0.05;

    canvas.drawLine(
      Offset(_body.left + 16, top + 72),
      Offset(_body.right - 16, top + 72),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.08)
        ..strokeWidth = 1.2,
    );
    canvas.drawLine(
      Offset(_body.left + 16, top + 73.4),
      Offset(_body.right - 16, top + 73.4),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.2,
    );

    // Dial.
    final kc = Offset(_body.left + 48, top + 38);
    canvas.drawCircle(
      kc.translate(0, 3),
      22,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(
      kc,
      22,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.4, -0.5),
          colors: [Color(0xFFFFFFFF), Color(0xFFBDB8CF)],
        ).createShader(Rect.fromCircle(center: kc, radius: 22)),
    );
    for (var i = 0; i <= 8; i++) {
      final a = -2.4 + i * (4.8 / 8);
      final d = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(
        kc + d * 26,
        kc + d * 29.5,
        Paint()
          ..color = const Color(0xFF30283D).withValues(alpha: 0.28)
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(
      kc,
      15,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.4),
          colors: [Color(0xFFFDFCFF), Color(0xFFCFCADF)],
        ).createShader(Rect.fromCircle(center: kc, radius: 15)),
    );
    final ka = -2.4 + f.a * 3.6;
    final kd = Offset(math.cos(ka), math.sin(ka));
    canvas.drawLine(
      kc + kd * 4,
      kc + kd * 13,
      Paint()
        ..color = const Color(0xFF8063C4)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Display.
    final disp = RRect.fromRectAndRadius(
      Rect.fromLTWH(_body.left + 92, top + 16, 104, 44),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      disp,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF241F33), Color(0xFF14111C)],
        ).createShader(disp.outerRect),
    );
    canvas.drawRRect(
      disp.deflate(0.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white.withValues(alpha: 0.12),
    );
    final dc = disp.outerRect.center;
    if (on) {
      final rem = 45 - (f.t % 45).floor();
      _text(
        canvas,
        '0:${rem.toString().padLeft(2, '0')}',
        dc.translate(0, -5),
        20,
        const Color(0xFF9FE8FF).withValues(alpha: f.a),
      );
      _text(
        canvas,
        'QUICK WASH  40°C',
        dc.translate(0, 13),
        7.5,
        const Color(0xFF9FE8FF).withValues(alpha: 0.7 * f.a),
        ls: 0.6,
      );
    } else {
      _text(
        canvas,
        'READY',
        dc.translate(0, -3),
        16,
        const Color(0xFF8D86B0).withValues(alpha: 0.9),
        ls: 1.5,
      );
      _text(
        canvas,
        'HerCare',
        dc.translate(0, 14),
        8,
        const Color(0xFF6D668F).withValues(alpha: 0.9),
        ls: 0.8,
      );
    }

    // Power button.
    final bc = Offset(_body.right - 36, top + 38);
    if (f.a > 0) {
      final pulse = 0.75 + 0.25 * math.sin(f.t * 4);
      canvas.drawCircle(
        bc,
        21,
        Paint()
          ..color = const Color(0xFF8063C4).withValues(alpha: 0.5 * f.a * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );
    }
    canvas.drawCircle(
      bc.translate(0, 2),
      14,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );
    canvas.drawCircle(
      bc,
      14,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.4),
          colors: [Color(0xFFFFFFFF), Color(0xFFC9C4DA)],
        ).createShader(Rect.fromCircle(center: bc, radius: 14)),
    );
    final iconColor = Color.lerp(
      const Color(0xFF9A94AF),
      const Color(0xFF8063C4),
      f.a,
    )!;
    final icon = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = iconColor;
    canvas.drawArc(
      Rect.fromCircle(center: bc, radius: 5.5),
      -math.pi / 2 + 0.7,
      math.pi * 2 - 1.4,
      false,
      icon,
    );
    canvas.drawLine(bc.translate(0, -6.5), bc.translate(0, -1), icon);
  }

  void _text(
    Canvas canvas,
    String s,
    Offset center,
    double size,
    Color color, {
    FontWeight weight = FontWeight.w700,
    double ls = 0,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          fontSize: size,
          color: color,
          fontWeight: weight,
          letterSpacing: ls,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  // -- door ----------------------------------------------------------------

  void _drawDoor(Canvas canvas) {
    const c = _c;

    // Light spilling out of the drum while it runs.
    if (f.a > 0) {
      final pulse = 0.85 + 0.15 * math.sin(f.t * 3);
      canvas.drawCircle(
        c,
        _r + 16,
        Paint()
          ..color = const Color(0xFF7DB8FF)
              .withValues(alpha: 0.38 * f.a * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }

    // Chrome ring.
    canvas.drawCircle(
      c.translate(0, 5),
      _r,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(
      c,
      _r,
      Paint()
        ..shader = const SweepGradient(
          colors: [
            Color(0xFFF7F6FB),
            Color(0xFFB4B0C6),
            Color(0xFFFFFFFF),
            Color(0xFF9A96AE),
            Color(0xFFE9E7F2),
            Color(0xFFF7F6FB),
          ],
          transform: GradientRotation(-0.6),
        ).createShader(Rect.fromCircle(center: c, radius: _r)),
    );
    // Bevel.
    canvas.drawCircle(
      c,
      _r - 7,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8E8AA3), Color(0xFFF1F0F7)],
        ).createShader(Rect.fromCircle(center: c, radius: _r - 7)),
    );
    // Rubber seal.
    canvas.drawCircle(
      c,
      _r - 14,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.4),
          colors: [Color(0xFF3A3449), Color(0xFF1E1A28)],
        ).createShader(Rect.fromCircle(center: c, radius: _r - 14)),
    );

    // Hinge and latch.
    final latch = RRect.fromRectAndRadius(
      Rect.fromLTWH(c.dx + _r - 4, c.dy - 16, 11, 32),
      const Radius.circular(5),
    );
    canvas.drawRRect(
      latch,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFF9F9AB5)],
        ).createShader(latch.outerRect),
    );

    // Glass interior.
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: _g)));

    canvas.drawCircle(
      c,
      _g,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.25, -0.3),
          colors: [Color(0xFF55507A), Color(0xFF241F36), Color(0xFF0F0D17)],
          stops: [0, 0.55, 1],
        ).createShader(Rect.fromCircle(center: c, radius: _g)),
    );

    // Rotating drum: perforations and light swirl.
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(_angle);
    canvas.drawCircle(
      Offset.zero,
      _g,
      Paint()
        ..shader = SweepGradient(
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.11),
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.11),
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.11),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: _g)),
    );
    const rings = [(22.0, 10), (40.0, 18), (58.0, 26)];
    final hole = Paint()
      ..color = const Color(0xFF8D88B3).withValues(alpha: 0.55);
    for (final ring in rings) {
      for (var i = 0; i < ring.$2; i++) {
        final a = math.pi * 2 * i / ring.$2;
        canvas.drawCircle(
          Offset(math.cos(a), math.sin(a)) * ring.$1,
          2.2,
          hole,
        );
      }
    }
    canvas.restore();

    _drawClothes(canvas);
    if (f.b > 0.01) _drawWater(canvas);

    // Edge vignette for depth.
    canvas.drawCircle(
      c,
      _g,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.45)],
          stops: const [0.6, 1],
        ).createShader(Rect.fromCircle(center: c, radius: _g)),
    );
    canvas.restore();

    // Glass reflections.
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: _g)));
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-0.7);
    final sheen = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(-18, -36), width: 120, height: 38),
      const Radius.circular(19),
    );
    canvas.drawRRect(
      sheen,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.32),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(sheen.outerRect),
    );
    canvas.restore();

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
    final arcRect = Rect.fromCircle(center: c, radius: _g - 7);
    canvas.drawArc(
      arcRect,
      -2.75,
      1.0,
      false,
      arc
        ..strokeWidth = 5
        ..color = Colors.white.withValues(alpha: 0.6),
    );
    canvas.drawArc(
      arcRect,
      0.45,
      0.7,
      false,
      arc
        ..strokeWidth = 3
        ..color = Colors.white.withValues(alpha: 0.22),
    );
    canvas.drawCircle(
      c,
      _g,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.16),
    );
    canvas.drawCircle(
      c,
      _g + 1,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.black.withValues(alpha: 0.5),
    );
  }

  void _drawClothes(Canvas canvas) {
    final e = Curves.easeInOut.transform(f.a.clamp(0.0, 1.0));
    for (final cl in _clothes) {
      final theta = _angle * 0.85 + cl.phase;
      final rho = cl.rho + math.sin(theta * 2 + cl.phase) * 6;
      final orbit = Offset(math.cos(theta), math.sin(theta)) * rho;
      final pos = Offset.lerp(cl.pile, orbit, e)!;
      final rot = e * theta * 0.7 + cl.phase * 0.4 * (1 - e);

      canvas.save();
      canvas.translate(_c.dx + pos.dx, _c.dy + pos.dy);
      canvas.rotate(rot);
      final rr = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: cl.w, height: cl.h),
        const Radius.circular(10),
      );
      canvas.drawRRect(
        rr.shift(const Offset(0, 2.5)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
      canvas.drawRRect(
        rr,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [cl.light, cl.dark],
          ).createShader(rr.outerRect),
      );
      final fold = Paint()
        ..color = Colors.white.withValues(alpha: 0.38)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(-cl.w * 0.28, -cl.h * 0.12),
        Offset(cl.w * 0.28, cl.h * 0.16),
        fold,
      );
      canvas.drawLine(
        Offset(-cl.w * 0.2, cl.h * 0.2),
        Offset(cl.w * 0.08, cl.h * 0.34),
        fold..color = Colors.black.withValues(alpha: 0.12),
      );
      canvas.restore();
    }
  }

  void _drawWater(Canvas canvas) {
    final level = Curves.easeOut.transform(f.b.clamp(0.0, 1.0));
    final surface = _c.dy + _g - (_g * 2 * 0.52) * level;
    final wave = 3 + 2 * f.a;

    double surfaceAt(double x) =>
        surface +
        math.sin(x * 0.09 + f.t * 3.2) * wave +
        math.sin(x * 0.17 - f.t * 2.1) * wave * 0.5;

    final fill = Path()..moveTo(_c.dx - _g - 2, surfaceAt(-_g - 2));
    final line = Path()..moveTo(_c.dx - _g - 2, surfaceAt(-_g - 2));
    for (var x = -_g - 2; x <= _g + 2; x += 4) {
      fill.lineTo(_c.dx + x, surfaceAt(x));
      line.lineTo(_c.dx + x, surfaceAt(x));
    }
    fill
      ..lineTo(_c.dx + _g + 2, _c.dy + _g + 2)
      ..lineTo(_c.dx - _g - 2, _c.dy + _g + 2)
      ..close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF9BDDFF).withValues(alpha: 0.55),
                const Color(0xFF3B86D9).withValues(alpha: 0.78),
              ],
            ).createShader(
              Rect.fromLTRB(_c.dx - _g, surface - 8, _c.dx + _g, _c.dy + _g),
            ),
    );
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = Colors.white.withValues(alpha: 0.65),
    );

    // Suds along the waterline.
    if (f.a > 0.2) {
      final suds = Paint()..color = Colors.white.withValues(alpha: 0.8 * f.a);
      final rim = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = const Color(0xFFBFE6FF).withValues(alpha: 0.9 * f.a);
      for (var i = 0; i < 14; i++) {
        final x = -_g + (i + 0.5) * (2 * _g / 14);
        final r = 4.5 + 4.5 * rand(i * 2.3);
        final p = Offset(
          _c.dx + x,
          surfaceAt(x) - 1 + math.sin(f.t * 2 + i) * 1.2,
        );
        canvas.drawCircle(p, r, suds);
        canvas.drawCircle(p, r, rim);
      }
    }

    // Rising bubbles.
    final bottom = _c.dy + _g * 0.9;
    if (surface < bottom) {
      for (var i = 0; i < 16; i++) {
        final speed = 0.10 + 0.12 * rand(i * 3.7);
        final life = (f.t * speed + rand(i * 1.9)) % 1.0;
        final x =
            _c.dx +
            (rand(i * 5.3) - 0.5) * _g * 1.6 +
            math.sin(f.t * 2 + i) * 4;
        final y = bottom - (bottom - surface) * life;
        final r = 2 + 3.2 * rand(i * 9.1);
        final a = f.b * (life < 0.1 ? life / 0.1 : 1.0);
        final p = Offset(x, y);
        canvas.drawCircle(
          p,
          r,
          Paint()..color = Colors.white.withValues(alpha: 0.12 * a),
        );
        canvas.drawCircle(
          p,
          r,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = Colors.white.withValues(alpha: 0.7 * a),
        );
        canvas.drawCircle(
          p.translate(-r * 0.35, -r * 0.35),
          r * 0.25,
          Paint()..color = Colors.white.withValues(alpha: 0.9 * a),
        );
      }
    }
  }

  // -- bottom --------------------------------------------------------------

  void _drawBottom(Canvas canvas) {
    for (var i = 0; i < 3; i++) {
      final y = 326.0 + i * 8;
      final slot = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(150, y), width: 92, height: 3.2),
        const Radius.circular(2),
      );
      canvas.drawRRect(
        slot.shift(const Offset(0, 1.2)),
        Paint()..color = Colors.white,
      );
      canvas.drawRRect(
        slot,
        Paint()..color = Colors.black.withValues(alpha: 0.12),
      );
    }
    for (final x in [_body.left + 22, _body.right - 58]) {
      final foot = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, _body.bottom - 2, 36, 9),
        const Radius.circular(4),
      );
      canvas.drawRRect(foot, Paint()..color = const Color(0xFF2B2637));
    }
  }
}
