import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../shared/widgets/premium.dart';
import '../../home/presentation/home_tab_provider.dart';
import '../data/booking_store.dart';
import '../domain/booking.dart';
import '../domain/when.dart';

/// "My bookings": upcoming and past visits.
class BookingsTab extends ConsumerStatefulWidget {
  const BookingsTab({super.key});

  @override
  ConsumerState<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends ConsumerState<BookingsTab> {
  bool _past = false;

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(bookingStoreProvider);
    final upcoming = [
      for (final b in all)
        if (b.isActive) b,
    ];
    final past = [
      for (final b in all)
        if (!b.isActive) b,
    ];
    final shown = _past ? past : upcoming;

    return PremiumScope(
      child: Container(
        color: AppInk.canvas,
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 18, 20, 14),
                child: Text(
                  'My bookings',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _Segment(
                  past: _past,
                  upcomingCount: upcoming.length,
                  pastCount: past.length,
                  onChanged: (v) => setState(() => _past = v),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  switchInCurve: premiumEase,
                  child: shown.isEmpty
                      ? _Empty(
                          key: ValueKey('empty-$_past'),
                          past: _past,
                          onBook: () =>
                              ref.read(homeTabProvider.notifier).show(0),
                        )
                      : ListView.separated(
                          key: ValueKey('list-$_past'),
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                          itemCount: shown.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) =>
                              BookingCard(booking: shown[i]),
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

class _Segment extends StatelessWidget {
  const _Segment({
    required this.past,
    required this.upcomingCount,
    required this.pastCount,
    required this.onChanged,
  });

  final bool past;
  final int upcomingCount;
  final int pastCount;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, int count, bool value) {
      final on = past == value;
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(value),
          child: SizedBox(
            height: 38,
            child: Center(
              child: Text(
                count > 0 ? '$label · $count' : label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: on ? Colors.white : AppInk.text,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppInk.hairline),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 260),
              curve: premiumEase,
              alignment: past ? Alignment.centerRight : Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.lavender,
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              tab('Upcoming', upcomingCount, false),
              tab('Past', pastCount, true),
            ],
          ),
        ],
      ),
    );
  }
}

/// One booking in a list.
class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.booking});

  final Booking booking;

  static ({String label, Color color, Color fill}) statusStyle(
    BookingStatus s,
  ) {
    switch (s) {
      case BookingStatus.confirmed:
        return (
          label: 'Confirmed',
          color: premiumGreen,
          fill: premiumGreenFill,
        );
      case BookingStatus.arrived:
        return (
          label: 'Expert arrived',
          color: AppColors.lavender,
          fill: premiumSelectedFill,
        );
      case BookingStatus.inProgress:
        return (
          label: 'In progress',
          color: AppColors.lavender,
          fill: premiumSelectedFill,
        );
      case BookingStatus.aboutToEnd:
        return (
          label: 'Ending soon',
          color: premiumAmber,
          fill: const Color(0xFFFCEFE2),
        );
      case BookingStatus.completed:
        return (
          label: 'Completed',
          color: AppInk.muted,
          fill: const Color(0xFFF1F0F6),
        );
      case BookingStatus.cancelled:
        return (
          label: 'Cancelled',
          color: premiumRed,
          fill: const Color(0xFFFBE9EA),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = statusStyle(booking.status);
    final when = booking.draft.instant
        ? 'Instant · ${booking.totalMinutes} min'
        : '${whenLabel(booking.start, DateTime.now())} · ${booking.totalMinutes} min';
    return AppCard(
      onTap: () => context.push(Routes.bookingDetail(booking.id)),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: premiumSelectedFill,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              booking.draft.instant
                  ? Icons.bolt_rounded
                  : Icons.home_repair_service_rounded,
              color: AppColors.lavender,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.draft.serviceTitle,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  when,
                  style: const TextStyle(fontSize: 12.5, color: AppInk.muted),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: style.fill,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    style.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: style.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppInk.muted),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({super.key, required this.past, required this.onBook});

  final bool past;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(36, 0, 36, 110),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: premiumSelectedFill,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_available_rounded,
                size: 44,
                color: AppColors.lavender,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              past ? 'No past bookings' : 'No bookings yet',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              past
                  ? 'Visits you have completed or cancelled will show up here.'
                  : 'Your upcoming and past bookings will show up here once '
                        'you book a helper.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: AppInk.muted,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: 180,
              child: PrimaryButton(label: 'Book now', onPressed: onBook),
            ),
          ],
        ),
      ),
    );
  }
}
