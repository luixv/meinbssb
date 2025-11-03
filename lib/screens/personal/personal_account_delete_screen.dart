import '/providers/font_size_provider.dart';
import '/constants/ui_styles.dart';
import '/widgets/scaled_text.dart';
import 'package:meinbssb/constants/ui_constants.dart';

import '/screens/base_screen_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/services/api_service.dart';
import '/models/user_data.dart';

class PersonalAccountDeleteScreen extends StatefulWidget {
  const PersonalAccountDeleteScreen({
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });

  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  State<PersonalAccountDeleteScreen> createState() =>
      _PersonalAccountDeleteScreenState();
}

class _PersonalAccountDeleteScreenState
    extends State<PersonalAccountDeleteScreen> {
  bool isLoading = false;

  Future<void> _onDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return Consumer<FontSizeProvider>(
          builder:
              (context, fontSizeProvider, _) => AlertDialog(
                backgroundColor: UIConstants.backgroundColor,
                title: Center(
                  child: ScaledText(
                    'Konto löschen',
                    style: UIStyles.dialogTitleStyle.copyWith(
                      fontSize: fontSizeProvider.getScaledFontSize(20),
                    ),
                  ),
                ),
                content: Text(
                  'Sind Sie sicher, dass Sie Ihr Konto unwiderruflich löschen möchten?\n\n (Login, Bankdaten und Zugriffsrechte werden entfernt.)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSizeProvider.getScaledFontSize(16),
                  ),
                ),
                actions: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(false);
                          },
                          style: UIStyles.dialogCancelButtonStyle,
                          child: Row(
                            mainAxisAlignment: UIConstants.centerAlignment,
                            children: [
                              const Icon(
                                Icons.close,
                                color: UIConstants.closeIcon,
                              ),
                              UIConstants.horizontalSpacingM,
                              Flexible(
                                child: ScaledText(
                                  'Abbrechen',
                                  style: UIStyles.dialogButtonTextStyle
                                      .copyWith(
                                        color: UIConstants.cancelButtonText,
                                        fontSize: fontSizeProvider
                                            .getScaledFontSize(16),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: UIConstants.spacingM),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(true);
                          },
                          style: UIStyles.dialogAcceptButtonStyle,
                          child: Row(
                            mainAxisAlignment: UIConstants.centerAlignment,
                            children: [
                              const Icon(
                                Icons.delete_forever,
                                color: UIConstants.deleteIcon,
                              ),
                              UIConstants.horizontalSpacingS,
                              Flexible(
                                child: ScaledText(
                                  'Löschen',
                                  style: UIStyles.dialogButtonTextStyle
                                      .copyWith(
                                        color: UIConstants.deleteButtonText,
                                        fontSize: fontSizeProvider
                                            .getScaledFontSize(16),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        );
      },
    );
    if (confirm != true) return;

    setState(() {
      isLoading = true;
    });

    final int? webloginId = widget.userData?.webLoginId;
    if (webloginId == null) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WebloginId ist nicht verfügbar.')),
      );
      return;
    }

    final apiService = Provider.of<ApiService>(context, listen: false);

    final bool success = await apiService.deleteMeinBSSBLogin(webloginId);

    if (mounted) {
      setState(() {
        isLoading = false;
      });

      if (success) {
        // Redirect to login screen
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Antrag konnte nicht gesendet werden.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FontSizeProvider>(
      builder:
          (context, fontSizeProvider, _) => BaseScreenLayout(
            title: 'Konto löschen',
            userData: widget.userData,
            isLoggedIn: widget.isLoggedIn,
            onLogout: widget.onLogout,
            automaticallyImplyLeading: true,
            body: Semantics(
              label:
                  'Konto löschen Bildschirm. Hier können Sie Ihr Konto unwiderruflich löschen.',
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),
                    Semantics(
                      label:
                          'Warnungstext: Möchten Sie Ihr Konto unwiderruflich löschen?',
                      child: Center(
                        child: Text(
                          'Möchten Sie Ihr Konto unwiderruflich löschen?',
                          style: TextStyle(
                            fontSize: fontSizeProvider.getScaledFontSize(20),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (isLoading)
                      Semantics(
                        label: 'Ladeindikator: Konto wird gelöscht',
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    else ...[
                      Semantics(
                        label: 'Button zum unwiderruflichen Löschen des Kontos',
                        button: true,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32.0,
                              vertical: 16.0,
                            ),
                            child: ElevatedButton(
                              onPressed: _onDelete,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18.0,
                                  horizontal: 4.0,
                                ),
                                backgroundColor: UIConstants.defaultAppColor,
                              ),
                              child: Center(
                                child: Text(
                                  'Konto Löschen',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: fontSizeProvider
                                        .getScaledFontSize(18),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
