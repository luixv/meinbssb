// lib/screens/impressum_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:meinbssb/screens/app_menu.dart';

class ImpressumScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final bool isLoggedIn;
  final Function() onLogout;

  const ImpressumScreen({
    super.key,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });

  @override
  State<ImpressumScreen> createState() => _ImpressumScreenState();
}

class _ImpressumScreenState extends State<ImpressumScreen> {
  String _htmlContent = 'Loading...'; // Define _htmlContent here

  @override
  void initState() {
    super.initState();
    _loadImpressum();
  }

  Future<void> _loadImpressum() async {
    try {
      final String content = await rootBundle.loadString('assets/html/impressum.html');
      setState(() {
        _htmlContent = content;
      });
    } catch (e) {
      setState(() {
        _htmlContent = 'Failed to load Impressum: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impressum'),
        actions: [
          AppMenu( // Add your AppMenu widget here
            context: context,
            userData: widget.userData,
            isLoggedIn: widget.isLoggedIn,
            onLogout: widget.onLogout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: HtmlWidget(
          _htmlContent, // Use the defined _htmlContent
        ),
      ),
    );
  }
}
