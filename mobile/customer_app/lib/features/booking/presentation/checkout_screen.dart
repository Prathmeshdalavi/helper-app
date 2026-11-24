import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../shared/widgets/premium.dart';
import '../../home/presentation/widgets/common.dart';
import '../../account/data/address_store.dart';
import '../../account/presentation/saved_addresses_sheet.dart';
import '../data/booking_store.dart';
import '../domain/booking.dart';
import '../domain/when.dart';

/// Order summary: what, when, where, the bill and the policy, then pay.
class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key, this.now});

  /// Overrides the clock, for tests.
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(draftProvider);
    final method = ref.watch(paymentMethodProvider);
    final address = ref.watch(selectedAddressProvider);
    if (draft == null) {
      return PremiumScope(
        child: Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('Nothing to pay for yet')),
        ),
      );
    }
    final bill = draft.bill;
    final clock = now ?? DateTime.now();

    return PremiumScope(
      child: Scaffold(
        backgroundColor: AppInk.canvas,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: PremiumTopBar(
                  title: address.label,
                  subtitle: address.line1,
                  onTapTitle: () => showSavedAddressesSheet(context),
                ),
              ),
              const Divider(height: 1, color: AppInk.hairline),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _ServiceCard(draft: draft, now: clock),
                    const SizedBox(height: 14),
                    _BillCard(draft: draft, bill: bill),
                    const SizedBox(height: 14),
                    _PolicyCard(draft: draft),
                    const SizedBox(height: 22),
                    const _TrustLine(),
                  ],
                ),
              ),
              _PayBar(
                total: bill.total,
                method: method,
                onChangeMethod: () => context.push(Routes.payment),
                onPay: () => context.push(Routes.paymentStatus),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.draft, required this.now});

  final BookingDraft draft;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: premiumSelectedFill,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              draft.instant
                  ? Icons.bolt_rounded
                  : Icons.home_repair_service_rounded,
              color: AppColors.lavender,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  draft.serviceTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${draft.durationLabel} × 1 visit',
                  style: const TextStyle(fontSize: 12.5, color: AppInk.muted),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: AppColors.lavender,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        draft.instant
                            ? 'Arrives in about ${draft.etaMinutes ?? 10} min'
                            : whenLabel(draft.start, now),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lavender,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                rupees(draft.price),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                rupees(draft.originalPrice),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9B97A6),
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BillCard extends StatelessWidget {
  const _BillCard({required this.draft, required this.bill});

  final BookingDraft draft;
  final Bill bill;

  @override
  Widget build(BuildContext context) {
    Widget line(Widget label, String value, {Widget? strike}) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: label),
          if (strike != null) ...[strike, const SizedBox(width: 6)],
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );

    Widget dotted(String text) => Container(
      padding: const EdgeInsets.only(bottom: 1),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFC9C5D3), width: 1)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 14)),
    );

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bill summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 14),
                line(
                  Row(
                    children: [
                      const Text('Home help', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F0F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          draft.durationLabel,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppInk.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  '₹${bill.service.toStringAsFixed(2)}',
                  strike: Text(
                    '₹${bill.original.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF9B97A6),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
                line(
                  dotted('Platform fee'),
                  '₹${Bill.platformFee.toStringAsFixed(2)}',
                ),
                line(dotted('Taxes'), '₹${bill.tax.toStringAsFixed(2)}'),
                const Divider(height: 8, color: AppInk.hairline),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'To pay',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '₹${bill.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: const BoxDecoration(
              color: premiumGreenFill,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.celebration_rounded,
                  size: 17,
                  color: premiumGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  'You save ${rupees(bill.savings)} on this order',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: premiumGreen,
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

class _PolicyCard extends StatefulWidget {
  const _PolicyCard({required this.draft});

  final BookingDraft draft;

  @override
  State<_PolicyCard> createState() => _PolicyCardState();
}

class _PolicyCardState extends State<_PolicyCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.draft;
    final cutoff = d.start.subtract(const Duration(hours: 2));
    final cutoffText =
        '${clockLabel(cutoff)}, ${dayLabel(cutoff, DateTime.now())}';
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Pressable(
            onTap: () => setState(() => _open = !_open),
            scale: 0.99,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booking policy',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'For cancellation and reschedule',
                          style: TextStyle(fontSize: 12.5, color: AppInk.muted),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(Icons.expand_more_rounded),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: premiumEase,
            alignment: Alignment.topCenter,
            child: _open
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PolicyItem(
                          icon: Icons.event_busy_outlined,
                          title: 'Cancellation',
                          text: d.instant
                              ? 'Cancel for free until an expert is assigned. '
                                    'After that, cancelling costs ₹49. Once your '
                                    'expert arrives, the full charge applies.'
                              : 'Cancel for free until $cutoffText. After that, '
                                    'cancelling costs ₹49. Once your expert arrives, '
                                    'the full charge applies.',
                        ),
                        const Divider(height: 22, color: AppInk.hairline),
                        _PolicyItem(
                          icon: Icons.edit_calendar_outlined,
                          title: 'Reschedule',
                          text: d.instant
                              ? 'Instant bookings cannot be rescheduled.'
                              : 'Reschedule for free until $cutoffText. '
                                    'It is not available after that.',
                        ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _PolicyItem extends StatelessWidget {
  const _PolicyItem({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppInk.muted),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: AppInk.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrustLine extends StatelessWidget {
  const _TrustLine();

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icon, String text) => Expanded(
      child: Column(
        children: [
          Icon(icon, size: 22, color: AppColors.lavender),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11.5,
              height: 1.3,
              color: AppInk.muted,
            ),
          ),
        ],
      ),
    );
    return Row(
      children: [
        item(Icons.verified_user_outlined, 'ID-verified\nhelpers'),
        item(Icons.shield_outlined, 'Insured\nvisits'),
        item(Icons.event_repeat_outlined, 'Free\nreschedule'),
      ],
    );
  }
}

class _PayBar extends StatelessWidget {
  const _PayBar({
    required this.total,
    required this.method,
    required this.onChangeMethod,
    required this.onPay,
  });

  final double total;
  final PaymentMethod method;
  final VoidCallback onChangeMethod;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppInk.hairline)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Pressable(
              onTap: onChangeMethod,
              scale: 0.98,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Pay using',
                        style: TextStyle(fontSize: 11.5, color: AppInk.muted),
                      ),
                      Icon(
                        Icons.arrow_drop_up_rounded,
                        size: 18,
                        color: AppInk.muted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: premiumSelectedFill,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 15,
                          color: AppColors.lavender,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          method.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: FilledButton(
              onPressed: onPay,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Row(
                children: [
                  Text(
                    '₹${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const Text('Pay now'),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
