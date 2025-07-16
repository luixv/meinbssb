// Project: Mein BSSB
// Filename: email_service.dart
// Author: Luis Mandel / NTT DATA

import 'dart:io';
import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart' as smtp;
import 'config_service.dart';
import 'logger_service.dart';
import 'http_client.dart';

abstract class EmailSender {
  Future<mailer.SendReport> send(
    mailer.Message message,
    smtp.SmtpServer server,
  );
}

class MailerEmailSender implements EmailSender {
  @override
  Future<mailer.SendReport> send(
    mailer.Message message,
    smtp.SmtpServer server,
  ) async {
    return await mailer.send(message, server);
  }
}

class EmailService {
  EmailService({
    required EmailSender emailSender,
    required ConfigService configService,
    required HttpClient httpClient,
  })  : _emailSender = emailSender,
        _configService = configService,
        _httpClient = httpClient;

  final EmailSender _emailSender;
  final ConfigService _configService; // Inject ConfigService
  final HttpClient _httpClient;

  Future<Map<String, dynamic>> sendEmail({
    required String from,
    required String recipient,
    required String subject,
    String? htmlBody,
    int? emailId,
  }) async {
    LoggerService.logInfo('sendEmail called with emailId: $emailId');
    LoggerService.logInfo('sendEmail called with from: $from');
    LoggerService.logInfo('sendEmail called with recipient: $recipient');
    LoggerService.logInfo('sendEmail called with subject: $subject');
    LoggerService.logInfo('sendEmail called with htmlBody: $htmlBody');

    try {
      final smtpHost = _configService.getString('host', 'smtpSettings');
      final username = _configService.getString('username', 'smtpSettings');
      final password = _configService.getString('password', 'smtpSettings');

      if (smtpHost == null || username == null || password == null) {
        LoggerService.logWarning(
          'SMTP settings are not fully configured in config.json.',
        );
        return {
          'ResultType': 0,
          'ResultMessage': 'SMTP settings are not fully configured.',
        };
      }

      final smtpServer = smtp.SmtpServer(
        smtpHost,
        username: username,
        password: password,
        port: 1025,
        ssl: false,
        allowInsecure: true,
        ignoreBadCertificate: true,
      );

      final message = mailer.Message()
        ..from = mailer.Address(from)
        ..recipients.add(recipient)
        ..subject = subject
        ..html = htmlBody
        ..headers = {
          'Content-Type': 'text/html; charset=utf-8',
          'content-transfer-encoding': 'quoted-printable',
        };

      final sendReport = await _emailSender.send(message, smtpServer);
      LoggerService.logInfo('Message sent: ${sendReport.toString()}');

      return {'ResultType': 1, 'ResultMessage': 'Email sent successfully'};
    } catch (e) {
      String errorMessage = 'Error sending email: $e';
      if (e is SocketException) {
        errorMessage =
            'Error sending email: ${e.message} (OS Error: ${e.osError}, errno = ${e.osError?.errorCode})';
      }

      LoggerService.logInfo('Email sending failed: $errorMessage');
      return {'ResultType': 0, 'ResultMessage': errorMessage};
    }
  }

  Future<String?> getRegistrationSubject() async {
    return _configService.getString('registrationSubject', 'smtpSettings');
  }

  Future<String?> getRegistrationContent() async {
    try {
      return File('lib/html/registrationEmail.html').readAsString();
    } catch (e) {
      LoggerService.logError('Error reading accountCreatedEmail.html: $e');
      return null;
    }
  }

  Future<String?> getVerificationBaseUrl() async {
    return _configService.getString('verificationBaseUrl', 'smtpSettings');
  }

  Future<String?> getWelcomeSubject() async {
    return _configService.getString('welcomeSubject', 'smtpSettings');
  }

  Future<String?> getWelcomeContent() async {
    return _configService.getString('welcomeContent', 'smtpSettings');
  }

  Future<String?> getFromEmail() async {
    return _configService.getString('fromEmail', 'smtpSettings');
  }

  Future<String?> getAccountCreatedSubject() async {
    return _configService.getString('accountCreatedSubject', 'smtpSettings');
  }

  Future<String?> getAccountCreatedContent() async {
    try {
      return File('lib/html/accountCreatedEmail.html').readAsString();
    } catch (e) {
      LoggerService.logError('Error reading accountCreatedEmail.html: $e');
      return null;
    }
  }

  Future<List<String>> getEmailAddressesByPersonId(String personId) async {
    try {
      final response = await _httpClient.get('FindeMailadressen/$personId');
      if (response is List) {
        return response.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      LoggerService.logError('Error fetching email addresses: $e');
      return [];
    }
  }

  Future<void> sendAccountCreationNotifications(
    String personId,
    String registeredEmail,
  ) async {
    try {
      // Get all email addresses for this person
      final emailAddresses = await getEmailAddressesByPersonId(personId);

      // Get email template and subject
      final fromEmail = await getFromEmail();
      final subject = await getAccountCreatedSubject();
      final emailContent = await getAccountCreatedContent();

      if (fromEmail == null || subject == null || emailContent == null) {
        LoggerService.logError(
          'Email configuration missing for account creation notification',
        );
        return;
      }
      final emailBody = emailContent.replaceAll('{email}', registeredEmail);
      await sendEmail(
        from: fromEmail,
        recipient: registeredEmail,
        subject: subject,
        htmlBody: emailBody,
      );
      // Send notification to each email address
      for (final email in emailAddresses) {
        if (email.isNotEmpty && email != 'null') {
          final emailBody = emailContent.replaceAll('{email}', registeredEmail);

          await sendEmail(
            from: fromEmail,
            recipient: email,
            subject: subject,
            htmlBody: emailBody,
          );
        }
      }
    } catch (e) {
      LoggerService.logError(
        'Error sending account creation notifications: $e',
      );
    }
  }
}
