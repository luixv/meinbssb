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
    final size = MediaQuery.of(context).size;

    return BaseScreenLayout(
      title: 'Eintritt Festzelt',
      userData: null,
      isLoggedIn: true,
      onLogout: () {},
      body: Stack(
        children: [
          // Background image covering full height
          Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/BSSB_Wappen.png'),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          // Centered info
          SingleChildScrollView(
            padding: UIConstants.defaultPadding,
            child: Center(
              // Center widget to center all content
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // More space on top
                  const SizedBox(height: 150),
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
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText(String label, String value, BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.black,
            ),
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
