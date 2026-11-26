import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../app/app_theme.dart';

/// All the drawn artwork in the app. Everything is painted from brand colours,
/// so there are no image assets to license or ship.

/// HerCare coin: a gold disc with a lavender heart. Spins on its vertical axis
/// as [turn] goes from 0 to 1.
class CoinIcon extends StatelessWidget {
  const CoinIcon({super.key, this.size = 20, this.turn = 0});

  final double size;
  final double turn;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _CoinPainter(turn));
}

class _CoinPainter extends CustomPainter {
  _CoinPainter(this.turn);

  final double turn;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final squash = math.max(0.12, math.cos(turn * math.pi * 2).abs());
    canvas
      ..save()
      ..translate(c.dx, c.dy)
      ..scale(squash, 1)
      ..drawCircle(Offset.zero, r, Paint()..color = AppColors.warning)
      ..drawCircle(
        Offset(-r * 0.05, -r * 0.07),
        r * 0.92,
        Paint()..color = AppColors.gold,
      )
      ..drawCircle(
        Offset.zero,
        r * 0.66,
        Paint()..color = AppColors.white.withValues(alpha: 0.45),
      )
      ..drawPath(
        _heart(Offset.zero, r * 0.46),
        Paint()..color = AppColors.lavenderDeep,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(covariant _CoinPainter old) => old.turn != turn;
}

Path _heart(Offset c, double s) => Path()
  ..moveTo(c.dx, c.dy + s * 0.8)
  ..cubicTo(
    c.dx - s * 1.5,
    c.dy - s * 0.2,
    c.dx - s * 0.6,
    c.dy - s * 1.2,
    c.dx,
    c.dy - s * 0.35,
  )
  ..cubicTo(
    c.dx + s * 0.6,
    c.dy - s * 1.2,
    c.dx + s * 1.5,
    c.dy - s * 0.2,
    c.dx,
    c.dy + s * 0.8,
  )
  ..close();

void _sparkle(Canvas canvas, Offset p, double s, Color color) {
  if (s <= 0.2) return;
  canvas.drawPath(
    Path()
      ..moveTo(p.dx, p.dy - s)
      ..quadraticBezierTo(p.dx, p.dy, p.dx + s, p.dy)
      ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy + s)
      ..quadraticBezierTo(p.dx, p.dy, p.dx - s, p.dy)
      ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy - s),
    Paint()..color = color,
  );
}

/// Head-and-shoulders avatar of an expert. [seed] varies the colours.
class ExpertAvatar extends StatelessWidget {
  const ExpertAvatar({super.key, this.size = 56, this.seed = 0, this.label});

  final double size;
  final int seed;
  final String? label;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: label ?? 'Profile picture',
    child: ClipOval(
      child: CustomPaint(
        size: Size.square(size),
        painter: _AvatarPainter(seed),
      ),
    ),
  );
}

class _AvatarPainter extends CustomPainter {
  _AvatarPainter(this.seed);

  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100);
    const backs = [
      AppColors.softLavender,
      AppColors.roseSoft,
      AppColors.infoSoft,
      AppColors.warningSoft,
    ];
    const tops = [
      AppColors.lavender,
      AppColors.roseDeep,
      AppColors.info,
      AppColors.success,
    ];
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 100, 100),
      Paint()..color = backs[seed % 4],
    );
    drawExpert(canvas, top: tops[seed % 4]);
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter old) => old.seed != seed;
}

/// Draws a friendly bust in a 100x100 space.
void drawExpert(Canvas canvas, {Color top = AppColors.lavender}) {
  final hair = Paint()..color = AppColors.hair;
  final skin = Paint()..color = AppColors.skin;
  // Bun and hair behind the head.
  canvas
    ..drawCircle(const Offset(68, 26), 11, hair)
    ..drawCircle(const Offset(50, 43), 24, hair)
    // Shoulders.
    ..drawRRect(
      RRect.fromRectAndCorners(
        const Rect.fromLTWH(18, 70, 64, 40),
        topLeft: const Radius.circular(30),
        topRight: const Radius.circular(30),
      ),
      Paint()..color = top,
    )
    ..drawRect(const Rect.fromLTWH(44, 60, 12, 14), skin)
    ..drawCircle(const Offset(50, 48), 18, skin)
    // Fringe.
    ..drawPath(
      Path()
        ..moveTo(31, 46)
        ..quadraticBezierTo(33, 24, 52, 26)
        ..quadraticBezierTo(68, 28, 69, 46)
        ..quadraticBezierTo(58, 34, 46, 34)
        ..quadraticBezierTo(42, 44, 31, 46),
      hair,
    )
    ..drawCircle(const Offset(43, 49), 2, hair)
    ..drawCircle(const Offset(57, 49), 2, hair)
    ..drawArc(
      const Rect.fromLTWH(43, 51, 14, 9),
      0.3,
      math.pi - 0.6,
      false,
      Paint()
        ..color = AppColors.hair
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1.8,
    );
}

/// Which story a hero illustration tells.
enum HeroScene { earn, flexible, safe }

/// Large animated illustration for the sign-in screen and promos. [t] runs
/// 0..1 on a loop.
class HeroArtPainter extends CustomPainter {
  HeroArtPainter(this.scene, this.t);

  final HeroScene scene;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width / 300, size.height / 260);
    canvas
      ..translate((size.width - 300 * s) / 2, (size.height - 260 * s) / 2)
      ..scale(s);
    final wave = math.sin(t * math.pi * 2);
    canvas
      ..drawCircle(
        const Offset(150, 130),
        112 + wave * 3,
        Paint()..color = AppColors.white.withValues(alpha: 0.55),
      )
      ..drawCircle(
        const Offset(150, 130),
        82 - wave * 2,
        Paint()..color = AppColors.white.withValues(alpha: 0.7),
      )
      ..drawOval(
        const Rect.fromLTWH(70, 222, 160, 20),
        Paint()..color = AppColors.shadow.withValues(alpha: 0.1),
      );

    // The expert herself, gently bobbing.
    canvas
      ..save()
      ..translate(78, 78 + wave * 4)
      ..scale(1.45);
    drawExpert(
      canvas,
      top: switch (scene) {
        HeroScene.earn => AppColors.lavender,
        HeroScene.flexible => AppColors.roseDeep,
        HeroScene.safe => AppColors.lavenderDeep,
      },
    );
    canvas.restore();

    switch (scene) {
      case HeroScene.earn:
        for (var i = 0; i < 5; i++) {
          final p = (t + i / 5) % 1;
          final x = [48.0, 252.0, 74.0, 232.0, 272.0][i];
          final y = 220 - p * 200;
          canvas
            ..save()
            ..translate(x + math.sin(p * 8 + i) * 8, y);
          _CoinPainter((t * 2 + i / 5) % 1)
              .paint(canvas..translate(-14, -14), const Size(28, 28));
          canvas.restore();
        }
      case HeroScene.flexible:
        _clock(canvas, Offset(246, 70 + wave * 6), 30);
        _calendar(canvas, Offset(24, 148 - wave * 6));
      case HeroScene.safe:
        _shield(canvas, Offset(240, 150 + wave * 6), 34);
        canvas.drawPath(
          _heart(Offset(54, 72 - wave * 5), 20 + wave * 1.5),
          Paint()..color = AppColors.softRose,
        );
    }
    for (var i = 0; i < 6; i++) {
      final p = (t + i * 0.17) % 1;
      _sparkle(
        canvas,
        [
          const Offset(40, 40),
          const Offset(262, 118),
          const Offset(108, 22),
          const Offset(212, 28),
          const Offset(30, 120),
          const Offset(270, 214),
        ][i],
        9 * math.sin(p * math.pi),
        i.isEven ? AppColors.lavender : AppColors.softRose,
      );
    }
  }

  void _clock(Canvas canvas, Offset c, double r) {
    final hand = Paint()
      ..color = AppColors.lavenderDeep
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;
    canvas
      ..drawCircle(c, r, Paint()..color = AppColors.card)
      ..drawLine(
        c,
        c +
            Offset(math.cos(t * math.pi * 2), math.sin(t * math.pi * 2)) *
                (r * 0.68),
        hand,
      )
      ..drawLine(c, c + Offset(0, -r * 0.45), hand);
  }

  void _calendar(Canvas canvas, Offset o) {
    final body = RRect.fromRectAndRadius(
      o & const Size(64, 60),
      const Radius.circular(12),
    );
    canvas
      ..drawRRect(body, Paint()..color = AppColors.card)
      ..drawRRect(
        RRect.fromRectAndCorners(
          o & const Size(64, 16),
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
        ),
        Paint()..color = AppColors.softRose,
      );
    for (var row = 0; row < 2; row++) {
      for (var col = 0; col < 3; col++) {
        canvas.drawCircle(
          o + Offset(16.0 + col * 16, 30.0 + row * 16),
          5,
          Paint()
            ..color = row + col == (t * 4).floor()
                ? AppColors.lavender
                : AppColors.softLavender,
        );
      }
    }
  }

  void _shield(Canvas canvas, Offset c, double r) {
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy - r)
        ..lineTo(c.dx + r * 0.86, c.dy - r * 0.62)
        ..quadraticBezierTo(c.dx + r * 0.86, c.dy + r * 0.5, c.dx, c.dy + r)
        ..quadraticBezierTo(
          c.dx - r * 0.86,
          c.dy + r * 0.5,
          c.dx - r * 0.86,
          c.dy - r * 0.62,
        )
        ..close(),
      Paint()..color = AppColors.success,
    );
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - r * 0.34, c.dy)
        ..lineTo(c.dx - r * 0.08, c.dy + r * 0.26)
        ..lineTo(c.dx + r * 0.38, c.dy - r * 0.24),
      Paint()
        ..color = AppColors.white
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 5,
    );
  }

  @override
  bool shouldRepaint(covariant HeroArtPainter old) =>
      old.t != t || old.scene != scene;
}

/// A stylised street map. With [route] it also draws a path from the expert to
/// the customer, with the marker [progress] of the way along it.
class MapPainter extends CustomPainter {
  MapPainter({this.route = false, this.progress = 0});

  final bool route;
  final double progress;

  static Path routePath(Size s) => Path()
    ..moveTo(s.width * 0.16, s.height * 0.78)
    ..lineTo(s.width * 0.16, s.height * 0.52)
    ..lineTo(s.width * 0.54, s.height * 0.52)
    ..lineTo(s.width * 0.54, s.height * 0.24)
    ..lineTo(s.width * 0.82, s.height * 0.24);

  @override
  void paint(Canvas canvas, Size size) {
    // Blocks are drawn past the edges, so keep them inside the box.
    canvas.clipRect(Offset.zero & size);
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.softLavender,
    );
    final rnd = math.Random(11);
    final block = Paint()..color = AppColors.border;
    final park = Paint()..color = AppColors.successSoft;
    for (var y = -10.0; y < size.height; y += 58) {
      for (var x = -20.0; x < size.width; x += 74) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              x + rnd.nextDouble() * 8,
              y + rnd.nextDouble() * 6,
              52 + rnd.nextDouble() * 10,
              36 + rnd.nextDouble() * 10,
            ),
            const Radius.circular(10),
          ),
          rnd.nextInt(7) == 0 ? park : block,
        );
      }
    }
    final road = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    canvas
      ..drawLine(
        Offset(0, size.height * 0.52),
        Offset(size.width, size.height * 0.52),
        road,
      )
      ..drawLine(
        Offset(size.width * 0.54, 0),
        Offset(size.width * 0.54, size.height),
        road,
      )
      ..drawLine(
        Offset(size.width * 0.16, 0),
        Offset(size.width * 0.16, size.height),
        road,
      );

    if (!route) return;
    final path = routePath(size);
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.lavender
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 5,
    );
    final end = Offset(size.width * 0.82, size.height * 0.24);
    canvas
      ..drawCircle(end, 13, Paint()..color = AppColors.roseDeep)
      ..drawCircle(end, 5, Paint()..color = AppColors.white);
    final metric = path.computeMetrics().first;
    final at = metric
        .getTangentForOffset(metric.length * progress.clamp(0, 1))!
        .position;
    canvas
      ..drawCircle(at, 15, Paint()..color = AppColors.white)
      ..drawCircle(at, 10, Paint()..color = AppColors.lavender);
  }

  @override
  bool shouldRepaint(covariant MapPainter old) =>
      old.progress != progress || old.route != route;
}
