import 'package:flutter_test/flutter_test.dart';
import 'package:roux_trainer/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App builds and shows timer', (WidgetTester tester) async {
    await tester.pumpWidget(const RouxTrainerApp());
    await tester.pumpAndSettle();

    // Verify timer screen is shown
    expect(find.text('Timer'), findsWidgets);
    expect(find.text('Hold to start'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'selecting a training mode returns to timer tab without popping the app',
    (WidgetTester tester) async {
      await tester.pumpWidget(const RouxTrainerApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Training'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('First Block (FB)'));
      await tester.pumpAndSettle();

      expect(find.text('First Block'), findsOneWidget);
      expect(find.text('Hold to start'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
