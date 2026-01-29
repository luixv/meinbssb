import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/models/bank_data.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/schulungstermin_data.dart';
import 'package:meinbssb/screens/schulungen/dialogs/booking_data_dialog.dart';
import 'package:meinbssb/screens/schulungen/dialogs/register_another_dialog.dart';


import 'booking_data_dialog_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BookingDataDialog', () {
    late MockApiService mockApiService;
    late FontSizeProvider fontSizeProvider;

    // captured callback values
    BankData? capturedBankData;
    UserData? capturedPrefillUser;
    String? capturedPrefillEmail;
    List<RegisteredPersonUi>? capturedRegisteredPersons;
    int submitCount = 0;

    setUp(() {
      mockApiService = MockApiService();
      fontSizeProvider = FontSizeProvider();

      capturedBankData = null;
      capturedPrefillUser = null;
      capturedPrefillEmail = null;
      capturedRegisteredPersons = null;
      submitCount = 0;

      when(mockApiService.validateIBAN(any)).thenReturn(true);
      when(mockApiService.validateBIC(any)).thenReturn(null);
      when(
        mockApiService.getCachedUsername(),
      ).thenAnswer((_) async => 'test@example.com');
    });

    UserData buildUser() => UserData(
      personId: 1,
      webLoginId: 99,
      passnummer: '12345',
      vereinNr: 100,
      namen: 'Mustermann',
      vorname: 'Max',
      titel: 'Herr',
      geburtsdatum: DateTime(1990, 1, 1),
      geschlecht: 1,
      vereinName: 'Schützenverein',
      passdatenId: 10,
      mitgliedschaftId: 20,
      strasse: 'Hauptstr. 1',
      plz: '12345',
      ort: 'Musterstadt',
      land: 'DE',
      nationalitaet: 'DE',
      passStatus: 1,
      eintrittVerein: DateTime(2010, 1, 1),
      austrittVerein: null,
      telefon: '01234',
      erstLandesverbandId: 0,
      produktionsDatum: null,
      erstVereinId: 0,
      digitalerPass: 0,
      isOnline: false,
      disziplin: 'Luftgewehr',
      email: 'max@example.com',
      role: 'mitglied',
    );

    Schulungstermin buildTermin() => Schulungstermin(
      schulungsterminId: 1,
      schulungsartId: 1,
      schulungsTeilnehmerId: 1,
      datum: DateTime(2024, 1, 1),
      bemerkung: '',
      kosten: 0,
      ort: 'München',
      lehrgangsleiter: 'Test',
      verpflegungskosten: 0,
      uebernachtungskosten: 0,
      lehrmaterialkosten: 0,
      lehrgangsinhalt: '',
      maxTeilnehmer: 10,
      webVeroeffentlichenAm: '',
      anmeldungenGesperrt: false,
      status: 1,
      datumBis: '',
      lehrgangsinhaltHtml: '',
      lehrgangsleiter2: '',
      lehrgangsleiter3: '',
      lehrgangsleiter4: '',
      lehrgangsleiterTel: '',
      lehrgangsleiter2Tel: '',
      lehrgangsleiter3Tel: '',
      lehrgangsleiter4Tel: '',
      lehrgangsleiterMail: '',
      lehrgangsleiter2Mail: '',
      lehrgangsleiter3Mail: '',
      lehrgangsleiter4Mail: '',
      anmeldeStopp: '',
      abmeldeStopp: '',
      geloescht: false,
      stornoGrund: '',
      webGruppe: 1,
      veranstaltungsBezirk: 1,
      fuerVerlaengerungen: false,
      fuerVuelVerlaengerungen: false,
      anmeldeErlaubt: 1,
      verbandsInternPasswort: '',
      bezeichnung: 'Sachkunde',
      angemeldeteTeilnehmer: 0,
    );

    Widget host() {
      final user = buildUser();
      final termin = buildTermin();

      return MultiProvider(
        providers: [
          Provider<ApiService>.value(value: mockApiService),
          ChangeNotifierProvider.value(value: fontSizeProvider),
        ],
        child: MaterialApp(
          home: Builder(
            builder:
                (context) => ElevatedButton(
                  onPressed: () {
                    BookingDataDialog.show(
                      context,
                      schulungsTermin: termin,
                      user: user,
                      registeredPersons: const [],
                      phoneNumber: '01234',
                      bankData: null,
                      onSubmit: ({
                        required BankData safeBankData,
                        required UserData prefillUser,
                        required String prefillEmail,
                        required List<RegisteredPersonUi> registeredPersons,
                      }) async {
                        submitCount++;
                        capturedBankData = safeBankData;
                        capturedPrefillUser = prefillUser;
                        capturedPrefillEmail = prefillEmail;
                        capturedRegisteredPersons = registeredPersons;
                      },
                    );
                  },
                  child: const Text('OPEN'),
                ),
          ),
        ),
      );
    }

    testWidgets('submits valid booking data', (tester) async {
      await tester.pumpWidget(host());
      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Kontoinhaber'),
        'Max Mustermann',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'IBAN'),
        'DE89370400440532013000',
      );

      final checkboxes = find.byType(Checkbox);
      await tester.tap(checkboxes.at(0));
      await tester.tap(checkboxes.at(1));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Buchen'));
      await tester.pumpAndSettle();

      expect(submitCount, 1);
      expect(capturedBankData!.kontoinhaber, 'Max Mustermann');
      expect(capturedBankData!.iban, 'DE89370400440532013000');
      expect(capturedPrefillEmail, 'test@example.com');
      expect(capturedPrefillUser!.telefon, '01234');
      expect(capturedRegisteredPersons, isEmpty);
    });
  });
}
