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
    String bezeichnung,
  ) async {
    try {
      // Your delete logic here
      await _fetchSchulungen();
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: UIConstants.startCrossAlignment,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const LogoWidget(),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: _profilePictureBytes != null &&
                            _profilePictureBytes!.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PersonalPictUploadScreen(
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
                                  builder: (context) =>
                                      PersonalPictUploadScreen(
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
                SizedBox(
                  height: 400,
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
                          mainAxisAlignment:
                              UIConstants.listItemLeadingAlignment,
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
                                // ...existing code...
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
      ),
    );
  }
}
