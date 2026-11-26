import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../shared/widgets/premium.dart';
import '../../booking/presentation/rating_sheet.dart';
import '../../home/presentation/widgets/common.dart';

class _Offer {
  const _Offer(this.code, this.title, this.detail, this.icon);

  final String code;
  final String title;
  final String detail;
  final IconData icon;
}

/// TODO(offers): replace with GET /offers.
const _offers = [
  _Offer(
    'FIRST20',
    '20% off your first booking',
    'Applied automatically at checkout. Valid on any service.',
    Icons.local_offer_rounded,
  ),
  _Offer(
    'HABIT3',
    '3 visits, one low price',
    'Book three one-hour visits together and save on each.',
    Icons.event_repeat_rounded,
  ),
  _Offer(
    'WEEKDAY',
    'Cheaper on weekday mornings',
    'Visits between 7 and 11 am, Monday to Friday.',
    Icons.wb_twilight_rounded,
  ),
];

/// "Offers": codes to use and a way to earn more.
class OffersTab extends StatelessWidget {
  const OffersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumScope(
      child: Container(
        color: AppInk.canvas,
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
            children: [
              const Text(
                'Offers',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                'Savings that apply to your bookings',
                style: TextStyle(fontSize: 13.5, color: AppInk.muted),
              ),
              const SizedBox(height: 18),
              for (final o in _offers) ...[
                _OfferCard(offer: o),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2E2E32), Color(0xFF18181B)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Refer & earn ₹200',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Your friend gets ₹50 on their first booking.',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.35,
                              color: Color(0xE6FFFFFF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () => showInviteSheet(context),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 40),
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF141414),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                      ),
                      child: const Text('Invite'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer});

  final _Offer offer;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          IconBadge(offer.icon, size: 48),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  offer.detail,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    color: AppInk.muted,
                  ),
                ),
                const SizedBox(height: 10),
                Pressable(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: offer.code));
                    toast(context, 'Code ${offer.code} copied');
                  },
                  scale: 0.96,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.lavender.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          offer.code,
                          style: const TextStyle(
                            fontSize: 12.5,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w700,
                            color: AppColors.lavender,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.copy_rounded,
                          size: 14,
                          color: AppColors.lavender,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
