import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/models/user_data.dart';
import '/screens/base_screen_layout.dart';

import 'package:provider/provider.dart';
import '/widgets/scaled_text.dart';
import '/providers/font_size_provider.dart';

class ImpressumScreen extends StatefulWidget {
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
  State<ImpressumScreen> createState() => _ImpressumScreenState();
}

class _ImpressumScreenState extends State<ImpressumScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FontSizeProvider fontSizeProvider = Provider.of<FontSizeProvider>(
      context,
    );

    return BaseScreenLayout(
      title: 'Impressum',
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout,
      body: Focus(
        autofocus: true,
        onKey: (node, event) {
          if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
            _scrollController.animateTo(
              _scrollController.offset + 100,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
            );
            return KeyEventResult.handled;
          } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
            _scrollController.animateTo(
              _scrollController.offset - 100,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
            );
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Semantics(
          label:
              'Impressum. Rechtliche Informationen, Verantwortlichkeiten und Kontaktangaben des Bayerischen Sportschützenbundes e.V. für diese App. Alle relevanten Angaben und Hinweise zur Nutzung und Haftung.',
          child: Center(
            child: SingleChildScrollView(
              controller: _scrollController,
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
                    _buildSectionHeader(
                      'Impressum',
                      isMainSection: true,
                      fontSizeProvider: fontSizeProvider,
                    ),
                    UIConstants.verticalSpacingM,
                    ExcludeSemantics(child: const Divider()),
                    UIConstants.verticalSpacingM,
                    _buildSectionHeader(
                      'Gesamtverantwortung',
                      fontSizeProvider: fontSizeProvider,
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
                    _buildSectionHeader(
                      'Datenschutzbeauftragter',
                      fontSizeProvider: fontSizeProvider,
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
                    _buildSectionHeader(
                      'Inhaltlich verantwortlich für die Teilbereiche',
                      fontSizeProvider: fontSizeProvider,
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
                    _buildSectionHeader(
                      'Hinweis zur Sprache',
                      fontSizeProvider: fontSizeProvider,
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
                    _buildSectionHeader(
                      'Bezirke / Gaue / Vereine',
                      fontSizeProvider: fontSizeProvider,
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

                    _buildSectionHeader(
                      'Haftung für weiterführende Links',
                      fontSizeProvider: fontSizeProvider,
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

                    _buildSectionHeader(
                      'Angaben zur allgemeinen Informationspflicht § 5 Digitale-Dienste-Gesetz (DDG)',
                      fontSizeProvider: fontSizeProvider,
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
        hint: 'Tippen, um das Impressum zu schließen und zur vorherigen Seite zurückzukehren',
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

// Helper method to build section headers with proper semantics
Widget _buildSectionHeader(
  String title, {
  bool isMainSection = false,
  required FontSizeProvider fontSizeProvider,
}) {
  return Semantics(
    header: true,
    label: '$title, ${isMainSection ? "Hauptabschnitt" : "Abschnittsüberschrift"}',
    child: ScaledText(
      title,
      style: UIStyles.dialogContentStyle.copyWith(
        fontSize: (isMainSection
                ? UIStyles.headerStyle.fontSize!
                : UIStyles.sectionTitleStyle.fontSize!) *
            fontSizeProvider.scaleFactor,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
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
  final contactInfo = <String>[];
  if (phone != null) contactInfo.add('Telefon $phone');
  if (email != null) contactInfo.add('E-Mail $email');
  if (web != null) contactInfo.add('Website $web');
  
  return Semantics(
    label: 'Kontaktinformationen: ${contactInfo.join(", ")}',
    child: Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.spacingXS),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: UIConstants.spacingSM,
        runSpacing: UIConstants.spacingXS,
        children: [
          if (phone != null)
            ExcludeSemantics(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.phone,
                    size: UIConstants.bodyFontSize,
                    color: UIConstants.defaultAppColor,
                  ),
                  const SizedBox(width: UIConstants.spacingXS),
                  ScaledText(
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
            ),
          if (email != null)
            ExcludeSemantics(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.email,
                    size: UIConstants.bodyFontSize,
                    color: UIConstants.defaultAppColor,
                  ),
                  const SizedBox(width: UIConstants.spacingXS),
                  ScaledText(
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
            ),
          if (web != null)
            ExcludeSemantics(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.language,
                    size: UIConstants.bodyFontSize,
                    color: UIConstants.defaultAppColor,
                  ),
                  const SizedBox(width: UIConstants.spacingXS),
                  ScaledText(
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
            ),
        ],
      ),
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
  return Semantics(
    label: 'Verantwortlicher für $title: $name, ${address.join(", ")}',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          label: '$title, Unterabschnitt',
          child: ScaledText(
            title,
            style: UIStyles.dialogContentStyle.copyWith(
              fontSize: UIStyles.bodyStyle.fontSize! * fontSizeProvider.scaleFactor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ExcludeSemantics(
          child: ScaledText(
            name,
            style: UIStyles.bodyStyle.copyWith(
              fontSize: UIStyles.bodyStyle.fontSize! * fontSizeProvider.scaleFactor,
            ),
          ),
        ),
        ExcludeSemantics(
          child: _addressBlock(address, fontSizeProvider: fontSizeProvider),
        ),
        _contactRow(
          phone: phone,
          email: email,
          fontSizeProvider: fontSizeProvider,
        ),
      ],
    ),
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