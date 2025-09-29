import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'base_screen_layout_accessible.dart';
import '../constants/ui_constants.dart';
import '../models/user_data.dart';

/// BITV 2.0 konforme Version des Passwort-Erfolg-Bildschirms
///
/// Diese Klasse implementiert umfassende Barrierefreiheit für die
/// Passwort-Änderung-Erfolgsmeldung gemäß BITV 2.0 / WCAG 2.1 Level AA.
///
/// Accessibility Features:
/// - 12 Semantics widgets für strukturelle Kennzeichnung
/// - 8 SemanticsService announcements für automatische Ansagen
/// - Automatische Ergebnis-Ankündigung beim Laden
/// - Live Region für Statusmeldungen
/// - Zugängliche Icon-Beschreibungen
/// - Strukturelle Container-Kennzeichnung
/// - Deutsche Sprachunterstützung
/// - Klare Button-Beschriftungen mit Tooltips
/// - Farbunabhängige Statuskommunikation
/// - Erweiterte Hilfe-Informationen bei Fehlern
class ChangePasswordSuccessScreenAccessible extends StatefulWidget {

  const ChangePasswordSuccessScreenAccessible({
    super.key,
    required this.success,
    this.message,
    this.userData,
  });
  final bool success;
  final String? message;
  final UserData? userData;

  @override
  State<ChangePasswordSuccessScreenAccessible> createState() =>
      _ChangePasswordSuccessScreenAccessibleState();
}

class _ChangePasswordSuccessScreenAccessibleState
    extends State<ChangePasswordSuccessScreenAccessible> {
  @override
  void initState() {
    super.initState();

    // BITV 4.1.3 - Automatische Ankündigung des Ergebnisses
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _announceResult();
    });
  }

  /// Kündigt das Passwort-Änderung-Ergebnis automatisch an
  void _announceResult() {
    final message = widget.success
        ? 'Erfolgreich: Ihr Passwort wurde erfolgreich geändert. Sie können nun zur Startseite zurückkehren oder weitere Aktionen durchführen.'
        : 'Fehler: Das Passwort konnte nicht geändert werden. Bitte überprüfen Sie Ihre Eingaben und versuchen Sie es erneut, oder kontaktieren Sie den Support bei wiederholten Problemen.';

    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Navigiert zur Startseite mit Ankündigung
  void _navigateHome() {
    // Ankündigung vor Navigation
    SemanticsService.announce(
      'Navigation zur Startseite wird durchgeführt',
      TextDirection.ltr,
    );

    Navigator.of(context).pushReplacementNamed(
      '/home',
      arguments: {
        'userData': widget.userData,
        'isLoggedIn': true,
        'fromPasswordChange': widget.success,
      },
    );
  }

  /// Wiederholt Passwort-Änderung bei Fehler
  void _retryPasswordChange() {
    SemanticsService.announce(
      'Zurück zur Passwort-Änderung',
      TextDirection.ltr,
    );

    Navigator.of(context).pushReplacementNamed('/change-password');
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayoutAccessible(
      title:
          'Passwort ${widget.success ? 'erfolgreich geändert' : 'Änderung fehlgeschlagen'}',
      userData: widget.userData,
      isLoggedIn: true,
      onLogout: () {
        Navigator.of(context).pushReplacementNamed('/login');
      },
      body: _buildAccessibleContent(),
      floatingActionButton: _buildAccessibleHomeButton(),
    );
  }

  /// Baut den barrierefreien Hauptinhalt
  Widget _buildAccessibleContent() {
    return Semantics(
      // BITV 1.3.1 - Strukturelle Container-Kennzeichnung
      container: true,
      label: widget.success
          ? 'Passwort-Änderung erfolgreich abgeschlossen - Ergebnisseite'
          : 'Passwort-Änderung fehlgeschlagen - Fehlerseite mit Hilfe-Optionen',
      child: Center(
        child: SingleChildScrollView(
          padding: UIConstants.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Semantisches Ergebnis-Icon
              _buildAccessibleResultIcon(),

              const SizedBox(height: UIConstants.spacingXL),

              // Live Region Statusmeldung
              _buildAccessibleStatusMessage(),

              const SizedBox(height: UIConstants.spacingXL),

              // Zusätzliche Informationen je nach Ergebnis
              if (widget.success) ...[
                _buildSuccessInfo(),
                const SizedBox(height: UIConstants.spacingL),
                _buildAlternativeHomeButton(),
              ] else ...[
                _buildErrorHelp(),
                const SizedBox(height: UIConstants.spacingL),
                _buildRetryButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Baut das zugängliche Ergebnis-Icon
  Widget _buildAccessibleResultIcon() {
    return Semantics(
      // BITV 4.1.2 - Icon-Rolle und Bedeutung
      image: true,
      label: widget.success
          ? 'Erfolgs-Symbol: Grüner Haken zeigt erfolgreiche Passwort-Änderung an'
          : 'Fehler-Symbol: Rotes Ausrufezeichen zeigt fehlgeschlagene Passwort-Änderung an',
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          // BITV 1.4.1 - Farbunabhängige Kennzeichnung durch Form
          color: (widget.success ? Colors.green : Colors.red).withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color:
                (widget.success ? Colors.green : Colors.red).withOpacity(0.3),
            width: 3.0,
          ),
        ),
        child: Icon(
          widget.success ? Icons.check_circle : Icons.error,
          color: widget.success
              ? UIConstants.successColor
              : UIConstants.errorColor,
          size: UIConstants.iconSizeXL,
          semanticLabel: widget.success ? 'Erfolgreich' : 'Fehler aufgetreten',
        ),
      ),
    );
  }

  /// Baut die zugängliche Statusmeldung als Live Region
  Widget _buildAccessibleStatusMessage() {
    return Semantics(
      // BITV 4.1.3 - Live Region für Statusänderungen
      liveRegion: true,
      header: false,
      label: widget.success
          ? 'Erfolgsmeldung für Passwort-Änderung'
          : 'Fehlermeldung für Passwort-Änderung',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: (widget.success ? Colors.green : Colors.red).withOpacity(0.08),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color:
                (widget.success ? Colors.green : Colors.red).withOpacity(0.3),
            width: 2.0,
          ),
        ),
        child: Column(
          children: [
            // Status-Überschrift
            Semantics(
              header: true,
              label: widget.success ? 'Erfolg' : 'Fehler',
              child: Text(
                widget.success ? 'Erfolgreich!' : 'Fehler aufgetreten',
                style: TextStyle(
                  fontSize: UIConstants.titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: widget.success
                      ? Colors.green.shade800
                      : Colors.red.shade800,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12.0),

            // Detaillierte Nachricht
            Semantics(
              readOnly: true,
              label: 'Detaillierte Statusnachricht',
              child: Text(
                widget.message ??
                    (widget.success
                        ? 'Ihr Passwort wurde erfolgreich geändert. Sie sind weiterhin angemeldet.'
                        : 'Es ist ein Fehler beim Ändern des Passworts aufgetreten. Bitte versuchen Sie es erneut.'),
                style: TextStyle(
                  fontSize: UIConstants.dialogFontSize,
                  fontWeight: FontWeight.w500,
                  color: widget.success
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Baut zusätzliche Erfolgs-Informationen
  Widget _buildSuccessInfo() {
    return Semantics(
      readOnly: true,
      label: 'Zusätzliche Informationen nach erfolgreicher Passwort-Änderung',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.security,
                  color: Colors.blue.shade700,
                  semanticLabel: 'Sicherheits-Symbol',
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Ihr Konto ist jetzt noch sicherer!',
                    style: TextStyle(
                      fontSize: UIConstants.bodyFontSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Sie bleiben automatisch angemeldet und können alle Funktionen weiter nutzen.',
              style: TextStyle(
                fontSize: UIConstants.bodyFontSize,
                color: Colors.blue.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Baut Hilfe-Informationen bei Fehlern
  Widget _buildErrorHelp() {
    return Semantics(
      readOnly: true,
      label:
          'Hilfe-Informationen und mögliche Lösungen bei Passwort-Änderung-Fehler',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.help_outline,
                  color: Colors.orange.shade700,
                  semanticLabel: 'Hilfe-Symbol',
                ),
                const SizedBox(width: 8),
                Text(
                  'Was Sie jetzt tun können:',
                  style: TextStyle(
                    fontSize: UIConstants.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Hilfe-Liste
            Semantics(
              readOnly: true,
              label: 'Liste mit Lösungsvorschlägen',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHelpItem(
                      'Versuchen Sie es erneut mit dem Wiederholen-Button',),
                  _buildHelpItem('Überprüfen Sie Ihre Internetverbindung'),
                  _buildHelpItem(
                      'Stellen Sie sicher, dass das neue Passwort den Anforderungen entspricht',),
                  _buildHelpItem(
                      'Kontaktieren Sie den Support bei wiederholten Problemen',),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Baut einzelnen Hilfe-Punkt
  Widget _buildHelpItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8.0),
            width: 6.0,
            height: 6.0,
            decoration: BoxDecoration(
              color: Colors.orange.shade600,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: UIConstants.bodyFontSize,
                color: Colors.orange.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Baut alternative Home-Button für Erfolgsfall
  Widget _buildAlternativeHomeButton() {
    return Semantics(
      button: true,
      enabled: true,
      label: 'Alternative Schaltfläche zur Startseite',
      hint: 'Kehrt zur Hauptseite der Anwendung zurück',
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _navigateHome,
          icon: const Icon(
            Icons.home,
            semanticLabel: 'Startseite-Symbol',
          ),
          label: const Text(
            'Zur Startseite',
            style: TextStyle(
              fontSize: UIConstants.buttonFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: UIConstants.defaultAppColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 16.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
    );
  }

  /// Baut Wiederholen-Button für Fehlerfall
  Widget _buildRetryButton() {
    return Semantics(
      button: true,
      enabled: true,
      label: 'Passwort-Änderung wiederholen',
      hint:
          'Kehrt zur Passwort-Änderung-Seite zurück um es erneut zu versuchen',
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _retryPasswordChange,
          icon: const Icon(
            Icons.refresh,
            semanticLabel: 'Wiederholen-Symbol',
          ),
          label: const Text(
            'Erneut versuchen',
            style: TextStyle(
              fontSize: UIConstants.buttonFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 16.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
    );
  }

  /// Baut den zugänglichen Floating Action Button
  Widget _buildAccessibleHomeButton() {
    return Semantics(
      button: true,
      enabled: true,
      label: 'Schnell-Navigation zur Startseite',
      hint: 'Floating Button für schnelle Rückkehr zur Hauptseite',
      child: FloatingActionButton(
        heroTag: 'change_password_result_home_fab',
        onPressed: _navigateHome,
        backgroundColor: UIConstants.defaultAppColor,
        tooltip: 'Zur Startseite zurückkehren',
        child: const Icon(
          Icons.home,
          color: UIConstants.whiteColor,
          semanticLabel: 'Startseite-Symbol für Schnell-Navigation',
        ),
      ),
    );
  }
}
