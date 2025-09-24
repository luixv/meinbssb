import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/settings_screen.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/constants/messages.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late FontSizeProvider fontSizeProvider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    fontSizeProvider = FontSizeProvider();
  });

  Widget buildTestWidget() {
    return ChangeNotifierProvider<FontSizeProvider>.value(
      value: fontSizeProvider,
      child: MaterialApp(
        home: SettingsScreen(
          userData: const UserData(
            personId: 1,
            webLoginId: 1,
            passnummer: '123456',
            vereinNr: 1,
            namen: 'Mustermann',
            vorname: 'Max',
            titel: null,
            geburtsdatum: null,
            geschlecht: null,
            vereinName: 'Testverein',
            strasse: null,
            plz: null,
            ort: null,
            land: '',
            nationalitaet: '',
            passStatus: 0,
            passdatenId: 1,
            eintrittVerein: null,
            austrittVerein: null,
            mitgliedschaftId: 1,
            telefon: '',
            erstLandesverbandId: 0,
            produktionsDatum: null,
            erstVereinId: 0,
            digitalerPass: 0,
            isOnline: false,
            disziplin: null,
          ),
          isLoggedIn: true,
          onLogout: () {},
        ),
      ),
    );
  }

  testWidgets('renders font size controls and description', (tester) async {
    await tester.pumpWidget(buildTestWidget());

    expect(find.text('Textgröße'), findsOneWidget);
    expect(find.byIcon(Icons.remove), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.textContaining('%'), findsOneWidget);
    expect(find.textContaining(Messages.fontSizeDescription), findsOneWidget);
  });

  testWidgets('decrease font size button decreases scaleFactor', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget());
    final initial = fontSizeProvider.scaleFactor;

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pumpAndSettle();

    expect(fontSizeProvider.scaleFactor, lessThan(initial));
  });

  testWidgets('increase font size button increases scaleFactor', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget());
    final initial = fontSizeProvider.scaleFactor;

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(fontSizeProvider.scaleFactor, greaterThan(initial));
  });

  testWidgets('reset font size button resets scaleFactor', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    fontSizeProvider.increaseFontSize();
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();

    expect(fontSizeProvider.scaleFactor, equals(1.0));
  });
}
