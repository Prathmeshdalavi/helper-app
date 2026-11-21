import 'package:customer_app/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Advance time in small steps so route transitions and timers all run.
/// (pumpAndSettle would never finish: the OTP screen has a ticking timer.)
Future<void> _pumpFor(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 100) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _toLogin(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: CustomerApp()));
  expect(find.text('HerCare'), findsOneWidget); // splash
  await _pumpFor(tester, 2400);
}

Future<void> _toOtp(WidgetTester tester) async {
  await _toLogin(tester);
  await tester.enterText(find.byType(EditableText), '7796693451');
  await tester.pump();
  await tester.tap(find.text('Proceed'));
  await _pumpFor(tester, 800);
}

void main() {
  testWidgets('Proceed stays disabled until 10 digits are entered',
      (tester) async {
    await _toLogin(tester);
    expect(find.text('Trusted Home Helpers'), findsOneWidget);

    FilledButton button() =>
        tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button().onPressed, isNull);

    await tester.enterText(find.byType(EditableText), '77966');
    await tester.pump();
    expect(button().onPressed, isNull);

    await tester.enterText(find.byType(EditableText), '7796693451');
    await tester.pump();
    expect(button().onPressed, isNotNull);
  });

  testWidgets('hero scenes are swipeable', (tester) async {
    // Phone-sized screen so the captions fit (they hide on short screens).
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await _toLogin(tester);
    expect(find.text('Laundry, sorted'), findsOneWidget);

    Future<void> swipeLeft() async {
      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await _pumpFor(tester, 900);
    }

    await swipeLeft();
    expect(find.text('Spotless floors'), findsOneWidget);
    await swipeLeft();
    expect(find.text('Pet care, with love'), findsOneWidget);
    await swipeLeft();
    expect(find.text('Sparkling dishes'), findsOneWidget);
  });

  testWidgets('phone -> OTP -> success -> home', (tester) async {
    await _toOtp(tester);
    expect(find.text('Enter OTP'), findsOneWidget);
    expect(find.text('Sent to +91 77966 93451'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), '1234');
    await _pumpFor(tester, 1500);
    expect(find.text("You're all set!"), findsOneWidget);

    await _pumpFor(tester, 3200);
    expect(find.text('Welcome to HerCare'), findsOneWidget);
  });

  testWidgets('wrong OTP shows an error', (tester) async {
    await _toOtp(tester);
    await tester.enterText(find.byType(EditableText), '0000');
    await _pumpFor(tester, 1000);
    expect(find.text('Incorrect OTP. Please try again.'), findsOneWidget);
  });
}
