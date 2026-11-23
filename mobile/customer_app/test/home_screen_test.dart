import 'package:customer_app/app/app_theme.dart';
import 'package:customer_app/features/auth/data/session.dart';
import 'package:customer_app/features/home/presentation/home_shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Advance time in small steps (timers and looping animations never settle).
Future<void> _pumpFor(WidgetTester tester, int ms) async {
  for (var t = 0; t < ms; t += 100) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _pumpHome(WidgetTester tester) async {
  // Phone-sized screen so every section is laid out.
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final container = ProviderContainer();
  addTearDown(container.dispose);
  container
      .read(sessionProvider.notifier)
      .signIn(name: 'Priya Sharma', phone: '7796693451');

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: AppTheme.light(), home: const HomeShell()),
    ),
  );
  await _pumpFor(tester, 1000);
}

void main() {
  testWidgets('greets the user and shows the main sections', (tester) async {
    await _pumpHome(tester);

    expect(find.text('Hi, Priya'), findsOneWidget);
    expect(find.text('Trusted help for your home, in minutes'), findsOneWidget);
    expect(find.text('Book a helper'), findsOneWidget);
    expect(find.text('Schedule'), findsOneWidget);
    expect(find.text('Instant'), findsOneWidget);
    expect(find.text('Our services'), findsOneWidget);

    // Eight service cards, plus the "Explore more" row.
    for (final t in [
      'Cooking',
      'Cleaning',
      'Baby care',
      'Pet care',
      'Elder care',
      'Laundry',
      'Full day',
      'Monthly',
      'Explore more services',
    ]) {
      expect(find.text(t), findsOneWidget, reason: t);
    }
    // The repeated "Popular tasks" grid is gone.
    expect(find.text('Popular tasks'), findsNothing);
  });

  testWidgets('search hint rotates through services', (tester) async {
    await _pumpHome(tester);
    expect(find.text("Search for 'bathroom cleaning'"), findsOneWidget);
    await _pumpFor(tester, 3000);
    expect(find.text("Search for 'dishwashing'"), findsOneWidget);
  });

  testWidgets('offer banners advance on their own', (tester) async {
    await _pumpHome(tester);
    expect(find.text('Your first booking,\n20% off'), findsOneWidget);
    await _pumpFor(tester, 4800);
    expect(find.text('A helper for\nthe full day'), findsOneWidget);
  });

  testWidgets('tapping a booking option explains it is coming soon', (
    tester,
  ) async {
    await _pumpHome(tester);
    await tester.tap(find.text('Schedule'));
    await _pumpFor(tester, 400);
    expect(find.text('Scheduling is coming soon'), findsOneWidget);
  });

  testWidgets('Explore more row is reachable and responds', (tester) async {
    await _pumpHome(tester);
    final list = find.byType(SingleChildScrollView).first;
    final row = find.text('Explore more services');
    await tester.dragUntilVisible(row, list, const Offset(0, -120));
    // Keep it clear of the floating bottom bar (which starts near y = 760).
    final y = tester.getCenter(row).dy;
    if (y > 650) await tester.drag(list, Offset(0, -(y - 450)));
    await _pumpFor(tester, 500);
    await tester.tap(row);
    await _pumpFor(tester, 400);
    expect(find.text('More services is coming soon'), findsOneWidget);
  });

  testWidgets('bottom bar switches between tabs', (tester) async {
    await _pumpHome(tester);

    await tester.tap(find.byKey(const ValueKey('nav-1')));
    await _pumpFor(tester, 400);
    expect(find.text('No bookings yet'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav-3')));
    await _pumpFor(tester, 400);
    expect(find.text('Priya Sharma'), findsOneWidget);
    expect(find.text('+91 77966 93451'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav-0')));
    await _pumpFor(tester, 400);
    expect(find.text('Hi, Priya'), findsOneWidget);
  });
}
