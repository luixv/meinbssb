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
      body: Focus(
        autofocus: true,
        child: Semantics(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScaledText(
                      'Impressum',
                      style: UIStyles.dialogContentStyle.copyWith(
                        fontSize:
                            UIStyles.headerStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    UIConstants.verticalSpacingM,
                    const Divider(),
                    UIConstants.verticalSpacingM,
                    ScaledText(
                      'Gesamtverantwortung',
                      style: UIStyles.dialogContentStyle.copyWith(
                        fontSize:
                            UIStyles.titleStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    UIConstants.verticalSpacingS,
                    ScaledText(
                      'Bayerischer Sportschützenbund e.V.',
                      style: UIStyles.bodyStyle.copyWith(
                        fontSize:
                            UIStyles.bodyStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ScaledText(
                      '1. Landesschützenmeister: Christian Kühn',
                      style: UIStyles.dialogContentStyle.copyWith(
                        fontSize:
                            UIStyles.bodyStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                      ),
                    ),
                    UIConstants.verticalSpacingXS,
                    _addressBlock([
                      'Olympia-Schießanlage Hochbrück',
                      'Ingolstädter Landstraße 110',
                      '85748 Garching',
                      'Eingetragen im Vereinsregister des Amtsgerichts München: VR 4803',
                    ], fontSizeProvider: fontSizeProvider),
                    UIConstants.verticalSpacingXS,
                    _contactRow(
                      phone: '0893169490',
                      email: 'gs@bssb.bayern',
                      web: 'www.bssb.de',
                      fontSizeProvider: fontSizeProvider,
                    ),
                    UIConstants.verticalSpacingM,
                    ScaledText(
                      'Datenschutzbeauftragter',
                      style: UIStyles.dialogContentStyle.copyWith(
                        fontSize:
                            UIStyles.sectionTitleStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    UIConstants.verticalSpacingS,
                    _addressBlock([
                      'Herbert Isdebski',
                      'Scheibenhalde 1',
                      '72160 Horb-Nordstetten',
                    ], fontSizeProvider: fontSizeProvider),
                    UIConstants.verticalSpacingXS,
                    _contactRow(
                      phone: '074516254240',
                      email: 'datenschutz@bssb.de',
                      fontSizeProvider: fontSizeProvider,
                    ),
                    UIConstants.verticalSpacingXS,
                    ScaledText(
                      'Telefon-Sprechstunde für BSSB-Mitglieder:',
                      style: UIStyles.dialogContentStyle.copyWith(
                        fontSize:
                            UIStyles.bodyStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ScaledText(
                      'jeder erste Donnerstag im Monat, 16 bis 18 Uhr',
                      style: UIStyles.dialogContentStyle.copyWith(
                        fontSize:
                            UIStyles.bodyStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                      ),
                    ),
                    UIConstants.verticalSpacingM,
                    ScaledText(
                      'Inhaltlich verantwortlich für die Teilbereiche',
                      style: UIStyles.dialogContentStyle.copyWith(
                        fontSize:
                            UIStyles.sectionTitleStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                      ),
                    ),
                    UIConstants.verticalSpacingS,
                    _subSection(
                      title: 'Verband',
                      name: 'Herr Alexander Heidel',
                      address: [
                        'Bayerischer Sportschützenbund e.V.',
                        'Olympia-Schießanlage Hochbrück',
                        'Ingolstädter Landstraße 110',
                        '85748 Garching',
                      ],
                      phone: '0893169490',
                      email: 'alexander.heidel@bssb.bayern',
                      fontSizeProvider: fontSizeProvider,
                    ),
                    UIConstants.verticalSpacingS,
                    _subSection(
                      title: 'Sport',
                      name: 'Herr Josef Lederer',
                      address: [
                        'Bayerischer Sportschützenbund e.V.',
                        'Olympia-Schießanlage Hochbrück',
                        'Ingolstädter Landstraße 110',
                        '85748 Garching',
                      ],
                      phone: '0893169490',
                      email: 'josef.lederer@bssb.de',
                      fontSizeProvider: fontSizeProvider,
                    ),
                    UIConstants.verticalSpacingS,
                    _subSection(
                      title: 'Jugend',
                      name: 'Herr Markus Maas',
                      address: [
                        'Bayerischer Sportschützenbund e.V.',
                        'Olympia-Schießanlage Hochbrück',
                        'Ingolstädter Landstraße 110',
                        '85748 Garching',
                      ],
                      phone: '0893169490',
                      email: 'jugend@bssb.bayern',
                      fontSizeProvider: fontSizeProvider,
                    ),
                    UIConstants.verticalSpacingM,
                    ScaledText(
                      'Hinweis zur Sprache',
                      style: UIStyles.sectionTitleStyle.copyWith(
                        fontSize:
                            UIStyles.sectionTitleStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                      ),
                    ),
                    UIConstants.verticalSpacingXS,
                    ScaledText(
                      'Aus Gründen der besseren Lesbarkeit wird auf die gleichzeitige Verwendung männlicher und weiblicher Sprachformen verzichtet. Sämtliche Personenbezeichnungen gelten gleichermaßen für alle Geschlechter.',
                      style: UIStyles.dialogContentStyle.copyWith(
                        fontSize:
                            UIStyles.bodyStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                      ),
                    ),
                    UIConstants.verticalSpacingM,
                    ScaledText(
                      'Bezirke / Gaue / Vereine',
                      style: UIStyles.dialogContentStyle.copyWith(
                        fontSize:
                            UIStyles.sectionTitleStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                      ),
                    ),
                    UIConstants.verticalSpacingXS,
                    ScaledText(
                      'Für die Liste aller Bezirke und Gaue ist der BSSB verantwortlich.',
                      style: UIStyles.dialogContentStyle.copyWith(
                        fontSize:
                            UIStyles.bodyStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                      ),
                    ),
                    ScaledText(
                      'Für die Liste aller Vereine sind die Vereine selbst verantwortlich.',
                      style: UIStyles.dialogContentStyle.copyWith(
                        fontSize:
                            UIStyles.bodyStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                      ),
                    ),
                    ScaledText(
                      'Für den Inhalt der Unterseiten von Gauen, Bezirken und Vereinen sind diese selbst verantwortlich.',
                      style: UIStyles.dialogContentStyle.copyWith(
                        fontSize:
                            UIStyles.bodyStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    UIConstants.verticalSpacingM,

                    ScaledText(
                      'Haftung für weiterführende Links',
                      style: UIStyles.sectionTitleStyle.copyWith(
                        fontSize:
                            UIStyles.sectionTitleStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                      ),
                    ),

                    UIConstants.verticalSpacingXS,
                    ScaledText(
                      'Der BSSB stellt an verschiedenen Stellen Links zu Internet-Seiten Dritter zur Verfügung. Bei Benutzung dieser Links erkennen Sie diese Nutzungsbedingungen an. Sie erkennen ebenso an, dass der BSSB keine Kontrolle über die Inhalte solcher Seiten hat und für diese Inhalte und deren Qualität keine Verantwortung übernimmt.',
                      style: UIStyles.bodyStyle.copyWith(
                        fontSize:
                            UIStyles.bodyStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                      ),
                    ),
                    UIConstants.verticalSpacingM,

                    ScaledText(
                      'Angaben zur allgemeinen Informationspflicht § 5 Digitale-Dienste-Gesetz (DDG)',
                      style: UIStyles.sectionTitleStyle.copyWith(
                        fontSize:
                            UIStyles.sectionTitleStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    UIConstants.verticalSpacingXS,
                    _addressBlock([
                      'Bayerischer Sportschützenbund e.V.',
                      'Eingetragen im Vereinsregister des Amtsgerichts München: VR 4803',
                      'Postanschrift der Geschäftsstelle:',
                      'Ingolstädter Landstrasse 110',
                      '85748 Garching',
                    ], fontSizeProvider: fontSizeProvider),
                    UIConstants.verticalSpacingXS,
                    _contactRow(
                      phone: '0893169490',
                      email: 'gs@bssb.bayern',
                      web: 'www.bssb.de/',
                      fontSizeProvider: fontSizeProvider,
                    ),
                    UIConstants.verticalSpacingXS,
                    ScaledText(
                      'Geschäftsführer',
                      style: UIStyles.bodyStyle.copyWith(
                        fontSize:
                            UIStyles.bodyStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                      style: UIStyles.bodyStyle.copyWith(
                        fontSize:
                            UIStyles.bodyStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _bulletList([
                      '1. Landesschützenmeister: Christian Kühn',
                      '2. Landesschützenmeister: Dieter Vierlbeck',
                      '3. Landesschützenmeister: Hans Hainthaler',
                      '4. Landesschützenmeister: Albert Euba',
                      '5. Landesschützenmeister: Stefan Fersch',
                    ], fontSizeProvider),
                    UIConstants.verticalSpacingXS,
                    ScaledText(
                      'Bankverbindung',
                      style: UIStyles.bodyStyle.copyWith(
                        fontSize:
                            UIStyles.bodyStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _addressBlock([
                      'HypoVereinsbank Gauting, Kontonummer: 840 000, Bankleitzahl: 700 202 70',
                      'IBAN: DE79 7002 0270 0000 8400 00, BIC: HYVEDEMMXXX',
                    ], fontSizeProvider: fontSizeProvider),
                    UIConstants.verticalSpacingXS,
                    ScaledText(
                      'Umsatzsteueridentifikationsnummer',
                      style: UIStyles.bodyStyle.copyWith(
                        fontSize:
                            UIStyles.bodyStyle.fontSize! *
                            fontSizeProvider.scaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
      floatingActionButton: Semantics(
        label: 'Impressum schließen',
        hint:
            'Tippen, um das Impressum zu schließen und zur vorherigen Seite zurückzukehren',
        button: true,
        child: FloatingActionButton(
          onPressed: () => Navigator.of(context).pop(),
          backgroundColor: UIConstants.defaultAppColor,
          child: const Icon(Icons.close, color: Colors.white),
        ),
      ),
    );
  }
}

Widget _addressBlock(
  List<String> lines, {
  required FontSizeProvider fontSizeProvider,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: UIConstants.spacingXS),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: UIConstants.spacingXXS),
            child: ScaledText(
              line,
              style: UIStyles.dialogContentStyle.copyWith(
                fontSize:
                    UIStyles.bodyStyle.fontSize! * fontSizeProvider.scaleFactor,
              ),
            ),
          ),
      ],
    ),
  );
}

Widget _contactRow({
  String? phone,
  String? email,
  String? web,
  required FontSizeProvider fontSizeProvider,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: UIConstants.spacingXS),
    child: Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: UIConstants.spacingSM,
      runSpacing: UIConstants.spacingXS,
      children: [
        if (phone != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.phone,
                size: UIConstants.bodyFontSize,
                color: UIConstants.defaultAppColor,
              ),
              const SizedBox(width: UIConstants.spacingXS),
              ScaledText(
                // Removed Flexible
                phone,
                style: UIStyles.bodyStyle.copyWith(
                  fontSize:
                      UIStyles.bodyStyle.fontSize! *
                      fontSizeProvider.scaleFactor,
                  color: UIConstants.defaultAppColor,
                ),
              ),
            ],
          ),
        if (email != null)
          Row(
            mainAxisSize:
                MainAxisSize
                    .min, // Corrected from MainAxisSize.inc to MainAxisSize.min
            children: [
              const Icon(
                Icons.email,
                size: UIConstants.bodyFontSize,
                color: UIConstants.defaultAppColor,
              ),
              const SizedBox(width: UIConstants.spacingXS),
              ScaledText(
                // Removed Flexible
                email,
                style: UIStyles.bodyStyle.copyWith(
                  fontSize:
                      UIStyles.bodyStyle.fontSize! *
                      fontSizeProvider.scaleFactor,
                  color: UIConstants.defaultAppColor,
                ),
              ),
            ],
          ),
        if (web != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.language,
                size: UIConstants.bodyFontSize,
                color: UIConstants.defaultAppColor,
              ),
              const SizedBox(width: UIConstants.spacingXS),
              ScaledText(
                // Removed Flexible
                web,
                style: UIStyles.bodyStyle.copyWith(
                  fontSize:
                      UIStyles.bodyStyle.fontSize! *
                      fontSizeProvider.scaleFactor,
                  color: UIConstants.defaultAppColor,
                ),
              ),
            ],
          ),
      ],
    ),
  );
}

Widget _subSection({
  required String title,
  required String name,
  required List<String> address,
  String? phone,
  String? email,
  required FontSizeProvider fontSizeProvider,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ScaledText(
        title,
        style: UIStyles.dialogContentStyle.copyWith(
          fontSize: UIStyles.bodyStyle.fontSize! * fontSizeProvider.scaleFactor,
          fontWeight: FontWeight.bold,
        ),
      ),
      ScaledText(
        name,
        style: UIStyles.bodyStyle.copyWith(
          fontSize: UIStyles.bodyStyle.fontSize! * fontSizeProvider.scaleFactor,
        ),
      ),
      _addressBlock(address, fontSizeProvider: fontSizeProvider),
      _contactRow(
        phone: phone,
        email: email,
        fontSizeProvider: fontSizeProvider,
      ),
    ],
  );
}

Widget _bulletList(List<String> items, FontSizeProvider fontSizeProvider) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final item in items)
        Padding(
          padding: const EdgeInsets.only(bottom: UIConstants.spacingXXS),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.start,
            spacing: UIConstants.spacingXS,
            children: [
              ScaledText('• ', style: TextStyle(fontWeight: FontWeight.bold)),
              ScaledText(
                item,
                style: UIStyles.dialogContentStyle.copyWith(
                  fontSize:
                      UIStyles.bodyStyle.fontSize! *
                      fontSizeProvider.scaleFactor,
                ),
              ), // Changed from Flexible to direct Text
            ],
          ),
        ),
    ],
  );
}
