import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/services/api/bezirk_service.dart';
import 'package:meinbssb/models/bezirk.dart';
import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/services/core/cache_service.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'bezirk_service_test.mocks.dart';

@GenerateMocks([HttpClient, CacheService, NetworkService])
void main() {
  late MockHttpClient mockHttpClient;
  late MockCacheService mockCacheService;
  late MockNetworkService mockNetworkService;
  late BezirkService bezirkService;

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockCacheService = MockCacheService();
    mockNetworkService = MockNetworkService();
    bezirkService = BezirkService(
      httpClient: mockHttpClient,
      cacheService: mockCacheService,
      networkService: mockNetworkService,
    );
    when(mockNetworkService.getCacheExpirationDuration())
        .thenReturn(const Duration(hours: 24));
    when(mockCacheService.cacheAndRetrieveData<List<Map<String, dynamic>>>(
      any,
      any,
      any,
      any,
    ),).thenAnswer((invocation) async {
      final fetchData = invocation.positionalArguments[2]
          as Future<List<Map<String, dynamic>>> Function();
      return await fetchData();
    });
  });

  group('BezirkService.fetchBezirke', () {
    test('returns list of Bezirke on success', () async {
      final response = [
        {'BEZIRKID': 1, 'BEZIRKNR': 100, 'BEZIRKNAME': 'TestBezirk'},
        {'BEZIRKID': 2, 'BEZIRKNR': 200, 'BEZIRKNAME': 'TestBezirk2'},
      ];
      when(mockHttpClient.get('Bezirke'))
          .thenAnswer((_) => Future.value(response));
      final result = await bezirkService.fetchBezirke();
      expect(result, isA<List<Bezirk>>());
      expect(result.length, 2);
      expect(result[0].bezirkId, 1);
      expect(result[1].bezirkName, 'TestBezirk2');
    });

    test('returns empty list and logs error on exception', () async {
      when(mockHttpClient.get('Bezirke'))
          .thenAnswer((_) => Future.error(Exception('fail')));
      final result = await bezirkService.fetchBezirke();
      expect(result, isEmpty);
    });

    test('returns empty list on malformed data', () async {
      when(mockHttpClient.get('Bezirke'))
          .thenAnswer((_) => Future.value({'unexpected': 'object'}));
      final result = await bezirkService.fetchBezirke();
      expect(result, isEmpty);
    });
  });

  group('BezirkService.fetchBezirk', () {
    test('returns list of Bezirke for a given bezirkNr', () async {
      final response = [
        {'BEZIRKID': 3, 'BEZIRKNR': 300, 'BEZIRKNAME': 'Bezirk300'},
      ];
      when(mockHttpClient.get('Bezirk/300'))
          .thenAnswer((_) => Future.value(response));
      final result = await bezirkService.fetchBezirk(300);
      expect(result, isA<List<Bezirk>>());
      expect(result.length, 1);
      expect(result[0].bezirkNr, 300);
    });

    test('returns empty list and logs error on exception', () async {
      when(mockHttpClient.get('Bezirk/123'))
          .thenAnswer((_) => Future.error(Exception('fail')));
      final result = await bezirkService.fetchBezirk(123);
      expect(result, isEmpty);
    });

    test('returns empty list on malformed data', () async {
      when(mockHttpClient.get('Bezirk/123'))
          .thenAnswer((_) => Future.value({'unexpected': 'object'}));
      final result = await bezirkService.fetchBezirk(123);
      expect(result, isEmpty);
    });
  });

  group('BezirkService.fetchBezirkeforSearch', () {
    test('returns list of BezirkSearchTriple on success', () async {
      final response = [
        {'BEZIRKID': 1, 'BEZIRKNR': 100, 'BEZIRKNAME': 'TestBezirk'},
        {'BEZIRKID': 2, 'BEZIRKNR': 200, 'BEZIRKNAME': 'TestBezirk2'},
      ];
      when(mockHttpClient.get('Bezirke'))
          .thenAnswer((_) => Future.value(response));
      final result = await bezirkService.fetchBezirkeforSearch();
      expect(result, isA<List<BezirkSearchTriple>>());
      expect(result.length, 2);
      expect(result[0].bezirkId, 1);
      expect(result[1].bezirkName, 'TestBezirk2');
    });

    test('returns empty list and logs error on exception', () async {
      when(mockHttpClient.get('Bezirke'))
          .thenAnswer((_) => Future.error(Exception('fail')));
      final result = await bezirkService.fetchBezirkeforSearch();
      expect(result, isEmpty);
    });

    test('returns empty list on malformed data', () async {
      when(mockHttpClient.get('Bezirke'))
          .thenAnswer((_) => Future.value({'unexpected': 'object'}));
      final result = await bezirkService.fetchBezirkeforSearch();
      expect(result, isEmpty);
    });
  });
}
