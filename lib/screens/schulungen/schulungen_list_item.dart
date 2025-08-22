import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Import provider
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/models/schulungstermin.dart';
import '/services/core/font_size_provider.dart'; // Import FontSizeProvider

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
            DateFormat('dd.MM.yyyy').format(schulungsTermin.datum);

        // Determine the background color for the FloatingActionButton based on webGruppeLabel
        Color fabBackgroundColor;
        if (schulungsTermin.webGruppeLabel == 'Sport') {
          fabBackgroundColor = UIConstants.sportColor;
        } else if (schulungsTermin.webGruppeLabel == 'Jugend') {
          fabBackgroundColor = UIConstants.jugendColor;
        } else {
          fabBackgroundColor = UIConstants.schulungenNormalColor;
        }

        if (schulungsTermin.anmeldungenGesperrt) {
          fabBackgroundColor = UIConstants.schulungenGesperrtColor;
        }

        return Column(
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
                        Row(
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
                                  fontSize: UIStyles.bodyStyle.fontSize! *
                                      fontSizeProvider.scaleFactor,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        Row(
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
                                  fontSize: UIStyles.bodyStyle.fontSize! *
                                      fontSizeProvider.scaleFactor,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        Row(
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
                                  fontSize: UIStyles.bodyStyle.fontSize! *
                                      fontSizeProvider.scaleFactor,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
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
                      child: Text(
                        schulungsTermin.bezeichnung,
                        style: UIStyles.subtitleStyle.copyWith(
                          fontSize: UIStyles.subtitleStyle.fontSize! *
                              fontSizeProvider.scaleFactor,
                        ),
                        textAlign: TextAlign.left,
                        // Removed: overflow: TextOverflow.ellipsis,
                        // Removed: maxLines: 1,
                      ),
                    ),
                  ),
                  // Right: description icon
                  FloatingActionButton(
                    heroTag: 'schulungenContentFab$index',
                    backgroundColor:
                        fabBackgroundColor, // Apply the new color logic
                    onPressed: onDetailsPressed,
                    child: const Icon(Icons.description),
                  ),
                ],
              ),
            ),
            const SizedBox(height: UIConstants.helpSpacing),
          ],
        );
      },
    );
  }
}
