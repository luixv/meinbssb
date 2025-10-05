import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/services/api_service.dart';
import '/services/core/logger_service.dart';
import '/screens/base_screen_layout.dart';
import '/models/schulung_data.dart';
import '/models/user_data.dart';
import '/widgets/scaled_text.dart';

class AbsolvierteSchulungenScreen extends StatefulWidget {
  const AbsolvierteSchulungenScreen(
    this.userData, {
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });
  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  AbsolvierteSchulungenScreenState createState() =>
      AbsolvierteSchulungenScreenState();
}

class AbsolvierteSchulungenScreenState
    extends State<AbsolvierteSchulungenScreen> {
  List<Schulung> absolvierteSchulungen = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAbsolvierteSchulungen();
  }

  Future<void> fetchAbsolvierteSchulungen() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final personId = widget.userData?.personId;

    if (personId == null) {
      LoggerService.logError('PERSONID is null');
      if (mounted) setState(() => isLoading = false);
      return;
    }

    try {
      final result = await apiService.fetchAbsolvierteSchulungen(personId);
      if (mounted) {
        setState(() {
          // Sort the results by ausgestelltAm in descending order (oldest first)
          absolvierteSchulungen = result
            ..sort((a, b) {
              // Get dates, handling all possible cases
              DateTime? dateA;
              DateTime? dateB;

              if (a.ausgestelltAm.isNotEmpty && a.ausgestelltAm != '-') {
                dateA = DateTime.tryParse(a.ausgestelltAm);
              }

              if (b.ausgestelltAm.isNotEmpty && b.ausgestelltAm != '-') {
                dateB = DateTime.tryParse(b.ausgestelltAm);
              }

              // If both dates are valid, compare them
              if (dateA != null && dateB != null) {
                return dateB
                    .compareTo(dateA); // Descending order (oldest first)
              }

              // If only one date is valid, prioritize it
              if (dateA != null) return -1; // Valid date comes first
              if (dateB != null) return 1; // Valid date comes first

              // If neither date is valid, maintain original order
              return 0;
            });
          isLoading = false;
        });
      }
    } catch (e) {
      LoggerService.logError('Error fetching absolvierte Schulungen: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          absolvierteSchulungen = [];
        });
      }
    }
  }

  void _handleLogout() {
    LoggerService.logInfo('Logging out user: ${widget.userData?.vorname}');
    widget.onLogout();
    // Navigation is handled by the app's logout handler
  }

  Future<bool> _isOffline() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      return !(await apiService.hasInternet());
    } catch (e) {
      LoggerService.logError('Error checking network status: $e');
      return true; // Assume offline if we can't check
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Absolvierte Schulungen',
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: _handleLogout,
      body: FutureBuilder<bool>(
        future: _isOffline(),
        builder: (context, offlineSnapshot) {
          if (offlineSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (offlineSnapshot.hasData && offlineSnapshot.data == true) {
            return Center(
              child: Padding(
                padding: UIConstants.screenPadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wifi_off,
                      size: UIConstants.wifiOffIconSize,
                      color: UIConstants.noConnectivityIcon,
                    ),
                    const SizedBox(height: UIConstants.spacingM),
                    ScaledText(
                      'Absolvierte Schulungen sind offline nicht verfügbar',
                      style: UIStyles.headerStyle.copyWith(
                        color: UIConstants.textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: UIConstants.spacingS),
                    ScaledText(
                      'Bitte stellen Sie sicher, dass Sie mit dem Internet verbunden sind, um Ihre absolvierten Schulungen anzuzeigen.',
                      style: UIStyles.bodyStyle.copyWith(
                        color: UIConstants.greySubtitleTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(UIConstants.spacingM),
            child: Column(
              crossAxisAlignment: UIConstants.startCrossAlignment,
              children: [
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (absolvierteSchulungen.isEmpty)
                  const ScaledText(
                    'Keine absolvierten Schulungen gefunden.',
                    style: TextStyle(color: UIConstants.greySubtitleTextColor),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: absolvierteSchulungen.length,
                      separatorBuilder: (_, _) => const SizedBox(
                        height: UIConstants.defaultSeparatorHeight,
                      ),
                      itemBuilder: (context, index) {
                        final seminar = absolvierteSchulungen[index];
                        final ausgestelltAm =
                            DateTime.tryParse(seminar.ausgestelltAm);
                        final formattedAusgestelltAm = ausgestelltAm == null ||
                                seminar.ausgestelltAm.isEmpty ||
                                seminar.ausgestelltAm == '-'
                            ? 'Unbekannt'
                            : '${ausgestelltAm.day.toString().padLeft(2, '0')}.${ausgestelltAm.month.toString().padLeft(2, '0')}.${ausgestelltAm.year}';

                        final gueltigBis =
                            DateTime.tryParse(seminar.gueltigBis);
                        final formattedGueltigBis = gueltigBis == null ||
                                seminar.gueltigBis.isEmpty ||
                                seminar.gueltigBis == '-'
                            ? 'Unbekannt'
                            : '${gueltigBis.day.toString().padLeft(2, '0')}.${gueltigBis.month.toString().padLeft(2, '0')}.${gueltigBis.year}';

                        return ListTile(
                          tileColor: UIConstants.tileColor,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(UIConstants.cornerRadius),
                          ),
                          leading: const Column(
                            mainAxisAlignment:
                                UIStyles.listItemLeadingAlignment,
                            children: [
                              Icon(
                                Icons.task_alt,
                                color: UIConstants.defaultAppColor,
                              ),
                            ],
                          ),
                          title: ScaledText(
                            seminar.bezeichnung,
                            style: UIStyles.subtitleStyle,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ScaledText(
                                'Ausgestellt am: $formattedAusgestelltAm',
                                style: UIStyles.listItemSubtitleStyle,
                              ),
                              ScaledText(
                                'Gültig bis: $formattedGueltigBis',
                                style: UIStyles.listItemSubtitleStyle,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: UIConstants.helpSpacing),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FutureBuilder<bool>(
        future: _isOffline(),
        builder: (context, offlineSnapshot) {
          // Hide FAB when offline
          if (offlineSnapshot.hasData && offlineSnapshot.data == true) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton(
            heroTag: 'absolvierteSchulungenFab',
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(
                '/profile',
                arguments: {'isLoggedIn': true},
              );
            },
            backgroundColor: UIConstants.defaultAppColor,
            child: const Icon(
              Icons.person,
              color: UIConstants.whiteColor,
            ),
          );
        },
      ),
    );
  }
}
