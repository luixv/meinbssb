import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/models/user_data.dart';
import '/screens/base_screen_layout.dart';

import 'package:provider/provider.dart';
import '/widgets/scaled_text.dart';
import '/providers/font_size_provider.dart';

class ImpressumScreen extends StatelessWidget {
  const ImpressumScreen({
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
    final FontSizeProvider fontSizeProvider = Provider.of<FontSizeProvider>(
      context,
    );
    return BaseScreenLayout(
      title: 'Impressum',
      userData: userData,
      isLoggedIn: isLoggedIn,
      onLogout: onLogout,
      body: Semantics(
        label:
            'Impressum. Rechtliche Informationen, Verantwortlichkeiten und Kontaktangaben des Bayerischen Sportschützenbundes e.V. für diese App. Alle relevanten Angaben und Hinweise zur Nutzung und Haftung.',
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
              child: Focus(
                autofocus: true,
                child: Semantics(
                  label:
                      'Impressum. Gesamtverantwortung: Bayerischer Sportschützenbund e.V., Olympia-Schießanlage Hochbrück, Ingolstädter Landstraße 110, 85748 Garching, Vereinsregister München VR 4803, Telefon: 0893169490, E-Mail: gs@bssb.bayern, Web: www.bssb.de. Gesetzliche Vertretung: 1. Landesschützenmeister: Christian Kühn, 2. Landesschützenmeister: Dieter Vierlbeck, 3. Landesschützenmeister: Hans Hainthaler, 4. Landesschützenmeister: Albert Euba, 5. Landesschützenmeister: Stefan Fersch. Geschäftsführer: Alexander Heidel. Datenschutzbeauftragter: Herbert Isdebski, Scheibenhalde 1, 72160 Horb-Nordstetten, Tel: 074516254240, E-Mail: datenschutz@bssb.de, Telefon-Sprechstunde: jeder erste Donnerstag im Monat, 16 bis 18 Uhr. Inhaltlich verantwortlich: Verband: Alexander Heidel, Sport: Josef Lederer, Jugend: Markus Maas. Hinweis zur Sprache: Alle Personenbezeichnungen gelten für alle Geschlechter. Bezirke/Gaue/Vereine: Listen und Inhalte verantwortet von BSSB bzw. Vereinen. Haftung für Links: BSSB übernimmt keine Verantwortung für Inhalte Dritter. Angaben zur Informationspflicht §5 DDG: Bayerischer Sportschützenbund e.V., Vereinsregister München VR 4803, Ingolstädter Landstrasse 110, 85748 Garching, Telefon: 0893169490, E-Mail: gs@bssb.bayern, Web: www.bssb.de, Geschäftsführer: Alexander Heidel, Vorstand i.S. §26 BGB: siehe oben, Bankverbindung: HypoVereinsbank Gauting, IBAN: DE79 7002 0270 0000 8400 00, BIC: HYVEDEMMXXX, Umsatzsteuer-ID: DE 129514004.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ScaledText(
                        'Angaben zur allgemeinen Informationspflicht § 5 Digitale-Dienste-Gesetz (DDG)',
                        style: UIStyles.sectionTitleStyle.copyWith(
                          fontSize:
                              UIStyles.sectionTitleStyle.fontSize! *
                              fontSizeProvider.scaleFactor,
                        ),
                      ),
                      UIConstants.verticalSpacingXS,
                      ScaledText(
                        'Bayerischer Sportschützenbund e.V.\nEingetragen im Vereinsregister des Amtsgerichts München: VR 4803\nPostanschrift der Geschäftsstelle:\nIngolstädter Landstrasse 110\n85748 Garching',
                        style: UIStyles.bodyStyle.copyWith(
                          fontSize:
                              UIStyles.bodyStyle.fontSize! *
                              fontSizeProvider.scaleFactor,
                        ),
                      ),
                      ScaledText(
                        'Telefon: 0893169490\nE-Mail: gs@bssb.bayern\nWeb: www.bssb.de/',
                        style: UIStyles.bodyStyle.copyWith(
                          fontSize:
                              UIStyles.bodyStyle.fontSize! *
                              fontSizeProvider.scaleFactor,
                        ),
                      ),
                      UIConstants.verticalSpacingXS,
                      ScaledText(
                        'Geschäftsführer',
                        style: UIStyles.sectionTitleStyle.copyWith(
                          fontSize:
                              UIStyles.sectionTitleStyle.fontSize! *
                              fontSizeProvider.scaleFactor,
                        ),
                      ),
                      UIConstants.verticalSpacingXS,
                      ScaledText(
                        'Alexander Heidel',
                        style: UIStyles.bodyStyle.copyWith(
                          fontSize:
                              UIStyles.bodyStyle.fontSize! *
                              fontSizeProvider.scaleFactor,
                        ),
                      ),
                      UIConstants.verticalSpacingXS,
                      ScaledText(
                        'Vorstand i.S. §26 BGB',
                        style: UIStyles.sectionTitleStyle.copyWith(
                          fontSize:
                              UIStyles.sectionTitleStyle.fontSize! *
                              fontSizeProvider.scaleFactor,
                        ),
                      ),
                      UIConstants.verticalSpacingXS,
                      ScaledText(
                        '1. Landesschützenmeister: Christian Kühn\n2. Landesschützenmeister: Dieter Vierlbeck\n3. Landesschützenmeister: Hans Hainthaler\n4. Landesschützenmeister: Albert Euba\n5. Landesschützenmeister: Stefan Fersch',
                        style: UIStyles.bodyStyle.copyWith(
                          fontSize:
                              UIStyles.bodyStyle.fontSize! *
                              fontSizeProvider.scaleFactor,
                        ),
                      ),
                      UIConstants.verticalSpacingXS,
                      ScaledText(
                        'Bankverbindung',
                        style: UIStyles.sectionTitleStyle.copyWith(
                          fontSize:
                              UIStyles.sectionTitleStyle.fontSize! *
                              fontSizeProvider.scaleFactor,
                        ),
                      ),
                      UIConstants.verticalSpacingXS,
                      ScaledText(
                        'HypoVereinsbank Gauting, Kontonummer: 840 000, Bankleitzahl: 700 202 70\nIBAN: DE79 7002 0270 0000 8400 00, BIC: HYVEDEMMXXX',
                        style: UIStyles.bodyStyle.copyWith(
                          fontSize:
                              UIStyles.bodyStyle.fontSize! *
                              fontSizeProvider.scaleFactor,
                        ),
                      ),
                      UIConstants.verticalSpacingXS,
                      ScaledText(
                        'Umsatzsteueridentifikationsnummer',
                        style: UIStyles.sectionTitleStyle.copyWith(
                          fontSize:
                              UIStyles.sectionTitleStyle.fontSize! *
                              fontSizeProvider.scaleFactor,
                        ),
                      ),
                      UIConstants.verticalSpacingXS,
                      ScaledText(
                        'DE 129514004',
                        style: UIStyles.bodyStyle.copyWith(
                          fontSize:
                              UIStyles.bodyStyle.fontSize! *
                              fontSizeProvider.scaleFactor,
                        ),
                      ),
                      const SizedBox(height: UIConstants.helpSpacing),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Semantics(
        child: Tooltip(
          message: 'Impressum schließen',
          child: FloatingActionButton(
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: UIConstants.defaultAppColor,
            child: Semantics(
              label: 'Impressum schließen',
              hint:
                  'Tippen, um das Impressum zu schließen und zur vorherigen Seite zurückzukehren',
              button: true,
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
