// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:e_jarkom/main.dart';
import 'package:e_jarkom/services/api_service.dart';
import 'package:e_jarkom/services/storage_service.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = StorageService(prefs);
    final apiService = ApiService();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MyApp(storageService: storageService, apiService: apiService),
    );

    // Verify that the app loads without crashing
    expect(find.byType(MyApp), findsOneWidget);
  });
}
