import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/models/user_data.dart';
import '/screens/base_screen_layout.dart';
import 'package:meinbssb/widgets/scaled_text.dart';

class DatenschutzScreen extends StatelessWidget {
  const DatenschutzScreen({
    super.key,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });
  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Datenschutz',
      userData: userData,
      isLoggedIn: isLoggedIn,
      onLogout: onLogout,
      body: Semantics(
        label:
            'Datenschutz. Übersicht über alle gespeicherten Daten in dieser App und deren Verwendungszweck.',
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: UIConstants.maxContentWidth,
              ),
              margin: const EdgeInsets.symmetric(
                vertical: UIConstants.spacingL,
                horizontal: UIConstants.spacingM,
              ),
              padding: UIConstants.defaultPadding,
              decoration: BoxDecoration(
                color: UIConstants.cardColor,
                borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
                boxShadow: UIStyles.cardDecoration.boxShadow,
              ),
              child: Focus(
                autofocus: true,
                child: Semantics(
                  label:
                      'Datenschutz. Alle Datenschutzkapitel und rechtliche Hinweise.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ScaledText(
                        'Datenschutz',
                        style: UIStyles.headerStyle,
                      ),
                      UIConstants.verticalSpacingM,
                      const Divider(),
                      UIConstants.verticalSpacingM,
                      const ScaledText(
                        'Allgemeine Hinweise',
                        style: UIStyles.sectionTitleStyle,
                      ),
                      UIConstants.verticalSpacingS,
                      const ScaledText(
                        'Die nachfolgenden Hinweise geben einen Überblick darüber, welche Daten in dieser App gespeichert werden und wie diese verwendet werden.',
                        style: UIStyles.bodyStyle,
                      ),
                      UIConstants.verticalSpacingM,
                      const ScaledText(
                        'Datenspeicherung und -verwendung',
                        style: UIStyles.sectionTitleStyle,
                      ),
                      UIConstants.verticalSpacingS,
                      const ScaledText(
                        'Ihre Daten werden ausschließlich zur Bereitstellung der Funktionen dieser App verwendet. Eine Weitergabe an Dritte erfolgt nicht.',
                        style: UIStyles.bodyStyle,
                      ),
                      UIConstants.verticalSpacingM,
                      const Divider(),
                      UIConstants.verticalSpacingM,
                      const ScaledText(
                        'Gespeicherte Daten',
                        style: UIStyles.sectionTitleStyle,
                      ),
                      UIConstants.verticalSpacingS,
                      const ScaledText(
                        'Folgende Daten werden in der App gespeichert:',
                        style: UIStyles.bodyStyle,
                      ),
                      UIConstants.verticalSpacingS,
                      const ScaledText(
                        '• Anmeldestatus (ob Sie aktuell angemeldet sind)\n• Benutzerdaten (PersonID, Name, Passnummer, etc.)\n• "Angemeldet bleiben"-Status und Passwort\n• E-Mail-Adresse für "Angemeldet bleiben"\n• Verschlüsseltes Passwort im Secure Storage\n• Temporäres verschlüsseltes Passwort für die aktuelle Sitzung\n• Cookie-Hinweis-Akzeptanz\n• Bevorzugte Schriftgröße (Skalierungsfaktor)',
                        style: UIStyles.bodyStyle,
                      ),
                      UIConstants.verticalSpacingM,
                      const Divider(),
                      UIConstants.verticalSpacingM,
                      const ScaledText(
                        'Weitere gespeicherte Daten',
                        style: UIStyles.sectionTitleStyle,
                      ),
                      UIConstants.verticalSpacingS,
                      const ScaledText(
                        '• Zwischengespeicherter Benutzername für Offline-Login\n• Fallback-Passwort\n• PersonID\n• WebLoginID für API-Authentifizierung\n• Zwischengespeicherte Bezirkssuchdaten\n• Zeitstempel für Bezirkssuchdaten-Validierung\n• Zwischengespeicherte Schulungsdaten\n• Zeitstempel für Cache-Validierung\n• Verschiedene gecachte API-Antworten zur Offline-Nutzung',
                        style: UIStyles.bodyStyle,
                      ),
                      UIConstants.verticalSpacingM,
                      const Divider(),
                      UIConstants.verticalSpacingM,
                      const ScaledText(
                        'Bilddaten',
                        style: UIStyles.sectionTitleStyle,
                      ),
                      UIConstants.verticalSpacingS,
                      const ScaledText(
                        '• Schützenausweis-Bild zur Offline-Anzeige\n• Zeitstempel für das Schützenausweis-Bild\n• Zeitstempel für verschiedene ZMI-Bilder',
                        style: UIStyles.bodyStyle,
                      ),
                      UIConstants.verticalSpacingM,
                      const Divider(),
                      UIConstants.verticalSpacingM,
                      const ScaledText(
                        'Rechtliche Hinweise',
                        style: UIStyles.sectionTitleStyle,
                      ),
                      UIConstants.verticalSpacingS,
                      const ScaledText(
                        'Ihre Daten werden gemäß den geltenden Datenschutzbestimmungen behandelt. Sie haben jederzeit das Recht auf Auskunft, Berichtigung und Löschung Ihrer Daten.',
                        style: UIStyles.bodyStyle,
                      ),
                      UIConstants.verticalSpacingM,
                      const Divider(),
                      const SizedBox(height: UIConstants.helpSpacing),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Semantics(
        child: Tooltip(
          message: 'Datenschutz schließen',
          child: FloatingActionButton(
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: UIConstants.defaultAppColor,
            child: Semantics(
              label: 'Datenschutz schließen',
              hint:
                  'Tippen, um den Datenschutz zu schließen und zur vorherigen Seite zurückzukehren',
              button: true,
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
