import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '/screens/app_menu.dart';
import '/screens/connectivity_icon.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/models/user_data.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({
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
        automaticallyImplyLeading: true,
        backgroundColor: UIConstants.backgroundColor,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back, color: UIConstants.defaultAppColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          UIConstants.helpTitle,
          style: UIStyles.appBarTitleStyle,
        ),
        actions: [
          const Padding(
            padding: UIConstants.appBarRightPadding,
            child: ConnectivityIcon(),
          ),
          AppMenu(
            context: context,
            userData: userData,
            isLoggedIn: isLoggedIn,
            onLogout: onLogout,
          ),
        ],
      ),
      endDrawer: AppDrawer(
        userData: userData,
        isLoggedIn: isLoggedIn,
        onLogout: onLogout,
      ),
      body: Container(
        color: UIConstants.backgroundColor,
        child: const SingleChildScrollView(
          padding: UIConstants.defaultPadding,
          child: Column(
            crossAxisAlignment: UIConstants.startCrossAlignment,
            children: [
              Text(
                'Häufig gestellte Fragen (FAQ)',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: UIConstants.helpSpacing),
              _AccordionSection(
                title: 'Allgemein',
                questions: [
                  _AccordionItem(
                    question: 'Was ist Mein BSSB?',
                    answer: Text(
                      'Mein BSSB ist die offizielle App des Bayerischen Sportschützenbundes e.V. Sie bietet Mitgliedern einen einfachen Zugang zu wichtigen Informationen, Terminen, Ergebnissen und vielem mehr.',
                    ),
                  ),
                  _AccordionItem(
                    question: 'Wer kann die App nutzen?',
                    answer: Text(
                      'Die App steht allen Mitgliedern des Bayerischen Sportschützenbundes e.V. zur Verfügung.',
                    ),
                  ),
                  _AccordionItem(
                    question: 'Wie erhalte ich meine Zugangsdaten?',
                    answer: Text(
                      'Ihre Zugangsdaten (Mitgliedsnummer und Passwort) erhalten Sie in der Regel per E-Mail oder über Ihren Verein. Bei Problemen wenden Sie sich bitte an Ihren Verein oder die Geschäftsstelle des BSSB.',
                    ),
                  ),
                ],
              ),
              SizedBox(height: UIConstants.helpSpacing),
              _AccordionSection(
                title: 'Funktionen der App',
                questions: [
                  _AccordionItem(
                    question: 'Welche Bereiche gibt es in der App?',
                    answer: Text(
                      'Die App umfasst verschiedene Bereiche wie News, Termine, Ergebnisse, mein Profil, Dokumente und mehr. Navigieren Sie einfach durch das Menü, um die gewünschten Informationen zu finden.',
                    ),
                  ),
                  _AccordionItem(
                    question:
                        'Wie kann ich meine persönlichen Daten einsehen und ändern?',
                    answer: Text(
                      'Im Bereich "mein Profil" können Sie Ihre hinterlegten Daten einsehen. Änderungen können Sie in der Regel über die Webseite des BSSB oder über Ihren Verein vornehmen.',
                    ),
                  ),
                  _AccordionItem(
                    question:
                        'Wo finde ich aktuelle Termine und Veranstaltungen?',
                    answer: Text(
                      'Unter dem Punkt "Termine" finden Sie eine Übersicht über alle wichtigen Veranstaltungen, Wettkämpfe und Schulungen.',
                    ),
                  ),
                  _AccordionItem(
                    question: 'Kann ich Ergebnisse von Wettkämpfen einsehen?',
                    answer: Text(
                      'Ja, im Bereich "Ergebnisse" werden die Resultate von verschiedenen Wettkämpfen veröffentlicht.',
                    ),
                  ),
                  _AccordionItem(
                    question: 'Wo finde ich wichtige Dokumente und Formulare?',
                    answer: Text(
                      'Im Bereich "Dokumente" stehen Ihnen wichtige Formulare, Ordnungen und andere Dokumente zum Download zur Verfügung.',
                    ),
                  ),
                ],
              ),
              SizedBox(height: UIConstants.helpSpacing),
              _AccordionSection(
                title: 'Technische Fragen',
                questions: [
                  _AccordionItem(
                    question:
                        'Die App funktioniert nicht richtig. Was kann ich tun?',
                    answer: Text(
                      'Überprüfen Sie zunächst Ihre Internetverbindung. Stellen Sie sicher, dass Sie die aktuellste Version der App installiert haben. Wenn das Problem weiterhin besteht, kontaktieren Sie bitte den Support des BSSB.',
                    ),
                  ),
                  _AccordionItem(
                    question: 'Ich habe mein Passwort vergessen. Was nun?',
                    answer: Text(
                      'Eine Funktion zum Zurücksetzen des Passworts ist in der App oder auf der Webseite des BSSB verfügbar. Folgen Sie den dortigen Anweisungen oder wenden Sie sich an Ihren Verein oder die Geschäftsstelle.',
                    ),
                  ),
                  _AccordionItem(
                    question: 'Unterstützt die App Benachrichtigungen?',
                    answer: Text(
                      'Ja, die App kann Benachrichtigungen für wichtige Termine oder Neuigkeiten senden. Sie können die Benachrichtigungseinstellungen in Ihrem Profil anpassen.',
                    ),
                  ),
                ],
              ),
              SizedBox(height: UIConstants.helpSpacing),
              _AccordionSection(
                title: 'Kontakt und Hilfe',
                questions: [
                  _AccordionItem(
                    question: 'Wo erhalte ich weitere Hilfe?',
                    answer: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bei weiteren Fragen oder Problemen wenden Sie sich bitte an Ihren Verein oder direkt an die Geschäftsstelle des Bayerischen Sportschützenbundes e.V.',
                        ),
                        _LinkText(
                          'Zur Webseite des BSSB',
                          'https://www.bssb.de/',
                        ),
                        Text(
                          'Kontaktdaten der Geschäftsstelle finden Sie im Impressum der App.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: UIConstants.helpSpacing),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccordionSection extends StatelessWidget {
  const _AccordionSection({
    required this.title,
    required this.questions,
  });

  final String title;
  final List<_AccordionItem> questions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...questions,
      ],
    );
  }
}

class _AccordionItem extends StatelessWidget {
  const _AccordionItem({
    required this.question,
    required this.answer,
  });

  final String question;
  final Widget answer;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title:
          Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            size: 18,
            color: Colors.grey,
          ),
        ),
      ),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: answer,
        ),
      ],
      onExpansionChanged: (bool expanded) {
        // You could potentially change the leading icon here if desired
        // based on the expanded state (e.g., to a minus sign in a circle).
      },
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
            color: UIConstants.linkColor,
            fontSize: UIConstants.bodyFontSize,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
