// Project: Mein BSSB
// Filename: email_service.dart
// Author: Luis Mandel / NTT DATA

import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart' as smtp;
import 'config_service.dart';
import 'logger_service.dart';
import 'http_client.dart';
import 'calendar_service.dart';

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
    CalendarService? calendarService,
  })  : _emailSender = emailSender,
        _configService = configService,
        _httpClient = httpClient,
        _calendarService = calendarService;

  final EmailSender _emailSender;
  final ConfigService _configService; // Inject ConfigService
  final HttpClient _httpClient;
  final CalendarService? _calendarService;

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
      final smtpPort = _configService.getString('port', 'smtpSettings');
      final ssl = _configService.getString('ssl', 'smtpSettings');
      final allowInsecure =
          _configService.getString('allowInsecure', 'smtpSettings');
      final ignoreBadCertificate =
          _configService.getString('ignoreBadCertificate', 'smtpSettings');

      if (smtpHost == null) {
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
        port: int.parse(smtpPort!),
        ssl: bool.parse(ssl!),
        allowInsecure: bool.parse(allowInsecure!),
        ignoreBadCertificate: bool.parse(ignoreBadCertificate!),
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
    return _configService.getString('registrationSubject', 'emailContent');
  }

  Future<String?> getRegistrationContent() async {
    try {
      return await rootBundle.loadString('assets/html/registrationEmail.html');
    } catch (e) {
      LoggerService.logError('Error reading registrationEmail.html: $e');
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

  Future<String?> getEmaiProtocol() async {
    return _configService.getString('emailProtocol', 'smtpSettings');
  }

  Future<String?> getAccountCreatedSubject() async {
    return _configService.getString('accountCreatedSubject', 'emailContent');
  }

  Future<String?> getAccountCreatedContent() async {
    try {
      return await rootBundle
          .loadString('assets/html/accountCreatedEmail.html');
    } catch (e) {
      LoggerService.logError('Error reading accountCreatedEmail.html: $e');
      return null;
    }
  }

  Future<String?> getSchulungAbmeldungSubject() async {
    return _configService.getString('schulungAbmeldungSubject', 'emailContent');
  }

  Future<String?> getSchulungAbmeldungContent() async {
    try {
      return await rootBundle
          .loadString('assets/html/schulungAbmeldungEmail.html');
    } catch (e) {
      LoggerService.logError('Error reading schulungAbmeldungEmail.html: $e');
      return null;
    }
  }

  Future<String?> getSchulungAnmeldungSubject() async {
    return _configService.getString('schulungAnmeldungSubject', 'emailContent');
  }

  Future<String?> getSchulungAnmeldungContent() async {
    try {
      return await rootBundle
          .loadString('assets/html/schulungAnmeldungEmail.html');
    } catch (e) {
      LoggerService.logError('Error reading schulungAnmeldungEmail.html: $e');
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

  Future<void> sendSchulungAbmeldungEmail({
    required String personId,
    required String schulungName,
    required String schulungDate,
    required String firstName,
    required String lastName,
  }) async {
    try {
      // Get all email addresses for this person
      final emailAddresses = await getEmailAddressesByPersonId(personId);

      if (emailAddresses.isEmpty) {
        LoggerService.logWarning(
          'No email addresses found for person ID: $personId',
        );
        return;
      }

      // Get email template and subject
      final fromEmail = await getFromEmail();
      final subject = await getSchulungAbmeldungSubject();
      final emailContent = await getSchulungAbmeldungContent();

      if (fromEmail == null || subject == null || emailContent == null) {
        LoggerService.logError(
          'Email configuration missing for training unregistration notification',
        );
        return;
      }

      // Replace placeholders in the email content
      final personalizedContent = emailContent
          .replaceAll('{schulung_name}', schulungName)
          .replaceAll('{schulung_date}', schulungDate)
          .replaceAll('{firstname}', firstName)
          .replaceAll('{lastname}', lastName);

      // Send email to all addresses
      for (final emailAddress in emailAddresses) {
        try {
          await sendEmail(
            from: fromEmail,
            recipient: emailAddress,
            subject: subject,
            htmlBody: personalizedContent,
          );
          LoggerService.logInfo(
            'Sent training unregistration notification to: $emailAddress',
          );
        } catch (e) {
          LoggerService.logError(
            'Failed to send training unregistration notification to $emailAddress: $e',
          );
        }
      }

      LoggerService.logInfo('Sent training unregistration notification emails');
    } catch (e) {
      LoggerService.logError(
        'Error sending training unregistration notifications: $e',
      );
    }
  }

  Future<void> sendSchulungAnmeldungEmail({
    required String personId,
    required String schulungName,
    required String schulungDate,
    required String firstName,
    required String lastName,
    required String passnumber,
    required String email,
    required int schulungRegistered,
    required int schulungTotal,
    String? location,
    DateTime? eventDateTime,
  }) async {
    try {
      // Get email template and subject
      final fromEmail = await getFromEmail();
      final subject = await getSchulungAnmeldungSubject();
      final emailContent = await getSchulungAnmeldungContent();

      if (fromEmail == null || subject == null || emailContent == null) {
        LoggerService.logError(
          'Email configuration missing for training registration notification',
        );
        return;
      }

      // Generate calendar link if CalendarService is available
      String calendarLink = '#';
      if (_calendarService != null && eventDateTime != null) {
        try {
          calendarLink = await _calendarService.generateCalendarLink(
            eventTitle: schulungName,
            eventDate: eventDateTime,
            location: location ?? 'BSSB Schulung',
            description:
                'Schulung: $schulungName\nTeilnehmer: $firstName $lastName\nPassnummer: $passnumber',
            organizerEmail: fromEmail,
          );
        } catch (e) {
          LoggerService.logError('Error generating calendar link: $e');
          calendarLink = '#';
        }
      }

      // Replace placeholders in the email content
      final personalizedContent = emailContent
          .replaceAll('{schulung_name}', schulungName)
          .replaceAll('{schulung_date}', schulungDate)
          .replaceAll('{firstname}', firstName)
          .replaceAll('{lastname}', lastName)
          .replaceAll('{passnumber}', passnumber)
          .replaceAll('{email}', email)
          .replaceAll('{schulung_registered}', schulungRegistered.toString())
          .replaceAll('{schulung_total}', schulungTotal.toString())
          .replaceAll('{calendar_link}', calendarLink);

      // Send email to the provided email address
      try {
        await sendEmail(
          from: fromEmail,
          recipient: email,
          subject: subject,
          htmlBody: personalizedContent,
        );
        LoggerService.logInfo(
          'Sent training registration notification to: $email',
        );
      } catch (e) {
        LoggerService.logError(
          'Failed to send training registration notification to $email: $e',
        );
      }

      LoggerService.logInfo('Sent training registration notification email');
    } catch (e) {
      LoggerService.logError(
        'Error sending training registration notification: $e',
      );
    }
  }
}
