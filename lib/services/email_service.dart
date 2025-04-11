// Project: Mein BSSB
// Filename: email_service.dart
// Author: Luis Mandel / NTT DATA

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter/material.dart';
import '/services/config_service.dart';

class EmailService {
  Future<Map<String, dynamic>> sendEmail({
    required String from,
    required String recipient,
    required String subject,
    String? body,
    int? emailId,
  }) async {
    debugPrint("sendEmail called with emailId: $emailId");

    try {
      final smtpHost = ConfigService.getString('host', 'smtpSettings');
      final username = ConfigService.getString('username', 'smtpSettings');
      final password = ConfigService.getString('password', 'smtpSettings');

      if (smtpHost == null || username == null || password == null) {
        debugPrint('SMTP settings are not fully configured in config.json.');
        return {
          "ResultType": 0,
          "ResultMessage": "SMTP settings are not fully configured.",
        };
      }

      final smtpServer = SmtpServer(
        smtpHost,
        username: username,
        password: password,
      );

      final message =
          Message()
            ..from = Address(from)
            ..recipients.add(recipient)
            ..subject = subject
            ..text = body;

      final sendReport = await send(message, smtpServer);
      debugPrint('Message sent: ${sendReport.toString()}');

      return {"ResultType": 1, "ResultMessage": "Email sent successfully"};
    } catch (e) {
      String errorMessage = "Error sending email: $e";
      if (e is SocketException) {
        errorMessage =
            "Error sending email: ${e.message} (OS Error: ${e.osError}, errno = ${e.osError?.errorCode})";
      }

      debugPrint('Email sending failed: $errorMessage');
      return {"ResultType": 0, "ResultMessage": errorMessage};
    }
  }

  Future<String?> getRegistrationSubject() async {
    return ConfigService.getString('registrationSubject', 'smtpSettings');
  }

  Future<String?> getRegistrationContent() async {
    return ConfigService.getString('registrationContent', 'smtpSettings');
  }

  Future<String?> getFromEmail() async {
    return ConfigService.getString('fromEmail', 'smtpSettings');
  }
}
