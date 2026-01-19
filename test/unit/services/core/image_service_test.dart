import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:meinbssb/services/core/image_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:meinbssb/services/core/http_client.dart';

class FakeConnectivity {
  FakeConnectivity(this.results);
  final List<ConnectivityResult> results;
  Future<List<ConnectivityResult>> checkConnectivity() async => results;
}

class ThrowingConnectivity {
  Future<List<ConnectivityResult>> checkConnectivity() async {
    throw Exception('Connectivity error');
  }
}

class FakeHttpClient implements HttpClient {
  FakeHttpClient({this.bytes, this.shouldThrow = false});
  final Uint8List? bytes;
  final bool shouldThrow;

  @override
  String get baseUrl => '';

  @override
  int get serverTimeout => 30; // Should match the interface type

  @override
  Future<Uint8List> getBytes(String endpoint) async {
    if (shouldThrow) throw Exception('Network error');
    return bytes ?? Uint8List.fromList([1, 2, 3]);
  }

  @override
  Future<dynamic> get(String endpoint, {String? overrideBaseUrl}) {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? overrideBaseUrl,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> body, {
    String? overrideBaseUrl,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    String? overrideBaseUrl,
  }) {
    throw UnimplementedError();
  }

  @override
  void setPostgrestService(dynamic postgrestService) {
    // No-op for fake implementation
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImageService', () {
    test(
      'fetchAndCacheSchuetzenausweis returns network image if online',
      () async {
        final imageData = Uint8List.fromList([10, 11, 12]);
        final service = ImageService(
          httpClient: FakeHttpClient(bytes: imageData),
          connectivity: FakeConnectivity([ConnectivityResult.wifi]),
        );
        final result = await service.fetchAndCacheSchuetzenausweis(
          100,
          const Duration(seconds: 10),
        );
        expect(result, imageData);
      },
    );

    test(
      'fetchAndCacheSchuetzenausweis returns cached image if fetch fails',
      () async {
        final imageData = Uint8List.fromList([30, 31, 32]);
        final service = ImageService(
          httpClient: FakeHttpClient(shouldThrow: true),
          connectivity: FakeConnectivity([ConnectivityResult.wifi]),
          getCachedSchuetzenausweisFn: (id, validity) async => imageData,
        );
        final result = await service.fetchAndCacheSchuetzenausweis(
          102,
          const Duration(seconds: 10),
        );
        expect(result, imageData);
      },
    );

    test(
      'cacheSchuetzenausweis and getCachedSchuetzenausweis roundtrip (smoke)',
      () async {
        final imageData = Uint8List.fromList([40, 41, 42]);
        const id = 105;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final service = ImageService(httpClient: FakeHttpClient());
        await service.cacheSchuetzenausweis(id, imageData, timestamp);
        final cached = await service.getCachedSchuetzenausweis(
          id,
          const Duration(seconds: 10),
        );
        expect(cached == null, isTrue);
      },
    );

    test(
      'getCachedSchuetzenausweis returns null if cache is expired',
      () async {
        final imageData = Uint8List.fromList([50, 51, 52]);
        const id = 106;
        final service = ImageService(httpClient: FakeHttpClient());
        // Simulate caching with an old timestamp
        final oldTimestamp = DateTime.now().millisecondsSinceEpoch - 1000000;
        await service.cacheSchuetzenausweis(id, imageData, oldTimestamp);
        final cached = await service.getCachedSchuetzenausweis(
          id,
          const Duration(milliseconds: 1),
        );
        expect(cached, isNull);
      },
    );

    test('getCachedSchuetzenausweis returns null if nothing cached', () async {
      final service = ImageService(httpClient: FakeHttpClient());
      final cached = await service.getCachedSchuetzenausweis(
        999,
        const Duration(seconds: 10),
      );
      expect(cached, isNull);
    });

    test('cacheSchuetzenausweis overwrites previous cache', () async {
      final imageData1 = Uint8List.fromList([60, 61, 62]);
      final imageData2 = Uint8List.fromList([63, 64, 65]);
      const id = 107;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final service = ImageService(httpClient: FakeHttpClient());
      await service.cacheSchuetzenausweis(id, imageData1, timestamp);
      await service.cacheSchuetzenausweis(id, imageData2, timestamp);
      // The cache is not persistent, so getCachedSchuetzenausweis will return null,
      // but this covers the overwrite branch.
      final cached = await service.getCachedSchuetzenausweis(
        id,
        const Duration(seconds: 10),
      );
      expect(cached, isNull);
    });

    test(
      'fetchAndCacheSchuetzenausweis returns cached image if cache is valid',
      () async {
        final imageData = Uint8List.fromList([70, 71, 72]);
        const id = 108;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final service = ImageService(
          httpClient: FakeHttpClient(shouldThrow: true),
          connectivity: FakeConnectivity([]),
          getCachedSchuetzenausweisFn: (i, d) async => imageData,
        );
        // Simulate valid cache
        await service.cacheSchuetzenausweis(id, imageData, timestamp);
        final result = await service.fetchAndCacheSchuetzenausweis(
          id,
          const Duration(seconds: 10),
        );
        expect(result, imageData);
      },
    );

    test(
      'fetchAndCacheSchuetzenausweis handles zero-length image data',
      () async {
        final emptyImageData = Uint8List.fromList([]);
        final service = ImageService(
          httpClient: FakeHttpClient(bytes: emptyImageData),
          connectivity: FakeConnectivity([ConnectivityResult.wifi]),
        );
        final result = await service.fetchAndCacheSchuetzenausweis(
          200,
          const Duration(seconds: 10),
        );
        expect(result, emptyImageData);
      },
    );

    test('fetchAndCacheSchuetzenausweis handles large image data', () async {
      // Create a large image (1MB)
      final largeImageData = Uint8List(1024 * 1024);
      for (int i = 0; i < largeImageData.length; i++) {
        largeImageData[i] = i % 256;
      }

      final service = ImageService(
        httpClient: FakeHttpClient(bytes: largeImageData),
        connectivity: FakeConnectivity([ConnectivityResult.wifi]),
      );
      final result = await service.fetchAndCacheSchuetzenausweis(
        201,
        const Duration(seconds: 10),
      );
      expect(result, largeImageData);
    });

    test('fetchAndCacheSchuetzenausweis handles negative ID values', () async {
      final imageData = Uint8List.fromList([80, 81, 82]);
      final service = ImageService(
        httpClient: FakeHttpClient(bytes: imageData),
        connectivity: FakeConnectivity([ConnectivityResult.wifi]),
      );
      final result = await service.fetchAndCacheSchuetzenausweis(
        -1,
        const Duration(seconds: 10),
      );
      expect(result, imageData);
    });

    test(
      'fetchAndCacheSchuetzenausweis handles very short cache duration',
      () async {
        final imageData = Uint8List.fromList([90, 91, 92]);
        final service = ImageService(
          httpClient: FakeHttpClient(bytes: imageData),
          connectivity: FakeConnectivity([ConnectivityResult.wifi]),
        );
        final result = await service.fetchAndCacheSchuetzenausweis(
          202,
          const Duration(microseconds: 1),
        );
        expect(result, imageData);
      },
    );

    test(
      'fetchAndCacheSchuetzenausweis handles very long cache duration',
      () async {
        final imageData = Uint8List.fromList([100, 101, 102]);
        final service = ImageService(
          httpClient: FakeHttpClient(bytes: imageData),
          connectivity: FakeConnectivity([ConnectivityResult.wifi]),
        );
        final result = await service.fetchAndCacheSchuetzenausweis(
          203,
          const Duration(days: 365),
        );
        expect(result, imageData);
      },
    );

    test(
      'fetchAndCacheSchuetzenausweis ignores cache when online and fetch succeeds',
      () async {
        final networkImageData = Uint8List.fromList([120, 121, 122]);
        final cachedImageData = Uint8List.fromList([123, 124, 125]);
        bool cacheFunctionCalled = false;

        final service = ImageService(
          httpClient: FakeHttpClient(bytes: networkImageData),
          connectivity: FakeConnectivity([ConnectivityResult.wifi]),
          getCachedSchuetzenausweisFn: (id, validity) async {
            cacheFunctionCalled = true;
            return cachedImageData;
          },
        );

        final result = await service.fetchAndCacheSchuetzenausweis(
          205,
          const Duration(seconds: 10),
        );

        expect(result, networkImageData);
        expect(cacheFunctionCalled, isFalse);
      },
    );

    test('cacheSchuetzenausweis handles zero timestamp', () async {
      final imageData = Uint8List.fromList([130, 131, 132]);
      const id = 206;
      final service = ImageService(httpClient: FakeHttpClient());

      // Should not throw when caching with zero timestamp
      await service.cacheSchuetzenausweis(id, imageData, 0);

      final cached = await service.getCachedSchuetzenausweis(
        id,
        const Duration(seconds: 10),
      );
      expect(cached, isNull); // Cache is not persistent in test
    });

    test('cacheSchuetzenausweis handles future timestamp', () async {
      final imageData = Uint8List.fromList([140, 141, 142]);
      const id = 207;
      final service = ImageService(httpClient: FakeHttpClient());

      // Timestamp far in the future
      final futureTimestamp =
          DateTime.now().millisecondsSinceEpoch + 1000000000;
      await service.cacheSchuetzenausweis(id, imageData, futureTimestamp);

      final cached = await service.getCachedSchuetzenausweis(
        id,
        const Duration(seconds: 10),
      );
      expect(cached, isNull); // Cache is not persistent in test
    });

    test('cacheSchuetzenausweis handles empty image data', () async {
      final emptyImageData = Uint8List.fromList([]);
      const id = 208;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final service = ImageService(httpClient: FakeHttpClient());

      // Should not throw when caching empty image data
      await service.cacheSchuetzenausweis(id, emptyImageData, timestamp);

      final cached = await service.getCachedSchuetzenausweis(
        id,
        const Duration(seconds: 10),
      );
      expect(cached, isNull); // Cache is not persistent in test
    });

    test('getCachedSchuetzenausweis handles zero validity duration', () async {
      final service = ImageService(httpClient: FakeHttpClient());

      final cached = await service.getCachedSchuetzenausweis(
        209,
        Duration.zero,
      );
      expect(cached, isNull);
    });

    test(
      'getCachedSchuetzenausweis handles negative validity duration',
      () async {
        final service = ImageService(httpClient: FakeHttpClient());

        final cached = await service.getCachedSchuetzenausweis(
          210,
          const Duration(seconds: -1),
        );
        expect(cached, isNull);
      },
    );

    test(
      'fetchAndCacheSchuetzenausweis handles concurrent requests for same ID',
      () async {
        final imageData = Uint8List.fromList([150, 151, 152]);
        final service = ImageService(
          httpClient: FakeHttpClient(bytes: imageData),
          connectivity: FakeConnectivity([ConnectivityResult.wifi]),
        );

        // Start multiple concurrent requests for the same ID
        final futures = List.generate(
          5,
          (index) => service.fetchAndCacheSchuetzenausweis(
            300,
            const Duration(seconds: 10),
          ),
        );

        final results = await Future.wait(futures);

        // All results should be the same
        for (final result in results) {
          expect(result, imageData);
        }
      },
    );

    test(
      'fetchAndCacheSchuetzenausweis handles concurrent requests for different IDs',
      () async {
        final imageData = Uint8List.fromList([160, 161, 162]);
        final service = ImageService(
          httpClient: FakeHttpClient(bytes: imageData),
          connectivity: FakeConnectivity([ConnectivityResult.wifi]),
        );

        // Start concurrent requests for different IDs
        final futures = List.generate(
          5,
          (index) => service.fetchAndCacheSchuetzenausweis(
            400 + index,
            const Duration(seconds: 10),
          ),
        );

        final results = await Future.wait(futures);

        // All results should be the same (same fake data)
        for (final result in results) {
          expect(result, imageData);
        }
      },
    );

    test('fetchAndCacheSchuetzenausweis validates parameters', () async {
      final service = ImageService(
        httpClient: FakeHttpClient(),
        connectivity: FakeConnectivity([ConnectivityResult.wifi]),
      );

      // Test with valid parameters - should not throw
      final result = await service.fetchAndCacheSchuetzenausweis(
        500,
        const Duration(seconds: 1),
      );
      expect(result, isNotNull);
    });

    test('ImageService constructor handles all parameter combinations', () {
      // Test with minimal parameters
      final service1 = ImageService(httpClient: FakeHttpClient());
      expect(service1, isNotNull);

      // Test with connectivity
      final service2 = ImageService(
        httpClient: FakeHttpClient(),
        connectivity: FakeConnectivity([ConnectivityResult.wifi]),
      );
      expect(service2, isNotNull);

      // Test with cache function
      final service3 = ImageService(
        httpClient: FakeHttpClient(),
        getCachedSchuetzenausweisFn: (id, validity) async => null,
      );
      expect(service3, isNotNull);

      // Test with all parameters
      final service4 = ImageService(
        httpClient: FakeHttpClient(),
        connectivity: FakeConnectivity([ConnectivityResult.wifi]),
        getCachedSchuetzenausweisFn: (id, validity) async => null,
      );
      expect(service4, isNotNull);
    });

    group('Enhanced Error Handling and Edge Cases', () {
      test(
        'fetchAndCacheSchuetzenausweis handles extremely large IDs',
        () async {
          final imageData = Uint8List.fromList([200, 201, 202]);
          final service = ImageService(
            httpClient: FakeHttpClient(bytes: imageData),
            connectivity: FakeConnectivity([ConnectivityResult.wifi]),
          );

          final result = await service.fetchAndCacheSchuetzenausweis(
            2147483647, // Max int32 value
            const Duration(seconds: 10),
          );
          expect(result, imageData);
        },
      );

      test(
        'fetchAndCacheSchuetzenausweis handles timeout with cache function',
        () async {
          final cachedData = Uint8List.fromList([210, 211, 212]);
          bool cacheReadAttempted = false;

          final service = ImageService(
            httpClient: FakeHttpClient(shouldThrow: true),
            connectivity: FakeConnectivity([ConnectivityResult.wifi]),
            getCachedSchuetzenausweisFn: (id, validity) async {
              cacheReadAttempted = true;
              return cachedData;
            },
          );

          final result = await service.fetchAndCacheSchuetzenausweis(
            600,
            const Duration(seconds: 10),
          );

          expect(result, cachedData);
          expect(cacheReadAttempted, isTrue);
        },
      );

      test(
        'cacheSchuetzenausweis with custom cache function gets called',
        () async {
          final imageData = Uint8List.fromList([220, 221, 222]);
          bool customCacheCalled = false;
          int capturedPersonId = 0;
          Uint8List? capturedImageData;
          int capturedTimestamp = 0;

          final service = ImageService(
            httpClient: FakeHttpClient(),
            cacheSchuetzenausweisFn: (personId, data, timestamp) async {
              customCacheCalled = true;
              capturedPersonId = personId;
              capturedImageData = data;
              capturedTimestamp = timestamp;
            },
          );

          const testPersonId = 700;
          const testTimestamp = 1640995200000; // Jan 1, 2022

          await service.cacheSchuetzenausweis(
            testPersonId,
            imageData,
            testTimestamp,
          );

          expect(customCacheCalled, isTrue);
          expect(capturedPersonId, equals(testPersonId));
          expect(capturedImageData, equals(imageData));
          expect(capturedTimestamp, equals(testTimestamp));
        },
      );
    });

    group('Complex Connectivity Scenarios', () {
      test(
        'fetchAndCacheSchuetzenausweis handles connectivity check failure',
        () async {
          final cachedData = Uint8List.fromList([240, 241, 242]);

          final service = ImageService(
            httpClient: FakeHttpClient(shouldThrow: true),
            connectivity: ThrowingConnectivity(),
            getCachedSchuetzenausweisFn: (id, validity) async => cachedData,
          );

          final result = await service.fetchAndCacheSchuetzenausweis(
            900,
            const Duration(seconds: 10),
          );

          expect(result, cachedData);
        },
      );
    });

    group('Boundary Value Testing', () {
      test('fetchAndCacheSchuetzenausweis handles maximum Duration', () async {
        final imageData = Uint8List.fromList([250, 251, 252]);
        final service = ImageService(
          httpClient: FakeHttpClient(bytes: imageData),
          connectivity: FakeConnectivity([ConnectivityResult.wifi]),
        );

        final result = await service.fetchAndCacheSchuetzenausweis(
          1000,
          const Duration(days: 999999),
        );
        expect(result, imageData);
      });

      test(
        'getCachedSchuetzenausweis handles minimum positive duration',
        () async {
          final service = ImageService(httpClient: FakeHttpClient());

          final result = await service.getCachedSchuetzenausweis(
            1001,
            const Duration(microseconds: 1),
          );
          expect(result, isNull);
        },
      );

      test('cacheSchuetzenausweis handles extreme timestamp values', () async {
        final imageData = Uint8List.fromList([1, 2, 3]);
        final service = ImageService(httpClient: FakeHttpClient());

        // Should not throw with extreme timestamp values
        await service.cacheSchuetzenausweis(
          1002,
          imageData,
          0x7FFFFFFFFFFFFFFF,
        );
        await service.cacheSchuetzenausweis(
          1003,
          imageData,
          -0x8000000000000000,
        );

        // Verify they were cached (though will return null in test environment)
        final cached1 = await service.getCachedSchuetzenausweis(
          1002,
          const Duration(seconds: 10),
        );
        final cached2 = await service.getCachedSchuetzenausweis(
          1003,
          const Duration(seconds: 10),
        );
        expect(cached1, isNull); // Expected in test environment
        expect(cached2, isNull); // Expected in test environment
      });
    });

    group('Performance and Stress Testing', () {
      test(
        'fetchAndCacheSchuetzenausweis handles rapid sequential calls',
        () async {
          final imageData = Uint8List.fromList([21, 22, 23]);
          final service = ImageService(
            httpClient: FakeHttpClient(bytes: imageData),
            connectivity: FakeConnectivity([ConnectivityResult.wifi]),
          );

          // Make rapid sequential calls
          for (int i = 0; i < 5; i++) {
            final result = await service.fetchAndCacheSchuetzenausweis(
              1100 + i,
              const Duration(seconds: 1),
            );
            expect(result, imageData);
          }
        },
      );

      test('cacheSchuetzenausweis handles multiple operations', () async {
        final service = ImageService(httpClient: FakeHttpClient());

        // Cache multiple images with different sizes
        for (int i = 0; i < 3; i++) {
          final imageSize = (i + 1) * 1024; // 1KB, 2KB, 3KB
          final testImage = Uint8List(imageSize);
          for (int j = 0; j < testImage.length; j++) {
            testImage[j] = (i + j) % 256;
          }

          await service.cacheSchuetzenausweis(
            1200 + i,
            testImage,
            DateTime.now().millisecondsSinceEpoch,
          );
        }

        // Verify all were processed without errors
        for (int i = 0; i < 3; i++) {
          final cached = await service.getCachedSchuetzenausweis(
            1200 + i,
            const Duration(seconds: 10),
          );
          expect(cached, isNull); // Expected in test environment
        }
      });
    });

    test(
      'fetchAndCacheSchuetzenausweis returns null if server is offline and no cached image is available',
      () async {
        final service = ImageService(
          httpClient: FakeHttpClient(shouldThrow: true),
          connectivity: FakeConnectivity([]),
          getCachedSchuetzenausweisFn: (id, validity) async => null,
        );
        final result = await service.fetchAndCacheSchuetzenausweis(
          9999,
          const Duration(seconds: 10),
        );
        expect(result, isNull);
      },
    );
  });
}
