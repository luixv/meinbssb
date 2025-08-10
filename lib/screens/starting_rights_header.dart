import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/widgets/scaled_text.dart';

class StartingRightsHeader extends StatelessWidget {
  final String seasonString;
  const StartingRightsHeader({super.key, required this.seasonString});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: UIConstants.screenPadding.copyWith(top: UIConstants.spacingS),
          child: ScaledText(
            'Schützenausweis',
            style: UIStyles.headerStyle.copyWith(
              color: UIConstants.defaultAppColor,
            ),
          ),
        ),
        Padding(
          padding: UIConstants.defaultHorizontalPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ScaledText(
                'Startrechte ändern für das Sportjahr ',
                style: UIStyles.bodyStyle.copyWith(
                  color: UIConstants.greySubtitleTextColor,
                ),
              ),
              ScaledText(
                seasonString,
                style: UIStyles.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: UIConstants.greySubtitleTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
