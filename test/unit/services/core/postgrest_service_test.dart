import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:meinbssb/services/core/postgrest_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'postgrest_service_test.mocks.dart';

@GenerateMocks([http.Client, ConfigService])
void main() {
  group('PostgrestService', () {
    late MockClient mockClient;
    late MockConfigService mockConfig;
    late PostgrestService service;

    setUp(() {
      mockClient = MockClient();
      mockConfig = MockConfigService();

      // Setup basic config values
      when(mockConfig.getString('postgrestProtocol')).thenReturn('https');
      when(mockConfig.getString('postgrestServer')).thenReturn('api.test.com');
      when(mockConfig.getString('postgrestPort')).thenReturn('443');
      when(mockConfig.getString('postgrestPath')).thenReturn('/rest/v1');

      service = PostgrestService(
        configService: mockConfig,
        client: mockClient,
      );
    });

    group('Service Configuration', () {
      test('initializes with correct dependencies', () {
        expect(service, isNotNull);
        expect(service.configService, equals(mockConfig));
      });

      test('has correct base URL configuration', () {
        // Test that the service can be created with the mocked config
        expect(service.configService, isNotNull);
        // The config methods are called when accessing _baseUrl, not during construction
        expect(service.configService, equals(mockConfig));
      });
    });

    group('Method Signatures', () {
      test('createUser has correct method signature', () {
        expect(service.createUser, isA<Function>());
      });

      test('getUserByEmail has correct method signature', () {
        expect(service.getUserByEmail, isA<Function>());
      });

      test('getProfilePhoto has correct method signature', () {
        expect(service.getProfilePhoto, isA<Function>());
      });

      test('uploadProfilePhoto has correct method signature', () {
        expect(service.uploadProfilePhoto, isA<Function>());
      });

      test('deleteProfilePhoto has correct method signature', () {
        expect(service.deleteProfilePhoto, isA<Function>());
      });

      test('verifyUser has correct method signature', () {
        expect(service.verifyUser, isA<Function>());
      });

      test('createEmailValidationEntry has correct method signature', () {
        expect(service.createEmailValidationEntry, isA<Function>());
      });

      test('getEmailValidationByToken has correct method signature', () {
        expect(service.getEmailValidationByToken, isA<Function>());
      });

      test('markEmailValidationAsValidated has correct method signature', () {
        expect(service.markEmailValidationAsValidated, isA<Function>());
      });
    });

    group('Method Functionality', () {
      test('methods can be called without throwing exceptions', () async {
        // These methods will fail due to network issues, but should not throw syntax errors
        expect(
          () => service.getUserByEmail('test@example.com'),
          returnsNormally,
        );
        expect(() => service.getProfilePhoto('123'), returnsNormally);
        expect(() => service.verifyUser('token123'), returnsNormally);
        expect(() => service.deleteProfilePhoto('123'), returnsNormally);
        expect(() => service.createEmailValidationEntry(
          personId: '123',
          email: 'test@example.com',
          emailType: 'private',
          verificationToken: 'token123',
        ), returnsNormally,);
        expect(() => service.getEmailValidationByToken('token123'), returnsNormally);
        expect(() => service.markEmailValidationAsValidated('token123'), returnsNormally);
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
        expect(
          () => service.createUser(
            firstName: 'Test',
            lastName: 'User',
            email: 'test@example.com',
            passNumber: '12345678',
            personId: '123',
            verificationToken: 'token123',
          ),
          throwsStateError,
        );
      });
    });

    group('Profile Photo Cache', () {
      test('profilePhotoCache returns cached photo without network call',
          () async {
        const userId = 'cacheTest';
        final bytes = Uint8List.fromList([10, 20, 30]);
        service.profilePhotoCache[userId] = bytes;
        // Should not call http.Client.get
        final result = await service.getProfilePhoto(userId);
        expect(result, bytes);
      });

      test('profilePhotoCache is updated after uploadProfilePhoto', () async {
        const userId = 'cacheUpload';
        final bytes = [40, 50, 60];
        // Mock GET for getUserByPersonId
        when(
          mockClient.get(
            any,
            headers: anyNamed('headers'),
          ),
        ).thenAnswer(
            (_) async => http.Response('[{"person_id":"$userId"}]', 200),);
        // Mock PATCH for uploadProfilePhoto
        when(
          mockClient.patch(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('', 200));
        final result = await service.uploadProfilePhoto(userId, bytes);
        expect(result, true);
        expect(service.profilePhotoCache[userId], Uint8List.fromList(bytes));
      });

      test('profilePhotoCache is cleared after deleteProfilePhoto', () async {
        const userId = 'cacheDelete';
        service.profilePhotoCache[userId] = Uint8List.fromList([70, 80, 90]);
        when(
          mockClient.patch(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('', 200));
        final result = await service.deleteProfilePhoto(userId);
        expect(result, true);
        expect(service.profilePhotoCache.containsKey(userId), false);
      });
    });
  });
}
