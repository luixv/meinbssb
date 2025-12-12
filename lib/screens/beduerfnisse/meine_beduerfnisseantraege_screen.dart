import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnissantrag_step1_screen.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import '/widgets/keyboard_focus_fab.dart';

class MeineBeduerfnisseantraegeScreen extends StatelessWidget {
  const MeineBeduerfnisseantraegeScreen({
    this.userData,
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });

  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return Semantics(
          container: true,
          liveRegion: true,
          label: 'Bedürfnisbescheinigung - Meine Bedürfnisseanträge',
          child: BaseScreenLayout(
            title: 'Bedürfnisbescheinigung',
            userData: userData,
            isLoggedIn: isLoggedIn,
            onLogout: onLogout,
            floatingActionButton: SizedBox(
              width: MediaQuery.of(context).size.width - 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  KeyboardFocusFAB(
                    heroTag: 'backToBeduerfnisbescheinigungFab',
                    tooltip: 'Zurück zur Ablaufbeschreibung',
                    semanticLabel: 'Zurück zur Ablaufbeschreibung Button',
                    semanticHint:
                        'Navigieren zurück zur Bedürfnisbescheinigung',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icons.arrow_back,
                  ),
                  KeyboardFocusFAB(
                    heroTag: 'neuerBeduerfnisantragFab',
                    tooltip: 'Neuer Bedürfnisantrag',
                    semanticLabel: 'Neuer Bedürfnisantrag Button',
                    semanticHint: 'Neuen Bedürfnisantrag erstellen',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => BeduerfnissantragStep1Screen(
                                userData: userData,
                                isLoggedIn: isLoggedIn,
                                onLogout: onLogout,
                              ),
                        ),
                      );
                    },
                    icon: Icons.add,
                  ),
                ],
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            body: Focus(
              autofocus: true,
              child: Semantics(
                label:
                    'Meine Bedürfnisseanträge. Hier sehen Sie Ihre eingereichten Bedürfnisseanträge.',
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(UIConstants.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle
                      Semantics(
                        header: true,
                        label: 'Meine Bedürfnisseanträge',
                        child: ScaledText(
                          'Meine Bedürfnisseanträge',
                          style: UIStyles.headerStyle.copyWith(
                            fontSize:
                                UIStyles.headerStyle.fontSize! *
                                fontSizeProvider.scaleFactor,
                          ),
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingM),

                      // Bedürfnisse List
                      _buildBeduerfnisItem(
                        fontSizeProvider: fontSizeProvider,
                        title: 'Bedürfnis 1',
                        date: '01.12.2025',
                        status: 'Genehmigt',
                        statusColor: UIConstants.successColor,
                      ),
                      const SizedBox(height: UIConstants.spacingS),

                      _buildBeduerfnisItem(
                        fontSizeProvider: fontSizeProvider,
                        title: 'Bedürfnis 2',
                        date: '15.11.2025',
                        status: 'Abgelehnt',
                        statusColor: UIConstants.errorColor,
                      ),
                      const SizedBox(height: UIConstants.spacingS),

                      _buildBeduerfnisItem(
                        fontSizeProvider: fontSizeProvider,
                        title: 'Bedürfnis 3',
                        date: '10.12.2025',
                        status: 'In Bearbeitung',
                        statusColor: UIConstants.warningColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBeduerfnisItem({
    required FontSizeProvider fontSizeProvider,
    required String title,
    required String date,
    required String status,
    required Color statusColor,
  }) {
    return Semantics(
      label: '$title vom $date, Status: $status',
      child: Container(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        decoration: BoxDecoration(
          color: UIConstants.whiteColor,
          borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
          border: Border.all(color: UIConstants.mydarkGreyColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScaledText(
                    title,
                    style: UIStyles.formValueBoldStyle.copyWith(
                      fontSize:
                          UIStyles.formValueBoldStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingXS),
                  ScaledText(
                    date,
                    style: UIStyles.bodyTextStyle.copyWith(
                      fontSize:
                          UIStyles.bodyTextStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                      color: UIConstants.mydarkGreyColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.spacingS,
                vertical: UIConstants.spacingXS,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
                border: Border.all(color: statusColor),
              ),
              child: ScaledText(
                status,
                style: UIStyles.bodyTextStyle.copyWith(
                  fontSize:
                      UIStyles.bodyTextStyle.fontSize! *
                      fontSizeProvider.scaleFactor,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
