import 'package:flutter/material.dart';
import 'email_service.dart';

class EmailQueueMonitor extends StatefulWidget {
  const EmailQueueMonitor({super.key});

  @override
  State<EmailQueueMonitor> createState() => _EmailQueueMonitorState();
}

class _EmailQueueMonitorState extends State<EmailQueueMonitor> {
  final EmailService _emailService = EmailService();
  Map<String, dynamic> _queueStats = {};

  @override
  void initState() {
    super.initState();
    _refreshQueue();
  }

  Future<void> _refreshQueue() async {
    final stats = await _emailService.getQueueStatus();
    setState(() => _queueStats = stats);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email Queue Monitor')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _StatCard(
              title: 'Pending Emails',
              value: _queueStats['pending']?.toString() ?? '0',
              color: Colors.orange,
            ),
            _StatCard(
              title: 'Failed Emails',
              value: _queueStats['failed']?.toString() ?? '0',
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _refreshQueue,
              child: const Text('Refresh Queue'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Text(title, style: const TextStyle(fontSize: 18)),
            const Spacer(),
            Text(value, style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            )),
          ],
        ),
      ),
    );
  }
}