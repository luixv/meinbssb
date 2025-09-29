import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/screens/base_screen_layout_accessible.dart';
import '/services/api_service.dart';
import '/services/core/logger_service.dart';
import '/screens/email_verification_success_screen_accessible.dart';
import '/screens/email_verification_fail_screen.dart';
import '/models/contact_data.dart';

/// BITV 2.0 konforme Version der E-Mail-Bestätigung
///
/// Diese Implementierung erfüllt die deutschen Barrierefreiheitsrichtlinien
/// E-Mail-Verifikation gemäß BITV 2.0 / WCAG 2.1 Level AA.
///
/// Accessibility Features:
/// - Live-Announcements für alle Prozessschritte
/// - Semantische Loading-Indikatoren
/// - Deutsche Sprachsemantik
/// - Progress-Tracking mit Zeitschätzungen
/// - Accessible Error-Handling
/// - Navigation-Ankündigungen
class EmailVerificationScreenAccessible extends StatefulWidget {
  const EmailVerificationScreenAccessible({
    super.key,
    required this.verificationToken,
    required this.personId,
  });

  final String verificationToken;
  final String personId;

  @override
  EmailVerificationScreenAccessibleState createState() =>
      EmailVerificationScreenAccessibleState();
}

class EmailVerificationScreenAccessibleState
    extends State<EmailVerificationScreenAccessible> {
  bool _isProcessing = false;
  String _currentStep = 'Initialisierung';
  int _progressStep = 0;
  final int _totalSteps = 5;

  @override
  void initState() {
    super.initState();

    // Initiale Ankündigung für Screenreader
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SemanticsService.announce(
        'E-Mail-Bestätigung gestartet. Automatische Verifikation läuft. Bitte warten Sie.',
        TextDirection.ltr,
      );

      LoggerService.logInfo(
        'EmailVerificationScreenAccessible: Auto-verification announced and starting.',
      );
      _processEmailVerification();
    });
  }

  /// Aktualisiert den Fortschritt und kündigt ihn an
  void _updateProgress(int step, String stepDescription) {
    setState(() {
      _progressStep = step;
      _currentStep = stepDescription;
    });

    // Live-Announcement für jeden Fortschrittsschritt
    SemanticsService.announce(
      'Schritt $step von $_totalSteps: $stepDescription',
      TextDirection.ltr,
    );

    LoggerService.logInfo(
      'EmailVerificationScreenAccessible: Progress update - Step $step: $stepDescription',
    );
  }

  Future<void> _processEmailVerification() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      _updateProgress(1, 'Verbindung zum Server wird hergestellt');
      final apiService = Provider.of<ApiService>(context, listen: false);

      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Kurze Pause für bessere UX

      _updateProgress(2, 'Bestätigungstoken wird überprüft');
      final validationEntry =
          await apiService.getEmailValidationByToken(widget.verificationToken);

      if (validationEntry == null) {
        // Fehler-Ankündigung für ungültigen Token
        SemanticsService.announce(
          'Fehler: Bestätigungslink ungültig oder bereits verwendet',
          TextDirection.ltr,
        );
        await _announceNavigationAndNavigate(
          'failure',
          'Der Bestätigungslink ist ungültig oder bereits verwendet worden.',
        );
        return;
      }

      _updateProgress(3, 'E-Mail-Status wird geprüft');
      await Future.delayed(const Duration(milliseconds: 300));

      // Check if already validated
      if (validationEntry['validated'] == true) {
        // Fehler-Ankündigung für bereits bestätigte E-Mail
        SemanticsService.announce(
          'Fehler: E-Mail-Adresse bereits bestätigt',
          TextDirection.ltr,
        );
        await _announceNavigationAndNavigate(
          'failure',
          'Diese E-Mail-Adresse wurde bereits bestätigt.',
        );
        return;
      }

      // Check if person_id matches
      if (validationEntry['person_id'] != widget.personId) {
        // Fehler-Ankündigung für nicht passende Person-ID
        SemanticsService.announce(
          'Fehler: Bestätigungslink gehört nicht zu diesem Benutzer',
          TextDirection.ltr,
        );
        await _announceNavigationAndNavigate(
          'failure',
          'Der Bestätigungslink ist ungültig.',
        );
        return;
      }

      _updateProgress(4, 'E-Mail-Adresse wird als bestätigt markiert');
      final success = await apiService
          .markEmailValidationAsValidated(widget.verificationToken);

      if (!success) {
        // Fehler-Ankündigung für Validierungsfehler
        SemanticsService.announce(
          'Fehler: E-Mail-Bestätigung fehlgeschlagen',
          TextDirection.ltr,
        );
        await _announceNavigationAndNavigate(
          'failure',
          'Fehler beim Bestätigen der E-Mail-Adresse.',
        );
        return;
      }

      _updateProgress(5, 'Kontaktdaten werden aktualisiert');

      // Add the contact to the user's contacts
      final contact = Contact(
        id: 0,
        personId: int.parse(widget.personId),
        type: validationEntry['emailtype'] == 'private' ? 4 : 8,
        value: validationEntry['email'],
      );

      final contactSuccess = await apiService.addKontakt(contact);

      if (contactSuccess) {
        await _announceNavigationAndNavigate(
          'success',
          'Ihre E-Mail-Adresse wurde erfolgreich bestätigt und zu Ihren Kontaktdaten hinzugefügt.',
        );
      } else {
        // Fehler-Ankündigung für Kontakt-Hinzufügung
        SemanticsService.announce(
          'Warnung: E-Mail bestätigt, aber Kontaktdaten-Fehler',
          TextDirection.ltr,
        );
        await _announceNavigationAndNavigate(
          'failure',
          'E-Mail-Adresse bestätigt, aber Fehler beim Hinzufügen zu den Kontaktdaten.',
        );
      }
    } catch (e) {
      LoggerService.logError('Error during email verification: $e');
      // Fehler-Ankündigung für unerwartete Ausnahmen
      SemanticsService.announce(
        'Schwerer Fehler: Unerwarteter Fehler bei der E-Mail-Verifikation',
        TextDirection.ltr,
      );
      await _announceNavigationAndNavigate(
        'failure',
        'Ein unerwarteter Fehler ist aufgetreten: $e',
      );
    }
  }

  /// Kündigt Navigation an und navigiert mit Verzögerung
  Future<void> _announceNavigationAndNavigate(
    String type,
    String message,
  ) async {
    if (!mounted) return;

    // Ankündigung der bevorstehenden Navigation
    String navigationAnnouncement = type == 'success'
        ? 'Verifikation erfolgreich. Weiterleitung zur Erfolgsseite in 2 Sekunden.'
        : 'Verifikation fehlgeschlagen. Weiterleitung zur Fehlerseite in 2 Sekunden.';

    SemanticsService.announce(navigationAnnouncement, TextDirection.ltr);

    // Kurze Verzögerung, damit Nutzer die Ankündigung hören können
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (type == 'success') {
      _navigateToSuccessScreen(message);
    } else {
      _navigateToFailScreen(message);
    }
  }

  void _navigateToSuccessScreen(String message) {
    if (!mounted) return;

    // Finale Ankündigung vor Navigation
    SemanticsService.announce(
      'Erfolgreich: $message Navigation zur Erfolgsseite.',
      TextDirection.ltr,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => EmailVerificationSuccessScreenAccessible(
          message: message,
          userData: null, // We don't have user data in this context
        ),
      ),
    );
  }

  void _navigateToFailScreen(String message) {
    if (!mounted) return;

    // Finale Ankündigung vor Navigation
    SemanticsService.announce(
      'Fehler: $message Navigation zur Fehlerseite.',
      TextDirection.ltr,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => EmailVerificationFailScreen(
          message: message,
          userData: null, // We don't have user data in this context
        ),
      ),
    );
  }

  /// Berechnet Fortschritt als Prozentsatz
  double get _progressPercentage => _progressStep / _totalSteps;

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayoutAccessible(
      title: 'E-Mail-Bestätigung',
      userData: null,
      isLoggedIn: false,
      onLogout: () {
        Navigator.pushReplacementNamed(context, '/login');
      },
      body: Semantics(
        container: true,
        label: 'E-Mail-Bestätigung Verifikationsprozess',
        hint:
            'Automatische E-Mail-Verifikation läuft. Fortschritt wird live übermittelt.',
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(UIConstants.spacingL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Progress Indicator mit vollständiger Accessibility
                Semantics(
                  label: 'Fortschrittsanzeige für E-Mail-Verifikation',
                  hint: 'Zeigt aktuellen Bearbeitungsfortschritt an',
                  value:
                      '${(_progressPercentage * 100).round()}% abgeschlossen',
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Circular Progress Indicator
                        Semantics(
                          excludeSemantics: true, // Vermeidet doppelte Semantik
                          child: CircularProgressIndicator(
                            value: _progressPercentage,
                            strokeWidth: 6,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              UIConstants.circularProgressIndicator,
                            ),
                            backgroundColor: UIConstants
                                .circularProgressIndicator
                                .withOpacity(0.2),
                          ),
                        ),
                        // Progress Text
                        Semantics(
                          excludeSemantics: true,
                          child: Text(
                            '${(_progressPercentage * 100).round()}%',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: UIConstants.spacingL),

                // Aktueller Schritt mit Live-Region
                Semantics(
                  liveRegion: true,
                  label: 'Aktueller Verifikationsschritt',
                  hint:
                      'Wird automatisch aktualisiert während der Verifikation',
                  child: Container(
                    padding: const EdgeInsets.all(UIConstants.spacingM),
                    decoration: BoxDecoration(
                      color: UIConstants.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: UIConstants.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Schritt-Indikator
                        Semantics(
                          readOnly: true,
                          label: 'Fortschritt',
                          child: Text(
                            'Schritt $_progressStep von $_totalSteps',
                            style: const TextStyle(
                              fontSize: 14,
                              color: UIConstants.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingS),

                        // Aktueller Schritt
                        Semantics(
                          readOnly: true,
                          label: 'Aktuelle Aktion',
                          child: Text(
                            _currentStep,
                            style: const TextStyle(
                              fontSize: UIConstants.dialogFontSize,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: UIConstants.spacingL),

                // Zusätzliche Information mit Accessibility
                Semantics(
                  readOnly: true,
                  label: 'Benutzerinformation',
                  hint: 'Allgemeine Informationen zum Verifikationsprozess',
                  child: Container(
                    padding: const EdgeInsets.all(UIConstants.spacingM),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                          size: 24,
                          semanticLabel: 'Informations-Symbol',
                        ),
                        SizedBox(height: UIConstants.spacingS),
                        Text(
                          'Die E-Mail-Bestätigung erfolgt automatisch. Sie werden nach Abschluss weitergeleitet.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: UIConstants.spacingL),

                // Tastatur-Hinweise für Accessibility
                Semantics(
                  readOnly: true,
                  label: 'Bedienungshinweise',
                  child: Text(
                    'Hinweis: Der Prozess läuft automatisch ab. Bei Problemen nutzen Sie die Zurück-Taste Ihres Browsers.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
