import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:meinbssb/screens/base_screen_layout_accessible.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/services/core/logger_service.dart';

/// BITV 2.0 compliant version of BankDataSuccessScreen
/// Provides comprehensive accessibility features for German "Barrierefreiheit" requirements
///
/// Accessibility Features:
/// - Screen reader announcements in German
/// - Keyboard navigation support
/// - Semantic structure with proper status communication
/// - Focus management for success/error states
/// - High contrast compliance
/// - ARIA labels and descriptions
/// - BITV 2.0/WCAG 2.1 Level AA compliance
class BankDataSuccessScreenAccessible extends StatefulWidget {
  const BankDataSuccessScreenAccessible({
    super.key,
    required this.success,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });

  final bool success;
  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  State<BankDataSuccessScreenAccessible> createState() =>
      _BankDataSuccessScreenAccessibleState();
}

class _BankDataSuccessScreenAccessibleState
    extends State<BankDataSuccessScreenAccessible> {
  final FocusNode _screenFocusNode = FocusNode();
  final FocusNode _actionButtonFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Initial accessibility announcements
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _announceResultState();
      _setInitialFocus();
    });
  }

  @override
  void dispose() {
    _screenFocusNode.dispose();
    _actionButtonFocusNode.dispose();
    super.dispose();
  }

  /// Announces the result state to screen readers in German
  void _announceResultState() {
    final String announcement = widget.success
        ? 'Erfolg: Ihre Bankdaten wurden erfolgreich gespeichert. Weiter zum Profil verfügbar.'
        : 'Fehler: Ein Fehler ist beim Speichern der Bankdaten aufgetreten. Weiter zum Profil verfügbar.';

    SemanticsService.announce(
      announcement,
      TextDirection.ltr,
    );

    LoggerService.logInfo(
      'BankDataSuccessAccessible: Result state announced - Success: ${widget.success}',
    );
  }

  /// Sets initial focus for accessibility
  void _setInitialFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _screenFocusNode.requestFocus();
    });
  }

  /// Handles the profile navigation action
  Future<void> _handleProfileNavigation() async {
    // Announce the navigation action
    SemanticsService.announce(
      'Navigiere zum Profil',
      TextDirection.ltr,
    );

    // Small delay to ensure announcement is heard
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(
      '/profile',
      arguments: {'userData': widget.userData, 'isLoggedIn': true},
    );

    LoggerService.logInfo(
      'BankDataSuccessAccessible: Navigation to profile initiated',
    );
  }

  /// Handles keyboard events for accessibility
  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter ||
          event.logicalKey == LogicalKeyboardKey.space) {
        if (_actionButtonFocusNode.hasFocus) {
          _handleProfileNavigation();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String statusLabel = widget.success ? 'Erfolg' : 'Fehler';
    final String statusMessage = widget.success
        ? 'Ihre Bankdaten wurden erfolgreich gespeichert.'
        : 'Es ist ein Fehler aufgetreten.';
    final String statusDescription = widget.success
        ? 'Die Speicherung der Bankdaten war erfolgreich'
        : 'Bei der Speicherung der Bankdaten ist ein Fehler aufgetreten';

    return Semantics(
      explicitChildNodes: true,
      label: 'Bankdaten Ergebnis-Seite',
      hint: 'Ergebnis der Bankdaten-Speicherung mit Navigation zum Profil',
      child: BaseScreenLayoutAccessible(
        title: 'Bankdaten',
        userData: widget.userData,
        isLoggedIn: widget.isLoggedIn,
        onLogout: widget.onLogout,
        semanticScreenLabel: 'Bankdaten Ergebnis',
        screenDescription: 'Ergebnis der Bankdaten-Speicherung anzeigen',
        body: Focus(
          focusNode: _screenFocusNode,
          onKeyEvent: (node, event) {
            _handleKeyEvent(event);
            return KeyEventResult.handled;
          },
          child: Semantics(
            container: true,
            explicitChildNodes: true,
            label: 'Bankdaten Ergebnis',
            hint: statusDescription,
            liveRegion: true,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.spacingL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // Status Icon with full accessibility
                    Semantics(
                      label: statusLabel,
                      hint: statusDescription,
                      image: true,
                      child: Container(
                        padding: const EdgeInsets.all(UIConstants.spacingM),
                        decoration: BoxDecoration(
                          color: widget.success
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(60),
                          border: Border.all(
                            color: widget.success
                                ? Colors.green.shade200
                                : Colors.red.shade200,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          widget.success ? Icons.check_circle : Icons.error,
                          color: widget.success
                              ? UIConstants.successColor
                              : UIConstants.errorColor,
                          size: UIConstants.iconSizeXL,
                        ),
                      ),
                    ),

                    const SizedBox(height: UIConstants.spacingL),

                    // Status Message with semantic structure
                    Semantics(
                      readOnly: true,
                      label: 'Status-Nachricht',
                      hint: statusMessage,
                      child: Container(
                        padding: const EdgeInsets.all(UIConstants.spacingM),
                        decoration: BoxDecoration(
                          color: widget.success
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: widget.success
                                ? Colors.green.shade200
                                : Colors.red.shade200,
                          ),
                        ),
                        child: Text(
                          statusMessage,
                          style: const TextStyle(
                            fontSize: UIConstants.dialogFontSize,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    const SizedBox(height: UIConstants.spacingXL),

                    // Additional Status Information
                    Semantics(
                      readOnly: true,
                      label: 'Zusätzliche Information',
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
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: UIConstants.spacingS),
                            Flexible(
                              child: Text(
                                widget.success
                                    ? 'Sie können nun zu Ihrem Profil zurückkehren'
                                    : 'Bitte versuchen Sie es später erneut oder kontaktieren Sie den Support',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: UIConstants.spacingXL),

                    // Navigation Button with full accessibility
                    Semantics(
                      button: true,
                      label: 'Zum Profil weiterleiten',
                      hint:
                          'Öffnet das Benutzerprofil zur Verwaltung Ihrer Daten',
                      onTap: _handleProfileNavigation,
                      child: Focus(
                        focusNode: _actionButtonFocusNode,
                        child: ElevatedButton.icon(
                          onPressed: _handleProfileNavigation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: UIConstants.defaultAppColor,
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
                          icon: const Icon(
                            Icons.person,
                            size: 24,
                          ),
                          label: const Text(
                            'Zum Profil',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: UIConstants.spacingM),

                    // Keyboard navigation hint
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
