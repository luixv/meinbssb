// Project: Mein BSSB
// Filename: password_reset_screen.dart
// Author: Luis Mandel / NTT DATA

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/screens/logo_widget.dart';
import 'package:meinbssb/services/api/auth_service.dart';
import 'package:meinbssb/services/core/error_service.dart';
import 'package:meinbssb/services/core/font_size_provider.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/widgets/scaled_text.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({
    required this.authService,
    super.key,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });
  final AuthService authService;
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
      final networkService =
          Provider.of<NetworkService>(context, listen: false);
      return !(await networkService.hasInternet());
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
      final response =
          await widget.authService.passwordReset(_passNumberController.text);

      if (response['ResultType'] == 1) {
        setState(() {
          _successMessage = response['ResultMessage'];
        });
      } else {
        setState(() {
          _errorMessage = response['ResultMessage'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = ErrorService.handleNetworkError(e);
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: UIConstants.passwordResetTitle,
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
            return Center(
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
                    ScaledText(
                      'Passwort zurücksetzen ist offline nicht verfügbar',
                      style: UIStyles.headerStyle.copyWith(
                        color: UIConstants.textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: UIConstants.spacingS),
                    ScaledText(
                      'Bitte stellen Sie sicher, dass Sie mit dem Internet verbunden sind, um Ihr Passwort zurückzusetzen.',
                      style: UIStyles.bodyStyle.copyWith(
                        color: UIConstants.greySubtitleTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Consumer<FontSizeProvider>(
            builder: (context, fontSizeProvider, child) {
              return SingleChildScrollView(
                padding: UIConstants.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LogoWidget(),
                    const SizedBox(height: UIConstants.spacingS),
                    ScaledText(
                      UIConstants.passwordResetTitle,
                      key: const Key('passwordResetTitle'),
                      style: UIStyles.headerStyle.copyWith(
                        color: UIConstants.defaultAppColor,
                        fontSize: UIStyles.headerStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingS),
                    if (_errorMessage.isNotEmpty)
                      ScaledText(
                        _errorMessage,
                        style: UIStyles.errorStyle.copyWith(
                          fontSize: UIStyles.errorStyle.fontSize! *
                              fontSizeProvider.scaleFactor,
                        ),
                      ),
                    if (_successMessage.isNotEmpty)
                      ScaledText(
                        _successMessage,
                        style: UIStyles.successStyle.copyWith(
                          fontSize: UIStyles.successStyle.fontSize! *
                              fontSizeProvider.scaleFactor,
                        ),
                      ),
                    TextField(
                      controller: _passNumberController,
                      style: UIStyles.bodyStyle.copyWith(
                        fontSize: UIStyles.bodyStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                      ),
                      decoration: UIStyles.formInputDecoration.copyWith(
                        labelText: UIConstants.passNumberLabel,
                        labelStyle: UIStyles.formLabelStyle.copyWith(
                          fontSize: UIStyles.formLabelStyle.fontSize! *
                              fontSizeProvider.scaleFactor,
                        ),
                        floatingLabelStyle: UIStyles.formLabelStyle.copyWith(
                          fontSize: UIStyles.formLabelStyle.fontSize! *
                              fontSizeProvider.scaleFactor,
                        ),
                        hintStyle: UIStyles.formLabelStyle.copyWith(
                          fontSize: UIStyles.formLabelStyle.fontSize! *
                              fontSizeProvider.scaleFactor,
                        ),
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingS),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        key: const Key('forgotPasswordButton'),
                        onPressed: _isLoading ? null : _resetPassword,
                        style: UIStyles.defaultButtonStyle,
                        child: SizedBox(
                          height: UIConstants.defaultButtonHeight,
                          child: Center(
                            child: _isLoading
                                ? UIConstants.defaultLoadingIndicator
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.lock_reset,
                                        color: Colors.white,
                                        size: UIConstants.iconSizeL * fontSizeProvider.scaleFactor,
                                      ),
                                      const SizedBox(
                                        width: UIConstants.spacingS,
                                      ),
                                      ScaledText(
                                        UIConstants.resetPasswordButtonLabel,
                                        style: UIStyles.buttonStyle.copyWith(
                                          fontSize:
                                              UIStyles.buttonStyle.fontSize! *
                                                  fontSizeProvider.scaleFactor,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
