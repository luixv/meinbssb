import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/screens/logo_widget.dart';
import '/services/api_service.dart';
import '/services/core/logger_service.dart';
import '/screens/base_screen_layout.dart';
import '/models/schulungstermin.dart';
import '/models/user_data.dart';
import '/widgets/scaled_text.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';

class StartScreen extends StatefulWidget {
  const StartScreen(
    this.userData, {
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });
  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  StartScreenState createState() => StartScreenState();
}

class StartScreenState extends State<StartScreen> {
  List<Schulungstermin> schulungen = [];
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
    final personId = widget.userData?.personId;

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
    LoggerService.logInfo('Logging out user: ${widget.userData?.vorname}');
    widget.onLogout();
    // Navigation is handled by the app's logout handler
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
          backgroundColor: UIConstants.backgroundColor,
          title: const Center(
            child: ScaledText(
              'Schulung abmelden',
              style: UIStyles.dialogTitleStyle,
            ),
          ),
          content: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: UIStyles.dialogContentStyle,
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
              padding: UIConstants.dialogPadding,
              child: Row(
                mainAxisAlignment: UIConstants.spaceBetweenAlignment,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false);
                      },
                      style: UIStyles.dialogCancelButtonStyle,
                      child: Row(
                        mainAxisAlignment: UIConstants.centerAlignment,
                        children: [
                          const Icon(Icons.close, color: UIConstants.closeIcon),
                          UIConstants.horizontalSpacingS,
                          Flexible(
                            child: ScaledText(
                              'Abbrechen',
                              style: UIStyles.dialogButtonTextStyle.copyWith(
                                color: UIConstants.cancelButtonText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  UIConstants.horizontalSpacingM,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(true);
                      },
                      style: UIStyles.dialogAcceptButtonStyle,
                      child: Row(
                        mainAxisAlignment: UIConstants.centerAlignment,
                        children: [
                          const Icon(Icons.check, color: UIConstants.checkIcon),
                          UIConstants.horizontalSpacingS,
                          Flexible(
                            child: ScaledText(
                              'Löschen',
                              style: UIStyles.dialogButtonTextStyle.copyWith(
                                color: UIConstants.deleteButtonText,
                              ),
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

    if (!mounted) return;

    if (confirmDelete != true) return;

    try {
      setState(() => isLoading = true);
      final success =
          await apiService.unregisterFromSchulung(schulungenTeilnehmerID);
      if (mounted) {
        if (success) {
          LoggerService.logInfo(
            'Unregistered from Schulung $schulungenTeilnehmerID',
          );
          await fetchSchulungen();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: ScaledText('Fehler beim Abmelden von der Schulung.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      LoggerService.logError('Unregister error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: ScaledText('Error: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = widget.userData;

    return BaseScreenLayout(
      title: 'Home',
      userData: userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: _handleLogout,
      body: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        child: Column(
          crossAxisAlignment: UIConstants.startCrossAlignment,
          children: [
            const LogoWidget(),
            const SizedBox(height: UIConstants.spacingM),
            ScaledText(
              "${userData?.vorname ?? ''} ${userData?.namen ?? ''}",
              style: UIStyles.titleStyle,
            ),
            const SizedBox(height: UIConstants.spacingS),
            ScaledText(
              userData?.passnummer ?? '',
              style: UIStyles.bodyStyle
                  .copyWith(fontSize: UIConstants.subtitleFontSize),
            ),
            ScaledText(
              'Schützenpassnummer',
              style: UIStyles.bodyStyle
                  .copyWith(color: UIConstants.greySubtitleTextColor),
            ),
            const SizedBox(height: UIConstants.spacingS),
            ScaledText(
              userData?.vereinName ?? '',
              style: UIStyles.bodyStyle
                  .copyWith(fontSize: UIConstants.subtitleFontSize),
            ),
            ScaledText(
              'Erstverein',
              style: UIStyles.bodyStyle
                  .copyWith(color: UIConstants.greySubtitleTextColor),
            ),
            const SizedBox(height: UIConstants.spacingM),
            Container(
              height: UIConstants.newsContainerHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: UIConstants.news,
                borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
              ),
              child: const Center(
                child: ScaledText(
                  'Hier könnten News stehen',
                  style: UIStyles.newsStyle,
                ),
              ),
            ),
            const SizedBox(height: UIConstants.spacingM),
            const ScaledText(
              'Angemeldete Schulungen:',
              style: UIStyles.titleStyle,
            ),
            const SizedBox(height: UIConstants.spacingS),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (schulungen.isEmpty)
              const ScaledText(
                'Keine Schulungen gefunden.',
                style: TextStyle(color: UIConstants.greySubtitleTextColor),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: schulungen.length,
                  separatorBuilder: (_, __) => const SizedBox(
                    height: UIConstants.defaultSeparatorHeight,
                  ),
                  itemBuilder: (context, index) {
                    final schulung = schulungen[index];
                    final date = schulung.datum;
                    final formattedDate =
                        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

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
                      title: ScaledText(
                        schulung.bezeichnung,
                        style: UIStyles.listItemTitleStyle,
                      ),
                      subtitle: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: UIConstants.defaultIconSize,
                            color: UIConstants.textColor,
                          ),
                          UIConstants.horizontalSpacingXS,
                          Text(
                            formattedDate,
                            style: UIStyles.listItemSubtitleStyle,
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.description,
                              color: UIConstants.defaultAppColor,
                            ),
                            onPressed: () async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                              final apiService = Provider.of<ApiService>(
                                context,
                                listen: false,
                              );
                              final termin =
                                  await apiService.fetchSchulungstermin(
                                schulung.schulungsterminId.toString(),
                              );
                              if (!context.mounted) return;
                              Navigator.of(context, rootNavigator: true)
                                  .pop(); // Remove spinner
                              if (termin == null) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Fehler'),
                                    content: const Text(
                                      'Details konnten nicht geladen werden.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Stack(
                                    children: [
                                      AlertDialog(
                                        backgroundColor:
                                            UIConstants.backgroundColor,
                                        contentPadding: EdgeInsets.zero,
                                        content: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxHeight: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.8,
                                            minWidth: 300,
                                          ),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    color:
                                                        UIConstants.whiteColor,
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                        UIConstants
                                                            .cornerRadius,
                                                      ),
                                                      topRight: Radius.circular(
                                                        UIConstants
                                                            .cornerRadius,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          top: UIConstants
                                                              .spacingM,
                                                          left: UIConstants
                                                              .spacingM,
                                                          right: UIConstants
                                                              .spacingM,
                                                        ),
                                                        child: Text(
                                                          schulung.bezeichnung,
                                                          style: UIStyles
                                                              .dialogTitleStyle,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: UIConstants
                                                            .spacingM,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          left: UIConstants
                                                              .spacingM,
                                                          right: UIConstants
                                                              .spacingM,
                                                          bottom: UIConstants
                                                              .spacingM,
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            'Es sind noch ${termin.maxTeilnehmer - termin.angemeldeteTeilnehmer} von ${termin.maxTeilnehmer} Plätzen frei',
                                                            style: UIStyles
                                                                .bodyStyle
                                                                .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          left: UIConstants
                                                              .spacingM,
                                                          right: UIConstants
                                                              .spacingM,
                                                          bottom: UIConstants
                                                              .spacingM,
                                                        ),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Flexible(
                                                              flex: 1,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      const Icon(
                                                                        Icons
                                                                            .calendar_today,
                                                                        size: UIConstants
                                                                            .defaultIconSize,
                                                                      ),
                                                                      UIConstants
                                                                          .horizontalSpacingS,
                                                                      Text(
                                                                        DateFormat('dd.MM.yyyy')
                                                                            .format(termin.datum),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: UIConstants
                                                                        .spacingXS,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      const Icon(
                                                                        Icons
                                                                            .location_on,
                                                                        size: UIConstants
                                                                            .defaultIconSize,
                                                                      ),
                                                                      UIConstants
                                                                          .horizontalSpacingS,
                                                                      Flexible(
                                                                        child:
                                                                            Text(
                                                                          termin
                                                                              .ort,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: UIConstants
                                                                        .spacingXS,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      const Icon(
                                                                        Icons
                                                                            .request_quote,
                                                                        size: UIConstants
                                                                            .defaultIconSize,
                                                                      ),
                                                                      UIConstants
                                                                          .horizontalSpacingS,
                                                                      Text(
                                                                        '${termin.kosten.toStringAsFixed(2)} €',
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: UIConstants
                                                                        .spacingXS,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      const Icon(
                                                                        Icons
                                                                            .group,
                                                                        size: UIConstants
                                                                            .defaultIconSize,
                                                                      ),
                                                                      UIConstants
                                                                          .horizontalSpacingS,
                                                                      Text(
                                                                        termin
                                                                            .webGruppeLabel,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: UIConstants
                                                                      .infoTableColumnSpacing *
                                                                  2,
                                                            ),
                                                            Flexible(
                                                              flex: 2,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      const Text(
                                                                        'Lehrgangsleiter: ',
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      Flexible(
                                                                        child:
                                                                            Text(
                                                                          termin
                                                                              .lehrgangsleiter,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: UIConstants
                                                                        .spacingXS,
                                                                  ),
                                                                  if (termin
                                                                      .lehrgangsleiterTel
                                                                      .isNotEmpty) ...[
                                                                    Row(
                                                                      children: [
                                                                        const Icon(
                                                                          Icons
                                                                              .phone,
                                                                          size:
                                                                              UIConstants.defaultIconSize,
                                                                        ),
                                                                        UIConstants
                                                                            .horizontalSpacingS,
                                                                        Flexible(
                                                                          child:
                                                                              Text(termin.lehrgangsleiterTel),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height: UIConstants
                                                                          .spacingXS,
                                                                    ),
                                                                  ],
                                                                  if (termin
                                                                      .lehrgangsleiterMail
                                                                      .isNotEmpty) ...[
                                                                    Row(
                                                                      children: [
                                                                        const Icon(
                                                                          Icons
                                                                              .email,
                                                                          size:
                                                                              UIConstants.defaultIconSize,
                                                                        ),
                                                                        UIConstants
                                                                            .horizontalSpacingS,
                                                                        Flexible(
                                                                          child:
                                                                              Text(termin.lehrgangsleiterMail),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height: UIConstants
                                                                          .spacingXS,
                                                                    ),
                                                                  ],
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Divider(
                                                  height: UIConstants
                                                      .defaultStrokeWidth,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    UIConstants.spacingM,
                                                  ),
                                                  child: termin
                                                          .lehrgangsinhaltHtml
                                                          .isNotEmpty
                                                      ? Html(
                                                          data: termin
                                                              .lehrgangsinhaltHtml,
                                                        )
                                                      : termin.lehrgangsinhalt
                                                              .isNotEmpty
                                                          ? Text(
                                                              termin
                                                                  .lehrgangsinhalt,
                                                            )
                                                          : termin.bemerkung
                                                                  .isNotEmpty
                                                              ? Text(
                                                                  termin
                                                                      .bemerkung,
                                                                )
                                                              : const Text(
                                                                  'Keine Beschreibung verfügbar.',
                                                                ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: UIConstants.spacingM,
                                        right: UIConstants.spacingM,
                                        child: FloatingActionButton(
                                          heroTag: 'descDialogCloseFab$index',
                                          mini: true,
                                          tooltip: 'Schließen',
                                          backgroundColor:
                                              UIConstants.defaultAppColor,
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_outlined,
                              color: UIConstants.deleteIcon,
                            ),
                            onPressed: () {
                              if (schulung.schulungsterminId > 0) {
                                _handleDeleteSchulung(
                                  schulung.schulungsterminId,
                                  index,
                                  schulung.bezeichnung,
                                );
                              }
                            },
                          ),
                        ],
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
