// Project: Mein BSSB
// Filename: start_screen.dart
// Author: Luis Mandel / NTT DATA

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

  @override
  void initState() {
    super.initState();
    fetchSchulungen();
    LoggerService.logInfo(
      'StartScreen initialized with user: ${widget.userData}',
    );
  }

  Future<void> fetchSchulungen() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final personId = widget.userData['PERSONID'];

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
    LoggerService.logInfo('Logging out user: ${widget.userData['VORNAME']}');
    widget.onLogout(); // Update app state
    Navigator.of(context).pushReplacementNamed('/login'); // Force navigation
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
            Text(
              "${widget.userData['VORNAME']} ${widget.userData['NAMEN']}",
              style: UIConstants.titleStyle,
            ),
            const SizedBox(height: UIConstants.smallSpacing),
            Text(
              widget.userData['PASSNUMMER'],
              style: UIConstants.bodyStyle.copyWith(
                fontSize: UIConstants.subtitleFontSize,
              ),
            ),
            Text(
              'Schützenpassnummer',
              style: UIConstants.bodyStyle.copyWith(color: UIConstants.grey),
            ),
            const SizedBox(height: UIConstants.smallSpacing),
            Text(
              widget.userData['VEREINNAME'],
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
                                      width: 90, // Fixed width for date
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
                                    ), // Small spacing
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
                                    // Delete Icon (conditionally shown)
                                    if (online)
                                      const SizedBox(
                                          width: UIConstants.smallSpacing,),
                                    if (online)
                                      const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
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
