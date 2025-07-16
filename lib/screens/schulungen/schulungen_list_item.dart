import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/models/schulungstermin.dart';

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
    String formattedDate =
        DateFormat('dd.MM.yyyy').format(schulungsTermin.datum);
    return Container(
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
                        style: UIStyles.bodyStyle,
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
                        style: UIStyles.bodyStyle,
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
                        style: UIStyles.bodyStyle,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Center: title (centered horizontally)
          const SizedBox(width: UIConstants.spacingM),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                schulungsTermin.bezeichnung,
                style: UIStyles.subtitleStyle,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // Right: description icon
          FloatingActionButton(
            heroTag: 'schulungenContentFab$index',
            backgroundColor: schulungsTermin.anmeldungenGesperrt
                ? UIConstants.schulungenGesperrtColor
                : UIConstants.schulungenNormalColor,
            onPressed: onDetailsPressed,
            child: const Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }
}
