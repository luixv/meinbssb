import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart'; // Import provider
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/models/user_data.dart';
import '/widgets/scaled_text.dart';
import '/screens/app_menu.dart';
import '/services/api_service.dart'; // Import your ApiService
import '/services/core/logger_service.dart'; // Import LoggerService
import '/services/core/font_size_provider.dart'; // Import FontSizeProvider

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
  bool _isUploading = false; // New state variable for upload process

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = image;
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
            _selectedImage =
                null; // Clear selected image after successful upload
          });
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
      floatingActionButton: FloatingActionButton(
        onPressed: _isUploading ? null : _uploadImage, // Call _uploadImage
        backgroundColor: UIConstants.defaultAppColor,
        child: _isUploading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : const Icon(Icons.save, color: Colors.white),
      ),
      endDrawer: AppDrawer(
        userData: widget.userData,
        isLoggedIn: widget.isLoggedIn,
        onLogout: widget.onLogout,
      ),
    );
  }
}
