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

/// Demo number the mock repository treats as already registered.
const _existing = '9876543210';
const _newNumber = '7796693451';

Future<void> _submitPhone(WidgetTester tester, String phone) async {
  await _toLogin(tester);
  await tester.enterText(find.byType(EditableText), phone);
  await tester.pump();
  await tester.tap(find.text('Proceed'));
  await _pumpFor(tester, 1300); // mock lookup + route transition
}

Future<void> _toOtp(WidgetTester tester) => _submitPhone(tester, _existing);

void main() {
  testWidgets('Proceed stays disabled until 10 digits are entered', (
    tester,
  ) async {
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
    expect(find.text('Pet care, with love'), findsOneWidget);

    Future<void> swipeLeft() async {
      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await _pumpFor(tester, 900);
    }

    await swipeLeft();
    expect(find.text('Laundry, sorted'), findsOneWidget);
    await swipeLeft();
    expect(find.text('Spotless floors'), findsOneWidget);
    await swipeLeft();
    expect(find.text('Sparkling dishes'), findsOneWidget);
  });

  testWidgets('hero scenes swap by themselves, dog first', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await _toLogin(tester);
    expect(find.text('Pet care, with love'), findsOneWidget);

    await _pumpFor(tester, 3600);
    expect(find.text('Laundry, sorted'), findsOneWidget);
    await _pumpFor(tester, 3000);
    expect(find.text('Spotless floors'), findsOneWidget);
  });

  testWidgets('phone -> OTP -> success -> home', (tester) async {
    await _toOtp(tester);
    expect(find.text('Enter OTP'), findsOneWidget);
    expect(find.text('Sent to +91 98765 43210'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), '1234');
    await _pumpFor(tester, 1500);
    expect(find.text("You're all set!"), findsOneWidget);

    await _pumpFor(tester, 3200);
    expect(find.text('Hi, Anita'), findsOneWidget);
  });

  testWidgets('registered number skips sign up and goes to OTP', (
    tester,
  ) async {
    await _submitPhone(tester, _existing);
    expect(find.text('Create your account'), findsNothing);
    expect(find.text('Enter OTP'), findsOneWidget);
  });

  testWidgets('new number -> sign up -> OTP -> welcome by name', (
    tester,
  ) async {
    await _submitPhone(tester, _newNumber);
    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('+91 77966 93451'), findsOneWidget);

    FilledButton continueButton() =>
        tester.widget<FilledButton>(find.byType(FilledButton));
    expect(continueButton().onPressed, isNull);

    await tester.enterText(find.byType(TextField).at(0), 'Priya Sharma');
    await tester.pump();
    expect(continueButton().onPressed, isNull); // terms not accepted yet

    final terms = find.byKey(const ValueKey('terms-checkbox'));
    await tester.ensureVisible(terms);
    await tester.pump();
    await tester.tap(terms);
    await tester.pump();
    expect(continueButton().onPressed, isNotNull);

    // A malformed email blocks Continue; clearing it is fine (optional).
    await tester.enterText(find.byType(TextField).at(1), 'nope');
    await tester.pump();
    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(continueButton().onPressed, isNull);
    await tester.enterText(find.byType(TextField).at(1), 'priya@example.com');
    await tester.pump();
    expect(continueButton().onPressed, isNotNull);

    await tester.tap(find.text('Continue'));
    await _pumpFor(tester, 800);
    expect(find.text('Enter OTP'), findsOneWidget);
    expect(find.text('Sent to +91 77966 93451'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), '1234');
    await _pumpFor(tester, 1500);
    expect(find.text("You're all set!"), findsOneWidget);
    await _pumpFor(tester, 100);
    expect(find.text('Welcome to HerCare, Priya'), findsOneWidget);

    await _pumpFor(tester, 3200);
    expect(find.text('Hi, Priya'), findsOneWidget);
  });

  testWidgets('wrong OTP shows an error', (tester) async {
    await _toOtp(tester);
    await tester.enterText(find.byType(EditableText), '0000');
    await _pumpFor(tester, 1000);
    expect(find.text('Incorrect OTP. Please try again.'), findsOneWidget);
  });
}
