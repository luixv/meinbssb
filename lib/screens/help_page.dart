import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart'; 
import 'package:meinbssb/services/localization_service.dart';  // moved

class HelpPage extends StatelessWidget {
  const HelpPage({super.key}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.getString("help_title")),
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