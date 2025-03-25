import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/password_reset_screen.dart'; // moved

void main() {
  testWidgets('Displays password reset form', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PasswordResetScreen(),
          appBar: AppBar(title: const Text('Test')),
        ),
      ),
    );

    // Find the main heading by style (size 24 and bold)
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Text && 
                   widget.data == 'Passwort zurücksetzen' &&
                   widget.style?.fontSize == 24 &&
                   widget.style?.fontWeight == FontWeight.bold,
      ),
      findsOneWidget,
    );
    
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('Validates pass number input', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PasswordResetScreen(),
        ),
      ),
    );

    // Test invalid input
    await tester.enterText(find.byType(TextField), '1234');
    await tester.pump();
    
    final errorText = tester.widget<TextField>(find.byType(TextField))
        .decoration?.errorText;
    expect(errorText, contains('Passnummer muss 8 Ziffern enthalten'));

    // Test valid input
    await tester.enterText(find.byType(TextField), '12345678');
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).decoration?.errorText,
      isNull,
    );
  });
}