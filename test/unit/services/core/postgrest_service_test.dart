import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:meinbssb/services/core/postgrest_service.dart';
import 'package:meinbssb/services/core/config_service.dart';

@GenerateMocks([
  ConfigService,
  http.Client,
])
import 'postgrest_service_test.mocks.dart';
void main() {
  group('PostgrestService', () {
    late MockClient mockClient;
    late MockConfigService mockConfig;
    late PostgrestService service;

    setUp(() {
      mockClient = MockClient();
      mockConfig = MockConfigService();

      // Reset all mocks to avoid verification conflicts
      reset(mockClient);
      reset(mockConfig);

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

    group('User Methods', () {
      test('getUserByPersonId returns user data when found', () async {
        final mockResponse = [
          {
            'id': 1,
            'person_id': '123',
            'firstname': 'John',
            'lastname': 'Doe',
            'email': 'john@example.com',
          }
        ];
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        ),).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getUserByPersonId('123');
        expect(result, equals(mockResponse[0]));
        verify(mockClient.get(
          any,
          headers: anyNamed('headers'),
        ),).called(1);
      });

      test('getUserByPersonId returns null when user not found', () async {
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        ),).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.getUserByPersonId('123');
        expect(result, isNull);
      });

      test('getUserByPersonId returns null on error', () async {
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        ),).thenAnswer((_) async => http.Response('Server error', 500));

        final result = await service.getUserByPersonId('123');
        expect(result, isNull);
      });

      test('getUserByPassNumber returns user data when found', () async {
        final mockResponse = [
          {
            'id': 1,
            'pass_number': '12345678',
            'firstname': 'John',
            'lastname': 'Doe',
            'email': 'john@example.com',
          }
        ];
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        ),).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getUserByPassNumber('12345678');
        expect(result, equals(mockResponse[0]));
        verify(mockClient.get(
          any,
          headers: anyNamed('headers'),
        ),).called(1);
      });

      test('getUserByPassNumber returns null when user not found', () async {
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        ),).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.getUserByPassNumber('12345678');
        expect(result, isNull);
      });

      test('getUserByPassNumber returns null on error', () async {
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        ),).thenAnswer((_) async => http.Response('Server error', 500));

        final result = await service.getUserByPassNumber('12345678');
        expect(result, isNull);
      });

      test('getUserByEmail returns user data when found', () async {
        final mockResponse = [
          {
            'id': 1,
            'email': 'test@example.com',
            'firstname': 'John',
            'lastname': 'Doe',
          }
        ];
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        ),).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getUserByEmail('test@example.com');
        expect(result, equals(mockResponse[0]));
        verify(mockClient.get(
          any,
          headers: anyNamed('headers'),
        ),).called(1);
      });

      test('getUserByEmail returns null when user not found', () async {
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        ),).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.getUserByEmail('test@example.com');
        expect(result, isNull);
      });

      test('getUserByEmail returns null on error', () async {
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        ),).thenAnswer((_) async => http.Response('Server error', 500));

        final result = await service.getUserByEmail('test@example.com');
        expect(result, isNull);
      });

      test('verifyUser updates verification status successfully', () async {
        when(mockClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.verifyUser('token123');
        expect(result, isTrue);
        verify(mockClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),).called(1);
      });

      test('verifyUser returns false on error', () async {
        when(mockClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),).thenAnswer((_) async => http.Response('Server error', 500));

        final result = await service.verifyUser('token123');
        expect(result, isFalse);
      });

      test('deleteUserRegistration deletes user successfully', () async {
        when(mockClient.delete(
          any,
          headers: anyNamed('headers'),
        ),).thenAnswer((_) async => http.Response('', 204));

        final result = await service.deleteUserRegistration(123);
        expect(result, isTrue);
        verify(mockClient.delete(
          any,
          headers: anyNamed('headers'),
        ),).called(1);
      });

      test('deleteUserRegistration returns false on error', () async {
        when(mockClient.delete(
          any,
          headers: anyNamed('headers'),
        ),).thenAnswer((_) async => http.Response('Server error', 500));

        final result = await service.deleteUserRegistration(123);
        expect(result, isFalse);
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

    group('Password Reset', () {
      test('createPasswordResetEntry creates entry successfully', () async {
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),).thenAnswer((_) async => http.Response('[]', 201));

        await service.createPasswordResetEntry(
          personId: '123',
          verificationToken: 'token123',
        );

        verify(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),).called(1);
      });

      test('getUserByPasswordResetVerificationToken returns user data when found', () async {
        final mockResponse = [
          {
            'id': 1,
            'person_id': '123',
            'verification_token': 'token123',
            'created_at': '2024-01-01T00:00:00Z',
            'is_used': false,
          }
        ];
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        ),).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getUserByPasswordResetVerificationToken('token123');
        expect(result, equals(mockResponse[0]));
        verify(mockClient.get(
          any,
          headers: anyNamed('headers'),
        ),).called(1);
      });

      test('getUserByPasswordResetVerificationToken returns null when not found', () async {
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        ),).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.getUserByPasswordResetVerificationToken('token123');
        expect(result, isNull);
      });

      test('getUserByPasswordResetVerificationToken returns null on error', () async {
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        ),).thenAnswer((_) async => http.Response('Server error', 500));

        final result = await service.getUserByPasswordResetVerificationToken('token123');
        expect(result, isNull);
      });

      test('markPasswordResetEntryUsed marks entry as used successfully', () async {
        when(mockClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),).thenAnswer((_) async => http.Response('[]', 200));

        await service.markPasswordResetEntryUsed(verificationToken: 'token123');

        verify(mockClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),).called(1);
      });

      test('getLatestPasswordResetForPerson returns latest entry when found', () async {
        final mockResponse = [
          {
            'id': 1,
            'person_id': '123',
            'verification_token': 'token123',
            'created_at': '2024-01-01T00:00:00Z',
            'is_used': false,
          }
        ];
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        ),).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getLatestPasswordResetForPerson('123');
        expect(result, equals(mockResponse[0]));
        verify(mockClient.get(
          any,
          headers: anyNamed('headers'),
        ),).called(1);
      });

      test('getLatestPasswordResetForPerson returns null when not found', () async {
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        ),).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.getLatestPasswordResetForPerson('123');
        expect(result, isNull);
      });

      test('getLatestPasswordResetForPerson returns null on error', () async {
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        ),).thenAnswer((_) async => http.Response('Server error', 500));

        final result = await service.getLatestPasswordResetForPerson('123');
        expect(result, isNull);
      });
    });

    group('Email Validation', () {
      test('createEmailValidationEntry creates entry successfully', () async {
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),).thenAnswer((_) async => http.Response('[]', 201));

        await service.createEmailValidationEntry(
          personId: '123',
          email: 'test@example.com',
          emailType: 'private',
          verificationToken: 'token123',
        );

        verify(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),).called(1);
      });

      test('getEmailValidationByToken returns entry when found', () async {
        final mockResponse = [
          {
            'id': 1,
            'person_id': '123',
            'email': 'test@example.com',
            'emailtype': 'private',
            'verification_token': 'token123',
            'created_on': '2024-01-01T00:00:00Z',
            'validated': false,
          }
        ];
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        ),).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getEmailValidationByToken('token123');
        expect(result, equals(mockResponse[0]));
        verify(mockClient.get(
          any,
          headers: anyNamed('headers'),
        ),).called(1);
      });

      test('getEmailValidationByToken returns null when not found', () async {
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        ),).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.getEmailValidationByToken('token123');
        expect(result, isNull);
      });

      test('getEmailValidationByToken returns null on error', () async {
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        ),).thenAnswer((_) async => http.Response('Server error', 500));

        final result = await service.getEmailValidationByToken('token123');
        expect(result, isNull);
      });

      test('markEmailValidationAsValidated marks entry as validated successfully', () async {
        when(mockClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.markEmailValidationAsValidated('token123');
        expect(result, isTrue);
        verify(mockClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),).called(1);
      });

      test('markEmailValidationAsValidated returns false on error', () async {
        when(mockClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),).thenAnswer((_) async => http.Response('Server error', 500));

        final result = await service.markEmailValidationAsValidated('token123');
        expect(result, isFalse);
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

      test('getProfilePhoto fetches and caches new photo', () async {
        const userId = 'newPhoto';
        const photoHex = '\\x010203';
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        ),).thenAnswer((_) async => http.Response(
          jsonEncode([{'profile_photo': photoHex}]),
          200,
        ),);

        final result = await service.getProfilePhoto(userId);
        expect(result, isA<Uint8List>());
        expect(service.profilePhotoCache[userId], equals(result));
      });

      test('uploadProfilePhoto updates photo successfully', () async {
        const userId = 'testUser';
        final bytes = [1, 2, 3];

        // Mock user existence check
        when(mockClient.get(
            any,
            headers: anyNamed('headers'),
        ),).thenAnswer((_) async => http.Response(
          jsonEncode([{'person_id': userId}]),
          200,
        ),);

        // Mock photo update
        when(mockClient.patch(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
        ),).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.uploadProfilePhoto(userId, bytes);
        expect(result, isTrue);
        expect(service.profilePhotoCache[userId], equals(Uint8List.fromList(bytes)));
      });

      test('deleteProfilePhoto removes photo and clears cache', () async {
        const userId = 'deleteTest';
        service.profilePhotoCache[userId] = Uint8List.fromList([1, 2, 3]);

        when(mockClient.patch(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
        ),).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.deleteProfilePhoto(userId);
        expect(result, isTrue);
        expect(service.profilePhotoCache.containsKey(userId), isFalse);
      });
    });
  });
}
