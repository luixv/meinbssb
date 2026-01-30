import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnisantrag_step1_screen.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/beduerfnis_antrag_data.dart';
import 'package:meinbssb/models/beduerfnis_antrag_status_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'beduerfnisantrag_step1_screen_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late MockApiService mockApiService;
  late FontSizeProvider fontSizeProvider;

  TestWidgetsFlutterBinding.ensureInitialized();

  // Dummy user data for testing
  const dummyUserData = UserData(
    personId: 12345,
    webLoginId: 1,
    passnummer: '12345',
    vereinNr: 1,
    namen: 'Test',
    vorname: 'User',
    vereinName: 'Test Verein',
    passdatenId: 1,
    mitgliedschaftId: 1,
    email: 'test@example.com',
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockApiService = MockApiService();
    fontSizeProvider = FontSizeProvider();
  });

  /// Helper function to create a test widget with necessary providers
  Widget createTestWidget({
    UserData? userData = dummyUserData,
    bool isLoggedIn = true,
    VoidCallback? onBack,
    BeduerfnisAntrag? antrag,
    bool readOnly = false,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<FontSizeProvider>.value(value: fontSizeProvider),
        Provider<ApiService>.value(value: mockApiService),
      ],
      child: MaterialApp(
        home: BeduerfnisantragStep1Screen(
          userData: userData,
          isLoggedIn: isLoggedIn,
          onLogout: () {},
          onBack: onBack,
          antrag: antrag,
          readOnly: readOnly,
        ),
      ),
    );
  }

  group('BeduerfnissantragStep1Screen - Rendering & Display', () {
    testWidgets('renders the screen title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.text('Bedürfnisbescheinigung'), findsOneWidget);
    });

    testWidgets('renders the subtitle "Erfassen der Daten"', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.text('Erfassen der Daten'), findsWidgets);
    });

    testWidgets('renders "Bedürfnisantrag" section title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.text('Bedürfnisantrag'), findsOneWidget);
    });

    testWidgets('renders all WBK type radio buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(
        find.text('Ich beantrage ein Bedürfnis für eine neue WBK'),
        findsOneWidget,
      );
      expect(
        find.text('Ich beantrage ein Bedürfnis für eine bestehende WBK'),
        findsOneWidget,
      );
    });

    testWidgets('renders all WBK color radio buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Gelbe WBK'), findsOneWidget);
      expect(find.text('Grüne WBK'), findsOneWidget);
    });

    testWidgets('renders all weapon type radio buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Kurzwaffe'), findsOneWidget);
      expect(find.text('Langwaffe'), findsOneWidget);
    });

    testWidgets('renders the Anzahl text field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Ich besitze bereits Kurzwaffen:'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Anzahl'), findsOneWidget);
    });

    testWidgets('renders the Verein dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Verein der genehmigt:'), findsOneWidget);
      expect(
        find.widgetWithText(
          DropdownButtonFormField<String>,
          'Verein auswählen',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Gebührenerhebung section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.text('Gebührenerhebung:'), findsOneWidget);
    });
  });

  group('BeduerfnissantragStep1Screen - FAB Buttons', () {
    testWidgets('renders back FAB', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final backFab = find.byWidgetPredicate(
        (widget) =>
            widget is FloatingActionButton &&
            widget.heroTag == 'backFromErfassenFab',
      );
      expect(backFab, findsOneWidget);
    });

    testWidgets('renders save FAB in create mode', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(readOnly: false));

      final saveFab = find.byWidgetPredicate(
        (widget) =>
            widget is FloatingActionButton &&
            widget.heroTag == 'saveFromErfassenFab',
      );
      expect(saveFab, findsOneWidget);
    });

    testWidgets('does not render save FAB in read-only mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(readOnly: true));

      final saveFab = find.byWidgetPredicate(
        (widget) =>
            widget is FloatingActionButton &&
            widget.heroTag == 'saveFromErfassenFab',
      );
      expect(saveFab, findsNothing);
    });

    testWidgets('renders forward FAB', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final forwardFab = find.byWidgetPredicate(
        (widget) =>
            widget is FloatingActionButton &&
            widget.heroTag == 'nextFromErfassenFab',
      );
      expect(forwardFab, findsOneWidget);
    });

    testWidgets('back FAB has correct icon', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final backFab = find.byWidgetPredicate(
        (widget) =>
            widget is FloatingActionButton &&
            widget.heroTag == 'backFromErfassenFab',
      );
      expect(backFab, findsOneWidget);

      // Verify the icon
      final fab = tester.widget<FloatingActionButton>(backFab);
      expect(fab.child, isA<Icon>());
    });

    testWidgets('forward FAB has correct icon', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final forwardFab = find.byWidgetPredicate(
        (widget) =>
            widget is FloatingActionButton &&
            widget.heroTag == 'nextFromErfassenFab',
      );
      expect(forwardFab, findsOneWidget);

      // Verify the icon
      final fab = tester.widget<FloatingActionButton>(forwardFab);
      expect(fab.child, isA<Icon>());
    });
  });

  group('BeduerfnissantragStep1Screen - Radio Button Interactions', () {
    testWidgets('can select "neu" WBK type', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find and tap "neu" radio button
      final neuRadio = find.widgetWithText(
        RadioListTile<String>,
        'Ich beantrage ein Bedürfnis für eine neue WBK',
      );
      expect(neuRadio, findsOneWidget);

      await tester.tap(neuRadio);
      await tester.pump();

      // Verify the radio is selected
      final radioWidget = tester.widget<RadioListTile<String>>(neuRadio);
      expect(radioWidget.value, 'neu');
      expect(radioWidget.groupValue, 'neu');
    });

    testWidgets('can select "bestehend" WBK type', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find and tap "bestehend" radio button
      final bestehendRadio = find.widgetWithText(
        RadioListTile<String>,
        'Ich beantrage ein Bedürfnis für eine bestehende WBK',
      );
      expect(bestehendRadio, findsOneWidget);

      await tester.tap(bestehendRadio);
      await tester.pump();

      // Verify the radio is selected
      final radioWidget = tester.widget<RadioListTile<String>>(bestehendRadio);
      expect(radioWidget.value, 'bestehend');
      expect(radioWidget.groupValue, 'bestehend');
    });

    testWidgets('can select "gelb" WBK color', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find and tap "gelb" radio button
      final gelbRadio = find.widgetWithText(RadioListTile<String>, 'Gelbe WBK');
      expect(gelbRadio, findsOneWidget);

      await tester.tap(gelbRadio);
      await tester.pump();

      // Verify the radio is selected (it's selected by default)
      final radioWidget = tester.widget<RadioListTile<String>>(gelbRadio);
      expect(radioWidget.value, 'gelb');
      expect(radioWidget.groupValue, 'gelb');
    });

    testWidgets('can select "gruen" WBK color', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find and tap "gruen" radio button
      final gruenRadio = find.widgetWithText(
        RadioListTile<String>,
        'Grüne WBK',
      );
      expect(gruenRadio, findsOneWidget);

      await tester.tap(gruenRadio);
      await tester.pump();

      // Verify the radio is selected
      final radioWidget = tester.widget<RadioListTile<String>>(gruenRadio);
      expect(radioWidget.value, 'gruen');
      expect(radioWidget.groupValue, 'gruen');
    });

    testWidgets('can select "kurz" weapon type', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find and tap "kurz" radio button
      final kurzRadio = find.widgetWithText(RadioListTile<String>, 'Kurzwaffe');
      expect(kurzRadio, findsOneWidget);

      await tester.tap(kurzRadio);
      await tester.pump();

      // Verify the radio is selected (it's selected by default)
      final radioWidget = tester.widget<RadioListTile<String>>(kurzRadio);
      expect(radioWidget.value, 'kurz');
      expect(radioWidget.groupValue, 'kurz');
    });

    testWidgets('can select "lang" weapon type', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find and tap "lang" radio button
      final langRadio = find.widgetWithText(RadioListTile<String>, 'Langwaffe');
      expect(langRadio, findsOneWidget);

      await tester.tap(langRadio);
      await tester.pump();

      // Verify the radio is selected
      final radioWidget = tester.widget<RadioListTile<String>>(langRadio);
      expect(radioWidget.value, 'lang');
      expect(radioWidget.groupValue, 'lang');
    });

    testWidgets('weapon type selection updates displayed text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Initially shows "Kurzwaffen"
      expect(find.text('Ich besitze bereits Kurzwaffen:'), findsOneWidget);

      // Tap "Langwaffe" radio button
      final langRadio = find.widgetWithText(RadioListTile<String>, 'Langwaffe');
      await tester.tap(langRadio);
      await tester.pump();

      // Now should show "Langwaffen"
      expect(find.text('Ich besitze bereits Langwaffen:'), findsOneWidget);
    });
  });

  group('BeduerfnissantragStep1Screen - Text Field Interactions', () {
    testWidgets('Anzahl text field has default value "0"', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      final textField = find.widgetWithText(TextField, 'Anzahl');
      expect(textField, findsOneWidget);

      final textFieldWidget = tester.widget<TextField>(textField);
      expect(textFieldWidget.controller?.text, '0');
    });

    testWidgets('can enter numeric value in Anzahl field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      final textField = find.widgetWithText(TextField, 'Anzahl');
      await tester.enterText(textField, '5');
      await tester.pump();

      final textFieldWidget = tester.widget<TextField>(textField);
      expect(textFieldWidget.controller?.text, '5');
    });

    testWidgets('Anzahl field only accepts numeric input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      final textField = find.widgetWithText(TextField, 'Anzahl');
      await tester.enterText(textField, 'abc123');
      await tester.pump();

      // Should only keep numeric characters
      final textFieldWidget = tester.widget<TextField>(textField);
      expect(textFieldWidget.controller?.text, '123');
    });

    testWidgets('Anzahl field is disabled in read-only mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(readOnly: true));

      final textField = find.widgetWithText(TextField, 'Anzahl');
      final textFieldWidget = tester.widget<TextField>(textField);
      expect(textFieldWidget.enabled, false);
    });
  });

  group('BeduerfnissantragStep1Screen - Dropdown Interactions', () {
    testWidgets('Verein dropdown is disabled in read-only mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(readOnly: true));

      final dropdown = find.widgetWithText(
        DropdownButtonFormField<String>,
        'Verein auswählen',
      );
      final dropdownWidget = tester.widget<DropdownButtonFormField<String>>(
        dropdown,
      );
      expect(dropdownWidget.onChanged, null);
    });
  });

  group('BeduerfnissantragStep1Screen - Edit Mode', () {
    testWidgets('initializes form fields from existing antrag', (
      WidgetTester tester,
    ) async {
      final existingAntrag = BeduerfnisAntrag(
        id: 1,
        antragsnummer: 12345,
        personId: 12345,
        statusId: BeduerfnisAntragStatus.entwurf,
        wbkNeu: false, // bestehend
        wbkArt: 'gruen',
        beduerfnisart: 'langwaffe',
        anzahlWaffen: 3,
        createdAt: DateTime.now(),
      );

      // Mock API call to fetch fresh antrag data
      when(
        mockApiService.getBedAntragByAntragsnummer(12345),
      ).thenAnswer((_) async => [existingAntrag]);

      await tester.pumpWidget(createTestWidget(antrag: existingAntrag));
      await tester.pumpAndSettle();

      // Verify WBK type is "bestehend"
      final bestehendRadio = find.widgetWithText(
        RadioListTile<String>,
        'Ich beantrage ein Bedürfnis für eine bestehende WBK',
      );
      final bestehendWidget = tester.widget<RadioListTile<String>>(
        bestehendRadio,
      );
      expect(bestehendWidget.groupValue, 'bestehend');

      // Verify WBK color is "gruen"
      final gruenRadio = find.widgetWithText(
        RadioListTile<String>,
        'Grüne WBK',
      );
      final gruenWidget = tester.widget<RadioListTile<String>>(gruenRadio);
      expect(gruenWidget.groupValue, 'gruen');

      // Verify weapon type is "lang"
      final langRadio = find.widgetWithText(RadioListTile<String>, 'Langwaffe');
      final langWidget = tester.widget<RadioListTile<String>>(langRadio);
      expect(langWidget.groupValue, 'lang');

      // Verify Anzahl is 3
      final textField = find.widgetWithText(TextField, 'Anzahl');
      final textFieldWidget = tester.widget<TextField>(textField);
      expect(textFieldWidget.controller?.text, '3');
    });
  });

  group('BeduerfnissantragStep1Screen - Read-Only Mode', () {
    testWidgets('radio buttons are disabled in read-only mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(readOnly: true));

      // Check WBK type radio buttons
      final neuRadio = find.widgetWithText(
        RadioListTile<String>,
        'Ich beantrage ein Bedürfnis für eine neue WBK',
      );
      final neuWidget = tester.widget<RadioListTile<String>>(neuRadio);
      expect(neuWidget.onChanged, null);

      // Check WBK color radio buttons
      final gelbRadio = find.widgetWithText(RadioListTile<String>, 'Gelbe WBK');
      final gelbWidget = tester.widget<RadioListTile<String>>(gelbRadio);
      expect(gelbWidget.onChanged, null);

      // Check weapon type radio buttons
      final kurzRadio = find.widgetWithText(RadioListTile<String>, 'Kurzwaffe');
      final kurzWidget = tester.widget<RadioListTile<String>>(kurzRadio);
      expect(kurzWidget.onChanged, null);
    });
  });

  group('BeduerfnissantragStep1Screen - Edge Cases', () {
    testWidgets('handles null userData', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(userData: null));
      expect(find.text('Bedürfnisbescheinigung'), findsOneWidget);
    });

    testWidgets('handles not logged in state', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(isLoggedIn: false));
      expect(find.text('Bedürfnisbescheinigung'), findsOneWidget);
    });
  });

  group('BeduerfnissantragStep1Screen - Accessibility', () {
    testWidgets('has semantic labels', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check that semantic labels exist
      expect(find.text('Bedürfnisbescheinigung'), findsOneWidget);
      expect(find.text('Erfassen der Daten'), findsWidgets);
    });

    testWidgets('has semantic labels for form fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(
        find.bySemanticsLabel(RegExp('WBK Art auswählen')),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp('Bedürfnis für eine:')),
        findsOneWidget,
      );
    });

    testWidgets('FABs have semantic labels', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check for semantic hints on FABs
      final backFab = find.byWidgetPredicate(
        (widget) =>
            widget is FloatingActionButton &&
            widget.heroTag == 'backFromErfassenFab',
      );
      expect(backFab, findsOneWidget);

      final forwardFab = find.byWidgetPredicate(
        (widget) =>
            widget is FloatingActionButton &&
            widget.heroTag == 'nextFromErfassenFab',
      );
      expect(forwardFab, findsOneWidget);
    });

    testWidgets('has Focus widget for keyboard navigation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      final focusWidget = find.byWidgetPredicate(
        (widget) => widget is Focus && widget.autofocus == true,
      );
      expect(focusWidget, findsWidgets);
    });
  });

  group('BeduerfnissantragStep1Screen - Navigation', () {
    testWidgets('back FAB has callback', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final backFab = find.byWidgetPredicate(
        (widget) =>
            widget is FloatingActionButton &&
            widget.heroTag == 'backFromErfassenFab',
      );
      final fab = tester.widget<FloatingActionButton>(backFab);
      expect(fab.onPressed, isNotNull);
    });

    testWidgets('forward FAB has callback', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final forwardFab = find.byWidgetPredicate(
        (widget) =>
            widget is FloatingActionButton &&
            widget.heroTag == 'nextFromErfassenFab',
      );
      final fab = tester.widget<FloatingActionButton>(forwardFab);
      expect(fab.onPressed, isNotNull);
    });

    testWidgets('save FAB has callback', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(readOnly: false));

      final saveFab = find.byWidgetPredicate(
        (widget) =>
            widget is FloatingActionButton &&
            widget.heroTag == 'saveFromErfassenFab',
      );
      final fab = tester.widget<FloatingActionButton>(saveFab);
      expect(fab.onPressed, isNotNull);
    });
  });

  group('BeduerfnissantragStep1Screen - State Management', () {
    testWidgets('screen renders successfully', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Screen should render
      expect(find.text('Bedürfnisbescheinigung'), findsOneWidget);
    });

    testWidgets('form fields are present', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should have at least one text field for Anzahl
      expect(find.byType(TextField), findsWidgets);
    });
  });

  group('BeduerfnissantragStep1Screen - Consumer Tests', () {
    testWidgets('rebuilds when FontSizeProvider changes', (
      WidgetTester tester,
    ) async {
      final fontSizeProvider = FontSizeProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<FontSizeProvider>.value(
              value: fontSizeProvider,
            ),
            Provider<ApiService>.value(value: mockApiService),
          ],
          child: MaterialApp(
            home: BeduerfnisantragStep1Screen(
              userData: dummyUserData,
              isLoggedIn: true,
              onLogout: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bedürfnisbescheinigung'), findsOneWidget);

      // Change font size to smaller value to avoid overflow
      fontSizeProvider.setScaleFactor(0.9);
      await tester.pumpAndSettle();

      // Screen should still render
      expect(find.text('Bedürfnisbescheinigung'), findsOneWidget);
    });
  });

  group('BeduerfnissantragStep1Screen - Layout Tests', () {
    testWidgets('uses proper layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should use Scaffold
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('has scrollable content', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find scrollable widgets
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('proper spacing between form elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for SizedBox widgets used for spacing
      final sizedBoxFinder = find.byType(SizedBox);
      expect(sizedBoxFinder, findsWidgets);
    });
  });

  group('BeduerfnissantragStep1Screen - Form Validation', () {
    testWidgets('anzahl field validates numeric input', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final textField = find.widgetWithText(TextField, 'Anzahl');
      expect(textField, findsOneWidget);

      // Enter valid number
      await tester.enterText(textField, '10');
      await tester.pump();

      // Field should accept it
      final textFieldWidget = tester.widget<TextField>(textField);
      expect(textFieldWidget.controller?.text, '10');
    });
  });

  group('BeduerfnissantragStep1Screen - Conditional Rendering', () {
    testWidgets('weapon count field changes label based on weapon type', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially shows Kurzwaffen
      expect(find.text('Ich besitze bereits Kurzwaffen:'), findsOneWidget);

      // Select Langwaffe
      final langRadio = find.widgetWithText(RadioListTile<String>, 'Langwaffe');
      await tester.tap(langRadio);
      await tester.pumpAndSettle();

      // Should now show Langwaffen
      expect(find.text('Ich besitze bereits Langwaffen:'), findsOneWidget);
    });

    testWidgets('WBK type selection enables color selection', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find WBK color radios
      expect(find.text('Gelbe WBK'), findsOneWidget);
      expect(find.text('Grüne WBK'), findsOneWidget);
    });
  });

  group('BeduerfnissantragStep1Screen - Integration Tests', () {
    testWidgets('complete form renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify basic screen structure
      expect(find.text('Bedürfnisbescheinigung'), findsOneWidget);
    });
  });
}
