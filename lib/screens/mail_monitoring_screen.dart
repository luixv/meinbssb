import 'package:flutter/material.dart';
import 'package:meinbssb/data/email_queue_db.dart';
import 'package:meinbssb/services/email_service.dart';

class MailMonitoringScreen extends StatefulWidget {
  const MailMonitoringScreen({super.key});

  @override
  MailMonitoringScreenState createState() => MailMonitoringScreenState();
}

class MailMonitoringScreenState extends State<MailMonitoringScreen> {
  final EmailQueueDB _emailQueueDB = EmailQueueDB();
  List<Map<String, dynamic>> _emails = [];

  @override
  void initState() {
    super.initState();
    _loadEmails();
  }

  Future<void> _loadEmails() async {
    final emails = await _emailQueueDB.getAllEmails();
    setState(() {
      _emails = emails;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mail Monitoring'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: const <DataColumn>[
              DataColumn(label: Text('Recipient')),
              DataColumn(label: Text('Subject')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Retries')),
              DataColumn(label: Text('Actions')),
            ],
            rows: _emails.map((email) {
              return DataRow(
                cells: <DataCell>[
                  DataCell(Text(email['recipient'])),
                  DataCell(Text(email['subject'])),
                  DataCell(Text(email['status'])),
                  DataCell(Text(email['retries'].toString())),
                  DataCell(
                    email['status'] == 'failed'
                        ? ElevatedButton(
                            onPressed: () async {
                              if (mounted) { // Mounted check at the very beginning
                                final result = await EmailService().retryEmail(email['id']);
                                if (result['ResultType'] == 1) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Email retried successfully')),
                                  );
                                  _loadEmails(); // Load emails outside the mounted check
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(result['ResultMessage'])),
                                  );
                                }
                                _loadEmails(); // Load emails outside the mounted check
                              }
                            },
                            child: const Text('Retry'),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}