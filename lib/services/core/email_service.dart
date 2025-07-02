// Project: Mein BSSB
// Filename: email_service.dart
// Author: Luis Mandel / NTT DATA

import 'dart:io';
import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart' as smtp;
import 'config_service.dart';
import 'logger_service.dart';

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
  })  : _emailSender = emailSender,
        _configService = configService;
  final EmailSender _emailSender;
  final ConfigService _configService; // Inject ConfigService

  Future<Map<String, dynamic>> sendEmail({
    required String from,
    required String recipient,
    required String subject,
    String? body,
    int? emailId,
  }) async {
    LoggerService.logInfo('sendEmail called with emailId: $emailId');
    LoggerService.logInfo('sendEmail called with from: $from');
    LoggerService.logInfo('sendEmail called with recipient: $recipient');
    LoggerService.logInfo('sendEmail called with subject: $subject');
    LoggerService.logInfo('sendEmail called with body: $body');

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
      );

      final message = mailer.Message()
        ..from = mailer.Address(from)
        ..recipients.add(recipient)
        ..subject = subject
        ..text = body;

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
    return _configService.getString('registrationContent', 'smtpSettings');
  }

  Future<String?> getFromEmail() async {
    return _configService.getString('fromEmail', 'smtpSettings');
  }
}
