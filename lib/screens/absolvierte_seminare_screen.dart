import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/services/api_service.dart';
import '/services/core/logger_service.dart';
import '/screens/base_screen_layout.dart';

class AbsolvierteSeminareScreen extends StatefulWidget {
  const AbsolvierteSeminareScreen(
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
  AbsolvierteSeminareScreenState createState() =>
      AbsolvierteSeminareScreenState();
}

class AbsolvierteSeminareScreenState extends State<AbsolvierteSeminareScreen> {
  late Future<List<dynamic>> _absolvierteSeminareFuture;

  @override
  void initState() {
    super.initState();
    _loadSeminareData();
  }

  void _loadSeminareData() {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      _absolvierteSeminareFuture =
          apiService.fetchAbsolvierteSeminare(widget.personId);
      LoggerService.logInfo(
        'AbsolvierteSeminareScreen: Initiating completed trainings data fetch.',
      );
    } catch (e) {
      LoggerService.logError(
        'Error setting up completed trainings data fetch: $e',
      );
      _absolvierteSeminareFuture =
          Future.value([]); // Return empty list on error
    }
  }

  void _handleLogout() {
    LoggerService.logInfo('Logging out user from AbsolvierteSeminareScreen');
    widget.onLogout(); // Call the logout function provided by the parent.
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Absolvierte Seminare',
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: _handleLogout,
      body: FutureBuilder<List<dynamic>>(
        future: _absolvierteSeminareFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            LoggerService.logError(
              'Error loading completed trainings data in FutureBuilder: ${snapshot.error}',
            );
            return Center(
              child: Text(
                'Fehler beim Laden der Seminardaten: ${snapshot.error}',
              ),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            final List<dynamic> seminare = snapshot.data!;

            if (seminare.isEmpty) {
              return const Center(
                child: Text('Keine absolvierten Seminare gefunden.'),
              );
            }

            return ListView.builder(
              itemCount: seminare.length,
              itemBuilder: (context, index) {
                final seminar = seminare[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: UIConstants.spacingM,
                    vertical: UIConstants.spacingS,
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.task_alt,
                      color: UIConstants.defaultAppColor,
                    ),
                    title: Text(
                      seminar['BEZEICHNUNG'] ?? 'Unbekanntes Seminar',
                      style: UIConstants.subtitleStyle,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ausgestellt am: ${seminar['AUSGESTELLTAM'] ?? 'Unbekannt'}',
                          style: UIConstants.bodyStyle,
                        ),
                        Text(
                          'Gültig bis: ${seminar['GUELTIGBIS'] ?? 'Unbekannt'}',
                          style: UIConstants.bodyStyle,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text('Keine Seminardaten verfügbar.'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'personalDataResultFab',
        onPressed: () {
          Navigator.of(context).pushReplacementNamed(
            '/home',
            arguments: {'isLoggedIn': true},
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
