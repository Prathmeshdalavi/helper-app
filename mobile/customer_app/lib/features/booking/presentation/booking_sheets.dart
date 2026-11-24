import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../shared/widgets/premium.dart';
import '../../home/presentation/widgets/common.dart';
import '../data/booking_store.dart';
import '../domain/booking.dart';

/// "Payment details": the bill for one booking.
Future<void> showPaymentDetailsSheet(BuildContext context, Booking b) =>
    showPremiumSheet<void>(
      context,
      builder: (_) => _PaymentDetails(booking: b),
    );

class _PaymentDetails extends StatelessWidget {
  const _PaymentDetails({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final bill = booking.bill;
    Widget line(
      String label,
      String value, {
      bool bold = false,
      Widget? strike,
    }) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: bold ? 15 : 14,
                fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          if (strike != null) ...[strike, const SizedBox(width: 6)],
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 17 : 14,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    final total = bill.total + booking.extraPaid;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Payment details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Booking ${booking.id}',
            style: const TextStyle(fontSize: 13, color: AppInk.muted),
          ),
          const SizedBox(height: 18),
          line(
            '${booking.draft.serviceTitle} · ${booking.draft.minutes} min',
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
          line('Platform fee', '₹${Bill.platformFee.toStringAsFixed(2)}'),
          line('Taxes', '₹${bill.tax.toStringAsFixed(2)}'),
          if (booking.extraPaid > 0)
            line(
              'Extra time · ${booking.extraMinutes} min',
              '₹${booking.extraPaid.toStringAsFixed(2)}',
            ),
          const Divider(height: 8, color: AppInk.hairline),
          const SizedBox(height: 10),
          line('Total paid', '₹${total.toStringAsFixed(2)}', bold: true),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: premiumGreenFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'You saved ${rupees(bill.savings)} on this order',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: premiumGreen,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Paid with ${booking.paidWith}',
            style: const TextStyle(fontSize: 13, color: AppInk.muted),
          ),
        ],
      ),
    );
  }
}

/// "Modify booking": reschedule or cancel.
Future<void> showModifyBookingSheet(BuildContext context, Booking b) =>
    showPremiumSheet<void>(context, builder: (_) => _Modify(booking: b));

class _Modify extends ConsumerStatefulWidget {
  const _Modify({required this.booking});

  final Booking booking;

  @override
  ConsumerState<_Modify> createState() => _ModifyState();
}

class _ModifyState extends ConsumerState<_Modify> {
  bool _confirming = false;

  Booking get b => widget.booking;

  /// Free to cancel until 2 hours before a scheduled visit, or until an
  /// expert is assigned to an instant one.
  bool get _free {
    if (b.status != BookingStatus.confirmed) return false;
    if (b.draft.instant) return b.expert == null;
    return DateTime.now().isBefore(b.start.subtract(const Duration(hours: 2)));
  }

  void _cancel() {
    ref.read(bookingStoreProvider.notifier).cancel(b.id);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppInk.text,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text(
            _free
                ? 'Booking cancelled. Your refund is on its way.'
                : 'Booking cancelled. A ₹49 fee was kept.',
          ),
          duration: const Duration(milliseconds: 2200),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 240),
      curve: premiumEase,
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: _confirming ? _confirm() : _options(),
      ),
    );
  }

  Widget _options() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Modify booking',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        if (!b.draft.instant)
          AppCard(
            onTap: () {
              Navigator.of(context).pop();
              comingSoon(context, 'Rescheduling');
            },
            child: const Row(
              children: [
                IconBadge(Icons.edit_calendar_outlined),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Reschedule',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppInk.muted),
              ],
            ),
          ),
        if (!b.draft.instant) const SizedBox(height: 10),
        AppCard(
          onTap: () => setState(() => _confirming = true),
          child: const Row(
            children: [
              IconBadge(Icons.event_busy_outlined, color: premiumRed),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Cancel booking',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppInk.muted),
            ],
          ),
        ),
      ],
    );
  }

  Widget _confirm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cancel this booking?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          _free
              ? 'You can cancel for free right now. Anything you paid is '
                    'refunded to your payment source.'
              : 'Cancelling now costs ₹49. The rest of what you paid is '
                    'refunded.',
          style: const TextStyle(
            fontSize: 14,
            height: 1.45,
            color: AppInk.muted,
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: 'Keep booking',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                label: 'Cancel booking',
                color: premiumRed,
                onPressed: _cancel,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
