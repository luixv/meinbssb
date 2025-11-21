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

      reset(mockClient);
      reset(mockConfig);

      when(mockConfig.getString('postgrestProtocol')).thenReturn('https');
      when(mockConfig.getString('postgrestServer')).thenReturn('api.test.com');
      when(mockConfig.getString('postgrestPort')).thenReturn('443');
      when(mockConfig.getString('postgrestPath')).thenReturn('/rest/v1');
      when(mockConfig.getString('postgrestApiKey')).thenReturn('test-api-key');

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

      test('includes API key in headers when configured', () async {
        Map<String, String>? capturedHeaders;
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((invocation) async {
          capturedHeaders = invocation.namedArguments[#headers] as Map<String, String>?;
          return http.Response('[]', 200);
        });

        await service.getUserByEmail('test@example.com');

        expect(capturedHeaders, isNotNull);
        final headers = capturedHeaders!;
        expect(headers['X-API-Key'], equals('test-api-key'));
        expect(headers['Content-Type'], equals('application/json'));
        expect(headers['Accept'], equals('application/json'));
        expect(headers['Prefer'], equals('return=representation'));
      });

      test('excludes API key from headers when not configured', () async {
        when(mockConfig.getString('postgrestApiKey')).thenReturn(null);
        final newService = PostgrestService(
          configService: mockConfig,
          client: mockClient,
        );

        Map<String, String>? capturedHeaders;
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((invocation) async {
          capturedHeaders = invocation.namedArguments[#headers] as Map<String, String>?;
          return http.Response('[]', 200);
        });

        await newService.getUserByEmail('test@example.com');

        expect(capturedHeaders, isNotNull);
        expect(capturedHeaders!.containsKey('X-API-Key'), isFalse);
      });
    });

    group('User Creation', () {
      test('createUser creates user successfully', () async {
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('[]', 201));

        final result = await service.createUser(
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          passNumber: '12345678',
          personId: '123',
          verificationToken: 'token123',
        );

        expect(result, isA<Map<String, dynamic>>());
        verify(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).called(1);
      });

      test('createUser throws exception on failure', () async {
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('Error', 400));

        expect(
          () => service.createUser(
            firstName: 'John',
            lastName: 'Doe',
            email: 'john@example.com',
            passNumber: '12345678',
            personId: '123',
            verificationToken: 'token123',
          ),
          throwsException,
        );
      });
    });

    group('User Retrieval', () {
      test('getUserByEmail returns user when found', () async {
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
        )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getUserByEmail('john@example.com');
        expect(result, equals(mockResponse[0]));
        verify(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).called(1);
      });

      test('getUserByEmail returns null when user not found', () async {
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.getUserByEmail('notfound@example.com');
        expect(result, isNull);
      });

      test('getUserByEmail returns null on error', () async {
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('Server error', 500));

        final result = await service.getUserByEmail('john@example.com');
        expect(result, isNull);
      });

      test('getUserByPersonId returns user when found', () async {
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
        )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getUserByPersonId('123');
        expect(result, equals(mockResponse[0]));
      });

      test('getUserByPersonId returns null when user not found', () async {
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.getUserByPersonId('999');
        expect(result, isNull);
      });

      test('getUserByPassNumber returns user when found', () async {
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
        )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getUserByPassNumber('12345678');
        expect(result, equals(mockResponse[0]));
      });

      test('getUserByPassNumber returns null when user not found', () async {
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.getUserByPassNumber('99999999');
        expect(result, isNull);
      });

      test('getUserByVerificationToken returns user when found', () async {
        final mockResponse = [
          {
            'id': 1,
            'person_id': '123',
            'verification_token': 'token123',
            'firstname': 'John',
            'lastname': 'Doe',
          }
        ];
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getUserByVerificationToken('token123');
        expect(result, equals(mockResponse[0]));
      });

      test('getUserByVerificationToken returns null when not found', () async {
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.getUserByVerificationToken('invalid');
        expect(result, isNull);
      });
    });

    group('User Verification', () {
      test('verifyUser updates verification status successfully', () async {
        when(mockClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.verifyUser('token123');
        expect(result, isTrue);
        verify(mockClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).called(1);
      });

      test('verifyUser returns false on error', () async {
        when(mockClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('Server error', 500));

        final result = await service.verifyUser('token123');
        expect(result, isFalse);
      });
    });

    group('User Deletion', () {
      test('deleteUserRegistration deletes user successfully', () async {
        when(mockClient.delete(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('', 204));

        final result = await service.deleteUserRegistration(123);
        expect(result, isTrue);
        verify(mockClient.delete(
          any,
          headers: anyNamed('headers'),
        )).called(1);
      });

      test('deleteUserRegistration returns false on error', () async {
        when(mockClient.delete(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('Server error', 500));

        final result = await service.deleteUserRegistration(123);
        expect(result, isFalse);
      });

      test('softDeleteUser sets is_deleted to true', () async {
        when(mockClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.softDeleteUser('123');
        expect(result, isTrue);
        expect(service.profilePhotoCache.containsKey('123'), isFalse);
      });

      test('softDeleteUser returns false on error', () async {
        when(mockClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('Server error', 500));

        final result = await service.softDeleteUser('123');
        expect(result, isFalse);
      });
    });

    group('User Updates', () {
      test('updateUserByVerificationToken updates user successfully', () async {
        when(mockClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.updateUserByVerificationToken(
          'token123',
          {'firstname': 'Jane'},
        );
        expect(result.statusCode, equals(200));
      });
    });

    group('Password Reset', () {
      test('createPasswordResetEntry creates entry successfully', () async {
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('[]', 201));

        await service.createPasswordResetEntry(
          personId: '123',
          verificationToken: 'token123',
        );

        verify(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).called(1);
      });

      test('getUserByPasswordResetVerificationToken returns entry when found', () async {
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
        )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getUserByPasswordResetVerificationToken('token123');
        expect(result, equals(mockResponse[0]));
      });

      test('getUserByPasswordResetVerificationToken returns null when not found', () async {
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.getUserByPasswordResetVerificationToken('invalid');
        expect(result, isNull);
      });

      test('markPasswordResetEntryUsed marks entry as used', () async {
        when(mockClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('[]', 200));

        await service.markPasswordResetEntryUsed(verificationToken: 'token123');

        verify(mockClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).called(1);
      });

      test('getLatestPasswordResetForPerson returns latest entry', () async {
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
        )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getLatestPasswordResetForPerson('123');
        expect(result, equals(mockResponse[0]));
      });

      test('getLatestPasswordResetForPerson returns null when not found', () async {
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.getLatestPasswordResetForPerson('999');
        expect(result, isNull);
      });
    });

    group('Email Validation', () {
      test('createEmailValidationEntry creates entry successfully', () async {
        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('[]', 201));

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
        )).called(1);
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
        )).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getEmailValidationByToken('token123');
        expect(result, equals(mockResponse[0]));
      });

      test('getEmailValidationByToken returns null when not found', () async {
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.getEmailValidationByToken('invalid');
        expect(result, isNull);
      });

      test('markEmailValidationAsValidated marks entry as validated', () async {
        when(mockClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.markEmailValidationAsValidated('token123');
        expect(result, isTrue);
        verify(mockClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).called(1);
      });

      test('markEmailValidationAsValidated returns false on error', () async {
        when(mockClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('Server error', 500));

        final result = await service.markEmailValidationAsValidated('token123');
        expect(result, isFalse);
      });
    });

    group('Profile Photo', () {
      test('getProfilePhoto returns cached photo without network call', () async {
        const userId = 'cacheTest';
        final bytes = Uint8List.fromList([10, 20, 30]);
        service.profilePhotoCache[userId] = bytes;

        final result = await service.getProfilePhoto(userId);
        expect(result, equals(bytes));
        verifyNever(mockClient.get(any, headers: anyNamed('headers')));
      });

      test('getProfilePhoto fetches and caches new photo', () async {
        const userId = 'newPhoto';
        const photoHex = '\\x010203';
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode([{'profile_photo': photoHex}]),
          200,
        ));

        final result = await service.getProfilePhoto(userId);
        expect(result, isA<Uint8List>());
        expect(result, equals(Uint8List.fromList([1, 2, 3])));
        expect(service.profilePhotoCache[userId], equals(result));
      });

      test('getProfilePhoto returns null when no photo found', () async {
        const userId = 'noPhoto';
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode([{'profile_photo': null}]),
          200,
        ));

        final result = await service.getProfilePhoto(userId);
        expect(result, isNull);
      });

      test('uploadProfilePhoto updates existing user photo', () async {
        const userId = 'existingUser';
        final bytes = [1, 2, 3];

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          jsonEncode([{'person_id': userId}]),
          200,
        ));

        when(mockClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.uploadProfilePhoto(userId, bytes);
        expect(result, isTrue);
        expect(service.profilePhotoCache[userId], equals(Uint8List.fromList(bytes)));
      });

      test('uploadProfilePhoto creates new user with photo', () async {
        const userId = 'newUser';
        final bytes = [1, 2, 3];

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('[]', 200));

        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('[]', 201));

        final result = await service.uploadProfilePhoto(userId, bytes);
        expect(result, isTrue);
        expect(service.profilePhotoCache[userId], equals(Uint8List.fromList(bytes)));
      });

      test('uploadProfilePhoto returns false on error', () async {
        const userId = 'errorUser';
        final bytes = [1, 2, 3];

        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('[]', 200));

        when(mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('Error', 400));

        final result = await service.uploadProfilePhoto(userId, bytes);
        expect(result, isFalse);
      });

      test('deleteProfilePhoto removes photo and clears cache', () async {
        const userId = 'deleteTest';
        service.profilePhotoCache[userId] = Uint8List.fromList([1, 2, 3]);

        when(mockClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.deleteProfilePhoto(userId);
        expect(result, isTrue);
        expect(service.profilePhotoCache.containsKey(userId), isFalse);
      });

      test('deleteProfilePhoto returns false on error', () async {
        const userId = 'errorDelete';
        when(mockClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('Error', 500));

        final result = await service.deleteProfilePhoto(userId);
        expect(result, isFalse);
      });
    });

    group('Error Handling', () {
      test('handles network exceptions gracefully', () async {
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenThrow(Exception('Network error'));

        final result = await service.getUserByEmail('test@example.com');
        expect(result, isNull);
      });

      test('handles JSON decode errors gracefully', () async {
        when(mockClient.get(
          any,
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('invalid json', 200));

        final result = await service.getUserByEmail('test@example.com');
        expect(result, isNull);
      });
    });
  });
}
