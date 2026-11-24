import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/data/address_store.dart';
import '../domain/booking.dart';

/// The booking being set up, from the Schedule or Instant screen to payment.
class DraftNotifier extends Notifier<BookingDraft?> {
  @override
  BookingDraft? build() => null;

  void set(BookingDraft draft) => state = draft;
  void clear() => state = null;
}

final draftProvider = NotifierProvider<DraftNotifier, BookingDraft?>(
  DraftNotifier.new,
);

/// How the customer pays. Shown on the checkout bar.
class PaymentMethod {
  const PaymentMethod(this.id, this.label);

  final String id;
  final String label;
}

const upiApps = [
  PaymentMethod('gpay', 'GPay UPI'),
  PaymentMethod('phonepe', 'PhonePe UPI'),
  PaymentMethod('paytm', 'Paytm UPI'),
  PaymentMethod('bhim', 'BHIM UPI'),
];

class PaymentMethodNotifier extends Notifier<PaymentMethod> {
  @override
  PaymentMethod build() => upiApps.first;

  void select(PaymentMethod m) => state = m;
}

final paymentMethodProvider =
    NotifierProvider<PaymentMethodNotifier, PaymentMethod>(
      PaymentMethodNotifier.new,
    );

/// All of the customer's bookings, newest first. In memory for now.
/// TODO(booking): load from and write to the backend booking module.
class BookingStore extends Notifier<List<Booking>> {
  int _seq = 1000;

  @override
  List<Booking> build() => const [];

  /// Turns the draft into a paid booking and returns it.
  Booking create(BookingDraft draft, {required String paidWith}) {
    _seq += 1;
    final id = 'HC$_seq';
    final otp = (_seq * 7919 % 900 + 100).toString();
    final booking = Booking(
      id: id,
      draft: draft,
      address: ref.read(selectedAddressProvider),
      status: BookingStatus.confirmed,
      paidWith: paidWith,
      checkInOtp: otp,
      checkOutOtp: (int.parse(otp) * 3 % 900 + 100).toString(),
      createdAt: DateTime.now(),
      expert: draft.instant && draft.expertName != null
          ? Expert(name: draft.expertName!, rating: 4.8)
          : null,
    );
    state = [booking, ...state];
    return booking;
  }

  void update(String id, Booking Function(Booking b) change) {
    state = [for (final b in state) b.id == id ? change(b) : b];
  }

  void cancel(String id) =>
      update(id, (b) => b.copyWith(status: BookingStatus.cancelled));

  /// Demo only: steps a booking to its next stage so every screen can be seen.
  /// TODO(booking): stages come from the server (expert check-in, timers).
  void advance(String id) {
    update(id, (b) {
      final now = DateTime.now();
      switch (b.status) {
        case BookingStatus.confirmed:
          return b.copyWith(
            status: BookingStatus.arrived,
            arrivedAt: now,
            expert: b.expert ?? const Expert(name: 'Sunita Rao', rating: 4.8),
          );
        case BookingStatus.arrived:
          return b.copyWith(status: BookingStatus.inProgress, startedAt: now);
        case BookingStatus.inProgress:
          // Jump to the last two minutes so the end of the visit can be seen.
          return b.copyWith(
            status: BookingStatus.aboutToEnd,
            startedAt: now.subtract(
              Duration(seconds: b.totalMinutes * 60 - 125),
            ),
          );
        case BookingStatus.aboutToEnd:
          return b.copyWith(status: BookingStatus.completed);
        case BookingStatus.completed:
        case BookingStatus.cancelled:
          return b;
      }
    });
  }

  /// Adds paid time to a running visit.
  void extend(String id, {required int minutes, required int price}) {
    update(
      id,
      (b) => b.copyWith(
        extraMinutes: b.extraMinutes + minutes,
        extraPaid: b.extraPaid + price,
        status: BookingStatus.inProgress,
      ),
    );
  }

  void rate(String id, {required int stars, bool extraStar = false}) =>
      update(id, (b) => b.copyWith(rating: stars, extraStar: extraStar));

  void favourite(String id, bool value) =>
      update(id, (b) => b.copyWith(favourited: value));

  /// Marks every visit by this expert as favourite (or not).
  void setExpertFavourite(String expertName, bool value) {
    state = [
      for (final b in state)
        b.expert?.name == expertName ? b.copyWith(favourited: value) : b,
    ];
  }
}

/// An expert who has visited, with how often and whether they are a favourite.
class ExpertEntry {
  const ExpertEntry({
    required this.expert,
    required this.visits,
    required this.favourite,
  });

  final Expert expert;
  final int visits;
  final bool favourite;
}

final expertsProvider = Provider<List<ExpertEntry>>((ref) {
  final byName = <String, ExpertEntry>{};
  for (final b in ref.watch(bookingStoreProvider)) {
    final e = b.expert;
    if (e == null || b.status == BookingStatus.cancelled) continue;
    final prev = byName[e.name];
    byName[e.name] = ExpertEntry(
      expert: e,
      visits: (prev?.visits ?? 0) + 1,
      favourite: (prev?.favourite ?? false) || b.favourited,
    );
  }
  return byName.values.toList();
});

final bookingStoreProvider = NotifierProvider<BookingStore, List<Booking>>(
  BookingStore.new,
);

final bookingByIdProvider = Provider.family<Booking?, String>((ref, id) {
  for (final b in ref.watch(bookingStoreProvider)) {
    if (b.id == id) return b;
  }
  return null;
});
