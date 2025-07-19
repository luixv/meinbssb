import 'package:flutter/material.dart';
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

class RegisteredPerson {
  RegisteredPerson(this.vorname, this.nachname, this.passnummer);
  final String vorname;
  final String nachname;
  final String passnummer;
}

class RegisterPersonFormDialog extends StatefulWidget {
  const RegisterPersonFormDialog({
    super.key,
    required this.schulungsTermin,
    required this.bankData,
    this.prefillUser,
    this.prefillEmail = '',
    required this.configService,
    required this.emailService,
    required this.apiService,
  });
  final Schulungstermin schulungsTermin;
  final BankData bankData;
  final UserData? prefillUser;
  final String prefillEmail;
  final ConfigService configService;
  final EmailService emailService;
  final ApiService apiService;

  @override
  State<RegisterPersonFormDialog> createState() =>
      _RegisterPersonFormDialogState();
}

class _RegisterPersonFormDialogState extends State<RegisterPersonFormDialog> {
  late final TextEditingController vornameController;
  late final TextEditingController nachnameController;
  late final TextEditingController passnummerController;
  late final TextEditingController emailController;
  late final TextEditingController telefonnummerController;
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    vornameController =
        TextEditingController(text: widget.prefillUser?.vorname ?? '');
    nachnameController =
        TextEditingController(text: widget.prefillUser?.namen ?? '');
    passnummerController =
        TextEditingController(text: widget.prefillUser?.passnummer ?? '');
    emailController = TextEditingController(text: widget.prefillEmail);
    telefonnummerController =
        TextEditingController(text: widget.prefillUser?.telefon ?? '');
  }

  @override
  void dispose() {
    vornameController.dispose();
    nachnameController.dispose();
    passnummerController.dispose();
    emailController.dispose();
    telefonnummerController.dispose();
    super.dispose();
  }

  bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}');
    return emailRegex.hasMatch(email);
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    final nachname = nachnameController.text.trim();
    final passnummer = passnummerController.text.trim();

    final personId =
        await widget.apiService.findePersonID2(nachname, passnummer);
    if (!mounted) return;

    // Check if the person is valid
    if (personId == 0) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
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
    // Remove the check for widget.prefillUser == null
    // Use the form fields to create the new person for registration
    final userData = widget.prefillUser?.copyWith(
          vorname: vornameController.text,
          namen: nachnameController.text,
          passnummer: passnummerController.text,
          telefon: telefonnummerController.text,
        ) ??
        UserData(
          personId: personId,
          webLoginId: 0,
          passnummer: passnummerController.text,
          vereinNr: 0,
          namen: nachnameController.text,
          vorname: vornameController.text,
          vereinName: '',
          passdatenId: 0,
          mitgliedschaftId: 0,
          telefon: telefonnummerController.text,
          // other optional fields use defaults from the model
        );
    final response = await widget.apiService.registerSchulungenTeilnehmer(
      schulungTerminId: widget.schulungsTermin.schulungsterminId,
      user: userData.copyWith(
        vorname: vornameController.text,
        namen: nachnameController.text,
        passnummer: passnummerController.text,
        telefon: telefonnummerController.text,
      ),
      email: emailController.text,
      telefon: telefonnummerController.text,
      bankData: widget.bankData,
      felderArray: [],
    );
    if (!mounted) return;
    final msg = response.msg;

    if (msg == 'Teilnehmer erfolgreich erfasst' ||
        msg == 'Teilnehmer bereits erfasst' ||
        msg == 'Teilnehmer erfolgreich aktualisiert') {
      // TODO Email in HTML
      await widget.emailService.sendEmail(
        from: widget.configService
                .getString('emailRegistration.registrationFrom') ??
            'do-not-reply@bssb.de',
        recipient: emailController.text,
        subject: widget.configService
                .getString('emailRegistration.registrationSubject') ??
            'Schulung Anmeldung',
        body: widget.configService
                .getString('emailRegistration.registrationContent') ??
            'Sie sind für einen Schulung angemeldet',
      );
      if (!mounted) return;
      setState(() => isLoading = false);
      if (!mounted) return;
      Navigator.of(context).pop(
        RegisteredPerson(
          vornameController.text,
          nachnameController.text,
          passnummerController.text,
        ),
      );
    } else {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg.isNotEmpty ? msg : 'Fehler bei der Anmeldung.'),
          duration: UIConstants.snackbarDuration,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                                    if (value == null || value.trim().isEmpty) {
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
                                    if (value == null || value.trim().isEmpty) {
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
                                    if (value == null || value.trim().isEmpty) {
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
                                    if (value == null || value.trim().isEmpty) {
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
                                    if (value == null || value.trim().isEmpty) {
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
              if (isLoading)
                Positioned.fill(
                  child: AbsorbPointer(
                    absorbing: true,
                    child: Container(
                      color: UIConstants.overlayColor,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            UIConstants.circularProgressIndicator,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
