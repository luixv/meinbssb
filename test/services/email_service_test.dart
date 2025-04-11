import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mailer/mailer.dart';
import 'package:mein_bssb/services/email_service.dart';
import 'package:mein_bssb/services/config_service.dart';
import 'dart:io';

// Create a Mock for ConfigService
class MockConfigService extends Mock implements ConfigService {}

// Create a Mock for the send function from mailer package
class MockMailer extends Mock {
  Future<SendReport> send(Message message, SmtpServer server) async {
    return Future.value(SendReport('OK', null, null));
  }
}

void main() {
  late EmailService emailService;
  late MockConfigService mockConfigService;
  late MockMailer mockMailer;

  setUp(() {
    mockConfigService = MockConfigService();
    mockMailer = MockMailer();
    // Replace the global send function with our mock for testing
    // This is a bit tricky as 'send' is a top-level function.
    // A better approach in a real application might be to inject
    // the mailer functionality into EmailService.
    // For this test, we'll try to work around it.
    // One way is to mock the entire 'mailer' library, but for simplicity,
    // we'll focus on the ConfigService and the EmailService logic.
    emailService = EmailService();
    // We'll need to manually control the behavior of ConfigService in each test.
  });

  group('EmailService', () {
    group('sendEmail', () {
      test('should return success if email is sent successfully', () async {
        // Configure ConfigService to return valid SMTP settings
        when(mockConfigService.getString('host', 'smtpSettings'))
            .thenReturn('smtp.example.com');
        when(mockConfigService.getString('username', 'smtpSettings'))
            .thenReturn('test@example.com');
        when(mockConfigService.getString('password', 'smtpSettings'))
            .thenReturn('password');

        // Replace the static ConfigService instance with our mock
        EmailService().configService = mockConfigService;

        final result = await emailService.sendEmail(
          from: 'sender@example.com',
          recipient: 'recipient@example.com',
          subject: 'Test Subject',
          body: 'Test Body',
          emailId: 123,
        );

        expect(result['ResultType'], 1);
        expect(result['ResultMessage'], 'Email sent successfully');
        // We can't easily verify that the 'send' function was called
        // without a more robust mocking strategy for the mailer package.
      });

      test('should return failure if SMTP settings are not fully configured', () async {
        // Configure ConfigService to return null for host
        when(mockConfigService.getString('host', 'smtpSettings')).thenReturn(null);
        when(mockConfigService.getString('username', 'smtpSettings'))
            .thenReturn('test@example.com');
        when(mockConfigService.getString('password', 'smtpSettings'))
            .thenReturn('password');

        // Replace the static ConfigService instance with our mock
        EmailService().configService = mockConfigService;

        final result = await emailService.sendEmail(
          from: 'sender@example.com',
          recipient: 'recipient@example.com',
          subject: 'Test Subject',
          body: 'Test Body',
          emailId: 123,
        );

        expect(result['ResultType'], 0);
        expect(result['ResultMessage'], 'SMTP settings are not fully configured.');
      });

      test('should return failure if sending email throws a SocketException', () async {
        // Configure ConfigService to return valid SMTP settings
        when(mockConfigService.getString('host', 'smtpSettings'))
            .thenReturn('smtp.example.com');
        when(mockConfigService.getString('username', 'smtpSettings'))
            .thenReturn('test@example.com');
        when(mockConfigService.getString('password', 'smtpSettings'))
            .thenReturn('password');

        // Replace the static ConfigService instance with our mock
        EmailService().configService = mockConfigService;

        // Force the 'send' function to throw a SocketException
        final EmailService errorService = EmailService();
        errorService._sendFunction = (Message message, SmtpServer server) async {
          throw SocketException('Failed to connect', osError: OSError('Network is unreachable', 101));
        };

        final result = await errorService.sendEmail(
          from: 'sender@example.com',
          recipient: 'recipient@example.com',
          subject: 'Test Subject',
          body: 'Test Body',
          emailId: 123,
        );

        expect(result['ResultType'], 0);
        expect(result['ResultMessage'],
            'Error sending email: Failed to connect (OS Error: Network is unreachable, errno = 101)');
      });

      test('should return generic error message for other exceptions', () async {
        // Configure ConfigService to return valid SMTP settings
        when(mockConfigService.getString('host', 'smtpSettings'))
            .thenReturn('smtp.example.com');
        when(mockConfigService.getString('username', 'smtpSettings'))
            .thenReturn('test@example.com');
        when(mockConfigService.getString('password', 'smtpSettings'))
            .thenReturn('password');

        // Replace the static ConfigService instance with our mock
        EmailService().configService = mockConfigService;

        // Force the 'send' function to throw a generic Exception
        final EmailService errorService = EmailService();
        errorService._sendFunction = (Message message, SmtpServer server) async {
          throw Exception('Something went wrong');
        };

        final result = await errorService.sendEmail(
          from: 'sender@example.com',
          recipient: 'recipient@example.com',
          subject: 'Test Subject',
          body: 'Test Body',
          emailId: 123,
        );

        expect(result['ResultType'], 0);
        expect(result['ResultMessage'], 'Error sending email: Exception: Something went wrong');
      });
    });

    group('getRegistrationSubject', () {
      test('should return the registration subject from ConfigService', () async {
        const expectedSubject = 'Welcome to Mein BSSB!';
        when(mockConfigService.getString('registrationSubject', 'smtpSettings'))
            .thenReturn(expectedSubject);

        // Replace the static ConfigService instance with our mock
        EmailService().configService = mockConfigService;

        final subject = await emailService.getRegistrationSubject();
        expect(subject, expectedSubject);
        verify(mockConfigService.getString('registrationSubject', 'smtpSettings'))
            .called(1);
      });

      test('should return null if registration subject is not configured', () async {
        when(mockConfigService.getString('registrationSubject', 'smtpSettings'))
            .thenReturn(null);

        // Replace the static ConfigService instance with our mock
        EmailService().configService = mockConfigService;

        final subject = await emailService.getRegistrationSubject();
        expect(subject, isNull);
        verify(mockConfigService.getString('registrationSubject', 'smtpSettings'))
            .called(1);
      });
    });

    group('getRegistrationContent', () {
      test('should return the registration content from ConfigService', () async {
        const expectedContent = 'Thank you for registering!';
        when(mockConfigService.getString('registrationContent', 'smtpSettings'))
            .thenReturn(expectedContent);

        // Replace the static ConfigService instance with our mock
        EmailService().configService = mockConfigService;

        final content = await emailService.getRegistrationContent();
        expect(content, expectedContent);
        verify(mockConfigService.getString('registrationContent', 'smtpSettings'))
            .called(1);
      });

      test('should return null if registration content is not configured', () async {
        when(mockConfigService.getString('registrationContent', 'smtpSettings'))
            .thenReturn(null);

        // Replace the static ConfigService instance with our mock
        EmailService().configService = mockConfigService;

        final content = await emailService.getRegistrationContent();
        expect(content, isNull);
        verify(mockConfigService.getString('registrationContent', 'smtpSettings'))
            .called(1);
      });
    });

    group('getFromEmail', () {
      test('should return the from email from ConfigService', () async {
        const expectedFromEmail = 'no-reply@meinbssb.com';
        when(mockConfigService.getString('fromEmail', 'smtpSettings'))
            .thenReturn(expectedFromEmail);

        // Replace the static ConfigService instance with our mock
        EmailService().configService = mockConfigService;

        final fromEmail = await emailService.getFromEmail();
        expect(fromEmail, expectedFromEmail);
        verify(mockConfigService.getString('fromEmail', 'smtpSettings')).called(1);
      });

      test('should return null if from email is not configured', () async {
        when(mockConfigService.getString('fromEmail', 'smtpSettings'))
            .thenReturn(null);

        // Replace the static ConfigService instance with our mock
        EmailService().configService = mockConfigService;

        final fromEmail = await emailService.getFromEmail();
        expect(fromEmail, isNull);
        verify(mockConfigService.getString('fromEmail', 'smtpSettings')).called(1);
      });
    });
  });
}

// A workaround to mock the top-level 'send' function.
// In a real application, consider dependency injection.
extension EmailServiceTestExtension on EmailService {
  // Provide a setter for a custom send function for testing
  Future<SendReport> Function(Message message, SmtpServer server)? _sendFunction;

  Future<SendReport> send(Message message, SmtpServer server) async {
    if (_sendFunction != null) {
      return _sendFunction!(message, server);
    }
    return mailer.send(message, server);
  }

  // Expose the ConfigService instance for testing purposes
  set configService(ConfigService service) {
    _configService = service;
  }
}