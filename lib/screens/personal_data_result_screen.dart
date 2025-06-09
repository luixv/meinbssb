// In lib/screens/person_data_result_screen.dart

import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/screens/app_menu.dart';
import '/screens/connectivity_icon.dart';

class PersonDataResultScreen extends StatelessWidget {
  const PersonDataResultScreen({
    super.key,
    required this.success,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });

  final bool success;
  final Map<String, dynamic> userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final String displayMessage = success
        ? 'Ihre persönlichen Daten wurden erfolgreich aktualisiert.'
        : 'Ihre persönlichen Daten konnten nicht aktualisiert werden.';

    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Daten Aktualisierung',
          style: UIConstants.titleStyle,
        ),
        automaticallyImplyLeading: false,
        backgroundColor: UIConstants.backgroundColor,
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: ConnectivityIcon(),
          ),
          AppMenu(
            context: context,
            userData: userData,
            isLoggedIn: isLoggedIn,
            onLogout: onLogout,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: UIConstants.defaultPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                success ? Icons.check_circle_outline : Icons.error_outline,
                color:
                    success ? UIConstants.successColor : UIConstants.errorColor,
                size: 100,
              ),
              const SizedBox(height: UIConstants.spacingS * 2),
              Text(
                success ? 'Erfolg!' : 'Fehler!',
                style: UIConstants.titleStyle.copyWith(
                  color: success
                      ? UIConstants.successColor
                      : UIConstants.errorColor,
                ),
              ),
              const SizedBox(height: UIConstants.spacingS),
              Text(
                displayMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: UIConstants.bodyFontSize,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'personalDataResultFab',
        onPressed: () {
          Navigator.of(context).pushReplacementNamed(
            '/home',
            arguments: {'userData': userData, 'isLoggedIn': true},
          );
        },
        backgroundColor: UIConstants.defaultAppColor,
        child: const Icon(
          Icons.home,
          color: UIConstants.whiteColor,
        ),
      ),
    );
  }
}
