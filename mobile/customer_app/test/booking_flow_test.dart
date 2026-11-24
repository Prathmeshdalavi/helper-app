import 'package:customer_app/app/router/routes.dart';
import 'package:customer_app/features/booking/data/booking_store.dart';
import 'package:customer_app/features/booking/domain/booking.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

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

/// Scrolls the screen's main list until [target] is on screen.
Future<void> scrollTo(WidgetTester tester, Finder target) async {
  final list = find
      .descendant(
        of: find.byType(ListView).first,
        matching: find.byType(Scrollable),
      )
      .first;
  await tester.scrollUntilVisible(target, 200, scrollable: list);
  // Nudge it clear of the screen edge so a tap lands on it.
  await tester.drag(list, const Offset(0, -80));
  await tester.pump(const Duration(milliseconds: 300));
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
      await scrollTo(tester, button);
      await tester.tap(button);
      await pumpFor(tester, 600);
      // Back to the top, where each stage's main card sits.
      await tester.drag(find.byType(ListView).first, const Offset(0, 3000));
      await pumpFor(tester, 300);
    }

    await next();
    expect(find.text('Expert arrived'), findsOneWidget);
    expect(find.text('Sunita has arrived!'), findsOneWidget);
    await next();
    expect(find.text('Service in progress'), findsOneWidget);
    await next();
    expect(find.text('Service about to end'), findsOneWidget);
    await next();
    expect(find.text('Service completed'), findsOneWidget);
  });

  Booking runningBooking(ProviderContainer c, int advances) {
    final store = c.read(bookingStoreProvider.notifier);
    final b = store.create(_draft(), paidWith: 'GPay UPI');
    for (var i = 0; i < advances; i++) {
      store.advance(b.id);
    }
    return c.read(bookingByIdProvider(b.id))!;
  }

  testWidgets('the running service shows a countdown and can be extended', (
    tester,
  ) async {
    final c = ProviderContainer();
    final b = runningBooking(c, 2);
    await pumpApp(tester, Routes.bookingDetail(b.id), container: c);
    await pumpFor(tester, 400);
    expect(find.text('Service in progress'), findsOneWidget);
    expect(find.text('Time remaining'), findsOneWidget);
    expect(find.text('Check-out code'), findsOneWidget);

    await tester.tap(find.text('Extend service'));
    await pumpFor(tester, 500);
    await tester.tap(find.text('30 min'));
    await pumpFor(tester, 300);
    await tester.tap(find.text('Pay now'));
    await pumpFor(tester, 1500);
    expect(c.read(bookingByIdProvider(b.id))!.extraMinutes, 30);
    expect(c.read(bookingByIdProvider(b.id))!.extraPaid, 79);
  });

  testWidgets('a finished service can be rated and a friend invited', (
    tester,
  ) async {
    final c = ProviderContainer();
    final b = runningBooking(c, 4);
    await pumpApp(tester, Routes.bookingDetail(b.id), container: c);
    await pumpFor(tester, 400);
    expect(find.text('Service completed'), findsOneWidget);
    expect(find.text('Rate your experience'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.star_rounded).at(4));
    await pumpFor(tester, 600);
    expect(find.text('Your rating'), findsOneWidget);
    expect(
      find.text('Did your expert go the extra mile? Add an extra star.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Submit'));
    await pumpFor(tester, 900);
    expect(c.read(bookingByIdProvider(b.id))!.rating, 5);
    expect(find.text('Invite a friend\nand get ₹200'), findsOneWidget);
  });

  testWidgets("What's included lists tasks for each group", (tester) async {
    final c = ProviderContainer();
    final b = runningBooking(c, 0);
    await pumpApp(tester, Routes.bookingDetail(b.id), container: c);
    await scrollTo(tester, find.text("See what's included"));
    await tester.tap(find.text("See what's included"));
    await pumpFor(tester, 500);
    expect(find.text('What is included?'), findsOneWidget);
    expect(find.text('Sweep and mop accessible floors'), findsOneWidget);
    await tester.ensureVisible(find.text('Bathroom cleaning'));
    await pumpFor(tester, 300);
    await tester.tap(find.text('Bathroom cleaning'));
    await pumpFor(tester, 500);
    expect(find.text('Clean the toilet seat, rim and lid'), findsOneWidget);
  });
}
