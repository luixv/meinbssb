import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '/constants/ui_constants.dart';
import '/screens/base_screen_layout.dart';
import '/models/user_data.dart';
import '/widgets/scaled_text.dart';

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
    return BaseScreenLayout(
      title: 'Impressum',
      userData: userData,
      isLoggedIn: isLoggedIn,
      onLogout: onLogout,
      body: Container(
        color: UIConstants.backgroundColor,
        child: const SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: UIConstants.startCrossAlignment,
            children: [
              SizedBox(height: 16),
              ScaledText(
                'Für den Inhalt verantwortlich sind:',
                style: TextStyle(
                    fontSize: UIConstants.dialogFontSize,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: UIConstants.spacingS),
              ScaledText(
                'Gesamtverantwortung',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ScaledText('Bayerischer Sportschützenbund e.V.'),
              ScaledText('1. Landesschützenmeister'),
              SizedBox(height: UIConstants.spacingXS),
              ScaledText('Christian Kühn'),
              ScaledText('Olympia-Schießanlage Hochbrück'),
              ScaledText('Ingolstädter Landstraße 110'),
              ScaledText('85748 Garching'),
              SizedBox(height: UIConstants.spacingS),
              _LinkText('Telefon: 089 - 31 69 49 - 0', 'tel:0893169490'),
              _LinkText('E-Mail: gs@bssb.bayern', 'mailto:gs@bssb.bayern'),
              _LinkText('Website: https://www.bssb.de', 'https://www.bssb.de'),
              SizedBox(height: UIConstants.spacingS),
              ScaledText(
                'Realisierung des Internetauftritts',
                style: TextStyle(
                    fontSize: UIConstants.dialogFontSize,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: UIConstants.spacingS),
              ScaledText(
                'Datenschutzbeauftragter',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ScaledText('Herbert Isdebski'),
              ScaledText('Scheibenhalde 1'),
              ScaledText('72160 Horb-Nordstetten'),
              SizedBox(height: UIConstants.spacingS),
              _LinkText(
                'E-Mail: datenschutz@bssb.de',
                'mailto:datenschutz@bssb.de',
              ),
              SizedBox(height: UIConstants.spacingS),
              ScaledText(
                'Telefon-Sprechstunde für BSSB-Mitglieder:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ScaledText('jeder erste Donnerstag im Monat, 16 bis 18 Uhr'),
              _LinkText('Telefon: (07451) 6 25 42 40', 'tel:074516254240'),
              SizedBox(height: UIConstants.spacingS),
              ScaledText(
                'Inhaltlich verantwortlich für die Teilbereiche',
                style: TextStyle(
                    fontSize: UIConstants.dialogFontSize,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: UIConstants.spacingS),
              ScaledText(
                'Verband',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ScaledText('Bayerischer Sportschützenbund e.V.'),
              ScaledText('Herr Alexander Heidel'),
              ScaledText('Olympia-Schießanlage Hochbrück'),
              ScaledText('Ingolstädter Landstraße 110'),
              ScaledText('85748 Garching'),
              SizedBox(height: UIConstants.spacingS),
              _LinkText('Telefon: 089 - 31 69 49 - 0', 'tel:0893169490'),
              _LinkText(
                'E-Mail: alexander.heidel@bssb.bayern',
                'mailto:alexander.heidel@bssb.bayern',
              ),
              SizedBox(height: UIConstants.spacingS),
              ScaledText(
                'Sport',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ScaledText('Einstellen der Ergebnisse'),
              ScaledText('Bayerischer Sportschützenbund e.V.'),
              ScaledText('Herr Josef Lederer'),
              ScaledText('Olympia-Schießanlage Hochbrück'),
              ScaledText('Ingolstädter Landstraße 110'),
              ScaledText('85748 Garching'),
              SizedBox(height: UIConstants.spacingS),
              _LinkText('Telefon: 089 - 31 69 49 - 0', 'tel:0893169490'),
              _LinkText(
                'E-Mail: josef.lederer@bssb.bayern',
                'mailto:josef.lederer@bssb.bayern',
              ),
              SizedBox(height: UIConstants.spacingS),
              ScaledText(
                'Jugend',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ScaledText('Bayerischer Sportschützenbund e.V.'),
              ScaledText('Herr Markus Maas'),
              ScaledText('Olympia-Schießanlage Hochbrück'),
              ScaledText('Ingolstädter Landstraße 110'),
              ScaledText('85748 Garching'),
              SizedBox(height: UIConstants.spacingS),
              _LinkText('Telefon: 089 - 31 69 49 - 0', 'tel:0893169490'),
              _LinkText(
                'E-Mail: jugend@bssb.bayern',
                'mailto:jugend@bssb.bayern',
              ),
              SizedBox(height: UIConstants.spacingS),
              ScaledText(
                'Aus Gründen der besseren Lesbarkeit wird auf die gleichzeitige Verwendung männlicher und weiblicher Sprachformen verzichtet. Sämtliche Personenbezeichnungen gelten gleichermaßen für alle Geschlechter.',
              ),
              SizedBox(height: UIConstants.spacingS),
              ScaledText(
                'Bezirke / Gaue / Vereine',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ScaledText(
                'Für die Liste aller Bezirke und Gaue ist der BSSB verantwortlich.',
              ),
              ScaledText(
                'Für die Liste aller Vereine sind die Vereine selbst verantwortlich.',
              ),
              ScaledText(
                'Für den Inhalt der Unterseiten von Gauen, Bezirken und Vereinen sind diese selbst verantwortlich.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: UIConstants.spacingS),
              ScaledText(
                'Haftung für weiterführende Links',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ScaledText(
                'Der BSSB stellt an verschiedenen Stellen Links zu Internet-Seiten Dritter zur Verfügung.',
              ),
              ScaledText(
                'Bei Benutzung dieser Links erkennen Sie diese Nutzungsbedingungen an.',
              ),
              ScaledText(
                'Sie erkennen ebenso an, dass der BSSB keine Kontrolle über die Inhalte solcher Seiten hat und für diese Inhalte und deren Qualität keine Verantwortung übernimmt.',
              ),
              SizedBox(height: UIConstants.spacingS),
              ScaledText(
                'Angaben zur allgemeinen Informationspflicht § 5 Digitale-Dienste-Gesetz (DDG)',
                style: TextStyle(
                    fontSize: UIConstants.dialogFontSize,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: UIConstants.spacingS),
              ScaledText(
                'Bayerischer Sportschützenbund e.V.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ScaledText(
                'eingetragen im Vereinsregister des Amtsgerichts München: VR 4803',
              ),
              SizedBox(height: UIConstants.spacingS),
              ScaledText('Postanschrift der Geschäftsstelle:'),
              ScaledText('Ingolstädter Landstrasse 110'),
              ScaledText('85748 Garching'),
              SizedBox(height: UIConstants.spacingS),
              ScaledText(
                'Kommunikation',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _LinkText('Telefon: 089 - 31 69 49 - 0', 'tel:0893169490'),
              _LinkText('E-Mail: gs@bssb.bayern', 'mailto:gs@bssb.bayern'),
              _LinkText(
                'Homepage: https://www.bssb.de/',
                'https://www.bssb.de/',
              ),
              SizedBox(height: UIConstants.spacingS),
              ScaledText(
                'Geschäftsführer',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ScaledText('Alexander Heidel'),
              SizedBox(height: UIConstants.spacingS),
              ScaledText(
                'Vorstand i.S. §26 BGB',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ScaledText('1. Landesschützenmeister: Christian Kühn'),
              ScaledText('2. Landesschützenmeister: Dieter Vierlbeck'),
              ScaledText('3. Landesschützenmeister: Hans Hainthaler'),
              ScaledText('4. Landesschützenmeister: Albert Euba'),
              ScaledText('5. Landesschützenmeister: Stefan Fersch'),
              SizedBox(height: UIConstants.spacingS),
              ScaledText(
                'Bankverbindung',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ScaledText(
                'HypoVereinsbank Gauting, Kontonummer: 840 000, Bankleitzahl: 700 202 70',
              ),
              ScaledText('IBAN: DE79 7002 0270 0000 8400 00, BIC: HYVEDEMMXXX'),
              SizedBox(height: UIConstants.spacingS),
              ScaledText(
                'Umsatzsteueridentifikationsnummer',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ScaledText('DE 129514004'),
              SizedBox(height: UIConstants.spacingS),
            ],
          ),
        ),
      ),
    );
  }
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
      child: ScaledText(
        text,
        style: const TextStyle(
          color: UIConstants.defaultAppColor,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
