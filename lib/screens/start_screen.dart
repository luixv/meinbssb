import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/screens/logo_widget.dart';
import '/services/api_service.dart';
import '/services/core/logger_service.dart';
import '/screens/base_screen_layout.dart';
import 'personal_pict_upload_screen.dart';

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
  Uint8List? _profilePictureBytes; // State variable for profile picture bytes

  @override
  void initState() {
    super.initState();
    _fetchSchulungen();
    _fetchProfilePicture(); // Fetch profile picture on init

    LoggerService.logInfo(
      'StartScreen initialized with user: ${widget.userData}',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch profile picture every time the screen is loaded/refreshed
    _fetchProfilePicture();
  }

  Future<void> _fetchProfilePicture() async {
    if (widget.userData?.personId == null) {
      return;
    }
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      // Call the updated fetchProfilPicture method that returns Uint8List
      String personId = widget.userData!.personId.toString();
      LoggerService.logInfo('Fetching profile picture for personId: $personId');
      final bytes = await apiService.getProfilePhoto(personId);

      if (mounted) {
        setState(() {
          _profilePictureBytes = bytes;
        });
        LoggerService.logInfo(
          'Profile picture updated: ${bytes != null ? '${bytes.length} bytes' : 'null'}',
        );
      }
    } catch (e) {
      LoggerService.logError('Error fetching profile picture: $e');
      if (mounted) {
        setState(() {
          _profilePictureBytes = null; // Ensure it's null on error
        });
      }
    }
  }

  Future<void> _fetchSchulungen() async {
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
                          UIConstants.horizontalSpacingM,
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

          // Send unregistration email notification
          if (widget.userData != null) {
            final formattedDate =
                '${schulungen[index].datum.day.toString().padLeft(2, '0')}.${schulungen[index].datum.month.toString().padLeft(2, '0')}.${schulungen[index].datum.year}';

            await apiService.sendSchulungAbmeldungEmail(
              personId: widget.userData!.personId.toString(),
              schulungName: schulungDescription,
              schulungDate: formattedDate,
              firstName: widget.userData!.vorname,
              lastName: widget.userData!.namen,
            );
          }

          await _fetchSchulungen();
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const LogoWidget(),
                // Display profile picture or default icon

                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: _profilePictureBytes != null &&
                          _profilePictureBytes!.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PersonalPictUploadScreen(
                                  userData: userData,
                                  isLoggedIn: widget.isLoggedIn,
                                  onLogout: widget.onLogout,
                                ),
                              ),
                            );
                          },
                          child: ClipOval(
                            child: Image.memory(
                              _profilePictureBytes!,
                              width: UIConstants.profilePictureSize,
                              height: UIConstants.profilePictureSize,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                LoggerService.logError(
                                  'Error displaying profile picture: $error',
                                );
                                return const Icon(
                                  Icons.person,
                                  size: UIConstants.profilePictureSize,
                                  color: UIConstants.defaultAppColor,
                                );
                              },
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PersonalPictUploadScreen(
                                  userData: userData,
                                  isLoggedIn: widget.isLoggedIn,
                                  onLogout: widget.onLogout,
                                ),
                              ),
                            );
                          },
                          child: const Icon(
                            Icons.person,
                            size: UIConstants.profilePictureSize,
                            color: UIConstants.defaultAppColor,
                          ),
                        ),
                ),
              ],
            ),
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
                                                  width: double
                                                      .infinity, // Retain original width behavior
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 28,
                                                    horizontal: 0,
                                                  ), // Original padding for the white container itself
                                                  decoration: BoxDecoration(
                                                    color: UIConstants
                                                        .whiteColor, // White background as per original
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      UIConstants.cornerRadius,
                                                    ), // Rounded corners
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: UIConstants
                                                              .spacingL, // Original horizontal padding for the title
                                                        ),
                                                        child: Text(
                                                          termin.bezeichnung
                                                                  .isNotEmpty
                                                              ? termin
                                                                  .bezeichnung
                                                              : schulung
                                                                  .bezeichnung,
                                                          style: UIStyles
                                                              .dialogTitleStyle,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: UIConstants
                                                            .spacingM,
                                                      ), // Small space below the title
                                                      Text(
                                                        'Es sind noch ${termin.maxTeilnehmer - termin.angemeldeteTeilnehmer} von ${termin.maxTeilnehmer} Plätzen frei',
                                                        style: UIStyles
                                                            .bodyStyle
                                                            .copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      const SizedBox(
                                                        height: UIConstants
                                                            .spacingM,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal:
                                                              32, // Tighter, equal left/right padding for the table
                                                          vertical: UIConstants
                                                              .spacingS,
                                                        ),
                                                        child: Table(
                                                          columnWidths: const {
                                                            0: IntrinsicColumnWidth(),
                                                            1: FixedColumnWidth(
                                                              UIConstants
                                                                  .dialogColumnGap,
                                                            ),
                                                            2: IntrinsicColumnWidth(),
                                                          },
                                                          children: [
                                                            TableRow(
                                                              children: [
                                                                // First column: Date and Place
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        const Icon(
                                                                          Icons
                                                                              .calendar_today,
                                                                          size:
                                                                              UIConstants.defaultIconSize,
                                                                        ),
                                                                        UIConstants
                                                                            .horizontalSpacingS,
                                                                        Text(
                                                                          DateFormat('dd. MM. yyyy')
                                                                              .format(termin.datum),
                                                                          style:
                                                                              UIStyles.bodyStyle,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height: UIConstants
                                                                          .spacingXS,
                                                                    ),
                                                                    Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        const Icon(
                                                                          Icons
                                                                              .location_on,
                                                                          size:
                                                                              UIConstants.defaultIconSize,
                                                                        ),
                                                                        UIConstants
                                                                            .horizontalSpacingS,
                                                                        Text(
                                                                          termin
                                                                              .ort,
                                                                          style:
                                                                              UIStyles.bodyStyle,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          maxLines:
                                                                              1,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(),
                                                                // Second column: Group and Price
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        const Icon(
                                                                          Icons
                                                                              .group,
                                                                          size:
                                                                              UIConstants.defaultIconSize,
                                                                        ),
                                                                        UIConstants
                                                                            .horizontalSpacingS,
                                                                        Text(
                                                                          termin
                                                                              .webGruppeLabel,
                                                                          style:
                                                                              UIStyles.bodyStyle,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          maxLines:
                                                                              1,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height: UIConstants
                                                                          .spacingXS,
                                                                    ),
                                                                    Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        const Icon(
                                                                          Icons
                                                                              .request_quote,
                                                                          size:
                                                                              UIConstants.defaultIconSize,
                                                                        ),
                                                                        UIConstants
                                                                            .horizontalSpacingS,
                                                                        Text(
                                                                          '${termin.kosten.toStringAsFixed(2)} €',
                                                                          style:
                                                                              UIStyles.bodyStyle,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: UIConstants
                                                            .spacingS,
                                                      ), // Small space between table and the next section
                                                      // "Lehrgangsleiter" section (originally the right column, now moved below the table)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: UIConstants
                                                              .spacingL, // Padding to align with the main title
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Lehrgangsleiter:',
                                                              style: UIStyles
                                                                  .bodyStyle
                                                                  .copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: UIConstants
                                                                  .spacingXS,
                                                            ),
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                const Icon(
                                                                  Icons.email,
                                                                  size: UIConstants
                                                                      .defaultIconSize,
                                                                ),
                                                                UIConstants
                                                                    .horizontalSpacingS,
                                                                Text(
                                                                  termin
                                                                      .lehrgangsleiterMail,
                                                                  style: UIStyles
                                                                      .bodyStyle,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines: 1,
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: UIConstants
                                                                  .spacingXXS,
                                                            ),
                                                            Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                const Icon(
                                                                  Icons.phone,
                                                                  size: UIConstants
                                                                      .defaultIconSize,
                                                                ),
                                                                UIConstants
                                                                    .horizontalSpacingS,
                                                                Text(
                                                                  termin
                                                                      .lehrgangsleiterTel,
                                                                  style: UIStyles
                                                                      .bodyStyle,
                                                                ),
                                                              ],
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
                                        bottom: UIConstants.dialogFabBottom +
                                            UIConstants.dialogFabDeleteOffset,
                                        right: UIConstants.dialogFabRight,
                                        child: FloatingActionButton(
                                          heroTag: 'descDialogDeleteFab$index',
                                          mini: true,
                                          tooltip: 'Löschen',
                                          backgroundColor:
                                              UIConstants.defaultAppColor,
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _handleDeleteSchulung(
                                              schulung.schulungsTeilnehmerId,
                                              index,
                                              schulung.bezeichnung,
                                            );
                                          },
                                          child: const Icon(
                                            Icons.delete_outline_outlined,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: UIConstants.dialogFabBottom,
                                        right: UIConstants.dialogFabRight,
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
                              if (schulung.schulungsTeilnehmerId > 0) {
                                _handleDeleteSchulung(
                                  schulung.schulungsTeilnehmerId,
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
