/// Demo scheduling options until the booking module exists.
/// TODO(booking): replace with GET /booking/availability.
enum DayPart {
  morning('Morning'),
  afternoon('Afternoon'),
  evening('Evening');

  const DayPart(this.label);
  final String label;
}

/// A visit length and what it costs (rupees).
class DurationOption {
  const DurationOption({
    required this.minutes,
    required this.price,
    required this.originalPrice,
  });

  final int minutes;
  final int price;
  final int originalPrice;

  /// "0.5 hr", "1 hr", "1.5 hr".
  String get label {
    final hours = minutes / 60;
    final text = hours == hours.roundToDouble()
        ? hours.round().toString()
        : hours.toString();
    return '$text hr';
  }
}

/// One start time on a given day.
class TimeSlot {
  const TimeSlot({required this.minuteOfDay, required this.extra});

  final int minuteOfDay;

  /// Peak-time surcharge in rupees; 0 means no extra charge.
  final int extra;

  DayPart get part => minuteOfDay < 12 * 60
      ? DayPart.morning
      : minuteOfDay < 17 * 60
      ? DayPart.afternoon
      : DayPart.evening;

  /// "7:30 am", "12:00 pm".
  String get label {
    final h = minuteOfDay ~/ 60;
    final m = minuteOfDay % 60;
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    final suffix = h < 12 ? 'am' : 'pm';
    return '$hour12:${m.toString().padLeft(2, '0')} $suffix';
  }
}

abstract final class DemoSchedule {
  static const durations = [
    DurationOption(minutes: 30, price: 79, originalPrice: 150),
    DurationOption(minutes: 60, price: 129, originalPrice: 250),
    DurationOption(minutes: 90, price: 179, originalPrice: 350),
    DurationOption(minutes: 120, price: 229, originalPrice: 450),
    DurationOption(minutes: 180, price: 329, originalPrice: 650),
  ];

  /// Every half hour from 7:00 am to 8:30 pm. Early-morning and evening
  /// rush hours cost a little extra.
  static final List<TimeSlot> allSlots = [
    for (var m = 7 * 60; m <= 20 * 60 + 30; m += 30)
      TimeSlot(minuteOfDay: m, extra: _extraFor(m)),
  ];

  static int _extraFor(int minute) {
    final peakMorning = minute >= 7 * 60 && minute <= 9 * 60;
    final peakEvening = minute >= 18 * 60 && minute <= 20 * 60;
    return peakMorning || peakEvening ? 10 : 0;
  }

  /// Slots a customer can still book on [day]. Today needs a one hour
  /// lead time; later days have every slot.
  static List<TimeSlot> slotsFor(DateTime day, DateTime now, DayPart part) {
    final isToday =
        day.year == now.year && day.month == now.month && day.day == now.day;
    final earliest = isToday ? now.hour * 60 + now.minute + 60 : 0;
    return [
      for (final s in allSlots)
        if (s.part == part && s.minuteOfDay >= earliest) s,
    ];
  }

  /// True when nothing at all is left to book on [day].
  static bool soldOut(DateTime day, DateTime now) =>
      DayPart.values.every((p) => slotsFor(day, now, p).isEmpty);
}
