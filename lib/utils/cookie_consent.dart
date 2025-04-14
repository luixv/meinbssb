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
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      margin: const EdgeInsets.all(UIConstants.defaultSpacing),
                      padding: const EdgeInsets.all(UIConstants.defaultPadding),
                      decoration: BoxDecoration(
                        color: UIConstants.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'We use cookies',
                            style: UIConstants.headerStyle.copyWith(
                              color: UIConstants.defaultAppColor,
                            ),
                          ),
                          const SizedBox(height: UIConstants.smallSpacing),
                          Text(
                            'To improve your experience, we use cookies. By continuing to use the app, you accept our use of cookies.',
                            textAlign: TextAlign.center,
                            style: UIConstants.bodyStyle.copyWith(
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                          const SizedBox(height: UIConstants.defaultSpacing),
                          SizedBox(
                            width: 200.0,
                            child: ElevatedButton(
                              onPressed: _acceptConsent,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: UIConstants.lightGreen,
                                padding: UIConstants.buttonPadding,
                              ),
                              child: Text(
                                'Accept',
                                style: UIConstants.bodyStyle.copyWith(
                                  color: UIConstants.white,
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
          ),
      ],
    );
  }
}
