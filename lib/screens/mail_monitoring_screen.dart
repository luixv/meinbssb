import 'package:flutter/material.dart';
import 'package:meinbssb/services/email_service.dart';

class MailMonitoringScreen extends StatefulWidget {
  const MailMonitoringScreen({super.key});

  @override
  MailMonitoringScreenState createState() => MailMonitoringScreenState();
}

class MailMonitoringScreenState extends State<MailMonitoringScreen> {
  final EmailService _emailService = EmailService();
  Map<String, dynamic> _queueStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQueueStats();
  }

  Future<void> _loadQueueStats() async {
    setState(() {
      _isLoading = true;
    });
    final stats = await _emailService.getQueueStats();
    setState(() {
      _queueStats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mail Monitoring')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Email Queue Statistics',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    DataTable(
                      columns: const [
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Count')),
                      ],
                      rows: [
                        DataRow(cells: [
                          const DataCell(Text('Total')),
                          DataCell(Text('${_queueStats['total'] ?? 0}')),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('Pending')),
                          DataCell(Text('${_queueStats['pending'] ?? 0}')),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('Sent')),
                          DataCell(Text('${_queueStats['sent'] ?? 0}')),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('Failed')),
                          DataCell(Text('${_queueStats['failed'] ?? 0}')),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('Average Retries')),
                          DataCell(Text('${_queueStats['avgRetries'] ?? 0}')),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadQueueStats,
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}