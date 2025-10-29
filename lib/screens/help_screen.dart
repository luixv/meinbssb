import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'menu/app_menu.dart';
import '/screens/connectivity_icon.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/constants/messages.dart';

import '/models/user_data.dart';
import '/widgets/scaled_text.dart';

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
          icon: const Icon(Icons.arrow_back, color: UIConstants.textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const ScaledText(
          Messages.helpTitle,
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
      body: Semantics(
        label:
            'Hilfebereich mit häufig gestellten Fragen, technischen Hinweisen und Kontaktmöglichkeiten für den Bayerischen Sportschützenbund',
        child: Container(
          color: UIConstants.backgroundColor,
          child: SingleChildScrollView(
            padding: UIConstants.defaultPadding,
            child: Column(
              crossAxisAlignment: UIConstants.startCrossAlignment,
              children: [
                const ScaledText(
                  'Häufig gestellte Fragen (FAQ)',
                  style: TextStyle(
                    fontSize: UIConstants.headerFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: UIConstants.spacingM),
                const _AccordionSection(
                  title: 'Allgemein',
                  questions: [
                    _AccordionItem(
                      question: 'Was ist Mein BSSB?',
                      answer: ScaledText(
                        'Mein BSSB ist die offizielle App des Bayerischen Sportschützenbundes e.V. Sie bietet Mitgliedern einen einfachen Zugang zu wichtigen Informationen, Terminen, Ergebnissen und vielem mehr.',
                      ),
                    ),
                    _AccordionItem(
                      question: 'Wer kann die App nutzen?',
                      answer: ScaledText(
                        'Die App steht allen Mitgliedern des Bayerischen Sportschützenbundes e.V. zur Verfügung.',
                      ),
                    ),
                    _AccordionItem(
                      question: 'Wie erhalte ich meine Zugangsdaten?',
                      answer: ScaledText(
                        'Ihre Zugangsdaten (Mitgliedsnummer und Passwort) erhalten Sie in der Regel per E-Mail oder über Ihren Verein. Bei Problemen wenden Sie sich bitte an Ihren Verein oder die Geschäftsstelle des BSSB.',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: UIConstants.spacingM),
                const _AccordionSection(
                  title: 'Funktionen der App',
                  questions: [
                    _AccordionItem(
                      question: 'Welche Bereiche gibt es in der App?',
                      answer: ScaledText(
                        'Die App umfasst verschiedene Bereiche wie News, Termine, Ergebnisse, mein Profil, Dokumente und mehr. Navigieren Sie einfach durch das Menü, um die gewünschten Informationen zu finden.',
                      ),
                    ),
                    _AccordionItem(
                      question:
                          'Wie kann ich meine persönlichen Daten einsehen und ändern?',
                      answer: ScaledText(
                        'Im Bereich "mein Profil" können Sie Ihre hinterlegten Daten einsehen. Änderungen können Sie in der Regel über die Webseite des BSSB oder über Ihren Verein vornehmen.',
                      ),
                    ),
                    _AccordionItem(
                      question:
                          'Wo finde ich aktuelle Termine und Veranstaltungen?',
                      answer: ScaledText(
                        'Unter dem Punkt "Termine" finden Sie eine Übersicht über alle wichtigen Veranstaltungen, Wettkämpfe und Schulungen.',
                      ),
                    ),
                    _AccordionItem(
                      question: 'Kann ich Ergebnisse von Wettkämpfen einsehen?',
                      answer: ScaledText(
                        'Ja, im Bereich "Ergebnisse" werden die Resultate von verschiedenen Wettkämpfen veröffentlicht.',
                      ),
                    ),
                    _AccordionItem(
                      question:
                          'Wo finde ich wichtige Dokumente und Formulare?',
                      answer: ScaledText(
                        'Im Bereich "Dokumente" stehen Ihnen wichtige Formulare, Ordnungen und andere Dokumente zum Download zur Verfügung.',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: UIConstants.spacingM),
                const _AccordionSection(
                  title: 'Technische Fragen',
                  questions: [
                    _AccordionItem(
                      question:
                          'Die App funktioniert nicht richtig. Was kann ich tun?',
                      answer: ScaledText(
                        'Überprüfen Sie zunächst Ihre Internetverbindung. Stellen Sie sicher, dass Sie die aktuellste Version der App installiert haben. Wenn das Problem weiterhin besteht, kontaktieren Sie bitte den Support des BSSB.',
                      ),
                    ),
                    _AccordionItem(
                      question: 'Ich habe mein Passwort vergessen. Was nun?',
                      answer: ScaledText(
                        'Eine Funktion zum Zurücksetzen des Passworts ist in der App oder auf der Webseite des BSSB verfügbar. Folgen Sie den dortigen Anweisungen oder wenden Sie sich an Ihren Verein oder die Geschäftsstelle.',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: UIConstants.spacingM),
                const _AccordionSection(
                  title: 'Kontakt und Hilfe',
                  questions: [
                    _AccordionItem(
                      question: 'Wo erhalte ich weitere Hilfe?',
                      answer: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ScaledText(
                            'Bei weiteren Fragen oder Problemen wenden Sie sich bitte an Ihren Verein oder direkt an die Geschäftsstelle des Bayerischen Sportschützenbundes e.V.',
                          ),
                          _LinkText(
                            'Zur Webseite des BSSB',
                            'https://www.bssb.de/',
                          ),
                          ScaledText(
                            'Kontaktdaten der Geschäftsstelle finden Sie im Impressum der App.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: UIConstants.spacingM),
                // Add version number at the bottom
                const SizedBox(height: 32),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final version =
                        snapshot.hasData
                            ? 'Version: ${snapshot.data!.version}+${snapshot.data!.buildNumber}'
                            : 'Version: ...';
                    return Column(
                      children: [
                        Center(
                          child: Text(
                            version,
                            style: UIStyles.bodyStyle.copyWith(
                              color: UIConstants.textColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: UIConstants.helpSpacing),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccordionSection extends StatelessWidget {
  const _AccordionSection({required this.title, required this.questions});

  final String title;
  final List<_AccordionItem> questions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScaledText(
          title,
          style: const TextStyle(
            fontSize: UIConstants.titleFontSize,
            fontWeight: FontWeight.bold,
            color: UIConstants.defaultAppColor,
          ),
        ),
        const SizedBox(height: UIConstants.spacingM),
        ...questions,
      ],
    );
  }
}

class _AccordionItem extends StatefulWidget {
  const _AccordionItem({required this.question, required this.answer});

  final String question;
  final Widget answer;

  @override
  State<_AccordionItem> createState() => _AccordionItemState();
}

class _AccordionItemState extends State<_AccordionItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingM),
      child: ExpansionTile(
        title: Semantics(
          label: 'Frage: ${widget.question}',
          child: ScaledText(
            widget.question,
            style: const TextStyle(
              fontSize: UIConstants.subtitleFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(UIConstants.spacingM),
            child: Semantics(
              label: 'Antwort zu: ${widget.question}',
              child: widget.answer,
            ),
          ),
        ],
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
