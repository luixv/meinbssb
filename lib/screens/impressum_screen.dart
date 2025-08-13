import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/models/user_data.dart';

class ImpressumScreen extends StatelessWidget {
  const ImpressumScreen({
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
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Impressum', style: UIStyles.appBarTitleStyle),
        backgroundColor: UIConstants.backgroundColor,
        elevation: UIConstants.appBarElevation,
        iconTheme: const IconThemeData(color: UIConstants.textColor),
      ),
      body: Center(
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
                  'Impressum',
                  style: UIStyles.headerStyle,
                ),
                UIConstants.verticalSpacingM,
                const Divider(),
                UIConstants.verticalSpacingM,
                // Gesamtverantwortung
                const Text(
                  'Gesamtverantwortung',
                  style: UIStyles.sectionTitleStyle,
                ),
                UIConstants.verticalSpacingS,
                Text(
                  'Bayerischer Sportschützenbund e.V.',
                  style:
                      UIStyles.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                ),
                const Text(
                  '1. Landesschützenmeister: Christian Kühn',
                  style: UIStyles.bodyStyle,
                ),
                UIConstants.verticalSpacingXS,
                _addressBlock([
                  'Olympia-Schießanlage Hochbrück',
                  'Ingolstädter Landstraße 110',
                  '85748 Garching',
                  'Eingetragen im Vereinsregister des Amtsgerichts München: VR 4803',
                ]),
                UIConstants.verticalSpacingXS,
                _contactRow(
                  phone: '0893169490',
                  email: 'gs@bssb.bayern',
                  web: 'https://www.bssb.de',
                ),
                UIConstants.verticalSpacingM,
                // Datenschutzbeauftragter
                const Text(
                  'Datenschutzbeauftragter',
                  style: UIStyles.sectionTitleStyle,
                ),
                UIConstants.verticalSpacingS,
                _addressBlock([
                  'Herbert Isdebski',
                  'Scheibenhalde 1',
                  '72160 Horb-Nordstetten',
                ]),
                UIConstants.verticalSpacingXS,
                _contactRow(
                  phone: '074516254240',
                  email: 'datenschutz@bssb.de',
                ),
                UIConstants.verticalSpacingXS,
                Text(
                  'Telefon-Sprechstunde für BSSB-Mitglieder:',
                  style:
                      UIStyles.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                ),
                const Text(
                  'jeder erste Donnerstag im Monat, 16 bis 18 Uhr',
                  style: UIStyles.bodyStyle,
                ),
                UIConstants.verticalSpacingM,
                // Inhaltlich verantwortlich für die Teilbereiche
                const Text(
                  'Inhaltlich verantwortlich für die Teilbereiche',
                  style: UIStyles.sectionTitleStyle,
                ),
                UIConstants.verticalSpacingS,
                _subSection(
                  title: 'Verband',
                  name: 'Herr Alexander Heidel',
                  address: [
                    'Bayerischer Sportschützenbund e.V.',
                    'Olympia-Schießanlage Hochbrück',
                    'Ingolstädter Landstraße 110',
                    '85748 Garching',
                  ],
                  phone: '0893169490',
                  email: 'alexander.heidel@bssb.bayern',
                ),
                UIConstants.verticalSpacingS,
                _subSection(
                  title: 'Sport',
                  name: 'Herr Josef Lederer',
                  address: [
                    'Bayerischer Sportschützenbund e.V.',
                    'Olympia-Schießanlage Hochbrück',
                    'Ingolstädter Landstraße 110',
                    '85748 Garching',
                  ],
                  phone: '0893169490',
                  email: 'josef.lederer@bssb.de',
                ),
                UIConstants.verticalSpacingS,
                _subSection(
                  title: 'Jugend',
                  name: 'Herr Markus Maas',
                  address: [
                    'Bayerischer Sportschützenbund e.V.',
                    'Olympia-Schießanlage Hochbrück',
                    'Ingolstädter Landstraße 110',
                    '85748 Garching',
                  ],
                  phone: '0893169490',
                  email: 'jugend@bssb.bayern',
                ),
                UIConstants.verticalSpacingM,
                const Text(
                  'Hinweis zur Sprache',
                  style: UIStyles.sectionTitleStyle,
                ),
                UIConstants.verticalSpacingXS,
                const Text(
                  'Aus Gründen der besseren Lesbarkeit wird auf die gleichzeitige Verwendung männlicher und weiblicher Sprachformen verzichtet. Sämtliche Personenbezeichnungen gelten gleichermaßen für alle Geschlechter.',
                  style: UIStyles.bodyStyle,
                ),
                UIConstants.verticalSpacingM,
                const Text(
                  'Bezirke / Gaue / Vereine',
                  style: UIStyles.sectionTitleStyle,
                ),
                UIConstants.verticalSpacingXS,
                const Text(
                  'Für die Liste aller Bezirke und Gaue ist der BSSB verantwortlich.',
                  style: UIStyles.bodyStyle,
                ),
                const Text(
                  'Für die Liste aller Vereine sind die Vereine selbst verantwortlich.',
                  style: UIStyles.bodyStyle,
                ),
                Text(
                  'Für den Inhalt der Unterseiten von Gauen, Bezirken und Vereinen sind diese selbst verantwortlich.',
                  style:
                      UIStyles.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                ),
                UIConstants.verticalSpacingM,
                const Text(
                  'Haftung für weiterführende Links',
                  style: UIStyles.sectionTitleStyle,
                ),
                UIConstants.verticalSpacingXS,
                const Text(
                  'Der BSSB stellt an verschiedenen Stellen Links zu Internet-Seiten Dritter zur Verfügung. Bei Benutzung dieser Links erkennen Sie diese Nutzungsbedingungen an. Sie erkennen ebenso an, dass der BSSB keine Kontrolle über die Inhalte solcher Seiten hat und für diese Inhalte und deren Qualität keine Verantwortung übernimmt.',
                  style: UIStyles.bodyStyle,
                ),
                UIConstants.verticalSpacingM,
                const Text(
                  'Angaben zur allgemeinen Informationspflicht § 5 Digitale-Dienste-Gesetz (DDG)',
                  style: UIStyles.sectionTitleStyle,
                ),
                UIConstants.verticalSpacingXS,
                _addressBlock([
                  'Bayerischer Sportschützenbund e.V.',
                  'Eingetragen im Vereinsregister des Amtsgerichts München: VR 4803',
                  'Postanschrift der Geschäftsstelle:',
                  'Ingolstädter Landstrasse 110',
                  '85748 Garching',
                ]),
                UIConstants.verticalSpacingXS,
                Text(
                  'Kommunikation',
                  style:
                      UIStyles.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                ),
                _contactRow(
                  phone: '0893169490',
                  email: 'gs@bssb.bayern',
                  web: 'https://www.bssb.de/',
                ),
                UIConstants.verticalSpacingXS,
                Text(
                  'Geschäftsführer',
                  style:
                      UIStyles.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                ),
                const Text('Alexander Heidel', style: UIStyles.bodyStyle),
                UIConstants.verticalSpacingXS,
                Text(
                  'Vorstand i.S. §26 BGB',
                  style:
                      UIStyles.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                ),
                _bulletList([
                  '1. Landesschützenmeister: Christian Kühn',
                  '2. Landesschützenmeister: Dieter Vierlbeck',
                  '3. Landesschützenmeister: Hans Hainthaler',
                  '4. Landesschützenmeister: Albert Euba',
                  '5. Landesschützenmeister: Stefan Fersch',
                ]),
                UIConstants.verticalSpacingXS,
                Text(
                  'Bankverbindung',
                  style:
                      UIStyles.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                ),
                _addressBlock([
                  'HypoVereinsbank Gauting, Kontonummer: 840 000, Bankleitzahl: 700 202 70',
                  'IBAN: DE79 7002 0270 0000 8400 00, BIC: HYVEDEMMXXX',
                ]),
                UIConstants.verticalSpacingXS,
                Text(
                  'Umsatzsteueridentifikationsnummer',
                  style:
                      UIStyles.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                ),
                const Text('DE 129514004', style: UIStyles.bodyStyle),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pop(),
        backgroundColor: UIConstants.defaultAppColor,
        child: const Icon(
          Icons.close,
          color: Colors.white,
        ),
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
          size: UIConstants.bodyFontSize,
          color: UIConstants.defaultAppColor,
        ),
        const SizedBox(width: UIConstants.spacingXS),
        _LinkText('Telefon', 'tel:$phone'),
        const SizedBox(width: UIConstants.spacingSM),
      ],
      if (email != null) ...[
        const Icon(
          Icons.email,
          size: UIConstants.bodyFontSize,
          color: UIConstants.defaultAppColor,
        ),
        const SizedBox(width: UIConstants.spacingXS),
        _LinkText(email, 'mailto:$email'),
        const SizedBox(width: UIConstants.spacingSM),
      ],
      if (web != null) ...[
        const Icon(
          Icons.language,
          size: UIConstants.bodyFontSize,
          color: UIConstants.defaultAppColor,
        ),
        const SizedBox(width: UIConstants.spacingXS),
        _LinkText('Webseite', web),
      ],
    ],
  );
}

Widget _subSection({
  required String title,
  required String name,
  required List<String> address,
  String? phone,
  String? email,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: UIStyles.bodyStyle.copyWith(fontWeight: FontWeight.bold),
      ),
      Text(name, style: UIStyles.bodyStyle),
      _addressBlock(address),
      _contactRow(phone: phone, email: email),
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
