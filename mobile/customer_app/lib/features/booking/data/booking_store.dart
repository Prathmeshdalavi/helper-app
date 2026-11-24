import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/booking.dart';

/// Where the customer lives. One demo address until Saved addresses exists.
/// TODO(addresses): replace with GET /users/me/addresses.
const demoAddress = Address(
  id: 'home',
  label: 'Home',
  line1: 'B104, Sai Prasad Enclave, 36 Kamothe Marg',
  line2: 'Shalome CHS, Sector 8, Kamothe, Panvel, Maharashtra 410209',
);

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
      address: demoAddress,
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
      switch (b.status) {
        case BookingStatus.confirmed:
          return b.copyWith(
            status: BookingStatus.arrived,
            expert: b.expert ?? const Expert(name: 'Sunita Rao', rating: 4.8),
          );
        case BookingStatus.arrived:
          return b.copyWith(status: BookingStatus.inProgress);
        case BookingStatus.inProgress:
          return b.copyWith(status: BookingStatus.aboutToEnd);
        case BookingStatus.aboutToEnd:
          return b.copyWith(status: BookingStatus.completed);
        case BookingStatus.completed:
        case BookingStatus.cancelled:
          return b;
      }
    });
  }
}

final bookingStoreProvider = NotifierProvider<BookingStore, List<Booking>>(
  BookingStore.new,
);

final bookingByIdProvider = Provider.family<Booking?, String>((ref, id) {
  for (final b in ref.watch(bookingStoreProvider)) {
    if (b.id == id) return b;
  }
  return null;
});
