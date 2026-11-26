import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worker_app/app/router/routes.dart';
import 'package:worker_app/features/earnings/data/earnings_store.dart';
import 'package:worker_app/features/shifts/data/shift_store.dart';

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

  test('period leave is limited to one a month', () {
    final c = testContainer();
    addTearDown(c.dispose);
    final shifts = c.read(shiftProvider.notifier);
    const reason = ShiftNotifier.careLeaveReason;
    expect(shifts.applyLeave(DateTime(2026, 11, 27), reason), isNull);
    expect(shifts.applyLeave(DateTime(2026, 11, 28), reason), isNotNull);
    expect(shifts.applyLeave(DateTime(2026, 12, 2), reason), isNull);
  });
}
