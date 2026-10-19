import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:colima_night/main.dart';

void main() {
  testWidgets('ColimaNightApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ColimaNightApp(),
      ),
    );

    // Verify app renders with header texts
    expect(find.textContaining('COLIMA'), findsWidgets);
    expect(find.textContaining('NIGHT'), findsWidgets);
  });
}
