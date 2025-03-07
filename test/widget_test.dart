import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/main.dart'; // Adjust this import according to your project name

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    final Finder fab = find.byTooltip('Increment');
    await tester.tap(fab);
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}