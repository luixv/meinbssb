// Project: Mein BSSB
// Filename: help_screen.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '/screens/app_menu.dart';
import '/constants/ui_constants.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({
    super.key,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });
  final Map<String, dynamic> userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  String _htmlContent = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadFaq();
  }

  Future<void> _loadFaq() async {
    try {
      final String content = await rootBundle.loadString(
        'assets/html/faq.html',
      );
      setState(() {
        _htmlContent = content;
      });
    } catch (e) {
      setState(() {
        _htmlContent = 'Failed to load FAQ: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FAQ', // You can hardcode the title or use a localization key
          style: UIConstants.titleStyle,
        ),
        actions: [
          AppMenu(
            // Add your AppMenu widget if needed
            context: context,
            userData: widget.userData,
            isLoggedIn: widget.isLoggedIn,
            onLogout: widget.onLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(UIConstants.defaultPadding),
        child: HtmlWidget(_htmlContent),
      ),
    );
  }
}
