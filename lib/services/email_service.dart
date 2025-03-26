// email_service.dart
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:meinbssb/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

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
      String smtpServerAddress = LocalizationService.getString('smtp');
      String username = LocalizationService.getString('smtp_username');
      String password = LocalizationService.getString('smtp_password');

      final smtpServer = SmtpServer(smtpServerAddress, username: username, password: password);

      final message = Message()
        ..from = Address(from)
        ..recipients.add(recipient)
        ..subject = subject
        ..text = body;

      final sendReport = await send(message, smtpServer);
      debugPrint('Message sent: ${sendReport.toString()}');

      return {
        "ResultType": 1,
        "ResultMessage": "Email sent successfully",
      };
    } catch (e) {
      String errorMessage = "Error sending email: $e";
      if (e is SocketException) {
        errorMessage = "Error sending email: ${e.message} (OS Error: ${e.osError}, errno = ${e.osError?.errorCode})";
      }

      debugPrint('Email sending failed: $errorMessage');
      return {
        "ResultType": 0,
        "ResultMessage": errorMessage,
      };
    }
  }

}