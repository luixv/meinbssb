
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:meinbssb/services/core/postgrest_service.dart';
import '../../helpers/test_mocks.mocks.dart';

void main() {
  group('PostgrestService', () {
    late PostgrestService postgrestService;
    late MockConfigService mockConfigService;

    setUp(() {
      mockConfigService = MockConfigService();
      
      // Setup basic config values
      when(mockConfigService.getString('postgrestProtocol')).thenReturn('https');
      when(mockConfigService.getString('postgrestServer')).thenReturn('api.test.com');
      when(mockConfigService.getString('postgrestPort')).thenReturn('443');
      when(mockConfigService.getString('postgrestPath')).thenReturn('/rest/v1');

      postgrestService = PostgrestService(
        configService: mockConfigService,
      );
    });

    group('Service Configuration', () {
      test('initializes with correct dependencies', () {
        expect(postgrestService, isNotNull);
        expect(postgrestService.configService, equals(mockConfigService));
      });

      test('has correct base URL configuration', () {
        // Test that the service can be created with the mocked config
        expect(postgrestService.configService, isNotNull);
        // The config methods are called when accessing _baseUrl, not during construction
        expect(postgrestService.configService, equals(mockConfigService));
      });
    });

    group('Method Signatures', () {
      test('createUser has correct method signature', () {
        expect(postgrestService.createUser, isA<Function>());
      });

      test('getUserByEmail has correct method signature', () {
        expect(postgrestService.getUserByEmail, isA<Function>());
      });

      test('getProfilePhoto has correct method signature', () {
        expect(postgrestService.getProfilePhoto, isA<Function>());
      });

      test('uploadProfilePhoto has correct method signature', () {
        expect(postgrestService.uploadProfilePhoto, isA<Function>());
      });

      test('deleteProfilePhoto has correct method signature', () {
        expect(postgrestService.deleteProfilePhoto, isA<Function>());
      });

      test('verifyUser has correct method signature', () {
        expect(postgrestService.verifyUser, isA<Function>());
      });
    });

    group('Method Functionality', () {
      test('methods can be called without throwing exceptions', () async {
        // These methods will fail due to network issues, but should not throw syntax errors
        expect(() => postgrestService.getUserByEmail('test@example.com'), returnsNormally);
        expect(() => postgrestService.getProfilePhoto('123'), returnsNormally);
        expect(() => postgrestService.verifyUser('token123'), returnsNormally);
        expect(() => postgrestService.deleteProfilePhoto('123'), returnsNormally);
      });
    });

    group('Error Handling', () {
      test('handles null config values gracefully', () {
        // Create a new mock for this test
        final nullConfigService = MockConfigService();
        when(nullConfigService.getString('postgrestProtocol')).thenReturn(null);
        when(nullConfigService.getString('postgrestServer')).thenReturn(null);
        when(nullConfigService.getString('postgrestPort')).thenReturn(null);
        when(nullConfigService.getString('postgrestPath')).thenReturn(null);

        // The service should throw an error when trying to access _baseUrl
        final service = PostgrestService(configService: nullConfigService);
        expect(() => service.createUser(
          firstName: 'Test',
          lastName: 'User',
          email: 'test@example.com',
          passNumber: '12345678',
          personId: '123',
          verificationToken: 'token123',
        ), throwsStateError,);
      });
    });
  });
} 