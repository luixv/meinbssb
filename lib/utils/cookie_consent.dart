import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/constants/ui_constants.dart';

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
    _checkConsentStatus();
  }

  Future<void> _checkConsentStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool('cookieConsentAccepted') ?? false;

    if (!accepted) {
      setState(() {
        _showConsent = true;
      });
    }
  }

  Future<void> _acceptConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cookieConsentAccepted', true);
    setState(() {
      _showConsent = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showConsent)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {}, // Absorb taps without doing anything
              child: Center(
                child: Material(
                  color: UIConstants.cookiesDialogColor,
                  child: Container(
                    margin: const EdgeInsets.all(UIConstants.spacingS),
                    padding: const EdgeInsets.all(UIConstants.spacingS),
                    decoration: BoxDecoration(
                      color: UIConstants.boxDecorationColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Wir verwenden Cookies',
                          style: UIConstants.titleStyle.copyWith(
                            color: UIConstants.defaultAppColor,
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingL),
                        Text(
                          'Um diese App offline nutzen zu können, verwenden wir Cookies.', // \n Durch die weitere Nutzung der App akzeptieren Sie unsere Verwendung von Cookies.
                          textAlign: TextAlign.center,
                          style: UIConstants.bodyStyle.copyWith(
                            backgroundColor: UIConstants.cookiesDialogColor,
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingS),
                        SizedBox(
                          width: 200.0,
                          child: ElevatedButton(
                            onPressed: _acceptConsent,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  UIConstants.acceptButtonBackground,
                              padding: UIConstants.buttonPadding,
                            ),
                            child: Text(
                              'Zustimmen',
                              style: UIConstants.bodyStyle.copyWith(
                                color: UIConstants.acceptButtonBackground,
                              ),
                            ),
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
