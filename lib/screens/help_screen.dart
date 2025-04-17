// lib/screens/help_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import for handling links
import '/screens/app_menu.dart';
import '/constants/ui_constants.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({
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
      appBar: AppBar(
        title: const Text('FAQ', style: UIConstants.titleStyle),
        actions: [
          AppMenu(
            context: context,
            userData: userData,
            isLoggedIn: isLoggedIn,
            onLogout: onLogout,
          ),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(UIConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Häufig gestellte Fragen (FAQ)',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Allgemein',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Was ist Mein BSSB?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Mein BSSB ist die offizielle App des Bayerischen Sportschützenbundes e.V. Sie bietet Mitgliedern einen einfachen Zugang zu wichtigen Informationen, Terminen, Ergebnissen und vielem mehr.',
            ),
            SizedBox(height: 8),
            Text(
              'Wer kann die App nutzen?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Die App steht allen Mitgliedern des Bayerischen Sportschützenbundes e.V. zur Verfügung.',
            ),
            SizedBox(height: 8),
            Text(
              'Wie erhalte ich meine Zugangsdaten?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Ihre Zugangsdaten (Mitgliedsnummer und Passwort) erhalten Sie in der Regel per E-Mail oder über Ihren Verein. Bei Problemen wenden Sie sich bitte an Ihren Verein oder die Geschäftsstelle des BSSB.',
            ),
            SizedBox(height: 16),
            Text(
              'Funktionen der App',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Welche Bereiche gibt es in der App?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Die App umfasst verschiedene Bereiche wie News, Termine, Ergebnisse, mein Profil, Dokumente und mehr. Navigieren Sie einfach durch das Menü, um die gewünschten Informationen zu finden.',
            ),
            SizedBox(height: 8),
            Text(
              'Wie kann ich meine persönlichen Daten einsehen und ändern?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Im Bereich "mein Profil" können Sie Ihre hinterlegten Daten einsehen. Änderungen können Sie in der Regel über die Webseite des BSSB oder über Ihren Verein vornehmen.',
            ),
            SizedBox(height: 8),
            Text(
              'Wo finde ich aktuelle Termine und Veranstaltungen?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Unter dem Punkt "Termine" finden Sie eine Übersicht über alle wichtigen Veranstaltungen, Wettkämpfe und Schulungen.',
            ),
            SizedBox(height: 8),
            Text(
              'Kann ich Ergebnisse von Wettkämpfen einsehen?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Ja, im Bereich "Ergebnisse" werden die Resultate von verschiedenen Wettkämpfen veröffentlicht.',
            ),
            SizedBox(height: 8),
            Text(
              'Wo finde ich wichtige Dokumente und Formulare?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Im Bereich "Dokumente" stehen Ihnen wichtige Formulare, Ordnungen und andere Dokumente zum Download zur Verfügung.',
            ),
            SizedBox(height: 16),
            Text(
              'Technische Fragen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Die App funktioniert nicht richtig. Was kann ich tun?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Überprüfen Sie zunächst Ihre Internetverbindung. Stellen Sie sicher, dass Sie die aktuellste Version der App installiert haben. Wenn das Problem weiterhin besteht, kontaktieren Sie bitte den Support des BSSB.',
            ),
            SizedBox(height: 8),
            Text(
              'Ich habe mein Passwort vergessen. Was nun?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Eine Funktion zum Zurücksetzen des Passworts ist in der App oder auf der Webseite des BSSB verfügbar. Folgen Sie den dortigen Anweisungen oder wenden Sie sich an Ihren Verein oder die Geschäftsstelle.',
            ),
            SizedBox(height: 8),
            Text(
              'Unterstützt die App Benachrichtigungen?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Ja, die App kann Benachrichtigungen für wichtige Termine oder Neuigkeiten senden. Sie können die Benachrichtigungseinstellungen in Ihrem Profil anpassen.',
            ),
            SizedBox(height: 16),
            Text(
              'Kontakt und Hilfe',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Wo erhalte ich weitere Hilfe?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Bei weiteren Fragen oder Problemen wenden Sie sich bitte an Ihren Verein oder direkt an die Geschäftsstelle des Bayerischen Sportschützenbundes e.V.',
            ),
            _LinkText('Zur Webseite des BSSB', 'https://www.bssb.de/'),
            Text(
              'Kontaktdaten der Geschäftsstelle finden Sie im Impressum der App.',
            ),
            SizedBox(height: 16),
          ],
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
              const SnackBar(content: Text('Could not launch URL')),
            );
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
