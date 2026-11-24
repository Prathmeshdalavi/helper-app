import 'package:customer_app/app/router/routes.dart';
import 'package:customer_app/features/auth/data/session.dart';
import 'package:customer_app/features/booking/data/booking_store.dart';
import 'package:customer_app/features/home/presentation/home_tab_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'test_app.dart';

ProviderContainer _signedIn() {
  final c = ProviderContainer();
  c
      .read(sessionProvider.notifier)
      .signIn(name: 'Priya Sharma', phone: '7796693451');
  return c;
}

void main() {
  testWidgets('the address row opens saved addresses', (tester) async {
    await pumpApp(tester, Routes.home, container: _signedIn());
    await pumpFor(tester, 600);
    expect(find.textContaining('B104, Sai Prasad'), findsOneWidget);
    await tester.tap(find.textContaining('B104, Sai Prasad'));
    await pumpFor(tester, 600);
    expect(find.text('Saved addresses'), findsOneWidget);
  });

  testWidgets('the 20% off chip and the avatar switch tabs', (tester) async {
    final c = _signedIn();
    await pumpApp(tester, Routes.home, container: c);
    await pumpFor(tester, 600);
    await tester.tap(find.text('20% off'));
    await pumpFor(tester, 500);
    expect(c.read(homeTabProvider), 2);

    c.read(homeTabProvider.notifier).show(0);
    await pumpFor(tester, 400);
    await tester.tap(find.text('P').first);
    await pumpFor(tester, 500);
    expect(c.read(homeTabProvider), 3);
  });

  testWidgets('search finds a service and books it', (tester) async {
    final c = _signedIn();
    await pumpApp(tester, Routes.home, container: c);
    await pumpFor(tester, 600);
    await tester.tap(find.textContaining("Search for '"));
    await pumpFor(tester, 600);
    expect(find.text('Popular searches'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'bath');
    await pumpFor(tester, 400);
    expect(find.text('Bathroom cleaning'), findsOneWidget);
    await tester.tap(find.text('Bathroom cleaning'));
    await pumpFor(tester, 600);
    expect(find.text('Book Bathroom cleaning'), findsOneWidget);
    expect(c.read(selectedServiceProvider), 'Bathroom cleaning');

    await tester.tap(find.text('Schedule'));
    await pumpFor(tester, 700);
    expect(find.text('Schedule for later'), findsOneWidget);
  });

  testWidgets('search shows a friendly message for no match', (tester) async {
    await pumpApp(tester, Routes.search, container: _signedIn());
    await tester.enterText(find.byType(TextField), 'zzzz');
    await pumpFor(tester, 400);
    expect(find.text('No services found'), findsOneWidget);
  });

  testWidgets('Explore more lists the extra services', (tester) async {
    await pumpApp(tester, Routes.explore, container: _signedIn());
    await pumpFor(tester, 300);
    expect(find.text('More services'), findsOneWidget);
    expect(find.text('Garden care'), findsOneWidget);
    await tester.tap(find.text('Garden care'));
    await pumpFor(tester, 600);
    expect(find.text('Book Garden care'), findsOneWidget);
  });

  testWidgets('a service detail Book now carries the service to checkout', (
    tester,
  ) async {
    final c = _signedIn();
    await pumpApp(tester, Routes.serviceDetail('cooking'), container: c);
    await pumpFor(tester, 300);
    await tester.tap(find.text('Book now'));
    await pumpFor(tester, 600);
    expect(find.text('Book Cooking'), findsOneWidget);
    await tester.tap(find.text('Instant'));
    await pumpFor(tester, 800);
    await tester.tap(find.text('Continue'));
    await pumpFor(tester, 700);
    expect(find.text('Bill summary'), findsOneWidget);
    expect(find.text('Cooking'), findsWidgets);
    expect(c.read(draftProvider)!.serviceTitle, 'Cooking');
  });
}
