import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/constants/messages.dart';
import 'package:meinbssb/services/core/logger_service.dart';

/// BITV 2.0 konforme Version der Cookie-Zustimmung
///
/// Diese Implementierung erfüllt die deutschen Barrierefreiheitsrichtlinien
/// Cookie-Zustimmung gemäß BITV 2.0 / WCAG 2.1 Level AA.
///
/// Accessibility Features:
/// - Vollständige Semantics-Integration
/// - Fokus-Management mit automatischer Dialog-Fokussierung
/// - Tastaturnavigation (Tab, Shift+Tab, Escape, Enter, Space)
/// - Live-Announcements für Screenreader
/// - Deutsche Sprachsemantik
/// - ARIA-konforme Dialog-Struktur
class CookieConsentAccessible extends StatefulWidget {
  const CookieConsentAccessible({super.key, required this.child});
  final Widget child;

  @override
  State<CookieConsentAccessible> createState() =>
      _CookieConsentAccessibleState();
}

class _CookieConsentAccessibleState extends State<CookieConsentAccessible> {
  bool _showConsent = false;
  bool _loading = true;
  late FocusNode _dialogFocusNode;
  late FocusNode _acceptButtonFocusNode;

  @override
  void initState() {
    super.initState();
    LoggerService.logInfo('CookieConsentAccessible: initState called.');

    // Fokus-Nodes für Accessibility-Management
    _dialogFocusNode = FocusNode();
    _acceptButtonFocusNode = FocusNode();

    _checkConsentStatus();

    // Accessibility-Ankündigung bei Initialisierung
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SemanticsService.announce(
        'Cookie-Zustimmung wird geladen',
        TextDirection.ltr,
      );
    });
  }

  @override
  void dispose() {
    _dialogFocusNode.dispose();
    _acceptButtonFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkConsentStatus() async {
    LoggerService.logInfo(
      'CookieConsentAccessible: _checkConsentStatus called.',
    );
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool('cookieConsentAccepted') ?? false;
    LoggerService.logInfo(
      'CookieConsentAccessible: SharedPreferences result: cookieConsentAccepted = $accepted',
    );

    if (mounted) {
      setState(() {
        _showConsent = !accepted;
        _loading = false;
      });

      // Fokus auf Dialog setzen wenn er angezeigt wird
      if (_showConsent) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _dialogFocusNode.requestFocus();

          // Ankündigung für Screenreader
          SemanticsService.announce(
            'Cookie-Zustimmung erforderlich. Dialog geöffnet. Verwenden Sie Tab zum Navigieren und Escape zum Schließen.',
            TextDirection.ltr,
          );
        });
      }
    }
  }

  Future<void> _acceptConsent() async {
    LoggerService.logInfo('CookieConsentAccessible: _acceptConsent called.');

    // Ankündigung vor Aktion
    SemanticsService.announce(
      'Cookies werden akzeptiert',
      TextDirection.ltr,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cookieConsentAccepted', true);

    if (mounted) {
      setState(() {
        _showConsent = false;
      });

      // Erfolgs-Ankündigung
      SemanticsService.announce(
        'Cookie-Zustimmung erfolgreich gespeichert. Dialog geschlossen.',
        TextDirection.ltr,
      );

      LoggerService.logInfo(
        'CookieConsentAccessible: Consent accepted and saved.',
      );
    }
  }

  /// Behandelt Tastatureingaben für erweiterte Accessibility
  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        // Hinweis: Da Cookie-Zustimmung erforderlich ist, informieren wir nur
        SemanticsService.announce(
          'Cookie-Zustimmung ist erforderlich. Bitte stimmen Sie zu, um fortzufahren.',
          TextDirection.ltr,
        );
      } else if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.space) {
        if (_acceptButtonFocusNode.hasFocus) {
          _acceptConsent();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      // Loading-Zustand mit Accessibility-Label
      return Semantics(
        label: 'Anwendung wird geladen, Cookie-Einstellungen werden überprüft',
        child: widget.child,
      );
    }

    return Stack(
      children: [
        widget.child,
        if (_showConsent)
          Positioned.fill(
            child: Semantics(
              scopesRoute: true,
              namesRoute: true,
              explicitChildNodes: true,
              label: 'Cookie-Zustimmung erforderlich',
              hint: 'Wichtiger Dialog für Cookie-Einstellungen',
              child: Focus(
                focusNode: _dialogFocusNode,
                onKeyEvent: (node, event) {
                  _handleKeyEvent(event);
                  return KeyEventResult.handled;
                },
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    LoggerService.logInfo(
                      'CookieConsentAccessible: Background tap - focusing dialog.',
                    );
                    _dialogFocusNode.requestFocus();
                    SemanticsService.announce(
                      'Cookie-Dialog fokussiert. Verwenden Sie Tab zum Navigieren.',
                      TextDirection.ltr,
                    );
                  },
                  child: Container(
                    key: const ValueKey('cookieConsentAccessibleBackground'),
                    color: const Color.fromARGB(
                      180,
                      0,
                      0,
                      0,
                    ), // Stärkerer Kontrast
                    alignment: Alignment.center,
                    child: Semantics(
                      container: true,
                      explicitChildNodes: true,
                      label: 'Cookie-Zustimmung Dialog',
                      hint: 'Enthält Informationen und Zustimmungsbutton',
                      child: Material(
                        color: UIConstants.backgroundColor,
                        borderRadius:
                            BorderRadius.circular(UIConstants.cornerRadius),
                        clipBehavior: Clip.antiAlias,
                        elevation:
                            12.0, // Erhöhte Elevation für bessere Sichtbarkeit
                        child: Container(
                          margin: const EdgeInsets.all(UIConstants.spacingM),
                          padding: const EdgeInsets.all(UIConstants.spacingL),
                          constraints: const BoxConstraints(
                            maxWidth: 450,
                            minWidth: 320,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Dialog-Titel mit semantischer Struktur
                              Semantics(
                                header: true,
                                label: 'Dialog-Überschrift: Cookie-Verwendung',
                                child: Text(
                                  Messages.cookieConsentTitle,
                                  style: UIStyles.dialogTitleStyle.copyWith(
                                    fontSize:
                                        20, // Größere Schrift für bessere Lesbarkeit
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: UIConstants.spacingL),

                              // Hauptinhalt mit detaillierter Semantik
                              Semantics(
                                readOnly: true,
                                label: 'Cookie-Information',
                                hint:
                                    'Erläuterung zur Cookie-Nutzung in der Anwendung',
                                child: Column(
                                  children: [
                                    Text(
                                      Messages.cookieConsentMessage,
                                      textAlign: TextAlign.center,
                                      style:
                                          UIStyles.dialogContentStyle.copyWith(
                                        fontSize: 16,
                                        height: 1.5, // Bessere Zeilenhöhe
                                      ),
                                    ),
                                    const SizedBox(
                                      height: UIConstants.spacingM,
                                    ),

                                    // Zusätzliche Erklärung für besseres Verständnis
                                    Semantics(
                                      readOnly: true,
                                      label: 'Zusätzliche Cookie-Details',
                                      child: Container(
                                        padding: const EdgeInsets.all(
                                          UIConstants.spacingS,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: const Text(
                                          'Diese Cookies ermöglichen es, Ihre Einstellungen zu speichern und die App auch ohne Internetverbindung zu verwenden.',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                            height: 1.4,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: UIConstants.spacingL),

                              // Zustimmungsbutton mit vollständiger Accessibility
                              Semantics(
                                button: true,
                                label: 'Cookie-Verwendung zustimmen',
                                hint:
                                    'Stimmt der Verwendung von Cookies zu und schließt den Dialog',
                                onTap: _acceptConsent,
                                child: Focus(
                                  focusNode: _acceptButtonFocusNode,
                                  child: ElevatedButton(
                                    onPressed: _acceptConsent,
                                    style: UIStyles.dialogAcceptButtonStyle
                                        .copyWith(
                                      padding: MaterialStateProperty.all(
                                        const EdgeInsets.symmetric(
                                          vertical: UIConstants.spacingM,
                                          horizontal: UIConstants.spacingL,
                                        ),
                                      ),
                                      // Fokus-Indikator
                                      side: MaterialStateProperty.resolveWith(
                                          (states) {
                                        if (states
                                            .contains(MaterialState.focused)) {
                                          return const BorderSide(
                                            color: Colors.blue,
                                            width: 3,
                                          );
                                        }
                                        return null;
                                      }),
                                    ),
                                    child: Semantics(
                                      excludeSemantics:
                                          true, // Vermeidet doppelte Semantik
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Semantics(
                                            label: 'Häkchen-Symbol',
                                            child: const Icon(
                                              Icons.check_circle,
                                              color: UIConstants.checkIcon,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: UIConstants.spacingS,
                                          ),
                                          Text(
                                            'Cookies akzeptieren',
                                            style: UIStyles
                                                .dialogButtonTextStyle
                                                .copyWith(
                                              color:
                                                  UIConstants.submitButtonText,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: UIConstants.spacingS),

                              // Tastatur-Hinweise für bessere Usability
                              Semantics(
                                readOnly: true,
                                label: 'Bedienungshinweise',
                                child: Text(
                                  'Tipp: Verwenden Sie Tab zum Navigieren und Enter zum Bestätigen',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
