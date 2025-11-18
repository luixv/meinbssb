import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/personal/personal_account_delete_screen.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';

class MockApiService extends Mock implements ApiService {
  bool deleteCalled = false;
  @override
  Future<bool> deleteMeinBSSBLogin(int webloginId) async {
    deleteCalled = true;
    return true;
  }
}

void main() {
  group('PersonalAccountDeleteScreen', () {
    late MockApiService mockApiService;
    late FontSizeProvider fontSizeProvider;
    late UserData userData;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      mockApiService = MockApiService();
      fontSizeProvider = FontSizeProvider();
      userData = UserData(
        personId: 1,
        webLoginId: 123,
        passnummer: '12345',
        vereinNr: 1,
        namen: 'Test',
        vorname: 'User',
        vereinName: 'TestVerein',
        passdatenId: 1,
        mitgliedschaftId: 1,
      );
    });

    Widget buildTestWidget() {
      return MultiProvider(
        providers: [
          Provider<ApiService>.value(value: mockApiService),
          ChangeNotifierProvider<FontSizeProvider>.value(
            value: fontSizeProvider,
          ),
        ],
        child: MaterialApp(
          home: PersonalAccountDeleteScreen(
            userData: userData,
            isLoggedIn: true,
            onLogout: () {},
          ),
        ),
      );
    }

    testWidgets('shows delete button', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      // Find the ElevatedButton with the delete text
      final buttonFinder = find.widgetWithText(ElevatedButton, 'Benutzerkonto löschen');
      expect(buttonFinder, findsOneWidget);
    });

    testWidgets('shows confirmation dialog when delete button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      // Tap the ElevatedButton specifically, not just any text
      final buttonFinder = find.widgetWithText(ElevatedButton, 'Benutzerkonto löschen');
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // Check dialog content text (the actual text in the dialog)
      final dialogTexts = tester.widgetList<Text>(find.byType(Text));
      expect(
        dialogTexts.any(
          (t) =>
              t.data?.contains(
                'Sind Sie sicher, dass Sie Ihr Benutzerkonto unwiderruflich löschen möchten?',
              ) ??
              false,
        ),
        isTrue,
      );
      // Check dialog title
      final scaledTexts = tester.widgetList<ScaledText>(
        find.byType(ScaledText),
      );
      expect(scaledTexts.any((b) => b.text == 'Benutzerkonto löschen'), isTrue);
      // Check dialog buttons
      expect(scaledTexts.any((b) => b.text == 'Abbrechen'), isTrue);
      expect(scaledTexts.any((b) => b.text == 'Löschen'), isTrue);
    });

    testWidgets('font size is scaled in dialog', (WidgetTester tester) async {
      // Set a specific scale factor before opening the dialog
      fontSizeProvider.setScaleFactor(1.5);
      await tester.pumpWidget(buildTestWidget());
      // Tap the ElevatedButton specifically
      final buttonFinder = find.widgetWithText(ElevatedButton, 'Benutzerkonto löschen');
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();
      final dialogTexts = tester.widgetList<Text>(find.byType(Text));
      final dialogText = dialogTexts.firstWhere(
        (t) =>
            t.data?.contains(
              'Sind Sie sicher, dass Sie Ihr Benutzerkonto unwiderruflich löschen möchten?',
            ) ??
            false,
      );
      final fontSize = dialogText.style?.fontSize;
      // Verify the font size is scaled (16 * 1.5 = 24)
      expect(fontSize, equals(24.0));
    });
  });
}
