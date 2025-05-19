import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/screens/app_menu.dart';
import '/screens/connectivity_icon.dart';
import '/screens/logo_widget.dart';
import '/services/api_service.dart';
import '/services/logger_service.dart';

class StartScreen extends StatefulWidget {
  const StartScreen(
    this.userData, {
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });
  final Map<String, dynamic> userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  StartScreenState createState() => StartScreenState();
}

class StartScreenState extends State<StartScreen> {
  List<dynamic> schulungen = [];
  bool isLoading = true;
  final Color _appColor = UIConstants.defaultAppColor;
  // Declare a new variable to hold the simplified user data.
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    // Assign the nested data to _userData in initState.
    _userData = widget.userData['data'] ?? {}; // Use a null check here.
    fetchSchulungen();
    LoggerService.logInfo(
      'StartScreen initialized with user: ${widget.userData}',
    );
  }

  Future<void> fetchSchulungen() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    // Use the simplified _userData here.
    final personId = _userData['PERSONID'];

    if (personId == null) {
      LoggerService.logError('PERSONID is null');
      if (mounted) setState(() => isLoading = false);
      return;
    }

    final today = DateTime.now();
    final abDatum =
        "${today.day.toString().padLeft(2, '0')}.${today.month.toString().padLeft(2, '0')}.${today.year}";

    try {
      LoggerService.logInfo('Fetching schulungen for $personId on $abDatum');
      final result = await apiService.fetchAngemeldeteSchulungen(
        personId,
        abDatum,
      );

      if (mounted) {
        setState(() {
          schulungen = result;
          isLoading = false;
        });
      }
    } catch (e) {
      LoggerService.logError('Error fetching schulungen: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          schulungen = []; // Ensure empty state is clear
        });
      }
    }
  }

  void _handleLogout() {
    // Use the simplified _userData here.
    LoggerService.logInfo('Logging out user: ${_userData['VORNAME']}');
    widget.onLogout(); // Update app state
    Navigator.of(context).pushReplacementNamed('/login'); // Force navigation
  }

  Future<void> _handleDeleteSchulung(
    int personId,
    int schulungId,
    int index,
  ) async {
    final apiService =
        Provider.of<ApiService>(context, listen: false); //get api service

    try {
      setState(() {
        isLoading = true; // Show loading indicator
      });
      final success =
          await apiService.unregisterFromSchulung(personId, schulungId);
      if (mounted) {
        // ADDED THIS CHECK
        if (success) {
          LoggerService.logInfo(
            'Successfully unregistered from Schulung $schulungId',
          );
          // Remove the item from the list to update the UI
          setState(() {
            schulungen.removeAt(index); // Remove at index
          });

          // Optionally, show a success message to the user
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Schulung abgemeldet.'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          LoggerService.logWarning(
            'Failed to unregister from Schulung $schulungId',
          );
          // Optionally, show an error message to the user
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fehler beim Abmelden von der Schulung.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (error) {
      LoggerService.logError('Error unregistering from Schulung: $error');
      if (mounted) {
        // ADDED THIS CHECK
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        // ADDED THIS CHECK
        setState(() {
          isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Ändere die Hintergrundfarbe des Scaffolds.
      backgroundColor:
          UIConstants.backgroundGreen, // Setze die Hintergrundfarbe
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Startseite',
          style: UIConstants.titleStyle,
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: ConnectivityIcon(), // Add the ConnectivityIcon here
          ),
          AppMenu(
            context: context,
            userData: widget.userData,
            isLoggedIn: widget.isLoggedIn,
            onLogout: _handleLogout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(UIConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LogoWidget(),
            const SizedBox(height: UIConstants.defaultSpacing),
            Text(
              'Mein BSSB',
              style: UIConstants.headerStyle.copyWith(color: _appColor),
            ),
            const SizedBox(height: UIConstants.defaultSpacing),
            // Use the simplified _userData here.
            Text(
              "${_userData['VORNAME'] ?? ''} ${_userData['NAMEN'] ?? ''}",
              style: UIConstants.titleStyle,
            ),
            const SizedBox(height: UIConstants.smallSpacing),
            // Use the simplified _userData here.
            Text(
              '${_userData['PASSNUMMER'] ?? ''}',
              style: UIConstants.bodyStyle.copyWith(
                fontSize: UIConstants.subtitleFontSize,
              ),
            ),
            Text(
              'Schützenpassnummer',
              style: UIConstants.bodyStyle.copyWith(color: UIConstants.grey),
            ),
            const SizedBox(height: UIConstants.smallSpacing),
            // Use the simplified _userData here.
            Text(
              '${_userData['VEREINNAME'] ?? ''}',
              style: UIConstants.bodyStyle.copyWith(
                fontSize: UIConstants.subtitleFontSize,
              ),
            ),
            Text(
              'Erstverein',
              style: UIConstants.bodyStyle.copyWith(color: UIConstants.grey),
            ),
            const SizedBox(height: UIConstants.defaultSpacing),
            const Text(
              'Angemeldete Schulungen:',
              style: UIConstants.titleStyle,
            ),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: UIConstants.defaultAppColor,
                      strokeWidth: 2.0,
                    ),
                  )
                : schulungen.isEmpty
                    ? Text(
                        'Keine Schulungen gefunden.',
                        style: UIConstants.bodyStyle.copyWith(
                          color: UIConstants.grey,
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: schulungen.length,
                          itemBuilder: (context, index) {
                            final schulung = schulungen[index];
                            final datum = DateTime.parse(schulung['DATUM']);
                            final online = schulung['ONLINE'] as bool? ?? false;
                            // Use the simplified _userData here.
                            final personId =
                                _userData['PERSONID']; // Get Person ID

                            final formattedDatum =
                                "${datum.day.toString().padLeft(2, '0')}.${datum.month.toString().padLeft(2, '0')}.${datum.year}";
                            return Card(
                              margin: const EdgeInsets.only(
                                bottom: UIConstants.smallSpacing,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: UIConstants.smallSpacing,
                                  horizontal: UIConstants.smallSpacing,
                                ),
                                child: Row(
                                  children: [
                                    // Date
                                    SizedBox(
                                      width: 90,
                                      child: Text(
                                        formattedDatum,
                                        style: UIConstants.bodyStyle.copyWith(
                                          fontSize:
                                              UIConstants.subtitleFontSize,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: UIConstants.smallSpacing,
                                    ),
                                    // Schulung name
                                    Expanded(
                                      child: Text(
                                        schulung['BEZEICHNUNG'] ?? 'N/A',
                                        style: UIConstants.bodyStyle.copyWith(
                                          fontSize:
                                              UIConstants.subtitleFontSize,
                                        ),
                                      ),
                                    ),
                                    // Delete Icon
                                    if (online)
                                      IconButton(
                                        // Changed to IconButton
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () {
                                          // Call the delete handler
                                          if (personId != null &&
                                              schulung[
                                                      'SCHULUNGENTEILNEHMERID'] !=
                                                  null) {
                                            _handleDeleteSchulung(
                                              personId,
                                              schulung[
                                                  'SCHULUNGENTEILNEHMERID'],
                                              index, // Pass the index
                                            );
                                          } else {
                                            LoggerService.logError(
                                              "personId or schulungId is null. personId: $personId, schulungId: ${schulung['SCHULUNGENTEILNEHMERID']}",
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Ein unerwarteter Fehler ist aufgetreten.',
                                                ),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
