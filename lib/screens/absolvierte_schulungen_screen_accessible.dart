import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/services/api_service.dart';
import '/services/core/logger_service.dart';
import '/services/core/network_service.dart';
import '/screens/base_screen_layout_accessible.dart';
import '../models/schulung_data.dart';
import '/models/user_data.dart';
import '/widgets/scaled_text.dart';

class AbsolvierteSchulungenScreenAccessible extends StatefulWidget {
  const AbsolvierteSchulungenScreenAccessible(
    this.userData, {
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });
  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  AbsolvierteSchulungenScreenAccessibleState createState() =>
      AbsolvierteSchulungenScreenAccessibleState();
}

class AbsolvierteSchulungenScreenAccessibleState
    extends State<AbsolvierteSchulungenScreenAccessible> {
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
      final networkService =
          Provider.of<NetworkService>(context, listen: false);
      return !(await networkService.hasInternet());
    } catch (e) {
      LoggerService.logError('Error checking network status: $e');
      return true; // Assume offline if we can't check
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Absolvierte Schulungen Bildschirm',
      hint: 'Zeigt eine Liste aller erfolgreich abgeschlossenen Schulungen an',
      child: BaseScreenLayoutAccessible(
        title: 'Absolvierte Schulungen',
        userData: widget.userData,
        isLoggedIn: widget.isLoggedIn,
        onLogout: _handleLogout,
        body: FutureBuilder<bool>(
          future: _isOffline(),
          builder: (context, offlineSnapshot) {
            if (offlineSnapshot.connectionState == ConnectionState.waiting) {
              return Semantics(
                container: true,
                liveRegion: true,
                label: 'Netzwerkverbindung wird überprüft',
                child: const Center(
                  child: CircularProgressIndicator(
                    semanticsLabel: 'Überprüfung der Internetverbindung',
                  ),
                ),
              );
            }

            if (offlineSnapshot.hasData && offlineSnapshot.data == true) {
              return Semantics(
                container: true,
                label: 'Offline Modus aktiv',
                hint:
                    'Absolvierte Schulungen sind ohne Internetverbindung nicht verfügbar',
                child: Center(
                  child: Padding(
                    padding: UIConstants.screenPadding,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Semantics(
                          image: true,
                          label: 'Keine Internetverbindung Symbol',
                          child: const Icon(
                            Icons.wifi_off,
                            size: UIConstants.wifiOffIconSize,
                            color: UIConstants.noConnectivityIcon,
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingM),
                        Semantics(
                          header: true,
                          label:
                              'Offline Hinweis: Absolvierte Schulungen sind offline nicht verfügbar',
                          child: ScaledText(
                            'Absolvierte Schulungen sind offline nicht verfügbar',
                            style: UIStyles.headerStyle.copyWith(
                              color: UIConstants.textColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingS),
                        Semantics(
                          container: true,
                          label: 'Detaillierte Offline Erklärung',
                          child: ScaledText(
                            'Bitte stellen Sie sicher, dass Sie mit dem Internet verbunden sind, um Ihre absolvierten Schulungen anzuzeigen.',
                            style: UIStyles.bodyStyle.copyWith(
                              color: UIConstants.greySubtitleTextColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Semantics(
              container: true,
              label: 'Absolvierte Schulungen Inhalt',
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.spacingM),
                child: Column(
                  crossAxisAlignment: UIConstants.startCrossAlignment,
                  children: [
                    if (isLoading)
                      Semantics(
                        container: true,
                        liveRegion: true,
                        label: 'Absolvierte Schulungen werden geladen',
                        child: const Center(
                          child: CircularProgressIndicator(
                            semanticsLabel: 'Laden der absolvierten Schulungen',
                          ),
                        ),
                      )
                    else if (absolvierteSchulungen.isEmpty)
                      Semantics(
                        container: true,
                        label: 'Keine absolvierten Schulungen vorhanden',
                        hint:
                            'Es wurden noch keine Schulungen erfolgreich abgeschlossen',
                        child: const ScaledText(
                          'Keine absolvierten Schulungen gefunden.',
                          style: TextStyle(
                            color: UIConstants.greySubtitleTextColor,
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: Semantics(
                          container: true,
                          label:
                              'Liste der absolvierten Schulungen mit ${absolvierteSchulungen.length} Einträgen',
                          hint:
                              'Navigieren Sie durch die Liste um Details zu jeder abgeschlossenen Schulung zu erfahren',
                          child: ListView.separated(
                            itemCount: absolvierteSchulungen.length,
                            separatorBuilder: (_, __) => const SizedBox(
                              height: UIConstants.defaultSeparatorHeight,
                            ),
                            itemBuilder: (context, index) {
                              final seminar = absolvierteSchulungen[index];
                              final ausgestelltAm =
                                  DateTime.tryParse(seminar.ausgestelltAm);
                              final formattedAusgestelltAm = ausgestelltAm ==
                                          null ||
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

                              // Check if certificate is still valid
                              final now = DateTime.now();
                              final isExpired = gueltigBis != null &&
                                  gueltigBis.isBefore(now);
                              final isExpiringSoon = gueltigBis != null &&
                                  gueltigBis.isAfter(now) &&
                                  gueltigBis.difference(now).inDays <= 30;

                              String validityStatus = '';
                              if (isExpired) {
                                validityStatus =
                                    'Abgelaufen seit ${(now.difference(gueltigBis).inDays)} Tagen';
                              } else if (isExpiringSoon) {
                                validityStatus =
                                    'Läuft in ${gueltigBis.difference(now).inDays} Tagen ab';
                              } else if (gueltigBis != null) {
                                validityStatus = 'Gültig';
                              }

                              return Semantics(
                                container: true,
                                label:
                                    'Absolvierte Schulung ${index + 1} von ${absolvierteSchulungen.length}',
                                hint:
                                    '${seminar.bezeichnung}, ausgestellt am $formattedAusgestelltAm, gültig bis $formattedGueltigBis${validityStatus.isNotEmpty ? ', Status: $validityStatus' : ''}',
                                child: ListTile(
                                  tileColor: isExpired
                                      ? UIConstants.errorColor.withOpacity(0.1)
                                      : isExpiringSoon
                                          ? Colors.orange.withOpacity(0.1)
                                          : UIConstants.tileColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      UIConstants.cornerRadius,
                                    ),
                                    side: isExpired
                                        ? const BorderSide(
                                            color: UIConstants.errorColor,
                                            width: 1,
                                          )
                                        : isExpiringSoon
                                            ? const BorderSide(
                                                color: Colors.orange,
                                                width: 1,
                                              )
                                            : BorderSide.none,
                                  ),
                                  leading: Semantics(
                                    image: true,
                                    label: isExpired
                                        ? 'Abgelaufene Schulung Symbol'
                                        : isExpiringSoon
                                            ? 'Bald ablaufende Schulung Symbol'
                                            : 'Erfolgreich abgeschlossene Schulung Symbol',
                                    child: Column(
                                      mainAxisAlignment:
                                          UIStyles.listItemLeadingAlignment,
                                      children: [
                                        Icon(
                                          isExpired
                                              ? Icons.warning
                                              : isExpiringSoon
                                                  ? Icons.schedule
                                                  : Icons.task_alt,
                                          color: isExpired
                                              ? UIConstants.errorColor
                                              : isExpiringSoon
                                                  ? Colors.orange
                                                  : UIConstants.defaultAppColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                  title: Semantics(
                                    header: true,
                                    label:
                                        'Schulungsname: ${seminar.bezeichnung}',
                                    child: ScaledText(
                                      seminar.bezeichnung,
                                      style: UIStyles.subtitleStyle.copyWith(
                                        color: isExpired
                                            ? UIConstants.errorColor
                                            : isExpiringSoon
                                                ? Colors.orange.shade800
                                                : UIConstants.textColor,
                                      ),
                                    ),
                                  ),
                                  subtitle: Semantics(
                                    container: true,
                                    label: 'Schulungsdetails',
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Semantics(
                                          label:
                                              'Ausstellungsdatum: $formattedAusgestelltAm',
                                          child: ScaledText(
                                            'Ausgestellt am: $formattedAusgestelltAm',
                                            style:
                                                UIStyles.listItemSubtitleStyle,
                                          ),
                                        ),
                                        Semantics(
                                          label:
                                              'Gültigkeitsdatum: $formattedGueltigBis',
                                          child: ScaledText(
                                            'Gültig bis: $formattedGueltigBis',
                                            style: UIStyles
                                                .listItemSubtitleStyle
                                                .copyWith(
                                              color: isExpired
                                                  ? UIConstants.errorColor
                                                  : isExpiringSoon
                                                      ? Colors.orange.shade700
                                                      : UIConstants
                                                          .greySubtitleTextColor,
                                            ),
                                          ),
                                        ),
                                        if (validityStatus.isNotEmpty)
                                          Semantics(
                                            label:
                                                'Gültigkeitsstatus: $validityStatus',
                                            child: ScaledText(
                                              validityStatus,
                                              style: UIStyles
                                                  .listItemSubtitleStyle
                                                  .copyWith(
                                                color: isExpired
                                                    ? UIConstants.errorColor
                                                    : isExpiringSoon
                                                        ? Colors.orange.shade700
                                                        : UIConstants
                                                            .defaultAppColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: UIConstants.helpSpacing),
                  ],
                ),
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

            return Semantics(
              container: true,
              button: true,
              label: 'Zum Benutzerprofil navigieren',
              hint:
                  'Öffnet die Benutzerprofilseite mit persönlichen Informationen',
              child: FloatingActionButton(
                heroTag: 'absolvierteSchulungenFab',
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(
                    '/profile',
                    arguments: {'isLoggedIn': true},
                  );
                },
                backgroundColor: UIConstants.defaultAppColor,
                tooltip: 'Benutzerprofil öffnen',
                child: Semantics(
                  excludeSemantics: true,
                  child: const Icon(
                    Icons.person,
                    color: UIConstants.whiteColor,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
