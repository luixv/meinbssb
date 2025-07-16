import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/models/schulungstermin.dart';
import '/models/user_data.dart';
import '/models/bank_data.dart';
import '/services/api_service.dart';
import '/services/core/config_service.dart';
import '/services/core/email_service.dart';
import '/widgets/dialog_fabs.dart';
import '/widgets/scaled_text.dart';
import 'schulungen_register_another_dialog.dart';

class RegisteredPerson {
  RegisteredPerson(this.vorname, this.nachname, this.passnummer);
  final String vorname;
  final String nachname;
  final String passnummer;
}

void showRegisterPersonDialog(
  BuildContext parentContext,
  BuildContext dialogContext,
  Schulungstermin schulungsTermin,
  List registeredPersons,
  BankData bankData, {
  UserData? prefillUser,
  String prefillEmail = '',
}) {
  showDialog(
    context: dialogContext,
    barrierDismissible: false,
    builder: (context) {
      final vornameController = TextEditingController(
        text: prefillUser?.vorname ?? '',
      );
      final nachnameController = TextEditingController(
        text: prefillUser?.namen ?? '',
      );
      final passnummerController = TextEditingController(
        text: prefillUser?.passnummer ?? '',
      );
      final emailController = TextEditingController(text: prefillEmail);
      final telefonnummerController = TextEditingController(
        text: prefillUser?.telefon ?? '',
      );
      final formKey = GlobalKey<FormState>();
      bool isEmailValid(String email) {
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}');
        return emailRegex.hasMatch(email);
      }

      void submit() async {
        final configService = Provider.of<ConfigService>(
          dialogContext,
          listen: false,
        );
        final emailService = Provider.of<EmailService>(
          dialogContext,
          listen: false,
        );

        final from =
            configService.getString('emailRegistration.registrationFrom') ??
                'do-not-reply@bssb.de';
        final subject = configService.getString(
              'emailRegistration.registrationSubject',
            ) ??
            'Schulung Anmeldung';
        final content =
            '${configService.getString('emailRegistration.registrationContent') ?? 'Sie sind für einen Schulung angemeldet'}\n\nSchulung: ${schulungsTermin.bezeichnung}';

        final apiService = Provider.of<ApiService>(
          dialogContext,
          listen: false,
        );

        showDialog(
          context: dialogContext,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                UIConstants.defaultAppColor,
              ),
            ),
          ),
        );

        final nachname = nachnameController.text.trim();
        final passnummer = passnummerController.text.trim();
        if (!dialogContext.mounted) return;

        final isValidPerson = await apiService.findePersonID2(
          nachname,
          passnummer,
        );

        if (dialogContext.mounted) {
          Navigator.of(dialogContext, rootNavigator: true).pop();
        }

        if (!dialogContext.mounted) return;
        if (!isValidPerson) {
          ScaffoldMessenger.of(parentContext).showSnackBar(
            const SnackBar(
              content: Text(
                'Nachname und Passnummer stimmen nicht überein oder existieren nicht.',
              ),
              duration: UIConstants.snackbarDuration,
              backgroundColor: UIConstants.errorColor,
            ),
          );
          return;
        }

        if (!formKey.currentState!.validate()) return;

        Navigator.of(context).pop();
        try {
          final userData = prefillUser;
          if (userData == null) {
            ScaffoldMessenger.of(parentContext).showSnackBar(
              const SnackBar(
                content: Text('Kein Benutzer für die Anmeldung verfügbar.'),
                duration: UIConstants.snackbarDuration,
                backgroundColor: UIConstants.errorColor,
              ),
            );
            return;
          }
          final response = await apiService.registerSchulungenTeilnehmer(
            schulungTerminId: schulungsTermin.schulungsterminId,
            user: userData.copyWith(
              vorname: vornameController.text,
              namen: nachnameController.text,
              passnummer: passnummerController.text,
              telefon: telefonnummerController.text,
            ),
            email: emailController.text,
            telefon: telefonnummerController.text,
            bankData: bankData,
            felderArray: [],
          );
          final msg = response.msg;
          if (msg == 'Teilnehmer erfolgreich erfasst' ||
              msg == 'Teilnehmer bereits erfasst' ||
              msg == 'Teilnehmer erfolgreich aktualisiert') {
            await emailService.sendEmail(
              from: from,
              recipient: emailController.text,
              subject: subject,
              body: content,
            );

            if (!dialogContext.mounted) return;
            final updatedRegisteredPersons = List.from(
              registeredPersons,
            )..add(
                RegisteredPerson(
                  vornameController.text,
                  nachnameController.text,
                  passnummerController.text,
                ),
              );
            if (!dialogContext.mounted) return;
            showDialog(
              context: dialogContext,
              barrierDismissible: false,
              builder: (context) => buildRegisterAnotherDialog(
                parentContext,
                schulungsTermin,
                updatedRegisteredPersons,
                bankData,
              ),
            );
          } else {
            if (!parentContext.mounted) return;
            ScaffoldMessenger.of(parentContext).showSnackBar(
              SnackBar(
                content: Text(
                  msg.isNotEmpty ? msg : 'Fehler bei der Anmeldung.',
                ),
                duration: UIConstants.snackbarDuration,
              ),
            );
          }
        } catch (e) {
          if (!parentContext.mounted) return;
          ScaffoldMessenger.of(parentContext).showSnackBar(
            SnackBar(
              content: Text('Fehler bei der Anmeldung: $e'),
              duration: UIConstants.snackbarDuration,
            ),
          );
        }
      }

      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(UIConstants.spacingXL),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: UIConstants.dialogMinWidth,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: UIConstants.backgroundColor,
                    borderRadius: BorderRadius.circular(
                      UIConstants.cornerRadius,
                    ),
                  ),
                  padding: const EdgeInsets.only(
                    top: UIConstants.spacingXL,
                    left: UIConstants.spacingM,
                    right: UIConstants.spacingM,
                    bottom: UIConstants.spacingXL,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: ScaledText(
                          'Person anmelden',
                          style: UIStyles.dialogTitleStyle,
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingL),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: UIConstants.dialogNarrowWidth,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: UIConstants.whiteColor,
                              border: Border.all(
                                color: UIConstants.mydarkGreyColor,
                              ),
                              borderRadius: BorderRadius.circular(
                                UIConstants.cornerRadius,
                              ),
                            ),
                            padding: const EdgeInsets.only(
                              left: UIConstants.spacingM,
                              right: UIConstants.spacingM,
                              top: UIConstants.spacingM,
                              bottom: UIConstants.spacingM,
                            ),
                            child: Form(
                              key: formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: vornameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Vorname',
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Vorname ist erforderlich';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: UIConstants.spacingM,
                                  ),
                                  TextFormField(
                                    controller: nachnameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nachname',
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Nachname ist erforderlich';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: UIConstants.spacingM,
                                  ),
                                  TextFormField(
                                    controller: passnummerController,
                                    decoration: const InputDecoration(
                                      labelText: 'Passnummer',
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Passnummer ist erforderlich';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: UIConstants.spacingM,
                                  ),
                                  TextFormField(
                                    controller: emailController,
                                    decoration: const InputDecoration(
                                      labelText: 'E-Mail',
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'E-Mail ist erforderlich';
                                      }
                                      if (!isEmailValid(value.trim())) {
                                        return 'Ungültige E-Mail-Adresse';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: UIConstants.spacingM,
                                  ),
                                  TextFormField(
                                    controller: telefonnummerController,
                                    decoration: const InputDecoration(
                                      labelText: 'Telefonnummer',
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Telefonnummer ist erforderlich';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: UIConstants.dialogFabTightBottom,
                  right: UIConstants.dialogFabTightRight,
                  child: DialogFABs(
                    children: [
                      FloatingActionButton(
                        heroTag: 'cancelRegisterAnotherFab',
                        mini: true,
                        tooltip: 'Abbrechen',
                        backgroundColor: UIConstants.defaultAppColor,
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                      FloatingActionButton(
                        heroTag: 'okRegisterAnotherFab',
                        mini: true,
                        tooltip: 'OK',
                        backgroundColor: UIConstants.defaultAppColor,
                        onPressed: submit,
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
