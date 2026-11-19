import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hercare_app/app/app.dart';

void main() {
  testWidgets('app boots to the home placeholder', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: HerCareApp()));
    await tester.pumpAndSettle();
    expect(find.text('HerCare'), findsOneWidget);
  });
}
