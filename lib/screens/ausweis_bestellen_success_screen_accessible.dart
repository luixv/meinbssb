import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/constants/messages.dart';
import '/screens/base_screen_layout_accessible.dart';
import '/models/user_data.dart';
import '/widgets/scaled_text.dart';
import '../providers/font_size_provider.dart';

/// BITV 2.0 konforme Version der Schützenausweis-Bestellbestätigung
///
/// Erfüllt deutsche Barrierefreiheitsstandards (BITV 2.0/WCAG 2.1 Level AA):
/// - Vollständige Semantik-Unterstützung für Screen Reader
/// - Deutsche Sprachanpassung für Accessibility
/// - Live-Region-Ankündigungen für Erfolgsmeldungen
/// - Erweiterte Tastaturnavigation
/// - Kontextuelle Navigations-Labels
/// - Fokus-Management für Erfolgsbestätigung
class AusweisBestellendSuccessScreenAccessible extends StatefulWidget {
  const AusweisBestellendSuccessScreenAccessible({
    super.key,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });

  final UserData? userData;
  final bool isLoggedIn;
  final VoidCallback onLogout;

  @override
  State<AusweisBestellendSuccessScreenAccessible> createState() =>
      _AusweisBestellendSuccessScreenAccessibleState();
}

class _AusweisBestellendSuccessScreenAccessibleState
    extends State<AusweisBestellendSuccessScreenAccessible> {
  @override
  void initState() {
    super.initState();
    // Erfolgsankündigung für Screen Reader nach dem Laden der Seite
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SemanticsService.announce(
        'Erfolg! Die Bestellung des Schützenausweises wurde erfolgreich abgeschlossen. '
        'Sie befinden sich nun auf der Bestätigungsseite. Verwenden Sie den Home-Button, um zur Startseite zurückzukehren.',
        TextDirection.ltr,
      );
    });
  }

  void _navigateToHome() {
    // Navigations-Ankündigung für Screen Reader
    SemanticsService.announce(
      'Navigation zur Startseite wird gestartet.',
      TextDirection.ltr,
    );

    Navigator.of(context).pushReplacementNamed(
      '/home',
      arguments: {'userData': widget.userData, 'isLoggedIn': widget.isLoggedIn},
    );
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Semantics(
      label:
          'Schützenausweis-Bestellung erfolgreich abgeschlossen - Bestätigungsseite',
      child: BaseScreenLayoutAccessible(
        title: Messages.ausweisBestellenTitle,
        userData: widget.userData,
        isLoggedIn: widget.isLoggedIn,
        onLogout: widget.onLogout,
        body: Semantics(
          container: true,
          label: 'Erfolgsbestätigung für Schützenausweis-Bestellung',
          child: Center(
            child: Padding(
              padding: UIConstants.screenPadding,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Erfolgs-Icon mit umfassender Accessibility
                    Semantics(
                      label: 'Erfolgreich abgeschlossen',
                      hint:
                          'Ihre Schützenausweis-Bestellung wurde erfolgreich verarbeitet',
                      image: true,
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.green,
                            width: 2.0,
                          ),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: UIConstants.iconSizeXL,
                          semanticLabel: 'Erfolgreich abgeschlossen Symbol',
                        ),
                      ),
                    ),

                    const SizedBox(height: UIConstants.spacingL),

                    // Haupterfolgs-Nachricht mit Live Region
                    Semantics(
                      liveRegion: true,
                      header: true,
                      label:
                          'Erfolgs-Nachricht: Die Bestellung des Schützenausweises wurde erfolgreich abgeschlossen',
                      child: Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          children: [
                            ScaledText(
                              'Die Bestellung des Schützenausweises wurde erfolgreich abgeschlossen.',
                              style: UIStyles.dialogContentStyle.copyWith(
                                fontSize:
                                    UIStyles.dialogContentStyle.fontSize! *
                                        fontSizeProvider.scaleFactor,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade800,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: UIConstants.spacingM),

                            // Zusätzliche Erfolgs-Details
                            Semantics(
                              readOnly: true,
                              label: 'Bestelldetails und nächste Schritte',
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Semantics(
                                          label: 'Informations-Symbol',
                                          child: Icon(
                                            Icons.info_outline,
                                            color: Colors.blue.shade700,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Was passiert als nächstes:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue.shade800,
                                              fontSize: 16.0 *
                                                  fontSizeProvider.scaleFactor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '• Sie erhalten eine Bestätigungs-E-Mail\n'
                                      '• Die Bearbeitung dauert 5-10 Werktage\n'
                                      '• Der digitale Ausweis wird in Ihr Profil übertragen\n'
                                      '• Bei Fragen kontaktieren Sie unseren Support',
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontSize:
                                            14.0 * fontSizeProvider.scaleFactor,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: UIConstants.spacingL),

                    // Sekundäre Nachricht mit besserer Accessibility
                    Semantics(
                      readOnly: true,
                      label:
                          'Navigations-Hinweis: Sie können nun zu Ihrem Profil zurückkehren',
                      child: ScaledText(
                        'Sie können nun zu Ihrem Profil zurückkehren.',
                        style: UIStyles.bodyStyle.copyWith(
                          fontSize: UIStyles.bodyStyle.fontSize! *
                              fontSizeProvider.scaleFactor,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: UIConstants.spacingXL),

                    // Zusätzlicher Home-Button für bessere Accessibility
                    Semantics(
                      button: true,
                      enabled: true,
                      label: 'Zur Startseite zurückkehren. Schaltfläche.',
                      hint:
                          'Navigiert Sie zurück zur Haupt-Anwendung und Ihrem Profil',
                      child: ElevatedButton.icon(
                        onPressed: _navigateToHome,
                        icon: const Icon(
                          Icons.home,
                          semanticLabel: 'Startseite Symbol',
                        ),
                        label: const Text(
                          'Zur Startseite',
                          style: TextStyle(
                            fontSize: 16,
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
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Floating Action Button mit verbesserter Accessibility
        floatingActionButton: Semantics(
          button: true,
          enabled: true,
          label: 'Schnell-Navigation zur Startseite. Floating Button.',
          hint:
              'Alternative Schaltfläche um schnell zur Hauptseite zurückzukehren',
          child: FloatingActionButton(
            heroTag: 'ausweisBestellenSuccessFab',
            onPressed: _navigateToHome,
            backgroundColor: UIConstants.defaultAppColor,
            tooltip: 'Zur Startseite zurückkehren',
            child: const Icon(
              Icons.home,
              color: UIConstants.whiteColor,
              semanticLabel: 'Startseite Navigation',
            ),
          ),
        ),
      ),
    );
  }
}
