import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/models/user_data.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key, required this.userData});
  final UserData? userData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Datenschutz', style: UIStyles.appBarTitleStyle),
        backgroundColor: UIConstants.backgroundColor,
        elevation: UIConstants.appBarElevation,
        iconTheme: const IconThemeData(color: UIConstants.textColor),
      ),
      body: Semantics(
        label:
            'Datenschutzbereich mit Informationen zur Datenverarbeitung, Hosting, Cookies, Rechte und Sicherheit beim Bayerischen Sportschützenbund.',
        child: Center(
          child: SingleChildScrollView(
            child: Container(
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
                  // Main Title
                  const Text(
                    'Datenschutzerklärung',
                    style: UIStyles.headerStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  const Divider(),
                  UIConstants.verticalSpacingM,
                  // Verantwortlicher
                  const Text(
                    'Verantwortlicher und Datenschutzbeauftragter',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  _addressBlock([
                    'Bayerischer Sportschützenbund e.V.',
                    'Olympia-Schießanlage Hochbrück',
                    'Ingolstädter Landstraße 110',
                    '85748 Garching',
                  ]),
                  UIConstants.verticalSpacingXS,
                  _contactRow(
                    phone: '0893169490',
                    email: 'gs@bssb.bayern',
                    web: 'https://www.bssb.de',
                  ),
                  UIConstants.verticalSpacingXS,
                  const Text(
                    'Datenschutzbeauftragter:',
                    style: UIStyles.bodyStyle,
                  ),
                  _addressBlock([
                    'Herbert Isdebski',
                    'Scheibenhalde 1',
                    '72160 Horb-Nordstetten',
                  ]),
                  _contactRow(
                    phone: '074516254240',
                    email: 'datenschutz@bssb.de',
                  ),
                  UIConstants.verticalSpacingM,
                  // Hosting
                  const Text('Hosting', style: UIStyles.sectionTitleStyle),
                  UIConstants.verticalSpacingXS,
                  _addressBlock([
                    'Unsere in Anspruch genommenen Hosting-Leistungen, um den Betrieb der Homepage sicherzustellen, umfassen folgende Leistungen:',
                    'Plattformdienstleistungen, Webspace, Datenbank, technische Wartung.',
                    'Provider: Hetzner Online GmbH',
                    'Industriestr. 25, 91710 Gunzenhausen, Deutschland',
                    'Telefon: +49 (0)9831 505-0',
                    'E-Mail: info@hetzner.com',
                  ]),
                  UIConstants.verticalSpacingM,
                  // Welche Daten werden erfasst und wie?
                  const Text(
                    'Welche Daten werden erfasst und wie?',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingXS,
                  const Text('Server-Log-Dateien', style: UIStyles.bodyStyle),
                  _bulletList([
                    'Browsertyp und Browserversion',
                    'verwendetes Betriebssystem',
                    'Referrer URL',
                    'Hostname des zugreifenden Rechners',
                    'Uhrzeit der Serveranfrage',
                    'IP-Adresse',
                  ]),
                  const Text(
                    'Diese werden benötigt, um Angriffe, einen fehlerhaften Code oder allgemeine Fehler zu identifizieren und werden nach vier Wochen vom Webserver automatisch gelöscht. Eine Zusammenführung dieser Daten mit anderen Datenquellen findet nicht statt. Grundlage für die Datenverarbeitung ist Art. 6 Abs. 1, b DSGVO, der die Verarbeitung von Daten zur Erfüllung eines Vertrags oder vorvertraglicher Maßnahmen gestattet.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingXS,
                  const Text('Cookies', style: UIStyles.bodyStyle),
                  const Text(
                    'Die Internetseiten verwendet so genannte Cookies. Cookies richten auf Ihrem Rechner keinen Schaden an und enthalten keine Viren. Cookies dienen dazu, unser Angebot nutzerfreundlicher, effektiver und sicherer zu machen. Cookies sind kleine Textdateien, die auf Ihrem Rechner abgelegt werden und die Ihr Browser speichert.',
                    style: UIStyles.bodyStyle,
                  ),
                  _bulletList([
                    'Session-Cookies: Werden nach Ende Ihres Besuchs automatisch gelöscht.',
                    'Persistente Cookies: Bleiben auf Ihrem Endgerät gespeichert, bis Sie diese löschen.',
                  ]),
                  const Text(
                    'Sie können Ihren Browser so einstellen, dass Sie über das Setzen von Cookies informiert werden und Cookies nur im Einzelfall erlauben, die Annahme von Cookies für bestimmte Fälle oder generell ausschließen sowie das automatische Löschen der Cookies beim Schließen des Browsers aktivieren. Bei der Deaktivierung von Cookies kann die Funktionalität dieser Website eingeschränkt sein.',
                    style: UIStyles.bodyStyle,
                  ),
                  const Text(
                    'Cookies, die zur Durchführung des elektronischen Kommunikationsvorgangs oder zur Bereitstellung bestimmter, von Ihnen erwünschter Funktionen (z.B. Warenkorbfunktion) erforderlich sind, werden auf Grundlage von Art. 6 Abs. 1, f DSGVO gespeichert. Der Websitebetreiber hat ein berechtigtes Interesse an der Speicherung von Cookies zur technisch fehlerfreien und optimierten Bereitstellung seiner Dienste.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingXS,
                  const Text(
                    'Cookie-Einstellungen und Widerruf der Einwilligung',
                    style: UIStyles.bodyStyle,
                  ),
                  const Text(
                    'Sie können Ihre Cookie-Einstellungen jederzeit in Ihrem Browser anpassen und bereits gesetzte Cookies löschen. Viele Browser bieten zudem die Möglichkeit, das Setzen von Cookies generell zu unterbinden. Hinweise dazu finden Sie in der Hilfefunktion Ihres Browsers.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  // Wofür werden erhobene Daten genutzt?
                  const Text(
                    'Wofür werden erhobene Daten genutzt?',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingXS,
                  const Text(
                    'Ein Teil der Daten wird erhoben, um eine fehlerfreie Bereitstellung der Website zu gewährleisten. Andere Daten können zur Analyse Ihres Nutzerverhaltens verwendet werden.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingXS,
                  const Text(
                    'Analyse-Tools und Tools von Drittanbietern',
                    style: UIStyles.bodyStyle,
                  ),
                  const Text(
                    'Wir verwenden keine Analyse-Tools und Tools von Drittanbietern.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingXS,
                  const Text(
                    'Kontaktformulare, RSS-Feeds, Onlinemelder, BSSB-Abo-Bestellung, BSSB-Online-Shop, Veasy-Lizenzprogramm des Deutschen Schützenbundes',
                    style: UIStyles.bodyStyle,
                  ),
                  const Text(
                    'Wir verarbeiten Daten (z. B. Namen und Adressen sowie Kontaktdaten von Nutzern), die in den Kontaktformularen, Anmeldung für RSS-Feeds oder im Onlinemelder erhoben werden, um vertraglichen Verpflichtungen, Serviceleistungen und der Organisation von Wettkämpfen und Veranstaltungen nachzukommen. Ebenso werden die Vertragsdaten bei einer Abo-Bestellung oder einer Bestellung im BSSB-Online-Shop (z.B. in Anspruch genommene Leistungen, Name, Adresse, Kontaktdaten, Zahlungsinformationen) zwecks Erfüllung unserer vertraglichen Verpflichtungen gem. Art. 6 Abs. 1 DSGVO verarbeitet.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingXS,
                  const Text('Newsletter', style: UIStyles.bodyStyle),
                  const Text(
                    'Wenn Sie den auf der Website angebotenen Newsletter beziehen möchten, benötigen wir von Ihnen eine E-Mail-Adresse sowie Informationen, welche uns die Überprüfung gestatten, dass Sie der Inhaber der angegebenen E-Mail-Adresse sind und mit dem Empfang des Newsletters einverstanden sind. Weitere Daten werden nicht bzw. nur auf freiwilliger Basis erhoben. Diese Daten verwenden wir ausschließlich für den Versand der angeforderten Informationen und geben diese nicht an Dritte weiter.',
                    style: UIStyles.bodyStyle,
                  ),
                  const Text(
                    'Die erteilte Einwilligung zur Speicherung der Daten, der E-Mail-Adresse sowie deren Nutzung zum Versand des Newsletters können Sie jederzeit widerrufen, etwa über den "Austragen"-Link im Newsletter.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingXS,
                  const Text('Routenplaner', style: UIStyles.bodyStyle),
                  const Text(
                    'Im Service-Center auf unserer Homepage ist als Routenplaner Google Maps implementiert. Hierfür gelten die Datenschutzerklärung und Nutzungsbedingungen von Google: https://policies.google.com/privacy?hl=de&gl=de',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  // Datenübermittlung an Dritte und Drittstaaten
                  const Text(
                    'Datenübermittlung an Dritte und Drittstaaten',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingXS,
                  const Text(
                    'Eine Übermittlung Ihrer personenbezogenen Daten an Dritte findet nur statt, wenn dies gesetzlich erlaubt ist oder Sie eingewilligt haben. Eine Übermittlung in Drittstaaten außerhalb der EU/des EWR erfolgt nur, wenn dies zur Vertragserfüllung erforderlich ist, gesetzlich vorgeschrieben ist oder Sie uns Ihre Einwilligung erteilt haben.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  // Speicherdauer und Datenlöschung
                  const Text(
                    'Speicherdauer und Datenlöschung',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingXS,
                  const Text(
                    'Ihre personenbezogenen Daten werden gelöscht, sobald der Zweck der Speicherung entfällt, Sie Ihre Einwilligung widerrufen oder der Löschung keine gesetzlichen Aufbewahrungspflichten entgegenstehen.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  // Datensicherheit
                  const Text(
                    'Datensicherheit',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingXS,
                  const Text(
                    'Wir setzen technische und organisatorische Sicherheitsmaßnahmen ein, um Ihre durch uns verwalteten Daten gegen zufällige oder vorsätzliche Manipulationen, Verlust, Zerstörung oder gegen den Zugriff unberechtigter Personen zu schützen. Unsere Sicherheitsmaßnahmen werden entsprechend der technologischen Entwicklung fortlaufend verbessert.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  // Rechte der betroffenen Person
                  const Text(
                    'Rechte der betroffenen Person',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingXS,
                  _bulletList([
                    'gemäß Art. 15 DSGVO Auskunft über Ihre von uns verarbeiteten personenbezogenen Daten zu verlangen;',
                    'gemäß Art. 16 DSGVO unverzüglich die Berichtigung unrichtiger oder Vervollständigung Ihrer bei uns gespeicherten personenbezogenen Daten zu verlangen;',
                    'gemäß Art. 17 DSGVO die Löschung Ihrer bei uns gespeicherten personenbezogenen Daten zu verlangen, soweit nicht die Verarbeitung zur Erfüllung einer rechtlichen Verpflichtung, aus Gründen des öffentlichen Interesses oder zur Geltendmachung, Ausübung oder Verteidigung von Rechtsansprüchen erforderlich ist;',
                    'gemäß Art. 18 DSGVO die Einschränkung der Verarbeitung Ihrer personenbezogenen Daten zu verlangen;',
                    'gemäß Art. 20 DSGVO Ihre personenbezogenen Daten, die Sie uns bereitgestellt haben, in einem strukturierten, gängigen und maschinenlesbaren Format zu erhalten oder die Übermittlung an einen anderen Verantwortlichen zu verlangen;',
                    'gemäß Art. 7 Abs. 3 DSGVO Ihre einmal erteilte Einwilligung jederzeit gegenüber uns zu widerrufen;',
                    'gemäß Art. 77 DSGVO sich bei einer Aufsichtsbehörde zu beschweren.',
                  ]),
                  UIConstants.verticalSpacingM,
                  // Widerspruchsrecht
                  const Text(
                    'Widerspruchsrecht',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingXS,
                  const Text(
                    'Sofern Ihre personenbezogenen Daten auf Grundlage von berechtigten Interessen gemäß Art. 6 Abs. 1 lit. f DSGVO verarbeitet werden, haben Sie das Recht, gemäß Art. 21 DSGVO Widerspruch gegen die Verarbeitung Ihrer personenbezogenen Daten einzulegen, soweit dafür Gründe vorliegen, die sich aus Ihrer besonderen Situation ergeben.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  // SSL- bzw. TLS-Verschlüsselung
                  const Text(
                    'SSL- bzw. TLS-Verschlüsselung',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingXS,
                  const Text(
                    'Diese Seite nutzt aus Sicherheitsgründen und zum Schutz der Übertragung vertraulicher Inhalte, wie zum Beispiel Bestellungen oder Anfragen, die Sie an uns als Seitenbetreiber senden, eine SSL-bzw. TLS-Verschlüsselung. Eine verschlüsselte Verbindung erkennen Sie daran, dass die Adresszeile des Browsers von "http://" auf "https://" wechselt und an dem Schloss-Symbol in Ihrer Browserzeile. Wenn die SSL- bzw. TLS-Verschlüsselung aktiviert ist, können die Daten, die Sie an uns übermitteln, nicht von Dritten mitgelesen werden.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  // Footer
                  const Text(
                    'Weitere Informationen finden Sie unter:',
                    style: UIStyles.bodyStyle,
                  ),
                  const _LinkText(
                    'https://www.bssb.de/datenschutz',
                    'https://www.bssb.de/datenschutz',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pop(),
        backgroundColor: UIConstants.defaultAppColor,
        child: const Icon(Icons.close, color: Colors.white),
      ),
    );
  }
}

Widget _addressBlock(List<String> lines) {
  return Padding(
    padding: const EdgeInsets.only(bottom: UIConstants.spacingXS),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: UIConstants.spacingXXS),
            child: Text(line, style: UIStyles.bodyStyle),
          ),
      ],
    ),
  );
}

Widget _contactRow({String? phone, String? email, String? web}) {
  return Row(
    children: [
      if (phone != null) ...[
        const Icon(
          Icons.phone,
          size: UIConstants.defaultIconSize,
          color: UIConstants.defaultAppColor,
        ),
        UIConstants.horizontalSpacingXS,
        _LinkText('Telefon', 'tel:$phone'),
        UIConstants.horizontalSpacingS,
      ],
      if (email != null) ...[
        const Icon(
          Icons.email,
          size: UIConstants.defaultIconSize,
          color: UIConstants.defaultAppColor,
        ),
        UIConstants.horizontalSpacingXS,
        _LinkText(email, 'mailto:$email'),
        UIConstants.horizontalSpacingS,
      ],
      if (web != null) ...[
        const Icon(
          Icons.language,
          size: UIConstants.defaultIconSize,
          color: UIConstants.defaultAppColor,
        ),
        UIConstants.horizontalSpacingXS,
        _LinkText('Webseite', web),
      ],
    ],
  );
}

Widget _bulletList(List<String> items) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final item in items)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(child: Text(item, style: UIStyles.bodyStyle)),
          ],
        ),
    ],
  );
}

class _LinkText extends StatelessWidget {
  const _LinkText(this.text, this.url);

  final String text;
  final String url;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
      child: Text(
        text,
        style: const TextStyle(
          color: UIConstants.defaultAppColor,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
