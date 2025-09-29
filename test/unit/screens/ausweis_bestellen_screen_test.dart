import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/screens/ausweis_bestellen_screen_accessible.dart';
import 'package:meinbssb/screens/ausweis_bestellen_success_screen_accessible.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/providers/font_size_provider.dart';

class FakeApiService implements ApiService {
  bool called = false;
  bool shouldSucceed = true;

  @override
  Future<bool> bssbAppPassantrag(
    Map<int, Map<String, int?>> secondColumns,
    int? passdatenId,
    int? personId,
    int? erstVereinId,
    int digitalerPass,
    int antragsTyp,
  ) async {
    called = true;
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
        home: AusweisBestellenScreenAccessible(
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

  testWidgets('calls apiService.bssbAppPassantrag and navigates on success',
      (WidgetTester tester) async {
    final apiService = FakeApiService();
    await tester.pumpWidget(buildTestWidget(apiService: apiService));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();
    expect(apiService.called, isTrue);
    // Success navigation: AusweisBestellendSuccessScreen should be pushed
    expect(
        find.byType(AusweisBestellendSuccessScreenAccessible), findsOneWidget,);
  });

  testWidgets('shows snackbar on failure', (WidgetTester tester) async {
    final apiService = FakeApiService()..shouldSucceed = false;
    await tester.pumpWidget(buildTestWidget(apiService: apiService));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Start async
    await tester.pump(const Duration(seconds: 1)); // Finish async
    expect(apiService.called, isTrue);
    expect(find.byType(SnackBar), findsOneWidget);
    // Check for the text within the SnackBar specifically to avoid confusion with error container
    expect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.text(
          'Antrag konnte nicht gesendet werden. Bitte versuchen Sie es erneut.',
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows error container on failure for accessibility',
      (WidgetTester tester) async {
    final apiService = FakeApiService()..shouldSucceed = false;
    await tester.pumpWidget(buildTestWidget(apiService: apiService));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump(); // Start async
    await tester.pump(const Duration(seconds: 1)); // Finish async
    expect(apiService.called, isTrue);
    // Check that error container is displayed for accessibility
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    // Check that there are exactly 2 instances of the error text (SnackBar + Container)
    expect(
      find.text(
        'Antrag konnte nicht gesendet werden. Bitte versuchen Sie es erneut.',
      ),
      findsNWidgets(2),
    );
  });
}
