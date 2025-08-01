import 'dart:async';

import 'package:flutter/material.dart';

import '/screens/base_screen_layout.dart';
import '/constants/ui_constants.dart';

class OktoberfestEintrittFestzelt extends StatefulWidget {
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
  OktoberfestEintrittFestzeltState createState() =>
      OktoberfestEintrittFestzeltState();
}

class OktoberfestEintrittFestzeltState
    extends State<OktoberfestEintrittFestzelt> {
  late String _currentTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = _getCurrentTime();
    _startClock();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startClock() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = _getCurrentTime();
      });
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(now.hour)}:${twoDigits(now.minute)}:${twoDigits(now.second)}';
  }

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
          // Background image
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
          // Center all info vertically and horizontally
          Center(
            child: SingleChildScrollView(
              padding: UIConstants.defaultPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  _buildDatumWithTime(),
                  const SizedBox(height: 20),
                  // Each info line with white background and black border only for values
                  _buildLabeledValue('Passnummer', widget.passnummer),
                  const SizedBox(height: 10),
                  _buildLabeledValue('Vorname', widget.vorname),
                  const SizedBox(height: 10),
                  _buildLabeledValue('Nachname', widget.nachname),
                  const SizedBox(height: 10),
                  _buildLabeledValue('Geburtsdatum', widget.geburtsdatum),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatumWithTime() {
    // Shows date and clock with same font size centered
    return Column(
      children: [
        Text(
          widget.date,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize:
                    UIConstants.titleFontSize, // Use constant for font size
                color: Colors.black,
              ),
        ),
        const SizedBox(
          height: UIConstants.spacingS,
        ), // Use constant for spacing
        Text(
          _currentTime,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: UIConstants.titleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
        ),
      ],
    );
  }

  Widget _buildLabeledValue(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label (plain text)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: UIConstants.spacingS),
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: UIConstants.bodyFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Value with white background and black border
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spacingS,
            vertical: UIConstants.spacingXS,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black), // black border
            borderRadius: BorderRadius.circular(UIConstants.borderWidth),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: UIConstants.bodyFontSize,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
