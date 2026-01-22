import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/screens/beduerfnisse/meine_beduerfnisseantraege_screen.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import '/widgets/keyboard_focus_fab.dart';

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
          hint:
              'Informationen zum Beantragungsprozess der Bedürfnisbescheinigung',
          child: BaseScreenLayout(
            title: 'Bedürfnisbescheinigung',
            userData: userData,
            isLoggedIn: isLoggedIn,
            onLogout: onLogout,
            floatingActionButton: Semantics(
              button: true,
              enabled: true,
              label: 'Meine Bedürfnisanträge anzeigen',
              hint: 'Doppeltippen um zur Übersicht Ihrer Anträge zu navigieren',
              child: KeyboardFocusFAB(
                heroTag: 'meineBedürfnisantraegeFab',
                tooltip: 'Meine Bedürfnisanträge',
                semanticLabel: 'Meine Bedürfnisanträge Button',
                semanticHint: 'Navigieren zu Meine Bedürfnisanträge',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => MeineBeduerfnisseantraegeScreen(
                            userData: userData,
                            isLoggedIn: isLoggedIn,
                            onLogout: onLogout,
                          ),
                    ),
                  );
                },
                icon: Icons.list_alt,
              ),
            ),
            body: Focus(
              autofocus: true,
              child: Semantics(
                label:
                    'Bedürfnisbescheinigungsbereich. Hier können Sie die Bedürfnisbescheinigung beantragen und den Prozessablauf einsehen.',
                hint:
                    'Scrollen Sie nach unten um die vier Prozessschritte zu lesen',
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(UIConstants.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle
                      Semantics(
                        header: true,
                        label: 'Ablaufbeschreibung',
                        hint: 'Überschrift der Prozessbeschreibung',
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
                        hint: 'Einführungstext zum Beantragungsprozess',
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
                        hint: 'Überleitung zu den vier Prozessschritten',
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
                      Semantics(
                        label: 'Schritt 1 von 4',
                        hint: 'Erfassen der Daten mit 5 Unterpunkten',
                        child: _buildStepSection(
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
                          stepOf: '1 von 4',
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingM),

                      // Step 2
                      Semantics(
                        label: 'Schritt 2 von 4',
                        hint: 'Bestätigung der Angaben durch den Vorstand',
                        child: _buildStepSection(
                          fontSizeProvider: fontSizeProvider,
                          stepNumber: '2',
                          title:
                              'Bestätigung der Angaben durch den Vorstand nach §26 BGB',
                          items: [],
                          stepOf: '2 von 4',
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingM),

                      // Step 3
                      Semantics(
                        label: 'Schritt 3 von 4',
                        hint: 'Prüfung der Daten durch den BSSB',
                        child: _buildStepSection(
                          fontSizeProvider: fontSizeProvider,
                          stepNumber: '3',
                          title: 'Prüfung der Daten durch den BSSB',
                          items: [],
                          stepOf: '3 von 4',
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingM),

                      // Step 4
                      Semantics(
                        label: 'Schritt 4 von 4',
                        hint:
                            'Letzter Schritt: Erstellung oder Ablehnung der Bescheinigung',
                        child: _buildStepSection(
                          fontSizeProvider: fontSizeProvider,
                          stepNumber: '4',
                          title:
                              'Erstellung / Ablehnung der Bedürfnisbescheinigung',
                          items: [],
                          stepOf: '4 von 4',
                        ),
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
    String? stepOf,
  }) {
    final fullStepText =
        items.isEmpty
            ? '${stepOf != null ? "Schritt $stepOf: " : ""}$stepNumber. $title'
            : '${stepOf != null ? "Schritt $stepOf: " : ""}$stepNumber. $title mit ${items.length} Unterpunkten';

    return Semantics(
      label: fullStepText,
      hint:
          items.isEmpty
              ? 'Keine weiteren Details verfügbar'
              : 'Enthält ${items.length} Detailpunkte',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step title
          Semantics(
            header: true,
            label: 'Schritt $stepNumber: $title',
            child: Row(
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
          ),

          // Sub-items if any
          if (items.isNotEmpty) ...[
            const SizedBox(height: UIConstants.spacingS),
            Semantics(
              label: 'Liste mit ${items.length} Detailpunkten',
              child: Padding(
                padding: const EdgeInsets.only(left: UIConstants.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return Semantics(
                          label:
                              'Punkt ${index + 1} von ${items.length}: $item',
                          hint:
                              index == items.length - 1
                                  ? 'Letzter Punkt in dieser Liste'
                                  : 'Scrollen Sie weiter für mehr Punkte',
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
            ),
          ],
        ],
      ),
    );
  }
}
