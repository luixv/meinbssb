import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:meinbssb/services/core/email_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/services/core/http_client.dart';
import 'package:meinbssb/services/core/calendar_service.dart';

@GenerateMocks([
  ConfigService,
  HttpClient,
  CalendarService,
  EmailSender,
])
import 'email_service_test.mocks.dart';

// Mock Response class for http client
class MockResponse extends Mock implements http.Response {

  MockResponse({
    required this.statusCode,
    this.body = '{"success": true}',
  });
  @override
  final int statusCode;
  @override
  final String body;
}

void main() {
  late EmailService emailService;
  late MockConfigService mockConfigService;
  late MockHttpClient mockHttpClient;
  late MockCalendarService mockCalendarService;
  late MockEmailSender mockEmailSender;

  setUp(() {
    mockConfigService = MockConfigService();
    mockHttpClient = MockHttpClient();
    mockCalendarService = MockCalendarService();
    mockEmailSender = MockEmailSender();

    emailService = EmailService(
      emailSender: mockEmailSender,
      configService: mockConfigService,
      httpClient: mockHttpClient,
      calendarService: mockCalendarService,
    );
  });

  group('EmailService', () {
    group('sendEmail', () {
      test('uses original recipient when test emails are disabled', () async {
        // Setup
        when(mockConfigService.getBool('testEmails')).thenReturn(false);
        when(mockConfigService.getString('webProtocol')).thenReturn('https');
        when(mockConfigService.getString('email')).thenReturn('email.example.com');
        
        // Execute
        await emailService.sendEmail(
          sender: 'sender@example.com',
          recipient: 'test@example.com',
          subject: 'Test Subject',
          htmlBody: '<p>Test Body</p>',
        );

        // Verify that the original recipient was used
        verify(mockConfigService.getBool('testEmails')).called(1);
        verifyNever(mockConfigService.getString('testRecipient'));
      });

      test('uses test recipient when test emails are enabled', () async {
        // Setup
        when(mockConfigService.getBool('testEmails')).thenReturn(true);
        when(mockConfigService.getString('testRecipient'))
            .thenReturn('test-recipient@example.com');
        when(mockConfigService.getString('webProtocol')).thenReturn('https');
        when(mockConfigService.getString('email')).thenReturn('email.example.com');
        
        // Execute
        await emailService.sendEmail(
          sender: 'sender@example.com',
          recipient: 'original@example.com',
          subject: 'Test Subject',
          htmlBody: '<p>Test Body</p>',
        );

        // Verify that the test recipient was used
        verify(mockConfigService.getBool('testEmails')).called(1);
        verify(mockConfigService.getString('testRecipient')).called(1);
      });
    });

    group('sendEmail', () {
      setUp(() {
        // Common setup for email tests
        when(mockConfigService.getBool('testEmails')).thenReturn(false);
        when(mockConfigService.getString('webProtocol')).thenReturn('https');
        when(mockConfigService.getString('email')).thenReturn('email.example.com');
      });
      test('handles email sending failure gracefully', () async {
        // Mock failed HTTP response
        when(mockHttpClient.post(
          any,
          any,
          overrideBaseUrl: anyNamed('overrideBaseUrl'),
        ),).thenThrow(Exception('Failed to send email: Server error'));

        // Execute
        final result = await emailService.sendEmail(
          sender: 'sender@example.com',
          recipient: 'recipient@example.com',
          subject: 'Test Subject',
          htmlBody: '<p>Test Body</p>',
        );

        // Verify
        expect(result['ResultType'], equals(0));
        expect(result['ResultMessage'], contains('Error sending email'));
      });
    });

    group('getEmailAddressesByPersonId', () {
      test('returns list of email addresses from API response', () async {
        // Setup
        final mockResponse = [
          {'MAILADRESSEN': 'email1@example.com', 'LOGINMAIL': 'login1@example.com'},
          {'MAILADRESSEN': 'email2@example.com', 'LOGINMAIL': null},
          {'MAILADRESSEN': null, 'LOGINMAIL': 'login2@example.com'},
        ];
        when(mockHttpClient.get(any))
            .thenAnswer((_) async => mockResponse);

        // Execute
        final result = await emailService.getEmailAddressesByPersonId('123');

        // Verify
        expect(result, containsAll([
          'email1@example.com',
          'login1@example.com',
          'email2@example.com',
          'login2@example.com',
        ]),);
        verify(mockHttpClient.get('FindeMailadressen/123')).called(1);
      });

      test('filters out null and empty email addresses', () async {
        // Setup
        final mockResponse = [
          {'MAILADRESSEN': '', 'LOGINMAIL': 'null'},
          {'MAILADRESSEN': null, 'LOGINMAIL': ''},
          {'MAILADRESSEN': 'valid@example.com', 'LOGINMAIL': null},
        ];
        when(mockHttpClient.get(any))
            .thenAnswer((_) async => mockResponse);

        // Execute
        final result = await emailService.getEmailAddressesByPersonId('123');

        // Verify
        expect(result, equals(['valid@example.com']));
        verify(mockHttpClient.get('FindeMailadressen/123')).called(1);
      });

      test('returns empty list on API error', () async {
        // Setup
        when(mockHttpClient.get(any))
            .thenThrow(Exception('API Error'));

        // Execute
        final result = await emailService.getEmailAddressesByPersonId('123');

        // Verify
        expect(result, isEmpty);
        verify(mockHttpClient.get('FindeMailadressen/123')).called(1);
      });
    });

    group('Email Template Methods', () {
      test('getRegistrationSubject returns configured subject', () async {
        when(mockConfigService.getString('registrationSubject', 'emailContent'))
            .thenReturn('Registration Subject');
        
        final result = await emailService.getRegistrationSubject();
        expect(result, equals('Registration Subject'));
      });

      test('getFromEmail returns configured email', () async {
        when(mockConfigService.getString('fromEmail', 'smtpSettings'))
            .thenReturn('noreply@example.com');
        
        final result = await emailService.getFromEmail();
        expect(result, equals('noreply@example.com'));
      });

      test('getEmailValidationSubject returns hardcoded subject', () async {
        final result = await emailService.getEmailValidationSubject();
        expect(result, equals('E-Mail-Adresse bestätigen'));
      });

      test('getStartingRightsChangeSubject returns hardcoded subject', () async {
        final result = await emailService.getStartingRightsChangeSubject();
        expect(result, equals('Anfrage zur Änderung des Schützenausweises eingegangen'));
      });
    });
  });
}