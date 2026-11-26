import 'dart:async';
import 'dart:math' as math;

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
import 'booking_sheets.dart';
import 'extend_sheet.dart';
import 'inclusions_sheet.dart';
import 'instant_map.dart';
import 'rating_sheet.dart';

const _heroGreen = Color(0xFF1FA463);
const _heroGreenDeep = Color(0xFF0F7447);
const _mint = Color(0xFF8CF2B0);
const _mintInk = Color(0xFF0B5A36);
const _amber = Color(0xFFC46A1B);
const _gold = Color(0xFFF2B84B);

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
    final live =
        booking.status == BookingStatus.inProgress ||
        booking.status == BookingStatus.aboutToEnd;

    return PremiumScope(
      child: live
          ? _LiveLayout(booking: booking, now: clock)
          : _SheetLayout(booking: booking, now: clock),
    );
  }
}

// ---------------------------------------------------------------------------
// Layouts

void _leave(BuildContext context) =>
    context.canPop() ? context.pop() : context.go(Routes.home);

/// A coloured header (badge or map) with a white sheet over it.
class _SheetLayout extends StatelessWidget {
  const _SheetLayout({required this.booking, required this.now});

  final Booking booking;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final arrived = booking.status == BookingStatus.arrived;
    final hero = _HeroSpec.of(booking);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: arrived ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 360),
              child: arrived
                  ? _MapHero(key: const ValueKey('map'), booking: booking)
                  : _BadgeHero(
                      key: ValueKey(booking.status),
                      spec: hero,
                      booking: booking,
                    ),
            ),
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -24),
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
                    child: _Body(booking: booking, now: now),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Soft canvas with the countdown on top, used while the service runs.
class _LiveLayout extends StatelessWidget {
  const _LiveLayout({required this.booking, required this.now});

  final Booking booking;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppInk.canvas,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              PremiumTopBar(
                title: '',
                onBack: () => _leave(context),
                trailing: IconButton(
                  tooltip: 'Refresh',
                  onPressed: () {},
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ),
              Expanded(
                child: _Body(booking: booking, now: now),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Heroes

class _HeroSpec {
  const _HeroSpec({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.deep,
    this.badge,
    this.badgeInk = Colors.white,
    this.tilt = 0,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  /// Bottom colour of the header gradient; darker than [color] by default.
  final Color? deep;

  /// Fill and tick colour of the status badge, and how far it is tilted.
  final Color? badge;
  final Color badgeInk;
  final double tilt;

  static _HeroSpec of(Booking b) {
    switch (b.status) {
      case BookingStatus.confirmed:
        return _HeroSpec(
          color: _heroGreen,
          deep: _heroGreenDeep,
          badge: _mint,
          badgeInk: _mintInk,
          tilt: -0.2,
          icon: Icons.check_rounded,
          title: 'Booking confirmed',
          subtitle: b.draft.instant
              ? 'Your expert is on the way'
              : 'An expert is assigned 15 minutes before your scheduled time',
        );
      case BookingStatus.completed:
        return const _HeroSpec(
          color: _heroGreen,
          deep: _heroGreenDeep,
          badge: _mint,
          badgeInk: _mintInk,
          tilt: -0.2,
          icon: Icons.check_rounded,
          title: 'Service completed',
          subtitle: 'Thanks for choosing HerCare',
        );
      case BookingStatus.cancelled:
        return const _HeroSpec(
          color: Color(0xFF5E5E5E),
          icon: Icons.close_rounded,
          title: 'Booking cancelled',
          subtitle: 'Any amount paid is refunded to the source',
        );
      case BookingStatus.arrived:
      case BookingStatus.inProgress:
      case BookingStatus.aboutToEnd:
        return const _HeroSpec(
          color: AppColors.lavender,
          icon: Icons.home_rounded,
          title: '',
          subtitle: '',
        );
    }
  }
}

class _BadgeHero extends StatelessWidget {
  const _BadgeHero({super.key, required this.spec, required this.booking});

  final _HeroSpec spec;
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            spec.color,
            spec.deep ?? Color.lerp(spec.color, Colors.black, 0.18)!,
          ],
        ),
      ),
      child: ClipRect(
        child: Stack(
          children: [
            // Soft rings add depth so a flat colour never looks pale.
            Positioned(
              right: -70,
              top: -50,
              child: _HeroRing(size: 230, alpha: 0.10),
            ),
            Positioned(
              left: -80,
              bottom: -60,
              child: _HeroRing(size: 210, alpha: 0.08),
            ),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  PremiumTopBar(
                    title: '',
                    onDark: true,
                    onBack: () => _leave(context),
                    trailing: IconButton(
                      tooltip: 'Refresh',
                      onPressed: () {},
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  StatusBadge(
                    icon: spec.icon,
                    color: spec.badge ?? Colors.white.withValues(alpha: 0.22),
                    iconColor: spec.badgeInk,
                    tilt: spec.tilt,
                    size: 92,
                  ),
                  const SizedBox(height: 14),
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
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroRing extends StatelessWidget {
  const _HeroRing({required this.size, required this.alpha});

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: Colors.white.withValues(alpha: alpha),
        width: 28,
      ),
    ),
  );
}

/// The street map with the customer's pin and the expert at the door.
class _MapHero extends StatefulWidget {
  const _MapHero({super.key, required this.booking});

  final Booking booking;

  @override
  State<_MapHero> createState() => _MapHeroState();
}

class _MapHeroState extends State<_MapHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final height = 300.0 + top * 0.3;
    final name = widget.booking.expert?.name.split(' ').first ?? 'Your expert';
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: StreetsPainter()),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (context, _) =>
                  CustomPaint(painter: _PinPainter(t: _pulse.value)),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: height * 0.5 - 62,
            child: Center(
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.lavender,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.home_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            left: 36,
            top: height * 0.5 + 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppInk.text,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFCE4D8),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      name.substring(0, 1),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lavender,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "$name has arrived!",
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: top + 6,
            left: 14,
            right: 14,
            child: Row(
              children: [
                _RoundIcon(
                  icon: Icons.arrow_back_rounded,
                  label: 'Back',
                  onTap: () => _leave(context),
                ),
                const Spacer(),
                _RoundIcon(
                  icon: Icons.refresh_rounded,
                  label: 'Refresh',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({
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
        scale: 0.94,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}

class _PinPainter extends CustomPainter {
  _PinPainter({required this.t});

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2 - 62 + 19);
    canvas.drawCircle(
      c,
      44 + 36 * t,
      Paint()..color = AppColors.lavender.withValues(alpha: 0.16 * (1 - t)),
    );
    canvas.drawCircle(
      c,
      58,
      Paint()..color = AppColors.lavender.withValues(alpha: 0.1),
    );
  }

  @override
  bool shouldRepaint(covariant _PinPainter old) => old.t != t;
}

// ---------------------------------------------------------------------------
// Body

class _Body extends ConsumerWidget {
  const _Body({required this.booking, required this.now});

  final Booking booking;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = booking;
    final children = <Widget>[];
    void gap([double h = 14]) => children.add(SizedBox(height: h));

    switch (b.status) {
      case BookingStatus.confirmed:
        children.add(
          _OtpCard(
            title: 'Check-in code',
            subtitle: 'Share with your expert to start the service',
            code: b.checkInOtp,
          ),
        );
      case BookingStatus.arrived:
        children
          ..add(_ArrivalCard(booking: b))
          ..add(const SizedBox(height: 14))
          ..add(
            _OtpCard(
              title: 'Check-in code',
              subtitle: 'Share with your expert to start the service',
              code: b.checkInOtp,
            ),
          );
      case BookingStatus.inProgress:
      case BookingStatus.aboutToEnd:
        children
          ..add(_LiveCard(booking: b))
          ..add(const SizedBox(height: 14))
          ..add(
            _OtpCard(
              title: 'Check-out code',
              subtitle: 'Share with your expert to end the service',
              code: b.checkOutOtp,
            ),
          );
      case BookingStatus.completed:
        children.add(_RateCard(booking: b));
      case BookingStatus.cancelled:
        break;
    }

    if (b.expert != null && b.status != BookingStatus.cancelled) {
      gap();
      children.add(_ExpertCard(booking: b));
    }
    gap();
    children.add(_WhenWhereCard(booking: b, now: now));

    if (b.isActive) {
      gap();
      children.add(const _TipsCarousel());
    }
    if (b.status == BookingStatus.confirmed ||
        b.status == BookingStatus.arrived) {
      gap();
      children.add(_ReferCard(onTap: () => showInviteSheet(context)));
    }
    gap();
    children.add(_TrainedCard(onTap: () => showInclusionsSheet(context)));
    gap();
    children.add(
      AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            if (b.isActive)
              ListRow(
                icon: Icons.edit_calendar_outlined,
                title: 'Modify booking',
                subtitle: b.draft.instant
                    ? 'Cancel booking'
                    : 'Reschedule or cancel booking',
                onTap: () => showModifyBookingSheet(context, b),
              ),
            ListRow(
              icon: Icons.currency_rupee_rounded,
              title: 'Payment details',
              subtitle: b.extraPaid > 0
                  ? 'Paid ${rupees(b.bill.total + b.extraPaid)} including extra time'
                  : 'View detailed price summary',
              onTap: () => showPaymentDetailsSheet(context, b),
            ),
            ListRow(
              icon: Icons.headset_mic_outlined,
              title: 'Contact support',
              subtitle: 'Get quick help for your queries',
              divider: false,
              onTap: () => context.push(Routes.support),
            ),
          ],
        ),
      ),
    );

    if (kDebugMode && b.isActive) {
      gap(18);
      children.add(
        Center(
          child: TextButton.icon(
            onPressed: () =>
                ref.read(bookingStoreProvider.notifier).advance(b.id),
            icon: const Icon(Icons.fast_forward_rounded, size: 18),
            label: const Text('Debug: preview next stage'),
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        b.status == BookingStatus.inProgress ||
                b.status == BookingStatus.aboutToEnd
            ? 6
            : 22,
        16,
        32,
      ),
      children: children,
    );
  }
}

// ---------------------------------------------------------------------------
// Cards

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
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
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
          ),
          const Divider(height: 1, color: AppInk.hairline),
          Pressable(
            onTap: () {
              Clipboard.setData(ClipboardData(text: code));
              comingSoon(context, 'Sharing the code');
            },
            scale: 0.99,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Booked for someone else?',
                      style: TextStyle(fontSize: 13.5),
                    ),
                  ),
                  Icon(
                    Icons.ios_share_rounded,
                    size: 17,
                    color: AppColors.lavender,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Share code',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lavender,
                    ),
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

class _ArrivalCard extends StatelessWidget {
  const _ArrivalCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final at = booking.arrivedAt ?? DateTime.now();
    final h = at.hour % 12 == 0 ? 12 : at.hour % 12;
    final m = at.minute.toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E2E32), Color(0xFF18181B)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expert arrived',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Your expert will reach your doorstep shortly.',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: Color(0xE6FFFFFF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 3,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ARRIVED AT',
                  style: TextStyle(
                    fontSize: 9.5,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                Text(
                  '$h:$m',
                  style: const TextStyle(
                    fontSize: 30,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  at.hour < 12 ? 'AM' : 'PM',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
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

/// Status, end time, countdown ring and Extend service.
class _LiveCard extends StatelessWidget {
  const _LiveCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final ending = booking.status == BookingStatus.aboutToEnd;
    final color = ending ? _amber : AppColors.lavender;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: Text(
                  ending ? 'Service about to end' : 'Service in progress',
                  key: ValueKey(ending),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Ends at ${clockLabel(booking.serviceEnd)}',
            style: const TextStyle(fontSize: 13.5, color: AppInk.muted),
          ),
          const SizedBox(height: 22),
          _TimerRing(booking: booking, color: color),
          const SizedBox(height: 22),
          PrimaryButton(
            label: 'Extend service',
            icon: Icons.add_alarm_rounded,
            color: color,
            onPressed: () => showExtendSheet(context, booking.id),
          ),
        ],
      ),
    );
  }
}

class _TimerRing extends StatefulWidget {
  const _TimerRing({required this.booking, required this.color});

  final Booking booking;
  final Color color;

  @override
  State<_TimerRing> createState() => _TimerRingState();
}

class _TimerRingState extends State<_TimerRing> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.booking.totalMinutes * 60;
    final left = widget.booking.serviceEnd
        .difference(DateTime.now())
        .inSeconds
        .clamp(0, total);
    final mm = (left ~/ 60).toString().padLeft(2, '0');
    final ss = (left % 60).toString().padLeft(2, '0');
    return SizedBox(
      width: 210,
      height: 210,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: total == 0 ? 0 : left / total),
        duration: const Duration(milliseconds: 600),
        curve: premiumEase,
        builder: (context, v, _) => CustomPaint(
          painter: _RingPainter(progress: v, color: widget.color),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Time remaining',
                  style: TextStyle(fontSize: 13, color: AppInk.muted),
                ),
                const SizedBox(height: 4),
                Text(
                  '$mm:$ss',
                  style: TextStyle(
                    fontSize: 42,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                    color: widget.color,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 13.0;
    final rect = Offset.zero & size;
    final arc = rect.deflate(stroke / 2);
    canvas.drawArc(
      arc,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = const Color(0xFFFEF3EE),
    );
    canvas.drawArc(
      arc,
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0.0, 1.0),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}

class _ExpertCard extends StatelessWidget {
  const _ExpertCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final expert = booking.expert!;
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFFCE4D8),
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
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        expert.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (booking.favourited) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.favorite_rounded,
                        size: 15,
                        color: _gold,
                      ),
                      const SizedBox(width: 3),
                      const Text(
                        'Favourite',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _amber,
                        ),
                      ),
                    ],
                  ],
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

class _RateCard extends ConsumerWidget {
  const _RateCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rated = booking.rating != null;
    final expert = booking.expert;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFCE4D8),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    expert?.initial ?? 'H',
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
                        rated ? 'Thanks for rating' : 'Rate your experience',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Service by ${expert?.name ?? 'your expert'}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppInk.muted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (var i = 1; i <= 5; i++)
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: rated
                                  ? null
                                  : () => showRatingSheet(
                                      context,
                                      booking,
                                      initialStars: i,
                                    ),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.star_rounded,
                                  size: 28,
                                  color: i <= (booking.rating ?? 0)
                                      ? _gold
                                      : const Color(0xFFFCE9DF),
                                ),
                              ),
                            ),
                          if (booking.extraStar)
                            const Padding(
                              padding: EdgeInsets.only(left: 2),
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                size: 22,
                                color: _gold,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF3E9),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite_rounded, size: 18, color: _gold),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    booking.favourited
                        ? 'Added to your favourite experts'
                        : 'Want them to assist you again?',
                    style: const TextStyle(fontSize: 13.5),
                  ),
                ),
                if (!booking.favourited)
                  Pressable(
                    onTap: () => ref
                        .read(bookingStoreProvider.notifier)
                        .favourite(booking.id, true),
                    scale: 0.95,
                    child: const Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: _amber,
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

class _WhenWhereCard extends StatelessWidget {
  const _WhenWhereCard({required this.booking, required this.now});

  final Booking booking;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final extra = booking.extraMinutes > 0
        ? ' (+${booking.extraMinutes} min)'
        : '';
    final when = booking.draft.instant
        ? 'Instant · ${booking.draft.minutes} min visit$extra'
        : '${whenLabel(booking.start, now)} · ${booking.draft.minutes} min visit$extra';
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

/// Swipeable reminders for the customer.
class _TipsCarousel extends StatefulWidget {
  const _TipsCarousel();

  @override
  State<_TipsCarousel> createState() => _TipsCarouselState();
}

class _TipsCarouselState extends State<_TipsCarousel> {
  int _page = 0;

  static const _tips = [
    (Icons.pets_rounded, 'Kindly keep pets secure and away during the service'),
    (
      Icons.cleaning_services_outlined,
      'Kindly guide your expert with clear instructions and the tools needed',
    ),
    (Icons.water_drop_outlined, 'Please offer drinking water to your expert'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 82,
          child: PageView.builder(
            itemCount: _tips.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: AppCard(
                child: Row(
                  children: [
                    IconBadge(_tips[i].$1, size: 46),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _tips[i].$2,
                        style: const TextStyle(fontSize: 14, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _tips.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _page ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _page
                      ? AppColors.lavender
                      : const Color(0xFFFBE1D3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ReferCard extends StatelessWidget {
  const _ReferCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFEF3EE), Color(0xFFFBE1D3)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Refer & earn',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                const Text(
                  'You get ₹200, your friend gets ₹50',
                  style: TextStyle(fontSize: 13, color: AppInk.muted),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 38,
                  child: FilledButton(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      textStyle: const TextStyle(
                        fontFamily: 'Figtree',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Refer now'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.card_giftcard_rounded,
              size: 34,
              color: AppColors.lavender,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainedCard extends StatelessWidget {
  const _TrainedCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trained helpers for all regular home tasks',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      "See what's included",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lavender,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: AppColors.lavender,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _MiniIcon(Icons.cleaning_services_rounded),
              _MiniIcon(Icons.bathtub_outlined),
              _MiniIcon(Icons.local_laundry_service_outlined),
              _MiniIcon(Icons.soup_kitchen_outlined),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniIcon extends StatelessWidget {
  const _MiniIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
      color: premiumSelectedFill,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, size: 18, color: AppColors.lavender),
  );
}
