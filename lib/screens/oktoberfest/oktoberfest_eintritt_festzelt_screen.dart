import 'dart:async';

import 'package:flutter/material.dart';

import '/services/api_service.dart';
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
    required this.apiService,
  });
  final String date;
  final String passnummer;
  final String vorname;
  final String nachname;
  final String geburtsdatum;
  final ApiService apiService;

  @override
  OktoberfestEintrittFestzeltState createState() =>
      OktoberfestEintrittFestzeltState();
}

class OktoberfestEintrittFestzeltState
    extends State<OktoberfestEintrittFestzelt> {
  late String _currentTime;
  Timer? _timer;
  bool _hasInternet = true;
  bool _checkingConnection = false;

  @override
  void initState() {
    super.initState();
    _currentTime = _getCurrentTime();
    _startClock();
    _checkNetworkConnectivity();
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

  Future<void> _checkNetworkConnectivity() async {
    if (!mounted) return;

    setState(() {
      _checkingConnection = true;
    });

    try {
      final hasConnection = await widget.apiService.hasInternet();
      if (mounted) {
        setState(() {
          _hasInternet = hasConnection;
          _checkingConnection = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasInternet = false;
          _checkingConnection = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BaseScreenLayout(
      title: 'Eintritt Festzelt',
      userData: null,
      isLoggedIn: true,
      onLogout: () {},
      body: Semantics(
        container: true,
        label:
            'Oktoberfest Eintritt Festzelt. Zeigt Eintrittsdaten, aktuelle Uhrzeit, Netzwerkstatus und persönliche Informationen für das Festzelt beim Oktoberfest.',
        child: Stack(
          children: [
            // Background image
            Container(
              width: size.width,
              height: size.height,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/BSSB_Wappen_dimmed.png'),
                  fit: BoxFit.fitHeight,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: UIConstants.defaultPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: UIConstants.spacingS),
                    Semantics(
                      label:
                          _checkingConnection
                              ? 'Netzwerkstatus wird geprüft'
                              : (_hasInternet ? 'Online' : 'Offline'),
                      child: _buildNetworkStatus(),
                    ),
                    const SizedBox(height: UIConstants.spacingS),
                    Semantics(
                      label: 'Datum: ${widget.date}, Uhrzeit: $_currentTime',
                      child: _buildDatumWithTime(),
                    ),
                    const SizedBox(height: UIConstants.spacingS),
                    Semantics(
                      label:
                          'Persönliche Daten: Passnummer ${widget.passnummer}, Vorname ${widget.vorname}, Nachname ${widget.nachname}, Geburtsdatum ${widget.geburtsdatum}',
                      child: _buildInfoTable(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkStatus() {
    if (_checkingConnection) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(UIConstants.textColor),
            ),
          ),
          SizedBox(width: UIConstants.spacingS),
          Text(
            'Verbindung prüfen...',
            style: TextStyle(
              color: UIConstants.textColor,
              fontSize: UIConstants.bodyFontSize,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _hasInternet ? Icons.wifi : Icons.wifi_off,
          color: _hasInternet ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: UIConstants.spacingXS),
        Text(
          _hasInternet ? 'Online' : 'Offline',
          style: TextStyle(
            color: _hasInternet ? Colors.green : Colors.red,
            fontSize: UIConstants.bodyFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: UIConstants.spacingS),
        GestureDetector(
          onTap: _checkNetworkConnectivity,
          child: const Icon(
            Icons.refresh,
            color: UIConstants.textColor,
            size: 16,
          ),
        ),
      ],
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
            color: UIConstants.textColor,
          ),
        ),
        const SizedBox(height: UIConstants.spacingS),
        Text(
          _currentTime,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: UIConstants.titleFontSize,
            fontWeight: FontWeight.bold,
            color: UIConstants.textColor,
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
                color: UIConstants.whiteColor,
                border: Border.all(color: UIConstants.blackColor),
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
                    color: UIConstants.blackColor,
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
