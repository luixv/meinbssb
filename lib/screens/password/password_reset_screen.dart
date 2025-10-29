import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/messages.dart';

import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/screens/logo_widget.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/error_service.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import 'package:meinbssb/screens/password/password_reset_success_screen.dart';
import 'package:meinbssb/screens/password/password_reset_fail_screen.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({
    required this.apiService,
    super.key,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });
  final ApiService apiService;
  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  PasswordResetScreenState createState() => PasswordResetScreenState();
}

class PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController _passNumberController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  @override
  void dispose() {
    _passNumberController.dispose();
    super.dispose();
  }

  Future<bool> _isOffline() async {
    try {
      return !(await widget.apiService.hasInternet());
    } catch (e) {
      return true; // Assume offline if we can't check
    }
  }

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _successMessage = '';
    });

    try {
      final response = await widget.apiService.passwordReset(
        _passNumberController.text,
      );
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      if (response['ResultType'] == 1) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (_) => PasswordResetSuccessScreen(
                  message: (response['ResultMessage'] ?? '').toString(),
                  userData: widget.userData,
                ),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (_) => PasswordResetFailScreen(
                  message: (response['ResultMessage'] ?? '').toString(),
                  userData: widget.userData,
                ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (_) => PasswordResetFailScreen(
                message: ErrorService.handleNetworkError(e),
                userData: widget.userData,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: Messages.passwordResetTitle,
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout,
      body: FutureBuilder<bool>(
        future: _isOffline(),
        builder: (context, offlineSnapshot) {
          if (offlineSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (offlineSnapshot.hasData && offlineSnapshot.data == true) {
            return Semantics(
              label:
                  'Passwort zurücksetzen ist offline nicht verfügbar. Bitte stellen Sie eine Internetverbindung her, um Ihr Passwort zurückzusetzen.',
              child: Center(
                child: Padding(
                  padding: UIConstants.screenPadding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.wifi_off,
                        size: UIConstants.wifiOffIconSize,
                        color: UIConstants.noConnectivityIcon,
                      ),
                      const SizedBox(height: UIConstants.spacingM),
                      Semantics(
                        label:
                            'Fehlermeldung: Passwort zurücksetzen ist offline nicht verfügbar',
                        child: ScaledText(
                          'Passwort zurücksetzen ist offline nicht verfügbar',
                          style: UIStyles.headerStyle.copyWith(
                            color: UIConstants.textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingS),
                      Semantics(
                        label:
                            'Hinweis: Bitte stellen Sie sicher, dass Sie mit dem Internet verbunden sind, um Ihr Passwort zurückzusetzen.',
                        child: ScaledText(
                          'Bitte stellen Sie sicher, dass Sie mit dem Internet verbunden sind, um Ihr Passwort zurückzusetzen.',
                          style: UIStyles.bodyStyle.copyWith(
                            color: UIConstants.greySubtitleTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Semantics(
            label:
                'Passwort zurücksetzen. Geben Sie Ihre Schützenpassnummer ein, um Ihr Passwort zurückzusetzen. Bestätigung und Fehlerhinweise werden angezeigt.',
            child: Consumer<FontSizeProvider>(
              builder: (context, fontSizeProvider, child) {
                return SingleChildScrollView(
                  padding: UIConstants.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LogoWidget(),
                      const SizedBox(height: UIConstants.spacingS),
                      Semantics(
                        label: 'Titel: Passwort zurücksetzen',
                        child: ScaledText(
                          Messages.passwordResetTitle,
                          key: const Key('passwordResetTitle'),
                          style: UIStyles.headerStyle.copyWith(
                            color: UIConstants.defaultAppColor,
                            fontSize:
                                UIStyles.headerStyle.fontSize! *
                                fontSizeProvider.scaleFactor,
                          ),
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingS),
                      if (_errorMessage.isNotEmpty)
                        Semantics(
                          label: 'Fehlermeldung: $_errorMessage',
                          child: ScaledText(
                            _errorMessage,
                            style: UIStyles.errorStyle.copyWith(
                              fontSize:
                                  UIStyles.errorStyle.fontSize! *
                                  fontSizeProvider.scaleFactor,
                            ),
                          ),
                        ),
                      if (_successMessage.isNotEmpty)
                        Semantics(
                          label: 'Erfolgsmeldung: $_successMessage',
                          child: ScaledText(
                            _successMessage,
                            style: UIStyles.successStyle.copyWith(
                              fontSize:
                                  UIStyles.successStyle.fontSize! *
                                  fontSizeProvider.scaleFactor,
                            ),
                          ),
                        ),
                      Semantics(
                        label: 'Schützenausweisnummer Eingabefeld',
                        child: TextField(
                          controller: _passNumberController,
                          style: UIStyles.bodyStyle.copyWith(
                            fontSize:
                                UIStyles.bodyStyle.fontSize! *
                                fontSizeProvider.scaleFactor,
                          ),
                          decoration: UIStyles.formInputDecoration.copyWith(
                            labelText: Messages.passNumberLabel,
                            labelStyle: UIStyles.formLabelStyle.copyWith(
                              fontSize:
                                  UIStyles.formLabelStyle.fontSize! *
                                  fontSizeProvider.scaleFactor,
                            ),
                            floatingLabelStyle: UIStyles.formLabelStyle
                                .copyWith(
                                  fontSize:
                                      UIStyles.formLabelStyle.fontSize! *
                                      fontSizeProvider.scaleFactor,
                                ),
                            hintStyle: UIStyles.formLabelStyle.copyWith(
                              fontSize:
                                  UIStyles.formLabelStyle.fontSize! *
                                  fontSizeProvider.scaleFactor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingS),
                      Semantics(
                        label: 'Passwort zurücksetzen Button',
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            key: const Key('forgotPasswordButton'),
                            onPressed: _isLoading ? null : _resetPassword,
                            style: UIStyles.defaultButtonStyle,
                            child: SizedBox(
                              height: UIConstants.defaultButtonHeight,
                              child: Center(
                                child:
                                    _isLoading
                                        ? UIConstants.defaultLoadingIndicator
                                        : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.lock_reset,
                                              color: Colors.white,
                                              size:
                                                  UIConstants.iconSizeM *
                                                  fontSizeProvider.scaleFactor,
                                            ),
                                            const SizedBox(
                                              width: UIConstants.spacingS,
                                            ),
                                            ScaledText(
                                              Messages.resetPasswordButtonLabel,
                                              style: UIStyles.buttonStyle
                                                  .copyWith(
                                                    fontSize:
                                                        UIStyles
                                                            .buttonStyle
                                                            .fontSize! *
                                                        fontSizeProvider
                                                            .scaleFactor,
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
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
