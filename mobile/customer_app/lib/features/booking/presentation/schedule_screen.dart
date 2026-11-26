import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../home/presentation/widgets/common.dart';
import '../data/booking_store.dart';
import '../data/demo_schedule.dart';
import '../domain/booking.dart';

const _selectedFill = Color(0xFFFEF3EE);
const _surcharge = Color(0xFFE8782B);
const _ease = Curves.easeOutCubic;

/// "Schedule for later": pick a day, how long, and when to start.
class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key, this.now});

  /// Overrides the clock, for tests.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.withFigtree(Theme.of(context)),
      child: _ScheduleBody(now: now),
    );
  }
}

class _ScheduleBody extends ConsumerStatefulWidget {
  const _ScheduleBody({this.now});

  final DateTime? now;

  @override
  ConsumerState<_ScheduleBody> createState() => _ScheduleBodyState();
}

class _ScheduleBodyState extends ConsumerState<_ScheduleBody> {
  late final DateTime _now = widget.now ?? DateTime.now();
  late final List<DateTime> _days = [
    for (var i = 0; i < 7; i++)
      DateTime(_now.year, _now.month, _now.day).add(Duration(days: i)),
  ];

  int _day = 0;
  DurationOption? _duration;
  DayPart _part = DayPart.morning;
  TimeSlot? _slot;

  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  String _dayLabel(int i) => i == 0
      ? 'Today'
      : (i == 1 ? 'Tomorrow' : _weekdays[_days[i].weekday - 1]);

  void _pickDay(int i) {
    setState(() {
      _day = i;
      _slot = null;
      // Land on the first part of the day that still has slots.
      _part = DayPart.values.firstWhere(
        (p) => DemoSchedule.slotsFor(_days[i], _now, p).isNotEmpty,
        orElse: () => DayPart.morning,
      );
    });
  }

  int get _total => (_duration?.price ?? 0) + (_slot?.extra ?? 0);

  void _continue() {
    final d = _duration;
    final slot = _slot;
    if (d == null || slot == null) return;
    final day = _days[_day];
    ref
        .read(draftProvider.notifier)
        .set(
          BookingDraft(
            serviceTitle: ref.read(selectedServiceProvider),
            start: DateTime(
              day.year,
              day.month,
              day.day,
              slot.minuteOfDay ~/ 60,
              slot.minuteOfDay % 60,
            ),
            minutes: d.minutes,
            price: d.price + slot.extra,
            originalPrice: d.originalPrice + slot.extra,
          ),
        );
    context.push(Routes.checkout);
  }

  @override
  Widget build(BuildContext context) {
    final day = _days[_day];
    final soldOut = DemoSchedule.soldOut(day, _now);
    final slots = DemoSchedule.slotsFor(day, _now, _part);
    final ready = _duration != null && _slot != null;

    return Scaffold(
      backgroundColor: AppInk.canvas,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              days: [for (var i = 0; i < _days.length; i++) _dayLabel(i)],
              selected: _day,
              onPick: _pickDay,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                children: [
                  const _InfoBanner(
                    'Pick a day and a start time. Your helper arrives within '
                    '30 minutes of the slot you choose.',
                  ),
                  const SizedBox(height: 14),
                  Container(
                    clipBehavior: Clip.antiAlias,
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0E0E0E)
                              .withValues(alpha: 0.06),
                          blurRadius: 28,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 260),
                      curve: _ease,
                      alignment: Alignment.topCenter,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: _Label('Service duration'),
                          ),
                          const SizedBox(height: 10),
                          _DurationRow(
                            selected: _duration,
                            enabled: !soldOut,
                            onPick: (d) => setState(() => _duration = d),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 240),
                            switchInCurve: _ease,
                            switchOutCurve: Curves.easeIn,
                            child: soldOut
                                ? _SoldOut(
                                    key: const ValueKey('sold-out'),
                                    dayName: _day == 0
                                        ? 'today'
                                        : _dayLabel(_day),
                                  )
                                : _TimePicker(
                                    key: ValueKey('times-$_day'),
                                    part: _part,
                                    slots: slots,
                                    selected: _slot,
                                    onPart: (p) => setState(() {
                                      _part = p;
                                      _slot = null;
                                    }),
                                    onSlot: (s) => setState(() => _slot = s),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NOTE',
                          style: TextStyle(
                            fontSize: 10.5,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600,
                            color: AppInk.muted,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Slots with a small extra charge are our busiest '
                          'times.',
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: AppInk.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _CartBar(ready: ready, total: _total, onTap: _continue),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.days,
    required this.selected,
    required this.onPick,
  });

  final List<String> days;
  final int selected;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 20, 2),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Back',
                  onPressed: () => context.canPop() ? context.pop() : null,
                  icon: const Icon(Icons.arrow_back_rounded, size: 22),
                ),
                const SizedBox(width: 2),
                const Expanded(
                  child: Text(
                    'Schedule for later',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: days.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) => _Chip(
                selected: i == selected,
                onTap: () => onPick(i),
                child: Text(
                  days[i],
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: i == selected
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Crisp outlined choice; a soft lavender fill and thin accent line when
/// selected.
class _Chip extends StatelessWidget {
  const _Chip({
    required this.selected,
    required this.onTap,
    required this.child,
    this.width,
    this.enabled = true,
  });

  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final Widget child;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Pressable(
        onTap: enabled ? onTap : () {},
        scale: 0.98,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: _ease,
          width: width,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? _selectedFill : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.lavender : AppInk.hairline,
              width: selected ? 1.3 : 1,
            ),
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: enabled ? 1 : 0.45,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFDEEE7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.info_outline_rounded, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppInk.muted,
      ),
    ),
  );
}

class _DurationRow extends StatelessWidget {
  const _DurationRow({
    required this.selected,
    required this.enabled,
    required this.onPick,
  });

  final DurationOption? selected;
  final bool enabled;
  final ValueChanged<DurationOption> onPick;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: DemoSchedule.durations.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final d = DemoSchedule.durations[i];
          return _Chip(
            width: 88,
            enabled: enabled,
            selected: d == selected,
            onTap: () => onPick(d),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  d.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    children: [
                      Text(
                        '₹${d.price}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '₹${d.originalPrice}',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF7C7C7C),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The "Service start time" block: day-part switch and the slot panel.
class _TimePicker extends StatelessWidget {
  const _TimePicker({
    super.key,
    required this.part,
    required this.slots,
    required this.selected,
    required this.onPart,
    required this.onSlot,
  });

  final DayPart part;
  final List<TimeSlot> slots;
  final TimeSlot? selected;
  final ValueChanged<DayPart> onPart;
  final ValueChanged<TimeSlot> onSlot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 22),
          const _Label('Service start time'),
          const SizedBox(height: 10),
          _PartSwitch(selected: part, onPick: onPart),
          const SizedBox(height: 12),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppInk.hairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: const Color(0xFFFEF7F4),
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  child: const Text(
                    'Standard slots',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 12, 10, 14),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: _ease,
                    child: slots.isEmpty
                        ? const Padding(
                            key: ValueKey('none'),
                            padding: EdgeInsets.symmetric(vertical: 18),
                            child: Center(
                              child: Text(
                                'No slots left in this part of the day',
                                style: TextStyle(color: AppInk.muted),
                              ),
                            ),
                          )
                        : _SlotGrid(
                            key: ValueKey(part),
                            slots: slots,
                            selected: selected,
                            onPick: onSlot,
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

class _PartSwitch extends StatelessWidget {
  const _PartSwitch({required this.selected, required this.onPick});

  final DayPart selected;
  final ValueChanged<DayPart> onPick;

  static const _icons = {
    DayPart.morning: Icons.wb_twilight_rounded,
    DayPart.afternoon: Icons.wb_sunny_outlined,
    DayPart.evening: Icons.nightlight_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppInk.hairline),
      ),
      child: Stack(
        children: [
          // The lavender pill glides to the chosen part.
          Positioned.fill(
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 260),
              curve: _ease,
              alignment: Alignment(DayPart.values.indexOf(selected) - 1.0, 0),
              child: FractionallySizedBox(
                widthFactor: 1 / DayPart.values.length,
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
              for (final p in DayPart.values)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: p == selected,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onPick(p),
                      child: SizedBox(
                        height: 34,
                        child: TweenAnimationBuilder<Color?>(
                          duration: const Duration(milliseconds: 220),
                          tween: ColorTween(
                            end: p == selected ? Colors.white : AppInk.text,
                          ),
                          builder: (context, color, _) => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_icons[p], size: 16, color: color),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  p.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SlotGrid extends StatelessWidget {
  const _SlotGrid({
    super.key,
    required this.slots,
    required this.selected,
    required this.onPick,
  });

  final List<TimeSlot> slots;
  final TimeSlot? selected;
  final ValueChanged<TimeSlot> onPick;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        const gap = 8.0;
        final w = (box.maxWidth - gap * 3) / 4;
        return Wrap(
          spacing: gap,
          runSpacing: 14,
          children: [
            for (final s in slots)
              SizedBox(
                width: w,
                child: _SlotCell(
                  slot: s,
                  selected: s.minuteOfDay == selected?.minuteOfDay,
                  onTap: () => onPick(s),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SlotCell extends StatelessWidget {
  const _SlotCell({
    required this.slot,
    required this.selected,
    required this.onTap,
  });

  final TimeSlot slot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Pressable(
        onTap: onTap,
        scale: 0.97,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: _ease,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? _selectedFill : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? AppColors.lavender : AppInk.hairline,
                  width: selected ? 1.3 : 1,
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  slot.label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
            if (slot.extra > 0)
              Positioned(
                bottom: -7,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '+₹${slot.extra}',
                    style: const TextStyle(
                      fontSize: 10.5,
                      height: 1.1,
                      fontWeight: FontWeight.w600,
                      color: _surcharge,
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

class _SoldOut extends StatelessWidget {
  const _SoldOut({super.key, required this.dayName});

  final String dayName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 34, 22, 18),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: _selectedFill,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              size: 28,
              color: AppColors.lavender,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'NO SLOTS AVAILABLE ${dayName.toUpperCase()}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11.5,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w600,
              color: AppInk.muted,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please pick another day, or check back later.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _CartBar extends StatelessWidget {
  const _CartBar({
    required this.ready,
    required this.total,
    required this.onTap,
  });

  final bool ready;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppInk.hairline)),
      ),
      child: FilledButton(
        onPressed: ready ? onTap : null,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          disabledBackgroundColor: const Color(0xFFFDEDE4),
          disabledForegroundColor: Colors.white,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            ready ? 'Continue  ·  ₹$total' : 'Continue',
            key: ValueKey(ready ? total : -1),
          ),
        ),
      ),
    );
  }
}
