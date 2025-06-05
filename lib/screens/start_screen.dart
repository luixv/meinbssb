import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/screens/app_menu.dart';
import '/screens/connectivity_icon.dart';
import '/screens/logo_widget.dart';
import '/services/api_service.dart';
import '../services/core/logger_service.dart';

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
          schulungen = [];
        });
      }
    }
  }

  void _handleLogout() {
    LoggerService.logInfo('Logging out user: ${widget.userData['VORNAME']}');
    widget.onLogout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  Future<void> _handleDeleteSchulung(
    int schulungenTeilnehmerID,
    int index,
    String schulungDescription,
  ) async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: UIConstants.backgroundGreen,
          title: const Center(
            child: Text(
              'Schulung abmelden',
              style: TextStyle(
                color: UIConstants.defaultAppColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: UIConstants.bodyStyle.copyWith(
                fontSize: UIConstants.subtitleFontSize,
                color: UIConstants.black,
              ),
              children: <TextSpan>[
                const TextSpan(text: 'Sind Sie sicher, dass Sie die Schulung '),
                TextSpan(
                  text: schulungDescription,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: ' löschen möchten?'),
              ],
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.defaultPadding,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIConstants.cancelButton,
                        padding: UIConstants.buttonPadding,
                      ),
                      child: Row(
                        // <-- Added Row for icon and text
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.close,
                            color: UIConstants.white,
                            size: UIConstants.bodyFontSize + 4.0,
                          ), // X icon
                          const SizedBox(width: UIConstants.defaultSpacing / 2),
                          Text(
                            'Abbrechen',
                            style: UIConstants.bodyStyle.copyWith(
                              color: UIConstants.white,
                              fontSize: UIConstants
                                  .bodyFontSize, // Consistent font size
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: UIConstants.defaultSpacing,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UIConstants.acceptButton,
                        padding: UIConstants.buttonPadding,
                      ),
                      child: Row(
                        // <-- Added Row for icon and text
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check,
                            color: UIConstants.white,
                            size: UIConstants.bodyFontSize + 4.0,
                          ), // OK icon
                          const SizedBox(width: UIConstants.defaultSpacing / 2),
                          Text(
                            'Löschen',
                            style: UIConstants.bodyStyle.copyWith(
                              color: UIConstants.white,
                              fontSize: UIConstants
                                  .bodyFontSize, // Consistent font size
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (confirmDelete == null || !confirmDelete) {
      LoggerService.logInfo('Schulung deletion cancelled by user.');
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });
      final success =
          await apiService.unregisterFromSchulung(schulungenTeilnehmerID);
      if (mounted) {
        if (success) {
          LoggerService.logInfo(
            'Successfully unregistered from Schulung $schulungenTeilnehmerID',
          );
          setState(() {
            schulungen.removeAt(index);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Schulung abgemeldet.'),
              duration: UIConstants.snackBarDuration,
            ),
          );
        } else {
          LoggerService.logWarning(
            'Failed to unregister from Schulung $schulungenTeilnehmerID',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fehler beim Abmelden von der Schulung.'),
              duration: UIConstants.snackBarDuration,
            ),
          );
        }
      }
    } catch (error) {
      LoggerService.logError('Error unregistering from Schulung: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            duration: UIConstants.snackBarDuration,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundGreen,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: UIConstants.backgroundGreen,
        title: const Text(
          'Startseite',
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
      body: Padding(
        padding: const EdgeInsets.all(UIConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LogoWidget(),
            const SizedBox(height: UIConstants.defaultSpacing),
            Container(
              height: 100, // You can adjust the height as needed
              width: double.infinity, // Makes the container take full width
              decoration: BoxDecoration(
                color: UIConstants.news, // Example background color
                borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
              ),
              child: Center(
                child: Text(
                  'Hier könnten News stehen',
                  style: UIConstants.titleStyle.copyWith(
                    color: UIConstants.white, // Adjust text color as needed
                  ),
                ),
              ),
            ),
            const SizedBox(height: UIConstants.defaultSpacing),
            Text(
              "${widget.userData['VORNAME'] ?? ''} ${widget.userData['NAMEN'] ?? ''}",
              style: UIConstants.titleStyle,
            ),
            const SizedBox(height: UIConstants.smallSpacing),
            Text(
              '${widget.userData['PASSNUMMER'] ?? ''}',
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
              '${widget.userData['VEREINNAME'] ?? ''}',
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
                            final personId = widget.userData['PERSONID'];

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
                                    Expanded(
                                      child: Text(
                                        schulung['BEZEICHNUNG'] ?? 'N/A',
                                        style: UIConstants.bodyStyle.copyWith(
                                          fontSize:
                                              UIConstants.subtitleFontSize,
                                        ),
                                      ),
                                    ),
                                    if (online)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: UIConstants.defaultAppColor,
                                        ),
                                        onPressed: () {
                                          if (personId != null &&
                                              schulung[
                                                      'SCHULUNGENTEILNEHMERID'] !=
                                                  null) {
                                            _handleDeleteSchulung(
                                              schulung[
                                                  'SCHULUNGENTEILNEHMERID'],
                                              index,
                                              schulung['BEZEICHNUNG'],
                                            );
                                          } else {
                                            LoggerService.logError(
                                              "personId or schulungId is null. personId: $personId, schulungenTeilnehmerID: ${schulung['SCHULUNGENTEILNEHMERID']}",
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Ein unerwarteter Fehler ist aufgetreten.',
                                                ),
                                                duration: UIConstants
                                                    .snackBarDuration,
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
