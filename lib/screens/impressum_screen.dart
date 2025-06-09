import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:meinbssb/screens/app_menu.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/screens/connectivity_icon.dart'; // Import the ConnectivityIcon

class ImpressumScreen extends StatelessWidget {
  const ImpressumScreen({
    super.key,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });
  final Map<String, dynamic> userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: UIConstants.backgroundColor,
        title: const Text(
          'Impressum',
          style: UIConstants.titleStyle,
        ),
        actions: [
          // --- Added ConnectivityIcon here ---
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: ConnectivityIcon(), // The ConnectivityIcon
          ),
          // --- End ConnectivityIcon addition ---
          AppMenu(
            context: context,
            userData: userData,
            isLoggedIn: isLoggedIn,
            onLogout: onLogout,
          ),
        ],
      ),
      body: Container(
        color: UIConstants.backgroundColor,
        child: const SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: UIConstants.startCrossAlignment,
            children: [
              SizedBox(height: 16),
              Text(
                'Für den Inhalt verantwortlich sind:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Gesamtverantwortung',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Bayerischer Sportschützenbund e.V.'),
              Text('1. Landesschützenmeister'),
              SizedBox(height: 4),
              Text('Christian Kühn'),
              Text('Olympia-Schießanlage Hochbrück'),
              Text('Ingolstädter Landstraße 110'),
              Text('85748 Garching'),
              SizedBox(height: 8),
              _LinkText('Telefon: 089 - 31 69 49 - 0', 'tel:0893169490'),
              _LinkText('E-Mail: gs@bssb.bayern', 'mailto:gs@bssb.bayern'),
              _LinkText('Website: https://www.bssb.de', 'https://www.bssb.de'),
              SizedBox(height: UIConstants.defaultSpacing),
              Text(
                'Realisierung des Internetauftritts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Datenschutzbeauftragter',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Herbert Isdebski'),
              Text('Scheibenhalde 1'),
              Text('72160 Horb-Nordstetten'),
              SizedBox(height: 8),
              _LinkText(
                'E-Mail: datenschutz@bssb.de',
                'mailto:datenschutz@bssb.de',
              ),
              SizedBox(height: 8),
              Text(
                'Telefon-Sprechstunde für BSSB-Mitglieder:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('jeder erste Donnerstag im Monat, 16 bis 18 Uhr'),
              _LinkText('Telefon: (07451) 6 25 42 40', 'tel:074516254240'),
              SizedBox(height: UIConstants.defaultSpacing),
              Text(
                'Inhaltlich verantwortlich für die Teilbereiche',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Verband',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Bayerischer Sportschützenbund e.V.'),
              Text('Herr Alexander Heidel'),
              Text('Olympia-Schießanlage Hochbrück'),
              Text('Ingolstädter Landstraße 110'),
              Text('85748 Garching'),
              SizedBox(height: 8),
              _LinkText('Telefon: 089 - 31 69 49 - 0', 'tel:0893169490'),
              _LinkText(
                'E-Mail: alexander.heidel@bssb.bayern',
                'mailto:alexander.heidel@bssb.bayern',
              ),
              SizedBox(height: 8),
              Text(
                'Sport',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Einstellen der Ergebnisse'),
              Text('Bayerischer Sportschützenbund e.V.'),
              Text('Herr Josef Lederer'),
              Text('Olympia-Schießanlage Hochbrück'),
              Text('Ingolstädter Landstraße 110'),
              Text('85748 Garching'),
              SizedBox(height: 8),
              _LinkText('Telefon: 089 - 31 69 49 - 0', 'tel:0893169490'),
              _LinkText(
                'E-Mail: josef.lederer@bssb.bayern',
                'mailto:josef.lederer@bssb.bayern',
              ),
              SizedBox(height: 8),
              Text(
                'Jugend',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Bayerischer Sportschützenbund e.V.'),
              Text('Herr Markus Maas'),
              Text('Olympia-Schießanlage Hochbrück'),
              Text('Ingolstädter Landstraße 110'),
              Text('85748 Garching'),
              SizedBox(height: 8),
              _LinkText('Telefon: 089 - 31 69 49 - 0', 'tel:0893169490'),
              _LinkText(
                'E-Mail: jugend@bssb.bayern',
                'mailto:jugend@bssb.bayern',
              ),
              SizedBox(height: 8),
              Text(
                'Aus Gründen der besseren Lesbarkeit wird auf die gleichzeitige Verwendung männlicher und weiblicher Sprachformen verzichtet. Sämtliche Personenbezeichnungen gelten gleichermaßen für alle Geschlechter.',
              ),
              SizedBox(height: UIConstants.defaultSpacing),
              Text(
                'Bezirke / Gaue / Vereine',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Für die Liste aller Bezirke und Gaue ist der BSSB verantwortlich.',
              ),
              Text(
                'Für die Liste aller Vereine sind die Vereine selbst verantwortlich.',
              ),
              Text(
                'Für den Inhalt der Unterseiten von Gauen, Bezirken und Vereinen sind diese selbst verantwortlich.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: UIConstants.defaultSpacing),
              Text(
                'Haftung für weiterführende Links',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Der BSSB stellt an verschiedenen Stellen Links zu Internet-Seiten Dritter zur Verfügung.',
              ),
              Text(
                'Bei Benutzung dieser Links erkennen Sie diese Nutzungsbedingungen an.',
              ),
              Text(
                'Sie erkennen ebenso an, dass der BSSB keine Kontrolle über die Inhalte solcher Seiten hat und für diese Inhalte und deren Qualität keine Verantwortung übernimmt.',
              ),
              SizedBox(height: UIConstants.defaultSpacing),
              Text(
                'Angaben zur allgemeinen Informationspflicht § 5 Digitale-Dienste-Gesetz (DDG)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Bayerischer Sportschützenbund e.V.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'eingetragen im Vereinsregister des Amtsgerichts München: VR 4803',
              ),
              SizedBox(height: 8),
              Text('Postanschrift der Geschäftsstelle:'),
              Text('Ingolstädter Landstrasse 110'),
              Text('85748 Garching'),
              SizedBox(height: 8),
              Text(
                'Kommunikation',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _LinkText('Telefon: 089 - 31 69 49 - 0', 'tel:0893169490'),
              _LinkText('E-Mail: gs@bssb.bayern', 'mailto:gs@bssb.bayern'),
              _LinkText(
                'Homepage: https://www.bssb.de/',
                'https://www.bssb.de/',
              ),
              SizedBox(height: 8),
              Text(
                'Geschäftsführer',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Alexander Heidel'),
              SizedBox(height: 8),
              Text(
                'Vorstand i.S. §26 BGB',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('1. Landesschützenmeister: Christian Kühn'),
              Text('2. Landesschützenmeister: Dieter Vierlbeck'),
              Text('3. Landesschützenmeister: Hans Hainthaler'),
              Text('4. Landesschützenmeister: Albert Euba'),
              Text('5. Landesschützenmeister: Stefan Fersch'),
              SizedBox(height: 8),
              Text(
                'Bankverbindung',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'HypoVereinsbank Gauting, Kontonummer: 840 000, Bankleitzahl: 700 202 70',
              ),
              Text('IBAN: DE79 7002 0270 0000 8400 00, BIC: HYVEDEMMXXX'),
              SizedBox(height: 8),
              Text(
                'Umsatzsteueridentifikationsnummer',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('DE 129514004'),
              SizedBox(height: UIConstants.defaultSpacing),
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
    return InkWell(
      onTap: () async {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('URL konnte nicht geöffnet werden'),
                duration: UIConstants.snackBarDuration,
              ),
            );
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingS),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: UIConstants.linkStyle.copyWith(
                color: UIConstants.linkColor,
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(width: UIConstants.spacingXS),
            const Icon(
              Icons.open_in_new,
              size: 16,
              color: UIConstants.linkColor,
            ),
          ],
        ),
      ),
    );
  }
}
