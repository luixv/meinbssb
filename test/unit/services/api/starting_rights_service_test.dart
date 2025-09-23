import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:meinbssb/services/api/starting_rights_service.dart';
import 'package:meinbssb/services/api/user_service.dart';
import 'package:meinbssb/services/api/verein_service.dart';
import 'package:meinbssb/services/core/email_service.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/zweitmitgliedschaft_data.dart';
import 'package:meinbssb/models/passdaten_akzept_or_aktiv_data.dart';
import 'package:meinbssb/models/verein_data.dart';

@GenerateMocks([
  UserService,
  VereinService,
  EmailService,
])
import 'starting_rights_service_test.mocks.dart';

void main() {
  group('StartingRightsService', () {
    late StartingRightsService startingRightsService;
    late MockUserService mockUserService;
    late MockVereinService mockVereinService;
    late MockEmailService mockEmailService;

    setUp(() {
      mockUserService = MockUserService();
      mockVereinService = MockVereinService();
      mockEmailService = MockEmailService();
      
      startingRightsService = StartingRightsService(
        userService: mockUserService,
        vereinService: mockVereinService,
        emailService: mockEmailService,
      );
    });

    test('can be instantiated with dependencies', () {
      expect(startingRightsService, isNotNull);
      expect(startingRightsService, isA<StartingRightsService>());
    });

    group('sendStartingRightsChangeNotifications', () {
      const int testPersonId = 12345;
      
      late UserData testUserData;
      late List<ZweitmitgliedschaftData> testZweitmitgliedschaften;
      late PassdatenAkzeptOrAktiv testZveData;
      late List<Verein> testVereinData;

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

        testVereinData = [
          const Verein(
            id: 101,
            vereinsNr: 100,
            name: 'Test Verein',
            email: 'contact@testverein.de',
            pEmail: 'president@testverein.de',
          ),
        ];
      });

      test('successfully sends notifications with complete data', () async {
        // Arrange
        when(mockUserService.fetchPassdaten(testPersonId))
            .thenAnswer((_) async => testUserData);
        when(mockEmailService.getEmailAddressesByPersonId(testPersonId.toString()))
            .thenAnswer((_) async => ['user@example.com']);
        when(mockUserService.fetchZweitmitgliedschaften(testPersonId))
            .thenAnswer((_) async => testZweitmitgliedschaften);
        when(mockUserService.fetchPassdatenAkzeptierterOderAktiverPass(testPersonId))
            .thenAnswer((_) async => testZveData);
        when(mockVereinService.fetchVerein(100))
            .thenAnswer((_) async => testVereinData);
        when(mockVereinService.fetchVerein(200))
            .thenAnswer((_) async => [
              const Verein(
                id: 201,
                vereinsNr: 200,
                name: 'Second Club',
                email: 'info@secondclub.de',
              ),
            ],);
        when(mockEmailService.sendStartingRightsChangeNotifications(
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
        verify(mockUserService.fetchPassdaten(testPersonId)).called(1);
        verify(mockEmailService.getEmailAddressesByPersonId(testPersonId.toString())).called(1);
        verify(mockUserService.fetchZweitmitgliedschaften(testPersonId)).called(1);
        verify(mockUserService.fetchPassdatenAkzeptierterOderAktiverPass(testPersonId)).called(1);
        verify(mockVereinService.fetchVerein(100)).called(1);
        verify(mockVereinService.fetchVerein(200)).called(1);
        verify(mockEmailService.sendStartingRightsChangeNotifications(
          personId: testPersonId,
          passdaten: testUserData,
          userEmailAddresses: ['user@example.com'],
          clubEmailAddresses: ['contact@testverein.de', 'president@testverein.de', 'info@secondclub.de'],
          zweitmitgliedschaften: testZweitmitgliedschaften,
          zveData: testZveData,
        ),).called(1);
      });

      test('returns early when passdaten is null', () async {
        // Arrange
        when(mockUserService.fetchPassdaten(testPersonId))
            .thenAnswer((_) async => null);

        // Act
        await startingRightsService.sendStartingRightsChangeNotifications(
          personId: testPersonId,
        );

        // Assert
        verify(mockUserService.fetchPassdaten(testPersonId)).called(1);
        verifyNever(mockEmailService.getEmailAddressesByPersonId(any));
        verifyNever(mockUserService.fetchZweitmitgliedschaften(any));
        verifyNever(mockUserService.fetchPassdatenAkzeptierterOderAktiverPass(any));
        verifyNever(mockVereinService.fetchVerein(any));
        verifyNever(mockEmailService.sendStartingRightsChangeNotifications(
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
        when(mockUserService.fetchPassdaten(testPersonId))
            .thenAnswer((_) async => testUserData);
        when(mockEmailService.getEmailAddressesByPersonId(testPersonId.toString()))
            .thenAnswer((_) async => ['user@example.com']);
        when(mockUserService.fetchZweitmitgliedschaften(testPersonId))
            .thenAnswer((_) async => []);
        when(mockUserService.fetchPassdatenAkzeptierterOderAktiverPass(testPersonId))
            .thenAnswer((_) async => testZveData);
        when(mockVereinService.fetchVerein(100))
            .thenAnswer((_) async => []); // Empty club data
        when(mockEmailService.sendStartingRightsChangeNotifications(
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
        verify(mockEmailService.sendStartingRightsChangeNotifications(
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
        when(mockUserService.fetchPassdaten(testPersonId))
            .thenAnswer((_) async => testUserData);
        when(mockEmailService.getEmailAddressesByPersonId(testPersonId.toString()))
            .thenAnswer((_) async => ['user@example.com']);
        when(mockUserService.fetchZweitmitgliedschaften(testPersonId))
            .thenAnswer((_) async => []);
        when(mockUserService.fetchPassdatenAkzeptierterOderAktiverPass(testPersonId))
            .thenAnswer((_) async => testZveData);
        when(mockVereinService.fetchVerein(100))
            .thenAnswer((_) async => [
              const Verein(
                id: 101,
                vereinsNr: 100,
                name: 'Test Verein',
                email: null, // null email
                pEmail: '', // empty email
              ),
            ],);
        when(mockEmailService.sendStartingRightsChangeNotifications(
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
        verify(mockEmailService.sendStartingRightsChangeNotifications(
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
        when(mockUserService.fetchPassdaten(testPersonId))
            .thenAnswer((_) async => testUserData);
        when(mockEmailService.getEmailAddressesByPersonId(testPersonId.toString()))
            .thenAnswer((_) async => ['user@example.com']);
        when(mockUserService.fetchZweitmitgliedschaften(testPersonId))
            .thenAnswer((_) async => []);
        when(mockUserService.fetchPassdatenAkzeptierterOderAktiverPass(testPersonId))
            .thenAnswer((_) async => testZveData);
        when(mockVereinService.fetchVerein(100))
            .thenAnswer((_) async => [
              const Verein(
                id: 101,
                vereinsNr: 100,
                name: 'Test Verein',
                email: 'null', // "null" string
                pEmail: 'valid@email.com',
              ),
            ],);
        when(mockEmailService.sendStartingRightsChangeNotifications(
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
        verify(mockEmailService.sendStartingRightsChangeNotifications(
          personId: testPersonId,
          passdaten: testUserData,
          userEmailAddresses: ['user@example.com'],
          clubEmailAddresses: ['valid@email.com'], // Only valid email should remain
          zweitmitgliedschaften: [],
          zveData: testZveData,
        ),).called(1);
      });
      test('handles multiple clubs with different email configurations', () async {
        // Arrange
        final multipleZweitmitgliedschaften = [
          ZweitmitgliedschaftData(
            vereinId: 201,
            vereinNr: 200,
            vereinName: 'Second Club',
            eintrittVerein: DateTime(2020, 1, 1),
          ),
          ZweitmitgliedschaftData(
            vereinId: 301,
            vereinNr: 300,
            vereinName: 'Third Club',
            eintrittVerein: DateTime(2021, 1, 1),
          ),
        ];

        when(mockUserService.fetchPassdaten(testPersonId))
            .thenAnswer((_) async => testUserData);
        when(mockEmailService.getEmailAddressesByPersonId(testPersonId.toString()))
            .thenAnswer((_) async => ['user@example.com']);
        when(mockUserService.fetchZweitmitgliedschaften(testPersonId))
            .thenAnswer((_) async => multipleZweitmitgliedschaften);
        when(mockUserService.fetchPassdatenAkzeptierterOderAktiverPass(testPersonId))
            .thenAnswer((_) async => testZveData);
        
        // First club - has both emails
        when(mockVereinService.fetchVerein(100))
            .thenAnswer((_) async => [
              const Verein(
                id: 101,
                vereinsNr: 100,
                name: 'Test Verein',
                email: 'contact@testverein.de',
                pEmail: 'president@testverein.de',
              ),
            ],);
        
        // Second club - has only one email
        when(mockVereinService.fetchVerein(200))
            .thenAnswer((_) async => [
              const Verein(
                id: 201,
                vereinsNr: 200,
                name: 'Second Club',
                email: 'info@secondclub.de',
                pEmail: null,
              ),
            ],);
        
        // Third club - has no emails
        when(mockVereinService.fetchVerein(300))
            .thenAnswer((_) async => [
              const Verein(
                id: 301,
                vereinsNr: 300,
                name: 'Third Club',
                email: null,
                pEmail: null,
              ),
            ],);

        when(mockEmailService.sendStartingRightsChangeNotifications(
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
        verify(mockVereinService.fetchVerein(100)).called(1);
        verify(mockVereinService.fetchVerein(200)).called(1);
        verify(mockVereinService.fetchVerein(300)).called(1);
        verify(mockEmailService.sendStartingRightsChangeNotifications(
          personId: testPersonId,
          passdaten: testUserData,
          userEmailAddresses: ['user@example.com'],
          clubEmailAddresses: [
            'contact@testverein.de',
            'president@testverein.de',
            'info@secondclub.de',
          ],
          zweitmitgliedschaften: multipleZweitmitgliedschaften,
          zveData: testZveData,
        ),).called(1);
      });

      test('handles user with no email addresses', () async {
        // Arrange
        when(mockUserService.fetchPassdaten(testPersonId))
            .thenAnswer((_) async => testUserData);
        when(mockEmailService.getEmailAddressesByPersonId(testPersonId.toString()))
            .thenAnswer((_) async => []); // No user email addresses
        when(mockUserService.fetchZweitmitgliedschaften(testPersonId))
            .thenAnswer((_) async => []);
        when(mockUserService.fetchPassdatenAkzeptierterOderAktiverPass(testPersonId))
            .thenAnswer((_) async => testZveData);
        when(mockVereinService.fetchVerein(100))
            .thenAnswer((_) async => testVereinData);
        when(mockEmailService.sendStartingRightsChangeNotifications(
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
        verify(mockEmailService.sendStartingRightsChangeNotifications(
          personId: testPersonId,
          passdaten: testUserData,
          userEmailAddresses: [], // Empty user email list
          clubEmailAddresses: ['contact@testverein.de', 'president@testverein.de'],
          zweitmitgliedschaften: [],
          zveData: testZveData,
        ),).called(1);
      });

      test('handles duplicate email addresses in club data', () async {
        // Arrange
        when(mockUserService.fetchPassdaten(testPersonId))
            .thenAnswer((_) async => testUserData);
        when(mockEmailService.getEmailAddressesByPersonId(testPersonId.toString()))
            .thenAnswer((_) async => ['user@example.com']);
        when(mockUserService.fetchZweitmitgliedschaften(testPersonId))
            .thenAnswer((_) async => []);
        when(mockUserService.fetchPassdatenAkzeptierterOderAktiverPass(testPersonId))
            .thenAnswer((_) async => testZveData);
        when(mockVereinService.fetchVerein(100))
            .thenAnswer((_) async => [
              const Verein(
                id: 101,
                vereinsNr: 100,
                name: 'Test Verein',
                email: 'same@email.com', // Same email in both fields
                pEmail: 'same@email.com',
              ),
            ],);
        when(mockEmailService.sendStartingRightsChangeNotifications(
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
        verify(mockEmailService.sendStartingRightsChangeNotifications(
          personId: testPersonId,
          passdaten: testUserData,
          userEmailAddresses: ['user@example.com'],
          clubEmailAddresses: ['same@email.com', 'same@email.com'], // Duplicates are allowed as per current implementation
          zweitmitgliedschaften: [],
          zveData: testZveData,
        ),).called(1);
      });
    });
  });
}
