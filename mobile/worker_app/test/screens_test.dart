import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_app/app/router/routes.dart';
import 'package:worker_app/features/earnings/data/earnings_store.dart';
import 'package:worker_app/features/shifts/data/shift_store.dart';
import 'package:worker_app/features/shop/data/shop_store.dart';

import 'test_app.dart';

/// Every pushed screen must lay out without overflow, down to a small phone.
final _screens = <String>[
  Routes.language,
  Routes.profileSetup,
  Routes.documents,
  Routes.job,
  Routes.payouts,
  Routes.earlyPayout,
  Routes.rateCard,
  Routes.bank,
  Routes.level,
  Routes.performance,
  Routes.attendance,
  Routes.leave,
  Routes.emergencyLogout,
  Routes.overtime,
  Routes.insuranceFor('accident'),
  Routes.insuranceFor('health'),
  Routes.coins,
  Routes.hospitals,
  Routes.store,
  Routes.training,
  Routes.help,
];

void main() {
  for (final route in [Routes.login, Routes.home, ..._screens]) {
    testWidgets('$route fits a small phone', (tester) async {
      await pumpApp(
        tester,
        route,
        container: signedInContainer(),
        physicalSize: const Size(960, 1704), // 320 x 568 points
      );
      expect(tester.takeException(), isNull);
    });
  }

  test('early payout needs a linked account and respects the limit', () {
    final c = testContainer();
    addTearDown(c.dispose);
    final notifier = c.read(earningsProvider.notifier);
    final limit = c.read(earningsProvider).earlyLimit;
    expect(notifier.withdrawEarly(100), isFalse);
    notifier.linkAccount('ab••••@bank');
    expect(notifier.withdrawEarly(limit + 1), isFalse);
    expect(notifier.withdrawEarly(100), isTrue);
    expect(c.read(earningsProvider).month.earlyPayout, 100);
  });

  test('period leave is one day, once a month; leaves cannot overlap', () {
    final c = testContainer();
    addTearDown(c.dispose);
    final shifts = c.read(shiftProvider.notifier);
    const care = ShiftNotifier.careLeaveReason;
    DateTime nov(int d) => DateTime(2026, 11, d);

    expect(shifts.applyLeave(nov(27), nov(28), care), isNotNull);
    expect(shifts.applyLeave(nov(27), nov(27), care), isNull);
    expect(shifts.applyLeave(nov(29), nov(29), care), isNotNull);
    expect(
      shifts.applyLeave(DateTime(2026, 12, 2), DateTime(2026, 12, 2), care),
      isNull,
    );
    expect(shifts.applyLeave(nov(26), nov(28), 'Family'), isNotNull);
    expect(shifts.applyLeave(nov(30), nov(29), 'Family'), isNotNull);
    expect(shifts.applyLeave(nov(29), nov(30), 'Family'), isNull);
  });

  test('a shop order is taken from the next payout, once', () {
    final c = testContainer();
    addTearDown(c.dispose);
    int cost() => c.read(earningsProvider).month.productCost;
    final before = cost();
    final apron = shopItems.firstWhere((i) => i.id == 'apron');
    final orders = c.read(ordersProvider.notifier);

    expect(orders.order(apron), isTrue);
    expect(orders.order(apron), isFalse);
    expect(orders.order(shopItems.firstWhere((i) => i.soldOut)), isFalse);
    expect(cost(), before + apron.price);
  });

  testWidgets('applying leave through the date pickers', (tester) async {
    await pumpApp(tester, Routes.leave, container: signedInContainer());
    await tester.tap(find.text('Apply leave'));
    await pumpFor(tester, 600);
    await tester.tap(find.text('Choose').first);
    await pumpFor(tester, 600);
    await tester.tap(find.text('OK'));
    await pumpFor(tester, 600);
    await tester.tap(find.text('Submit request'));
    await pumpFor(tester, 600);
    expect(find.text('Fri, 27 Nov'), findsOneWidget);
  });
}
