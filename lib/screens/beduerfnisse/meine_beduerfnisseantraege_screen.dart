import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/models/beduerfnisse_antrag_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/screens/beduerfnisse/beduerfnissantrag_step1_screen.dart';
import 'package:meinbssb/services/api_service.dart';
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

                      // Bedürfnisse List from API
                      FutureBuilder<List<BeduerfnisseAntrag>>(
                        future:
                            userData?.personId != null
                                ? Provider.of<ApiService>(
                                  context,
                                  listen: false,
                                ).getBedAntragByPersonId(userData!.personId)
                                : Future.value([]),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  UIConstants.defaultAppColor,
                                ),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: ScaledText(
                                'Fehler beim Laden: ${snapshot.error}',
                                style: UIStyles.bodyTextStyle.copyWith(
                                  fontSize:
                                      UIStyles.bodyTextStyle.fontSize! *
                                      fontSizeProvider.scaleFactor,
                                  color: UIConstants.errorColor,
                                ),
                              ),
                            );
                          }

                          final beduerfnisse = snapshot.data ?? [];
                          if (beduerfnisse.isEmpty) {
                            return Center(
                              child: ScaledText(
                                'Keine Bedürfnisseanträge vorhanden',
                                style: UIStyles.bodyTextStyle.copyWith(
                                  fontSize:
                                      UIStyles.bodyTextStyle.fontSize! *
                                      fontSizeProvider.scaleFactor,
                                  color: UIConstants.mydarkGreyColor,
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: [
                              for (int i = 0; i < beduerfnisse.length; i++) ...[
                                _buildBeduerfnisItem(
                                  fontSizeProvider: fontSizeProvider,
                                  antrag: beduerfnisse[i],
                                ),
                                if (i < beduerfnisse.length - 1)
                                  const SizedBox(height: UIConstants.spacingS),
                              ],
                            ],
                          );
                        },
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
    required BeduerfnisseAntrag antrag,
  }) {
    final statusColor = _getStatusColor(antrag.statusId);
    final statusText = _getStatusText(antrag.statusId);

    return Semantics(
      label:
          '${antrag.antragsnummer} vom ${antrag.createdAt}, Status: $statusText',
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
                    antrag.antragsnummer,
                    style: UIStyles.formValueBoldStyle.copyWith(
                      fontSize:
                          UIStyles.formValueBoldStyle.fontSize! *
                          fontSizeProvider.scaleFactor,
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingXS),
                  ScaledText(
                    antrag.createdAt != null
                        ? antrag.createdAt.toString()
                        : 'N/A',
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
                statusText,
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

  Color _getStatusColor(int? statusId) {
    switch (statusId) {
      case 1: // Assuming 1 = Genehmigt
        return UIConstants.successColor;
      case 2: // Assuming 2 = Abgelehnt
        return UIConstants.errorColor;
      case 3: // Assuming 3 = In Bearbeitung
        return UIConstants.warningColor;
      default:
        return UIConstants.labelTextColor;
    }
  }

  String _getStatusText(int? statusId) {
    switch (statusId) {
      case 1:
        return 'Genehmigt';
      case 2:
        return 'Abgelehnt';
      case 3:
        return 'In Bearbeitung';
      default:
        return 'Unbekannt';
    }
  }
}
