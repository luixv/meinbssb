import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '/screens/base_screen_layout_accessible.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/constants/messages.dart';
import '/models/user_data.dart';
import '/widgets/scaled_text.dart';
import '/services/core/logger_service.dart';

/// BITV 2.0 compliant version of HelpScreen
/// Provides comprehensive accessibility features for German "Barrierefreiheit" requirements
///
/// Accessibility Features:
/// - Screen reader announcements in German
/// - Keyboard navigation support
/// - Semantic structure with proper headings
/// - Focus management for expandable content
/// - High contrast compliance
/// - ARIA labels and descriptions
/// - BITV 2.0/WCAG 2.1 Level AA compliance
class HelpScreenAccessible extends StatefulWidget {
  const HelpScreenAccessible({
    super.key,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });

  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  State<HelpScreenAccessible> createState() => _HelpScreenAccessibleState();
}

class _HelpScreenAccessibleState extends State<HelpScreenAccessible> {
  final FocusNode _screenFocusNode = FocusNode();
  int _expandedSectionIndex = -1;

  @override
  void initState() {
    super.initState();

    // Initial accessibility announcements
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _announceScreenLoaded();
      _setInitialFocus();
    });
  }

  @override
  void dispose() {
    _screenFocusNode.dispose();
    super.dispose();
  }

  /// Announces screen loaded state to screen readers in German
  void _announceScreenLoaded() {
    SemanticsService.announce(
      'Hilfe-Seite geladen. Häufig gestellte Fragen verfügbar. Navigieren Sie mit Tab durch die Bereiche.',
      TextDirection.ltr,
    );

    LoggerService.logInfo(
      'HelpScreenAccessible: Screen loaded announcement made',
    );
  }

  /// Sets initial focus for accessibility
  void _setInitialFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _screenFocusNode.requestFocus();
    });
  }

  /// Handles section expansion for accessibility
  void _onSectionExpanded(int index, String sectionTitle) {
    setState(() {
      _expandedSectionIndex = index;
    });

    SemanticsService.announce(
      'Bereich $sectionTitle erweitert',
      TextDirection.ltr,
    );

    LoggerService.logInfo(
      'HelpScreenAccessible: Section expanded - $sectionTitle',
    );
  }

  /// Handles section collapse for accessibility
  void _onSectionCollapsed(String sectionTitle) {
    setState(() {
      _expandedSectionIndex = -1;
    });

    SemanticsService.announce(
      'Bereich $sectionTitle eingeklappt',
      TextDirection.ltr,
    );

    LoggerService.logInfo(
      'HelpScreenAccessible: Section collapsed - $sectionTitle',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      explicitChildNodes: true,
      label: 'Hilfe und FAQ Seite',
      hint: 'Häufig gestellte Fragen und Hilfestellungen zur App',
      child: BaseScreenLayoutAccessible(
        title: Messages.helpTitle,
        userData: widget.userData,
        isLoggedIn: widget.isLoggedIn,
        onLogout: widget.onLogout,
        semanticScreenLabel: 'Hilfe-Seite',
        screenDescription:
            'Häufig gestellte Fragen und Unterstützung für die BSSB App',
        body: Focus(
          focusNode: _screenFocusNode,
          child: Semantics(
            container: true,
            explicitChildNodes: true,
            label: 'Hilfe-Inhalt',
            hint: 'FAQ-Bereiche mit erweiterbaren Fragen und Antworten',
            child: SingleChildScrollView(
              padding: UIConstants.defaultPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main heading with semantic structure
                  Semantics(
                    header: true,
                    label: 'Hauptüberschrift FAQ',
                    child: const ScaledText(
                      'Häufig gestellte Fragen (FAQ)',
                      style: TextStyle(
                        fontSize: UIConstants.headerFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: UIConstants.spacingM),

                  // General section
                  _AccordionSectionAccessible(
                    index: 0,
                    title: 'Allgemein',
                    isExpanded: _expandedSectionIndex == 0,
                    onExpansionChanged: (expanded) {
                      if (expanded) {
                        _onSectionExpanded(0, 'Allgemein');
                      } else {
                        _onSectionCollapsed('Allgemein');
                      }
                    },
                    questions: const [
                      _AccordionItemAccessible(
                        question: 'Was ist Mein BSSB?',
                        answer: ScaledText(
                          'Mein BSSB ist die offizielle App des Bayerischen Sportschützenbundes e.V. Sie bietet Mitgliedern einen einfachen Zugang zu wichtigen Informationen, Terminen, Ergebnissen und vielem mehr.',
                        ),
                      ),
                      _AccordionItemAccessible(
                        question: 'Wer kann die App nutzen?',
                        answer: ScaledText(
                          'Die App steht allen Mitgliedern des Bayerischen Sportschützenbundes e.V. zur Verfügung.',
                        ),
                      ),
                      _AccordionItemAccessible(
                        question: 'Wie erhalte ich meine Zugangsdaten?',
                        answer: ScaledText(
                          'Ihre Zugangsdaten (Mitgliedsnummer und Passwort) erhalten Sie in der Regel per E-Mail oder über Ihren Verein. Bei Problemen wenden Sie sich bitte an Ihren Verein oder die Geschäftsstelle des BSSB.',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: UIConstants.spacingM),

                  // App functions section
                  _AccordionSectionAccessible(
                    index: 1,
                    title: 'Funktionen der App',
                    isExpanded: _expandedSectionIndex == 1,
                    onExpansionChanged: (expanded) {
                      if (expanded) {
                        _onSectionExpanded(1, 'Funktionen der App');
                      } else {
                        _onSectionCollapsed('Funktionen der App');
                      }
                    },
                    questions: const [
                      _AccordionItemAccessible(
                        question: 'Welche Bereiche gibt es in der App?',
                        answer: ScaledText(
                          'Die App umfasst verschiedene Bereiche wie News, Termine, Ergebnisse, mein Profil, Dokumente und mehr. Navigieren Sie einfach durch das Menü, um die gewünschten Informationen zu finden.',
                        ),
                      ),
                      _AccordionItemAccessible(
                        question:
                            'Wie kann ich meine persönlichen Daten einsehen und ändern?',
                        answer: ScaledText(
                          'Im Bereich "mein Profil" können Sie Ihre hinterlegten Daten einsehen. Änderungen können Sie in der Regel über die Webseite des BSSB oder über Ihren Verein vornehmen.',
                        ),
                      ),
                      _AccordionItemAccessible(
                        question:
                            'Wo finde ich aktuelle Termine und Veranstaltungen?',
                        answer: ScaledText(
                          'Unter dem Punkt "Termine" finden Sie eine Übersicht über alle wichtigen Veranstaltungen, Wettkämpfe und Schulungen.',
                        ),
                      ),
                      _AccordionItemAccessible(
                        question:
                            'Kann ich Ergebnisse von Wettkämpfen einsehen?',
                        answer: ScaledText(
                          'Ja, im Bereich "Ergebnisse" werden die Resultate von verschiedenen Wettkämpfen veröffentlicht.',
                        ),
                      ),
                      _AccordionItemAccessible(
                        question:
                            'Wo finde ich wichtige Dokumente und Formulare?',
                        answer: ScaledText(
                          'Im Bereich "Dokumente" stehen Ihnen wichtige Formulare, Ordnungen und andere Dokumente zum Download zur Verfügung.',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: UIConstants.spacingM),

                  // Technical questions section
                  _AccordionSectionAccessible(
                    index: 2,
                    title: 'Technische Fragen',
                    isExpanded: _expandedSectionIndex == 2,
                    onExpansionChanged: (expanded) {
                      if (expanded) {
                        _onSectionExpanded(2, 'Technische Fragen');
                      } else {
                        _onSectionCollapsed('Technische Fragen');
                      }
                    },
                    questions: const [
                      _AccordionItemAccessible(
                        question:
                            'Die App funktioniert nicht richtig. Was kann ich tun?',
                        answer: ScaledText(
                          'Überprüfen Sie zunächst Ihre Internetverbindung. Stellen Sie sicher, dass Sie die aktuellste Version der App installiert haben. Wenn das Problem weiterhin besteht, kontaktieren Sie bitte den Support des BSSB.',
                        ),
                      ),
                      _AccordionItemAccessible(
                        question: 'Ich habe mein Passwort vergessen. Was nun?',
                        answer: ScaledText(
                          'Eine Funktion zum Zurücksetzen des Passworts ist in der App oder auf der Webseite des BSSB verfügbar. Folgen Sie den dortigen Anweisungen oder wenden Sie sich an Ihren Verein oder die Geschäftsstelle.',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: UIConstants.spacingM),

                  // Contact and help section
                  _AccordionSectionAccessible(
                    index: 3,
                    title: 'Kontakt und Hilfe',
                    isExpanded: _expandedSectionIndex == 3,
                    onExpansionChanged: (expanded) {
                      if (expanded) {
                        _onSectionExpanded(3, 'Kontakt und Hilfe');
                      } else {
                        _onSectionCollapsed('Kontakt und Hilfe');
                      }
                    },
                    questions: const [
                      _AccordionItemAccessible(
                        question: 'Wo erhalte ich weitere Hilfe?',
                        answer: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ScaledText(
                              'Bei weiteren Fragen oder Problemen wenden Sie sich bitte an Ihren Verein oder direkt an die Geschäftsstelle des Bayerischen Sportschützenbundes e.V.',
                            ),
                            SizedBox(height: UIConstants.spacingS),
                            _LinkTextAccessible(
                              'Zur Webseite des BSSB',
                              'https://www.bssb.de/',
                            ),
                            SizedBox(height: UIConstants.spacingS),
                            ScaledText(
                              'Kontaktdaten der Geschäftsstelle finden Sie im Impressum der App.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: UIConstants.spacingM),

                  // Version information with accessibility
                  Semantics(
                    readOnly: true,
                    label: 'App-Versionsinformation',
                    child: FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        final version = snapshot.hasData
                            ? 'Version: ${snapshot.data!.version}+${snapshot.data!.buildNumber}'
                            : 'Version: wird geladen...';
                        return Column(
                          children: [
                            const SizedBox(height: 32),
                            Center(
                              child: Semantics(
                                label: 'App-Version: $version',
                                child: Text(
                                  version,
                                  style: UIStyles.bodyStyle.copyWith(
                                    color: UIConstants.textColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: UIConstants.helpSpacing),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Accessible accordion section with proper semantics
class _AccordionSectionAccessible extends StatelessWidget {
  const _AccordionSectionAccessible({
    required this.index,
    required this.title,
    required this.questions,
    required this.isExpanded,
    required this.onExpansionChanged,
  });

  final int index;
  final String title;
  final List<_AccordionItemAccessible> questions;
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'FAQ-Bereich: $title',
      hint: isExpanded
          ? 'Bereich ist erweitert, enthält ${questions.length} Fragen'
          : 'Bereich ist eingeklappt, enthält ${questions.length} Fragen. Zum Erweitern aktivieren.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Semantics(
            header: true,
            label: 'Bereichsüberschrift: $title',
            button: true,
            onTap: () => onExpansionChanged(!isExpanded),
            child: GestureDetector(
              onTap: () => onExpansionChanged(!isExpanded),
              child: Container(
                padding: const EdgeInsets.all(UIConstants.spacingS),
                decoration: BoxDecoration(
                  color: isExpanded
                      ? UIConstants.defaultAppColor.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: UIConstants.defaultAppColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ScaledText(
                        title,
                        style: const TextStyle(
                          fontSize: UIConstants.titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: UIConstants.defaultAppColor,
                        ),
                      ),
                    ),
                    Semantics(
                      label: isExpanded ? 'Einklappen' : 'Erweitern',
                      child: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: UIConstants.defaultAppColor,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Expanded content
          if (isExpanded) ...[
            const SizedBox(height: UIConstants.spacingM),
            Semantics(
              liveRegion: true,
              label: 'Erweiterte Fragen für $title',
              child: Column(
                children: questions
                    .map(
                      (question) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: UIConstants.spacingS),
                        child: question,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Accessible accordion item with proper focus management
class _AccordionItemAccessible extends StatefulWidget {
  const _AccordionItemAccessible({
    required this.question,
    required this.answer,
  });

  final String question;
  final Widget answer;

  @override
  State<_AccordionItemAccessible> createState() =>
      _AccordionItemAccessibleState();
}

class _AccordionItemAccessibleState extends State<_AccordionItemAccessible> {
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleExpansionChanged(bool expanded) {
    setState(() {
      _isExpanded = expanded;
    });

    final String announcement = expanded
        ? 'Frage erweitert: ${widget.question}'
        : 'Frage eingeklappt: ${widget.question}';

    SemanticsService.announce(announcement, TextDirection.ltr);

    LoggerService.logInfo(
      'HelpScreenAccessible: Question ${expanded ? 'expanded' : 'collapsed'} - ${widget.question}',
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.space) {
        _handleExpansionChanged(!_isExpanded);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      label: 'FAQ-Frage: ${widget.question}',
      hint: _isExpanded
          ? 'Frage ist erweitert. Antwort verfügbar. Zum Einklappen aktivieren.'
          : 'Frage ist eingeklappt. Zum Erweitern und Anzeigen der Antwort aktivieren.',
      onTap: () => _handleExpansionChanged(!_isExpanded),
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: (node, event) {
          _handleKeyEvent(event);
          return KeyEventResult.handled;
        },
        child: Card(
          margin: const EdgeInsets.only(bottom: UIConstants.spacingS),
          elevation: _focusNode.hasFocus ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: _focusNode.hasFocus
                ? const BorderSide(color: Colors.blue, width: 2)
                : BorderSide.none,
          ),
          child: ExpansionTile(
            key: ValueKey(widget.question),
            onExpansionChanged: _handleExpansionChanged,
            title: Semantics(
              excludeSemantics: true, // Handled by parent
              child: ScaledText(
                widget.question,
                style: const TextStyle(
                  fontSize: UIConstants.subtitleFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            children: [
              Semantics(
                readOnly: true,
                label: 'Antwort zur Frage: ${widget.question}',
                child: Padding(
                  padding: const EdgeInsets.all(UIConstants.spacingM),
                  child: widget.answer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Accessible link text with proper announcements
class _LinkTextAccessible extends StatelessWidget {
  const _LinkTextAccessible(this.text, this.url);

  final String text;
  final String url;

  Future<void> _handleLinkTap(BuildContext context) async {
    // Announce link activation
    SemanticsService.announce(
      'Link wird geöffnet: $text',
      TextDirection.ltr,
    );

    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);

        // Announce successful opening
        SemanticsService.announce(
          'Link erfolgreich geöffnet',
          TextDirection.ltr,
        );
      } else {
        // Announce failure
        SemanticsService.announce(
          'Link konnte nicht geöffnet werden',
          TextDirection.ltr,
        );

        // Show error to user
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Link konnte nicht geöffnet werden'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      LoggerService.logError(
        'HelpScreenAccessible: Error opening link: $e',
      );

      SemanticsService.announce(
        'Fehler beim Öffnen des Links',
        TextDirection.ltr,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      link: true,
      label: 'Link: $text',
      hint: 'Öffnet externe Webseite: $url',
      onTap: () => _handleLinkTap(context),
      child: TextButton(
        onPressed: () => _handleLinkTap(context),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spacingS,
            vertical: UIConstants.spacingXS,
          ),
        ),
        child: ScaledText(
          text,
          style: const TextStyle(
            color: UIConstants.defaultAppColor,
            decoration: TextDecoration.underline,
            decorationColor: UIConstants.defaultAppColor,
          ),
        ),
      ),
    );
  }
}
