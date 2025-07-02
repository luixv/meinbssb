import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/screens/schulungen_screen.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/services/core/font_size_provider.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/cache_service.dart';
import 'package:meinbssb/models/schulungstermin.dart';
import 'package:meinbssb/models/bank_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';

// Simple mock classes
class MockApiService extends Mock implements ApiService {
  @override
  Future<List<Schulungstermin>> fetchSchulungstermine(String date) async {
    return [];
  }

  @override
  Future<List<BankData>> fetchBankData(int webLoginId) async {
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchKontakte(int personId) async {
    return [];
  }
}

class MockCacheService extends Mock implements CacheService {
  @override
  Future<String?> getString(String key) async {
    return 'test@example.com';
  }
}

void main() {
  const dummyUser = UserData(
    personId: 1,
    webLoginId: 1,
    passnummer: '12345',
    vereinNr: 1,
    namen: 'User',
    vorname: 'Test',
    vereinName: 'Test Verein',
    passdatenId: 1,
    mitgliedschaftId: 1,
  );

  group('SchulungenScreen', () {
    testWidgets('renders without crashing', (WidgetTester tester) async {
      // Set up SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<FontSizeProvider>(
                create: (_) => FontSizeProvider(),
              ),
              Provider<ApiService>(create: (_) => MockApiService()),
              Provider<CacheService>(create: (_) => MockCacheService()),
            ],
            child: SchulungenScreen(
              dummyUser,
              isLoggedIn: true,
              onLogout: () {},
              searchDate: DateTime.now(),
            ),
          ),
        ),
      );

      // Wait for the widget to settle and for FontSizeProvider to initialize
      await tester.pumpAndSettle();

      // Verify the screen renders
      expect(find.byType(SchulungenScreen), findsOneWidget);
    });

    testWidgets('FontSizeProvider works in isolation', (
      WidgetTester tester,
    ) async {
      // Set up SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<FontSizeProvider>(
            create: (_) => FontSizeProvider(),
            child: Consumer<FontSizeProvider>(
              builder: (context, fontSizeProvider, _) {
                return Text('Scale: ${fontSizeProvider.scaleFactor}');
              },
            ),
          ),
        ),
      );

      // Wait for the provider to initialize
      await tester.pumpAndSettle();

      // Verify the scale factor is displayed correctly
      expect(find.text('Scale: 1.0'), findsOneWidget);
    });
  });
}
