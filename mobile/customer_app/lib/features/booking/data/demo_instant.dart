/// Demo data for the Instant booking screen.
/// TODO(booking): replace with GET /booking/instant/availability.
class InstantHelper {
  const InstantHelper({
    required this.id,
    required this.name,
    required this.etaMinutes,
    required this.maxMinutes,
    required this.rating,
    required this.mapX,
    required this.mapY,
  });

  final String id;
  final String name;

  /// Minutes until this helper can reach the customer.
  final int etaMinutes;

  /// Longest visit this helper is free for right now.
  final int maxMinutes;
  final double rating;

  /// Position on the map as a fraction of its width and height.
  final double mapX;
  final double mapY;

  bool get isBest => id == 'best';

  String get initial => name.substring(0, 1);
}

class InstantDuration {
  const InstantDuration({
    required this.minutes,
    required this.price,
    required this.originalPrice,
  });

  final int minutes;
  final int price;
  final int originalPrice;

  /// "30 min", "1 hr", "2.5 hrs".
  String get label {
    if (minutes < 60) return '$minutes min';
    final hours = minutes / 60;
    final text = hours == hours.roundToDouble()
        ? hours.round().toString()
        : hours.toString();
    return hours == 1 ? '$text hr' : '$text hrs';
  }
}

abstract final class DemoInstant {
  static const helpers = [
    InstantHelper(
      id: 'best',
      name: 'Best available',
      etaMinutes: 9,
      maxMinutes: 240,
      rating: 4.9,
      mapX: 0.30,
      mapY: 0.66,
    ),
    InstantHelper(
      id: 'sunita',
      name: 'Sunita',
      etaMinutes: 12,
      maxMinutes: 180,
      rating: 4.9,
      mapX: 0.72,
      mapY: 0.30,
    ),
    InstantHelper(
      id: 'meena',
      name: 'Meena',
      etaMinutes: 14,
      maxMinutes: 120,
      rating: 4.8,
      mapX: 0.80,
      mapY: 0.72,
    ),
    InstantHelper(
      id: 'kavita',
      name: 'Kavita',
      etaMinutes: 18,
      maxMinutes: 90,
      rating: 4.8,
      mapX: 0.16,
      mapY: 0.30,
    ),
  ];

  static const durations = [
    InstantDuration(minutes: 30, price: 99, originalPrice: 180),
    InstantDuration(minutes: 60, price: 149, originalPrice: 299),
    InstantDuration(minutes: 90, price: 199, originalPrice: 399),
    InstantDuration(minutes: 120, price: 249, originalPrice: 499),
    InstantDuration(minutes: 180, price: 349, originalPrice: 699),
    InstantDuration(minutes: 240, price: 449, originalPrice: 899),
  ];
}
