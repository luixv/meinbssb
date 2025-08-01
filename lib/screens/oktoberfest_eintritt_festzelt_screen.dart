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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  _buildDatumWithTime(),
                  const SizedBox(height: 20),
                  _buildInfoRow('Passnummer:', widget.passnummer),
                  const SizedBox(height: 10),
                  _buildInfoRow('Vorname:', widget.vorname),
                  const SizedBox(height: 10),
                  _buildInfoRow('Nachname:', widget.nachname),
                  const SizedBox(height: 10),
                  _buildInfoRow('Geburtsdatum:', widget.geburtsdatum),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatumWithTime() {
    // Shows date and real-time clock with same font size, centered
    return Column(
      children: [
        Text(
          widget.date,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          _currentTime,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    // Simply show label and value, centered
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
