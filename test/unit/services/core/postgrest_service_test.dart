import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:meinbssb/services/core/postgrest_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/models/beduerfnisse_auswahl_typ_data.dart';
import 'package:meinbssb/models/beduerfnisse_auswahl_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_status_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_data.dart';
import 'package:meinbssb/models/beduerfnisse_datei_data.dart';
import 'package:meinbssb/models/beduerfnisse_sport_data.dart';
import 'package:meinbssb/models/beduerfnisse_waffe_besitz_data.dart';

@GenerateMocks([ConfigService, http.Client])
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

      service = PostgrestService(configService: mockConfig, client: mockClient);
    });

    group('Service Configuration', () {
      test('initializes with correct dependencies', () {
        expect(service, isNotNull);
        expect(service.configService, equals(mockConfig));
      });

      test('includes API key in headers when configured', () async {
        Map<String, String>? capturedHeaders;
        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((
          invocation,
        ) async {
          capturedHeaders =
              invocation.namedArguments[#headers] as Map<String, String>?;
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
        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer((
          invocation,
        ) async {
          capturedHeaders =
              invocation.namedArguments[#headers] as Map<String, String>?;
          return http.Response('[]', 200);
        });

        await newService.getUserByEmail('test@example.com');

        expect(capturedHeaders, isNotNull);
        expect(capturedHeaders!.containsKey('X-API-Key'), isFalse);
      });
    });

    group('User Creation', () {
      test('createUser creates user successfully', () async {
        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('[]', 201));

        final result = await service.createUser(
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          passNumber: '12345678',
          personId: '123',
          verificationToken: 'token123',
        );

        expect(result, isA<Map<String, dynamic>>());
        verify(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(1);
      });

      test('createUser throws exception on failure', () async {
        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('Error', 400));

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
          },
        ];
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getUserByEmail('john@example.com');
        expect(result, equals(mockResponse[0]));
        verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
      });

      test('getUserByEmail returns null when user not found', () async {
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.getUserByEmail('notfound@example.com');
        expect(result, isNull);
      });

      test('getUserByEmail returns null on error', () async {
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('Server error', 500));

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
          },
        ];
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getUserByPersonId('123');
        expect(result, equals(mockResponse[0]));
      });

      test('getUserByPersonId returns null when user not found', () async {
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('[]', 200));

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
          },
        ];
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getUserByPassNumber('12345678');
        expect(result, equals(mockResponse[0]));
      });

      test('getUserByPassNumber returns null when user not found', () async {
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('[]', 200));

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
          },
        ];
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getUserByVerificationToken('token123');
        expect(result, equals(mockResponse[0]));
      });

      test('getUserByVerificationToken returns null when not found', () async {
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.getUserByVerificationToken('invalid');
        expect(result, isNull);
      });
    });

    group('User Verification', () {
      test('verifyUser updates verification status successfully', () async {
        when(
          mockClient.patch(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.verifyUser('token123');
        expect(result, isTrue);
        verify(
          mockClient.patch(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(1);
      });

      test('verifyUser returns false on error', () async {
        when(
          mockClient.patch(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('Server error', 500));

        final result = await service.verifyUser('token123');
        expect(result, isFalse);
      });
    });

    group('User Deletion', () {
      test('deleteUserRegistration deletes user successfully', () async {
        when(
          mockClient.delete(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('', 204));

        final result = await service.deleteUserRegistration(123);
        expect(result, isTrue);
        verify(mockClient.delete(any, headers: anyNamed('headers'))).called(1);
      });

      test('deleteUserRegistration returns false on error', () async {
        when(
          mockClient.delete(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('Server error', 500));

        final result = await service.deleteUserRegistration(123);
        expect(result, isFalse);
      });

      test('softDeleteUser sets is_deleted to true', () async {
        when(
          mockClient.patch(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.softDeleteUser('123');
        expect(result, isTrue);
        expect(service.profilePhotoCache.containsKey('123'), isFalse);
      });

      test('softDeleteUser returns false on error', () async {
        when(
          mockClient.patch(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('Server error', 500));

        final result = await service.softDeleteUser('123');
        expect(result, isFalse);
      });
    });

    group('User Updates', () {
      test('updateUserByVerificationToken updates user successfully', () async {
        when(
          mockClient.patch(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.updateUserByVerificationToken('token123', {
          'firstname': 'Jane',
        });
        expect(result.statusCode, equals(200));
      });
    });

    group('Password Reset', () {
      test('createPasswordResetEntry creates entry successfully', () async {
        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('[]', 201));

        await service.createPasswordResetEntry(
          personId: '123',
          verificationToken: 'token123',
        );

        verify(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(1);
      });

      test(
        'getUserByPasswordResetVerificationToken returns entry when found',
        () async {
          final mockResponse = [
            {
              'id': 1,
              'person_id': '123',
              'verification_token': 'token123',
              'created_at': '2024-01-01T00:00:00Z',
              'is_used': false,
            },
          ];
          when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
            (_) async => http.Response(jsonEncode(mockResponse), 200),
          );

          final result = await service.getUserByPasswordResetVerificationToken(
            'token123',
          );
          expect(result, equals(mockResponse[0]));
        },
      );

      test(
        'getUserByPasswordResetVerificationToken returns null when not found',
        () async {
          when(
            mockClient.get(any, headers: anyNamed('headers')),
          ).thenAnswer((_) async => http.Response('[]', 200));

          final result = await service.getUserByPasswordResetVerificationToken(
            'invalid',
          );
          expect(result, isNull);
        },
      );

      test('markPasswordResetEntryUsed marks entry as used', () async {
        when(
          mockClient.patch(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('[]', 200));

        await service.markPasswordResetEntryUsed(verificationToken: 'token123');

        verify(
          mockClient.patch(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(1);
      });

      test('getLatestPasswordResetForPerson returns latest entry', () async {
        final mockResponse = [
          {
            'id': 1,
            'person_id': '123',
            'verification_token': 'token123',
            'created_at': '2024-01-01T00:00:00Z',
            'is_used': false,
          },
        ];
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getLatestPasswordResetForPerson('123');
        expect(result, equals(mockResponse[0]));
      });

      test(
        'getLatestPasswordResetForPerson returns null when not found',
        () async {
          when(
            mockClient.get(any, headers: anyNamed('headers')),
          ).thenAnswer((_) async => http.Response('[]', 200));

          final result = await service.getLatestPasswordResetForPerson('999');
          expect(result, isNull);
        },
      );
    });

    group('Email Validation', () {
      test('createEmailValidationEntry creates entry successfully', () async {
        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('[]', 201));

        await service.createEmailValidationEntry(
          personId: '123',
          email: 'test@example.com',
          emailType: 'private',
          verificationToken: 'token123',
        );

        verify(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(1);
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
          },
        ];
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getEmailValidationByToken('token123');
        expect(result, equals(mockResponse[0]));
      });

      test('getEmailValidationByToken returns null when not found', () async {
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.getEmailValidationByToken('invalid');
        expect(result, isNull);
      });

      test('markEmailValidationAsValidated marks entry as validated', () async {
        when(
          mockClient.patch(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.markEmailValidationAsValidated('token123');
        expect(result, isTrue);
        verify(
          mockClient.patch(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(1);
      });

      test('markEmailValidationAsValidated returns false on error', () async {
        when(
          mockClient.patch(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('Server error', 500));

        final result = await service.markEmailValidationAsValidated('token123');
        expect(result, isFalse);
      });
    });

    group('Profile Photo', () {
      test(
        'getProfilePhoto returns cached photo without network call',
        () async {
          const userId = 'cacheTest';
          final bytes = Uint8List.fromList([10, 20, 30]);
          service.profilePhotoCache[userId] = bytes;

          final result = await service.getProfilePhoto(userId);
          expect(result, equals(bytes));
          verifyNever(mockClient.get(any, headers: anyNamed('headers')));
        },
      );

      test('getProfilePhoto fetches and caches new photo', () async {
        const userId = 'newPhoto';
        const photoHex = '\\x010203';
        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) async => http.Response(
            jsonEncode([
              {'profile_photo': photoHex},
            ]),
            200,
          ),
        );

        final result = await service.getProfilePhoto(userId);
        expect(result, isA<Uint8List>());
        expect(result, equals(Uint8List.fromList([1, 2, 3])));
        expect(service.profilePhotoCache[userId], equals(result));
      });

      test('getProfilePhoto returns null when no photo found', () async {
        const userId = 'noPhoto';
        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) async => http.Response(
            jsonEncode([
              {'profile_photo': null},
            ]),
            200,
          ),
        );

        final result = await service.getProfilePhoto(userId);
        expect(result, isNull);
      });

      test('uploadProfilePhoto updates existing user photo', () async {
        const userId = 'existingUser';
        final bytes = [1, 2, 3];

        when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
          (_) async => http.Response(
            jsonEncode([
              {'person_id': userId},
            ]),
            200,
          ),
        );

        when(
          mockClient.patch(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.uploadProfilePhoto(userId, bytes);
        expect(result, isTrue);
        expect(
          service.profilePhotoCache[userId],
          equals(Uint8List.fromList(bytes)),
        );
      });

      test('uploadProfilePhoto creates new user with photo', () async {
        const userId = 'newUser';
        final bytes = [1, 2, 3];

        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('[]', 200));

        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('[]', 201));

        final result = await service.uploadProfilePhoto(userId, bytes);
        expect(result, isTrue);
        expect(
          service.profilePhotoCache[userId],
          equals(Uint8List.fromList(bytes)),
        );
      });

      test('uploadProfilePhoto returns false on error', () async {
        const userId = 'errorUser';
        final bytes = [1, 2, 3];

        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('[]', 200));

        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('Error', 400));

        final result = await service.uploadProfilePhoto(userId, bytes);
        expect(result, isFalse);
      });

      test('deleteProfilePhoto removes photo and clears cache', () async {
        const userId = 'deleteTest';
        service.profilePhotoCache[userId] = Uint8List.fromList([1, 2, 3]);

        when(
          mockClient.patch(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.deleteProfilePhoto(userId);
        expect(result, isTrue);
        expect(service.profilePhotoCache.containsKey(userId), isFalse);
      });

      test('deleteProfilePhoto returns false on error', () async {
        const userId = 'errorDelete';
        when(
          mockClient.patch(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('Error', 500));

        final result = await service.deleteProfilePhoto(userId);
        expect(result, isFalse);
      });
    });

    group('Error Handling', () {
      test('handles network exceptions gracefully', () async {
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenThrow(Exception('Network error'));

        final result = await service.getUserByEmail('test@example.com');
        expect(result, isNull);
      });

      test('handles JSON decode errors gracefully', () async {
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('invalid json', 200));

        final result = await service.getUserByEmail('test@example.com');
        expect(result, isNull);
      });
    });

    group('bed_auswahl_typ Service Methods', () {

      test('getBedAuswahlTypen returns list of types', () async {
        final mockResponse = [
          {'id': 1, 'kuerzel': 'WA', 'beschreibung': 'Waffenart'},
          {'id': 2, 'kuerzel': 'DI', 'beschreibung': 'Disziplin'},
        ];
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getBedAuswahlTypen();
        expect(result, hasLength(2));
        expect(result[0], isA<BeduerfnisseAuswahlTyp>());
        expect(result[0].kuerzel, equals('WA'));
        verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
      });

      test('getBedAuswahlTypById returns type when found', () async {
        final mockResponse = [
          {'id': 1, 'kuerzel': 'WA', 'beschreibung': 'Waffenart'},
        ];
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getBedAuswahlTypById(1);
        expect(result, isNotNull);
        expect(result, isA<BeduerfnisseAuswahlTyp>());
        expect(result!.kuerzel, equals('WA'));
      });

      test('getBedAuswahlTypById returns null when not found', () async {
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.getBedAuswahlTypById(999);
        expect(result, isNull);
      });

    });

    group('bed_auswahl Service Methods', () {

      test('getBedAuswahlList returns list of entries', () async {
        final mockResponse = [
          {'id': 1, 'typ_id': 1, 'kuerzel': 'PIS', 'beschreibung': 'Pistole'},
          {'id': 2, 'typ_id': 1, 'kuerzel': 'REV', 'beschreibung': 'Revolver'},
        ];
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getBedAuswahlList();
        expect(result, hasLength(2));
        expect(result[0], isA<BeduerfnisseAuswahl>());
        expect(result[0].kuerzel, equals('PIS'));
      });

      test('getBedAuswahlByTypId returns filtered list', () async {
        final mockResponse = [
          {'id': 1, 'typ_id': 1, 'kuerzel': 'PIS', 'beschreibung': 'Pistole'},
        ];
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getBedAuswahlByTypId(1);
        expect(result, hasLength(1));
        expect(result[0], isA<BeduerfnisseAuswahl>());
        expect(result[0].typId, equals(1));
      });

      test('getBedAuswahlById returns entry when found', () async {
        final mockResponse = [
          {'id': 1, 'typ_id': 1, 'kuerzel': 'PIS', 'beschreibung': 'Pistole'},
        ];
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getBedAuswahlById(1);
        expect(result, isNotNull);
        expect(result, isA<BeduerfnisseAuswahl>());
        expect(result!.kuerzel, equals('PIS'));
      });

    });

    group('bed_datei Service Methods', () {
      test('createBedDatei creates file entry successfully', () async {
        final mockResponse = [
          {'id': 1, 'antragsnummer': 100000, 'dateiname': 'doc.pdf'},
        ];
        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 201));

        final result = await service.createBedDatei(
          antragsnummer: 100000,
          dateiname: 'doc.pdf',
          fileBytes: [1, 2, 3, 4, 5],
        );

        expect(result, equals(mockResponse[0]));
        verify(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(1);
      });

      test('getBedDateiByAntragsnummer returns list of files', () async {
        final mockResponse = [
          {'id': 1, 'antragsnummer': 100000, 'dateiname': 'doc1.pdf', 'file_bytes': []},
          {'id': 2, 'antragsnummer': 100000, 'dateiname': 'doc2.pdf', 'file_bytes': []},
        ];
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getBedDateiByAntragsnummer(100000);
        expect(result, hasLength(2));
        expect(result[0].dateiname, equals('doc1.pdf'));
        expect(result[0].antragsnummer, equals(100000));
      });


      test('updateBedDatei updates file entry successfully', () async {
        when(
          mockClient.patch(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('[]', 200));

        final datei = BeduerfnisseDatei(
          id: 1,
          antragsnummer: 100000,
          dateiname: 'new.pdf',
          fileBytes: [],
        );
        final result = await service.updateBedDatei(datei);
        expect(result, isTrue);
      });

      test('deleteBedDatei soft deletes file entry successfully', () async {
        when(
          mockClient.patch(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.deleteBedDatei(100000);
        expect(result, isTrue);
      });
    });

    group('bed_sport Service Methods', () {
      test('createBedSport creates sport record successfully', () async {
        final mockResponse = [
          {
            'id': 1,
            'antragsnummer': 100000,
            'schiessdatum': '2024-01-01',
            'waffenart_id': 1,
            'disziplin_id': 2,
            'training': true,
          },
        ];
        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 201));

        final result = await service.createBedSport(
          antragsnummer: 100000,
          schiessdatum: '2024-01-01',
          waffenartId: 1,
          disziplinId: 2,
          training: true,
        );

        expect(result, equals(mockResponse[0]));
        verify(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(1);
      });

      test('createBedSport includes optional parameters', () async {
        final mockResponse = [
          {
            'id': 1,
            'antragsnummer': 100000,
            'wettkampfart_id': 5,
            'wettkampfergebnis': 95.5,
          },
        ];
        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 201));

        final result = await service.createBedSport(
          antragsnummer: 100000,
          schiessdatum: '2024-01-01',
          waffenartId: 1,
          disziplinId: 2,
          training: false,
          wettkampfartId: 5,
          wettkampfergebnis: 95.5,
        );

        expect(result['wettkampfart_id'], equals(5));
        expect(result['wettkampfergebnis'], equals(95.5));
      });

      test('getBedSportByAntragsnummer returns list of records', () async {
        final mockResponse = [
          {
            'id': 1,
            'antragsnummer': 100000,
            'schiessdatum': '2024-01-01T00:00:00Z',
            'waffenart_id': 1,
            'disziplin_id': 2,
            'training': true,
          },
          {
            'id': 2,
            'antragsnummer': 100000,
            'schiessdatum': '2024-01-02T00:00:00Z',
            'waffenart_id': 1,
            'disziplin_id': 2,
            'training': false,
          },
        ];
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getBedSportByAntragsnummer(100000);
        expect(result, hasLength(2));
        expect(result[0].antragsnummer, equals(100000));
        expect(result[0].training, equals(true));
      });


      test('updateBedSport updates record successfully', () async {
        when(
          mockClient.patch(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('[]', 200));

        final sport = BeduerfnisseSport(
          id: 1,
          antragsnummer: 100000,
          schiessdatum: DateTime.now(),
          waffenartId: 1,
          disziplinId: 2,
          training: false,
        );
        final result = await service.updateBedSport(sport);
        expect(result, isTrue);
      });

    });

    group('bed_waffe_besitz Service Methods', () {
      test('createBedWaffeBesitz creates weapon record successfully', () async {
        final mockResponse = [
          {
            'id': 1,
            'antragsnummer': 100000,
            'wbk_nr': 'WBK001',
            'lfd_wbk': '001',
            'waffenart_id': 1,
            'kaliber_id': 2,
            'kompensator': false,
          },
        ];
        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 201));

        final result = await service.createBedWaffeBesitz(
          antragsnummer: 100000,
          wbkNr: 'WBK001',
          lfdWbk: '001',
          waffenartId: 1,
          kaliberId: 2,
          kompensator: false,
        );

        expect(result, equals(mockResponse[0]));
        verify(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(1);
      });

      test('createBedWaffeBesitz includes optional parameters', () async {
        final mockResponse = [
          {
            'id': 1,
            'antragsnummer': 100000,
            'hersteller': 'TestManufacturer',
            'gewicht': '1.5kg',
            'bemerkung': 'Test note',
          },
        ];
        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 201));

        final result = await service.createBedWaffeBesitz(
          antragsnummer: 100000,
          wbkNr: 'WBK001',
          lfdWbk: '001',
          waffenartId: 1,
          kaliberId: 2,
          kompensator: false,
          hersteller: 'TestManufacturer',
          gewicht: '1.5kg',
          bemerkung: 'Test note',
        );

        expect(result['hersteller'], equals('TestManufacturer'));
        expect(result['gewicht'], equals('1.5kg'));
      });

      test(
        'getBedWaffeBesitzByAntragsnummer returns list of weapons',
        () async {
          final mockResponse = [
            {
              'id': 1,
              'antragsnummer': 100000,
              'wbk_nr': 'WBK001',
              'lfd_wbk': '001',
              'waffenart_id': 1,
              'kaliber_id': 2,
              'kompensator': false,
            },
            {
              'id': 2,
              'antragsnummer': 100000,
              'wbk_nr': 'WBK002',
              'lfd_wbk': '002',
              'waffenart_id': 1,
              'kaliber_id': 2,
              'kompensator': false,
            },
          ];
          when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
            (_) async => http.Response(jsonEncode(mockResponse), 200),
          );

          final result = await service.getBedWaffeBesitzByAntragsnummer(100000);
          expect(result, hasLength(2));
          expect(result[0].antragsnummer, equals(100000));
          expect(result[0].wbkNr, equals('WBK001'));
        },
      );


      test('updateBedWaffeBesitz updates weapon record successfully', () async {
        when(
          mockClient.patch(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('[]', 200));

        final waffeBesitz = BeduerfnisseWaffeBesitz(
          id: 1,
          antragsnummer: 100000,
          wbkNr: 'WBK001',
          lfdWbk: '001',
          waffenartId: 1,
          kaliberId: 2,
          kompensator: true,
        );
        final result = await service.updateBedWaffeBesitz(waffeBesitz);
        expect(result, isTrue);
      });

    });

    group('bed_antrag_status Service Methods', () {
      test('createBedAntragStatus creates entry successfully', () async {
        final mockResponse = [
          {'id': 1, 'status': 'offen', 'beschreibung': 'Antrag eingegangen'},
        ];
        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 201));

        final result = await service.createBedAntragStatus(
          status: 'offen',
          beschreibung: 'Antrag eingegangen',
        );

        expect(result, isA<BeduerfnisseAntragStatus>());
        expect(result.id, equals(1));
        expect(result.status, equals('offen'));
        expect(result.beschreibung, equals('Antrag eingegangen'));
        verify(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(1);
      });

      test('createBedAntragStatus throws exception on failure', () async {
        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('Error', 400));

        expect(
          () => service.createBedAntragStatus(
            status: 'offen',
            beschreibung: 'Antrag eingegangen',
          ),
          throwsException,
        );
      });

      test('getBedAntragStatusList returns list of statuses', () async {
        final mockResponse = [
          {'id': 1, 'status': 'offen', 'beschreibung': 'Antrag eingegangen'},
          {'id': 2, 'status': 'bearbeitung', 'beschreibung': 'In Bearbeitung'},
        ];
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getBedAntragStatusList();
        expect(result, hasLength(2));
        expect(result[0], isA<BeduerfnisseAntragStatus>());
        expect(result[0].status, equals('offen'));
        verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
      });
    });

    group('bed_antrag Service Methods', () {
      test('createBedAntrag creates entry successfully', () async {
        final mockResponse = [
          {
            'id': 1,
            'antragsnummer': 100000,
            'person_id': 100,
            'status_id': 1,
            'wbk_neu': true,
            'wbk_art': 'gelb',
            'beduerfnisart': 'langwaffe',
            'anzahl_waffen': 2,
            'verein_genehmigt': false,
            'email': 'test@example.com',
            'abbuchung_erfolgt': false,
          },
        ];
        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 201));

        final result = await service.createBedAntrag(
          personId: 100,
          statusId: BeduerfnisAntragStatus.entwurf,
          wbkNeu: true,
          wbkArt: 'gelb',
          beduerfnisart: 'langwaffe',
          anzahlWaffen: 2,
          email: 'test@example.com',
        );

        expect(result, isA<BeduerfnisseAntrag>());
        expect(result.id, equals(1));
        expect(result.antragsnummer, equals(100000));
        expect(result.personId, equals(100));
        verify(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(1);
      });

      test('createBedAntrag throws exception on failure', () async {
        when(
          mockClient.post(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('Error', 400));

        expect(
          () => service.createBedAntrag(personId: 100),
          throwsException,
        );
      });


      test('getBedAntragByAntragsnummer returns filtered list', () async {
        final mockResponse = [
          {'id': 1, 'antragsnummer': 100000, 'person_id': 100},
        ];
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getBedAntragByAntragsnummer(100000);
        expect(result, hasLength(1));
        expect(result[0], isA<BeduerfnisseAntrag>());
        expect(result[0].antragsnummer, equals(100000));
      });

      test('getBedAntragByPersonId returns filtered list', () async {
        final mockResponse = [
          {'id': 1, 'antragsnummer': 100000, 'person_id': 100},
          {'id': 2, 'antragsnummer': 100001, 'person_id': 100},
        ];
        when(
          mockClient.get(any, headers: anyNamed('headers')),
        ).thenAnswer((_) async => http.Response(jsonEncode(mockResponse), 200));

        final result = await service.getBedAntragByPersonId(100);
        expect(result, hasLength(2));
        expect(result[0], isA<BeduerfnisseAntrag>());
        expect(result[0].personId, equals(100));
      });

      test('updateBedAntrag updates entry successfully', () async {
        when(
          mockClient.patch(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('[]', 200));

        final antrag = BeduerfnisseAntrag(
          id: 1,
          antragsnummer: 100000,
          personId: 100,
          vereinGenehmigt: true,
        );
        final result = await service.updateBedAntrag(antrag);
        expect(result, isTrue);
        verify(
          mockClient.patch(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(1);
      });

      test('updateBedAntrag returns false on error', () async {
        when(
          mockClient.patch(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('Error', 500));

        final antrag = BeduerfnisseAntrag(
          id: 1,
          antragsnummer: 100000,
          personId: 100,
          vereinGenehmigt: true,
        );
        final result = await service.updateBedAntrag(antrag);
        expect(result, isFalse);
      });

      test('deleteBedAntrag soft deletes entry successfully', () async {
        when(
          mockClient.patch(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).thenAnswer((_) async => http.Response('[]', 200));

        final result = await service.deleteBedAntrag(100000);
        expect(result, isTrue);
        verify(
          mockClient.patch(
            any,
            headers: anyNamed('headers'),
            body: anyNamed('body'),
          ),
        ).called(1);
      });
    });
  });
}
