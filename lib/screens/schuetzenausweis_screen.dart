import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Import the intl package
import '/constants/ui_constants.dart';
import '/screens/app_menu.dart';
import '/screens/logo_widget.dart';
import '/services/api_service.dart';

class SchuetzenausweisScreen extends StatefulWidget {
  const SchuetzenausweisScreen({
    super.key,
    required this.personId,
    required this.userData,
  });
  final int personId;
  final Map<String, dynamic> userData;

  @override
  State<SchuetzenausweisScreen> createState() => _SchuetzenausweisScreenState();
}

class _SchuetzenausweisScreenState extends State<SchuetzenausweisScreen> {
  late Future<Uint8List> _schuetzenausweisFuture;
  late Future<List<dynamic>> _zweitmitgliedschaftenFuture;
  late Future<List<dynamic>> _passdatenZVEFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final passDataId = widget.userData['PASSDATENID'];

    _schuetzenausweisFuture = apiService.fetchSchuetzenausweis(widget.personId);
    _zweitmitgliedschaftenFuture = apiService.fetchZweitmitgliedschaften(
      widget.personId,
    );
    _passdatenZVEFuture = passDataId != null
        ? apiService.fetchPassdatenZVE(passDataId, widget.personId)
        : Future.value([]);
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: UIConstants.red),
          const SizedBox(height: UIConstants.defaultSpacing),
          Text(
            message,
            textAlign: TextAlign.center,
            style: UIConstants.errorStyle,
          ),
        ],
      ),
    );
  }

  String _formatDate(String? isoDateString) {
    if (isoDateString == null ||
        isoDateString.isEmpty ||
        isoDateString == 'N/A') {
      return 'N/A';
    }
    try {
      final DateTime dateTime = DateTime.parse(isoDateString);
      final DateFormat formatter = DateFormat('dd.MM.yyyy');
      return formatter.format(dateTime);
    } catch (e) {
      return isoDateString; // Return the original string in case of error
    }
  }

  Widget _buildZweitmitgliedschaftenSection(
    List<dynamic> zweitmitgliedschaften,
  ) {
    if (zweitmitgliedschaften.isEmpty) {
      return const Center(
        child: Text(
          'Keine Zweitmitgliedschaften gefunden.',
          style: UIConstants.bodyStyle,
        ),
      );
    }

    return Container(
      color: UIConstants.tableBackground,
      child: Center(
        child: Table(
          columnWidths: const {
            0: IntrinsicColumnWidth(),
            1: IntrinsicColumnWidth(),
            2: IntrinsicColumnWidth(),
          },
          border: null,
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Id',
                    style: UIConstants.titleStyle
                        .copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ), // Empty title for VereinID
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Zweitmitgliedschaften',
                    style: UIConstants.titleStyle
                        .copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Seit',
                    style: UIConstants.titleStyle
                        .copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
            for (final item in zweitmitgliedschaften)
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${item['VEREINID'] ?? 'N/A'}',
                      style: UIConstants.bodyStyle.copyWith(
                        fontSize: UIConstants.subtitleFontSize,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${item['VEREINNAME'] ?? 'Unbekannter Verein'}',
                      style: UIConstants.bodyStyle.copyWith(
                        fontSize: UIConstants.subtitleFontSize,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _formatDate(item['EINTRITTVEREIN']),
                      style: UIConstants.bodyStyle.copyWith(
                        fontSize: UIConstants.subtitleFontSize,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisziplinenSection(List<dynamic> disziplinen) {
    if (disziplinen.isEmpty) {
      return const Center(
        child: Text(
          'Keine Disziplinen gefunden.',
          style: UIConstants.bodyStyle,
        ),
      );
    }

    return Container(
      color: UIConstants.white,
      child: Center(
        child: Table(
          columnWidths: const {
            0: IntrinsicColumnWidth(),
            1: IntrinsicColumnWidth(),
            2: IntrinsicColumnWidth(),
          },
          border: null,
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Nr.',
                    style: UIConstants.titleStyle
                        .copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Disziplin',
                    style: UIConstants.titleStyle
                        .copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Verein',
                    style: UIConstants.titleStyle
                        .copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
            for (final item in disziplinen)
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      item['DISZIPLINNR'] ?? 'N/A',
                      style: UIConstants.bodyStyle.copyWith(
                        fontSize: UIConstants.subtitleFontSize,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      item['DISZIPLIN'] ?? 'N/A',
                      style: UIConstants.bodyStyle.copyWith(
                        fontSize: UIConstants.subtitleFontSize,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      item['VEREINNAME'] ?? 'N/A',
                      style: UIConstants.bodyStyle.copyWith(
                        fontSize: UIConstants.subtitleFontSize,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundGreen,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back button
        title: const Text(
          'Digitaler Schützenausweis',
          style: UIConstants.titleStyle,
        ),
        actions: [
          AppMenu(
            context: context,
            userData: widget.userData,
            isLoggedIn: true,
            onLogout: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LogoWidget(), // Display the logo at the top
            const SizedBox(height: UIConstants.defaultSpacing),
            FutureBuilder<Uint8List>(
              future: _schuetzenausweisFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: UIConstants.defaultAppColor,
                      strokeWidth: 2.0,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  String errorMessage = snapshot.error.toString();
                  if (errorMessage.startsWith('Exception: ')) {
                    errorMessage = errorMessage.substring('Exception: '.length);
                  }
                  return Center(
                    child: Text(
                      'Error beim Laden des Schützenausweises: $errorMessage',
                      style: UIConstants.errorStyle,
                    ),
                  );
                }
                if (snapshot.hasData) {
                  return Center(
                    child: SizedBox(
                      key: const ValueKey<String>('schuetzenausweis'),
                      child: Image.memory(snapshot.data!),
                    ),
                  );
                }
                return const Center(
                  child: Text(
                    'Kein Schützenausweis verfügbar',
                    style: UIConstants.bodyStyle,
                  ),
                );
              },
            ),
            const SizedBox(height: UIConstants.defaultSpacing),
            FutureBuilder<List<dynamic>>(
              future: _zweitmitgliedschaftenFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: UIConstants.defaultAppColor,
                      strokeWidth: 2.0,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return _buildErrorWidget(
                    'Fehler beim Laden der Zweitmitgliedschaften',
                  );
                }
                if (snapshot.hasData) {
                  return _buildZweitmitgliedschaftenSection(snapshot.data!);
                }
                return const Center(
                  child: Text(
                    'Keine Zweitmitgliedschaften gefunden.',
                    style: UIConstants.bodyStyle,
                  ),
                );
              },
            ),
            const SizedBox(height: UIConstants.defaultSpacing),
            FutureBuilder<List<dynamic>>(
              future: _passdatenZVEFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: UIConstants.defaultAppColor,
                      strokeWidth: 2.0,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return _buildErrorWidget('Fehler beim Laden der Disziplinen');
                }
                if (snapshot.hasData) {
                  return _buildDisziplinenSection(snapshot.data!);
                }
                return const Center(
                  child: Text(
                    'Keine Disziplinen gefunden.',
                    style: UIConstants.bodyStyle,
                  ),
                );
              },
            ),
            const SizedBox(height: UIConstants.defaultSpacing),
          ],
        ),
      ),
    );
  }
}
