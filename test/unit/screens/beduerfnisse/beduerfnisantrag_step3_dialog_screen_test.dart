import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnisantrag_step3_dialog_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';

import 'package:meinbssb/services/core/error_service.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockApiService extends Mock implements ApiService {}

class MockErrorService extends Mock implements ErrorService {}

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

    Widget buildDialog({int? antragsnummer, BuildContext? parentContext}) {
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
