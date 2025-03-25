import 'package:flutter/material.dart';
import '../data/email_queue_db.dart';

class EmailListScreen extends StatefulWidget {
  const EmailListScreen({super.key}); // Corrected constructor

  @override
  EmailListScreenState createState() => EmailListScreenState(); //Corrected state class name
}

class EmailListScreenState extends State<EmailListScreen> { // Corrected state class name
  final dbHelper = EmailQueueDB();
  List<Map<String, dynamic>> emails = [];

  @override
  void initState() {
    super.initState();
    _loadEmails();
  }

  Future<void> _loadEmails() async {
    final loadedEmails = await dbHelper.getAllEmails();
    setState(() {
      emails = loadedEmails;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Monitored Emails')),
      body: ListView.builder(
        itemCount: emails.length,
        itemBuilder: (context, index) {
          final email = emails[index];
          return ListTile(
            title: Text(email['subject']),
            subtitle: Text(email['recipient']),
            // Add more details
          );
        },
      ),
    );
  }
}