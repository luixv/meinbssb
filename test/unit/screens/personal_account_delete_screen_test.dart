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
      expect(find.text('Benutzerkonto löschen'), findsOneWidget);
    });

    testWidgets('shows confirmation dialog when delete button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Benutzerkonto löschen'));
      await tester.pumpAndSettle();

      final dialogTexts = tester.widgetList<Text>(find.byType(Text));
      expect(
        dialogTexts.any(
          (t) =>
              t.data?.contains(
                'Möchten Sie Ihr Benutzerkonto unwiderruflich löschen?',
              ) ??
              false,
        ),
        isTrue,
      );
      // Check buttons
      final scaledTexts = tester.widgetList<ScaledText>(
        find.byType(ScaledText),
      );
      expect(scaledTexts.any((b) => b.text == 'Benutzerkonto löschen'), isTrue);
    });

    testWidgets('font size changes in dialog', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Benutzerkonto löschen'));
      await tester.pumpAndSettle();
      final dialogTexts = tester.widgetList<Text>(find.byType(Text));
      final dialogText = dialogTexts.firstWhere(
        (t) =>
            t.data?.contains(
              'Möchten Sie Ihr Benutzerkonto unwiderruflich löschen?',
            ) ??
            false,
      );
      final initialFontSize = dialogText.style?.fontSize;
      fontSizeProvider.setScaleFactor(1.5);
      await tester.pumpAndSettle();
      final updatedDialogTexts = tester.widgetList<Text>(find.byType(Text));
      final updatedDialogText = updatedDialogTexts.firstWhere(
        (t) =>
            t.data?.contains(
              'Möchten Sie Ihr Benutzerkonto unwiderruflich löschen?',
            ) ??
            false,
      );
      final updatedFontSize = updatedDialogText.style?.fontSize;
      expect(updatedFontSize, greaterThan(initialFontSize ?? 0));
    });
  });
}
