// Project: Mein BSSB
// Filename: help_screen.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:meinbssb/services/localization_service.dart';
import 'package:meinbssb/constants/ui_constants.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocalizationService.getString("help_title"),
          style: UIConstants.titleStyle,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(UIConstants.defaultPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Using Html widget to render the HTML content
              Html(
                data: LocalizationService.getString(
                  "help_content",
                ), // Fetch help content from properties file
                style: {
                  "body": Style(
                    fontSize: FontSize(UIConstants.bodyFontSize),
                    color: UIConstants.black,
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
