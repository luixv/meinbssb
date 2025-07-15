import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/services/core/logger_service.dart';

class CookieConsent extends StatefulWidget {
  const CookieConsent({super.key, required this.child});
  final Widget child;

  @override
  State<CookieConsent> createState() => _CookieConsentState();
}

class _CookieConsentState extends State<CookieConsent> {
  bool _showConsent = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    LoggerService.logInfo('CookieConsent: initState called.');
    _checkConsentStatus();
  }

  Future<void> _checkConsentStatus() async {
    LoggerService.logInfo('CookieConsent: _checkConsentStatus called.');
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool('cookieConsentAccepted') ?? false;
    LoggerService.logInfo(
      'CookieConsent: SharedPreferences result: cookieConsentAccepted = $accepted',
    );

    if (mounted) {
      setState(() {
        _showConsent = !accepted;
        _loading = false;
      });
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
    if (_loading) {
      // While loading, just show the child (or a splash/loading if you want)
      return widget.child;
    }
    return Stack(
      children: [
        widget.child, // The main content of your app
        if (_showConsent) // Only show the overlay if consent is not accepted
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior
                  .opaque, // Ensures taps are caught by this layer
              onTap: () {
                LoggerService.logInfo(
                  'CookieConsent: Tap outside dialog detected, but not dismissed.',
                );
              },
              child: Container(
                key: const ValueKey('cookieConsentBackground'),
                color: const Color.fromARGB(128, 0, 0, 0),
                alignment: Alignment.center,
                child: Material(
                  color: UIConstants.backgroundColor,
                  borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
                  clipBehavior: Clip.antiAlias,
                  elevation: 10.0,
                  child: Container(
                    margin: const EdgeInsets.all(UIConstants.spacingS),
                    padding: const EdgeInsets.all(UIConstants.spacingS),
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                          padding: UIConstants.dialogPadding,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _acceptConsent,
                                  style: UIStyles.dialogAcceptButtonStyle,
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
