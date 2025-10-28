import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/screens/base_screen_layout.dart';
import '/services/api_service.dart';
import '/services/core/logger_service.dart';
import '/screens/email_verification_success_screen.dart';
import '/screens/email_verification_fail_screen.dart';
import '/models/contact_data.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({
    super.key,
    required this.verificationToken,
    required this.personId,
  });

  final String verificationToken;
  final String personId;

  @override
  EmailVerificationScreenState createState() => EmailVerificationScreenState();
}

class EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Start verification process immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processEmailVerification();
    });
  }

  Future<void> _processEmailVerification() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      // Get email validation entry by token
      final validationEntry = await apiService.getEmailValidationByToken(
        widget.verificationToken,
      );

      if (validationEntry == null) {
        _navigateToFailScreen(
          'Der Bestätigungslink ist ungültig oder bereits verwendet worden.',
        );
        return;
      }

      // Check if already validated
      if (validationEntry['validated'] == true) {
        _navigateToFailScreen('Diese E-Mail-Adresse wurde bereits bestätigt.');
        return;
      }

      // Check if person_id matches
      if (validationEntry['person_id'] != widget.personId) {
        _navigateToFailScreen('Der Bestätigungslink ist ungültig.');
        return;
      }

      // Mark as validated
      final success = await apiService.markEmailValidationAsValidated(
        widget.verificationToken,
      );

      if (!success) {
        _navigateToFailScreen('Fehler beim Bestätigen der E-Mail-Adresse.');
        return;
      }

      // Add the contact to the user's contacts
      final contact = Contact(
        id: 0,
        personId: int.parse(widget.personId),
        type: validationEntry['emailtype'] == 'private' ? 4 : 8,
        value: validationEntry['email'],
      );

      final contactSuccess = await apiService.addKontakt(contact);

      if (contactSuccess) {
        _navigateToSuccessScreen(
          'Ihre E-Mail-Adresse wurde erfolgreich bestätigt und zu Ihren Kontaktdaten hinzugefügt.',
        );
      } else {
        _navigateToFailScreen(
          'E-Mail-Adresse bestätigt, aber Fehler beim Hinzufügen zu den Kontaktdaten.',
        );
      }
    } catch (e) {
      LoggerService.logError('Error during email verification: $e');
      _navigateToFailScreen('Ein Fehler ist aufgetreten: $e');
    }
  }

  void _navigateToSuccessScreen(String message) {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (context) => EmailVerificationSuccessScreen(
              message: message,
              userData: null, // We don't have user data in this context
            ),
      ),
    );
  }

  void _navigateToFailScreen(String message) {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder:
            (context) => EmailVerificationFailScreen(
              message: message,
              userData: null, // We don't have user data in this context
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'E-Mail-Bestätigung',
      userData: null,
      isLoggedIn: false,
      onLogout: () {
        Navigator.pushReplacementNamed(context, '/login');
      },
      body: Semantics(
        label:
            'E-Mail-Bestätigung. Ihre E-Mail-Adresse wird überprüft und bestätigt. Bitte warten Sie, während der Vorgang abgeschlossen wird.',
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  UIConstants.circularProgressIndicator,
                ),
              ),
              SizedBox(height: UIConstants.spacingM),
              Text(
                'E-Mail-Adresse wird bestätigt...',
                style: TextStyle(fontSize: UIConstants.dialogFontSize),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
