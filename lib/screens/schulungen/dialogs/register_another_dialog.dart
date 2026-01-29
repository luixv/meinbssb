import 'package:flutter/material.dart';

import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/models/schulungstermin_data.dart';
import '/widgets/scaled_text.dart';

class RegisteredPersonUi {
  RegisteredPersonUi(this.vorname, this.nachname, this.passnummer);
  final String vorname;
  final String nachname;
  final String passnummer;
}

class RegisterAnotherDialog extends StatelessWidget {
  const RegisterAnotherDialog({
    super.key,
    required this.schulungsTermin,
    required this.registeredPersons,
  });

  final Schulungstermin schulungsTermin;
  final List<RegisteredPersonUi> registeredPersons;

  static Future<String?> show(
    BuildContext context, {
    required Schulungstermin schulungsTermin,
    required List<RegisteredPersonUi> registeredPersons,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => RegisterAnotherDialog(
            schulungsTermin: schulungsTermin,
            registeredPersons: registeredPersons,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Dialog zur Anmeldung weiterer Personen für die Schulung.',
      child: AlertDialog(
        backgroundColor: UIConstants.backgroundColor,
        title: Center(
          child: ScaledText(
            'Bereits angemeldete Personen',
            style: UIStyles.dialogTitleStyle,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
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
                                    const TextSpan(text: '• '),
                                    TextSpan(
                                      text: '${p.vorname} ${p.nachname}',
                                      style: UIStyles.dialogContentStyle
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    TextSpan(text: ' (${p.passnummer})'),
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
          ),
        ),
        actions: [
          Padding(
            padding: UIConstants.dialogPadding,
            child: Row(
              mainAxisAlignment: UIConstants.spaceBetweenAlignment,
              children: [
                Expanded(
                  child: Semantics(
                    label: 'Button zum Abbrechen und Rückkehr zur Übersicht',
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pop('goHome');
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
                ),
                UIConstants.horizontalSpacingM,
                Expanded(
                  child: Semantics(
                    label:
                        'Button zum Hinzufügen einer weiteren Person zur Schulung',
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pop('registerAnother');
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
