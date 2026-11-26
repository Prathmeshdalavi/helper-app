import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:worker_app/app/router/routes.dart';
import 'package:worker_app/features/auth/data/session.dart';

import 'test_app.dart';

Future<void> _enterPhone(WidgetTester tester, String phone) async {
  await tester.enterText(find.byType(TextField), phone);
  await tester.pump();
  await tester.tap(find.text('Get OTP'));
  await pumpFor(tester, 1200);
}

Future<void> _enterOtp(WidgetTester tester, String code) async {
  await tester.enterText(find.byType(TextField).last, code);
  await pumpFor(tester, 1500);
}

void main() {
  testWidgets('the button waits for a 10 digit number', (tester) async {
    await pumpApp(tester, Routes.login);
    FilledButton button() => tester.widget(find.byType(FilledButton));

    await tester.enterText(find.byType(TextField), '98765');
    await tester.pump();
    expect(button().onPressed, isNull);

    await tester.enterText(find.byType(TextField), '9876543210');
    await tester.pump();
    expect(button().onPressed, isNotNull);
  });

  testWidgets('demo number and OTP 1234 reach home', (tester) async {
    final c = await pumpApp(tester, Routes.login);
    await _enterPhone(tester, '9876543210');
    expect(find.text('Sent to +91 98765 43210'), findsOneWidget);

    await _enterOtp(tester, '1234');
    expect(find.text('Hi, Lakshmi'), findsOneWidget);
    expect(c.read(sessionProvider).signedIn, isTrue);
  });

  testWidgets('a wrong OTP is rejected', (tester) async {
    final c = await pumpApp(tester, Routes.login);
    await _enterPhone(tester, '9876543210');
    await _enterOtp(tester, '0000');
    expect(find.text('Incorrect OTP. Try again.'), findsOneWidget);
    expect(c.read(sessionProvider).signedIn, isFalse);
  });

  testWidgets('a new number goes through sign up and documents', (
    tester,
  ) async {
    await pumpApp(tester, Routes.login);
    await _enterPhone(tester, '9000000001');
    await _enterOtp(tester, '1234');
    expect(find.text('Choose language'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await pumpFor(tester, 800);
    await tester.enterText(find.byType(TextField).at(0), 'Asha More');
    await tester.enterText(find.byType(TextField).at(1), 'Manpada');
    await tester.tap(find.text('Mopping'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await pumpFor(tester, 800);

    for (final doc in ['Aadhaar card', 'Your photo', 'Police verification']) {
      await tester.tap(find.text(doc));
      await pumpFor(tester, 600);
      await tester.tap(find.text('Take photo'));
      await pumpFor(tester, 600);
    }
    // Let the toast leave before using the button under it.
    await pumpFor(tester, 2600);
    await tester.tap(find.text('Finish sign up'));
    await pumpFor(tester, 800);
    expect(find.text('Hi, Asha'), findsOneWidget);
  });
}
