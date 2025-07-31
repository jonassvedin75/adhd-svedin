import 'package:flutter_test/flutter_test.dart';
import 'package:ai_kodhjalp/main.dart';
import 'package:ai_kodhjalp/app/app.dart';

void main() {
  testWidgets('App starts and renders smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app renders without crashing.
    // We can check for a known widget, for example the initial route.
    // This is a basic check to ensure the app starts.
    expect(find.byType(MyApp), findsOneWidget);
  });
}
