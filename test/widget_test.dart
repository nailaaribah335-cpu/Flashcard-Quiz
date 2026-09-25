import 'package:flutter_test/flutter_test.dart';
import 'package:ujian_coding/main.dart';

void main() {
  testWidgets('Flashcard Quiz smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FlashcardQuizApp());

    // Verify that Naila Aribah Zahra and Flashcard Quiz appear
    expect(find.textContaining('Naila Aribah Zahra'), findsOneWidget);
    expect(find.text('Flashcard Quiz'), findsOneWidget);
  });
}
