import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/models/schulungstermin.dart';
import '/models/bank_data.dart';
import '/widgets/scaled_text.dart';

Widget buildRegisterAnotherDialog(
  BuildContext parentContext,
  Schulungstermin schulungsTermin,
  List registeredPersons,
  BankData bankData, {
  required Future<void> Function() onRegisterAnother,
}) {
  return Builder(
    builder: (context) {
      return AlertDialog(
        backgroundColor: UIConstants.backgroundColor,
        title: const Center(
          child: ScaledText(
            'Bereits angemeldete Personen',
            style: UIStyles.dialogTitleStyle,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (registeredPersons.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...registeredPersons.map(
                    (p) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: UIStyles.dialogContentStyle,
                              children: [
                                const TextSpan(
                                  text: '• ',
                                  style: UIStyles.dialogContentStyle,
                                ),
                                TextSpan(
                                  text: '${p.vorname} ${p.nachname}',
                                  style: UIStyles.dialogContentStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: ' (${p.passnummer})',
                                  style: UIStyles.dialogContentStyle,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingM),
                ],
              ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: UIStyles.dialogContentStyle,
                children: <TextSpan>[
                  const TextSpan(
                    text: 'Sie sind angemeldet für die Schulung\n\n',
                  ),
                  TextSpan(
                    text: schulungsTermin.bezeichnung,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            const SizedBox(height: UIConstants.spacingL),
            const Text(
              'Möchten Sie noch eine weitere Person für diese Schulung anmelden?',
              textAlign: TextAlign.center,
              style: UIStyles.dialogContentStyle,
            ),
          ],
        ),
        actions: <Widget>[
          Padding(
            padding: UIConstants.dialogPadding,
            child: Row(
              mainAxisAlignment: UIConstants.spaceBetweenAlignment,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    style: UIStyles.dialogCancelButtonStyle,
                    child: Row(
                      mainAxisAlignment: UIConstants.centerAlignment,
                      children: [
                        const Icon(Icons.close, color: UIConstants.closeIcon),
                        const SizedBox(width: UIConstants.spacingS),
                        ScaledText(
                          'Nein',
                          style: UIStyles.dialogButtonTextStyle.copyWith(
                            color: UIConstants.cancelButtonText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                UIConstants.horizontalSpacingM,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await onRegisterAnother();
                    },
                    style: UIStyles.dialogAcceptButtonStyle,
                    child: Row(
                      mainAxisAlignment: UIConstants.centerAlignment,
                      children: [
                        const Icon(Icons.check, color: UIConstants.checkIcon),
                        const SizedBox(width: UIConstants.spacingS),
                        ScaledText(
                          'Ja',
                          style: UIStyles.dialogButtonTextStyle.copyWith(
                            color: UIConstants.submitButtonText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}
