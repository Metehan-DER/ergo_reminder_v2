// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ergo_reminder_v2/main.dart';
import 'package:ergo_reminder_v2/core/services/storage_service.dart';
import 'package:ergo_reminder_v2/presentation/providers/service_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App renders home page smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = await StorageService.init();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [storageServiceProvider.overrideWithValue(storageService)],
        child: const MyApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('ErgoMate'), findsWidgets);
  });
}
