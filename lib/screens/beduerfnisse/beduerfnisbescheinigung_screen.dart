import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/widgets/scaled_text.dart';

class BeduerfnisbescheinigungScreen extends StatelessWidget {
  const BeduerfnisbescheinigungScreen({
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
          label: 'Bedürfnisbescheinigung',
          child: BaseScreenLayout(
            title: 'Bedürfnisbescheinigung',
            userData: userData,
            isLoggedIn: isLoggedIn,
            onLogout: onLogout,
            body: Focus(
              autofocus: true,
              child: Semantics(
                label:
                    'Bedürfnisbescheinigungsbereich. Hier können Sie die Bedürfnisbescheinigung beantragen und den Prozessablauf einsehen.',
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(UIConstants.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle
                      Semantics(
                        header: true,
                        label: 'Ablaufbeschreibung',
                        child: ScaledText(
                          'Ablaufbeschreibung',
                          style: UIStyles.headerStyle.copyWith(
                            fontSize:
                                UIStyles.headerStyle.fontSize! *
                                fontSizeProvider.scaleFactor,
                          ),
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingM),

                      // Introduction text
                      Semantics(
                        label:
                            'Hier können Sie die Bedürfnisbescheinigung beantragen.',
                        child: ScaledText(
                          'Hier können Sie die Bedürfnisbescheinigung beantragen.',
                          style: UIStyles.bodyTextStyle.copyWith(
                            fontSize:
                                UIStyles.bodyTextStyle.fontSize! *
                                fontSizeProvider.scaleFactor,
                          ),
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingM),

                      Semantics(
                        label: 'Der Prozess sieht folgende Schritte vor:',
                        child: ScaledText(
                          'Der Prozess sieht folgende Schritte vor:',
                          style: UIStyles.bodyTextStyle.copyWith(
                            fontSize:
                                UIStyles.bodyTextStyle.fontSize! *
                                fontSizeProvider.scaleFactor,
                          ),
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingM),

                      // Step 1
                      _buildStepSection(
                        fontSizeProvider: fontSizeProvider,
                        stepNumber: '1',
                        title: 'Erfassen der Daten',
                        items: [
                          'Auswahl ob ein Bedürfnis für eine neue WBK beantragt werden soll, oder eine weitere Waffe einer bestehenden WBK hinzugefügt werden soll.',
                          'Auswahl der WBK Art',
                          'Erfassen der Sportschützeneigenschaft',
                          'Ggf. erfassen der Kurz- oder Langwaffen',
                          'Ggf. Nachweis der Teilnahme an Wettbewerben',
                        ],
                      ),
                      const SizedBox(height: UIConstants.spacingM),

                      // Step 2
                      _buildStepSection(
                        fontSizeProvider: fontSizeProvider,
                        stepNumber: '2',
                        title:
                            'Bestätigung der Angaben durch den Vorstand nach §26 BGB',
                        items: [],
                      ),
                      const SizedBox(height: UIConstants.spacingM),

                      // Step 3
                      _buildStepSection(
                        fontSizeProvider: fontSizeProvider,
                        stepNumber: '3',
                        title: 'Prüfung der Daten durch den BSSB',
                        items: [],
                      ),
                      const SizedBox(height: UIConstants.spacingM),

                      // Step 4
                      _buildStepSection(
                        fontSizeProvider: fontSizeProvider,
                        stepNumber: '4',
                        title:
                            'Erstellung / Ablehnung der Bedürfnisbescheinigung',
                        items: [],
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

  Widget _buildStepSection({
    required FontSizeProvider fontSizeProvider,
    required String stepNumber,
    required String title,
    required List<String> items,
  }) {
    final fullStepText =
        items.isEmpty
            ? '$stepNumber. $title'
            : '$stepNumber. $title mit ${items.length} Unterpunkten';

    return Semantics(
      label: fullStepText,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScaledText(
                '$stepNumber. ',
                style: UIStyles.formValueBoldStyle.copyWith(
                  fontSize:
                      UIStyles.formValueBoldStyle.fontSize! *
                      fontSizeProvider.scaleFactor,
                ),
              ),
              Expanded(
                child: ScaledText(
                  title,
                  style: UIStyles.formValueBoldStyle.copyWith(
                    fontSize:
                        UIStyles.formValueBoldStyle.fontSize! *
                        fontSizeProvider.scaleFactor,
                  ),
                ),
              ),
            ],
          ),

          // Sub-items if any
          if (items.isNotEmpty) ...[
            const SizedBox(height: UIConstants.spacingS),
            Padding(
              padding: const EdgeInsets.only(left: UIConstants.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Semantics(
                        label:
                            'Unterpunkt ${index + 1} von ${items.length}: $item',
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: UIConstants.spacingS,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ScaledText(
                                '• ',
                                style: UIStyles.bodyTextStyle.copyWith(
                                  fontSize:
                                      UIStyles.bodyTextStyle.fontSize! *
                                      fontSizeProvider.scaleFactor,
                                ),
                              ),
                              Expanded(
                                child: ScaledText(
                                  item,
                                  style: UIStyles.bodyTextStyle.copyWith(
                                    fontSize:
                                        UIStyles.bodyTextStyle.fontSize! *
                                        fontSizeProvider.scaleFactor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
