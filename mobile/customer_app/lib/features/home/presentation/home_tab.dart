import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'widgets/book_options.dart';
import 'widgets/common.dart';
import 'widgets/home_hero.dart';
import 'widgets/promo_carousel.dart';
import 'widgets/service_sections.dart';

/// The main feed: a photo header with a white sheet that slides over it.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  static const _heroHeight = 340.0;
  static const _overlap = 28.0;

  final _scroll = ScrollController();
  bool _solidBar = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final solid = _scroll.offset > _heroHeight - _overlap - 40;
      if (solid != _solidBar) setState(() => _solidBar = solid);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Light status-bar icons over the photo, dark once the sheet is on top.
      value: _solidBar ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
      child: Stack(
        children: [
          SingleChildScrollView(
            controller: _scroll,
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              children: [
                const HomeHero(height: _heroHeight),
                Transform.translate(
                  offset: const Offset(0, -_overlap),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 22),
                    child: const _Sheet(),
                  ),
                ),
              ],
            ),
          ),
          // Solid strip behind the status bar once content scrolls under it.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _solidBar ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: Container(height: topInset, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Reveal(
          index: 0,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: HomeSearch(),
          ),
        ),
        SizedBox(height: 24),
        Reveal(
          index: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle('Book a helper'),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: BookOptions(),
              ),
            ],
          ),
        ),
        SizedBox(height: 30),
        Reveal(
          index: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [SectionTitle('Our services'), ServiceGrid()],
          ),
        ),
        SizedBox(height: 30),
        Reveal(index: 3, child: PromoCarousel()),
        SizedBox(height: 30),
        Reveal(index: 4, child: TrustRow()),
        SizedBox(height: 30),
        Reveal(
          index: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [SectionTitle('How it works'), HowItWorks()],
          ),
        ),
        SizedBox(height: 36),
        BrandFooter(),
      ],
    );
  }
}
