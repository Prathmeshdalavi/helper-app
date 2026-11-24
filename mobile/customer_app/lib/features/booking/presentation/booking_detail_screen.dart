import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../shared/widgets/premium.dart';
import '../../home/presentation/widgets/common.dart';
import '../data/booking_store.dart';
import '../domain/booking.dart';
import '../domain/when.dart';

const _heroGreen = Color(0xFF2F7D55);

/// One booking, from confirmed to completed.
class BookingDetailScreen extends ConsumerWidget {
  const BookingDetailScreen({super.key, required this.bookingId, this.now});

  final String bookingId;

  /// Overrides the clock, for tests.
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingByIdProvider(bookingId));
    if (booking == null) {
      return PremiumScope(
        child: Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('This booking is not available')),
        ),
      );
    }
    final clock = now ?? DateTime.now();
    final hero = _HeroSpec.of(booking, clock);

    return PremiumScope(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: hero.color,
          body: Column(
            children: [
              _Hero(spec: hero, booking: booking),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    child: _Body(booking: booking, now: clock),
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

class _HeroSpec {
  const _HeroSpec({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  static _HeroSpec of(Booking b, DateTime now) {
    switch (b.status) {
      case BookingStatus.confirmed:
        return _HeroSpec(
          color: _heroGreen,
          icon: Icons.check_rounded,
          title: 'Booking confirmed',
          subtitle: b.draft.instant
              ? 'Your expert is on the way'
              : 'An expert is assigned 15 minutes before your scheduled time',
        );
      case BookingStatus.arrived:
        return const _HeroSpec(
          color: AppColors.lavender,
          icon: Icons.home_rounded,
          title: 'Your expert has arrived',
          subtitle: 'Share the check-in code to start the service',
        );
      case BookingStatus.inProgress:
        return const _HeroSpec(
          color: AppColors.lavender,
          icon: Icons.timelapse_rounded,
          title: 'Service in progress',
          subtitle: 'Your helper is at work',
        );
      case BookingStatus.aboutToEnd:
        return const _HeroSpec(
          color: Color(0xFFB8651F),
          icon: Icons.hourglass_bottom_rounded,
          title: 'Service about to end',
          subtitle: 'Extend now if you need a little more time',
        );
      case BookingStatus.completed:
        return const _HeroSpec(
          color: _heroGreen,
          icon: Icons.check_rounded,
          title: 'Service completed',
          subtitle: 'Thanks for choosing HerCare',
        );
      case BookingStatus.cancelled:
        return const _HeroSpec(
          color: Color(0xFF6E6A7A),
          icon: Icons.close_rounded,
          title: 'Booking cancelled',
          subtitle: 'Any amount paid is refunded to the source',
        );
    }
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.spec, required this.booking});

  final _HeroSpec spec;
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: premiumEase,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [spec.color, Color.lerp(spec.color, Colors.black, 0.18)!],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            PremiumTopBar(
              title: '',
              onDark: true,
              trailing: IconButton(
                tooltip: 'Refresh',
                onPressed: () {},
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              ),
              onBack: () =>
                  context.canPop() ? context.pop() : context.go(Routes.home),
            ),
            const SizedBox(height: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 360),
              transitionBuilder: (c, a) => FadeTransition(
                opacity: a,
                child: ScaleTransition(
                  scale: Tween(begin: 0.85, end: 1.0).animate(a),
                  child: c,
                ),
              ),
              child: StatusBadge(
                key: ValueKey(booking.status),
                icon: spec.icon,
                color: Colors.white.withValues(alpha: 0.22),
                size: 84,
              ),
            ),
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: Column(
                key: ValueKey(booking.status),
                children: [
                  Text(
                    spec.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Text(
                      spec.subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
          ],
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.booking, required this.now});

  final Booking booking;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showCheckIn =
        booking.status == BookingStatus.confirmed ||
        booking.status == BookingStatus.arrived;
    final showCheckOut =
        booking.status == BookingStatus.inProgress ||
        booking.status == BookingStatus.aboutToEnd;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 32),
      children: [
        if (showCheckIn)
          _OtpCard(
            title: 'Check-in code',
            subtitle: 'Share with your expert to start the service',
            code: booking.checkInOtp,
          ),
        if (showCheckOut)
          _OtpCard(
            title: 'Check-out code',
            subtitle: 'Share with your expert to end the service',
            code: booking.checkOutOtp,
          ),
        if (showCheckIn || showCheckOut) const SizedBox(height: 14),
        if (booking.expert != null) ...[
          _ExpertCard(expert: booking.expert!),
          const SizedBox(height: 14),
        ],
        _WhenWhereCard(booking: booking, now: now),
        const SizedBox(height: 14),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ListRow(
                icon: Icons.edit_calendar_outlined,
                title: 'Modify booking',
                subtitle: booking.draft.instant
                    ? 'Cancel booking'
                    : 'Reschedule or cancel booking',
                onTap: () => comingSoon(context, 'Modify booking'),
              ),
              ListRow(
                icon: Icons.currency_rupee_rounded,
                title: 'Payment details',
                subtitle: 'View detailed price summary',
                onTap: () => comingSoon(context, 'Payment details'),
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
        if (kDebugMode && booking.isActive) ...[
          const SizedBox(height: 18),
          Center(
            child: TextButton.icon(
              onPressed: () =>
                  ref.read(bookingStoreProvider.notifier).advance(booking.id),
              icon: const Icon(Icons.fast_forward_rounded, size: 18),
              label: const Text('Debug: preview next stage'),
            ),
          ),
        ],
      ],
    );
  }
}

class _OtpCard extends StatelessWidget {
  const _OtpCard({
    required this.title,
    required this.subtitle,
    required this.code,
  });

  final String title;
  final String subtitle;
  final String code;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    color: AppInk.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          for (final digit in code.split(''))
            Container(
              width: 34,
              height: 44,
              margin: const EdgeInsets.only(left: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppInk.text,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                digit,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ExpertCard extends StatelessWidget {
  const _ExpertCard({required this.expert});

  final Expert expert;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFEAE4F7),
              shape: BoxShape.circle,
            ),
            child: Text(
              expert.initial,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.lavender,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expert.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: premiumGreenFill,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: premiumGreen,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        expert.rating.toString(),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: premiumGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Pressable(
            onTap: () => comingSoon(context, 'Calling'),
            scale: 0.94,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppInk.hairline),
              ),
              child: const Icon(Icons.call_rounded, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhenWhereCard extends StatelessWidget {
  const _WhenWhereCard({required this.booking, required this.now});

  final Booking booking;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final when = booking.draft.instant
        ? 'Instant · ${booking.totalMinutes} min visit'
        : '${whenLabel(booking.start, now)} · ${booking.totalMinutes} min visit';
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
                  '${booking.address.label} | ${booking.address.full}',
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
