import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/zweitmitgliedschaften_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/services/core/cache_service.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/services/core/image_service.dart';

// More explicit fakes

class MockHttpClient implements HttpClient {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockCacheService implements CacheService {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockNetworkService implements NetworkService {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockImageService implements ImageService {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockConfigService implements ConfigService {
  @override
  String? getString(String key, [String? section]) {
    if (key == 'appColor') return '4278190080'; // ARGB for blue
    return null;
  }

  @override
  int? getInt(String key, [String? section]) {
    return null;
  }
}

class MockApiService extends Fake implements ApiService {
  MockApiService({
    required this.mockZweitmitgliedschaften,
    required this.mockPassdatenZVE,
    this.shouldThrowError = false,
  });

  final List<dynamic> mockZweitmitgliedschaften;
  final List<dynamic> mockPassdatenZVE;
  final bool shouldThrowError;

  @override
  Future<List<dynamic>> fetchZweitmitgliedschaften(int personId) async {
    if (shouldThrowError) throw Exception('API Error');
    return mockZweitmitgliedschaften;
  }

  @override
  Future<List<dynamic>> fetchPassdatenZVE(int passdatenId, int personId) async {
    if (shouldThrowError) throw Exception('API Error');
    return mockPassdatenZVE;
  }
}

void main() {
  const int testPersonId = 1;
  final testUserData = {
    'data': {
      'VORNAME': 'Max',
      'NAMEN': 'Mustermann',
      'PASSNUMMER': '123456',
      'VEREINNAME': 'Test Verein',
      'PASSDATENID': 1,
    },
  };

  const Widget dummyLogo = SizedBox();

  Widget makeTestableWidget({
    required ApiService apiService,
    ConfigService? configService,
  }) {
    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        Provider<ConfigService>.value(
          value: configService ?? MockConfigService(),
        ),
      ],
      child: MaterialApp(
        home: ZweitmitgliedschaftenScreen(
          personId: testPersonId,
          userData: testUserData,
          logoWidget: dummyLogo,
        ),
      ),
    );
  }

  group('ZweitmitgliedschaftenScreen', () {
    testWidgets('displays loading indicators initially', (tester) async {
      // Arrange
      final apiService = MockApiService(
        mockZweitmitgliedschaften: [],
        mockPassdatenZVE: [],
      );

      // Act
      await tester.pumpWidget(makeTestableWidget(apiService: apiService));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
    });

    testWidgets('displays error message when fetchZweitmitgliedschaften fails',
        (tester) async {
      // Arrange
      final apiService = MockApiService(
        mockZweitmitgliedschaften: [],
        mockPassdatenZVE: [],
        shouldThrowError: true,
      );

      // Act
      await tester.pumpWidget(makeTestableWidget(apiService: apiService));
      await tester.pumpAndSettle(); // Wait for the error state

      // Assert
      expect(find.textContaining('Fehler beim Laden'), findsNWidgets(2));
    });

    testWidgets(
        'displays "Keine Zweitmitgliedschaften gefunden." when the list is empty',
        (tester) async {
      // Arrange
      final apiService = MockApiService(
        mockZweitmitgliedschaften: [],
        mockPassdatenZVE: [],
      );

      // Act
      await tester.pumpWidget(makeTestableWidget(apiService: apiService));
      await tester.pumpAndSettle(); // Wait for data to load

      // Assert
      expect(
        find.text('Keine Zweitmitgliedschaften gefunden.'),
        findsOneWidget,
      );
    });

    testWidgets('displays a list of zweitmitgliedschaften', (tester) async {
      // Arrange
      final apiService = MockApiService(
        mockZweitmitgliedschaften: [
          {'VEREINID': 1, 'VEREINNAME': 'Verein Alpha'},
          {'VEREINID': 2, 'VEREINNAME': 'Verein Beta'},
        ],
        mockPassdatenZVE: [],
      );

      // Act
      await tester.pumpWidget(makeTestableWidget(apiService: apiService));
      await tester.pumpAndSettle(); // Wait for data to load

      // Assert
      expect(find.text('Verein Alpha'), findsOneWidget);
      expect(find.text('Verein Beta'), findsOneWidget);
    });
  });
}
