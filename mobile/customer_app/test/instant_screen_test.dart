import 'package:customer_app/app/app_theme.dart';
import 'package:customer_app/features/booking/data/demo_instant.dart';
import 'package:customer_app/features/booking/presentation/instant_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(theme: AppTheme.light(), home: const InstantScreen()),
    ),
  );
  // The map pulses forever, so step time instead of settling.
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _step(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  test('duration labels read naturally', () {
    expect(DemoInstant.durations.map((d) => d.label), [
      '30 min',
      '1 hr',
      '1.5 hrs',
      '2 hrs',
      '3 hrs',
      '4 hrs',
    ]);
  });

  testWidgets('starts on best available with 1 hr selected', (tester) async {
    await _pump(tester);
    expect(find.text('Choose a helper'), findsOneWidget);
    expect(find.text('Select duration'), findsOneWidget);
    expect(find.text('₹149'), findsWidgets);
    expect(find.text('Arrives in about 9 min'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('picking a duration updates the total', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('2 hrs'));
    await _step(tester);
    expect(find.text('₹249'), findsWidgets);
  });

  testWidgets('a helper with less time shrinks the options and the ETA', (
    tester,
  ) async {
    await _pump(tester);
    await tester.tap(find.text('3 hrs'));
    await _step(tester);
    expect(find.text('₹349'), findsWidgets);

    // Kavita is free for 90 minutes only, 18 minutes away.
    await tester.tap(find.text('Kavita'));
    await _step(tester);
    expect(find.text('Arrives in about 18 min'), findsOneWidget);
    expect(find.text('Not available'), findsNWidgets(3));
    // The 3 hr choice no longer fits, so it falls back to 90 minutes.
    expect(find.text('₹199'), findsWidgets);
  });
}
