import 'package:flutter_test/flutter_test.dart';
import 'package:chupaca_directo/services/service_locator.dart';
import 'package:chupaca_directo/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Initialize service locator (will fallback to memory mock services in test environment)
    await ServiceLocator.init();

    await tester.pumpWidget(const MyApp());
    // Basic compilation smoke test verification
    expect(find.byType(MyApp), findsOneWidget);
  });
}
