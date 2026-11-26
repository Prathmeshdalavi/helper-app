import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../app/app_theme.dart';

/// Drives a 0..1 value round and round. Stands still when the phone asks for
/// reduced motion.
class Loop extends StatefulWidget {
  const Loop({
    super.key,
    required this.duration,
    required this.builder,
    this.active = true,
  });

  final Duration duration;
  final bool active;
  final Widget Function(BuildContext context, double t) builder;

  @override
  State<Loop> createState() => _LoopState();
}

class _LoopState extends State<Loop> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: widget.duration);

  void _sync() {
    final run = widget.active && !MediaQuery.disableAnimationsOf(context);
    if (run && !_c.isAnimating) _c.repeat();
    if (!run) _c.stop();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(Loop old) {
    super.didUpdateWidget(old);
    _sync();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (context, _) => widget.builder(context, _c.value),
  );
}

/// A number that rolls up to its value, and rolls again when it changes.
class CountUp extends StatelessWidget {
  const CountUp({
    super.key,
    required this.value,
    required this.format,
    this.style,
  });

  final num value;
  final String Function(num) format;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: format(value),
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.toDouble()),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => Text(format(v.round()), style: style),
      ),
    );
  }
}

/// Fades and slides a section up when it first appears.
class Reveal extends StatelessWidget {
  const Reveal({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + index * 80),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 20),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Expanding rings behind [child], for "live" states.
class PulseRings extends StatelessWidget {
  const PulseRings({
    super.key,
    required this.size,
    required this.child,
    this.color = AppColors.lavender,
    this.active = true,
  });

  final double size;
  final Widget child;
  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Loop(
        active: active,
        duration: const Duration(milliseconds: 2200),
        builder: (context, t) => Stack(
          alignment: Alignment.center,
          children: [
            if (active)
              for (var i = 0; i < 3; i++) _ring((t + i / 3) % 1),
            child,
          ],
        ),
      ),
    );
  }

  Widget _ring(double p) => Container(
    width: size * (0.45 + 0.55 * p),
    height: size * (0.45 + 0.55 * p),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withValues(alpha: 0.22 * (1 - p)),
    ),
  );
}

/// One burst of confetti over the whole of its box.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({super.key});

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: CustomPaint(size: Size.infinite, painter: _ConfettiPainter(_c)),
  );
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t) : super(repaint: t);

  final Animation<double> t;

  static const _colors = [
    AppColors.lavender,
    AppColors.softRose,
    AppColors.gold,
    AppColors.success,
    AppColors.lavenderLight,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final v = t.value;
    if (v >= 1) return;
    final rnd = math.Random(7);
    final origin = Offset(size.width / 2, size.height * 0.28);
    for (var i = 0; i < 110; i++) {
      final angle = rnd.nextDouble() * math.pi * 2;
      final speed = 80 + rnd.nextDouble() * 260;
      final spin = rnd.nextDouble() * 14 - 7;
      final burst = Curves.easeOutCubic.transform(math.min(1, v * 1.8));
      final p =
          origin +
          Offset(math.cos(angle), math.sin(angle)) * (speed * burst) +
          Offset(0, size.height * 0.55 * v * v);
      canvas
        ..save()
        ..translate(p.dx, p.dy)
        ..rotate(spin * v)
        ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: 8,
              height: 4 + 6 * math.cos(v * 9 + i).abs(),
            ),
            const Radius.circular(2),
          ),
          Paint()
            ..color = _colors[i % _colors.length].withValues(
              alpha: (1 - v).clamp(0, 0.5) * 2,
            ),
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => false;
}
