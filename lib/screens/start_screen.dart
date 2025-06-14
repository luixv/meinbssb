import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/screens/logo_widget.dart';
import '/services/api_service.dart';
import '/services/core/logger_service.dart';
import '/screens/base_screen_layout.dart';
import '/models/schulung.dart';
import '/models/user_data.dart';
import '/widgets/scaled_text.dart';

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
  List<Schulung> schulungen = [];
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
                          ScaledText(
                            'Abbrechen',
                            style: UIStyles.dialogButtonTextStyle.copyWith(
                              color: UIConstants.cancelButtonText,
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
                          ScaledText(
                            'Löschen',
                            style: UIStyles.dialogButtonTextStyle.copyWith(
                              color: UIConstants.deleteButtonText,
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
          setState(() => schulungen.removeAt(index));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ScaledText('Fehler beim Abmelden von der Schulung.'),
              duration: const Duration(seconds: 3),
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
                    final date =
                        DateTime.tryParse(schulung.datum) ?? DateTime.now();
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
                      subtitle: ScaledText(
                        formattedDate,
                        style: UIStyles.listItemSubtitleStyle,
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline_outlined,
                          color: UIConstants.deleteIcon,
                        ),
                        onPressed: () {
                          if (schulung.teilnehmerId > 0) {
                            _handleDeleteSchulung(
                              schulung.teilnehmerId,
                              index,
                              schulung.bezeichnung,
                            );
                          }
                        },
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
