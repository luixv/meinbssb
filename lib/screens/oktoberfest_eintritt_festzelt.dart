import 'package:flutter/material.dart';
import '/screens/base_screen_layout.dart';
import '/constants/ui_constants.dart';

class OktoberfestEintrittFestzelt extends StatelessWidget {
  const OktoberfestEintrittFestzelt({
    super.key,
    required this.date,
    required this.passnummer,
    required this.vorname,
    required this.nachname,
    required this.geburtsdatum,
  });
  final String date;
  final String passnummer;
  final String vorname;
  final String nachname;
  final String geburtsdatum;

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Eintritt Festzelt',
      userData: null, // or pass userData if needed
      isLoggedIn: true, // or false depending on your app logic
      onLogout: () {}, // pass a function if required
      body: SingleChildScrollView(
        padding: UIConstants.defaultPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoText('Datum:', date, context),
            const SizedBox(height: 10),
            _buildInfoText('Passnummer:', passnummer, context),
            const SizedBox(height: 10),
            _buildInfoText('Vorname:', vorname, context),
            const SizedBox(height: 10),
            _buildInfoText('Nachname:', nachname, context),
            const SizedBox(height: 10),
            _buildInfoText('Geburtsdatum:', geburtsdatum, context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoText(String label, String value, BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}
