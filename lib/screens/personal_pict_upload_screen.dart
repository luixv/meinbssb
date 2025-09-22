// Keep for non-web platforms, though not directly used in Image.file anymore
import 'dart:typed_data';
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
import '../providers/font_size_provider.dart';
import '/services/core/config_service.dart';
import '/screens/personal_pict_upload_success.dart';
import '/screens/connectivity_icon.dart';

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
  XFile? _selectedImage; // Holds the XFile for processing (e.g., upload)
  Uint8List? _existingProfilePhoto; // Holds bytes of the photo fetched from API
  Uint8List?
      _currentDisplayImageBytes; // Holds bytes of the image currently shown
  bool _isUploading = false; // State variable for upload process
  bool _isDeleting = false; // New state variable for delete process
  bool _isImageUploadedToServer =
      false; // New state to track successful upload to server
  bool _isLoadingExistingPhoto =
      true; // New state to track loading of existing photo

  @override
  void initState() {
    super.initState();
    _loadExistingProfilePhoto();
  }

  Future<void> _loadExistingProfilePhoto() async {
    if (widget.userData == null || widget.userData!.personId == 0) {
      setState(() {
        _isLoadingExistingPhoto = false;
        _currentDisplayImageBytes = null; // Ensure no image is displayed
      });
      return;
    }

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final String userId = widget.userData!.personId.toString();

      LoggerService.logInfo(
        'Loading existing profile photo for userId: $userId',
      );
      final Uint8List? existingPhoto = await apiService.getProfilePhoto(userId);

      if (mounted) {
        setState(() {
          _existingProfilePhoto = existingPhoto;
          _currentDisplayImageBytes = existingPhoto; // Set for display
          _isImageUploadedToServer =
              existingPhoto != null; // If photo exists, it's uploaded to server
          _isLoadingExistingPhoto = false;
          _selectedImage = null; // Clear selected image when existing is loaded
        });

        if (existingPhoto != null) {
          LoggerService.logInfo('Existing profile photo loaded successfully');
        } else {
          LoggerService.logInfo('No existing profile photo found');
        }
      }
    } catch (e) {
      LoggerService.logError('Error loading existing profile photo: $e');
      if (mounted) {
        setState(() {
          _isLoadingExistingPhoto = false;
          _currentDisplayImageBytes =
              null; // Ensure no image is displayed on error
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // Validate image immediately after selection
        final validationResult = await _validateImage(image);
        if (!validationResult['isValid']) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: ScaledText(
                  validationResult['error'],
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
          return; // Don't set the invalid image
        }

        // Read bytes for display
        final imageBytes = await image.readAsBytes();

        if (mounted) {
          setState(() {
            _selectedImage = image;
            _currentDisplayImageBytes = imageBytes; // Set for display
            _existingProfilePhoto =
                null; // Clear existing photo when new image is selected
            _isImageUploadedToServer =
                false; // Reset this when a new image is selected
          });
          LoggerService.logInfo('Image selected and validated: ${image.path}');
        }
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

  Future<Map<String, dynamic>> _validateImage(XFile image) async {
    final configService = Provider.of<ConfigService>(context, listen: false);
    final maxSizeMB = configService.getInt('maxSizeMB', 'profilePhoto') ?? 2;
    final allowedFormats =
        configService.getList('allowedFormats', 'profilePhoto') ??
            ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];

    LoggerService.logInfo(
      'Validating image: ${image.name}, maxSize: ${maxSizeMB}MB, allowedFormats: $allowedFormats',
    );

    // Check file format
    final fileName = image.name.toLowerCase();
    final fileExtension = fileName.split('.').last;

    if (!allowedFormats.contains(fileExtension)) {
      LoggerService.logWarning(
        'Invalid file format: $fileExtension, allowed: $allowedFormats',
      );
      return {
        'isValid': false,
        'error':
            'Nicht unterstütztes Dateiformat. Erlaubte Formate: ${allowedFormats.join(', ')}',
      };
    }

    // Check file size
    final fileSize = await image.length();
    final maxSizeBytes = maxSizeMB * 1024 * 1024; // Convert MB to bytes

    LoggerService.logInfo(
      'File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB, max: ${maxSizeMB}MB',
    );

    if (fileSize > maxSizeBytes) {
      LoggerService.logWarning(
        'File too large: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB > ${maxSizeMB}MB',
      );
      return {
        'isValid': false,
        'error': 'Datei ist zu groß. Maximale Größe: ${maxSizeMB}MB',
      };
    }

    LoggerService.logInfo('Image validation passed');
    return {'isValid': true};
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
      // Validate image before upload (re-validate just in case)
      final validationResult = await _validateImage(_selectedImage!);
      if (!validationResult['isValid']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: ScaledText(
                validationResult['error'],
                style: UIStyles.bodyStyle.copyWith(
                  fontSize: UIStyles.bodyStyle.fontSize! *
                      Provider.of<FontSizeProvider>(context, listen: false)
                          .scaleFactor,
                ),
              ),
            ),
          );
        }
        return;
      }

      final apiService = Provider.of<ApiService>(context, listen: false);
      final imageBytes = await _selectedImage!.readAsBytes();
      final String userId = widget.userData!.personId.toString();

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
            _selectedImage =
                null; // Clear selected image as it's now "existing"
          });
          // Reload the existing photo to ensure the display is updated from the server
          await _loadExistingProfilePhoto(); // Important: Await this call
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
            'Navigating to PersonalPictUploadSuccessScreen.',
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
      final String userId = widget.userData!.personId.toString();

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
            _existingProfilePhoto =
                null; // Clear the existing photo after successful deletion
            _currentDisplayImageBytes = null; // Clear the display bytes
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

  Widget _buildProfileImageWidget() {
    // Determine the size for the image/icon container
    const double imageContainerSize = UIConstants.defaultImageHeight + 60;

    // Show loading indicator while loading existing photo
    if (_isLoadingExistingPhoto) {
      return Container(
        width: imageContainerSize,
        height: imageContainerSize,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(imageContainerSize / 2),
          border: Border.all(
            color: UIConstants.mydarkGreyColor,
            width: UIConstants.defaultStrokeWidth,
          ),
        ),
        child: const Center(
          // Center the CircularProgressIndicator
          child: CircularProgressIndicator(
            color: UIConstants.mydarkGreyColor,
          ),
        ),
      );
    }

    // Display the current image (either selected or existing)
    if (_currentDisplayImageBytes != null &&
        _currentDisplayImageBytes!.isNotEmpty) {
      return Stack(
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: Image.memory(
              _currentDisplayImageBytes!,
              width: imageContainerSize,
              height: imageContainerSize,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                LoggerService.logError('Error loading Image.memory: $error');
                return Container(
                  // Fallback to a default icon container on error
                  width: imageContainerSize,
                  height: imageContainerSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(imageContainerSize / 2),
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
                );
              },
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
                  size: UIConstants.iconSizeM,
                  color: UIConstants.mydarkGreyColor,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Show default person icon if no image is available
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: imageContainerSize,
          height: imageContainerSize,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(imageContainerSize / 2),
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
                size: UIConstants.iconSizeM,
                color: UIConstants.mydarkGreyColor,
              ),
            ),
          ),
        ),
      ],
    );
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
          const Padding(
            padding: UIConstants.appBarRightPadding,
            child: ConnectivityIcon(),
          ),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: UIConstants.spacingXL),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: _buildProfileImageWidget(),
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

              const SizedBox(height: UIConstants.spacingM),
              // Show validation requirements
              Consumer<ConfigService>(
                builder: (context, configService, child) {
                  final maxSizeMB =
                      configService.getInt('maxSizeMB', 'profilePhoto') ?? 2;
                  final allowedFormats =
                      configService.getList('allowedFormats', 'profilePhoto') ??
                          ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];

                  return Center(
                    child: Column(
                      children: [
                        ScaledText(
                          'Anforderungen:',
                          style: UIStyles.bodyStyle.copyWith(
                            fontSize: UIStyles.bodyStyle.fontSize! *
                                fontSizeProvider.scaleFactor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingXS),
                        ScaledText(
                          'Maximale Größe: ${maxSizeMB}MB',
                          style: UIStyles.bodyStyle.copyWith(
                            fontSize: UIStyles.bodyStyle.fontSize! *
                                fontSizeProvider.scaleFactor,
                            color: UIConstants.greySubtitleTextColor,
                          ),
                        ),
                        ScaledText(
                          'Formate: ${allowedFormats.join(', ')}',
                          style: UIStyles.bodyStyle.copyWith(
                            fontSize: UIStyles.bodyStyle.fontSize! *
                                fontSizeProvider.scaleFactor,
                            color: UIConstants.greySubtitleTextColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end, // Aligns FABs to the bottom
        children: [
          // Delete FAB (visible only if an image is selected AND successfully uploaded to server, or if there's an existing photo)
          if ((_selectedImage != null && _isImageUploadedToServer) ||
              _existingProfilePhoto != null)
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
          if ((_selectedImage != null && _isImageUploadedToServer) ||
              _existingProfilePhoto != null)
            const SizedBox(
              height: UIConstants.spacingM,
            ), // Spacing between buttons
          // Save FAB (enabled when there's a selected image to upload)
          FloatingActionButton(
            heroTag: 'saveFab', // Unique tag for save FAB
            onPressed:
                (_isUploading || _selectedImage == null) ? null : _uploadImage,
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
