import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'scenes/cleaning_scene.dart';
import 'scenes/dishes_scene.dart';
import 'scenes/pet_scene.dart';
import 'scenes/scene_kit.dart';
import 'scenes/washing_machine_scene.dart';

class _Slide {
  const _Slide(this.title, this.subtitle);
  final String title;
  final String subtitle;
}

/// The pet scene leads; the others follow.
const _slides = <_Slide>[
  _Slide('Pet care, with love', 'Walks, play and feeding while you are away'),
  _Slide('Laundry, sorted', 'Fresh, folded clothes without lifting a finger'),
  _Slide('Spotless floors', 'Deep-cleaned by verified, trained helpers'),
  _Slide('Sparkling dishes', 'Dishwashing done before you sit down'),
];

/// How long each scene stays before the next one slides in.
const _autoAdvance = Duration(milliseconds: 2800);

/// Swipeable hero of animated scenes. The scene on screen runs by itself; the
/// one you leave winds down.
class HeroCarousel extends StatefulWidget {
  const HeroCarousel({super.key});

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _clock = ValueNotifier<double>(0);
  final _controller = PageController();
  final _frames = List.generate(_slides.length, (_) => SceneFrame());
  late final List<ScenePainter> _painters = [
    PetPainter(_frames[0], _clock),
    WashingMachinePainter(_frames[1], _clock),
    CleaningPainter(_frames[2], _clock),
    DishesPainter(_frames[3], _clock),
  ];
  Duration _last = Duration.zero;
  int _active = 0;
  Timer? _auto;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
    _restartAuto();
  }

  /// Moves to the next scene after a pause; a swipe restarts the pause.
  void _restartAuto() {
    _auto?.cancel();
    _auto = Timer.periodic(_autoAdvance, (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_active + 1) % _slides.length;
      _controller.animateToPage(
        next,
        duration: Duration(milliseconds: next == 0 ? 700 : 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  double _approach(double v, double target, double step) =>
      v < target ? math.min(v + step, target) : math.max(v - step, target);

  void _tick(Duration d) {
    final dt = ((d - _last).inMicroseconds / 1e6).clamp(0.0, 0.05).toDouble();
    _last = d;
    final t = d.inMicroseconds / 1e6;
    for (var i = 0; i < _frames.length; i++) {
      final fr = _frames[i];
      final on = i == _active;
      fr.a = _approach(fr.a, on ? 1 : 0, dt * (on ? 1.1 : 1.5));
      fr.b = _approach(fr.b, on ? 1 : 0, dt * (on ? 0.28 : 0.6));
      fr.run += dt * fr.a;
      fr.t = t;
    }
    _clock.value = t;
  }

  void _onPage(int i) {
    HapticFeedback.selectionClick();
    setState(() => _active = i);
    _restartAuto();
  }

  @override
  void dispose() {
    _auto?.cancel();
    _ticker.dispose();
    _clock.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return LayoutBuilder(
      builder: (context, c) {
        final showCaption = c.maxHeight > 420;
        final showDots = c.maxHeight > 240;
        return Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: _onPage,
                itemBuilder: (context, i) => AnimatedBuilder(
                  animation: Listenable.merge([_controller, _clock]),
                  builder: (context, child) {
                    var page = 0.0;
                    if (_controller.hasClients &&
                        _controller.position.haveDimensions) {
                      page = _controller.page ?? 0;
                    }
                    final off = (i - page).clamp(-1.0, 1.0).toDouble();
                    final sway = math.sin(_clock.value * 0.7) * 0.08;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..rotateY(off * 0.6 + sway)
                        ..rotateX(-0.04)
                        ..scaleByDouble(
                          1 - off.abs() * 0.12,
                          1 - off.abs() * 0.12,
                          1,
                          1,
                        ),
                      child: child,
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, top + 8, 24, 4),
                    child: CustomPaint(
                      painter: _painters[i],
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
            ),
            if (showCaption)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: Column(
                    key: ValueKey(_active),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _slides[_active].title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _slides[_active].subtitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B6577),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (showDots)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < _slides.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _active ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: i == _active
                              ? const Color(0xFF8063C4)
                              : const Color(0xFF8063C4).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
