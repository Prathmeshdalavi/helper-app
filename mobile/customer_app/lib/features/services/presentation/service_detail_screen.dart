import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../shared/widgets/app_photo.dart';
import '../../home/presentation/widgets/common.dart';
import '../data/demo_service_details.dart';
import '../data/demo_services.dart';
import '../domain/service_detail.dart';
import '../domain/service_item.dart';

/// What the customer sees after tapping a service card.
class ServiceDetailScreen extends StatelessWidget {
  const ServiceDetailScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.withFigtree(Theme.of(context)),
      child: _content(context),
    );
  }

  Widget _content(BuildContext context) {
    final category = DemoServices.categories
        .where((c) => c.id == serviceId)
        .firstOrNull;
    final detail = DemoServiceDetails.byId(serviceId);

    if (category == null || detail == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('This service is not available')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header(category: category)),
              SliverToBoxAdapter(
                child: _Body(category: category, detail: detail),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BookBar(category: category),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.category});

  final ServiceCategory category;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: 250 + top * 0.4,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppPhoto(
            category.image,
            fallback: category.tint,
            cacheWidth: 1000,
            alignment: category.focus,
          ),
          Positioned(
            top: top + 8,
            left: 16,
            child: _RoundButton(
              icon: Icons.arrow_back_rounded,
              label: 'Back',
              onTap: () => context.canPop() ? context.pop() : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Pressable(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: 22, color: AppColors.deepPlum),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.category, required this.detail});

  final ServiceCategory category;
  final ServiceDetail detail;

  @override
  Widget build(BuildContext context) {
    final saving = category.originalPrice - category.price;
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category.title,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              category.tagline,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B6577)),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: Color(0xFFF2B84B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      category.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${detail.reviewCount} reviews)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B6577),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: Color(0xFF6B6577),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      detail.duration,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B6577),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F3FB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(
                    '₹${category.price}',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹${category.originalPrice}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9A94A5),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        'You save ₹$saving',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.lavender,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              detail.about,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: Color(0xFF4A4457),
              ),
            ),
            const SizedBox(height: 26),
            const _Heading("What's included"),
            for (final item in detail.included)
              _CheckRow(text: item, included: true),
            if (detail.notIncluded.isNotEmpty) ...[
              const SizedBox(height: 18),
              const _Heading('Not included'),
              for (final item in detail.notIncluded)
                _CheckRow(text: item, included: false),
            ],
            const SizedBox(height: 26),
            const _Heading('Reviews'),
            for (final r in detail.reviews) _ReviewCard(review: r),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.text, required this.included});

  final String text;
  final bool included;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            included ? Icons.check_circle_rounded : Icons.remove_circle_outline,
            size: 20,
            color: included ? AppColors.lavender : const Color(0xFFB4AEC2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.3,
                color: included ? AppColors.deepPlum : const Color(0xFF6B6577),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final ServiceReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              for (var i = 0; i < 5; i++)
                Icon(
                  Icons.star_rounded,
                  size: 15,
                  color: i < review.rating
                      ? const Color(0xFFF2B84B)
                      : const Color(0xFFE3DFEA),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            review.text,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: Color(0xFF4A4457),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            review.when,
            style: const TextStyle(fontSize: 11, color: Color(0xFF9A94A5)),
          ),
        ],
      ),
    );
  }
}

class _BookBar extends StatelessWidget {
  const _BookBar({required this.category});

  final ServiceCategory category;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.deepPlum.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Starting at',
                style: TextStyle(fontSize: 11, color: Color(0xFF6B6577)),
              ),
              Text(
                '₹${category.price}',
                style: const TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: FilledButton(
              // TODO(booking): open the booking flow (date, address, summary).
              onPressed: () => comingSoon(context, 'Booking'),
              child: const Text('Book now'),
            ),
          ),
        ],
      ),
    );
  }
}
