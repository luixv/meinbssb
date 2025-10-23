import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/passdaten_akzept_or_aktiv_data.dart';
import 'package:meinbssb/screens/ausweis_bestellen_screen.dart';
import 'package:meinbssb/screens/ausweis_bestellen_success_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/providers/font_size_provider.dart';

class FakeApiService implements ApiService {
  bool called = false;
  bool shouldSucceed = true;

  @override
  Future<PassdatenAkzeptOrAktiv?> fetchPassdatenAkzeptierterOderAktiverPass(
    int? personId,
  ) async {
    return null;
  }

  @override
  Future<bool> bssbAppPassantrag(
    List<Map<String, dynamic>> zves,
    int? passdatenId,
    int? personId,
    int? erstVereinId,
    int digitalerPass,
    int antragsTyp,
  ) async {
    called = true;
    // Optionally check zves for test logic
    return shouldSucceed;
  }

  // Add stubs for all other ApiService methods:
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Widget buildTestWidget({
    required ApiService apiService,
    UserData? userData,
    bool isLoggedIn = true,
    Function()? onLogout,
  }) {
    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider<FontSizeProvider>(
          create: (_) => FontSizeProvider(),
        ),
      ],
      child: MaterialApp(
        home: AusweisBestellenScreen(
          userData: userData,
          isLoggedIn: isLoggedIn,
          onLogout: onLogout ?? () {},
        ),
      ),
    );
  }

  testWidgets('renders button and description', (WidgetTester tester) async {
    final apiService = FakeApiService();
    await tester.pumpWidget(buildTestWidget(apiService: apiService));
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(
      find.text(
        'Möchten sie Ihren Schützenausweis kostenpflichtig bestellen? \nKlicken Sie auf den Button unten, um fortzufahren.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('calls apiService.bssbAppPassantrag and navigates on success', (
    WidgetTester tester,
  ) async {
    final apiService = FakeApiService();
    await tester.pumpWidget(buildTestWidget(apiService: apiService));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(apiService.called, isTrue);
    // Success navigation: AusweisBestellendSuccessScreen should be pushed
    expect(find.byType(AusweisBestellendSuccessScreen), findsOneWidget);
  });

  testWidgets('shows snackbar on failure', (WidgetTester tester) async {
    final apiService = FakeApiService()..shouldSucceed = false;
    await tester.pumpWidget(buildTestWidget(apiService: apiService));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Start async
    await tester.pump(const Duration(seconds: 1)); // Finish async
    expect(apiService.called, isTrue);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Antrag konnte nicht gesendet werden.'), findsOneWidget);
  });
}
