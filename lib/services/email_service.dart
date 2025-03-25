import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:meinbssb/services/localization_service.dart';
import '../data/email_queue_db.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class EmailService {
  Future<Map<String, dynamic>> sendEmail({
    required String from,
    required String to,
    required String subject,
    required String content,
  }) async {
    // Extract SMTP server credentials from your configuration
    String smtpServerAddress = LocalizationService.getString('smtp');
    String username = LocalizationService.getString('smtp_username');
    String password = LocalizationService.getString('smtp_password');

    // Create the SMTP server
    final smtpServer = SmtpServer(smtpServerAddress, username: username, password: password);

    // Create the message
    final message = Message()
      ..from = Address(from) // Use from address from localization
      ..recipients.add(to)
      ..subject = subject
      ..text = content;

    try {
      // Send the message
      final sendReport = await send(message, smtpServer);
      debugPrint('Message sent: ${sendReport.toString()}');

      return {"ResultType": 1, "ResultMessage": "Email sent successfully"};
    } catch (e) {
      debugPrint('Error sending email: $e');
      return {
        "ResultType": 0,
        "ResultMessage": "Error sending email: $e",
      };
    }
  }

  Future<void> sendEmailFromQueue() async {
  final db = EmailQueueDB();
  final pendingEmails = await db.getPendingEmails();

  for (final email in pendingEmails) {
    final from = LocalizationService.getString('From'); // Get from address from localization

    final result = await sendEmail(
      from: from, // Use the retrieved from address
      to: email['recipient'],
      subject: email['subject'],
      content: email['body'] ?? '',
    );

    if (result['ResultType'] == 1) {
      await db.updateStatus(email['id'], 'sent');
    } else {
      await db.updateStatus(email['id'], 'failed');
      await db.incrementRetry(email['id']);
      // Add retry delay if needed
      // await Future.delayed(Duration(seconds: 30));
    }
  }
}

  Future<void> addEmailToQueue({
    required String recipient,
    required String subject,
    String? body,
  }) async {
    final db = EmailQueueDB();
    await db.addEmail(
      recipient: recipient,
      subject: subject,
      body: body,
    );
  }

  Future<Map<String, dynamic>> getQueueStats() async {
    final db = EmailQueueDB();
    return db.getQueueStats();
  }
}