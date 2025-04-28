import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/screens/zweitmitgliedschaften_screen.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/config_service.dart';
import 'package:meinbssb/services/http_client.dart';
import 'package:meinbssb/services/cache_service.dart';
import 'package:meinbssb/services/network_service.dart';
import 'package:meinbssb/services/image_service.dart';

// Minimal fakes for required dependencies
class FakeHttpClient implements HttpClient {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCacheService implements CacheService {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeNetworkService implements NetworkService {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeImageService implements ImageService {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class Dummy {}

class FakeApiService extends ApiService {
  FakeApiService({
    required this.zweitmitgliedschaften,
    required this.passdatenZVE,
    this.throwError = false,
  }) : super(
          httpClient: FakeHttpClient(),
          cacheService: FakeCacheService(),
          networkService: FakeNetworkService(),
          imageService: FakeImageService(),
          baseIp: '',
          port: '',
          serverTimeout: 0,
        );

  final List<dynamic> zweitmitgliedschaften;
  final List<dynamic> passdatenZVE;
  final bool throwError;

  @override
  Future<List<dynamic>> fetchZweitmitgliedschaften(int personId) async {
    if (throwError) throw Exception('error');
    return zweitmitgliedschaften;
  }

  @override
  Future<List<dynamic>> fetchPassdatenZVE(int passdatenId, int personId) async {
    if (throwError) throw Exception('error');
    return passdatenZVE;
  }
}

class FakeConfigService implements ConfigService {
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

void main() {
  final userData = {
    'VORNAME': 'Max',
    'NAMEN': 'Mustermann',
    'PASSNUMMER': '123456',
    'VEREINNAME': 'Test Verein',
    'PASSDATENID': 1,
  };

  Widget makeTestable({
    required ApiService apiService,
    ConfigService? configService,
  }) {
    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        Provider<ConfigService>.value(value: configService ?? FakeConfigService()),
      ],
      child: MaterialApp(
        home: ZweitmitgliedschaftenScreen(
          personId: 1,
          userData: userData,
          logoWidget: const SizedBox(), // avoid loading real logo
        ),
      ),
    );
  }

  testWidgets('shows loading indicator', (tester) async {
    final apiService = FakeApiService(
      zweitmitgliedschaften: [],
      passdatenZVE: [],
    );
    await tester.pumpWidget(makeTestable(apiService: apiService));
    expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
  });

  testWidgets('shows error widget on error', (tester) async {
    final apiService = FakeApiService(
      zweitmitgliedschaften: [],
      passdatenZVE: [],
      throwError: true,
    );
    await tester.pumpWidget(makeTestable(apiService: apiService));
    await tester.pumpAndSettle();
    expect(find.textContaining('Fehler'), findsNWidgets(2));
  });

  testWidgets('shows empty state when no zweitmitgliedschaften', (tester) async {
    final apiService = FakeApiService(
      zweitmitgliedschaften: [],
      passdatenZVE: [],
    );
    await tester.pumpWidget(makeTestable(apiService: apiService));
    await tester.pumpAndSettle();
    expect(find.text('Keine Zweitmitgliedschaften gefunden.'), findsOneWidget);
  });

  testWidgets('shows list of zweitmitgliedschaften', (tester) async {
    final apiService = FakeApiService(
      zweitmitgliedschaften: [
        {'VEREINID': 1, 'VEREINNAME': 'Verein A'},
        {'VEREINID': 2, 'VEREINNAME': 'Verein B'},
      ],
      passdatenZVE: [],
    );
    await tester.pumpWidget(makeTestable(apiService: apiService));
    await tester.pumpAndSettle();
    expect(find.text('Verein A'), findsOneWidget);
    expect(find.text('Verein B'), findsOneWidget);
  });
}
