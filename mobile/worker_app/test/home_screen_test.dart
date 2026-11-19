import 'package:flutter_test/flutter_test.dart';
import 'package:worker_app/main.dart';

void main() {
  testWidgets('shows welcome content and job cards', (tester) async {
    await tester.pumpWidget(const WorkerApp());

    expect(find.text('HerCare Worker'), findsOneWidget);
    expect(find.text('Welcome, Helper!'), findsOneWidget);
    expect(
      find.text('Manage your work and opportunities in one place.'),
      findsOneWidget,
    );
    expect(find.text('Available Jobs'), findsOneWidget);
    expect(find.text('My Assignments'), findsOneWidget);
    expect(find.text('My Earnings'), findsOneWidget);
  });

  testWidgets('View Jobs shows the coming soon SnackBar', (tester) async {
    await tester.pumpWidget(const WorkerApp());

    final button = find.text('View Jobs');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();

    expect(find.text('Worker App Demo — Coming Soon'), findsOneWidget);
  });
}
