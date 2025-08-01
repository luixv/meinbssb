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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 150),
                  _buildDatumWithTime(),
                  const SizedBox(height: 10),
                  // Wrap each info field with a white background container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    color: Colors.white,
                    child: _buildInfoText(
                        'Passnummer:', widget.passnummer, context,),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    color: Colors.white,
                    child: _buildInfoText('Vorname:', widget.vorname, context),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    color: Colors.white,
                    child:
                        _buildInfoText('Nachname:', widget.nachname, context),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    color: Colors.white,
                    child: _buildInfoText(
                        'Geburtsdatum:', widget.geburtsdatum, context,),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatumWithTime() {
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
