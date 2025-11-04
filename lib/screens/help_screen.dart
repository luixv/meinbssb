import 'package:flutter/material.dart';
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
                  'Häufig gestellte Fragen',
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
                        'MeinBSSB bietet Mitgliedern einen einfachen Zugang zu wichtigen Informationen, Terminen, Ergebnissen und vielem mehr.',
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
                        'Ihre Zugangsdaten (Schützenausweisnummer) erhalten Sie von Ihrem Verein.',
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
                        'Die App umfasst verschiedene Funktionen wie z.B. Schützenausweis ansehen und verwalten, An- und Abmeldung zu Aus- und Weiterbildungen, Abruf von Geldpreisen wie z.B. Oktoberfestlandesschießen, u.v.m.',
                      ),
                    ),

                    _AccordionItem(
                      question:
                          'Wie kann ich meine persönlichen Daten einsehen und ändern?',
                      answer: ScaledText(
                        'Im Bereich „Profil“ können Sie Ihre hinterlegten Daten einsehen und ggf. anpassen.',
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
                        'Überprüfen Sie zunächst Ihre Internetverbindung. Stellen Sie sicher, dass Sie die aktuellste Version der App installiert haben. Wenn das Problem weiterhin besteht, kontaktieren Sie bitte den Support des BSSB unter webportal@bssb.bayern.',
                      ),
                    ),

                    _AccordionItem(
                      question: 'Ich habe mein Passwort vergessen. Was nun?',
                      answer: ScaledText(
                        'Eine Funktion zum Zurücksetzen des Passworts ist bei MeinBSSB verfügbar. Folgen Sie den dortigen Anweisungen um Ihr Passwort zu ändern. Bei Problemen wenden Sie sich bitte an den Support des BSSB unter webportal@bssb.bayern.',
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
                            'Bei weiteren Fragen oder Problemen wenden Sie sich bitte an den Support des BSSB unter...',
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
              label: 'Antwort: ${_extractAnswerText(widget.answer)}',
              child: widget.answer,
            ),
          ),
        ],
      ),
    );
  }

  // Helper to extract answer text for semantics label
  String _extractAnswerText(Widget answer) {
    if (answer is ScaledText) {
      // Try to extract text from the constructor argument
      final text = _getScaledTextString(answer);
      if (text != null) return text;
    } else if (answer is Text) {
      return answer.data ?? '';
    } else if (answer is Column) {
      final children = answer.children;
      for (final child in children) {
        if (child is ScaledText) {
          final text = _getScaledTextString(child);
          if (text != null) return text;
        } else if (child is Text && child.data != null) {
          return child.data!;
        }
      }
    }
    return 'Antwort';
  }

  // Helper to get the string from ScaledText
  String? _getScaledTextString(ScaledText scaledText) {
    // ScaledText usually has a 'text' or similar property, but if not, fallback
    try {
      // No reliable way to extract text, so fallback
      return null;
    } catch (_) {
      return null;
    }
  }
}
