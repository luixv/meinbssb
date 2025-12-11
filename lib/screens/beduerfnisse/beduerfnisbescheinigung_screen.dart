import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/models/user_data.dart';
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
    return Semantics(
      container: true,
      liveRegion: true,
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
                  const ScaledText(
                    'Ablaufbeschreibung',
                    style: UIStyles.headerStyle,
                  ),
                  const SizedBox(height: UIConstants.spacingM),

                  // Introduction text
                  const ScaledText(
                    'Hier können Sie die Bedürfnisbescheinigung beantragen.',
                    style: UIStyles.bodyTextStyle,
                  ),
                  const SizedBox(height: UIConstants.spacingM),

                  const ScaledText(
                    'Der Prozess sieht folgende Schritte vor:',
                    style: UIStyles.bodyTextStyle,
                  ),
                  const SizedBox(height: UIConstants.spacingM),

                  // Step 1
                  _buildStepSection(
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
                    stepNumber: '2',
                    title:
                        'Bestätigung der Angaben durch den Vorstand nach §26 BGB',
                    items: [],
                  ),
                  const SizedBox(height: UIConstants.spacingM),

                  // Step 3
                  _buildStepSection(
                    stepNumber: '3',
                    title: 'Prüfung der Daten durch den BSSB',
                    items: [],
                  ),
                  const SizedBox(height: UIConstants.spacingM),

                  // Step 4
                  _buildStepSection(
                    stepNumber: '4',
                    title: 'Erstellung / Ablehnung der Bedürfnisbescheinigung',
                    items: [],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepSection({
    required String stepNumber,
    required String title,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step title
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScaledText('$stepNumber. ', style: UIStyles.formValueBoldStyle),
            Expanded(
              child: ScaledText(title, style: UIStyles.formValueBoldStyle),
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
                  items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: UIConstants.spacingS,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ScaledText('• ', style: UIStyles.bodyTextStyle),
                          Expanded(
                            child: ScaledText(
                              item,
                              style: UIStyles.bodyTextStyle,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
