import 'package:customer_app/app/app_theme.dart';
import 'package:customer_app/features/booking/data/demo_schedule.dart';
import 'package:customer_app/features/booking/presentation/schedule_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pump(WidgetTester tester, DateTime now) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(),
      home: ScheduleScreen(now: now),
    ),
  );
  await tester.pumpAndSettle();
}

FilledButton _cartButton(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byType(FilledButton));

void main() {
  // 10:00 am, so today still has afternoon and evening slots.
  final morning = DateTime(2026, 11, 24, 10);
  // 9:00 pm, so nothing is left today.
  final lateNight = DateTime(2026, 11, 24, 21);

  test('today needs a one hour lead time, later days do not', () {
    final today = DateTime(2026, 11, 24);
    final tomorrow = DateTime(2026, 11, 25);
    final todays = DemoSchedule.slotsFor(today, morning, DayPart.morning);
    expect(todays.first.label, '11:00 am');
    final next = DemoSchedule.slotsFor(tomorrow, morning, DayPart.morning);
    expect(next.first.label, '7:00 am');
    expect(DemoSchedule.soldOut(today, lateNight), isTrue);
    expect(DemoSchedule.soldOut(tomorrow, lateNight), isFalse);
  });

  test('slot and duration labels read naturally', () {
    expect(DemoSchedule.durations.map((d) => d.label), [
      '0.5 hr',
      '1 hr',
      '1.5 hr',
      '2 hr',
      '3 hr',
    ]);
    expect(const TimeSlot(minuteOfDay: 12 * 60, extra: 0).label, '12:00 pm');
    expect(
      const TimeSlot(minuteOfDay: 7 * 60 + 30, extra: 10).label,
      '7:30 am',
    );
  });

  testWidgets('Add to cart stays disabled until duration and slot are set', (
    tester,
  ) async {
    await _pump(tester, morning);
    await tester.tap(find.text('Tomorrow'));
    await tester.pumpAndSettle();
    expect(_cartButton(tester).onPressed, isNull);

    await tester.tap(find.text('1 hr'));
    await tester.pumpAndSettle();
    expect(_cartButton(tester).onPressed, isNull);

    await tester.tap(find.text('7:30 am'));
    await tester.pumpAndSettle();
    expect(_cartButton(tester).onPressed, isNotNull);
    // ₹129 for the hour plus ₹10 for the busy slot.
    expect(find.text('Add to cart  ·  ₹139'), findsOneWidget);
  });

  testWidgets('switching to Afternoon shows afternoon slots', (tester) async {
    await _pump(tester, morning);
    await tester.tap(find.text('Tomorrow'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Afternoon'));
    await tester.pumpAndSettle();
    expect(find.text('12:00 pm'), findsOneWidget);
    expect(find.text('7:30 am'), findsNothing);
  });

  testWidgets('a fully booked day shows the empty state', (tester) async {
    await _pump(tester, lateNight);
    expect(find.text('NO SLOTS AVAILABLE TODAY'), findsOneWidget);
    expect(_cartButton(tester).onPressed, isNull);

    await tester.tap(find.text('Tomorrow'));
    await tester.pumpAndSettle();
    expect(find.text('NO SLOTS AVAILABLE TODAY'), findsNothing);
    expect(find.text('7:00 am'), findsOneWidget);
  });
}
