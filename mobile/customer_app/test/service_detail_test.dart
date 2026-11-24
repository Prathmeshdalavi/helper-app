import 'package:customer_app/app/app_theme.dart';
import 'package:customer_app/features/services/data/demo_service_details.dart';
import 'package:customer_app/features/services/data/demo_services.dart';
import 'package:customer_app/features/services/presentation/service_detail_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _pumpDetail(WidgetTester tester, String id) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light(),
        home: ServiceDetailScreen(serviceId: id),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  test('every home service has detail content', () {
    for (final c in DemoServices.categories) {
      expect(DemoServiceDetails.byId(c.id), isNotNull, reason: c.id);
    }
  });

  testWidgets('shows price, what is included and a Book now button', (
    tester,
  ) async {
    await _pumpDetail(tester, 'cleaning');

    expect(find.text('Cleaning'), findsOneWidget);
    expect(find.text('₹149'), findsWidgets);
    expect(find.text('Book now'), findsOneWidget);
    expect(find.text("What's included"), findsOneWidget);
    expect(find.text('Sweeping and mopping'), findsOneWidget);
  });

  testWidgets('Book now offers Schedule or Instant', (tester) async {
    await _pumpDetail(tester, 'cooking');

    await tester.tap(find.text('Book now'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Book Cooking'), findsOneWidget);
    expect(find.text('Schedule'), findsOneWidget);
    expect(find.text('Instant'), findsOneWidget);
  });

  testWidgets('unknown service shows a friendly message', (tester) async {
    await _pumpDetail(tester, 'nope');
    expect(find.text('This service is not available'), findsOneWidget);
  });
}
