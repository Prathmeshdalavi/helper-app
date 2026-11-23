import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/app_theme.dart';
import '../../../../shared/widgets/app_photo.dart';
import '../../../auth/data/session.dart';
import 'common.dart';

/// Full-width photo at the top with the location row and greeting over it.
/// The white sheet below slides up over the bottom of this.
class HomeHero extends ConsumerWidget {
  const HomeHero({super.key, this.height = 340});

  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final name = session.firstName;
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const AppPhoto(
            'assets/images/hero_home.jpg',
            alignment: Alignment(0, -0.3),
            cacheWidth: 1000,
          ),
          // Scrim so white text stays readable on a bright photo.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x80000000),
                  Color(0x14000000),
                  Color(0x99000000),
                ],
                stops: [0, 0.45, 1],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Pressable(
                          onTap: () => comingSoon(context, 'Address book'),
                          scale: 0.98,
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Home',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 22),
                                child: Text(
                                  'Add your address',
                                  style: TextStyle(
                                    color: Color(0xCCFFFFFF),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Pressable(
                        onTap: () => comingSoon(context, 'Offers'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.card_giftcard_rounded,
                                color: Colors.white,
                                size: 17,
                              ),
                              SizedBox(width: 6),
                              Text(
                                '20% off',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          session.initial,
                          style: const TextStyle(
                            color: AppColors.lavender,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    name.isEmpty ? 'Hi there' : 'Hi, $name',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Trusted help for your home, in minutes',
                    style: TextStyle(color: Color(0xE6FFFFFF), fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
