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
                    'Allgemeine Hinweise',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Nachfolgend möchten wir Sie über die Art, den Umfang und die Zwecke der Erhebung und Verwendung Ihrer personenbezogenen Daten auf unserer Webseite informieren. Wir behandeln personenbezogene Daten gemäß dieser Datenschutzerklärung und der gesetzlichen Vorschriften grundsätzlich vertraulich. Den Schutz Ihrer persönlichen Daten nehmen wir sehr ernst. Wenn Sie unsere Website benutzen, werden verschiedene personenbezogene Daten erhoben. Personenbezogene Daten sind Daten, mit denen Sie persönlich identifiziert werden können. Die vorliegende Datenschutzerklärung erläutert, welche Daten wir erheben und wofür wir diese nutzen. Sie erläutert auch, wie und zu welchem Zweck das geschieht. Eine Datenübertragung im Internet kann z.B. bei E-Mail-Kommunikation Sicherheitslücken aufweisen Wir möchten Sie darauf hinweisen, dass ein lückenloser Schutz der Daten vor dem Zugriff durch Dritte nicht möglich ist.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Datenschutzrichtlinie des Bayerischen Sportschützenbundes MeinBSSB',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  const Divider(),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Datenerfassung auf unserer Website',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Wer ist verantwortlich für die Datenerfassung auf dieser Website?',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Bayerischer Sportschützenbund e.V.\n\nIngolstädter Landstraße 110\n85748 Garching-Hochbrück\n\nTelefon: +49 89 316949-0\nE-Mail: gs@bssb.bayern',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  ScaledText(
                    'Gesetzliche Vertretung',
                    style: UIStyles.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    '1. Landesschützenmeister Christian Kühn\nstv. Landesschützenmeister Dieter Vierlbeck\nstv. Landesschützenmeister Hans Hainthaler\nstv. Landesschützenmeister Albert Euba\nstv. Landesschützenmeister Stefan Fersch',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  ScaledText(
                    'Geschäftsführer',
                    style: UIStyles.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Alexander Heidel',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  ScaledText(
                    'Datenschutzbeauftragter',
                    style: UIStyles.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                  ),
                  UIConstants.verticalSpacingS,
                  RichText(
                    text: TextSpan(
                      style: UIStyles.bodyStyle,
                      children: [
                        const TextSpan(text: 'Herbert Isdebski\nScheibenhalde 1\n72160 Horb-Nordstetten\n\nTel: (07451) 6 25 42 40 '),
                        TextSpan(
                          text: '(Sprechstunde für BSSB-Mitglieder: jeder erste Donnerstag im Monat, 16 bis 18 Uhr)',
                          style: UIStyles.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: '\nE-Mail: datenschutz@bssb.de'),
                      ],
                    ),
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
                    'Unsere in Anspruch genommenen Hosting-Leistungen, um den Betrieb der Homepage sicherzustellen, umfassen folgende Leistungen: Plattformdienstleistungen, Webspace, Datenbank, technische Wartung.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  const Divider(),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Welche Daten werden erfasst und wie?',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Server-Log-Dateien',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Der Provider der Seiten erhebt und speichert automatisch Informationen in so genannten Server-Log-Dateien, die Ihr Browser automatisch übermittelt. Dies sind:\n\n• Browsertyp und Browserversion\n• verwendetes Betriebssystem\n• Referrer URL\n• Hostname des zugreifenden Rechners\n• Uhrzeit der Serveranfrage\n• IP-Adresse',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Diese werden benötigt, um Angriffe, einen fehlerhaften Code oder allgemeine Fehler zu identifizieren und werden nach vier Wochen vom Webserver automatisch gelöscht. Eine Zusammenführung dieser Daten mit anderen Datenquellen findet nicht statt. Grundlage für die Datenverarbeitung ist Art. 6 Abs. 1, b DSGVO, der die Verarbeitung von Daten zur Erfüllung eines Vertrags oder vorvertraglicher Maßnahmen gestattet.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  const Divider(),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Cookies',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Die Internetseiten verwendet so genannte Cookies. Cookies richten auf Ihrem Rechner keinen Schaden an und enthalten keine Viren. Cookies dienen dazu, unser Angebot nutzerfreundlicher, effektiver und sicherer zu machen. Cookies sind kleine Textdateien, die auf Ihrem Rechner abgelegt werden und die Ihr Browser speichert.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Die meisten der von uns verwendeten Cookies sind so genannte "Session-Cookies". Sie werden nach Ende Ihres Besuchs automatisch gelöscht. Andere Cookies bleiben auf Ihrem Endgerät gespeichert bis Sie diese löschen. Diese Cookies ermöglichen es uns, Ihren Browser beim nächsten Besuch wiederzuerkennen.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Sie können Ihren Browser so einstellen, dass Sie über das Setzen von Cookies informiert werden und Cookies nur im Einzelfall erlauben, die Annahme von Cookies für bestimmte Fälle oder generell ausschließen sowie das automatische Löschen der Cookies beim Schließen des Browsers aktivieren. Bei der Deaktivierung von Cookies kann die Funktionalität dieser Website eingeschränkt sein.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Cookies, die zur Durchführung des elektronischen Kommunikationsvorgangs oder zur Bereitstellung bestimmter, von Ihnen erwünschter Funktionen (z.B. Warenkorbfunktion) erforderlich sind, werden auf Grundlage von Art. 6 Abs. 1, f DSGVO gespeichert. Der Websitebetreiber hat ein berechtigtes Interesse an der Speicherung von Cookies zur technisch fehlerfreien und optimierten Bereitstellung seiner Dienste.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  const Divider(),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Cookie-Informationen',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Diese Webseite verwendet Cookies. Wir verwenden Cookies, um Inhalte und Anzeigen zu personalisieren, Funktionen für soziale Medien anbieten zu können und die Zugriffe auf unsere Website zu analysieren. Außerdem geben wir Informationen zu Ihrer Verwendung unserer Website an unsere Partner für soziale Medien, Werbung und Analysen weiter. Unsere Partner führen diese Informationen möglicherweise mit weiteren Daten zusammen, die Sie ihnen bereitgestellt haben oder die sie im Rahmen Ihrer Nutzung der Dienste gesammelt haben.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Cookies sind kleine Textdateien, die von Webseiten verwendet werden, um die Benutzererfahrung effizienter zu gestalten.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Laut Gesetz können wir Cookies auf Ihrem Gerät speichern, wenn diese für den Betrieb dieser Seite unbedingt notwendig sind. Für alle anderen Cookie-Typen benötigen wir Ihre Erlaubnis.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Diese Seite verwendet unterschiedliche Cookie-Typen. Einige Cookies werden von Drittparteien platziert, die auf unseren Seiten erscheinen.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Sie können Ihre Einwilligung jederzeit von der Cookie-Erklärung auf unserer Website ändern oder widerrufen.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Erfahren Sie in unserer Datenschutzrichtlinie mehr darüber, wer wir sind, wie Sie uns kontaktieren können und wie wir personenbezogene Daten verarbeiten.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Bitte geben Sie Ihre Einwilligungs-ID und das Datum an, wenn Sie uns bezüglich Ihrer Einwilligung kontaktieren.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Ihre Einwilligung trifft auf die folgenden Domains zu: www.mein.bssb.de',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Die Cookie-Erklärung wurde das letzte Mal am 07.10.25 von Cookiebot aktualisiert.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Notwendig (3)',
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
                    'rememberMe',
                    'Boolean',
                    'Speichert, ob Sie "Angemeldet bleiben" aktiviert haben. Speichert das Benutzerpasswort.',
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
                    'Speichert Ihre bevorzugte Schriftgröße (Skalierungsfaktor).',
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
                    'Speichert Ihre PersonID.',
                  ),
                  _buildDataItem(
                    'cache_webLoginId',
                    'Integer',
                    'Ihre WebLoginID für die API-Authentifizierung.',
                  ),
                  _buildDataItem(
                    'cache_bezirke_search',
                    'JSON String',
                    'Zwischengespeicherte Bezirkssuchdaten für schnelleren Zugriff.',
                  ),
                  _buildDataItem(
                    'cache_bezirke_search_timestamp',
                    'Integer',
                    'Zeitstempel für die Bezirkssuchdaten-Validierung.',
                  ),
                  _buildDataItem(
                    'cache_schulungen',
                    'JSON String',
                    'Zwischengespeicherte Schulungsdaten zur Offline-Verfügbarkeit.',
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
                  const ScaledText(
                    'Analyse-Tools und Tools von Drittanbietern',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Wir verwenden keine Analyse-Tools und Tools von Drittanbietern.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  const Divider(),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Kontaktformulare, des Deutschen Schützenbundes',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Wir verarbeiten Daten (z. B. Namen und Adressen sowie Kontaktdaten von Nutzern), die in den Kontaktformularen, Anmeldung für RSS-Feeds oder im Onlinemelder erhoben werden, um vertraglichen Verpflichtungen, Serviceleistungen und der Organisation von Wettkämpfen und Veranstaltungen nachzukommen. Ebenso werden die Vertragsdaten bei Aus- und Weiterbildungen bei einer Abo-Bestellung oder einer Bestellung im BSSB-Online-Shop (z.B. in Anspruch genommene Leistungen, Name, Adresse, Kontaktdaten, Zahlungsinformationen) zwecks Erfüllung unserer vertraglichen Verpflichtungen gem. Art. 6 Abs. 1 DSGVO verarbeitet.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  const Divider(),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Welche Rechte haben Sie bezüglich Ihrer Daten?',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Auskunft, Sperrung, Löschung',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Sie haben jederzeit das Recht unentgeltlich Auskunft über Herkunft, Empfänger und Zweck Ihrer gespeicherten personenbezogenen Daten zu erhalten. Sie haben außerdem das Recht, die Berichtigung, Sperrung oder Löschung Ihrer Daten zu verlangen. Des Weiteren steht Ihnen ein Beschwerderecht bei der zuständigen Aufsichtsbehörde zu.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Widerruf Ihrer Einwilligung zur Datenverarbeitung',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Viele Datenverarbeitungsvorgänge sind nur mit Ihrer ausdrücklichen Einwilligung möglich. Sie können eine bereits erteilte Einwilligung jederzeit widerrufen. Dazu reicht eine formlose Mitteilung per E-Mail an uns. Die Rechtmäßigkeit der bis zum Widerruf erfolgten Datenverarbeitung bleibt vom Widerruf unberührt.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Veröffentlichung von Daten und Fotos auf der Homepage',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'In unseren online-Medien wird von Wettbewerben in Ton, Bild, Video und Text berichtet. Außerdem werden Ergebnislisten dieser Wettbewerbe veröffentlicht. Eine entsprechende Ergebnisliste ist zwingender Bestandteil des sportlichen Wettkampfes, denn dem sportlichen Wettbewerb ist es immanent, dass man sich mit seinem sportlichen Kontrahent misst und vergleicht und am Ende feststellt, wer der bessere ist. Diese Feststellung geschieht durch die Veröffentlichung der Ergebnisliste. Damit hat diese aber auch eine Bedeutung für die Zukunft, denn auch zukünftig ist es aus sportlicher Sicht interessant zu wissen, wie der einzelne Teilnehmer bei dem Wettbewerben abgeschnitten hat.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Mit der Teilnahme an einem Wettbewerb erklärt sich der Teilnehmer bereit, dass diese Daten, Bilder, Videos erfasst und veröffentlicht werden. Eine spätere Löschung dieser oder Streichung insbesondere aus den Ergebnislisten erfolgt daher nicht; auch nicht bei Austritt des Teilnehmers aus dem BSSB.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Sportlerinnen und Sportler, die eine Veröffentlichung ihrer Daten in Ergebnislisten sowie Berichterstattung von Wettbewerben mit ihrer Namensnennung oder Veröffentlichung ihrer Person in Ton, Bild oder Film auf dem Siegertreppchen oder Wettkampf nicht wünschen, dürfen daher nicht an dem Wettbewerb teilnehmen.',
                    style: UIStyles.bodyStyle,
                  ),
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

