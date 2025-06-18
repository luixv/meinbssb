import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/models/user_data.dart';
import '/widgets/scaled_text.dart';
import '/screens/app_menu.dart';

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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: UIConstants.backgroundColor,
        iconTheme: const IconThemeData(color: UIConstants.textColor),
        title: const ScaledText(
          'Profilbild',
          style: UIStyles.appBarTitleStyle,
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
                    ? Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: UIStyles.profilePictureBackgroundColor,
                          borderRadius: BorderRadius.circular(80),
                          border: Border.all(
                            color: UIConstants.greyColor,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.add_a_photo_outlined,
                          size: 64,
                          color: UIConstants.greyColor,
                        ),
                      )
                    : ClipOval(
                        child: Image.file(
                          // ignore: use_build_context_synchronously
                          File(_selectedImage!.path),
                          width: 160,
                          height: 160,
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
                label: const Text('Bild auswählen'),
                style: UIStyles.defaultButtonStyle,
              ),
            ),
            const SizedBox(height: UIConstants.spacingL),
            if (_selectedImage != null)
              Center(
                child: ScaledText(
                  'Bild ausgewählt: ${_selectedImage!.name}',
                  style: UIStyles.bodyStyle,
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // No action for now
        backgroundColor: UIConstants.defaultAppColor,
        child: const Icon(Icons.save, color: Colors.white),
      ),
      endDrawer: AppDrawer(
        userData: widget.userData,
        isLoggedIn: widget.isLoggedIn,
        onLogout: widget.onLogout,
      ),
    );
  }
}
