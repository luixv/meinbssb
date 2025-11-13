import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/screens/base_screen_layout.dart';
import '/models/user_data.dart';
import '/widgets/scaled_text.dart';
import '/providers/font_size_provider.dart';
import '/widgets/keyboard_focus_fab.dart';

class StartrechteSuccessScreen extends StatefulWidget {
  const StartrechteSuccessScreen({
    super.key,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });

  final UserData? userData;
  final bool isLoggedIn;
  final VoidCallback onLogout;

  @override
  State<StartrechteSuccessScreen> createState() =>
      _StartrechteSuccessScreenState();
}

class _StartrechteSuccessScreenState extends State<StartrechteSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return BaseScreenLayout(
      title: 'Startrechte',
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout,
      body: Center(
        child: Semantics(
          label: 'Startrechte erfolgreich gespeichert!',
          liveRegion: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: UIConstants.iconSizeXL,
              ),
              const SizedBox(height: UIConstants.spacingM),
              ScaledText(
                'Ihr Startrechte wurden erfolgreich gespeichert!',
                style: UIStyles.dialogContentStyle.copyWith(
                  fontSize:
                      UIStyles.dialogContentStyle.fontSize! *
                      fontSizeProvider.scaleFactor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: KeyboardFocusFAB(
        heroTag: 'startrechteSuccessFab',
        icon: Icons.home,
        tooltip: 'Zur Startseite',
        semanticLabel: 'Zurück zum Profil',
        onPressed: () {
          Navigator.of(context).pushReplacementNamed(
            '/home',
            arguments: {
              'userData': widget.userData,
              'isLoggedIn': widget.isLoggedIn,
            },
          );
        },
      ),
    );
  }
}
