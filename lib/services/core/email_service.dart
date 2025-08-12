// Project: Mein BSSB
// Filename: email_service.dart
// Author: Luis Mandel / NTT DATA

import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
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
  })  : _configService = configService,
        _httpClient = httpClient,
        _calendarService = calendarService;

  final ConfigService _configService; // Inject ConfigService
  final HttpClient _httpClient;
  final CalendarService? _calendarService;

  Future<Map<String, dynamic>> sendEmail({
    required String sender,
    required String recipient,
    required String subject,
    String? htmlBody,
    int? emailId,
  }) async {
    try {
      final emailUrl = ConfigService.buildBaseUrlForServer(
        _configService,
        name: 'email',
        protocolKey: 'webProtocol',
      );
      final response = await http.post(
        Uri.parse(emailUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'to': recipient,
          'subject': subject,
          'html': htmlBody,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        LoggerService.logInfo('Email sent successfully!');
      } else {
        LoggerService.logInfo('Failed to send email: ${response.statusCode}');
      }
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

  Future<String?> getPasswordResetSubject() async {
    return _configService.getString('passwordResetSubject', 'emailContent');
  }

  Future<String?> getPasswordResetContent() async {
    try {
      return await rootBundle.loadString('assets/html/passwordReset.html');
    } catch (e) {
      LoggerService.logError('Error reading passwordReset.html: $e');
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
        // Parse the response to extract MAILADRESSEN from each object
        final List<String> emailAddresses = [];
        for (final item in response) {
          if (item is Map<String, dynamic> && item['MAILADRESSEN'] != null) {
            final email = item['MAILADRESSEN'].toString();
            if (email.isNotEmpty && email != 'null') {
              emailAddresses.add(email);
            }
          }
          if (item is Map<String, dynamic> && item['LOGINMAIL'] != null) {
            final email = item['LOGINMAIL'].toString();
            if (email.isNotEmpty && email != 'null') {
              emailAddresses.add(email);
            }
          }
        }
        LoggerService.logInfo(
          'Found ${emailAddresses.length} email addresses for person $personId: $emailAddresses',
        );
        return emailAddresses;
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

      LoggerService.logInfo('Got these email addresses: $emailAddresses');

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

      // Send email to the newly registered email
      final emailBody = emailContent.replaceAll('{email}', registeredEmail);
      LoggerService.logInfo('Sending email to $registeredEmail');
      LoggerService.logInfo(emailBody);
      await sendEmail(
        sender: fromEmail,
        recipient: registeredEmail,
        subject: subject,
        htmlBody: emailBody,
      );

      // Send notification to each email address
      for (final email in emailAddresses) {
        if (email.isNotEmpty && email != 'null' && email != registeredEmail) {
          final emailBody = emailContent.replaceAll('{email}', email);
          LoggerService.logInfo('Sending email to $email');
          LoggerService.logInfo(emailBody);
          await sendEmail(
            sender: fromEmail,
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

  Future<void> sendPasswordResetNotifications(
    Map<String, dynamic> passData,
    List<String> emailAddresses,
    String verificationLink,
  ) async {
    try {
      LoggerService.logInfo('Got these email addresses: $emailAddresses');

      // Get email template and subject
      final fromEmail = await getFromEmail();
      final subject = await getPasswordResetSubject();
      final emailContent = await getPasswordResetContent();

      if (fromEmail == null || subject == null || emailContent == null) {
        LoggerService.logError(
          'Email configuration missing for account creation notification',
        );
        return;
      }

      // Send notification to each email address
      for (final email in emailAddresses) {
        final emailBody = emailContent
            .replaceAll('{email}', email)
            .replaceAll('{title}', passData['TITEL'] ?? '')
            .replaceAll('{firstName}', passData['VORNAME'] ?? '')
            .replaceAll('{lastName}', passData['NAMEN'] ?? '')
            .replaceAll('{verificationLink}', verificationLink);
        LoggerService.logInfo('Sending email to $email');
        LoggerService.logInfo(emailBody);
        await sendEmail(
          sender: fromEmail,
          recipient: email,
          subject: subject,
          htmlBody: emailBody,
        );
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
            sender: fromEmail,
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

  Future<void> sendRegistrationEmail({
    required String email,
    required String firstName,
    required String lastName,
    required String verificationLink,
  }) async {
    try {
      // Get email template and subject
      final fromEmail = await getFromEmail();
      final subject = await getRegistrationSubject();
      final emailContent = await getRegistrationContent();

      if (fromEmail == null || subject == null || emailContent == null) {
        LoggerService.logError(
          'Email configuration missing for registration notification',
        );
        return;
      }

      // Replace placeholders in the email content
      final emailBody = emailContent
          .replaceAll('{firstName}', firstName)
          .replaceAll('{lastName}', lastName)
          .replaceAll('{verificationLink}', verificationLink);

      // Send email
      await sendEmail(
        sender: fromEmail,
        recipient: email,
        subject: subject,
        htmlBody: emailBody,
      );

      LoggerService.logInfo('Sent registration email to: $email');
    } catch (e) {
      LoggerService.logError('Error sending registration email: $e');
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
          sender: fromEmail,
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
