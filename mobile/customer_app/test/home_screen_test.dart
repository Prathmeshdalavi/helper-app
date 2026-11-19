import 'package:customer_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows welcome content and service cards', (tester) async {
    await tester.pumpWidget(const CustomerApp());

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

  testWidgets('Explore Services shows the coming soon SnackBar', (tester) async {
    await tester.pumpWidget(const CustomerApp());

    final button = find.text('Explore Services');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();

    expect(find.text('Customer App Demo — Coming Soon'), findsOneWidget);
  });
}
