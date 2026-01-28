import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnisantrag_step3_dialog_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/services/core/error_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'beduerfnisantrag_step3_dialog_screen_test.mocks.dart';

@GenerateMocks([ApiService, ErrorService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('BeduerfnissantragStep3Dialog', () {
    late MockApiService mockApiService;
    late FontSizeProvider fontSizeProvider;

    setUp(() {
      mockApiService = MockApiService();
      fontSizeProvider = FontSizeProvider();
    });

    Widget buildDialog({int? antragsnummer}) {
      return MultiProvider(
        providers: [
          Provider<ApiService>.value(value: mockApiService),
          ChangeNotifierProvider<FontSizeProvider>.value(
            value: fontSizeProvider,
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => Center(
                    child: BeduerfnisantragStep3Dialog(
                      antragsnummer: antragsnummer,
                      parentContext: context,
                    ),
                  ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders dialog with title and buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildDialog(antragsnummer: 123));
      expect(find.text('WBK-Dokument hochladen'), findsOneWidget);
      expect(find.text('Hochladen'), findsOneWidget);
      expect(find.text('Scannen'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('allows entering label text', (WidgetTester tester) async {
      await tester.pumpWidget(buildDialog(antragsnummer: 123));
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, 'Mein Dokument');
      expect(find.text('Mein Dokument'), findsOneWidget);
    });

    testWidgets('disables buttons while uploading', (
      WidgetTester tester,
    ) async {
      // Simulate uploading by tapping Hochladen with a label and mock uploadBedDateiForWBK to delay
      when(
        mockApiService.uploadBedDateiForWBK(
          antragsnummer: anyNamed('antragsnummer'),
          dateiname: anyNamed('dateiname'),
          fileBytes: anyNamed('fileBytes'),
          label: anyNamed('label'),
        ),
      ).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return true;
      });

      await tester.pumpWidget(buildDialog(antragsnummer: 123));
      await tester.enterText(find.byType(TextField), 'foo');
      await tester.tap(find.text('Hochladen'));
      await tester.pump();
      // Check that loading overlay is shown
      expect(find.text('Wird hochgeladen...'), findsOneWidget);
      // Check that buttons are disabled if still present
      final uploadButtonFinder = find.widgetWithText(
        ElevatedButton,
        'Hochladen',
      );
      final scanButtonFinder = find.widgetWithText(ElevatedButton, 'Scannen');
      if (uploadButtonFinder.evaluate().isNotEmpty) {
        final uploadButton = tester.widget<ElevatedButton>(uploadButtonFinder);
        expect(uploadButton.onPressed, isNull);
      }
      if (scanButtonFinder.evaluate().isNotEmpty) {
        final scanButton = tester.widget<ElevatedButton>(scanButtonFinder);
        expect(scanButton.onPressed, isNull);
      }
    });

    testWidgets('shows error message in error container', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildDialog(antragsnummer: 123));
      // Trigger error by tapping Hochladen with empty label
      await tester.tap(find.text('Hochladen'));
      await tester.pump();
      expect(
        find.textContaining('Beschreibung'),
        findsWidgets,
      ); // error message contains 'Beschreibung'
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      // Let the error timer complete to avoid pending timer error
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('shows loading overlay when uploading', (
      WidgetTester tester,
    ) async {
      when(
        mockApiService.uploadBedDateiForWBK(
          antragsnummer: anyNamed('antragsnummer'),
          dateiname: anyNamed('dateiname'),
          fileBytes: anyNamed('fileBytes'),
          label: anyNamed('label'),
        ),
      ).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return true;
      });

      await tester.pumpWidget(buildDialog(antragsnummer: 123));
      await tester.enterText(find.byType(TextField), 'foo');
      await tester.tap(find.text('Hochladen'));
      await tester.pump();
      expect(find.text('Wird hochgeladen...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error if label is empty on upload', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildDialog(antragsnummer: 123));
      await tester.tap(find.text('Hochladen'));
      await tester.pumpAndSettle();
      // Wait for the error timer to complete
      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('shows error if label is empty on scan', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildDialog(antragsnummer: 123));
      await tester.tap(find.text('Scannen'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('close button pops the dialog', (WidgetTester tester) async {
      await tester.pumpWidget(buildDialog(antragsnummer: 123));
      expect(find.byIcon(Icons.close), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      // The dialog should be popped, so the title should not be found
      expect(find.text('WBK-Dokument hochladen'), findsNothing);
    });
  });
}
