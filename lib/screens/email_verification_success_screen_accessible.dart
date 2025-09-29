import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import '/constants/ui_constants.dart';
import '/screens/base_screen_layout_accessible.dart';
import '/models/user_data.dart';
import '/services/core/logger_service.dart';

/// BITV 2.0 compliant version of EmailVerificationSuccessScreen
/// Provides comprehensive accessibility features for German "Barrierefreiheit" requirements
///
/// Accessibility Features:
/// - Screen reader announcements in German
/// - Keyboard navigation support
/// - Semantic structure with proper headings
/// - Focus management
/// - High contrast compliance
/// - Success state communication
/// - BITV 2.0/WCAG 2.1 Level AA compliance
class EmailVerificationSuccessScreenAccessible extends StatefulWidget {
  const EmailVerificationSuccessScreenAccessible({
    super.key,
    required this.message,
    required this.userData,
  });

  final String message;
  final UserData? userData;

  @override
  State<EmailVerificationSuccessScreenAccessible> createState() =>
      _EmailVerificationSuccessScreenAccessibleState();
}

class _EmailVerificationSuccessScreenAccessibleState
    extends State<EmailVerificationSuccessScreenAccessible> {
  final FocusNode _actionButtonFocusNode = FocusNode();
  final FocusNode _screenFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Initial accessibility announcements
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _announceSuccessState();
      _setInitialFocus();
    });
  }

  @override
  void dispose() {
    _actionButtonFocusNode.dispose();
    _screenFocusNode.dispose();
    super.dispose();
  }

  /// Announces the success state to screen readers in German
  void _announceSuccessState() {
    final String announcement = widget.userData != null
        ? 'E-Mail-Bestätigung erfolgreich abgeschlossen. Sie sind angemeldet. Weiter zu Kontaktdaten verfügbar.'
        : 'E-Mail-Bestätigung erfolgreich abgeschlossen. Bitte melden Sie sich an. Weiter zur Anmeldung verfügbar.';

    SemanticsService.announce(
      announcement,
      TextDirection.ltr,
    );

    LoggerService.logInfo(
      'EmailVerificationSuccessAccessible: Success state announced to screen reader',
    );
  }

  /// Sets initial focus for accessibility
  void _setInitialFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _screenFocusNode.requestFocus();
    });
  }

  /// Handles the primary action (continue to next screen)
  Future<void> _handlePrimaryAction() async {
    final String actionAnnouncement = widget.userData != null
        ? 'Navigiere zu Kontaktdaten'
        : 'Navigiere zur Anmeldung';

    // Announce the action
    SemanticsService.announce(
      actionAnnouncement,
      TextDirection.ltr,
    );

    // Small delay to ensure announcement is heard
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    if (widget.userData != null) {
      Navigator.of(context).pushReplacementNamed(
        '/contact-data',
        arguments: {'userData': widget.userData, 'isLoggedIn': true},
      );
    } else {
      Navigator.of(context).pushReplacementNamed(
        '/login',
        arguments: {'userData': widget.userData, 'isLoggedIn': false},
      );
    }

    LoggerService.logInfo(
      'EmailVerificationSuccessAccessible: Navigation to ${widget.userData != null ? 'contact-data' : 'login'}',
    );
  }

  /// Handles keyboard events for accessibility
  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.space) {
        if (_actionButtonFocusNode.hasFocus) {
          _handlePrimaryAction();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = widget.userData != null;
    final String actionButtonLabel = isLoggedIn
        ? 'Zu Kontaktdaten weiterleiten'
        : 'Zur Anmeldung weiterleiten';
    final String actionButtonHint = isLoggedIn
        ? 'Öffnet die Kontaktdaten-Seite zur Verwaltung Ihrer Informationen'
        : 'Öffnet die Anmelde-Seite zur Authentifizierung';

    return Semantics(
      explicitChildNodes: true,
      label: 'E-Mail-Bestätigung erfolgreich abgeschlossen',
      hint: 'Erfolgsseite für die E-Mail-Verifikation',
      child: BaseScreenLayoutAccessible(
        title: 'E-Mail-Bestätigung erfolgreich',
        userData: widget.userData,
        isLoggedIn: isLoggedIn,
        onLogout: () {
          Navigator.pushReplacementNamed(context, '/login');
        },
        body: Focus(
          focusNode: _screenFocusNode,
          onKeyEvent: (node, event) {
            _handleKeyEvent(event);
            return KeyEventResult.handled;
          },
          child: Semantics(
            container: true,
            explicitChildNodes: true,
            label: 'Erfolgsmeldung E-Mail-Bestätigung',
            hint:
                'Bestätigung der erfolgreichen E-Mail-Verifikation mit Weiterleitung',
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.spacingL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // Success Icon with full accessibility
                    Semantics(
                      label: 'Erfolgreich',
                      hint: 'E-Mail-Bestätigung war erfolgreich',
                      image: true,
                      child: Container(
                        padding: const EdgeInsets.all(UIConstants.spacingM),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(60),
                          border: Border.all(
                            color: Colors.green.shade200,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: UIConstants.iconSizeXL,
                        ),
                      ),
                    ),

                    const SizedBox(height: UIConstants.spacingL),

                    // Success Heading
                    Semantics(
                      header: true,
                      label: 'Erfolgs-Überschrift',
                      child: const Text(
                        'E-Mail erfolgreich bestätigt',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: UIConstants.spacingM),

                    // Success Message with semantic structure
                    Semantics(
                      readOnly: true,
                      label: 'Erfolgsmeldung Details',
                      hint:
                          'Detaillierte Informationen zur erfolgreichen E-Mail-Bestätigung',
                      child: Container(
                        padding: const EdgeInsets.all(UIConstants.spacingM),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.shade200,
                          ),
                        ),
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            fontSize: UIConstants.dialogFontSize,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    const SizedBox(height: UIConstants.spacingL),

                    // Status Information
                    Semantics(
                      readOnly: true,
                      label: 'Status-Information',
                      child: Container(
                        padding: const EdgeInsets.all(UIConstants.spacingM),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.shade200,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isLoggedIn ? Icons.person : Icons.login,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: UIConstants.spacingS),
                            Text(
                              isLoggedIn
                                  ? 'Sie sind angemeldet'
                                  : 'Anmeldung erforderlich',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: UIConstants.spacingXL),

                    // Primary Action Button with full accessibility
                    Semantics(
                      button: true,
                      label: actionButtonLabel,
                      hint: actionButtonHint,
                      onTap: _handlePrimaryAction,
                      child: Focus(
                        focusNode: _actionButtonFocusNode,
                        child: ElevatedButton.icon(
                          onPressed: _handlePrimaryAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: UIConstants.primaryColor,
                            foregroundColor: UIConstants.whiteColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: UIConstants.spacingXL,
                              vertical: UIConstants.spacingM,
                            ),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            // Focus styling
                            side: _actionButtonFocusNode.hasFocus
                                ? const BorderSide(
                                    color: Colors.blue,
                                    width: 3,
                                  )
                                : null,
                          ),
                          icon: Icon(
                            isLoggedIn ? Icons.contacts : Icons.login,
                            size: 24,
                          ),
                          label: Text(
                            isLoggedIn ? 'Zu Kontaktdaten' : 'Zur Anmeldung',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: UIConstants.spacingM),

                    // Alternative navigation hint
                    Semantics(
                      readOnly: true,
                      label: 'Navigations-Hinweis',
                      child: Text(
                        'Tipp: Verwenden Sie Tab zum Navigieren und Enter zum Aktivieren',
                        style: TextStyle(
                          fontSize: 14,
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
    );
  }
}
