import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/ausweis_bestellen_success_screen.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';

void main() {
  late UserData userData;

  setUp(() {
    userData = const UserData(
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
    );
  });

  Widget buildTestWidget() {
    return ChangeNotifierProvider<FontSizeProvider>(
      create: (_) => FontSizeProvider(),
      child: MaterialApp(
        routes: {
          '/home': (context) => const Scaffold(body: Text('Home Screen')),
        },
        home: AusweisBestellendSuccessScreen(
          userData: userData,
          isLoggedIn: true,
          onLogout: () {},
        ),
      ),
    );
  }

  testWidgets('shows success icon and main message', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.text('Ihr Shützenausweis wurde bestellt!'), findsOneWidget);
    expect(find.text('Sie können nun zu Ihrem Profil zurückkehren.'),
        findsOneWidget,);
  });

  testWidgets('FAB navigates to home screen', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Home Screen'), findsOneWidget);
  });
}
