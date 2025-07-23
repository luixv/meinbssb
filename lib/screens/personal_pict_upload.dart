import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/models/user_data.dart';
import '/widgets/scaled_text.dart';
import '/screens/app_menu.dart';
import '/services/api_service.dart';
import '/services/core/logger_service.dart';
import '/services/core/font_size_provider.dart';
import '/screens/personal_pict_upload_success.dart';

class PersonalPictUploadScreen extends StatefulWidget {
  const PersonalPictUploadScreen({
    super.key,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });

  final UserData? userData;
  final bool isLoggedIn;
  final VoidCallback onLogout;

  @override
  State<PersonalPictUploadScreen> createState() =>
      _PersonalPictUploadScreenState();
}

class _PersonalPictUploadScreenState extends State<PersonalPictUploadScreen> {
  XFile? _selectedImage;
  bool _isUploading = false; // State variable for upload process
  bool _isDeleting = false; // New state variable for delete process
  bool _isImageUploadedToServer =
      false; // New state to track successful upload to server

  @override
  void initState() {
    super.initState();
    // Potentially load existing profile picture here if available and set _isImageUploadedToServer accordingly
    // For now, we assume _selectedImage is null and _isImageUploadedToServer is false initially.
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _isImageUploadedToServer =
              false; // Reset this when a new image is selected
        });
        LoggerService.logInfo('Image selected: ${image.path}');
      } else {
        LoggerService.logInfo('Image selection cancelled.');
      }
    } catch (e) {
      LoggerService.logError('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: ScaledText(
              'Fehler beim Bildauswahl: $e',
              style: UIStyles.bodyStyle.copyWith(
                fontSize: UIStyles.bodyStyle.fontSize! *
                    Provider.of<FontSizeProvider>(context, listen: false)
                        .scaleFactor,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
      LoggerService.logWarning('No image selected for upload.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: ScaledText(
              'Bitte wählen Sie zuerst ein Bild aus.',
              style: UIStyles.bodyStyle.copyWith(
                fontSize: UIStyles.bodyStyle.fontSize! *
                    Provider.of<FontSizeProvider>(context, listen: false)
                        .scaleFactor,
              ),
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (widget.userData == null || widget.userData!.personId == 0) {
      LoggerService.logError('User data or Person ID is missing for upload.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: ScaledText(
              'Benutzerdaten fehlen. Bild kann nicht hochgeladen werden.',
              style: UIStyles.bodyStyle.copyWith(
                fontSize: UIStyles.bodyStyle.fontSize! *
                    Provider.of<FontSizeProvider>(context, listen: false)
                        .scaleFactor,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final imageBytes = await _selectedImage!.readAsBytes();
      final String userId = widget.userData!.personId
          .toString(); // Assuming personId is the userId

      LoggerService.logInfo('Attempting to upload image for userId: $userId');
      final bool success =
          await apiService.uploadProfilePhoto(userId, imageBytes);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ScaledText(
                'Profilbild erfolgreich hochgeladen!',
                style: UIStyles.bodyStyle.copyWith(
                  fontSize: UIStyles.bodyStyle.fontSize! *
                      Provider.of<FontSizeProvider>(context, listen: false)
                          .scaleFactor,
                ),
              ),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _isImageUploadedToServer = true; // Set to true on successful upload
          });
          // Navigate to the success screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PersonalPictUploadSuccessScreen(
                userData: widget.userData,
                isLoggedIn: widget.isLoggedIn,
                onLogout: widget.onLogout,
              ),
            ),
          );
          LoggerService.logInfo(
            'Navigating to PersonalPictUploadSuccessScreen (placeholder).',
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ScaledText(
                'Fehler beim Hochladen des Profilbilds.',
                style: UIStyles.bodyStyle.copyWith(
                  fontSize: UIStyles.bodyStyle.fontSize! *
                      Provider.of<FontSizeProvider>(context, listen: false)
                          .scaleFactor,
                ),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      LoggerService.logError('Exception during image upload: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: ScaledText(
              'Ein Fehler ist aufgetreten: $e',
              style: UIStyles.bodyStyle.copyWith(
                fontSize: UIStyles.bodyStyle.fontSize! *
                    Provider.of<FontSizeProvider>(context, listen: false)
                        .scaleFactor,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _deleteImage() async {
    if (widget.userData == null || widget.userData!.personId == 0) {
      LoggerService.logError('User data or Person ID is missing for deletion.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: ScaledText(
              'Benutzerdaten fehlen. Bild kann nicht gelöscht werden.',
              style: UIStyles.bodyStyle.copyWith(
                fontSize: UIStyles.bodyStyle.fontSize! *
                    Provider.of<FontSizeProvider>(context, listen: false)
                        .scaleFactor,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final String userId = widget.userData!.personId
          .toString(); // Assuming personId is the userId

      LoggerService.logInfo('Attempting to delete image for userId: $userId');
      final bool success = await apiService.deleteProfilePhoto(userId);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ScaledText(
                'Profilbild erfolgreich gelöscht!',
                style: UIStyles.bodyStyle.copyWith(
                  fontSize: UIStyles.bodyStyle.fontSize! *
                      Provider.of<FontSizeProvider>(context, listen: false)
                          .scaleFactor,
                ),
              ),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _selectedImage =
                null; // Clear the displayed image after successful deletion
            _isImageUploadedToServer =
                false; // Reset this when image is deleted
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ScaledText(
                'Fehler beim Löschen des Profilbilds.',
                style: UIStyles.bodyStyle.copyWith(
                  fontSize: UIStyles.bodyStyle.fontSize! *
                      Provider.of<FontSizeProvider>(context, listen: false)
                          .scaleFactor,
                ),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      LoggerService.logError('Exception during image deletion: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: ScaledText(
              'Ein Fehler ist aufgetreten: $e',
              style: UIStyles.bodyStyle.copyWith(
                fontSize: UIStyles.bodyStyle.fontSize! *
                    Provider.of<FontSizeProvider>(context, listen: false)
                        .scaleFactor,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: UIConstants.backgroundColor,
        iconTheme: const IconThemeData(color: UIConstants.textColor),
        title: ScaledText(
          'Profilbild',
          style: UIStyles.appBarTitleStyle.copyWith(
            fontSize: UIStyles.appBarTitleStyle.fontSize! *
                fontSizeProvider.scaleFactor,
          ),
        ),
        actions: [
          AppMenu(
            context: context,
            userData: widget.userData,
            isLoggedIn: widget.isLoggedIn,
            onLogout: widget.onLogout,
          ),
        ],
      ),
      body: Padding(
        padding: UIConstants.defaultPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: UIConstants.spacingXL),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: _selectedImage == null
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: UIConstants.defaultImageHeight + 60,
                            height: UIConstants.defaultImageHeight + 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                (UIConstants.defaultImageHeight + 60) / 2,
                              ),
                              border: Border.all(
                                color: UIConstants.mydarkGreyColor,
                                width: UIConstants.defaultStrokeWidth,
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: UIConstants.defaultImageHeight,
                              color: UIConstants.mydarkGreyColor,
                            ),
                          ),
                          Positioned(
                            bottom: UIConstants.spacingM,
                            right: UIConstants.spacingM,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x1A000000),
                                    blurRadius: UIConstants.spacingXS,
                                  ),
                                ],
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(UIConstants.spacingXS),
                                child: Icon(
                                  Icons.add_a_photo_outlined,
                                  size: UIConstants.iconSizeL,
                                  color: UIConstants.mydarkGreyColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : ClipOval(
                        child: Image.file(
                          File(_selectedImage!.path),
                          width: UIConstants.defaultImageHeight + 60,
                          height: UIConstants.defaultImageHeight + 60,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: UIConstants.spacingM),
            Center(
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload_file),
                label: ScaledText(
                  'Bild auswählen',
                  style: UIStyles.buttonStyle.copyWith(
                    fontSize: UIStyles.buttonStyle.fontSize! *
                        fontSizeProvider.scaleFactor,
                  ),
                ),
                style: UIStyles.defaultButtonStyle,
              ),
            ),
            const SizedBox(height: UIConstants.spacingL),
            if (_selectedImage != null)
              Center(
                child: ScaledText(
                  'Bild ausgewählt: ${_selectedImage!.name}',
                  style: UIStyles.bodyStyle.copyWith(
                    fontSize: UIStyles.bodyStyle.fontSize! *
                        fontSizeProvider.scaleFactor,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end, // Aligns FABs to the bottom
        children: [
          // Delete FAB (visible only if an image is selected AND successfully uploaded to server)
          if (_selectedImage != null && _isImageUploadedToServer)
            FloatingActionButton(
              heroTag: 'deleteFab', // Unique tag for delete FAB
              onPressed: _isDeleting ? null : _deleteImage,
              backgroundColor:
                  UIConstants.defaultAppColor, // Same color as save
              child: _isDeleting
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Icon(Icons.delete, color: Colors.white),
            ),
          if (_selectedImage != null && _isImageUploadedToServer)
            const SizedBox(
              height: UIConstants.spacingM,
            ), // Spacing between buttons
          // Save FAB
          FloatingActionButton(
            heroTag: 'saveFab', // Unique tag for save FAB
            onPressed: _isUploading ? null : _uploadImage,
            backgroundColor: UIConstants.defaultAppColor,
            child: _isUploading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Icon(Icons.save, color: Colors.white),
          ),
        ],
      ),
      endDrawer: AppDrawer(
        userData: widget.userData,
        isLoggedIn: widget.isLoggedIn,
        onLogout: widget.onLogout,
      ),
    );
  }
}
