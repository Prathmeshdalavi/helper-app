import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'scene_kit.dart';

/// A sponge scrubbing a plate clean under a running tap, with suds, sparkles
/// and a stack of finished plates.
class DishesPainter extends ScenePainter {
  DishesPainter(super.f, super.repaint);

  static const _pc = Offset(140, 214);
  static const _rx = 104.0;
  static const _ry = 80.0;

  static const _stains = <(Offset, double, Color)>[
    (Offset(-34, -10), 20, Color(0xFFE58B4B)),
    (Offset(26, -24), 15, Color(0xFFA66A3A)),
    (Offset(38, 14), 18, Color(0xFFE58B4B)),
    (Offset(-12, 24), 14, Color(0xFF7DB36A)),
    (Offset(-50, 18), 11, Color(0xFFA66A3A)),
    (Offset(8, -2), 13, Color(0xFFD9A441)),
  ];

  Offset _sponge(double r) =>
      _pc + Offset(math.cos(r * 2.2) * 42, math.sin(r * 3.3) * 24);

  @override
  void draw(Canvas canvas) {
    backdropBlob(canvas, const Color(0xFFCFE6FA));
    _stack(canvas);
    _plate(canvas);
    _faucet(canvas);
    _foam(canvas);
    _spongeBody(canvas);
    _bubbles(canvas);
    _sparkles(canvas);
  }

  // -- stack of clean plates ------------------------------------------------

  void _stack(Canvas canvas) {
    floorShadow(canvas, const Offset(150, 352), 190, 18, alpha: 0.2);
    for (var i = 0; i < 3; i++) {
      final c = Offset(150, 338 - i * 9.0);
      final r = Rect.fromCenter(center: c, width: 150, height: 26);
      canvas.drawOval(
        r.shift(const Offset(0, 4)),
        Paint()..color = const Color(0xFFBBB5D2),
      );
      canvas.drawOval(
        r,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFEAE6F6)],
          ).createShader(r),
      );
      canvas.drawOval(
        r.deflate(6),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3
          ..color = const Color(0xFF8FB8E8).withValues(alpha: 0.7),
      );
    }
  }

  // -- main plate -----------------------------------------------------------

  void _plate(Canvas canvas) {
    final outer = Rect.fromCenter(center: _pc, width: _rx * 2, height: _ry * 2);
    canvas.drawOval(
      outer.shift(const Offset(0, 8)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );
    canvas.drawOval(
      outer,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFE3E0F2)],
        ).createShader(outer),
    );
    canvas.drawOval(
      outer.deflate(3),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = Colors.white,
    );
    // Painted blue ring.
    canvas.drawOval(
      outer.deflate(14),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFF8FB8E8).withValues(alpha: 0.8),
    );

    // Well of the plate.
    final well = Rect.fromCenter(
      center: _pc.translate(0, 2),
      width: _rx * 1.5,
      height: _ry * 1.5,
    );
    canvas.drawOval(
      well,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD9D5EA), Color(0xFFF7F6FC)],
        ).createShader(well),
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(well));
    _stainsLayer(canvas);
    // Wet gloss drifting across the plate.
    final sweep = ((f.run * 0.25) % 1) * (_rx * 3) - _rx * 1.5;
    canvas.save();
    canvas.translate(_pc.dx + sweep, _pc.dy);
    canvas.rotate(-0.6);
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: 22, height: 260),
      Paint()..color = Colors.white.withValues(alpha: 0.35 * f.a),
    );
    canvas.restore();
    canvas.restore();
  }

  void _stainsLayer(Canvas canvas) {
    final cyc = (f.run / 8) % 1;
    for (var i = 0; i < _stains.length; i++) {
      final st = _stains[i];
      final cleaned =
          smooth(0.05 + i * 0.1, 0.25 + i * 0.1, cyc) *
          (1 - smooth(0.9, 1, cyc));
      final dirty = 1 - cleaned;
      if (dirty <= 0.02) continue;
      final p = _pc + st.$1;
      canvas.drawOval(
        Rect.fromCenter(center: p, width: st.$2 * 2.1, height: st.$2 * 1.5),
        Paint()
          ..color = st.$3.withValues(alpha: 0.85 * dirty)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: p.translate(-st.$2 * 0.25, -st.$2 * 0.2),
          width: st.$2 * 0.8,
          height: st.$2 * 0.5,
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.35 * dirty),
      );
    }
  }

  // -- faucet ---------------------------------------------------------------

  void _faucet(Canvas canvas) {
    final chrome = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFC9C5DA);
    final spout = Path()
      ..moveTo(262, 92)
      ..lineTo(262, 52)
      ..quadraticBezierTo(262, 26, 232, 26)
      ..lineTo(196, 26)
      ..lineTo(196, 40);
    canvas.drawPath(
      spout.shift(const Offset(0, 3)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..color = Colors.black.withValues(alpha: 0.12),
    );
    canvas.drawPath(spout, chrome);
    canvas.drawPath(
      spout.shift(const Offset(-2, -2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.7),
    );
    // Handle.
    canvas.save();
    canvas.translate(262, 76);
    canvas.rotate(-0.5 * f.a);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-4, -4, 26, 8),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF8E73D2),
    );
    canvas.restore();

    // Water stream.
    if (f.a < 0.02) return;
    const x = 196.0;
    const y0 = 48.0;
    const y1 = 142.0;
    final w = 7.0 * f.a;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(x - w / 2, y0, x + w / 2, y1),
        Radius.circular(w / 2),
      ),
      Paint()..color = const Color(0xFF9BDDFF).withValues(alpha: 0.5 * f.a),
    );
    for (var k = 0; k < 6; k++) {
      final y = y0 + ((f.run * 70 + k * 16) % (y1 - y0));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y), width: w * 0.7, height: 12),
          const Radius.circular(3),
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.7 * f.a),
      );
    }
    // Splash.
    for (var k = 0; k < 7; k++) {
      final life = (f.run * 1.6 + k * 0.14) % 1;
      final dir = (k - 3) * 0.42;
      final p = Offset(
        x + math.sin(dir) * 28 * life,
        y1 -
            math.cos(dir * 0.8) * 26 * math.sin(life * math.pi) +
            10 * life * life,
      );
      canvas.drawCircle(
        p,
        2.2 * (1 - life * 0.4),
        Paint()
          ..color = const Color(0xFFBFE6FF)
              .withValues(alpha: 0.9 * f.a * (1 - life)),
      );
    }
  }

  // -- sponge, foam ---------------------------------------------------------

  void _foam(Canvas canvas) {
    if (f.a < 0.02) return;
    for (var k = 0; k < 16; k++) {
      final p = _sponge(f.run - k * 0.12);
      final off = Offset(
        (rand(k * 2.3) - 0.5) * 34,
        (rand(k * 4.1) - 0.5) * 16,
      );
      final grow = smooth(0, 0.5, f.a);
      final r = (6 + 8 * rand(k * 7.1)) * grow;
      final fade = 1 - k / 18;
      final c = p + off;
      canvas.drawCircle(
        c,
        r,
        Paint()..color = Colors.white.withValues(alpha: 0.92 * fade),
      );
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9
          ..color = const Color(0xFFBFD8F5).withValues(alpha: 0.9 * fade),
      );
      canvas.drawCircle(
        c.translate(-r * 0.3, -r * 0.3),
        r * 0.22,
        Paint()..color = Colors.white.withValues(alpha: fade),
      );
    }
  }

  void _spongeBody(Canvas canvas) {
    final p = _sponge(f.run);
    final rot = math.sin(f.run * 2.2) * 0.28;
    final squish = 1 - 0.06 * math.sin(f.run * 6.6) * f.a;

    canvas.drawOval(
      Rect.fromCenter(center: p.translate(4, 22), width: 74, height: 16),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.save();
    canvas.translate(p.dx, p.dy);
    canvas.rotate(rot);
    canvas.scale(1, squish);

    final side = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, 8), width: 68, height: 34),
      const Radius.circular(11),
    );
    canvas.drawRRect(side, Paint()..color = const Color(0xFFD9A02B));
    final top = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, -2), width: 68, height: 34),
      const Radius.circular(11),
    );
    canvas.drawRRect(
      top,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE27A), Color(0xFFF5C03E)],
        ).createShader(top.outerRect),
    );
    for (var i = 0; i < 9; i++) {
      canvas.drawCircle(
        Offset(-26 + rand(i * 3.3) * 52, -12 + rand(i * 6.1) * 20),
        1.6 + rand(i * 8.2) * 2.2,
        Paint()..color = const Color(0xFFE0A726).withValues(alpha: 0.75),
      );
    }
    // Green scrubber layer on the underside.
    final scrub = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, 17), width: 68, height: 10),
      const Radius.circular(5),
    );
    canvas.drawRRect(scrub, Paint()..color = const Color(0xFF58B97C));
    canvas.drawLine(
      const Offset(-26, -10),
      const Offset(20, -12),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  void _bubbles(Canvas canvas) {
    for (var i = 0; i < 7; i++) {
      final life = (f.run * 0.22 + rand(i * 1.9)) % 1;
      final base = _sponge(f.run - i * 0.3);
      drawBubble(
        canvas,
        Offset(
          base.dx + math.sin(life * 7 + i) * 14,
          base.dy - 20 - life * 110,
        ),
        4 + 6 * rand(i * 2.7),
        alpha: f.a * math.sin(life * math.pi),
      );
    }
  }

  void _sparkles(Canvas canvas) {
    // Twinkles on the finished plates and the rim of the main plate.
    for (var k = 0; k < 5; k++) {
      final tw = math.max(0.0, math.sin(f.t * 4 + k * 2.3));
      final pos = k < 3
          ? Offset(95 + k * 55.0 + rand(k * 1.0) * 10, 322 - rand(k * 2.0) * 8)
          : _pc + Offset((k - 3.5) * 110, -50 + (k - 3) * 40);
      drawSparkle(canvas, pos, 8 * tw * f.a, alpha: f.a);
    }
  }
}
