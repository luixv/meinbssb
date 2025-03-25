import 'package:mailer/mailer.dart';
import 'email_queue_db.dart';
import 'package:mailer/smtp_server.dart'; 
import 'localization_service.dart';

class EmailService {
  final EmailQueueDB _db = EmailQueueDB();

  // Add email to queue
  Future<void> queueEmail({
    required String to,
    required String subject,
    String? body,
  }) async {
    await _db.addEmail(
      recipient: to,
      subject: subject,
      body: body,
    );
    _processQueue(); // Start processing in background
  }

  // Process pending emails
  Future<void> _processQueue() async {
    final pendingEmails = await _db.getPendingEmails();
    if (pendingEmails.isEmpty) return;

    final smtpServer = SmtpServer(
      LocalizationService.getString('smtp'),
      username: LocalizationService.getString('smtp_username'),
      password: LocalizationService.getString('smtp_password'),
    );

    for (final email in pendingEmails) {
      try {
        final message = Message()
          ..from = Address('your@email.com')
          ..recipients.add(email['recipient'] as String)
          ..subject = email['subject'] as String
          ..text = email['body'] as String? ?? '';

        await send(message, smtpServer);
        await _db.updateStatus(email['id'] as int, 'sent');
      } catch (e) {
        await _db.updateStatus(email['id'] as int, 'failed');
      }
    }
  }

  // Get queue stats (for monitoring)
  Future<Map<String, dynamic>> getQueueStatus() async {
    return _db.getQueueStats();
  }
}