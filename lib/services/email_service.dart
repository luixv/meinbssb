// email_service.dart
import 'package:meinbssb/data/email_queue_db.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:meinbssb/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class EmailService {
  final EmailQueueDB _emailQueueDB = EmailQueueDB();

  Future<Map<String, dynamic>> sendEmail({
    required String from,
    required String recipient,
    required String subject,
    String? body,
    int? emailId,
  }) async {
    int queueResult = -1;

    debugPrint("sendEmail called with emailId: $emailId");

    if (emailId == null) {
      debugPrint("Inserting new email...");
      queueResult = await this._emailQueueDB.addEmail(
        recipient: recipient,
        subject: subject,
        body: body,
      );
    } else {
      debugPrint("Skipping insertion. Using existing emailId: $emailId");
      queueResult = emailId;
    }

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

      await this._emailQueueDB.updateStatus(queueResult, 'sent');
      debugPrint("Updated status to 'sent' for id: $queueResult");

      return {
        "ResultType": 1,
        "ResultMessage": "Email sent successfully",
      };
    } catch (e) {
      String errorMessage = "Error sending email: $e";
      if (e is SocketException) {
        errorMessage = "Error sending email: ${e.message} (OS Error: ${e.osError}, errno = ${e.osError?.errorCode})";
      }

      await this._emailQueueDB.updateStatus(queueResult, 'failed');
      // Remove incrementRetry from here.
      debugPrint("Updated status to 'failed' for id: $queueResult");

      debugPrint('Email sending failed: $errorMessage');
      return {
        "ResultType": 0,
        "ResultMessage": errorMessage,
      };
    }
  }

  Future<Map<String, dynamic>> retryEmail(int emailId) async {
    try {
      final email = await _emailQueueDB.getAllEmails();
      Map<String, dynamic>? emailData;

      for (int i = 0; i < email.length; i++) {
        if (email[i]['id'] == emailId) {
          emailData = email[i];
          break;
        }
      }

      if (emailData == null) {
        return {
          "ResultType": 0,
          "ResultMessage": "Email not found",
        };
      }

      final sendResult = await sendEmail(
        from: LocalizationService.getString('From'),
        recipient: emailData['recipient'],
        subject: emailData['subject'],
        body: emailData['body'],
        emailId: emailId,
      );

      if (sendResult['ResultType'] == 1) {
        await _emailQueueDB.updateStatus(emailId, 'sent');
        return sendResult;
      } else {
        await _emailQueueDB.incrementRetry(emailId); // Increment only here.
        await _emailQueueDB.updateStatus(emailId, 'failed');
        return sendResult;
      }
    } catch (e) {
      debugPrint("Error retrying email: $e");
      return {
        "ResultType": 0,
        "ResultMessage": "Error retrying email: $e",
      };
    }
  }
}