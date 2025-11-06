import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/models/bank_data.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/screens/bankdata/bank_data_screen.dart';
import 'package:meinbssb/screens/bankdata/bank_data_success_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';

// Test Data Factory
class TestDataFactory {
  static const validBankData = BankData(
    id: 1,
    webloginId: 13901,
    kontoinhaber: 'Max Mustermann',
    iban: 'DE89370400440532013000',
    bic: 'COBADEFFXXX',
    mandatSeq: 2,
  );

  static const testUserData = UserData(
    personId: 439287,
    webLoginId: 13901,
    passnummer: '40100709',
    vereinNr: 401051,
    namen: 'Schürz',
    vorname: 'Lukas',
    vereinName: 'Feuerschützen Kühbach',
    passdatenId: 2000009155,
    mitgliedschaftId: 439287,
    strasse: 'Aichacher Strasse 21',
    plz: '86574',
    ort: 'Alsmoos',
    telefon: '123456789',
  );

  static const germanIban = 'DE89370400440532013000';
  static const austrianIban = 'AT611904300234573201';
  static const validBic = 'COBADEFFXXX';
}

// Mock API Service
class MockApiService implements ApiService {
  // Configuration
  bool hasInternetValue = true;
  bool shouldThrowError = false;
  bool registerBankDataSuccess = true;
  bool deleteBankDataSuccess = true;

  // Data
  List<BankData> mockBankDataList = [];
  String? errorMessage;

  // Reset to defaults
  void reset() {
    hasInternetValue = true;
    shouldThrowError = false;
    registerBankDataSuccess = true;
    deleteBankDataSuccess = true;
    mockBankDataList.clear();
    errorMessage = null;
  }

  // Convenience methods for test setup
  void simulateNetworkError() {
    shouldThrowError = true;
    errorMessage = 'Network timeout';
  }

  void simulateOffline() {
    hasInternetValue = false;
  }

  void setExistingBankData() {
    mockBankDataList = [TestDataFactory.validBankData];
  }

  @override
  Future<bool> hasInternet() async => hasInternetValue;

  @override
  Future<List<BankData>> fetchBankdatenMyBSSB(int webloginId) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'API Error');
    }
    return mockBankDataList;
  }

  @override
  Future<bool> registerBankData(BankData bankData) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Register Error');
    }
    return registerBankDataSuccess;
  }

  @override
  Future<bool> deleteBankData(BankData bankData) async {
    if (shouldThrowError) {
      throw Exception(errorMessage ?? 'Delete Error');
    }
    return deleteBankDataSuccess;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

// Test Helper
class BankDataTestHelper {
  static Widget createBankDataScreen(
    MockApiService mockApiService, {
    UserData? userData,
    int? webloginId,
    bool isLoggedIn = true,
    VoidCallback? onLogout,
  }) {
    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: mockApiService),
        ChangeNotifierProvider<FontSizeProvider>(
          create: (_) => FontSizeProvider(),
        ),
      ],
      child: MaterialApp(
        home: BankDataScreen(
          userData ?? TestDataFactory.testUserData,
          webloginId: webloginId ?? TestDataFactory.testUserData.webLoginId,
          isLoggedIn: isLoggedIn,
          onLogout: onLogout ?? () {},
        ),
      ),
    );
  }

  static Future<void> enterEditMode(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
  }

  static Future<void> fillFormData(
    WidgetTester tester, {
    String kontoinhaber = 'Test User',
    String iban = TestDataFactory.germanIban,
    String bic = TestDataFactory.validBic,
  }) async {
    await tester.enterText(find.byType(TextFormField).at(0), kontoinhaber);
    await tester.enterText(find.byType(TextFormField).at(1), iban);
    await tester.enterText(find.byType(TextFormField).at(2), bic);
    await tester.pumpAndSettle();
  }

  static Future<void> saveForm(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();
  }

  static Future<void> cancelEdit(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
  }

  static Future<void> deleteData(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Löschen'));
    await tester.pumpAndSettle();
  }

  static void expectErrorState(String message) {
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(find.text('Fehler beim Laden der Bankdaten'), findsOneWidget);
    expect(find.text(message), findsOneWidget);
  }

  static void expectReadOnlyMode() {
    expect(find.byIcon(Icons.edit), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    expect(find.byIcon(Icons.save), findsNothing);
    expect(find.byIcon(Icons.close), findsNothing);
  }

  static void expectEditMode() {
    expect(find.byIcon(Icons.save), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.edit), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  }

  static void expectValidationError(String message) {
    expect(find.text(message), findsOneWidget);
  }

  static void expectSuccessNavigation() {
    expect(find.byType(BankDataSuccessScreen), findsOneWidget);
  }
}

// Test Suite
void main() {
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    mockApiService.reset();
  });

  group('BankDataScreen - Initial State', () {
    testWidgets('shows loading then content', (tester) async {
      await tester.pumpWidget(
        BankDataTestHelper.createBankDataScreen(mockApiService),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Bankdaten'), findsOneWidget);
    });

    testWidgets('displays existing bank data', (tester) async {
      mockApiService.setExistingBankData();

      await tester.pumpWidget(
        BankDataTestHelper.createBankDataScreen(mockApiService),
      );
      await tester.pumpAndSettle();

      expect(find.text('Max Mustermann'), findsOneWidget);
      expect(find.text('DE89370400440532013000'), findsOneWidget);
      expect(find.text('COBADEFFXXX'), findsOneWidget);
    });
  });

  group('BankDataScreen - Mode Transitions', () {
    testWidgets('switches to edit mode correctly', (tester) async {
      await tester.pumpWidget(
        BankDataTestHelper.createBankDataScreen(mockApiService),
      );
      await tester.pumpAndSettle();

      await BankDataTestHelper.enterEditMode(tester);
      BankDataTestHelper.expectEditMode();
    });

    testWidgets('cancel resets form and exits edit mode', (tester) async {
      mockApiService.setExistingBankData();

      await tester.pumpWidget(
        BankDataTestHelper.createBankDataScreen(mockApiService),
      );
      await tester.pumpAndSettle();

      await BankDataTestHelper.enterEditMode(tester);
      await tester.enterText(find.byType(TextFormField).first, 'Modified');
      await tester.pumpAndSettle();

      await BankDataTestHelper.cancelEdit(tester);

      BankDataTestHelper.expectReadOnlyMode();
      expect(find.text('Max Mustermann'), findsOneWidget);
      expect(find.text('Modified'), findsNothing);
    });
  });

  group('BankDataScreen - Form Validation', () {
    setUp(() async {
      // Common setup for form validation tests
    });

    testWidgets('validates required fields', (tester) async {
      await tester.pumpWidget(
        BankDataTestHelper.createBankDataScreen(mockApiService),
      );
      await tester.pumpAndSettle();

      await BankDataTestHelper.enterEditMode(tester);
      await BankDataTestHelper.saveForm(tester);

      BankDataTestHelper.expectValidationError('Kontoinhaber ist erforderlich');
      BankDataTestHelper.expectValidationError('IBAN ist erforderlich');
    });

    testWidgets('validates IBAN format', (tester) async {
      await tester.pumpWidget(
        BankDataTestHelper.createBankDataScreen(mockApiService),
      );
      await tester.pumpAndSettle();

      await BankDataTestHelper.enterEditMode(tester);
      await BankDataTestHelper.fillFormData(tester, iban: 'INVALID_IBAN');
      await BankDataTestHelper.saveForm(tester);

      BankDataTestHelper.expectValidationError('Ungültige IBAN');
    });

    testWidgets('BIC optional for German IBAN', (tester) async {
      await tester.pumpWidget(
        BankDataTestHelper.createBankDataScreen(mockApiService),
      );
      await tester.pumpAndSettle();

      await BankDataTestHelper.enterEditMode(tester);
      await BankDataTestHelper.fillFormData(
        tester,
        iban: TestDataFactory.germanIban,
        bic: '',
      );
      await BankDataTestHelper.saveForm(tester);

      expect(find.text('Bitte geben Sie die BIC ein'), findsNothing);
    });

    testWidgets('BIC required for non-German IBAN', (tester) async {
      await tester.pumpWidget(
        BankDataTestHelper.createBankDataScreen(mockApiService),
      );
      await tester.pumpAndSettle();

      await BankDataTestHelper.enterEditMode(tester);
      await BankDataTestHelper.fillFormData(
        tester,
        iban: TestDataFactory.austrianIban,
        bic: '',
      );
      await BankDataTestHelper.saveForm(tester);

      BankDataTestHelper.expectValidationError('Bitte geben Sie die BIC ein');
    });

    testWidgets('fields behavior in different modes', (tester) async {
      await tester.pumpWidget(
        BankDataTestHelper.createBankDataScreen(mockApiService),
      );
      await tester.pumpAndSettle();

      // Test read-only mode
      await tester.enterText(
        find.byType(TextFormField).first,
        'Should not work',
      );
      await tester.pumpAndSettle();
      expect(find.text('Should not work'), findsNothing);

      // Test edit mode
      await BankDataTestHelper.enterEditMode(tester);
      await tester.enterText(find.byType(TextFormField).first, 'Should work');
      await tester.pumpAndSettle();
      expect(find.text('Should work'), findsOneWidget);
    });
  });

  group('BankDataScreen - Save Operations', () {
    testWidgets('successful save navigates to success screen', (tester) async {
      await tester.pumpWidget(
        BankDataTestHelper.createBankDataScreen(mockApiService),
      );
      await tester.pumpAndSettle();

      await BankDataTestHelper.enterEditMode(tester);
      await BankDataTestHelper.fillFormData(tester);
      await BankDataTestHelper.saveForm(tester);

      BankDataTestHelper.expectSuccessNavigation();
    });

    testWidgets('handles save failure', (tester) async {
      mockApiService.registerBankDataSuccess = false;

      await tester.pumpWidget(
        BankDataTestHelper.createBankDataScreen(mockApiService),
      );
      await tester.pumpAndSettle();

      await BankDataTestHelper.enterEditMode(tester);
      await BankDataTestHelper.fillFormData(tester);
      await BankDataTestHelper.saveForm(tester);

      expect(find.text('Fehler beim Speichern der Bankdaten.'), findsOneWidget);
    });

    testWidgets('prevents save when offline', (tester) async {
      mockApiService.simulateOffline();

      await tester.pumpWidget(
        BankDataTestHelper.createBankDataScreen(mockApiService),
      );
      await tester.pumpAndSettle();

      await BankDataTestHelper.enterEditMode(tester);
      await BankDataTestHelper.fillFormData(tester);
      await BankDataTestHelper.saveForm(tester);

      expect(
        find.text('Bankdaten können offline nicht gespeichert werden'),
        findsOneWidget,
      );
    });
  });

  group('BankDataScreen - Delete Operations', () {
    testWidgets('cancel works correctly', (tester) async {
      await tester.pumpWidget(
        BankDataTestHelper.createBankDataScreen(mockApiService),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();

      expect(find.text('Bankdaten löschen'), findsNothing);
      BankDataTestHelper.expectReadOnlyMode();
    });

    testWidgets('successful delete navigates to success screen', (
      tester,
    ) async {
      await tester.pumpWidget(
        BankDataTestHelper.createBankDataScreen(mockApiService),
      );
      await tester.pumpAndSettle();

      await BankDataTestHelper.deleteData(tester);
      BankDataTestHelper.expectSuccessNavigation();
    });

    testWidgets('handles delete failure', (tester) async {
      mockApiService.deleteBankDataSuccess = false;

      await tester.pumpWidget(
        BankDataTestHelper.createBankDataScreen(mockApiService),
      );
      await tester.pumpAndSettle();

      await BankDataTestHelper.deleteData(tester);

      expect(find.text('Fehler beim Löschen der Bankdaten.'), findsOneWidget);
    });

    testWidgets('prevents delete when offline', (tester) async {
      mockApiService.simulateOffline();

      await tester.pumpWidget(
        BankDataTestHelper.createBankDataScreen(mockApiService),
      );
      await tester.pumpAndSettle();

      await BankDataTestHelper.deleteData(tester);

      expect(
        find.text('Bankdaten können offline nicht gelöscht werden'),
        findsOneWidget,
      );
    });
  });

  group('BankDataScreen - Edge Cases & Lifecycle', () {
    testWidgets('handles null user data', (tester) async {
      await tester.pumpWidget(
        BankDataTestHelper.createBankDataScreen(mockApiService, userData: null),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bankdaten'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles empty bank data list', (tester) async {
      await tester.pumpWidget(
        BankDataTestHelper.createBankDataScreen(mockApiService),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(3));

      final textFields = tester.widgetList<TextFormField>(
        find.byType(TextFormField),
      );
      for (final field in textFields) {
        expect(field.controller?.text, isEmpty);
      }
    });

    testWidgets('disposes properly', (tester) async {
      await tester.pumpWidget(
        BankDataTestHelper.createBankDataScreen(mockApiService),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(Container());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('BankDataScreen - UI & Accessibility', () {
    testWidgets('renders efficiently', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        BankDataTestHelper.createBankDataScreen(mockApiService),
      );
      await tester.pumpAndSettle();

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles rapid state changes', (tester) async {
      await tester.pumpWidget(
        BankDataTestHelper.createBankDataScreen(mockApiService),
      );
      await tester.pumpAndSettle();

      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.edit));
        await tester.pump();
        await tester.tap(find.byIcon(Icons.close));
        await tester.pump();
      }

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('font scaling integration works', (tester) async {
      await tester.pumpWidget(
        BankDataTestHelper.createBankDataScreen(mockApiService),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(BankDataScreen));
      final fontProvider = Provider.of<FontSizeProvider>(
        context,
        listen: false,
      );

      expect(fontProvider, isNotNull);
      expect(tester.takeException(), isNull);
    });
  });
}
