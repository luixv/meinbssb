import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import '/screens/base_screen_layout.dart';

class DatenschutzScreen extends StatelessWidget {
  const DatenschutzScreen({
    super.key,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
  });
  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Datenschutz',
      userData: userData,
      isLoggedIn: isLoggedIn,
      onLogout: onLogout,
      body: Semantics(
        label:
            'Datenschutz. Übersicht über alle gespeicherten Daten in dieser App und deren Verwendungszweck.',
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: UIConstants.maxContentWidth,
              ),
              margin: const EdgeInsets.symmetric(
                vertical: UIConstants.spacingL,
                horizontal: UIConstants.spacingM,
              ),
              padding: UIConstants.defaultPadding,
              decoration: BoxDecoration(
                color: UIConstants.cardColor,
                borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
                boxShadow: UIStyles.cardDecoration.boxShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ScaledText('Datenschutz', style: UIStyles.headerStyle),
                  UIConstants.verticalSpacingM,
                  const Divider(),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Allgemeine Hinweise',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Hier stehen allgemeine Hinweise zum Datenschutz.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Weitere Hinweise zum Datenschutz.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  const Divider(),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Datenspeicherung',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Verwendungszweck',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Informationen zur Datennutzung.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Besondere Hinweise',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Weitere Hinweise.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Zusätzliche Hinweise',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const Text('Hier könnte ein RichText stehen.'),
                  UIConstants.verticalSpacingM,
                  const Divider(),
                  UIConstants.verticalSpacingM,
                  const ScaledText('Rechte', style: UIStyles.sectionTitleStyle),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Informationen zu Ihren Rechten.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  const Divider(),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Weitere Rechte',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Noch mehr Rechte',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Rechte im Detail.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Weitere Details zu Rechten.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  const Divider(),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Kontakt',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Kontaktinformationen.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Weitere Kontaktinformationen.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Noch mehr Kontaktinformationen.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Letzte Kontaktinformation.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  const Divider(),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Beschwerderecht',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Informationen zum Beschwerderecht.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Weitere Informationen zum Beschwerderecht.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Letzte Information zum Beschwerderecht.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  const Divider(),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'Datenübertragbarkeit',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Informationen zur Datenübertragbarkeit.',
                    style: UIStyles.bodyStyle,
                  ),
                  UIConstants.verticalSpacingM,
                  const ScaledText(
                    'SSL- bzw. TLS-Verschlüsselung',
                    style: UIStyles.sectionTitleStyle,
                  ),
                  UIConstants.verticalSpacingS,
                  const ScaledText(
                    'Informationen zur Verschlüsselung.',
                    style: UIStyles.bodyStyle,
                  ),
                  // ...existing _buildDataItem widgets and other children...
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Semantics(
        child: Tooltip(
          message: 'Datenschutz schließen',
          child: FloatingActionButton(
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: UIConstants.defaultAppColor,
            child: Semantics(
              label: 'Datenschutz schließen',
              hint:
                  'Tippen, um den Datenschutz zu schließen und zur vorherigen Seite zurückzukehren',
              button: true,
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
