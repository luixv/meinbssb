import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/screens/app_menu.dart';
import '/screens/connectivity_icon.dart';
import '/services/api_service.dart';
import '../services/core/logger_service.dart';

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
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: UIConstants.backgroundColor,
        title: const Text(
          'Absolvierte Seminare', // Screen title
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

            return Padding(
              padding: UIConstants.defaultPadding,
              child: ListView.separated(
                itemCount: seminare.length,
                separatorBuilder: (_, __) => const SizedBox(
                  height: UIConstants.defaultSeparatorHeight,
                ),
                itemBuilder: (context, index) {
                  final schulung = seminare[index];
                  return ListTile(
                    tileColor: UIConstants.tileColor,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(UIConstants.cornerRadius),
                    ),
                    leading: const Column(
                      mainAxisAlignment: UIConstants.listItemLeadingAlignment,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          color: UIConstants.defaultAppColor,
                        ),
                      ],
                    ),
                    title: Text(
                      schulung['BEZEICHNUNG'] ?? 'N/A',
                      style: UIConstants.listItemTitleStyle,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ausgestellt am: ${schulung['AUSGESTELLTAM'] ?? 'N/A'}',
                          style: UIConstants.listItemSubtitleStyle,
                        ),
                        Text(
                          'Gültig bis: ${schulung['GUELTIGBIS'] ?? 'N/A'}',
                          style: UIConstants.listItemSubtitleStyle,
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          } else {
            // This case handles when snapshot.data is null (though covered by hasData check)
            return const Center(
              child: Text('Keine absolvierten Seminare verfügbar.'),
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
