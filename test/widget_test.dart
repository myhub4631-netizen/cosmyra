import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cosmyra/main.dart';

void main() {
  testWidgets('Cosmyra App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CosmyraApp(),
      ),
    );

    expect(find.text('COSMYRA'), findsOneWidget);
  });
}
