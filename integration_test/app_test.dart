import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:btrainer_log_viewer/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('verify initial UI elements', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify that the app bar title is correct.
      expect(
        find.widgetWithText(AppBar, 'B-Trainer Log Viewer (Step 1)'),
        findsOneWidget,
      );

      // Verify that the floating action button for opening files is present.
      expect(find.byIcon(Icons.folder_open), findsOneWidget);
    });
  });
}
