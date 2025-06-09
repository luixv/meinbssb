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
          backgroundColor: UIConstants.backgroundColor,
          title: Center(
            child: Text(
              'Schulung abmelden',
              style: UIConstants.dialogTitleStyle,
            ),
          ),
          content: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: UIConstants.dialogContentStyle,
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
                      style: UIConstants.dialogCancelButtonStyle,
                      child: Row(
                        mainAxisAlignment: UIConstants.centerAlignment,
                        children: [
                          Icon(Icons.close, color: UIConstants.closeIcon),
                          UIConstants.horizontalSpacingS,
                          Text(
                            'Abbrechen',
                            style: UIConstants.dialogButtonStyle.copyWith(
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
                      style: UIConstants.dialogAcceptButtonStyle,
                      child: Row(
                        mainAxisAlignment: UIConstants.centerAlignment,
                        children: [
                          Icon(Icons.check, color: UIConstants.checkIcon),
                          UIConstants.horizontalSpacingS,
                          Text(
                            'Löschen',
                            style: UIConstants.dialogButtonStyle.copyWith(
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
            const SnackBar(
              content: Text('Fehler beim Abmelden von der Schulung.'),
              duration: UIConstants.snackBarDuration,
            ),
          );
        }
      }
    } catch (e) {
      LoggerService.logError('Unregister error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: UIConstants.snackBarDuration,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = widget.userData;

    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: UIConstants.backgroundColor,
        title: Text(
          'Start',
          style: UIConstants.appBarTitleStyle,
        ),
        actions: [
          const Padding(
            padding: UIConstants.appBarRightPadding,
            child: ConnectivityIcon(),
          ),
          AppMenu(
            context: context,
            userData: userData,
            isLoggedIn: widget.isLoggedIn,
            onLogout: _handleLogout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        child: Column(
          crossAxisAlignment: UIConstants.startCrossAlignment,
          children: [
            const LogoWidget(),
            const SizedBox(height: UIConstants.spacingM),
            Text(
              "${userData['VORNAME'] ?? ''} ${userData['NAMEN'] ?? ''}",
              style: UIConstants.titleStyle,
            ),
            const SizedBox(height: UIConstants.spacingS),
            Text(
              '${userData['PASSNUMMER'] ?? ''}',
              style: UIConstants.bodyStyle
                  .copyWith(fontSize: UIConstants.subtitleFontSize),
            ),
            Text(
              'Schützenpassnummer',
              style: UIConstants.bodyStyle
                  .copyWith(color: UIConstants.greySubtitleText),
            ),
            const SizedBox(height: UIConstants.spacingS),
            Text(
              '${userData['VEREINNAME'] ?? ''}',
              style: UIConstants.bodyStyle
                  .copyWith(fontSize: UIConstants.subtitleFontSize),
            ),
            Text(
              'Erstverein',
              style: UIConstants.bodyStyle
                  .copyWith(color: UIConstants.greySubtitleText),
            ),
            const SizedBox(height: UIConstants.spacingM),
            Container(
              height: UIConstants.newsContainerHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: UIConstants.news,
                borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
              ),
              child: Center(
                child: Text(
                  'Hier könnten News stehen',
                  style: UIConstants.newsStyle,
                ),
              ),
            ),
            const SizedBox(height: UIConstants.spacingM),
            Text(
              'Angemeldete Schulungen:',
              style: UIConstants.titleStyle,
            ),
            const SizedBox(height: UIConstants.spacingS),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (schulungen.isEmpty)
              Text(
                'Keine Schulungen gefunden.',
                style: TextStyle(color: UIConstants.greySubtitleText),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: schulungen.length,
                  separatorBuilder: (_, __) => const SizedBox(height: UIConstants.defaultSeparatorHeight),
                  itemBuilder: (context, index) {
                    final schulung = schulungen[index];
                    final date = DateTime.tryParse(schulung['DATUM'] ?? '') ??
                        DateTime.now();
                    final formattedDate =
                        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
                    final description = schulung['BEZEICHNUNG'] ?? 'N/A';
                    final isOnline =
                        schulung['ONLINE'] ?? false;

                    return ListTile(
                      tileColor: UIConstants.tileColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
                      ),
                      leading: Column(
                        mainAxisAlignment: UIConstants.listItemLeadingAlignment,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            color: UIConstants.defaultAppColor,
                          ),
                        ],
                      ),
                      title: Text(description, style: UIConstants.listItemTitleStyle),
                      subtitle: Text(
                        formattedDate,
                        style: UIConstants.listItemSubtitleStyle,
                      ),
                      trailing:
                          isOnline
                              ? IconButton(
                                  icon: Icon(
                                    Icons.delete_outline_outlined,
                                    color: UIConstants.deleteIcon,
                                  ),
                                  onPressed: () {
                                    final id =
                                        schulung['SCHULUNGENTEILNEHMERID'];
                                    if (id != null) {
                                      _handleDeleteSchulung(
                                        id,
                                        index,
                                        description,
                                      );
                                    }
                                  },
                                )
                              : null,
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
