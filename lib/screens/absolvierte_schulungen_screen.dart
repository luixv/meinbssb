import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/screens/app_menu.dart';
import '/screens/connectivity_icon.dart';
import '/services/api_service.dart';
import '../services/core/logger_service.dart';

class AbsolvierteSchulungenScreen extends StatefulWidget {
  const AbsolvierteSchulungenScreen(
    this.userData, {
    required this.personId,
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });

  final Map<String, dynamic> userData;
  final int personId;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  AbsolvierteSchulungenScreenState createState() =>
      AbsolvierteSchulungenScreenState();
}

class AbsolvierteSchulungenScreenState
    extends State<AbsolvierteSchulungenScreen> {
  late Future<List<dynamic>> _absolvierteSchulungenFuture;

  @override
  void initState() {
    super.initState();
    _loadSchulungenData();
  }

  void _loadSchulungenData() {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      _absolvierteSchulungenFuture =
          apiService.fetchAbsolvierteSchulungen(widget.personId);
      LoggerService.logInfo(
        'AbsolvierteSchulungenScreen: Initiating completed trainings data fetch.',
      );
    } catch (e) {
      LoggerService.logError(
        'Error setting up completed trainings data fetch: $e',
      );
      _absolvierteSchulungenFuture =
          Future.value([]); // Return empty list on error
    }
  }

  void _handleLogout() {
    LoggerService.logInfo('Logging out user from AbsolvierteSchulungenScreen');
    widget.onLogout(); // Call the logout function provided by the parent.
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: UIConstants.backgroundColor,
        title: const Text(
          'Absolvierte Schulungen', // Screen title
          style: UIConstants.titleStyle,
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: ConnectivityIcon(),
          ),
          AppMenu(
            context: context,
            userData: widget.userData,
            isLoggedIn: widget.isLoggedIn,
            onLogout: _handleLogout,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _absolvierteSchulungenFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            LoggerService.logError(
              'Error loading completed trainings data in FutureBuilder: ${snapshot.error}',
            );
            return Center(
              child: Text(
                'Fehler beim Laden der Schulungsdaten: ${snapshot.error}',
              ),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            final List<dynamic> schulungen = snapshot.data!;

            if (schulungen.isEmpty) {
              return const Center(
                child: Text('Keine absolvierten Schulungen gefunden.'),
              );
            }

            return Padding(
              padding: UIConstants.defaultPadding,
              child: ListView.builder(
                itemCount: schulungen.length,
                itemBuilder: (context, index) {
                  final schulung = schulungen[index];
                  // Display AUSGESTELLTAM, BEZEICHNUNG, GUELTIGBIS
                  return Card(
                    color: UIConstants.cardColor,
                    margin: const EdgeInsets.only(
                      bottom: UIConstants.defaultSpacing,
                    ),
                    child: Padding(
                      padding: UIConstants.defaultPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoText(
                            label: 'Ausgestellt am:',
                            value: schulung['AUSGESTELLTAM'],
                          ),
                          const SizedBox(
                            height: UIConstants.listItemInterSpace,
                          ),
                          _buildInfoText(
                            label: 'Bezeichnung:',
                            value: schulung['BEZEICHNUNG'],
                          ),
                          const SizedBox(
                            height: UIConstants.listItemInterSpace,
                          ),
                          _buildInfoText(
                            label: 'Gültig bis:',
                            value: schulung['GUELTIGBIS'],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            // This case handles when snapshot.data is null (though covered by hasData check)
            return const Center(
              child: Text('Keine absolvierten Schulungen verfügbar.'),
            );
          }
        },
      ),
    );
  }

  // Helper method to build read-only info text lines
  Widget _buildInfoText({required String label, required String? value}) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: UIConstants.bodyFontSize,
          color: Colors.black,
        ),
        children: <TextSpan>[
          TextSpan(
            text: '$label ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value ?? 'N/A'), // Display 'N/A' if value is null
        ],
      ),
    );
  }
}
