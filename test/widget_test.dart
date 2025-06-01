// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:btrainer_log_viewer/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // テスト実行前に待機
    await tester.runAsync(() async {
      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(seconds: 1));
    });

    // AppBar内のタイトルを探す
    expect(find.widgetWithText(AppBar, 'B-Trainer Log Viewer'), findsOneWidget);

    // FloatingActionButtonを探す（ファイル選択ボタン）
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.folder_open), findsOneWidget);

    // 地図が存在することを確認
    expect(find.byType(FlutterMap), findsOneWidget);
  });
}
