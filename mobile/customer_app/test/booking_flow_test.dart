import 'package:customer_app/app/router/routes.dart';
import 'package:customer_app/features/booking/data/booking_store.dart';
import 'package:customer_app/features/booking/domain/booking.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_app.dart';

BookingDraft _draft({bool instant = false}) => BookingDraft(
  serviceTitle: 'Home help',
  start: DateTime.now().add(const Duration(days: 1)),
  minutes: 60,
  price: 99,
  originalPrice: 278,
  instant: instant,
  etaMinutes: 9,
);

ProviderContainer _containerWithDraft({bool instant = false}) {
  final c = ProviderContainer();
  c.read(draftProvider.notifier).set(_draft(instant: instant));
  return c;
}

void main() {
  test('bill adds the platform fee and taxes', () {
    const bill = Bill(service: 99, original: 278);
    expect(bill.tax, 6.75);
    expect(bill.total, 115.75);
    expect(bill.savings, 179);
  });

  testWidgets('checkout shows the order, the bill and the total', (
    tester,
  ) async {
    await pumpApp(tester, Routes.checkout, container: _containerWithDraft());
    expect(find.text('Home help'), findsWidgets);
    expect(find.text('Bill summary'), findsOneWidget);
    expect(find.text('₹99.00'), findsOneWidget);
    expect(find.text('₹10.00'), findsOneWidget);
    expect(find.text('₹6.75'), findsOneWidget);
    expect(find.text('₹115.75'), findsWidgets);
    expect(find.text('You save ₹179 on this order'), findsOneWidget);
    expect(find.text('Pay now'), findsOneWidget);
  });

  testWidgets('the booking policy opens and closes', (tester) async {
    await pumpApp(tester, Routes.checkout, container: _containerWithDraft());
    expect(find.text('Cancellation'), findsNothing);
    await tester.tap(find.text('Booking policy'));
    await pumpFor(tester, 400);
    expect(find.text('Cancellation'), findsOneWidget);
    expect(find.text('Reschedule'), findsOneWidget);
    await tester.tap(find.text('Booking policy'));
    await pumpFor(tester, 400);
    expect(find.text('Cancellation'), findsNothing);
  });

  testWidgets('choosing a UPI app changes the method and shows the amount', (
    tester,
  ) async {
    final c = await pumpApp(
      tester,
      Routes.payment,
      container: _containerWithDraft(),
    );
    expect(find.text('Pay ₹115.75'), findsOneWidget);
    await tester.tap(find.text('PhonePe'));
    await pumpFor(tester, 300);
    expect(c.read(paymentMethodProvider).id, 'phonepe');
  });

  testWidgets('paying confirms the booking and opens it', (tester) async {
    final c = await pumpApp(
      tester,
      Routes.checkout,
      container: _containerWithDraft(),
    );
    await tester.tap(find.text('Pay now'));
    await pumpFor(tester, 600);
    expect(find.text("We're confirming your payment"), findsOneWidget);

    await pumpFor(tester, 3000);
    expect(find.text('Booking confirmed'), findsOneWidget);
    expect(find.text('Check-in code'), findsOneWidget);
    expect(c.read(bookingStoreProvider), hasLength(1));
    expect(c.read(draftProvider), isNull);
  });

  testWidgets('a failed payment can be retried', (tester) async {
    await pumpApp(
      tester,
      Routes.paymentFailed,
      container: _containerWithDraft(),
    );
    expect(find.text('Payment failed'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Contact support'), findsOneWidget);
  });

  testWidgets('a booking moves through every stage', (tester) async {
    final c = ProviderContainer();
    final booking = c
        .read(bookingStoreProvider.notifier)
        .create(_draft(), paidWith: 'GPay UPI');
    await pumpApp(tester, Routes.bookingDetail(booking.id), container: c);
    expect(find.text('Booking confirmed'), findsOneWidget);

    Future<void> next() async {
      final button = find.text('Debug: preview next stage');
      await tester.scrollUntilVisible(button, 200);
      await tester.tap(button);
      await pumpFor(tester, 600);
    }

    await next();
    expect(find.text('Your expert has arrived'), findsOneWidget);
    await next();
    expect(find.text('Service in progress'), findsOneWidget);
    await next();
    expect(find.text('Service about to end'), findsOneWidget);
    await next();
    expect(find.text('Service completed'), findsOneWidget);
  });
}
