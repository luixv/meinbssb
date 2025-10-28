import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/models/schulungstermin_data.dart';
import '/providers/font_size_provider.dart';

class SchulungenListItem extends StatelessWidget {
  const SchulungenListItem({
    super.key,
    required this.schulungsTermin,
    required this.index,
    required this.onDetailsPressed,
  });
  final Schulungstermin schulungsTermin;
  final int index;
  final VoidCallback onDetailsPressed;

  @override
  Widget build(BuildContext context) {
    // Access FontSizeProvider
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        String formattedDate = DateFormat(
          'dd.MM.yyyy',
          'de_DE',
        ).format(schulungsTermin.datum);

        Color fabBackgroundColor;
        if (schulungsTermin.webGruppeLabel == 'Sport') {
          fabBackgroundColor = UIConstants.sportColor;
        } else if (schulungsTermin.webGruppeLabel == 'Jugend') {
          fabBackgroundColor = UIConstants.jugendColor;
        } else {
          fabBackgroundColor = UIConstants.schulungenNormalColor;
        }

        Widget fabIconWidget = const Icon(Icons.description);
        if (schulungsTermin.anmeldungenGesperrt) {
          fabBackgroundColor = UIConstants.schulungenGesperrtColor;
          fabIconWidget = Image.asset(
            'assets/images/stopHand.png',
            width: 40,
            height: 40,
          );
        }

        return Semantics(
          container: true,
          label:
              'Schulungslisten-Eintrag. Enthält Datum, Gruppe, Ort, Titel und Details-Button.',
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: UIConstants.tileColor,
                  borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
                ),
                padding: const EdgeInsets.all(UIConstants.spacingM),
                child: Row(
                  children: [
                    // Left: date, group, location
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            label: 'Datum der Schulung: $formattedDate',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: UIConstants.defaultIconSize,
                                ),
                                const SizedBox(width: UIConstants.spacingXS),
                                Flexible(
                                  child: Text(
                                    formattedDate,
                                    style: UIStyles.bodyStyle.copyWith(
                                      fontSize:
                                          UIStyles.bodyStyle.fontSize! *
                                          fontSizeProvider.scaleFactor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Semantics(
                            label: 'Gruppe: ${schulungsTermin.webGruppeLabel}',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.group,
                                  size: UIConstants.defaultIconSize,
                                ),
                                const SizedBox(width: UIConstants.spacingXS),
                                Flexible(
                                  child: Text(
                                    schulungsTermin.webGruppeLabel,
                                    style: UIStyles.bodyStyle.copyWith(
                                      fontSize:
                                          UIStyles.bodyStyle.fontSize! *
                                          fontSizeProvider.scaleFactor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Semantics(
                            label: 'Ort: ${schulungsTermin.ort}',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.place,
                                  size: UIConstants.defaultIconSize,
                                ),
                                const SizedBox(width: UIConstants.spacingXS),
                                Flexible(
                                  child: Text(
                                    schulungsTermin.ort,
                                    style: UIStyles.bodyStyle.copyWith(
                                      fontSize:
                                          UIStyles.bodyStyle.fontSize! *
                                          fontSizeProvider.scaleFactor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Center: title (wrapped horizontally)
                    const SizedBox(width: UIConstants.spacingM),
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Semantics(
                          label:
                              'Titel der Schulung: ${schulungsTermin.bezeichnung}',
                          child: Text(
                            schulungsTermin.bezeichnung,
                            style: UIStyles.subtitleStyle.copyWith(
                              fontSize:
                                  UIStyles.subtitleStyle.fontSize! *
                                  fontSizeProvider.scaleFactor,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ),
                    // Right: description icon
                    Semantics(
                      button: true,
                      label:
                          schulungsTermin.anmeldungenGesperrt
                              ? 'Details nicht verfügbar, Anmeldung gesperrt.'
                              : 'Details anzeigen',
                      child: FloatingActionButton(
                        heroTag: 'schulungenContentFab$index',
                        backgroundColor: fabBackgroundColor,
                        onPressed: onDetailsPressed,
                        child: fabIconWidget,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
