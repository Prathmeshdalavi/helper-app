import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../domain/shop_item.dart';

/// Drawn product pictures, in a 100x100 space.
class ProductPicture extends StatelessWidget {
  const ProductPicture(this.art, {super.key});

  final ProductArt art;

  @override
  Widget build(BuildContext context) => FittedBox(
    child: CustomPaint(
      size: const Size.square(100),
      painter: _ProductPainter(art),
    ),
  );
}

class _ProductPainter extends CustomPainter {
  _ProductPainter(this.art);

  final ProductArt art;

  @override
  void paint(Canvas canvas, Size size) {
    Paint fill(Color c) => Paint()..color = c;
    Paint line(Color c, [double w = 4]) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = w;
    void box(double l, double t, double w, double h, Color c, [double r = 6]) =>
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(l, t, w, h),
            Radius.circular(r),
          ),
          fill(c),
        );

    canvas.drawOval(
      const Rect.fromLTWH(18, 88, 64, 8),
      fill(AppColors.shadow.withValues(alpha: 0.1)),
    );

    switch (art) {
      case ProductArt.apron:
        canvas.drawArc(
          const Rect.fromLTWH(36, 6, 28, 30),
          math.pi,
          math.pi,
          false,
          line(AppColors.lavenderDeep),
        );
        canvas.drawPath(
          Path()
            ..moveTo(36, 20)
            ..lineTo(64, 20)
            ..lineTo(68, 42)
            ..lineTo(80, 88)
            ..lineTo(20, 88)
            ..lineTo(32, 42)
            ..close(),
          fill(AppColors.lavender),
        );
        box(34, 56, 32, 18, AppColors.lavenderLight);
        canvas.drawLine(
          const Offset(32, 44),
          const Offset(68, 44),
          line(AppColors.softRose),
        );
      case ProductArt.tunic:
        canvas.drawPath(
          Path()
            ..moveTo(36, 12)
            ..quadraticBezierTo(50, 26, 64, 12)
            ..lineTo(88, 28)
            ..lineTo(78, 44)
            ..lineTo(70, 38)
            ..lineTo(76, 88)
            ..lineTo(24, 88)
            ..lineTo(30, 38)
            ..lineTo(22, 44)
            ..lineTo(12, 28)
            ..close(),
          fill(AppColors.lavender),
        );
        canvas.drawLine(
          const Offset(50, 22),
          const Offset(50, 54),
          line(AppColors.softRose, 3),
        );
      case ProductArt.cycle:
      case ProductArt.cyclePlan:
        for (final x in [24.0, 76.0]) {
          canvas
            ..drawCircle(Offset(x, 66), 20, line(AppColors.hair, 3))
            ..drawCircle(Offset(x, 66), 3, fill(AppColors.hair));
        }
        canvas.drawPath(
          Path()
            ..moveTo(24, 66)
            ..lineTo(36, 40)
            ..moveTo(24, 66)
            ..lineTo(50, 66)
            ..quadraticBezierTo(60, 62, 68, 36)
            ..lineTo(76, 66)
            ..moveTo(50, 66)
            ..lineTo(36, 40)
            ..moveTo(68, 36)
            ..lineTo(64, 26)
            ..lineTo(56, 28),
          line(AppColors.lavender),
        );
        box(28, 34, 16, 6, AppColors.hair, 3);
        box(70, 30, 18, 14, AppColors.softRose, 4);
        if (art == ProductArt.cyclePlan) {
          canvas
            ..drawCircle(const Offset(50, 20), 15, fill(AppColors.gold))
            ..drawCircle(const Offset(50, 20), 15, line(AppColors.warning, 2));
          final rupee = TextPainter(
            text: const TextSpan(
              text: '₹',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          rupee.paint(
            canvas,
            Offset(50 - rupee.width / 2, 20 - rupee.height / 2),
          );
        }
      case ProductArt.careKit:
        box(14, 30, 72, 54, AppColors.softRose, 12);
        box(14, 30, 72, 20, AppColors.roseDeep, 10);
        box(45, 56, 10, 22, AppColors.white, 3);
        box(39, 62, 22, 10, AppColors.white, 3);
      case ProductArt.bag:
        canvas.drawArc(
          const Rect.fromLTWH(32, 14, 36, 40),
          math.pi,
          math.pi,
          false,
          line(AppColors.lavenderDeep, 5),
        );
        box(20, 34, 60, 54, AppColors.lavenderLight, 10);
        canvas.drawCircle(const Offset(50, 62), 11, fill(AppColors.lavender));
      case ProductArt.bottle:
        box(40, 8, 20, 12, AppColors.hair, 4);
        box(34, 20, 32, 68, AppColors.lavender, 12);
        box(34, 46, 32, 18, AppColors.softRose, 2);
        box(40, 26, 5, 16, AppColors.white.withValues(alpha: 0.5), 3);
      case ProductArt.umbrella:
        canvas.drawArc(
          const Rect.fromLTWH(10, 14, 80, 72),
          math.pi,
          math.pi,
          true,
          fill(AppColors.lavender),
        );
        canvas.drawPath(
          Path()
            ..moveTo(50, 50)
            ..lineTo(50, 80)
            ..quadraticBezierTo(50, 90, 40, 86),
          line(AppColors.hair),
        );
        canvas.drawLine(
          const Offset(50, 8),
          const Offset(50, 16),
          line(AppColors.hair),
        );
    }
  }

  @override
  bool shouldRepaint(covariant _ProductPainter old) => old.art != art;
}
