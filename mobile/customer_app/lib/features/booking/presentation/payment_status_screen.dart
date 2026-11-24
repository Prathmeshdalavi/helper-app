import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../shared/widgets/premium.dart';
import '../../home/presentation/widgets/common.dart';
import '../data/booking_store.dart';
import '../domain/when.dart';

/// "We're confirming your payment". Moves on by itself.
/// TODO(payments): wait for the payment gateway result instead of a timer.
class PaymentStatusScreen extends ConsumerStatefulWidget {
  const PaymentStatusScreen({super.key, this.wait});

  /// How long the demo waits before succeeding. Tests shorten this.
  final Duration? wait;

  @override
  ConsumerState<PaymentStatusScreen> createState() =>
      _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends ConsumerState<PaymentStatusScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.wait ?? const Duration(milliseconds: 2600), _succeed);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _succeed() {
    final draft = ref.read(draftProvider);
    if (!mounted || draft == null) return;
    final method = ref.read(paymentMethodProvider);
    final booking = ref
        .read(bookingStoreProvider.notifier)
        .create(draft, paidWith: method.label);
    ref.read(draftProvider.notifier).clear();
    context.pushReplacement(Routes.bookingDetail(booking.id));
  }

  void _fail() {
    _timer?.cancel();
    context.pushReplacement(Routes.paymentFailed);
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: Text(
                    'Payment confirmation',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 52,
                        height: 52,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          strokeCap: StrokeCap.round,
                          color: AppColors.lavender,
                          backgroundColor: premiumSelectedFill,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        "We're confirming your payment",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'This can take a few moments. Your booking updates '
                        'once your bank confirms.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: AppInk.muted,
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: 220,
                        child: SecondaryButton(
                          label: 'Go to home',
                          onPressed: () => context.go(Routes.home),
                        ),
                      ),
                      if (kDebugMode)
                        TextButton(
                          onPressed: _fail,
                          child: const Text('Debug: simulate failure'),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown when the payment did not go through.
class PaymentFailedScreen extends ConsumerWidget {
  const PaymentFailedScreen({super.key, this.now});

  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(draftProvider);
    final clock = now ?? DateTime.now();
    return PremiumScope(
      child: Scaffold(
        backgroundColor: AppInk.canvas,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: PremiumTopBar(title: ''),
              ),
              const SizedBox(height: 10),
              const StatusBadge(icon: Icons.close_rounded, color: premiumRed),
              const SizedBox(height: 18),
              const Text(
                'Payment failed',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 36),
                child: Text(
                  'If any amount has been deducted, it will be refunded to the '
                  'source in 5 to 7 business days.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: AppInk.muted,
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(26),
                    ),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
                    children: [
                      if (draft != null)
                        _VisitCard(
                          when: draft.instant
                              ? 'Instant · ${draft.durationLabel} visit'
                              : '${whenLabel(draft.start, clock)} · ${draft.durationLabel} visit',
                          address: '${demoAddress.label} | ${demoAddress.full}',
                        ),
                      const SizedBox(height: 14),
                      AppCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            ListRow(
                              icon: Icons.currency_rupee_rounded,
                              title: 'Payment details',
                              subtitle: 'View detailed price summary',
                              onTap: () => context.pop(),
                            ),
                            ListRow(
                              icon: Icons.headset_mic_outlined,
                              title: 'Contact support',
                              subtitle: 'Get quick help for your queries',
                              divider: false,
                              onTap: () => comingSoon(context, 'Support'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      PrimaryButton(
                        label: 'Try again',
                        icon: Icons.refresh_rounded,
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  const _VisitCard({required this.when, required this.address});

  final String when;
  final String address;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.lavender,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  when,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: AppInk.hairline),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.lavender),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(fontSize: 14, height: 1.45),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
