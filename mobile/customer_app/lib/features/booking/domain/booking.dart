/// Where a booking is in its life.
enum BookingStatus {
  /// Paid; an expert is assigned shortly before the start time.
  confirmed,

  /// The expert is at the door.
  arrived,

  /// The visit has started.
  inProgress,

  /// The last couple of minutes of the visit.
  aboutToEnd,

  completed,
  cancelled,
}

/// Rupee breakdown for one booking.
class Bill {
  const Bill({required this.service, required this.original});

  final int service;
  final int original;

  static const platformFee = 10.0;

  /// 5% on the service, 18% on the platform fee.
  double get tax => _round(service * 0.05 + platformFee * 0.18);
  double get total => _round(service + platformFee + tax);
  int get savings => original - service;

  static double _round(double v) => (v * 100).roundToDouble() / 100;
}

class Address {
  const Address({
    required this.id,
    required this.label,
    required this.line1,
    required this.line2,
  });

  final String id;
  final String label;
  final String line1;
  final String line2;

  String get full => '$line1, $line2';
}

class Expert {
  const Expert({
    required this.name,
    required this.rating,
    this.phone = '+91 98765 43210',
  });

  final String name;
  final double rating;
  final String phone;

  String get initial => name.substring(0, 1);
}

/// What the customer picked, before paying.
class BookingDraft {
  const BookingDraft({
    required this.serviceTitle,
    required this.start,
    required this.minutes,
    required this.price,
    required this.originalPrice,
    this.instant = false,
    this.etaMinutes,
    this.expertName,
  });

  final String serviceTitle;

  /// When the visit starts; for Instant this is the moment of booking.
  final DateTime start;
  final int minutes;
  final int price;
  final int originalPrice;
  final bool instant;
  final int? etaMinutes;

  /// A specific helper chosen on the Instant screen, if any.
  final String? expertName;

  Bill get bill => Bill(service: price, original: originalPrice);

  String get durationLabel => '$minutes min';
}

class Booking {
  const Booking({
    required this.id,
    required this.draft,
    required this.address,
    required this.status,
    required this.paidWith,
    required this.checkInOtp,
    required this.checkOutOtp,
    required this.createdAt,
    this.expert,
    this.rating,
    this.favourited = false,
    this.extraMinutes = 0,
    this.extraPaid = 0,
  });

  final String id;
  final BookingDraft draft;
  final Address address;
  final BookingStatus status;
  final String paidWith;
  final String checkInOtp;
  final String checkOutOtp;
  final DateTime createdAt;
  final Expert? expert;

  /// 0 until the customer rates; 1 to 5 after, 6 for the "extra mile" star.
  final int? rating;
  final bool favourited;
  final int extraMinutes;
  final int extraPaid;

  Bill get bill => draft.bill;
  int get totalMinutes => draft.minutes + extraMinutes;
  DateTime get start => draft.start;
  DateTime get end => start.add(Duration(minutes: totalMinutes));

  bool get isActive =>
      status == BookingStatus.confirmed ||
      status == BookingStatus.arrived ||
      status == BookingStatus.inProgress ||
      status == BookingStatus.aboutToEnd;

  Booking copyWith({
    BookingStatus? status,
    Expert? expert,
    int? rating,
    bool? favourited,
    int? extraMinutes,
    int? extraPaid,
  }) => Booking(
    id: id,
    draft: draft,
    address: address,
    status: status ?? this.status,
    paidWith: paidWith,
    checkInOtp: checkInOtp,
    checkOutOtp: checkOutOtp,
    createdAt: createdAt,
    expert: expert ?? this.expert,
    rating: rating ?? this.rating,
    favourited: favourited ?? this.favourited,
    extraMinutes: extraMinutes ?? this.extraMinutes,
    extraPaid: extraPaid ?? this.extraPaid,
  );
}
