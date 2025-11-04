import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import '/screens/base_screen_layout.dart';

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
                    'Lokal gespeicherte Daten (SharedPreferences)',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Die folgenden Daten werden lokal auf Ihrem Gerät gespeichert und nicht an Dritte weitergegeben:',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  _buildDataItem(
                    'isLoggedIn',
                    'Boolean',
                    'Speichert, ob Sie aktuell angemeldet sind. Wird verwendet, um Sie automatisch zur Startseite weiterzuleiten.',
                  ),
                  _buildDataItem(
                    'userData',
                    'JSON String',
                    'Speichert Ihre Benutzerdaten (PersonID, Name, Passnummer, etc.). Wird für die Anzeige Ihrer persönlichen Informationen verwendet.',
                  ),
                  _buildDataItem(
                    'rememberMe',
                    'Boolean',
                    'Speichert, ob Sie "Angemeldet bleiben" aktiviert haben. Ermöglicht automatisches Login beim nächsten Start.',
                  ),
                  _buildDataItem(
                    'savedEmail',
                    'String',
                    'Speichert Ihre E-Mail-Adresse für die "Angemeldet bleiben" Funktion.',
                  ),
                  _buildDataItem(
                    'saved_password_remember_me',
                    'String (verschlüsselt)',
                    'Speichert Ihr Passwort verschlüsselt im Secure Storage für die "Angemeldet bleiben" Funktion.',
                  ),
                  _buildDataItem(
                    'password',
                    'String (verschlüsselt)',
                    'Temporäres verschlüsseltes Passwort im Secure Storage für die aktuelle Sitzung.',
                  ),
                  _buildDataItem(
                    'cookieConsentAccepted',
                    'Boolean',
                    'Speichert, ob Sie die Cookie-Hinweise akzeptiert haben.',
                  ),
                  _buildDataItem(
                    'fontSizeScale',
                    'Double',
                    'Speichert Ihre bevorzugte Schriftgröße (Skalierungsfaktor). Standard: 1.0',
                  ),
                  UIConstants.verticalSpacingM,
                  const Divider(),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Cache-Daten (mit Präfix "cache_")',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Folgende Daten werden temporär gecacht und automatisch nach einer bestimmten Zeit gelöscht:',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  _buildDataItem(
                    'cache_username',
                    'String',
                    'Zwischengespeicherter Benutzername für Offline-Login.',
                  ),
                  _buildDataItem(
                    'cache_password_fallback',
                    'String',
                    'Fallback-Passwort wenn Secure Storage nicht verfügbar ist.',
                  ),
                  _buildDataItem(
                    'cache_personId',
                    'Integer',
                    'Ihre PersonID aus dem ZMI-System.',
                  ),
                  _buildDataItem(
                    'cache_webLoginId',
                    'Integer',
                    'Ihre WebLoginID für die API-Authentifizierung.',
                  ),
                  _buildDataItem(
                    'cache_timestamp_*',
                    'Integer',
                    'Zeitstempel für Cache-Validierung. Bestimmt, wann gecachte Daten erneuert werden müssen.',
                  ),
                  _buildDataItem(
                    'cache_*_data',
                    'JSON String',
                    'Verschiedene gecachte API-Antworten (z.B. Passdaten, Schulungen, Vereinsdaten, etc.) zur Offline-Nutzung.',
                  ),
                  UIConstants.verticalSpacingM,
                  const Divider(),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Bilder-Cache',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  _buildDataItem(
                    'schuetzenausweis_<personId>.jpg',
                    'Base64 String',
                    'Ihr Schützenausweis-Bild zur Offline-Anzeige.',
                  ),
                  _buildDataItem(
                    'schuetzenausweis_<personId>_timestamp',
                    'Integer',
                    'Zeitstempel für das Schützenausweis-Bild.',
                  ),
                  _buildDataItem(
                    'zmi_*_timestamp',
                    'Integer',
                    'Zeitstempel für verschiedene ZMI-Bilder.',
                  ),
                  UIConstants.verticalSpacingM,
                  const Divider(),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Datenlöschung',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Alle lokal gespeicherten Daten werden gelöscht, wenn Sie:',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const Padding(
                    padding: EdgeInsets.only(left: UIConstants.spacingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScaledText(
                          '• Sich abmelden',
                          style: UIStyles.bodyStyle,
                        ),
                        ScaledText(
                          '• Die App deinstallieren',
                          style: UIStyles.bodyStyle,
                        ),
                        ScaledText(
                          '• Den App-Cache manuell löschen',
                          style: UIStyles.bodyStyle,
                        ),
                      ],
                    ),
                  ),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Cache-Daten werden automatisch nach Ablauf der Cache-Dauer (konfigurierbar) gelöscht.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  const Divider(),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Sicherheit',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Passwörter werden verschlüsselt im Flutter Secure Storage gespeichert. Unter Android wird encryptedSharedPreferences verwendet. Alle Daten bleiben auf Ihrem Gerät und werden nicht an Dritte weitergegeben.',
                    style: UIStyles.bodyStyle,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataItem(String key, String type, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.spacingS,
                  vertical: UIConstants.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: UIConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ScaledText(
                  key,
                  style: UIStyles.bodyStyle.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: UIConstants.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: UIConstants.spacingS),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.spacingS,
                  vertical: UIConstants.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: UIConstants.greySubtitleTextColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ScaledText(
                  type,
                  style: UIStyles.bodyStyle.copyWith(
                    fontSize: 12,
                    color: UIConstants.greySubtitleTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.spacingXS),
          Padding(
            padding: const EdgeInsets.only(left: UIConstants.spacingS),
            child: ScaledText(
              description,
              style: UIStyles.bodyStyle.copyWith(
                color: UIConstants.greySubtitleTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

