import 'package:customer_app/app/app_theme.dart';
import 'package:customer_app/features/home/presentation/home_screen.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows welcome content and service cards', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const HomeScreen()),
    );

    expect(find.text('HerCare'), findsOneWidget);
    expect(find.text('Welcome to HerCare'), findsOneWidget);
    expect(
      find.text('Find trusted home helpers for your everyday needs.'),
      findsOneWidget,
    );
    expect(find.text('Home Cleaning'), findsOneWidget);
    expect(find.text('Dishwashing'), findsOneWidget);
    expect(find.text('Laundry Assistance'), findsOneWidget);
  });

  testWidgets('Explore Services shows the coming soon SnackBar', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const HomeScreen()),
    );

    final button = find.text('Explore Services');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();

    expect(find.text('Customer App Demo — Coming Soon'), findsOneWidget);
  });
}
