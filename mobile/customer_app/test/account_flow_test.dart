import 'package:customer_app/app/router/routes.dart';
import 'package:customer_app/features/account/data/address_store.dart';
import 'package:customer_app/features/account/data/wallet_store.dart';
import 'package:customer_app/features/auth/data/session.dart';
import 'package:customer_app/features/booking/data/booking_store.dart';
import 'package:customer_app/features/booking/domain/booking.dart';
import 'package:customer_app/features/home/presentation/home_tab_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_app.dart';

BookingDraft _draft() => BookingDraft(
  serviceTitle: 'Home help',
  start: DateTime.now().add(const Duration(days: 2)),
  minutes: 60,
  price: 99,
  originalPrice: 278,
);

ProviderContainer _signedIn({int bookings = 0, int advances = 0}) {
  final c = ProviderContainer();
  c
      .read(sessionProvider.notifier)
      .signIn(name: 'Priya Sharma', phone: '7796693451');
  final store = c.read(bookingStoreProvider.notifier);
  for (var i = 0; i < bookings; i++) {
    final b = store.create(_draft(), paidWith: 'GPay UPI');
    for (var a = 0; a < advances; a++) {
      store.advance(b.id);
    }
  }
  return c;
}

Future<void> _tabTo(WidgetTester tester, ProviderContainer c, int i) async {
  c.read(homeTabProvider.notifier).show(i);
  await pumpFor(tester, 500);
}

void main() {
  testWidgets('Bookings tab lists a booking and opens it', (tester) async {
    final c = _signedIn(bookings: 1);
    await pumpApp(tester, Routes.home, container: c);
    await _tabTo(tester, c, 1);
    expect(find.text('My bookings'), findsOneWidget);
    expect(find.text('Confirmed'), findsOneWidget);

    await tester.tap(
      find.text('Past · 0').evaluate().isEmpty
          ? find.text('Past')
          : find.text('Past · 0'),
    );
    await pumpFor(tester, 400);
    expect(find.text('No past bookings'), findsOneWidget);

    await tester.tap(find.text('Upcoming · 1'));
    await pumpFor(tester, 400);
    await tester.tap(find.text('Confirmed'));
    await pumpFor(tester, 600);
    expect(find.text('Booking confirmed'), findsOneWidget);
  });

  testWidgets('Bookings tab empty state sends you home', (tester) async {
    final c = _signedIn();
    await pumpApp(tester, Routes.home, container: c);
    await _tabTo(tester, c, 1);
    expect(find.text('No bookings yet'), findsOneWidget);
    await tester.tap(find.text('Book now'));
    await pumpFor(tester, 500);
    expect(c.read(homeTabProvider), 0);
  });

  testWidgets('Offers tab shows codes', (tester) async {
    final c = _signedIn();
    await pumpApp(tester, Routes.home, container: c);
    await _tabTo(tester, c, 2);
    expect(find.text('FIRST20'), findsOneWidget);
    expect(find.text('Refer & earn ₹200'), findsOneWidget);
  });

  testWidgets('Profile shows the name and opens Edit profile', (tester) async {
    final c = _signedIn();
    await pumpApp(tester, Routes.home, container: c);
    await _tabTo(tester, c, 3);
    expect(find.text('Priya Sharma'), findsOneWidget);
    expect(find.text('+91 77966 93451'), findsOneWidget);

    await tester.tap(find.text('Priya Sharma'));
    await pumpFor(tester, 600);
    expect(find.text('Edit profile'), findsWidgets);
    await tester.enterText(find.byType(TextField).first, 'Priya S');
    await pumpFor(tester, 200);
    await tester.tap(find.text('Female'));
    await pumpFor(tester, 200);
    await tester.tap(find.text('Update'));
    await pumpFor(tester, 600);
    expect(c.read(sessionProvider).name, 'Priya S');
    expect(c.read(sessionProvider).gender, 'Female');
  });

  testWidgets('a new address can be added and becomes selected', (
    tester,
  ) async {
    final c = _signedIn();
    await pumpApp(tester, Routes.home, container: c);
    await _tabTo(tester, c, 3);
    await tester.scrollUntilVisible(
      find.text('Saved addresses'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Saved addresses'));
    await pumpFor(tester, 600);
    expect(find.text('SELECTED'), findsOneWidget);

    await tester.tap(find.text('Add address'));
    await pumpFor(tester, 600);
    await tester.tap(find.text('Work'));
    await pumpFor(tester, 200);
    await tester.enterText(find.byType(TextField).at(0), '12 Park Road');
    await tester.enterText(find.byType(TextField).at(1), 'Panvel 410206');
    await pumpFor(tester, 200);
    await tester.tap(find.text('Save address'));
    await pumpFor(tester, 600);
    final state = c.read(addressProvider);
    expect(state.addresses, hasLength(2));
    expect(state.selected.label, 'Work');
  });

  testWidgets('Wallet shows a zero balance and the booking payments', (
    tester,
  ) async {
    final c = _signedIn(bookings: 1);
    await pumpApp(tester, Routes.wallet, container: c);
    expect(find.text('Available balance'), findsOneWidget);
    expect(find.text('Add money'), findsOneWidget);
    expect(find.text('Paid for Home help'), findsOneWidget);
    expect(find.text('−₹115.75'), findsOneWidget);

    // The Added filter hides it, the Spent filter keeps it.
    await tester.tap(find.text('Added'));
    await pumpFor(tester, 400);
    expect(find.text('Paid for Home help'), findsNothing);
    expect(find.text('No transactions yet'), findsOneWidget);
    await tester.tap(find.text('Spent'));
    await pumpFor(tester, 400);
    expect(find.text('Paid for Home help'), findsOneWidget);
  });

  testWidgets('the add money sheet checks the amount and shows the bonus', (
    tester,
  ) async {
    final c = _signedIn();
    await pumpApp(tester, Routes.wallet, container: c);
    await tester.tap(find.text('Add money'));
    await pumpFor(tester, 600);
    expect(find.text('Add ₹500'), findsOneWidget);
    expect(find.text('You get ₹25 extra as bonus'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '20');
    await pumpFor(tester, 300);
    expect(find.text('Enter an amount from ₹50 to ₹10,000'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '200');
    await pumpFor(tester, 300);
    expect(find.text('Add ₹200'), findsOneWidget);
    expect(find.text('You get ₹25 extra as bonus'), findsNothing);
  });

  testWidgets('adding money pays, credits the wallet and the bonus', (
    tester,
  ) async {
    final c = _signedIn();
    await pumpApp(tester, Routes.wallet, container: c);
    await tester.tap(find.text('₹500').first);
    await pumpFor(tester, 600);
    expect(find.text('To pay: ₹500.00'), findsOneWidget);
    expect(find.text('Wallet'), findsNothing);
    await tester.tap(find.text('Pay ₹500.00'));
    await pumpFor(tester, 800);
    await pumpFor(tester, 3200);
    final w = c.read(walletProvider);
    expect(w.cash, 500);
    expect(w.bonus, 25);
    expect(find.text('Available balance'), findsOneWidget);
    expect(find.text('Added to wallet'), findsOneWidget);
    expect(find.text('Bonus on top-up'), findsOneWidget);
  });

  testWidgets('a booking can be paid from the wallet', (tester) async {
    final c = _signedIn();
    c.read(walletProvider.notifier).topUp(1000);
    c.read(draftProvider.notifier).set(_draft());
    await pumpApp(tester, Routes.payment, container: c);
    expect(find.text('Balance ₹1050'), findsOneWidget);
    await tester.tap(find.text('Wallet'));
    await pumpFor(tester, 600);
    expect(find.text('Pay from wallet'), findsOneWidget);
    await tester.tap(find.text('Pay ₹115.75').last);
    await pumpFor(tester, 800);
    await pumpFor(tester, 3200);
    final b = c.read(bookingStoreProvider).first;
    expect(b.paidWith, 'Wallet');
    expect(c.read(walletProvider).balance, closeTo(1050 - 115.75, 0.01));
    expect(find.text('Booking confirmed'), findsOneWidget);
  });

  testWidgets('a low wallet cannot pay a booking', (tester) async {
    final c = _signedIn();
    c.read(draftProvider.notifier).set(_draft());
    await pumpApp(tester, Routes.payment, container: c);
    await tester.tap(find.text('Wallet'));
    await pumpFor(tester, 500);
    expect(find.textContaining('Wallet balance is ₹0'), findsOneWidget);
    expect(find.text('Pay from wallet'), findsNothing);
  });

  testWidgets('cancelling a wallet booking refunds it', (tester) async {
    final c = _signedIn();
    c.read(walletProvider.notifier).topUp(1000);
    c.read(walletProvider.notifier).spend(115.75, 'Paid for Home help');
    final b = c
        .read(bookingStoreProvider.notifier)
        .create(_draft(), paidWith: 'Wallet');
    await pumpApp(tester, Routes.bookingDetail(b.id), container: c);
    await tester.drag(find.byType(ListView).first, const Offset(0, -700));
    await pumpFor(tester, 300);
    await tester.tap(find.text('Modify booking'));
    await pumpFor(tester, 600);
    await tester.tap(find.text('Cancel booking').first);
    await pumpFor(tester, 500);
    await tester.tap(find.text('Cancel booking').last);
    await pumpFor(tester, 800);
    expect(c.read(walletProvider).balance, closeTo(1050, 0.01));
  });

  testWidgets('Help opens answers, searches and reaches the chat', (
    tester,
  ) async {
    final c = _signedIn(bookings: 1);
    await pumpApp(tester, Routes.help, container: c);
    expect(find.text('Recent visit'), findsOneWidget);
    await tester.tap(find.text('Why was my booking cancelled?'));
    await pumpFor(tester, 400);
    expect(find.textContaining('refunded to you'), findsOneWidget);

    await tester.tap(find.text('Account'));
    await pumpFor(tester, 400);
    expect(find.text('I want to add a new address'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'refund');
    await pumpFor(tester, 400);
    expect(find.text('I have not received my refund'), findsOneWidget);
  });

  testWidgets('Support chat answers a message', (tester) async {
    final c = _signedIn();
    await pumpApp(tester, Routes.support, container: c);
    expect(find.textContaining('Need a hand'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'My refund is late');
    await pumpFor(tester, 200);
    await tester.tap(find.byTooltip('Send'));
    await pumpFor(tester, 300);
    expect(find.text('My refund is late'), findsOneWidget);
    await pumpFor(tester, 1800);
    expect(find.textContaining('support agent will reply'), findsOneWidget);
  });

  testWidgets('Your experts and favourites follow the visits', (tester) async {
    final c = _signedIn(bookings: 1, advances: 1);
    await pumpApp(tester, Routes.favourites, container: c);
    expect(find.text('Add an expert as a favourite'), findsOneWidget);

    c
        .read(bookingStoreProvider.notifier)
        .setExpertFavourite('Sunita Rao', true);
    await pumpFor(tester, 600);
    expect(find.text('Sunita Rao'), findsOneWidget);
  });

  testWidgets('Your experts starts empty', (tester) async {
    final c = _signedIn();
    await pumpApp(tester, Routes.experts, container: c);
    expect(
      find.text('All experts who visited you appear here'),
      findsOneWidget,
    );
  });

  testWidgets('logging out returns to sign in', (tester) async {
    final c = _signedIn();
    await pumpApp(tester, Routes.manageAccount, container: c);
    await tester.tap(find.text('Log out'));
    await pumpFor(tester, 600);
    expect(find.text('Log out?'), findsOneWidget);
    await tester.tap(find.text('Log out').last);
    await pumpFor(tester, 600);
    expect(c.read(sessionProvider).signedIn, isFalse);
  });

  testWidgets('a confirmed booking can be cancelled', (tester) async {
    final c = _signedIn(bookings: 1);
    final b = c.read(bookingStoreProvider).first;
    await pumpApp(tester, Routes.bookingDetail(b.id), container: c);
    await tester.drag(find.byType(ListView).first, const Offset(0, -700));
    await pumpFor(tester, 300);
    await tester.tap(find.text('Modify booking'));
    await pumpFor(tester, 600);
    await tester.tap(find.text('Cancel booking').first);
    await pumpFor(tester, 500);
    expect(find.text('Cancel this booking?'), findsOneWidget);
    await tester.tap(find.text('Cancel booking').last);
    await pumpFor(tester, 800);
    expect(c.read(bookingByIdProvider(b.id))!.status, BookingStatus.cancelled);
    expect(find.text('Booking cancelled'), findsOneWidget);
  });

  testWidgets('payment details shows the bill', (tester) async {
    final c = _signedIn(bookings: 1);
    final b = c.read(bookingStoreProvider).first;
    await pumpApp(tester, Routes.bookingDetail(b.id), container: c);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
    await pumpFor(tester, 300);
    await tester.tap(find.text('Payment details'));
    await pumpFor(tester, 600);
    expect(find.text('Total paid'), findsOneWidget);
    expect(find.text('₹115.75'), findsOneWidget);
  });
}
