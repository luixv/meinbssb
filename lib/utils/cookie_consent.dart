import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/services/core/logger_service.dart';

class CookieConsent extends StatefulWidget {
  const CookieConsent({super.key, required this.child});
  final Widget child;

  @override
  State<CookieConsent> createState() => _CookieConsentState();
}

class _CookieConsentState extends State<CookieConsent> {
  bool _showConsent = false;

  @override
  void initState() {
    super.initState();
    LoggerService.logInfo('CookieConsent: initState called.');
    // Set _showConsent to true immediately in initState.
    // This ensures the dimmed background (and the dialog it contains)
    // is part of the very first frame rendered for this widget.
    _showConsent =
        true; // Set to true right away for instant background dimming

    // Schedule the actual consent check after the initial build phase.
    // This asynchronous check will then determine if _showConsent should be
    // set to false (hiding the dialog) if consent was already accepted.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LoggerService.logInfo('CookieConsent: addPostFrameCallback triggered.');
      _checkConsentStatus();
    });
  }

  Future<void> _checkConsentStatus() async {
    LoggerService.logInfo('CookieConsent: _checkConsentStatus called.');
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool('cookieConsentAccepted') ?? false;
    LoggerService.logInfo(
      'CookieConsent: SharedPreferences result: cookieConsentAccepted = $accepted',
    );

    if (accepted) {
      if (mounted) {
        setState(() {
          _showConsent =
              false; // Hide the overlay if consent was already accepted
        });
      }
    }
  }

  Future<void> _acceptConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cookieConsentAccepted', true);
    if (mounted) {
      setState(() {
        _showConsent = false; // Hide the custom cookie consent overlay
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child, // The main content of your app
        if (_showConsent) // Only show the overlay if consent is not accepted
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior
                  .opaque, // Ensures taps are caught by this layer
              onTap: () {
                // Tapping outside the dialog could potentially close it,
                // but since barrierDismissible is false in a showDialog context,
                // here we prevent any tap from closing it unless a button is pressed.
                LoggerService.logInfo(
                  'CookieConsent: Tap outside dialog detected, but not dismissed.',
                );
              },
              child: Container(
                key: const ValueKey(
                  'cookieConsentBackground',
                ), // Added a key for debugging/identification
                // Replaced Colors.black.withOpacity(0.5) with Color.fromARGB to fix the deprecation warning
                color: const Color.fromARGB(
                  128,
                  0,
                  0,
                  0,
                ), // This creates the dimmed background effect
                alignment: Alignment.center,
                child: Material(
                  color: UIConstants.backgroundColor,
                  borderRadius: BorderRadius.circular(
                    UIConstants.cornerRadius,
                  ), // Apply rounded corners
                  clipBehavior:
                      Clip.antiAlias, // Clip children to the rounded border
                  elevation:
                      10.0, // Added elevation for a subtle shadow and consistent look
                  child: Container(
                    margin: const EdgeInsets.all(
                      UIConstants.spacingS,
                    ), // Inner margin for content
                    padding: const EdgeInsets.all(
                      UIConstants.spacingS,
                    ), // Inner padding for content
                    constraints: const BoxConstraints(
                      maxWidth: 400,
                    ), // Limit dialog width for larger screens
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Wrap content tightly
                      children: [
                        const Text(
                          UIConstants.cookieConsentTitle,
                          style: UIStyles.dialogTitleStyle,
                        ),
                        const SizedBox(height: UIConstants.spacingL),
                        const Text(
                          UIConstants.cookieConsentMessage,
                          textAlign: TextAlign.center,
                          style: UIStyles.dialogContentStyle,
                        ),
                        const SizedBox(height: UIConstants.spacingS),
                        Padding(
                          padding: UIConstants
                              .dialogPadding, // Consistent padding for buttons
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .center, // Center the single button
                            children: [
                              // Removed the "Abbrechen" button and horizontal spacing
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _acceptConsent, // Handle accept
                                  style: UIStyles
                                      .dialogAcceptButtonStyle, // Consistent accept button style
                                  child: Row(
                                    mainAxisAlignment:
                                        UIConstants.centerAlignment,
                                    children: [
                                      const Icon(
                                        Icons.check,
                                        color: UIConstants.checkIcon,
                                      ),
                                      UIConstants.horizontalSpacingS,
                                      Text(
                                        'Zustimmen',
                                        style: UIStyles.dialogButtonTextStyle
                                            .copyWith(
                                          color: UIConstants.submitButtonText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
