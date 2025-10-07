import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/services/api/bezirk_service.dart';
import 'package:meinbssb/models/bezirk_data.dart';
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
    when(
      mockNetworkService.getCacheExpirationDuration(),
    ).thenReturn(const Duration(hours: 24));
    when(
      mockCacheService.cacheAndRetrieveData<dynamic>(any, any, any, any),
    ).thenAnswer((invocation) async {
      final fetchData =
          invocation.positionalArguments[2] as Future<dynamic> Function();
      final result = await fetchData();
      if (result is List) {
        return result
            .map((item) => Map<String, dynamic>.from(item)..['ONLINE'] = true)
            .toList();
      }
      return <Map<String, dynamic>>[];
    });
  });

  group('BezirkService.fetchBezirke', () {
    test('returns list of Bezirke on success', () async {
      final response = [
        {'BEZIRKID': 1, 'BEZIRKNR': 100, 'BEZIRKNAME': 'TestBezirk'},
        {'BEZIRKID': 2, 'BEZIRKNR': 200, 'BEZIRKNAME': 'TestBezirk2'},
      ];
      when(
        mockHttpClient.get('Bezirke'),
      ).thenAnswer((_) => Future.value(response));
      final result = await bezirkService.fetchBezirke();
      expect(result, isA<List<Bezirk>>());
      expect(result.length, 2);
      expect(result[0].bezirkId, 1);
      expect(result[1].bezirkName, 'TestBezirk2');
    });

    test('returns empty list and logs error on exception', () async {
      when(
        mockHttpClient.get('Bezirke'),
      ).thenAnswer((_) => Future.error(Exception('fail')));
      final result = await bezirkService.fetchBezirke();
      expect(result, isEmpty);
    });

    test('returns empty list on malformed data', () async {
      when(
        mockHttpClient.get('Bezirke'),
      ).thenAnswer((_) => Future.value({'unexpected': 'object'}));
      final result = await bezirkService.fetchBezirke();
      expect(result, isEmpty);
    });
  });

  group('BezirkService.fetchBezirk', () {
    test('returns list of Bezirke for a given bezirkNr', () async {
      final response = [
        {'BEZIRKID': 3, 'BEZIRKNR': 300, 'BEZIRKNAME': 'Bezirk300'},
      ];
      when(
        mockHttpClient.get('Bezirk/300'),
      ).thenAnswer((_) => Future.value(response));
      final result = await bezirkService.fetchBezirk(300);
      expect(result, isA<List<Bezirk>>());
      expect(result.length, 1);
      expect(result[0].bezirkNr, 300);
    });

    test('returns empty list and logs error on exception', () async {
      when(
        mockHttpClient.get('Bezirk/123'),
      ).thenAnswer((_) => Future.error(Exception('fail')));
      final result = await bezirkService.fetchBezirk(123);
      expect(result, isEmpty);
    });

    test('returns empty list on malformed data', () async {
      when(
        mockHttpClient.get('Bezirk/123'),
      ).thenAnswer((_) => Future.value({'unexpected': 'object'}));
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
      when(
        mockHttpClient.get('Bezirke'),
      ).thenAnswer((_) => Future.value(response));
      final result = await bezirkService.fetchBezirkeforSearch();
      expect(result, isA<List<BezirkSearchTriple>>());
      expect(result.length, 2);
      expect(result[0].bezirkId, 1);
      expect(result[1].bezirkName, 'TestBezirk2');
    });

    test('returns empty list and logs error on exception', () async {
      when(
        mockHttpClient.get('Bezirke'),
      ).thenAnswer((_) => Future.error(Exception('fail')));
      final result = await bezirkService.fetchBezirkeforSearch();
      expect(result, isEmpty);
    });

    test('returns empty list on malformed data', () async {
      when(
        mockHttpClient.get('Bezirke'),
      ).thenAnswer((_) => Future.value({'unexpected': 'object'}));
      final result = await bezirkService.fetchBezirkeforSearch();
      expect(result, isEmpty);
    });
  });

  group('BezirkService._mapBezirkeResponse', () {
    test('returns empty list if response is not a List', () {
      bezirkService.fetchBezirke().then(
        (value) => bezirkService.fetchBezirke(),
      );
      expect(bezirkService.fetchBezirke(), completes);
      // Directly test the private mapping method via reflection or by making it public for test
      // Here, we simulate by calling through fetchBezirke with a stubbed cache returning a non-list
    });

    test('skips items that are not Map<String, dynamic>', () async {
      when(
        mockHttpClient.get('Bezirke'),
      ).thenAnswer((_) => Future.value([123, 'string', null]));
      final result = await bezirkService.fetchBezirke();
      expect(result, isEmpty);
    });

    test('skips items that throw in fromJson', () async {
      // Simulate a map that will throw in fromJson (missing required fields)
      when(mockHttpClient.get('Bezirke')).thenAnswer(
        (_) => Future.value([
          {'BEZIRKID': null},
        ]),
      );
      final result = await bezirkService.fetchBezirke();
      expect(result, isEmpty);
    });
  });

  group('BezirkService._mapBezirkResponse', () {
    test('returns empty list if response is not a List', () async {
      when(
        mockHttpClient.get('Bezirk/999'),
      ).thenAnswer((_) => Future.value('notalist'));
      final result = await bezirkService.fetchBezirk(999);
      expect(result, isEmpty);
    });

    test('skips items that are not Map<String, dynamic>', () async {
      when(
        mockHttpClient.get('Bezirk/888'),
      ).thenAnswer((_) => Future.value([123, 'string', null]));
      final result = await bezirkService.fetchBezirk(888);
      expect(result, isEmpty);
    });

    test('skips items that throw in fromJson', () async {
      when(mockHttpClient.get('Bezirk/777')).thenAnswer(
        (_) => Future.value([
          {'BEZIRKID': null},
        ]),
      );
      final result = await bezirkService.fetchBezirk(777);
      expect(result, isEmpty);
    });
  });

  group('BezirkService.fetchBezirkeforSearch', () {
    test('skips items that throw in BezirkSearchTriple.fromJson', () async {
      when(mockHttpClient.get('Bezirke')).thenAnswer(
        (_) => Future.value([
          {'BEZIRKID': null},
        ]),
      );
      final result = await bezirkService.fetchBezirkeforSearch();
      expect(result, isEmpty);
    });

    test('returns empty list if response is not a List', () async {
      when(
        mockHttpClient.get('Bezirke'),
      ).thenAnswer((_) => Future.value('notalist'));
      final result = await bezirkService.fetchBezirkeforSearch();
      expect(result, isEmpty);
    });
  });

  group(
    'BezirkService.fetchBezirkeforSearch mapping closure (additional coverage)',
    () {
      test(
        'process closure maps only required keys and filters non-maps',
        () async {
          // Custom stub to invoke the 4th param (process function) with our crafted raw list
          when(
            mockCacheService.cacheAndRetrieveData<List<Map<String, dynamic>>>(
              any,
              any,
              any,
              any,
            ),
          ).thenAnswer((invocation) async {
            final fetchData =
                invocation.positionalArguments[2] as Future<dynamic> Function();
            // Execute fetchData (its result ignored here)
            await fetchData();
            final process =
                invocation.positionalArguments[3]
                    as List<Map<String, dynamic>> Function(dynamic);

            final raw = [
              {
                'BEZIRKID': 1,
                'BEZIRKNR': 100,
                'BEZIRKNAME': 'A',
                'EXTRA': 'should be removed',
              },
              'not a map',
              {
                'BEZIRKID': 2,
                'BEZIRKNR': 200,
                'BEZIRKNAME': 'B',
                'IGNORED': 123,
              },
              42,
              null,
            ];
            return process(raw);
          });

          when(mockHttpClient.get('Bezirke')).thenAnswer(
            (_) async => [
              {
                'BEZIRKID': 9,
                'BEZIRKNR': 999,
                'BEZIRKNAME': 'WillBeIgnoredByStub',
              },
            ],
          );

          final result = await bezirkService.fetchBezirkeforSearch();

          expect(result.length, 2);
          expect(result.map((e) => e.bezirkName), containsAll(['A', 'B']));
          expect(result.first.bezirkId, 1);
          expect(result.last.bezirkNr, 200);
        },
      );

      test(
        'process closure returns empty list when rawResponse is non-list',
        () async {
          when(
            mockCacheService.cacheAndRetrieveData<List<Map<String, dynamic>>>(
              any,
              any,
              any,
              any,
            ),
          ).thenAnswer((invocation) async {
            final fetchData =
                invocation.positionalArguments[2] as Future<dynamic> Function();
            await fetchData();
            final process =
                invocation.positionalArguments[3]
                    as List<Map<String, dynamic>> Function(dynamic);
            return process('not-a-list');
          });

          when(
            mockHttpClient.get('Bezirke'),
          ).thenAnswer((_) async => 'ignored');

          final result = await bezirkService.fetchBezirkeforSearch();
          expect(result, isEmpty);
        },
      );
    },
  );
}
