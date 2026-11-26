import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:worker_app/app/router/routes.dart';
import 'package:worker_app/features/earnings/data/earnings_store.dart';
import 'package:worker_app/features/jobs/data/work_store.dart';
import 'package:worker_app/features/rewards/data/rewards_store.dart';

import 'test_app.dart';

final _toggle = find.byKey(const ValueKey('online-toggle'));

Future<void> _goOnlineAndWaitForOffer(WidgetTester tester) async {
  await tester.tap(_toggle);
  await pumpFor(tester, 4800);
}

void main() {
  testWidgets('starts offline with the main sections', (tester) async {
    await pumpApp(tester, Routes.home, container: signedInContainer());
    expect(find.text('Hi, Lakshmi'), findsOneWidget);
    expect(find.text('You are offline'), findsOneWidget);
    expect(find.text('Go online'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('going online brings a request that can be declined', (
    tester,
  ) async {
    final c = await pumpApp(
      tester,
      Routes.home,
      container: signedInContainer(),
    );
    await tester.tap(_toggle);
    await pumpFor(tester, 600);
    expect(find.text('Looking for jobs nearby'), findsOneWidget);

    await pumpFor(tester, 4200);
    expect(find.text('Accept job'), findsOneWidget);
    await tester.tap(find.text('Decline'));
    await pumpFor(tester, 800);
    expect(find.text('Accept job'), findsNothing);
    expect(c.read(workProvider).active, isNull);
    // Offline stops the next request.
    await tester.tap(_toggle);
    await pumpFor(tester, 5000);
    expect(find.text('Accept job'), findsNothing);
  });

  testWidgets('an unanswered request times out', (tester) async {
    final c = await pumpApp(
      tester,
      Routes.home,
      container: signedInContainer(),
    );
    await _goOnlineAndWaitForOffer(tester);
    await pumpFor(tester, 31000);
    expect(find.text('Accept job'), findsNothing);
    expect(c.read(workProvider).offer, isNull);
    await tester.tap(_toggle);
    await pumpFor(tester, 400);
  });

  testWidgets('accept, check in, finish: pay and coins are credited', (
    tester,
  ) async {
    final c = await pumpApp(
      tester,
      Routes.home,
      container: signedInContainer(),
    );
    final coins = c.read(rewardsProvider).coins;
    final jobsPay = c.read(earningsProvider).month.jobs;

    await _goOnlineAndWaitForOffer(tester);
    await tester.tap(find.text('Accept job'));
    await pumpFor(tester, 800);
    await tester.tap(find.text("I've arrived"));
    await pumpFor(tester, 600);

    // A wrong code does not start the job.
    await tester.tap(find.text('Take before photo'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '9999');
    await tester.pump();
    await tester.tap(find.text('Start job'));
    await tester.pump();
    expect(find.text('That code does not match'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '1234');
    await tester.pump();
    await tester.tap(find.text('Start job'));
    await pumpFor(tester, 600);

    for (final task in ['Mopping', 'Dusting', 'Surfaces']) {
      await tester.ensureVisible(find.text(task));
      await tester.pump();
      await tester.tap(find.text(task));
      await tester.pump();
    }
    await tester.scrollUntilVisible(
      find.text('Take after photo'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Take after photo'));
    await tester.pump();
    await tester.tap(find.text('Finish job'));
    await pumpFor(tester, 1500);

    expect(find.text('Job completed'), findsOneWidget);
    expect(c.read(rewardsProvider).coins, coins + 5);
    expect(c.read(earningsProvider).month.jobs, jobsPay + 210);

    await tester.scrollUntilVisible(
      find.text('Back to home'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Back to home'));
    await pumpFor(tester, 800);
    expect(find.text('Looking for jobs nearby'), findsOneWidget);
    expect(c.read(workProvider).jobsToday, 1);
    await tester.tap(_toggle);
    await pumpFor(tester, 400);
  });

  testWidgets('bottom bar switches between tabs', (tester) async {
    await pumpApp(tester, Routes.home, container: signedInContainer());
    for (final (tab, text) in [
      ('earnings', 'Total earnings'),
      ('refer', 'Earn up to ₹5,000'),
      ('updates', 'Weekend bonus is on'),
      ('profile', 'ID HC-543210'),
      ('home', 'Hi, Lakshmi'),
    ]) {
      await tester.tap(find.byKey(ValueKey('nav-$tab')));
      await pumpFor(tester, 500);
      expect(find.text(text), findsWidgets, reason: tab);
    }
  });
}
