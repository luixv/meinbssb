import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mailer/mailer.dart';
import 'package:meinbssb/services/email_service.dart';
import 'package:meinbssb/services/config_service.dart';
import 'email_service_test.mocks.dart';

@GenerateMocks([EmailSender, ConfigService])
void main() {
  group('EmailService', () {
    late MockEmailSender mockEmailSender;
    late MockConfigService mockConfigService;
    late EmailService emailService;

    setUp(() {
      mockEmailSender = MockEmailSender();
      mockConfigService = MockConfigService();
      emailService = EmailService(
        emailSender: mockEmailSender,
        configService: mockConfigService,
      );
    });

    test('sendEmail returns success when email is sent', () async {
      // Arrange
      when(
        mockConfigService.getString('host', 'smtpSettings'),
      ).thenReturn('smtp.example.com');
      when(
        mockConfigService.getString('username', 'smtpSettings'),
      ).thenReturn('user@example.com');
      when(
        mockConfigService.getString('password', 'smtpSettings'),
      ).thenReturn('pass');

      when(mockEmailSender.send(any, any)).thenAnswer(
        (_) async => FakeSendReport(
          Message(),
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
        body: 'Body',
      );

      // Assert
      expect(result['ResultType'], 1);
      expect(result['ResultMessage'], contains('Email sent successfully'));
      verify(mockEmailSender.send(any, any)).called(1);
    });

    test('sendEmail returns failure when SMTP config is missing', () async {
      // Arrange
      when(
        mockConfigService.getString('host', 'smtpSettings'),
      ).thenReturn(null);
      when(
        mockConfigService.getString('username', 'smtpSettings'),
      ).thenReturn(null);
      when(
        mockConfigService.getString('password', 'smtpSettings'),
      ).thenReturn(null);

      // Act
      final result = await emailService.sendEmail(
        from: 'from@example.com',
        recipient: 'recipient@example.com',
        subject: 'Subject',
        body: 'Body',
      );

      // Assert
      expect(result['ResultType'], 0);
      expect(
        result['ResultMessage'],
        contains('SMTP settings are not fully configured'),
      );
    });

    test('sendEmail catches exceptions and returns error', () async {
      // Arrange
      when(
        mockConfigService.getString('host', 'smtpSettings'),
      ).thenReturn('smtp.example.com');
      when(
        mockConfigService.getString('username', 'smtpSettings'),
      ).thenReturn('user@example.com');
      when(
        mockConfigService.getString('password', 'smtpSettings'),
      ).thenReturn('password123');

      when(
        mockEmailSender.send(any, any),
      ).thenThrow(Exception('Network error'));

      // Act
      final result = await emailService.sendEmail(
        from: 'from@example.com',
        recipient: 'recipient@example.com',
        subject: 'Subject',
        body: 'Body',
      );

      // Assert
      expect(result['ResultType'], 0);
      expect(result['ResultMessage'], contains('Error sending email'));
    });
  });
}

class FakeSendReport extends SendReport {
  FakeSendReport(
    Message mail,
    DateTime connectionOpened,
    DateTime messageSendingStart,
    DateTime messageSendingEnd,
  ) : super(mail, connectionOpened, messageSendingStart, messageSendingEnd);
}
