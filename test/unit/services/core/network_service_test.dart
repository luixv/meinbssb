import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'network_service_test.mocks.dart';

@GenerateMocks([InternetConnectionChecker, ConfigService])
void main() {
  late NetworkService networkService;
  late MockInternetConnectionChecker mockConnectionChecker;
  late MockConfigService mockConfigService;

  setUp(() {
    mockConnectionChecker = MockInternetConnectionChecker();
    mockConfigService = MockConfigService();
    networkService = NetworkService(
      connectionChecker: mockConnectionChecker,
      configService: mockConfigService,
    );
  });

  group('NetworkService Tests', () {
    group('Internet Connection Checks', () {
      test('hasInternet returns true when connection is available', () async {
        when(mockConnectionChecker.hasConnection).thenAnswer((_) async => true);

        final result = await networkService.hasInternet();

        expect(result, true);
        verify(mockConnectionChecker.hasConnection).called(1);
      });

      test(
        'hasInternet returns false when connection is not available',
        () async {
          when(
            mockConnectionChecker.hasConnection,
          ).thenAnswer((_) async => false);

          final result = await networkService.hasInternet();

          expect(result, false);
          verify(mockConnectionChecker.hasConnection).called(1);
        },
      );
    });

    group('Cache Expiration Duration', () {
      test('returns default duration when config value is null', () {
        when(
          mockConfigService.getString('cacheExpirationHours'),
        ).thenReturn(null);

        final duration = networkService.getCacheExpirationDuration();

        expect(duration, const Duration(hours: 24));
        verify(mockConfigService.getString('cacheExpirationHours')).called(1);
      });

      test('returns default duration when config value is invalid', () {
        when(
          mockConfigService.getString('cacheExpirationHours'),
        ).thenReturn('invalid');

        final duration = networkService.getCacheExpirationDuration();

        expect(duration, const Duration(hours: 24));
        verify(mockConfigService.getString('cacheExpirationHours')).called(1);
      });

      test('returns configured duration when valid value is provided', () {
        when(
          mockConfigService.getString('cacheExpirationHours'),
        ).thenReturn('12');

        final duration = networkService.getCacheExpirationDuration();

        expect(duration, const Duration(hours: 12));
        verify(mockConfigService.getString('cacheExpirationHours')).called(1);
      });

      test('handles zero cache expiration hours', () {
        when(
          mockConfigService.getString('cacheExpirationHours'),
        ).thenReturn('0');

        final duration = networkService.getCacheExpirationDuration();

        expect(duration, const Duration(hours: 0));
        verify(mockConfigService.getString('cacheExpirationHours')).called(1);
      });
    });
  });
}
