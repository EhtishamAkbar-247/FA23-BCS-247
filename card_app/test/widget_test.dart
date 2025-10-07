// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';

import 'package:card_app/main.dart';

void main() {
  testWidgets('Profile app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProfileApp());

    // Verify that the app bar title is present.
    expect(find.text('Professional CV'), findsOneWidget);

    // Verify that the profile name is present.
    expect(find.text('Muhammad Abdullah'), findsOneWidget);
  });
}
