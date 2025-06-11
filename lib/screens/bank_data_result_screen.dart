import 'package:flutter/material.dart';
import '/screens/base_screen_layout.dart';
import '/constants/ui_constants.dart';

class BankDataResultScreen extends StatelessWidget {
  const BankDataResultScreen({
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
    return BaseScreenLayout(
      title: 'Bankdaten',
      userData: userData,
      isLoggedIn: isLoggedIn,
      onLogout: onLogout,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              success
                  ? 'Ihre Bankdaten wurden erfolgreich gespeichert.'
                  : 'Es ist ein Fehler aufgetreten.',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'schuetzenausweisFab',
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
