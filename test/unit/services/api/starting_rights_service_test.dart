import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:meinbssb/services/api/starting_rights_service.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/zweitmitgliedschaft_data.dart';
import 'package:meinbssb/models/passdaten_akzept_or_aktiv_data.dart';

@GenerateMocks([
  ApiService,
])
import 'starting_rights_service_test.mocks.dart';

void main() {
  group('StartingRightsService', () {
    late StartingRightsService startingRightsService;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      
      startingRightsService = StartingRightsService(
        apiService: mockApiService,
      );
    });

    test('can be instantiated with dependencies', () {
      expect(startingRightsService, isNotNull);
      expect(startingRightsService, isA<StartingRightsService>());
    });

    group('sendStartingRightsChangeNotifications', () {
      const int testPersonId = 12345;

      test('requires ApiService to be set before use', () async {
        // Arrange
        final serviceWithoutApi = StartingRightsService();
        
        // Act
        await serviceWithoutApi.sendStartingRightsChangeNotifications(
          personId: testPersonId,
        );
        
        // Assert - should return early without error
        // The service should handle null ApiService gracefully
      });
      
      late UserData testUserData;
      late List<ZweitmitgliedschaftData> testZweitmitgliedschaften;
      late PassdatenAkzeptOrAktiv testZveData;

      setUp(() {
        testUserData = const UserData(
          personId: testPersonId,
          webLoginId: 1001,
          passnummer: 'PASS123',
          vereinNr: 100,
          namen: 'Mustermann',
          vorname: 'Max',
          vereinName: 'Test Verein',
          passdatenId: 5001,
          mitgliedschaftId: 2001,
          erstVereinId: 100,
        );

        testZweitmitgliedschaften = [
          ZweitmitgliedschaftData(
            vereinId: 201,
            vereinNr: 200,
            vereinName: 'Second Club',
            eintrittVerein: DateTime(2020, 1, 1),
          ),
        ];

        testZveData = PassdatenAkzeptOrAktiv(
          passdatenId: 5001,
          passStatus: 1,
          digitalerPass: 1,
          personId: testPersonId,
          erstVereinId: 100,
          evVereinNr: 100,
        );
      });

      test('successfully sends notifications with complete data', () async {
        // Arrange
        when(mockApiService.fetchPassdaten(testPersonId))
            .thenAnswer((_) async => testUserData);
        when(mockApiService.getEmailAddressesByPersonId(testPersonId.toString()))
            .thenAnswer((_) async => ['user@example.com']);
        when(mockApiService.fetchZweitmitgliedschaften(testPersonId))
            .thenAnswer((_) async => testZweitmitgliedschaften);
        when(mockApiService.fetchPassdatenAkzeptierterOderAktiverPass(testPersonId))
            .thenAnswer((_) async => testZveData);
        
        // First club - has AMTSEMAIL
        when(mockApiService.fetchVereinFunktionaer(100, 1))
            .thenAnswer((_) async => [
              {
                'AMTSEMAIL': 'contact@testverein.de',
                'EMAILLIST': 'president@testverein.de',
              }
            ]);
        
        // Second club - has AMTSEMAIL
        when(mockApiService.fetchVereinFunktionaer(201, 1))
            .thenAnswer((_) async => [
              {
                'AMTSEMAIL': 'info@secondclub.de',
                'EMAILLIST': null,
              }
            ]);
        
        when(mockApiService.sendStartingRightsChangeNotifications(
          personId: anyNamed('personId'),
          passdaten: anyNamed('passdaten'),
          userEmailAddresses: anyNamed('userEmailAddresses'),
          clubEmailAddresses: anyNamed('clubEmailAddresses'),
          zweitmitgliedschaften: anyNamed('zweitmitgliedschaften'),
          zveData: anyNamed('zveData'),
        ),).thenAnswer((_) async {});

        // Act
        await startingRightsService.sendStartingRightsChangeNotifications(
          personId: testPersonId,
        );

        // Assert
        verify(mockApiService.fetchPassdaten(testPersonId)).called(1);
        verify(mockApiService.getEmailAddressesByPersonId(testPersonId.toString())).called(1);
        verify(mockApiService.fetchZweitmitgliedschaften(testPersonId)).called(1);
        verify(mockApiService.fetchPassdatenAkzeptierterOderAktiverPass(testPersonId)).called(1);
        verify(mockApiService.fetchVereinFunktionaer(100, 1)).called(1);
        verify(mockApiService.fetchVereinFunktionaer(201, 1)).called(1);
        verify(mockApiService.sendStartingRightsChangeNotifications(
          personId: testPersonId,
          passdaten: testUserData,
          userEmailAddresses: ['user@example.com'],
          clubEmailAddresses: ['contact@testverein.de', 'info@secondclub.de'],
          zweitmitgliedschaften: testZweitmitgliedschaften,
          zveData: testZveData,
        ),).called(1);
      });

      test('returns early when passdaten is null', () async {
        // Arrange
        when(mockApiService.fetchPassdaten(testPersonId))
            .thenAnswer((_) async => null);

        // Act
        await startingRightsService.sendStartingRightsChangeNotifications(
          personId: testPersonId,
        );

        // Assert
        verify(mockApiService.fetchPassdaten(testPersonId)).called(1);
        verifyNever(mockApiService.getEmailAddressesByPersonId(any));
        verifyNever(mockApiService.fetchZweitmitgliedschaften(any));
        verifyNever(mockApiService.fetchPassdatenAkzeptierterOderAktiverPass(any));
        verifyNever(mockApiService.fetchVereinFunktionaer(any, any));
        verifyNever(mockApiService.sendStartingRightsChangeNotifications(
          personId: anyNamed('personId'),
          passdaten: anyNamed('passdaten'),
          userEmailAddresses: anyNamed('userEmailAddresses'),
          clubEmailAddresses: anyNamed('clubEmailAddresses'),
          zweitmitgliedschaften: anyNamed('zweitmitgliedschaften'),
          zveData: anyNamed('zveData'),
        ),);
      });

      test('handles empty club data gracefully', () async {
        // Arrange
        when(mockApiService.fetchPassdaten(testPersonId))
            .thenAnswer((_) async => testUserData);
        when(mockApiService.getEmailAddressesByPersonId(testPersonId.toString()))
            .thenAnswer((_) async => ['user@example.com']);
        when(mockApiService.fetchZweitmitgliedschaften(testPersonId))
            .thenAnswer((_) async => []);
        when(mockApiService.fetchPassdatenAkzeptierterOderAktiverPass(testPersonId))
            .thenAnswer((_) async => testZveData);
        when(mockApiService.fetchVereinFunktionaer(100, 1))
            .thenAnswer((_) async => []); // Empty club data
        when(mockApiService.fetchVereinFunktionaer(100, 201))
            .thenAnswer((_) async => []); // Empty fallback
        when(mockApiService.sendStartingRightsChangeNotifications(
          personId: anyNamed('personId'),
          passdaten: anyNamed('passdaten'),
          userEmailAddresses: anyNamed('userEmailAddresses'),
          clubEmailAddresses: anyNamed('clubEmailAddresses'),
          zweitmitgliedschaften: anyNamed('zweitmitgliedschaften'),
          zveData: anyNamed('zveData'),
        ),).thenAnswer((_) async {});

        // Act
        await startingRightsService.sendStartingRightsChangeNotifications(
          personId: testPersonId,
        );

        // Assert
        verify(mockApiService.sendStartingRightsChangeNotifications(
          personId: testPersonId,
          passdaten: testUserData,
          userEmailAddresses: ['user@example.com'],
          clubEmailAddresses: [], // Should be empty due to no club data
          zweitmitgliedschaften: [],
          zveData: testZveData,
        ),).called(1);
      });

      test('filters out null, empty, and "null" email addresses', () async {
        // Arrange
        when(mockApiService.fetchPassdaten(testPersonId))
            .thenAnswer((_) async => testUserData);
        when(mockApiService.getEmailAddressesByPersonId(testPersonId.toString()))
            .thenAnswer((_) async => ['user@example.com']);
        when(mockApiService.fetchZweitmitgliedschaften(testPersonId))
            .thenAnswer((_) async => []);
        when(mockApiService.fetchPassdatenAkzeptierterOderAktiverPass(testPersonId))
            .thenAnswer((_) async => testZveData);
        when(mockApiService.fetchVereinFunktionaer(100, 1))
            .thenAnswer((_) async => [
              {
                'AMTSEMAIL': null, // null email
                'EMAILLIST': '', // empty email
              }
            ]);
        when(mockApiService.sendStartingRightsChangeNotifications(
          personId: anyNamed('personId'),
          passdaten: anyNamed('passdaten'),
          userEmailAddresses: anyNamed('userEmailAddresses'),
          clubEmailAddresses: anyNamed('clubEmailAddresses'),
          zweitmitgliedschaften: anyNamed('zweitmitgliedschaften'),
          zveData: anyNamed('zveData'),
        ),).thenAnswer((_) async {});

        // Act
        await startingRightsService.sendStartingRightsChangeNotifications(
          personId: testPersonId,
        );

        // Assert
        verify(mockApiService.sendStartingRightsChangeNotifications(
          personId: testPersonId,
          passdaten: testUserData,
          userEmailAddresses: ['user@example.com'],
          clubEmailAddresses: [], // Should be empty due to filtered emails
          zweitmitgliedschaften: [],
          zveData: testZveData,
        ),).called(1);
      });

      test('filters out "null" string email addresses', () async {
        // Arrange
        when(mockApiService.fetchPassdaten(testPersonId))
            .thenAnswer((_) async => testUserData);
        when(mockApiService.getEmailAddressesByPersonId(testPersonId.toString()))
            .thenAnswer((_) async => ['user@example.com']);
        when(mockApiService.fetchZweitmitgliedschaften(testPersonId))
            .thenAnswer((_) async => []);
        when(mockApiService.fetchPassdatenAkzeptierterOderAktiverPass(testPersonId))
            .thenAnswer((_) async => testZveData);
        when(mockApiService.fetchVereinFunktionaer(100, 1))
            .thenAnswer((_) async => [
              {
                'AMTSEMAIL': 'null', // "null" string
                'EMAILLIST': 'valid@email.com',
              }
            ]);
        when(mockApiService.sendStartingRightsChangeNotifications(
          personId: anyNamed('personId'),
          passdaten: anyNamed('passdaten'),
          userEmailAddresses: anyNamed('userEmailAddresses'),
          clubEmailAddresses: anyNamed('clubEmailAddresses'),
          zweitmitgliedschaften: anyNamed('zweitmitgliedschaften'),
          zveData: anyNamed('zveData'),
        ),).thenAnswer((_) async {});

        // Act
        await startingRightsService.sendStartingRightsChangeNotifications(
          personId: testPersonId,
        );

        // Assert
        verify(mockApiService.sendStartingRightsChangeNotifications(
          personId: testPersonId,
          passdaten: testUserData,
          userEmailAddresses: ['user@example.com'],
          clubEmailAddresses: [], // AMTSEMAIL is "null", EMAILLIST is not used when AMTSEMAIL exists
          zweitmitgliedschaften: [],
          zveData: testZveData,
        ),).called(1);
      });

      test('uses EMAILLIST when AMTSEMAIL is empty', () async {
        // Arrange
        when(mockApiService.fetchPassdaten(testPersonId))
            .thenAnswer((_) async => testUserData);
        when(mockApiService.getEmailAddressesByPersonId(testPersonId.toString()))
            .thenAnswer((_) async => ['user@example.com']);
        when(mockApiService.fetchZweitmitgliedschaften(testPersonId))
            .thenAnswer((_) async => []);
        when(mockApiService.fetchPassdatenAkzeptierterOderAktiverPass(testPersonId))
            .thenAnswer((_) async => testZveData);
        when(mockApiService.fetchVereinFunktionaer(100, 1))
            .thenAnswer((_) async => [
              {
                'AMTSEMAIL': '', // empty
                'EMAILLIST': 'fallback@email.com',
              }
            ]);
        when(mockApiService.sendStartingRightsChangeNotifications(
          personId: anyNamed('personId'),
          passdaten: anyNamed('passdaten'),
          userEmailAddresses: anyNamed('userEmailAddresses'),
          clubEmailAddresses: anyNamed('clubEmailAddresses'),
          zweitmitgliedschaften: anyNamed('zweitmitgliedschaften'),
          zveData: anyNamed('zveData'),
        ),).thenAnswer((_) async {});

        // Act
        await startingRightsService.sendStartingRightsChangeNotifications(
          personId: testPersonId,
        );

        // Assert
        verify(mockApiService.sendStartingRightsChangeNotifications(
          personId: testPersonId,
          passdaten: testUserData,
          userEmailAddresses: ['user@example.com'],
          clubEmailAddresses: ['fallback@email.com'], // Should use EMAILLIST when AMTSEMAIL is empty
          zweitmitgliedschaften: [],
          zveData: testZveData,
        ),).called(1);
      });

      test('parses comma-separated email addresses', () async {
        // Arrange
        when(mockApiService.fetchPassdaten(testPersonId))
            .thenAnswer((_) async => testUserData);
        when(mockApiService.getEmailAddressesByPersonId(testPersonId.toString()))
            .thenAnswer((_) async => ['user@example.com']);
        when(mockApiService.fetchZweitmitgliedschaften(testPersonId))
            .thenAnswer((_) async => []);
        when(mockApiService.fetchPassdatenAkzeptierterOderAktiverPass(testPersonId))
            .thenAnswer((_) async => testZveData);
        when(mockApiService.fetchVereinFunktionaer(100, 1))
            .thenAnswer((_) async => [
              {
                'AMTSEMAIL': 'email1@example.com,email2@example.com,email3@example.com',
                'EMAILLIST': null,
              }
            ]);
        when(mockApiService.sendStartingRightsChangeNotifications(
          personId: anyNamed('personId'),
          passdaten: anyNamed('passdaten'),
          userEmailAddresses: anyNamed('userEmailAddresses'),
          clubEmailAddresses: anyNamed('clubEmailAddresses'),
          zweitmitgliedschaften: anyNamed('zweitmitgliedschaften'),
          zveData: anyNamed('zveData'),
        ),).thenAnswer((_) async {});

        // Act
        await startingRightsService.sendStartingRightsChangeNotifications(
          personId: testPersonId,
        );

        // Assert
        verify(mockApiService.sendStartingRightsChangeNotifications(
          personId: testPersonId,
          passdaten: testUserData,
          userEmailAddresses: ['user@example.com'],
          clubEmailAddresses: [
            'email1@example.com',
            'email2@example.com',
            'email3@example.com',
          ],
          zweitmitgliedschaften: [],
          zveData: testZveData,
        ),).called(1);
      });

      test('parses semicolon-separated email addresses', () async {
        // Arrange
        when(mockApiService.fetchPassdaten(testPersonId))
            .thenAnswer((_) async => testUserData);
        when(mockApiService.getEmailAddressesByPersonId(testPersonId.toString()))
            .thenAnswer((_) async => ['user@example.com']);
        when(mockApiService.fetchZweitmitgliedschaften(testPersonId))
            .thenAnswer((_) async => []);
        when(mockApiService.fetchPassdatenAkzeptierterOderAktiverPass(testPersonId))
            .thenAnswer((_) async => testZveData);
        when(mockApiService.fetchVereinFunktionaer(100, 1))
            .thenAnswer((_) async => [
              {
                'AMTSEMAIL': 'email1@example.com;email2@example.com',
                'EMAILLIST': null,
              }
            ]);
        when(mockApiService.sendStartingRightsChangeNotifications(
          personId: anyNamed('personId'),
          passdaten: anyNamed('passdaten'),
          userEmailAddresses: anyNamed('userEmailAddresses'),
          clubEmailAddresses: anyNamed('clubEmailAddresses'),
          zweitmitgliedschaften: anyNamed('zweitmitgliedschaften'),
          zveData: anyNamed('zveData'),
        ),).thenAnswer((_) async {});

        // Act
        await startingRightsService.sendStartingRightsChangeNotifications(
          personId: testPersonId,
        );

        // Assert
        verify(mockApiService.sendStartingRightsChangeNotifications(
          personId: testPersonId,
          passdaten: testUserData,
          userEmailAddresses: ['user@example.com'],
          clubEmailAddresses: [
            'email1@example.com',
            'email2@example.com',
          ],
          zweitmitgliedschaften: [],
          zveData: testZveData,
        ),).called(1);
      });

      test('parses mixed comma and semicolon-separated email addresses', () async {
        // Arrange
        when(mockApiService.fetchPassdaten(testPersonId))
            .thenAnswer((_) async => testUserData);
        when(mockApiService.getEmailAddressesByPersonId(testPersonId.toString()))
            .thenAnswer((_) async => ['user@example.com']);
        when(mockApiService.fetchZweitmitgliedschaften(testPersonId))
            .thenAnswer((_) async => []);
        when(mockApiService.fetchPassdatenAkzeptierterOderAktiverPass(testPersonId))
            .thenAnswer((_) async => testZveData);
        when(mockApiService.fetchVereinFunktionaer(100, 1))
            .thenAnswer((_) async => [
              {
                'AMTSEMAIL': 'email1@example.com, email2@example.com; email3@example.com',
                'EMAILLIST': null,
              }
            ]);
        when(mockApiService.sendStartingRightsChangeNotifications(
          personId: anyNamed('personId'),
          passdaten: anyNamed('passdaten'),
          userEmailAddresses: anyNamed('userEmailAddresses'),
          clubEmailAddresses: anyNamed('clubEmailAddresses'),
          zweitmitgliedschaften: anyNamed('zweitmitgliedschaften'),
          zveData: anyNamed('zveData'),
        ),).thenAnswer((_) async {});

        // Act
        await startingRightsService.sendStartingRightsChangeNotifications(
          personId: testPersonId,
        );

        // Assert
        verify(mockApiService.sendStartingRightsChangeNotifications(
          personId: testPersonId,
          passdaten: testUserData,
          userEmailAddresses: ['user@example.com'],
          clubEmailAddresses: [
            'email1@example.com',
            'email2@example.com',
            'email3@example.com',
          ],
          zweitmitgliedschaften: [],
          zveData: testZveData,
        ),).called(1);
      });

      test('falls back to funktyp 201 when funktyp 1 returns empty', () async {
        // Arrange
        when(mockApiService.fetchPassdaten(testPersonId))
            .thenAnswer((_) async => testUserData);
        when(mockApiService.getEmailAddressesByPersonId(testPersonId.toString()))
            .thenAnswer((_) async => ['user@example.com']);
        when(mockApiService.fetchZweitmitgliedschaften(testPersonId))
            .thenAnswer((_) async => []);
        when(mockApiService.fetchPassdatenAkzeptierterOderAktiverPass(testPersonId))
            .thenAnswer((_) async => testZveData);
        when(mockApiService.fetchVereinFunktionaer(100, 1))
            .thenAnswer((_) async => []); // Empty result
        when(mockApiService.fetchVereinFunktionaer(100, 201))
            .thenAnswer((_) async => [
              {
                'AMTSEMAIL': 'fallback@example.com',
                'EMAILLIST': null,
              }
            ]);
        when(mockApiService.sendStartingRightsChangeNotifications(
          personId: anyNamed('personId'),
          passdaten: anyNamed('passdaten'),
          userEmailAddresses: anyNamed('userEmailAddresses'),
          clubEmailAddresses: anyNamed('clubEmailAddresses'),
          zweitmitgliedschaften: anyNamed('zweitmitgliedschaften'),
          zveData: anyNamed('zveData'),
        ),).thenAnswer((_) async {});

        // Act
        await startingRightsService.sendStartingRightsChangeNotifications(
          personId: testPersonId,
        );

        // Assert
        verify(mockApiService.fetchVereinFunktionaer(100, 1)).called(1);
        verify(mockApiService.fetchVereinFunktionaer(100, 201)).called(1);
        verify(mockApiService.sendStartingRightsChangeNotifications(
          personId: testPersonId,
          passdaten: testUserData,
          userEmailAddresses: ['user@example.com'],
          clubEmailAddresses: ['fallback@example.com'],
          zweitmitgliedschaften: [],
          zveData: testZveData,
        ),).called(1);
      });

      test('handles user with no email addresses', () async {
        // Arrange
        when(mockApiService.fetchPassdaten(testPersonId))
            .thenAnswer((_) async => testUserData);
        when(mockApiService.getEmailAddressesByPersonId(testPersonId.toString()))
            .thenAnswer((_) async => []); // No user email addresses
        when(mockApiService.fetchZweitmitgliedschaften(testPersonId))
            .thenAnswer((_) async => []);
        when(mockApiService.fetchPassdatenAkzeptierterOderAktiverPass(testPersonId))
            .thenAnswer((_) async => testZveData);
        when(mockApiService.fetchVereinFunktionaer(100, 1))
            .thenAnswer((_) async => [
              {
                'AMTSEMAIL': 'contact@testverein.de',
                'EMAILLIST': 'president@testverein.de',
              }
            ]);
        when(mockApiService.sendStartingRightsChangeNotifications(
          personId: anyNamed('personId'),
          passdaten: anyNamed('passdaten'),
          userEmailAddresses: anyNamed('userEmailAddresses'),
          clubEmailAddresses: anyNamed('clubEmailAddresses'),
          zweitmitgliedschaften: anyNamed('zweitmitgliedschaften'),
          zveData: anyNamed('zveData'),
        ),).thenAnswer((_) async {});

        // Act
        await startingRightsService.sendStartingRightsChangeNotifications(
          personId: testPersonId,
        );

        // Assert
        verify(mockApiService.sendStartingRightsChangeNotifications(
          personId: testPersonId,
          passdaten: testUserData,
          userEmailAddresses: [], // Empty user email list
          clubEmailAddresses: ['contact@testverein.de'],
          zweitmitgliedschaften: [],
          zveData: testZveData,
        ),).called(1);
      });
    });
  });
}
