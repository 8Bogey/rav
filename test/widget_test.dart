// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mawlid_al_dhaki/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await tester.pumpWidget(
      const ProviderScope(
        child: AppRoot(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('Smart_gen'), findsWidgets);
  });
}
