import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mailer/mailer.dart' as mailer;
import 'package:meinbssb/services/core/email_service.dart';
import 'package:meinbssb/services/core/config_service.dart';
import 'package:meinbssb/services/core/http_client.dart';
import 'email_service_test.mocks.dart';

@GenerateMocks([EmailSender, ConfigService, HttpClient])
void main() {
  group('EmailService', () {
    late MockEmailSender mockEmailSender;
    late MockConfigService mockConfigService;
    late MockHttpClient mockHttpClient;
    late EmailService emailService;

    setUp(() {
      mockEmailSender = MockEmailSender();
      mockConfigService = MockConfigService();
      mockHttpClient = MockHttpClient();
      emailService = EmailService(
        emailSender: mockEmailSender,
        configService: mockConfigService,
        httpClient: mockHttpClient,
      );

      // Default config stubs
      when(mockConfigService.getString('host', 'smtpSettings'))
          .thenReturn('smtp.example.com');
      when(mockConfigService.getString('username', 'smtpSettings'))
          .thenReturn('user@example.com');
      when(mockConfigService.getString('password', 'smtpSettings'))
          .thenReturn('password123');
    });

    group('sendEmail', () {
      test('returns success when email is sent', () async {
        // Arrange
        final testMessage = mailer.Message()
          ..from = const mailer.Address('test@example.com')
          ..recipients.add('recipient@example.com')
          ..subject = 'Test'
          ..text = 'Test body';

        when(mockEmailSender.send(any, any)).thenAnswer(
          (_) async => mailer.SendReport(
            testMessage,
            DateTime.now(),
            DateTime.now(),
            DateTime.now(),
          ),
        );

        // Act
        final result = await emailService.sendEmail(
          from: 'from@example.com',
          recipient: 'recipient@example.com',
          subject: 'Subject',
          htmlBody: 'Body',
        );

        // Assert
        expect(result['ResultType'], 1);
        expect(result['ResultMessage'], contains('Email sent successfully'));
        verify(mockEmailSender.send(any, any)).called(1);
      });

      test('returns failure when SMTP config is missing', () async {
        // Arrange
        when(mockConfigService.getString('host', 'smtpSettings'))
            .thenReturn(null);
        when(mockConfigService.getString('username', 'smtpSettings'))
            .thenReturn(null);
        when(mockConfigService.getString('password', 'smtpSettings'))
            .thenReturn(null);

        // Act
        final result = await emailService.sendEmail(
          from: 'from@example.com',
          recipient: 'recipient@example.com',
          subject: 'Subject',
          htmlBody: 'Body',
        );

        // Assert
        expect(result['ResultType'], 0);
        expect(
          result['ResultMessage'],
          contains('SMTP settings are not fully configured'),
        );
        verifyNever(mockEmailSender.send(any, any));
      });

      test('returns error when email sending fails', () async {
        // Arrange
        when(mockEmailSender.send(any, any))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await emailService.sendEmail(
          from: 'from@example.com',
          recipient: 'recipient@example.com',
          subject: 'Subject',
          htmlBody: 'Body',
        );

        // Assert
        expect(result['ResultType'], 0);
        expect(result['ResultMessage'], contains('Error sending email'));
        verify(mockEmailSender.send(any, any)).called(1);
      });
    });

    group('getEmailAddressesByPersonId', () {
      test('returns list of email addresses when found', () async {
        // Arrange
        const personId = '123';
        final expectedEmails = ['test1@example.com', 'test2@example.com'];
        when(mockHttpClient.get('FindeMailadressen/$personId')).thenAnswer(
          (_) async => expectedEmails,
        );

        // Act
        final result = await emailService.getEmailAddressesByPersonId(personId);

        // Assert
        expect(result, equals(expectedEmails));
        verify(mockHttpClient.get('FindeMailadressen/$personId')).called(1);
      });

      test('returns empty list when no emails found', () async {
        // Arrange
        const personId = '123';
        when(mockHttpClient.get('FindeMailadressen/$personId'))
            .thenAnswer((_) async => []);

        // Act
        final result = await emailService.getEmailAddressesByPersonId(personId);

        // Assert
        expect(result, isEmpty);
        verify(mockHttpClient.get('FindeMailadressen/$personId')).called(1);
      });

      test('returns empty list on error', () async {
        // Arrange
        const personId = '123';
        when(mockHttpClient.get('FindeMailadressen/$personId'))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await emailService.getEmailAddressesByPersonId(personId);

        // Assert
        expect(result, isEmpty);
        verify(mockHttpClient.get('FindeMailadressen/$personId')).called(1);
      });
    });

    group('sendAccountCreationNotifications', () {
      const personId = '123';
      const registeredEmail = 'new@example.com';

      setUp(() {
        // Default stubs for email templates
        when(mockConfigService.getString('fromEmail', 'smtpSettings'))
            .thenReturn('noreply@example.com');
        when(mockConfigService.getString('accountCreatedSubject', 'emailContent'))
            .thenReturn('Account Created');
        when(mockConfigService.getString('accountCreatedContent', 'emailContent'))
            .thenReturn('New account created with email: {email}');

        // Default stub for email sending
        when(mockEmailSender.send(any, any)).thenAnswer(
          (_) async => mailer.SendReport(
            mailer.Message(),
            DateTime.now(),
            DateTime.now(),
            DateTime.now(),
          ),
        );
      });

      test('sends notifications to all associated email addresses', () async {
        // Arrange
        final existingEmails = ['existing1@example.com', 'existing2@example.com'];
        when(mockHttpClient.get('FindeMailadressen/$personId'))
            .thenAnswer((_) async => existingEmails);

        // Act
        await emailService.sendAccountCreationNotifications(
          personId,
          registeredEmail,
        );

        // Assert
        verify(mockHttpClient.get('FindeMailadressen/$personId')).called(1);
        verify(mockEmailSender.send(any, any)).called(2); // Two emails sent
      });

      test('handles missing email configuration gracefully', () async {
        // Arrange
        when(mockConfigService.getString('fromEmail', 'smtpSettings'))
            .thenReturn(null);
        when(mockHttpClient.get('FindeMailadressen/$personId'))
            .thenAnswer((_) async => ['existing@example.com']);

        // Act
        await emailService.sendAccountCreationNotifications(
          personId,
          registeredEmail,
        );

        // Assert
        verify(mockHttpClient.get('FindeMailadressen/$personId')).called(1);
        verifyNever(mockEmailSender.send(any, any)); // No emails sent
      });

      test('skips invalid email addresses', () async {
        // Arrange
        when(mockHttpClient.get('FindeMailadressen/$personId'))
            .thenAnswer((_) async => ['null', '', 'valid@example.com']);

        // Act
        await emailService.sendAccountCreationNotifications(
          personId,
          registeredEmail,
        );

        // Assert
        verify(mockHttpClient.get('FindeMailadressen/$personId')).called(1);
        verify(mockEmailSender.send(any, any))
            .called(1); // Only one valid email sent
      });
    });
  });
} 