import 'package:flutter_test/flutter_test.dart';
import 'package:profile_selector_app/main.dart';

void main() {
  testWidgets('Profile Selector App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProfileSelectorApp());

    // Verify that the title 'Profiles' exists on the app bar.
    expect(find.text('Profiles'), findsOneWidget);

    // Verify that the active profile banner is displayed.
    expect(find.text('ACTIVE SYSTEM STATE'), findsOneWidget);
    expect(find.text('Normal Profile'), findsOneWidget);
  });
}
