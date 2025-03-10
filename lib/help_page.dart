import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart'; // Import this package
import 'localization_service.dart'; // Make sure to import your localization service

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.getString("help_title")), // Fetch title from properties file
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Using Html widget to render the HTML content
              Html(
                data: LocalizationService.getString("help_content"), // Fetch help content from properties file
              ),
            ],
          ),
        ),
      ),
    );
  }
}