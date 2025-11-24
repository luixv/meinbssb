import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/models/user_data.dart';
import '/screens/base_screen_layout.dart';
import 'package:provider/provider.dart';
import '/widgets/scaled_text.dart';
import '/providers/font_size_provider.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({
    super.key,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });
  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FontSizeProvider fontSizeProvider = Provider.of<FontSizeProvider>(
      context,
    );

    return BaseScreenLayout(
      title: 'Datenschutz',
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout,
      body: Focus(
        autofocus: true,
        onKey: (node, event) {
          if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
            _scrollController.animateTo(
              _scrollController.offset + 100,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
            );
            return KeyEventResult.handled;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
            _scrollController.animateTo(
              _scrollController.offset - 100,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
            );
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Semantics(
          label:
              'Datenschutzbereich mit Informationen zur Datenverarbeitung, Hosting, Cookies, Rechte und Sicherheit beim Bayerischen Sportschützenbund.',
          child: Center(
            child: SingleChildScrollView(
              controller: _scrollController,
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
                    _buildSectionHeader(
                      'Datenschutzerklärung',
                      isMainSection: true,
                      fontSizeProvider: fontSizeProvider,
                    ),
                    UIConstants.verticalSpacingM,
                    ExcludeSemantics(child: const Divider()),
                    UIConstants.verticalSpacingM,
                    _buildSectionHeader(
                      'Verantwortlicher und Datenschutzbeauftragter',
                      fontSizeProvider: fontSizeProvider,
                    ),
                    UIConstants.verticalSpacingS,
                    _addressBlock([
                      'Bayerischer Sportschützenbund e.V.',
                      'Olympia-Schießanlage Hochbrück',
                      'Ingolstädter Landstraße 110',
                      '85748 Garching',
                    ], fontSizeProvider: fontSizeProvider),
                    UIConstants.verticalSpacingXS,
                    _contactRow(
                      phone: '0893169490',
                      email: 'gs@bssb.bayern',
                      web: 'https://www.bssb.de',
                      fontSizeProvider: fontSizeProvider,
                    ),
                    UIConstants.verticalSpacingXS,
                    ScaledText(
                      'Datenschutzbeauftragter:',
                      style: UIStyles.bodyStyle.copyWith(
                        fontSize:
                            UIStyles.bodyStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _addressBlock([
                      'Herbert Isdebski',
                      'Scheibenhalde 1',
                      '72160 Horb-Nordstetten',
                    ], fontSizeProvider: fontSizeProvider),
                    _contactRow(
                      phone: '074516254240',
                      email: 'datenschutz@bssb.de',
                      fontSizeProvider: fontSizeProvider,
                    ),
                    UIConstants.verticalSpacingM,
                    _buildSectionHeader(
                      'Hosting',
                      fontSizeProvider: fontSizeProvider,
                    ),
                    UIConstants.verticalSpacingXS,
                    _addressBlock([
                      'Unsere in Anspruch genommenen Hosting-Leistungen, um den Betrieb der Homepage sicherzustellen, umfassen folgende Leistungen:',
                      'Plattformdienstleistungen, Webspace, Datenbank, technische Wartung.',
                      'Provider: Hetzner Online GmbH',
                      'Industriestr. 25, 91710 Gunzenhausen, Deutschland',
                      'Telefon: +49 (0)9831 505-0',
                      'E-Mail: info@hetzner.com',
                    ], fontSizeProvider: fontSizeProvider),
                    UIConstants.verticalSpacingM,
                    _buildSectionHeader(
                      'Welche Daten werden erfasst und wie?',
                      fontSizeProvider: fontSizeProvider,
                    ),
                    UIConstants.verticalSpacingXS,
                    ScaledText(
                      'Server-Log-Dateien',
                      style: UIStyles.bodyStyle.copyWith(
                        fontSize:
                            UIStyles.bodyStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  _bulletList([
                    'Browsertyp und Browserversion',
                    'verwendetes Betriebssystem',
                    'Referrer URL',
                    'Hostname des zugreifenden Rechners',
                    'Uhrzeit der Serveranfrage',
                    'IP-Adresse',
                  ], fontSizeProvider),
                  ScaledText(
                    'Diese werden benötigt, um Angriffe, einen fehlerhaften Code oder allgemeine Fehler zu identifizieren und werden nach vier Wochen vom Webserver automatisch gelöscht. Eine Zusammenführung dieser Daten mit anderen Datenquellen findet nicht statt. Grundlage für die Datenverarbeitung ist Art. 6 Abs. 1, b DSGVO, der die Verarbeitung von Daten zur Erfüllung eines Vertrags oder vorvertraglicher Maßnahmen gestattet.',
                    style: UIStyles.bodyStyle.copyWith(
                      fontSize:
                          UIStyles.bodyStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                    ),
                  ),
                  UIConstants.verticalSpacingXS,
                  ScaledText(
                    'Cookies',
                    style: UIStyles.bodyStyle.copyWith(
                      fontSize:
                          UIStyles.bodyStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ScaledText(
                    'Die Internetseiten verwendet so genannte Cookies. Cookies richten auf Ihrem Rechner keinen Schaden an und enthalten keine Viren. Cookies dienen dazu, unser Angebot nutzerfreundlicher, effektiver und sicherer zu machen. Cookies sind kleine Textdateien, die auf Ihrem Rechner abgelegt werden und die Ihr Browser speichert.',
                    style: UIStyles.bodyStyle.copyWith(
                      fontSize:
                          UIStyles.bodyStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                    ),
                  ),
                  _bulletList([
                    'Session-Cookies: Werden nach Ende Ihres Besuchs automatisch gelöscht.',
                    'Persistente Cookies: Bleiben auf Ihrem Endgerät gespeichert, bis Sie diese löschen.',
                  ], fontSizeProvider),
                  ScaledText(
                    'Sie können Ihren Browser so einstellen, dass Sie über das Setzen von Cookies informiert werden und Cookies nur im Einzelfall erlauben, die Annahme von Cookies für bestimmte Fälle oder generell ausschließen sowie das automatische Löschen der Cookies beim Schließen des Browsers aktivieren. Bei der Deaktivierung von Cookies kann die Funktionalität dieser Website eingeschränkt sein.',
                    style: UIStyles.bodyStyle.copyWith(
                      fontSize:
                          UIStyles.bodyStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                    ),
                  ),
                  ScaledText(
                    'Cookies, die zur Durchführung des elektronischen Kommunikationsvorgangs oder zur Bereitstellung bestimmter, von Ihnen erwünschter Funktionen (z.B. Warenkorbfunktion) erforderlich sind, werden auf Grundlage von Art. 6 Abs. 1, f DSGVO gespeichert. Der Websitebetreiber hat ein berechtigtes Interesse an der Speicherung von Cookies zur technisch fehlerfreien und optimierten Bereitstellung seiner Dienste.',
                    style: UIStyles.bodyStyle.copyWith(
                      fontSize:
                          UIStyles.bodyStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                    ),
                  ),
                  UIConstants.verticalSpacingXS,
                  ScaledText(
                    'Cookie-Einstellungen und Widerruf der Einwilligung',
                    style: UIStyles.bodyStyle.copyWith(
                      fontSize:
                          UIStyles.bodyStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ScaledText(
                    'Sie können Ihre Cookie-Einstellungen jederzeit in Ihrem Browser anpassen und bereits gesetzte Cookies löschen. Viele Browser bieten zudem die Möglichkeit, das Setzen von Cookies generell zu unterbinden. Hinweise dazu finden Sie in der Hilfefunktion Ihres Browsers.',
                    style: UIStyles.bodyStyle.copyWith(
                      fontSize:
                          UIStyles.bodyStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                    ),
                  ),
                  UIConstants.verticalSpacingM,
                  _buildSectionHeader(
                    'Wofür werden erhobene Daten genutzt?',
                    fontSizeProvider: fontSizeProvider,
                  ),
                  UIConstants.verticalSpacingXS,
                  ScaledText(
                    'Ein Teil der Daten wird erhoben, um eine fehlerfreie Bereitstellung der Website zu gewährleisten. Andere Daten können zur Analyse Ihres Nutzerverhaltens verwendet werden.',
                    style: UIStyles.bodyStyle.copyWith(
                      fontSize:
                          UIStyles.bodyStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                    ),
                  ),
                  UIConstants.verticalSpacingXS,
                  ScaledText(
                    'Analyse-Tools und Tools von Drittanbietern',
                    style: UIStyles.bodyStyle.copyWith(
                      fontSize:
                          UIStyles.bodyStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ScaledText(
                    'Wir verwenden keine Analyse-Tools und Tools von Drittanbietern.',
                    style: UIStyles.bodyStyle.copyWith(
                      fontSize:
                          UIStyles.bodyStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                    ),
                  ),
                  UIConstants.verticalSpacingXS,
                  ScaledText(
                    'Kontaktformulare, RSS-Feeds, Onlinemelder, BSSB-Abo-Bestellung, BSSB-Online-Shop, Veasy-Lizenzprogramm des Deutschen Schützenbundes',
                    style: UIStyles.bodyStyle.copyWith(
                      fontSize:
                          UIStyles.bodyStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ScaledText(
                    'Wir verarbeiten Daten (z. B. Namen und Adressen sowie Kontaktdaten von Nutzern), die in den Kontaktformularen, Anmeldung für RSS-Feeds oder im Onlinemelder erhoben werden, um vertraglichen Verpflichtungen, Serviceleistungen und der Organisation von Wettkämpfen und Veranstaltungen nachzukommen. Ebenso werden die Vertragsdaten bei einer Abo-Bestellung oder einer Bestellung im BSSB-Online-Shop (z.B. in Anspruch genommene Leistungen, Name, Adresse, Kontaktdaten, Zahlungsinformationen) zwecks Erfüllung unserer vertraglichen Verpflichtungen gem. Art. 6 Abs. 1 DSGVO verarbeitet.',
                    style: UIStyles.bodyStyle.copyWith(
                      fontSize:
                          UIStyles.bodyStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                    ),
                  ),
                  UIConstants.verticalSpacingXS,
                  ScaledText(
                    'Newsletter',
                    style: UIStyles.bodyStyle.copyWith(
                      fontSize:
                          UIStyles.bodyStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ScaledText(
                    'Wenn Sie den auf der Website angebotenen Newsletter beziehen möchten, benötigen wir von Ihnen eine E-Mail-Adresse sowie Informationen, welche uns die Überprüfung gestatten, dass Sie der Inhaber der angegebenen E-Mail-Adresse sind und mit dem Empfang des Newsletters einverstanden sind. Weitere Daten werden nicht bzw. nur auf freiwilliger Basis erhoben. Diese Daten verwenden wir ausschließlich für den Versand der angeforderten Informationen und geben diese nicht an Dritte weiter.',
                    style: UIStyles.bodyStyle.copyWith(
                      fontSize:
                          UIStyles.bodyStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                    ),
                  ),
                  ScaledText(
                    'Die erteilte Einwilligung zur Speicherung der Daten, der E-Mail-Adresse sowie deren Nutzung zum Versand des Newsletters können Sie jederzeit widerrufen, etwa über den "Austragen"-Link im Newsletter.',
                    style: UIStyles.bodyStyle.copyWith(
                      fontSize:
                          UIStyles.bodyStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                    ),
                  ),
                  UIConstants.verticalSpacingXS,
                  ScaledText(
                    'Routenplaner',
                    style: UIStyles.bodyStyle.copyWith(
                      fontSize:
                          UIStyles.bodyStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ScaledText(
                    'Im Service-Center auf unserer Homepage ist als Routenplaner Google Maps implementiert. Hierfür gelten die Datenschutzerklärung und Nutzungsbedingungen von Google: https://policies.google.com/privacy?hl=de&gl=de',
                    style: UIStyles.bodyStyle.copyWith(
                      fontSize:
                          UIStyles.bodyStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                    ),
                  ),
                  UIConstants.verticalSpacingM,
                  _buildSectionHeader(
                    'Datenübermittlung an Dritte und Drittstaaten',
                    fontSizeProvider: fontSizeProvider,
                  ),
                  UIConstants.verticalSpacingXS,
                  ScaledText(
                    'Eine Übermittlung Ihrer personenbezogenen Daten an Dritte findet nur statt, wenn dies gesetzlich erlaubt ist oder Sie eingewilligt haben. Eine Übermittlung in Drittstaaten außerhalb der EU/des EWR erfolgt nur, wenn dies zur Vertragserfüllung erforderlich ist, gesetzlich vorgeschrieben ist oder Sie uns Ihre Einwilligung erteilt haben.',
                    style: UIStyles.bodyStyle.copyWith(
                      fontSize:
                          UIStyles.bodyStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                    ),
                  ),
                  UIConstants.verticalSpacingM,
                  _buildSectionHeader(
                    'Speicherdauer und Datenlöschung',
                    fontSizeProvider: fontSizeProvider,
                  ),
                  UIConstants.verticalSpacingXS,
                  ScaledText(
                    'Ihre personenbezogenen Daten werden gelöscht, sobald der Zweck der Speicherung entfällt, Sie Ihre Einwilligung widerrufen oder der Löschung keine gesetzlichen Aufbewahrungspflichten entgegenstehen.',
                    style: UIStyles.bodyStyle.copyWith(
                      fontSize:
                          UIStyles.bodyStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                    ),
                  ),
                  UIConstants.verticalSpacingM,
                  _buildSectionHeader(
                    'Datensicherheit',
                    fontSizeProvider: fontSizeProvider,
                  ),
                  UIConstants.verticalSpacingXS,
                  ScaledText(
                    'Wir setzen technische und organisatorische Sicherheitsmaßnahmen ein, um Ihre durch uns verwalteten Daten gegen zufällige oder vorsätzliche Manipulationen, Verlust, Zerstörung oder gegen den Zugriff unberechtigter Personen zu schützen. Unsere Sicherheitsmaßnahmen werden entsprechend der technologischen Entwicklung fortlaufend verbessert.',
                    style: UIStyles.bodyStyle.copyWith(
                      fontSize:
                          UIStyles.bodyStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                    ),
                  ),
                  UIConstants.verticalSpacingM,
                  _buildSectionHeader(
                    'Rechte der betroffenen Person',
                    fontSizeProvider: fontSizeProvider,
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
                  ], fontSizeProvider),
                  UIConstants.verticalSpacingM,
                  _buildSectionHeader(
                    'Widerspruchsrecht',
                    fontSizeProvider: fontSizeProvider,
                  ),
                  UIConstants.verticalSpacingXS,
                  ScaledText(
                    'Sofern Ihre personenbezogenen Daten auf Grundlage von berechtigten Interessen gemäß Art. 6 Abs. 1 lit. f DSGVO verarbeitet werden, haben Sie das Recht, gemäß Art. 21 DSGVO Widerspruch gegen die Verarbeitung Ihrer personenbezogenen Daten einzulegen, soweit dafür Gründe vorliegen, die sich aus Ihrer besonderen Situation ergeben.',
                    style: UIStyles.bodyStyle.copyWith(
                      fontSize:
                          UIStyles.bodyStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                    ),
                  ),
                  UIConstants.verticalSpacingM,
                  _buildSectionHeader(
                    'SSL- bzw. TLS-Verschlüsselung',
                    fontSizeProvider: fontSizeProvider,
                  ),
                  UIConstants.verticalSpacingXS,
                  ScaledText(
                    'Diese Seite nutzt aus Sicherheitsgründen und zum Schutz der Übertragung vertraulicher Inhalte, wie zum Beispiel Bestellungen oder Anfragen, die Sie an uns als Seitenbetreiber senden, eine SSL-bzw. TLS-Verschlüsselung. Eine verschlüsselte Verbindung erkennen Sie daran, dass die Adresszeile des Browsers von "http://" auf "https://" wechselt und an dem Schloss-Symbol in Ihrer Browserzeile. Wenn die SSL- bzw. TLS-Verschlüsselung aktiviert ist, können die Daten, die Sie an uns übermitteln, nicht von Dritten mitgelesen werden.',
                    style: UIStyles.bodyStyle.copyWith(
                      fontSize:
                          UIStyles.bodyStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                    ),
                  ),
                    UIConstants.verticalSpacingM,
                    ScaledText(
                      'Weitere Informationen finden Sie unter:',
                      style: UIStyles.bodyStyle.copyWith(
                        fontSize:
                            UIStyles.bodyStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                      ),
                    ),
                    _LinkText(
                      'https://www.bssb.de/datenschutz',
                      'https://www.bssb.de/datenschutz',
                      fontSizeProvider: fontSizeProvider,
                    ),
                    const SizedBox(height: UIConstants.helpSpacing),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Semantics(
        label: 'Datenschutz schließen',
        hint: 'Tippen, um den Datenschutzbereich zu schließen und zur vorherigen Seite zurückzukehren',
        button: true,
        child: FloatingActionButton(
          onPressed: () => Navigator.of(context).pop(),
          backgroundColor: UIConstants.defaultAppColor,
          child: const Icon(Icons.close, color: Colors.white),
        ),
      ),
    );
  }
}

// Helper method to build section headers with proper semantics
Widget _buildSectionHeader(
  String title, {
  bool isMainSection = false,
  required FontSizeProvider fontSizeProvider,
}) {
  return Semantics(
    header: true,
    label: '$title, ${isMainSection ? "Hauptabschnitt" : "Abschnittsüberschrift"}',
    child: ScaledText(
      title,
      style: UIStyles.dialogContentStyle.copyWith(
        fontSize: (isMainSection
                ? UIStyles.headerStyle.fontSize!
                : UIStyles.sectionTitleStyle.fontSize!) *
            fontSizeProvider.scaleFactor,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget _addressBlock(
  List<String> lines, {
  required FontSizeProvider fontSizeProvider,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: UIConstants.spacingXS),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: UIConstants.spacingXXS),
            child: ScaledText(
              line,
              style: UIStyles.dialogContentStyle.copyWith(
                fontSize:
                    UIStyles.bodyStyle.fontSize! * fontSizeProvider.scaleFactor,
              ),
            ),
          ),
      ],
    ),
  );
}

Widget _contactRow({
  String? phone,
  String? email,
  String? web,
  required FontSizeProvider fontSizeProvider,
}) {
  final contactInfo = <String>[];
  if (phone != null) contactInfo.add('Telefon $phone');
  if (email != null) contactInfo.add('E-Mail $email');
  if (web != null) contactInfo.add('Website $web');
  
  return Semantics(
    label: 'Kontaktinformationen: ${contactInfo.join(", ")}',
    child: Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.spacingXS),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: UIConstants.spacingSM,
        runSpacing: UIConstants.spacingXS,
        children: [
          if (phone != null)
            ExcludeSemantics(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.phone,
                    size: UIConstants.bodyFontSize,
                    color: UIConstants.defaultAppColor,
                  ),
                  const SizedBox(width: UIConstants.spacingXS),
                  ScaledText(
                    phone,
                    style: UIStyles.bodyStyle.copyWith(
                      fontSize:
                          UIStyles.bodyStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                      color: UIConstants.defaultAppColor,
                    ),
                  ),
                ],
              ),
            ),
          if (email != null)
            ExcludeSemantics(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.email,
                    size: UIConstants.bodyFontSize,
                    color: UIConstants.defaultAppColor,
                  ),
                  const SizedBox(width: UIConstants.spacingXS),
                  Flexible(
                    child: ScaledText(
                      email,
                      style: UIStyles.bodyStyle.copyWith(
                        fontSize:
                            UIStyles.bodyStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                        color: UIConstants.defaultAppColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (web != null)
            ExcludeSemantics(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.language,
                    size: UIConstants.bodyFontSize,
                    color: UIConstants.defaultAppColor,
                  ),
                  const SizedBox(width: UIConstants.spacingXS),
                  Flexible(
                    child: ScaledText(
                      web,
                      style: UIStyles.bodyStyle.copyWith(
                        fontSize:
                            UIStyles.bodyStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                        color: UIConstants.defaultAppColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

Widget _bulletList(List<String> items, FontSizeProvider fontSizeProvider) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final item in items)
        Padding(
          padding: const EdgeInsets.only(bottom: UIConstants.spacingXXS),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScaledText(
                '• ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: UIStyles.bodyStyle.fontSize! *
                      fontSizeProvider.scaleFactor,
                ),
              ),
              Expanded(
                child: ScaledText(
                  item,
                  style: UIStyles.dialogContentStyle.copyWith(
                    fontSize:
                        UIStyles.bodyStyle.fontSize! *
                        fontSizeProvider.scaleFactor,
                  ),
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

class _LinkText extends StatelessWidget {
  const _LinkText(
    this.text,
    this.url, {
    required this.fontSizeProvider,
  });

  final String text;
  final String url;
  final FontSizeProvider fontSizeProvider;

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
        style: TextStyle(
          color: UIConstants.defaultAppColor,
          decoration: TextDecoration.underline,
          fontSize: UIStyles.bodyStyle.fontSize! * fontSizeProvider.scaleFactor,
        ),
      ),
    );
  }
}
