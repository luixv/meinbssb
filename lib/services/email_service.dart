// email_service.dart
import 'package:meinbssb/data/email_queue_db.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:meinbssb/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class EmailService {
  final EmailQueueDB _emailQueueDB = EmailQueueDB();

 
Future<Map<String, dynamic>> sendEmail({
    required String from,
    required String recipient,
    required String subject,
    String? body,
}) async {
    int queueResult = -1; // Define queueResult outside try block
    try {
        String smtpServerAddress = LocalizationService.getString('smtp');
        String username = LocalizationService.getString('smtp_username');
        String password = LocalizationService.getString('smtp_password');

        // 1. Add email to the queue (before sending)
        queueResult = await _emailQueueDB.addEmail(
            recipient: recipient,
            subject: subject,
            body: body,
        );

        final smtpServer = SmtpServer(smtpServerAddress, username: username, password: password);

        final message = Message()
            ..from = Address(from)
            ..recipients.add(recipient)
            ..subject = subject
            ..text = body;

        final sendReport = await send(message, smtpServer);
        debugPrint('Message sent: ${sendReport.toString()}');

        // 2. Update the email status in the queue (after successful sending)
        await _emailQueueDB.updateStatus(queueResult, 'sent');

        return {
            "ResultType": 1,
            "ResultMessage": "Email sent successfully",
        };
    } catch (e) {
        String errorMessage = "Error sending email: $e";
        if (e is SocketException) {
            errorMessage = "Error sending email: ${e.message} (OS Error: ${e.osError}, errno = ${e.osError?.errorCode})";
        }

        // 3. Increment the retry count and update the status (after failed sending)
        if(queueResult != -1) {
            await _emailQueueDB.updateStatus(queueResult, 'failed');
            await _emailQueueDB.incrementRetry(queueResult);
        }

        debugPrint('Email sending failed: $errorMessage');
        return {
            "ResultType": 0,
            "ResultMessage": errorMessage,
        };
    }
}


  Future<void> sendEmailFromQueue() async {
    final pendingEmails = await _emailQueueDB.getPendingEmails();
    for (var email in pendingEmails) {
      try {
        String smtpServerAddress = LocalizationService.getString('smtp');
        String username = LocalizationService.getString('smtp_username');
        String password = LocalizationService.getString('smtp_password');

        final smtpServer = SmtpServer(smtpServerAddress, username: username, password: password);

        final message = Message()
          ..from = email['from']
          ..recipients.add(email['recipient']) // Use recipient
          ..subject = email['subject']
          ..text = email['body']; // Use body

        final sendReport = await send(message, smtpServer);
        debugPrint('Message sent: ${sendReport.toString()}');

        await _emailQueueDB.updateStatus(email['id'], 'sent');
      } catch (e) {
        String errorMessage = "Error sending email: $e";
        if (e is SocketException) {
          errorMessage = "Error sending email: ${e.message} (OS Error: ${e.osError}, errno = ${e.osError?.errorCode})";
        }

        await _emailQueueDB.updateStatus(email['id'], 'failed');
        await _emailQueueDB.incrementRetry(email['id']);

        debugPrint('Email sending failed: $errorMessage');
      }
    }
  }

  Future<Map<String, dynamic>> getQueueStats() async {
    return await _emailQueueDB.getQueueStats();
  }
}