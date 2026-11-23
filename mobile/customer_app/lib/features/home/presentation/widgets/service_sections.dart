import 'package:material_ui/material_ui.dart';

import '../../../../app/app_theme.dart';
import '../../../../shared/widgets/app_photo.dart';
import '../../../services/data/demo_services.dart';
import '../../../services/domain/service_item.dart';
import 'common.dart';

/// Two-column grid of service cards, with an "Explore more" row underneath.
class ServiceGrid extends StatelessWidget {
  const ServiceGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final items = DemoServices.categories;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 14,
              mainAxisExtent: 248,
            ),
            itemBuilder: (context, i) => _ServiceCard(category: items[i]),
          ),
          const SizedBox(height: 24),
          const _ExploreRow(),
        ],
      ),
    );
  }
}

/// One card: photo flush to the edges on top, details underneath, a single
/// thin outline drawn over everything so it is identical all the way round.
class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.category});

  final ServiceCategory category;

  static const _radius = 20.0;

  @override
  Widget build(BuildContext context) {
    final c = category;
    return Pressable(
      onTap: () => comingSoon(context, c.title),
      scale: 0.97,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_radius),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF30283D).withValues(alpha: 0.09),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: const Color(0xFF30283D).withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        // A hairline so the white card still reads on a white page.
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_radius),
          border: Border.all(color: const Color(0x1430283D), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppPhoto(
                    c.image,
                    fallback: c.tint,
                    cacheWidth: 560,
                    alignment: c.focus,
                  ),
                  const _Sheen(),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: Color(0xFFF2B84B),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            c.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(11),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        size: 22,
                        color: AppColors.lavender,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    c.tagline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B6577),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text(
                          '₹${c.price}',
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '₹${c.originalPrice}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF9A94A5),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
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

/// Soft diagonal highlight across a photo, like light catching glass.
class _Sheen extends StatelessWidget {
  const _Sheen();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x52FFFFFF),
              Color(0x00FFFFFF),
              Color(0x2EFFFFFF),
              Color(0x00FFFFFF),
            ],
            stops: [0, 0.32, 0.37, 0.52],
          ),
        ),
      ),
    );
  }
}

/// Wide row that points to the rest of the catalogue.
class _ExploreRow extends StatelessWidget {
  const _ExploreRow();

  @override
  Widget build(BuildContext context) {
    final photos = DemoServices.exploreMosaic;
    return Pressable(
      onTap: () => comingSoon(context, 'More services'),
      scale: 0.985,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F3FB),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 92,
              height: 48,
              child: Stack(
                children: [
                  for (var i = 0; i < photos.length; i++)
                    Positioned(
                      left: i * 22.0,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFF6F3FB),
                            width: 2.5,
                          ),
                        ),
                        child: ClipOval(
                          child: AppPhoto(photos[i], cacheWidth: 160),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore more services',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Bathroom, dishes, garden and more',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: Color(0xFF6B6577),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.lavender,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Three reassurance points on a quiet tinted panel.
class TrustRow extends StatelessWidget {
  const TrustRow({super.key});

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icon, String label) => Expanded(
      child: Column(
        children: [
          Icon(icon, size: 26, color: AppColors.lavender),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              height: 1.3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F3FB),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            const Text(
              'Relax, your home is in safe hands',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                item(Icons.verified_user_outlined, 'ID-verified\nhelpers'),
                item(Icons.fact_check_outlined, 'Background\nchecked'),
                item(Icons.shield_outlined, 'Insured\nvisits'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Choose, book, relax.
class HowItWorks extends StatelessWidget {
  const HowItWorks({super.key});

  @override
  Widget build(BuildContext context) {
    Widget step(String n, String title, String sub) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            n,
            style: TextStyle(
              fontSize: 34,
              height: 1,
              fontWeight: FontWeight.w800,
              color: AppColors.lavender.withValues(alpha: 0.28),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(
              fontSize: 12,
              height: 1.3,
              color: Color(0xFF6B6577),
            ),
          ),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          step('1', 'Choose', 'Pick what you need done'),
          const SizedBox(width: 14),
          step('2', 'Book', 'Now, or at a time you like'),
          const SizedBox(width: 14),
          step('3', 'Relax', 'Your helper arrives'),
        ],
      ),
    );
  }
}

/// Quiet sign-off at the bottom of the feed.
class BrandFooter extends StatelessWidget {
  const BrandFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        children: [
          Text(
            'HerCare',
            style: TextStyle(
              fontSize: 44,
              height: 1,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.5,
              color: AppColors.lavender.withValues(alpha: 0.16),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'HOME HELP YOU CAN TRUST',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w600,
              color: Color(0xFFB4AEC2),
            ),
          ),
        ],
      ),
    );
  }
}
