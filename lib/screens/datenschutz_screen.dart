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
      body: Focus(
        autofocus: true,
        child: Semantics(
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
                    Semantics(
                      label:
                          'Datenschutz. Übersicht über alle gespeicherten Daten in dieser App und deren Verwendungszweck.',
                      child: const ScaledText(
                        'Datenschutz',
                        style: UIStyles.headerStyle,
                      ),
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
                      'Diese App speichert verschiedene Daten, um die Funktionalität und Benutzerfreundlichkeit zu gewährleisten. Nachfolgend finden Sie eine Übersicht über die gespeicherten Daten und deren Verwendungszweck.',
                      style: UIStyles.bodyStyle,
                    ),
                    UIConstants.verticalSpacingM,
                    const ScaledText(
                      'Cookies',
                      style: UIStyles.sectionTitleStyle,
                    ),
                    UIConstants.verticalSpacingS,
                    const ScaledText(
                      'Notwendige Cookies helfen dabei, eine Webseite nutzbar zu machen, indem sie Grundfunktionen wie Seitennavigation und Zugriff auf sichere Bereiche der Webseite ermöglichen. Die Webseite kann ohne diese Cookies nicht richtig funktionieren.',
                      style: UIStyles.bodyStyle,
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
                      'stayLoggedIn',
                      'Boolean',
                      'Speichert, ob Sie "Angemeldet bleiben" aktiviert haben. Speichert das Benutzerpasswort.',
                    ),
                    _buildDataItem(
                      'email',
                      'String',
                      'Speichert Ihre E-Mail-Adresse für die "Angemeldet bleiben" Funktion.',
                    ),
                    _buildDataItem(
                      'password',
                      'String',
                      'Speichert Ihr Passwort verschlüsselt im Secure Storage für die "Angemeldet bleiben" Funktion.',
                    ),
                    _buildDataItem(
                      'sessionPassword',
                      'String',
                      'Temporäres verschlüsseltes Passwort im Secure Storage für die aktuelle Sitzung.',
                    ),
                    _buildDataItem(
                      'cookieAccepted',
                      'Boolean',
                      'Speichert, ob Sie die Cookie-Hinweise akzeptiert haben.',
                    ),
                    _buildDataItem(
                      'fontScale',
                      'Double',
                      'Speichert Ihre bevorzugte Schriftgröße (Skalierungsfaktor).',
                    ),
                    UIConstants.verticalSpacingM,
                    const Divider(),
                    UIConstants.verticalSpacingM,
                    const ScaledText(
                      'Zwischengespeicherte Daten',
                      style: UIStyles.sectionTitleStyle,
                    ),
                    UIConstants.verticalSpacingS,
                    _buildDataItem(
                      'offlineUsername',
                      'String',
                      'Zwischengespeicherter Benutzername für Offline-Login.',
                    ),
                    _buildDataItem(
                      'fallbackPassword',
                      'String',
                      'Fallback-Passwort wenn Secure Storage nicht verfügbar ist.',
                    ),
                    _buildDataItem(
                      'personId',
                      'String',
                      'Speichert Ihre PersonID.',
                    ),
                    _buildDataItem(
                      'webLoginId',
                      'String',
                      'Ihre WebLoginID für die API-Authentifizierung.',
                    ),
                    _buildDataItem(
                      'districtSearchCache',
                      'List',
                      'Zwischengespeicherte Bezirkssuchdaten für schnelleren Zugriff.',
                    ),
                    _buildDataItem(
                      'districtSearchTimestamp',
                      'DateTime',
                      'Zeitstempel für die Bezirkssuchdaten-Validierung.',
                    ),
                    _buildDataItem(
                      'trainingCache',
                      'List',
                      'Zwischengespeicherte Schulungsdaten zur Offline-Verfügbarkeit.',
                    ),
                    _buildDataItem(
                      'cacheTimestamp',
                      'DateTime',
                      'Zeitstempel für Cache-Validierung. Bestimmt, wann gecachte Daten erneuert werden müssen.',
                    ),
                    _buildDataItem(
                      'apiResponses',
                      'Map',
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
                    UIConstants.verticalSpacingM,
                    const Divider(),
                    UIConstants.verticalSpacingM,
                    const ScaledText(
                      'Wofür werden erhobene Daten genutzt?',
                      style: UIStyles.sectionTitleStyle,
                    ),
                    UIConstants.verticalSpacingS,
                    const ScaledText(
                      'Ein Teil der Daten wird erhoben, um eine fehlerfreie Bereitstellung der Website zu gewährleisten. Andere Daten können zur Analyse Ihres Nutzerverhaltens verwendet werden.',
                      style: UIStyles.bodyStyle,
                    ),
                    UIConstants.verticalSpacingM,
                    const Divider(),
                    UIConstants.verticalSpacingM,
                    const ScaledText(
                      'Hosting',
                      style: UIStyles.sectionTitleStyle,
                    ),
                    UIConstants.verticalSpacingS,
                    const ScaledText(
                      'Die App und die zugehörigen Server werden bei einem deutschen Anbieter gehostet. Es gelten die deutschen Datenschutzbestimmungen.',
                      style: UIStyles.bodyStyle,
                    ),
                    UIConstants.verticalSpacingM,
                    const Divider(),
                    UIConstants.verticalSpacingM,
                    const ScaledText(
                      'Veröffentlichung von Daten',
                      style: UIStyles.sectionTitleStyle,
                    ),
                    UIConstants.verticalSpacingS,
                    const ScaledText(
                      'Eine Veröffentlichung personenbezogener Daten erfolgt ausschließlich im Rahmen gesetzlicher Vorgaben oder mit Ihrer ausdrücklichen Einwilligung.',
                      style: UIStyles.bodyStyle,
                    ),
                    UIConstants.verticalSpacingM,
                    const ScaledText(
                      'Weitergabe an Dritte',
                      style: UIStyles.sectionTitleStyle,
                    ),
                    UIConstants.verticalSpacingS,
                    const ScaledText(
                      'Eine Weitergabe Ihrer Daten an Dritte erfolgt nur, sofern dies zur Vertragserfüllung notwendig ist, gesetzlich vorgeschrieben ist oder Sie ausdrücklich eingewilligt haben.',
                      style: UIStyles.bodyStyle,
                    ),
                    UIConstants.verticalSpacingM,
                    const ScaledText(
                      'Rechtsgrundlagen der Verarbeitung',
                      style: UIStyles.sectionTitleStyle,
                    ),
                    UIConstants.verticalSpacingS,
                    const ScaledText(
                      'Die Verarbeitung Ihrer Daten erfolgt auf Grundlage der DSGVO, insbesondere Art. 6 Abs. 1 lit. a (Einwilligung), lit. b (Vertragserfüllung), lit. c (rechtliche Verpflichtung) und lit. f (berechtigtes Interesse).',
                      style: UIStyles.bodyStyle,
                    ),
                    UIConstants.verticalSpacingM,
                    const Divider(),
                    UIConstants.verticalSpacingM,
                    const ScaledText(
                      'Beschwerderecht bei der zuständigen Aufsichtsbehörde',
                      style: UIStyles.sectionTitleStyle,
                    ),
                    UIConstants.verticalSpacingS,
                    const ScaledText(
                      'Im Falle datenschutzrechtlicher Verstöße steht dem Betroffenen ein Beschwerderecht bei der zuständigen Aufsichtsbehörde zu. Die Beschwerde kann über den Link https://www.lda.bayern.de/de/beschwerde.html an die zuständigen Landesdatenschutzbeauftragten der Aufsichtsbehörde in Bayern erfolgen.',
                      style: UIStyles.bodyStyle,
                    ),
                    UIConstants.verticalSpacingM,
                    const ScaledText(
                      'Recht auf Datenübertragbarkeit',
                      style: UIStyles.sectionTitleStyle,
                    ),
                    UIConstants.verticalSpacingS,
                    const ScaledText(
                      'Sie haben das Recht, Daten, die wir auf Grundlage Ihrer Einwilligung oder in Erfüllung eines Vertrags automatisiert verarbeiten, an sich oder an einen Dritten in einem gängigen, maschinenlesbaren Format aushändigen zu lassen. Sofern Sie die direkte Übertragung der Daten an einen anderen Verantwortlichen verlangen, erfolgt dies nur, soweit es technisch machbar ist.',
                      style: UIStyles.bodyStyle,
                    ),
                    UIConstants.verticalSpacingM,
                    const ScaledText(
                      'SSL- bzw. TLS-Verschlüsselung',
                      style: UIStyles.sectionTitleStyle,
                    ),
                    UIConstants.verticalSpacingS,
                    const ScaledText(
                      'Diese Seite nutzt aus Sicherheitsgründen und zum Schutz der Übertragung vertraulicher Inhalte, wie zum Beispiel Bestellungen oder Anfragen, die Sie an uns als Seitenbetreiber senden, eine SSL-bzw. TLS-Verschlüsselung. Eine verschlüsselte Verbindung erkennen Sie daran, dass die Adresszeile des Browsers von "http://" auf "https://" wechselt und an dem Schloss-Symbol in Ihrer Browserzeile. Wenn die SSL- bzw. TLS-Verschlüsselung aktiviert ist, können die Daten, die Sie an uns übermitteln, nicht von Dritten mitgelesen werden.',
                      style: UIStyles.bodyStyle,
                    ),
                  ],
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
