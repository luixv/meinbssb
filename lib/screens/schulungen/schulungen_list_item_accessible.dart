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
        String formattedDate =
            DateFormat('dd.MM.yyyy', 'de_DE').format(schulungsTermin.datum);

        // Determine the background color for the FloatingActionButton based on webGruppeLabel
        Color fabBackgroundColor;
        if (schulungsTermin.webGruppeLabel == 'Sport') {
          fabBackgroundColor = UIConstants.sportColor;
        } else if (schulungsTermin.webGruppeLabel == 'Jugend') {
          fabBackgroundColor = UIConstants.jugendColor;
        } else {
          fabBackgroundColor = UIConstants.schulungenNormalColor;
        }

        String statusBeschreibung = '';
        if (schulungsTermin.anmeldungenGesperrt) {
          fabBackgroundColor = UIConstants.schulungenGesperrtColor;
          statusBeschreibung = ', Anmeldungen gesperrt';
        } else {
          final verfuegbarePlaetze = schulungsTermin.maxTeilnehmer -
              schulungsTermin.angemeldeteTeilnehmer;
          statusBeschreibung =
              ', $verfuegbarePlaetze von ${schulungsTermin.maxTeilnehmer} Plätzen frei';
        }

        // Create comprehensive accessibility label
        final String accessibilityLabel =
            'Schulung: ${schulungsTermin.bezeichnung}, '
            'Datum: $formattedDate, '
            'Gruppe: ${schulungsTermin.webGruppeLabel}, '
            'Ort: ${schulungsTermin.ort}'
            '$statusBeschreibung';

        return Semantics(
          container: true,
          button: true,
          label: accessibilityLabel,
          hint: 'Tippen Sie hier um Details zu dieser Schulung anzuzeigen',
          onTap: onDetailsPressed,
          child: Column(
            children: [
              Semantics(
                excludeSemantics:
                    true, // Prevent duplicate announcements since parent has full info
                child: Container(
                  decoration: BoxDecoration(
                    color: UIConstants.tileColor,
                    borderRadius:
                        BorderRadius.circular(UIConstants.cornerRadius),
                    // Add subtle border for better visual accessibility
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.all(UIConstants.spacingM),
                  child: Row(
                    children: [
                      // Left: date, group, location
                      Expanded(
                        flex: 1,
                        child: Semantics(
                          container: true,
                          label: 'Schulungsinfos',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date row with accessibility
                              Semantics(
                                container: true,
                                label: 'Datum: $formattedDate',
                                child: Row(
                                  children: [
                                    Semantics(
                                      excludeSemantics: true,
                                      child: const Icon(
                                        Icons.calendar_today,
                                        size: UIConstants.defaultIconSize,
                                        semanticLabel: 'Kalendersymbol',
                                      ),
                                    ),
                                    const SizedBox(
                                        width: UIConstants.spacingXS,),
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
                              const SizedBox(height: UIConstants.spacingXS),
                              // Group row with accessibility
                              Semantics(
                                container: true,
                                label:
                                    'Zielgruppe: ${schulungsTermin.webGruppeLabel}',
                                child: Row(
                                  children: [
                                    Semantics(
                                      excludeSemantics: true,
                                      child: const Icon(
                                        Icons.group,
                                        size: UIConstants.defaultIconSize,
                                        semanticLabel: 'Gruppensymbol',
                                      ),
                                    ),
                                    const SizedBox(
                                        width: UIConstants.spacingXS,),
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
                              const SizedBox(height: UIConstants.spacingXS),
                              // Location row with accessibility
                              Semantics(
                                container: true,
                                label:
                                    'Veranstaltungsort: ${schulungsTermin.ort}',
                                child: Row(
                                  children: [
                                    Semantics(
                                      excludeSemantics: true,
                                      child: const Icon(
                                        Icons.place,
                                        size: UIConstants.defaultIconSize,
                                        semanticLabel: 'Ortssymbol',
                                      ),
                                    ),
                                    const SizedBox(
                                        width: UIConstants.spacingXS,),
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
                      ),
                      // Center: title (wrapped horizontally) with accessibility
                      const SizedBox(width: UIConstants.spacingM),
                      Expanded(
                        flex: 2,
                        child: Semantics(
                          container: true,
                          header: true,
                          label:
                              'Schulungstitel: ${schulungsTermin.bezeichnung}',
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              schulungsTermin.bezeichnung,
                              style: UIStyles.subtitleStyle.copyWith(
                                fontSize: UIStyles.subtitleStyle.fontSize! *
                                    fontSizeProvider.scaleFactor,
                                // Improve contrast for accessibility
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.left,
                              // Allow text to wrap for better readability
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: UIConstants.spacingM),
                      // Right: description icon with enhanced accessibility
                      Semantics(
                        container: true,
                        button: true,
                        label:
                            'Details anzeigen für ${schulungsTermin.bezeichnung}',
                        hint: schulungsTermin.anmeldungenGesperrt
                            ? 'Anmeldungen für diese Schulung sind gesperrt'
                            : 'Zeigt detaillierte Informationen zur Schulung und Buchungsmöglichkeiten',
                        onTap: onDetailsPressed,
                        child: FloatingActionButton(
                          heroTag: 'schulungenContentFab$index',
                          backgroundColor: fabBackgroundColor,
                          tooltip: schulungsTermin.anmeldungenGesperrt
                              ? 'Anmeldungen gesperrt - Details anzeigen'
                              : 'Details anzeigen - ${schulungsTermin.webGruppeLabel}',
                          onPressed: onDetailsPressed,
                          // Improve minimum tap target size for accessibility
                          mini: false,
                          child: Semantics(
                            excludeSemantics: true,
                            child: const Icon(
                              Icons.description,
                              color: Colors.white,
                              // Ensure sufficient contrast
                              semanticLabel: 'Detailsymbol',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Add subtle visual separator for screen readers
              Semantics(
                excludeSemantics: true,
                child: Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(
                      vertical: UIConstants.spacingXS,),
                  color: Colors.transparent,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
