import 'package:flutter/material.dart';
import 'api_service.dart';
import 'app_menu.dart';
import 'package:logging/logging.dart';
import 'localization_service.dart';

class PasswordResetScreen extends StatefulWidget {
  final String personId;

  const PasswordResetScreen({required this.personId, super.key});

  @override
  PasswordResetScreenState createState() => PasswordResetScreenState();
}

class PasswordResetScreenState extends State<PasswordResetScreen> {
  Map<String, dynamic> userData = {};
  bool _isLoading = true;
  final Logger _logger = Logger('PasswordResetScreen');
  Color _appColor = const Color(0xFF006400); // Declare _appColor here

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadLocalization();
  }

  Future<void> _loadLocalization() async {
    await LocalizationService.load('assets/strings.json');
    setState(() {
      final colorString = LocalizationService.getString('appColor');
      if (colorString.isNotEmpty) {
        _appColor = Color(int.parse(colorString));
      }
    });
  }

  Future<void> _fetchUserData() async {
    try {
      int? parsedPersonId = int.tryParse(widget.personId);
      if (parsedPersonId != null) {
        var passdaten = await ApiService.fetchPassdaten(parsedPersonId);
        setState(() {
          userData = passdaten;
          _isLoading = false;
        });
      } else {
        _logger.warning("Invalid personId format: ${widget.personId}");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _logger.severe("Error fetching user data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Passwort zurücksetzen"),
        actions: [
          if (!_isLoading)
            AppMenu(
              context: context,
              userData: userData,
              isPasswordReset: true,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/myBSSB-logo.png',
                      height: 100,
                      width: 100,
                    ),
                    Text(
                      "Passnummer: ${widget.personId}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Passwort zurücksetzen",
                      style: TextStyle( // Removed 'const' here
                        color: _appColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text("Passwort zurücksetzen"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}