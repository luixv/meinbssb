import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/providers/font_size_provider.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/widgets/scaled_text.dart';
import '/widgets/keyboard_focus_fab.dart';

class BeduerfnissantragStep1Screen extends StatefulWidget {
  const BeduerfnissantragStep1Screen({
    this.userData,
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });

  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  State<BeduerfnissantragStep1Screen> createState() =>
      _BeduerfnissantragStep1ScreenState();
}

class _BeduerfnissantragStep1ScreenState
    extends State<BeduerfnissantragStep1Screen> {
  String? _wbkType = 'neu'; // 'neu' or 'bestehend'
  String? _wbkColor = 'gelb'; // 'gelb' or 'gruen'
  String? _weaponType = 'kurz'; // 'kurz' or 'lang'
  final TextEditingController _anzahlController = TextEditingController();
  String? _selectedVerein;

  @override
  void dispose() {
    _anzahlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return Semantics(
          container: true,
          liveRegion: true,
          label: 'Bedürfnisbescheinigung - Erfassen der Daten',
          child: BaseScreenLayout(
            title: 'Bedürfnisbescheinigung',
            userData: widget.userData,
            isLoggedIn: widget.isLoggedIn,
            onLogout: widget.onLogout,
            floatingActionButton: SizedBox(
              width: MediaQuery.of(context).size.width - 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  KeyboardFocusFAB(
                    heroTag: 'backFromErfassenFab',
                    tooltip: 'Zurück',
                    semanticLabel: 'Zurück Button',
                    semanticHint: 'Zurück zur vorherigen Seite',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icons.arrow_back,
                  ),
                  KeyboardFocusFAB(
                    heroTag: 'nextFromErfassenFab',
                    tooltip: 'Weiter',
                    semanticLabel: 'Weiter Button',
                    semanticHint: 'Weiter zum nächsten Schritt',
                    onPressed: () {
                      // TODO: Navigate to next step
                    },
                    icon: Icons.arrow_forward,
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
                    'Erfassen der Daten. Hier können Sie die notwendigen Daten für Ihren Bedürfnisantrag erfassen.',
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(UIConstants.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle
                      Semantics(
                        header: true,
                        label: 'Erfassen der Daten',
                        child: ScaledText(
                          'Erfassen der Daten',
                          style: UIStyles.headerStyle.copyWith(
                            fontSize:
                                UIStyles.headerStyle.fontSize! *
                                fontSizeProvider.scaleFactor,
                          ),
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingM),

                      // Title
                      Semantics(
                        header: true,
                        label: 'Bedürfnisantrag',
                        child: ScaledText(
                          'Bedürfnisantrag',
                          style: UIStyles.formValueBoldStyle.copyWith(
                            fontSize:
                                UIStyles.formValueBoldStyle.fontSize! *
                                fontSizeProvider.scaleFactor,
                          ),
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingM),

                      // Radio Group 1: WBK Type
                      Semantics(
                        label:
                            'Bedürfnisantrag Typ auswählen: neue oder bestehende WBK',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Transform.translate(
                              offset: const Offset(0, -8),
                              child: RadioListTile<String>(
                                dense: true,
                                visualDensity: const VisualDensity(
                                  horizontal: 0,
                                  vertical: -4,
                                ),
                                contentPadding: EdgeInsets.zero,
                                title: ScaledText(
                                  'Ich beantrage ein Bedürfnis für eine neue WBK',
                                  style: UIStyles.bodyTextStyle.copyWith(
                                    fontSize:
                                        UIStyles.bodyTextStyle.fontSize! *
                                        fontSizeProvider.scaleFactor,
                                  ),
                                ),
                                value: 'neu',
                                groupValue: _wbkType,
                                onChanged: (value) {
                                  setState(() {
                                    _wbkType = value;
                                  });
                                },
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0, -16),
                              child: RadioListTile<String>(
                                dense: true,
                                visualDensity: const VisualDensity(
                                  horizontal: 0,
                                  vertical: -4,
                                ),
                                contentPadding: EdgeInsets.zero,
                                title: ScaledText(
                                  'Ich beantrage ein Bedürfnis für eine bestehende WBK',
                                  style: UIStyles.bodyTextStyle.copyWith(
                                    fontSize:
                                        UIStyles.bodyTextStyle.fontSize! *
                                        fontSizeProvider.scaleFactor,
                                  ),
                                ),
                                value: 'bestehend',
                                groupValue: _wbkType,
                                onChanged: (value) {
                                  setState(() {
                                    _wbkType = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingS),

                      // Radio Group 2: WBK Color
                      Semantics(
                        label: 'WBK Art auswählen: Gelbe oder Grüne WBK',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Transform.translate(
                              offset: const Offset(0, -8),
                              child: RadioListTile<String>(
                                dense: true,
                                visualDensity: const VisualDensity(
                                  horizontal: 0,
                                  vertical: -4,
                                ),
                                contentPadding: EdgeInsets.zero,
                                title: ScaledText(
                                  'Gelbe WBK',
                                  style: UIStyles.bodyTextStyle.copyWith(
                                    fontSize:
                                        UIStyles.bodyTextStyle.fontSize! *
                                        fontSizeProvider.scaleFactor,
                                  ),
                                ),
                                value: 'gelb',
                                groupValue: _wbkColor,
                                onChanged: (value) {
                                  setState(() {
                                    _wbkColor = value;
                                  });
                                },
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0, -16),
                              child: RadioListTile<String>(
                                dense: true,
                                visualDensity: const VisualDensity(
                                  horizontal: 0,
                                  vertical: -4,
                                ),
                                contentPadding: EdgeInsets.zero,
                                title: ScaledText(
                                  'Grüne WBK',
                                  style: UIStyles.bodyTextStyle.copyWith(
                                    fontSize:
                                        UIStyles.bodyTextStyle.fontSize! *
                                        fontSizeProvider.scaleFactor,
                                  ),
                                ),
                                value: 'gruen',
                                groupValue: _wbkColor,
                                onChanged: (value) {
                                  setState(() {
                                    _wbkColor = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingS),

                      // Radio Group 3: Weapon Type
                      Semantics(
                        label:
                            'Bedürfnis für eine: Kurzwaffe oder Langwaffe auswählen',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ScaledText(
                              'Bedürfnis für eine:',
                              style: UIStyles.bodyTextStyle.copyWith(
                                fontSize:
                                    UIStyles.bodyTextStyle.fontSize! *
                                    fontSizeProvider.scaleFactor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0, -8),
                              child: RadioListTile<String>(
                                dense: true,
                                visualDensity: const VisualDensity(
                                  horizontal: 0,
                                  vertical: -4,
                                ),
                                contentPadding: EdgeInsets.zero,
                                title: ScaledText(
                                  'Kurzwaffe',
                                  style: UIStyles.bodyTextStyle.copyWith(
                                    fontSize:
                                        UIStyles.bodyTextStyle.fontSize! *
                                        fontSizeProvider.scaleFactor,
                                  ),
                                ),
                                value: 'kurz',
                                groupValue: _weaponType,
                                onChanged: (value) {
                                  setState(() {
                                    _weaponType = value;
                                  });
                                },
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0, -16),
                              child: RadioListTile<String>(
                                dense: true,
                                visualDensity: const VisualDensity(
                                  horizontal: 0,
                                  vertical: -4,
                                ),
                                contentPadding: EdgeInsets.zero,
                                title: ScaledText(
                                  'Langwaffe',
                                  style: UIStyles.bodyTextStyle.copyWith(
                                    fontSize:
                                        UIStyles.bodyTextStyle.fontSize! *
                                        fontSizeProvider.scaleFactor,
                                  ),
                                ),
                                value: 'lang',
                                groupValue: _weaponType,
                                onChanged: (value) {
                                  setState(() {
                                    _weaponType = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingM),

                      // Anzahl TextField
                      Semantics(
                        label:
                            'Ich besitze bereits Kurzwaffen/Langwaffen: Anzahl eingeben',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ScaledText(
                              'Ich besitze bereits Kurzwaffen/Langwaffen:',
                              style: UIStyles.bodyTextStyle.copyWith(
                                fontSize:
                                    UIStyles.bodyTextStyle.fontSize! *
                                    fontSizeProvider.scaleFactor,
                              ),
                            ),
                            const SizedBox(height: UIConstants.spacingS),
                            TextField(
                              controller: _anzahlController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Anzahl',
                                border: OutlineInputBorder(),
                              ),
                              style: UIStyles.bodyTextStyle.copyWith(
                                fontSize:
                                    UIStyles.bodyTextStyle.fontSize! *
                                    fontSizeProvider.scaleFactor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingM),

                      // Verein Dropdown
                      Semantics(
                        label: 'Verein der genehmigt auswählen',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ScaledText(
                              'Verein der genehmigt:',
                              style: UIStyles.bodyTextStyle.copyWith(
                                fontSize:
                                    UIStyles.bodyTextStyle.fontSize! *
                                    fontSizeProvider.scaleFactor,
                              ),
                            ),
                            const SizedBox(height: UIConstants.spacingS),
                            DropdownButtonFormField<String>(
                              value: _selectedVerein,
                              decoration: const InputDecoration(
                                labelText: 'Verein auswählen',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                // TODO: Load from ZMI - Erst- und Zweitvereine
                                DropdownMenuItem(
                                  value: 'verein1',
                                  child: ScaledText(
                                    'Verein 1 (Placeholder)',
                                    style: UIStyles.bodyTextStyle.copyWith(
                                      fontSize:
                                          UIStyles.bodyTextStyle.fontSize! *
                                          fontSizeProvider.scaleFactor,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 'verein2',
                                  child: ScaledText(
                                    'Verein 2 (Placeholder)',
                                    style: UIStyles.bodyTextStyle.copyWith(
                                      fontSize:
                                          UIStyles.bodyTextStyle.fontSize! *
                                          fontSizeProvider.scaleFactor,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedVerein = value;
                                });
                              },
                              style: UIStyles.bodyTextStyle.copyWith(
                                fontSize:
                                    UIStyles.bodyTextStyle.fontSize! *
                                    fontSizeProvider.scaleFactor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingM),

                      // Gebührenerhebung
                      Semantics(
                        label: 'Gebührenerhebung',
                        child: ScaledText(
                          'Gebührenerhebung:',
                          style: UIStyles.bodyTextStyle.copyWith(
                            fontSize:
                                UIStyles.bodyTextStyle.fontSize! *
                                fontSizeProvider.scaleFactor,
                          ),
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingXXXL2),
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
}
