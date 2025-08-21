import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/constants/messages.dart';

import 'package:meinbssb/widgets/scaled_text.dart';

class StartingRightsHeader extends StatelessWidget {
  const StartingRightsHeader({super.key, required this.seasonString});
  final String seasonString;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              UIConstants.screenPadding.copyWith(top: UIConstants.spacingS),
          child: ScaledText(
            'Schützenausweis',
            style: UIStyles.headerStyle.copyWith(
              color: UIConstants.defaultAppColor,
            ),
          ),
        ),
        Padding(
          padding: UIConstants.defaultHorizontalPadding,
          // Using Wrap to allow the elements to flow onto the next line if needed.
          // This effectively prevents overflow exceptions by enabling content wrapping.
          child: Wrap(
            // Aligns items vertically in the center of their "run" (line).
            crossAxisAlignment: WrapCrossAlignment.center,
            // Defines the horizontal spacing between children on the same line.
            spacing: UIConstants.spacingS /
                2, // A small space between main text and the season/icon group
            // Defines the vertical spacing between different lines (runs) of wrapped content.
            runSpacing: UIConstants.spacingS,
            children: [
              // The main descriptive text that might wrap independently
              ScaledText(
                'Startrechte ändern für das Sportjahr ',
                style: UIStyles.subtitleStyle.copyWith(
                  color: UIConstants.greySubtitleTextColor,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaledText(
                    '$seasonString ',
                    style: UIStyles.bodyStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      color: UIConstants.greySubtitleTextColor,
                    ),
                  ),
                  const Tooltip(
                    message: Messages.startingRightsHeaderTooltip,
                    triggerMode: TooltipTriggerMode.tap,
                    child: Icon(
                      Icons.info_outline,
                      color: UIConstants.defaultAppColor,
                      size: UIConstants.tooltipIconSize,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
