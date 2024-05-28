import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  testWidgets("_", (tester) async {
    await tester.pumpWidget(MaterialApp(home: Text("hello")));
    await tester.pumpAndSettle();
  });
}
