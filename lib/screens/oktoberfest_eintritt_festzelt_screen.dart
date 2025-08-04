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
                image: AssetImage('assets/images/BSSB_Wappen_dimmed.png'),
                fit: BoxFit.fitHeight, // Changed from BoxFit.cover
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
                  const SizedBox(height: UIConstants.spacingS),
                  _buildDatumWithTime(),
                  const SizedBox(height: UIConstants.spacingS),
                  _buildInfoTable(),
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
                fontSize: UIConstants.titleFontSize,
                color: Colors.black,
              ),
        ),
        const SizedBox(height: UIConstants.spacingS),
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

  Widget _buildInfoTable() {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: IntrinsicColumnWidth(),
      },
      children: [
        _buildTableRow('Passnummer', widget.passnummer),
        _buildTableRow('Vorname', widget.vorname),
        _buildTableRow('Nachname', widget.nachname),
        _buildTableRow('Geburtsdatum', widget.geburtsdatum),
      ],
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        // Label aligned right
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spacingS,
            vertical: UIConstants.spacingXS,
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize:
                    UIConstants.titleFontSize, // Increased font size for label
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // Value with intrinsic width
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spacingS,
            vertical: UIConstants.spacingXS,
          ),
          child: IntrinsicWidth(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(UIConstants.borderWidth),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.spacingS,
                vertical: UIConstants.spacingXS,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: UIConstants.titleFontSize, // Increased font size
                    color: Colors.black,
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
