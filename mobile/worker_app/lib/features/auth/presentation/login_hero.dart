import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../shared/widgets/art.dart';
import '../../../shared/widgets/motion.dart';

const _slides = <(HeroScene, String, String)>[
  (HeroScene.earn, 'Earn on every job', 'See your pay add up, day by day'),
  (HeroScene.flexible, 'Work your own shift', 'Go online when it suits you'),
  (HeroScene.safe, 'Protected at work', 'Insurance and one-tap SOS'),
];

/// Swipeable, self-advancing illustrations on the sign-in screen.
class LoginHero extends StatefulWidget {
  const LoginHero({super.key});

  @override
  State<LoginHero> createState() => _LoginHeroState();
}

class _LoginHeroState extends State<LoginHero> {
  final _pages = PageController();
  Timer? _auto;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _restart();
  }

  void _restart() {
    _auto?.cancel();
    _auto = Timer.periodic(const Duration(milliseconds: 3200), (_) {
      if (!mounted || !_pages.hasClients) return;
      _pages.animateToPage(
        (_index + 1) % _slides.length,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _auto?.cancel();
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.softLavender, AppColors.roseSoft],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: _slides.length,
                onPageChanged: (i) {
                  setState(() => _index = i);
                  _restart();
                },
                itemBuilder: (context, i) {
                  final (scene, title, subtitle) = _slides[i];
                  return LayoutBuilder(
                    builder: (context, c) => Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: ExcludeSemantics(
                              child: Loop(
                                duration: const Duration(seconds: 5),
                                active: i == _index,
                                builder: (context, t) => CustomPaint(
                                  size: Size.infinite,
                                  painter: HeroArtPainter(scene, t),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Drop the caption when the keyboard squeezes the hero.
                        if (c.maxHeight > 190) ...[
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: PageDots(count: _slides.length, index: _index),
            ),
          ],
        ),
      ),
    );
  }
}

class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (var i = 0; i < count; i++)
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: i == index ? 20 : 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: i == index ? AppColors.lavender : AppColors.lavenderLight,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
    ],
  );
}
