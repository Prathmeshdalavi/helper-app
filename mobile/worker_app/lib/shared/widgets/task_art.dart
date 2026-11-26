import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../app/app_theme.dart';

/// The household tasks a job can include, each with its own drawing.
enum HomeTask {
  mopping('Mopping'),
  dusting('Dusting'),
  dishes('Dishes'),
  chopping('Veg prep'),
  surfaces('Surfaces'),
  bathroom('Bathroom'),
  laundry('Ironing'),
  fridge('Fridge'),
  tidying('Tidying');

  const HomeTask(this.label);
  final String label;
}

class TaskArt extends StatelessWidget {
  const TaskArt(this.task, {super.key, this.size = 64});

  final HomeTask task;
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _TaskPainter(task));
}

class _TaskPainter extends CustomPainter {
  _TaskPainter(this.task);

  final HomeTask task;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 64);
    Paint fill(Color c) => Paint()..color = c;
    Paint line(Color c, [double w = 4]) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w;
    void box(double l, double t, double w, double h, Color c, [double r = 4]) =>
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(l, t, w, h),
            Radius.circular(r),
          ),
          fill(c),
        );

    // Shared floor line.
    box(6, 54, 52, 4, AppColors.border);

    switch (task) {
      case HomeTask.mopping:
        canvas.drawLine(
          const Offset(44, 8),
          const Offset(34, 46),
          line(AppColors.warning),
        );
        box(24, 44, 22, 10, AppColors.lavender);
        box(8, 34, 16, 20, AppColors.softRose, 6);
        canvas.drawArc(
          const Rect.fromLTWH(8, 27, 16, 14),
          math.pi,
          math.pi,
          false,
          line(AppColors.lavenderDeep, 2),
        );
      case HomeTask.dusting:
        canvas.drawLine(
          const Offset(18, 52),
          const Offset(36, 28),
          line(AppColors.lavenderDeep, 5),
        );
        for (var i = 0; i < 7; i++) {
          final a = i / 7 * math.pi * 2;
          canvas.drawCircle(
            Offset(42 + math.cos(a) * 8, 22 + math.sin(a) * 8),
            7,
            fill(AppColors.softRose),
          );
        }
        canvas.drawCircle(const Offset(42, 22), 7, fill(AppColors.gold));
      case HomeTask.dishes:
        for (var i = 0; i < 3; i++) {
          canvas
            ..drawCircle(Offset(21.0 + i * 11, 32), 14, fill(AppColors.card))
            ..drawCircle(
              Offset(21.0 + i * 11, 32),
              14,
              line(AppColors.lavender, 2),
            );
        }
        box(8, 40, 48, 14, AppColors.lavender, 6);
      case HomeTask.chopping:
        box(8, 44, 48, 10, AppColors.warning);
        canvas
          ..drawCircle(const Offset(22, 35), 10, fill(AppColors.danger))
          ..drawCircle(const Offset(40, 34), 11, fill(AppColors.gold))
          ..drawLine(
            const Offset(40, 23),
            const Offset(40, 17),
            line(AppColors.success),
          )
          ..drawLine(
            const Offset(22, 25),
            const Offset(25, 19),
            line(AppColors.success),
          );
      case HomeTask.surfaces:
        box(16, 26, 18, 28, AppColors.lavender, 6);
        box(20, 16, 10, 12, AppColors.lavenderDeep);
        box(28, 16, 10, 5, AppColors.lavenderDeep);
        for (var i = 0; i < 3; i++) {
          canvas.drawCircle(Offset(46, 12.0 + i * 7), 2, fill(AppColors.info));
        }
        box(36, 42, 20, 12, AppColors.gold, 5);
      case HomeTask.bathroom:
        box(16, 12, 12, 28, AppColors.lavenderLight);
        box(18, 36, 30, 10, AppColors.lavender, 5);
        box(26, 44, 14, 10, AppColors.lavenderLight);
        canvas.drawCircle(const Offset(47, 20), 3, fill(AppColors.info));
        canvas.drawCircle(const Offset(52, 29), 2, fill(AppColors.info));
      case HomeTask.laundry:
        canvas.drawPath(
          Path()
            ..moveTo(10, 46)
            ..quadraticBezierTo(18, 24, 38, 26)
            ..lineTo(52, 28)
            ..lineTo(54, 46)
            ..close(),
          fill(AppColors.lavender),
        );
        box(10, 46, 44, 6, AppColors.lavenderDeep, 3);
        canvas.drawArc(
          const Rect.fromLTWH(24, 16, 24, 20),
          math.pi,
          math.pi,
          false,
          line(AppColors.softRose),
        );
      case HomeTask.fridge:
        box(18, 8, 28, 46, AppColors.lavenderLight, 7);
        box(18, 24, 28, 3, AppColors.card, 1);
        box(38, 13, 3, 8, AppColors.lavenderDeep, 2);
        box(38, 31, 3, 12, AppColors.lavenderDeep, 2);
      case HomeTask.tidying:
        box(8, 44, 48, 6, AppColors.lavenderDeep, 2);
        box(12, 22, 8, 22, AppColors.softRose, 2);
        box(22, 16, 8, 28, AppColors.gold, 2);
        box(32, 24, 7, 20, AppColors.info, 2);
        box(43, 34, 11, 10, AppColors.warning, 2);
        canvas.drawCircle(const Offset(48, 29), 7, fill(AppColors.success));
    }
  }

  @override
  bool shouldRepaint(covariant _TaskPainter old) => old.task != task;
}
