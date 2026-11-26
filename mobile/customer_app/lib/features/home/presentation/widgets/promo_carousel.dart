import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/app_theme.dart';
import '../../../../app/router/routes.dart';
import '../../../../shared/widgets/app_photo.dart';
import 'common.dart';

class _Promo {
  const _Promo({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.cta,
    this.alignment = Alignment.center,
  });

  final String image;
  final String title;
  final String subtitle;
  final String cta;
  final Alignment alignment;
}

const _promos = <_Promo>[
  _Promo(
    image: 'assets/images/banner_living.jpg',
    title: 'Your first booking,\n20% off',
    subtitle: 'Use code HERCARE20',
    cta: 'Book now',
    alignment: Alignment(0, 0.1),
  ),
  _Promo(
    image: 'assets/images/banner_bedroom.jpg',
    title: 'A helper for\nthe full day',
    subtitle: 'Set it up once, then relax',
    cta: 'See plans',
  ),
  _Promo(
    image: 'assets/images/banner_plants.jpg',
    title: 'Monthly plans,\nsave up to 25%',
    subtitle: 'The same helper, every visit',
    cta: 'Explore',
    alignment: Alignment(0, -0.15),
  ),
];

/// Photo offer banners that advance on their own.
class PromoCarousel extends StatefulWidget {
  const PromoCarousel({super.key});

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  final _controller = PageController(viewportFraction: 0.9);
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_controller.hasClients) return;
      _controller.animateToPage(
        (_page + 1) % _promos.length,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 168,
          child: Listener(
            // Pause auto-advance while the user is touching the banners.
            onPointerDown: (_) => _timer?.cancel(),
            onPointerUp: (_) => _startTimer(),
            child: PageView.builder(
              controller: _controller,
              itemCount: _promos.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _Banner(promo: _promos[i]),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _promos.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _page ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _page
                      ? AppColors.lavender
                      : AppColors.lavender.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.promo});

  final _Promo promo;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => context.push(Routes.schedule),
      scale: 0.985,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppPhoto(promo.image, alignment: promo.alignment, cacheWidth: 900),
            // Left-to-right scrim keeps the text legible; the photo shows on the right.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xCC090909),
                    Color(0x66090909),
                    Color(0x00090909),
                  ],
                  stops: [0, 0.55, 1],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text shrinks (with ellipsis) before it can overflow, so
                  // large system fonts cannot break the banner.
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            promo.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              height: 1.15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          promo.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xE6FFFFFF),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      promo.cta,
                      style: const TextStyle(
                        color: AppColors.lavender,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
