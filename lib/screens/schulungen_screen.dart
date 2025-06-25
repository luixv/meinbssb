import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/models/schulungstermine.dart';
import '/models/user_data.dart';
import '/models/bank_data.dart';
import '/screens/base_screen_layout.dart';
import '/services/api_service.dart';
import '/widgets/scaled_text.dart';
import 'package:intl/intl.dart';
import '/services/core/cache_service.dart';
import '/services/api/bank_service.dart';
import 'package:flutter_html/flutter_html.dart';

class SchulungenScreen extends StatefulWidget {
  const SchulungenScreen(
    this.userData, {
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });
  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  State<SchulungenScreen> createState() => _SchulungenScreenState();
}

class _SchulungenScreenState extends State<SchulungenScreen> {
  DateTime? _selectedDate;
  bool _isLoading = false;
  List<Schulungstermine> _results = [];
  String? _errorMessage;
  bool _hasSearched = false;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      locale: const Locale('de', 'DE'),
      helpText: 'Datum wählen',
      cancelText: 'Abbrechen',
      confirmText: 'Auswählen',
      fieldLabelText: 'Datum eingeben',
      fieldHintText: 'TT.MM.JJJJ',
      errorFormatText: 'Ungültiges Datumsformat.',
      errorInvalidText: 'Ungültiges Datum.',
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: UIConstants.defaultAppColor,
                  onPrimary: UIConstants.whiteColor,
                  surface: UIConstants.calendarBackgroundColor,
                  onSurface: UIConstants.textColor,
                ),
            textButtonTheme: const TextButtonThemeData(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  UIConstants.cancelButtonBackground,
                ),
                foregroundColor: WidgetStatePropertyAll(UIConstants.whiteColor),
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(
                    horizontal: UIConstants.spacingL,
                    vertical: UIConstants.spacingS,
                  ),
                ),
                textStyle: WidgetStatePropertyAll(UIStyles.buttonStyle),
                minimumSize: WidgetStatePropertyAll(
                  Size(UIConstants.defaultButtonWidth, UIConstants.fabSize),
                ),
              ),
            ),
            datePickerTheme: const DatePickerThemeData(
              headerBackgroundColor: UIConstants.calendarBackgroundColor,
              backgroundColor: UIConstants.calendarBackgroundColor,
              headerForegroundColor: UIConstants.textColor,
              dayStyle: TextStyle(color: UIConstants.textColor),
              yearStyle: TextStyle(color: UIConstants.textColor),
              weekdayStyle: TextStyle(color: UIConstants.textColor),
              confirmButtonStyle: ButtonStyle(
                backgroundColor:
                    WidgetStatePropertyAll(UIConstants.primaryColor),
                foregroundColor: WidgetStatePropertyAll(UIConstants.whiteColor),
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(
                    horizontal: UIConstants.spacingL,
                    vertical: UIConstants.spacingS,
                  ),
                ),
                textStyle: WidgetStatePropertyAll(UIStyles.buttonStyle),
                minimumSize: WidgetStatePropertyAll(
                  Size(UIConstants.defaultButtonWidth, UIConstants.fabSize),
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      await _search();
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  Future<void> _search() async {
    if (_selectedDate == null) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _results = [];
      _hasSearched = true;
    });
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final result =
          await apiService.fetchSchulungstermine(_formatDate(_selectedDate!));
      setState(() {
        _results = result;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Laden der Schulungen: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showBookingDialog(
    Schulungstermine schulungsTermin, {
    required List<_RegisteredPerson> registeredPersons,
  }) async {
    if (!mounted) return;
    final parentContext = context;
    final user = widget.userData;
    // Fetch bank data
    final apiService = Provider.of<ApiService>(parentContext, listen: false);
    final cacheService =
        Provider.of<CacheService>(parentContext, listen: false);

    // Fetch bank data and contacts in parallel
    final Future<List<BankData>> bankDataFuture = apiService.fetchBankData(
      user?.webLoginId ?? 0,
    );
    final Future<List<Map<String, dynamic>>> contactsFuture =
        apiService.fetchKontakte(
      user?.personId ?? 0,
    );

    final List<BankData> bankDataList = await bankDataFuture;
    final List<Map<String, dynamic>> contacts = await contactsFuture;

    // Get phone number from contacts
    String phoneNumber = '';

    // Try to find private phone number first
    final privateContacts = contacts.firstWhere(
      (category) => category['category'] == 'Privat',
      orElse: () => {'contacts': []},
    )['contacts'] as List<dynamic>;

    // Look for any phone number in private contacts
    var phoneContact = privateContacts.cast<Map<String, dynamic>>().firstWhere(
          (contact) =>
              contact['rawKontaktTyp'] == 1 || contact['rawKontaktTyp'] == 2,
          orElse: () => {'value': ''},
        );

    if (phoneContact['value'] == '') {
      // If no private phone found, look for business phone
      final businessContacts = contacts.firstWhere(
        (category) => category['category'] == 'Geschäftlich',
        orElse: () => {'contacts': []},
      )['contacts'] as List<dynamic>;

      phoneContact = businessContacts.cast<Map<String, dynamic>>().firstWhere(
            (contact) =>
                contact['rawKontaktTyp'] == 5 || contact['rawKontaktTyp'] == 6,
            orElse: () => {'value': ''},
          );
    }

    phoneNumber = phoneContact['value'] as String;

    // Get email from cache
    final String email = await cacheService.getString('username') ?? '';

    // Get bank data
    final bankData = bankDataList.isNotEmpty ? bankDataList.first : null;

    if (!mounted) return;

    // Show the booking dialog with the fetched data
    showDialog(
      context: parentContext,
      builder: (context) {
        final emailController = TextEditingController(
          text: email,
        );
        final telefonController = TextEditingController(
          text: phoneNumber,
        );
        final kontoinhaberController = TextEditingController(
          text: bankData?.kontoinhaber ?? '',
        );
        final ibanController = TextEditingController(
          text: bankData?.iban ?? '',
        );
        final bicController = TextEditingController(
          text: bankData?.bic ?? '',
        );

        return Stack(
          children: [
            AlertDialog(
              backgroundColor: UIConstants.backgroundColor,
              title: const Center(
                child: ScaledText(
                  'Schulung buchen',
                  style: UIStyles.dialogTitleStyle,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- Personal Data Block ---
                    Container(
                      decoration: BoxDecoration(
                        color: UIConstants.whiteColor,
                        border: Border.all(color: UIConstants.mydarkGreyColor),
                        borderRadius:
                            BorderRadius.circular(UIConstants.cornerRadius),
                      ),
                      padding: UIConstants.defaultPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Persönliche Daten',
                            style: UIStyles.sectionTitleStyle,
                          ),
                          const SizedBox(height: UIConstants.spacingM),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: TextEditingController(
                                    text: user?.vorname ?? '',
                                  ),
                                  decoration: UIStyles.formInputDecoration
                                      .copyWith(labelText: 'Vorname'),
                                  readOnly: true,
                                  style: UIStyles.formValueBoldStyle,
                                ),
                              ),
                              const SizedBox(width: UIConstants.spacingM),
                              Expanded(
                                child: TextField(
                                  controller: TextEditingController(
                                    text: user?.namen ?? '',
                                  ),
                                  decoration: UIStyles.formInputDecoration
                                      .copyWith(labelText: 'Nachname'),
                                  readOnly: true,
                                  style: UIStyles.formValueBoldStyle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: UIConstants.spacingM),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: emailController,
                                  decoration: UIStyles.formInputDecoration
                                      .copyWith(labelText: 'E-Mail'),
                                  readOnly: true,
                                  style: UIStyles.formValueBoldStyle,
                                ),
                              ),
                              const SizedBox(width: UIConstants.spacingM),
                              Expanded(
                                child: TextField(
                                  controller: telefonController,
                                  decoration: UIStyles.formInputDecoration
                                      .copyWith(labelText: 'Telefon'),
                                  readOnly: true,
                                  style: UIStyles.formValueBoldStyle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingL),
                    // --- Bank Data Block ---
                    Container(
                      decoration: BoxDecoration(
                        color: UIConstants.whiteColor,
                        border: Border.all(color: UIConstants.mydarkGreyColor),
                        borderRadius:
                            BorderRadius.circular(UIConstants.cornerRadius),
                      ),
                      padding: UIConstants.defaultPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bankdaten',
                            style: UIStyles.sectionTitleStyle,
                          ),
                          const SizedBox(height: UIConstants.spacingM),
                          TextFormField(
                            controller: kontoinhaberController,
                            decoration: UIStyles.formInputDecoration
                                .copyWith(labelText: 'Kontoinhaber'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Kontoinhaber ist erforderlich';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: UIConstants.spacingM),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: ibanController,
                                  decoration: UIStyles.formInputDecoration
                                      .copyWith(labelText: 'IBAN'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'IBAN ist erforderlich';
                                    }
                                    if (!BankService.validateIBAN(value)) {
                                      return 'Ungültige IBAN';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: UIConstants.spacingM),
                              Expanded(
                                child: TextFormField(
                                  controller: bicController,
                                  decoration: UIStyles.formInputDecoration
                                      .copyWith(labelText: 'BIC'),
                                  validator: (value) {
                                    final bicError =
                                        BankService.validateBIC(value);
                                    if (bicError != null) {
                                      return bicError;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: UIConstants.spacingM,
              right: UIConstants.spacingM,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    heroTag: 'buchungCancelFab',
                    mini: true,
                    tooltip: 'Abbrechen',
                    backgroundColor: UIConstants.defaultAppColor,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: UIConstants.spacingS),
                  FloatingActionButton(
                    heroTag: 'buchungOkFab',
                    mini: true,
                    tooltip: 'Buchen',
                    backgroundColor: UIConstants.defaultAppColor,
                    onPressed: () async {
                      final dialogContext = parentContext;
                      Navigator.of(context).pop();
                      try {
                        final apiService = Provider.of<ApiService>(
                          dialogContext,
                          listen: false,
                        );
                        final response =
                            await apiService.registerSchulungenTeilnehmer(
                          schulungTerminId: schulungsTermin.schulungsterminId,
                          user: user!.copyWith(
                            vorname: user.vorname,
                            namen: user.namen,
                            passnummer: user.passnummer,
                            telefon: user.telefon,
                          ),
                          email: emailController.text,
                          telefon: telefonController.text,
                          bankData: BankData(
                            id: bankData?.id ?? 0,
                            webloginId: user.webLoginId,
                            kontoinhaber: kontoinhaberController.text,
                            iban: ibanController.text,
                            bic: bicController.text,
                            mandatSeq: bankData?.mandatSeq ?? 2,
                            bankName: bankData?.bankName ?? '',
                            mandatNr: bankData?.mandatNr ?? '',
                            mandatName: bankData?.mandatName ?? '',
                          ),
                          felderArray: [], // Pass an empty list unless you have dynamic fields
                        );
                        final msg = response.msg;
                        if (msg == 'Teilnehmer erfolgreich erfasst' ||
                            msg == 'Teilnehmer bereits erfasst' ||
                            msg == 'Teilnehmer erfolgreich aktualisiert') {
                          if (!mounted) return;
                          final updatedRegisteredPersons =
                              List<_RegisteredPerson>.from(registeredPersons)
                                ..add(
                                  _RegisteredPerson(
                                    user.vorname,
                                    user.namen,
                                    user.passnummer,
                                  ),
                                );
                          if (bankData != null) {
                            showDialog(
                              context: dialogContext,
                              barrierDismissible: false,
                              builder: (context) => _buildRegisterAnotherDialog(
                                dialogContext,
                                schulungsTermin,
                                updatedRegisteredPersons,
                                bankData,
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                msg.isNotEmpty
                                    ? msg
                                    : 'Fehler bei der Anmeldung.',
                              ),
                              duration: UIConstants.snackbarDuration,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(
                            content: Text('Fehler bei der Anmeldung: $e'),
                            duration: UIConstants.snackbarDuration,
                          ),
                        );
                      }
                    },
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
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

  Widget _buildRegisterAnotherDialog(
    BuildContext parentContext,
    Schulungstermine schulungsTermin,
    List<_RegisteredPerson> registeredPersons,
    BankData bankData,
  ) {
    return AlertDialog(
      backgroundColor: UIConstants.backgroundColor,
      title: const Center(
        child: ScaledText(
          'Erfolg',
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
                const Text(
                  'Bereits angemeldete Personen:',
                  style: UIStyles.dialogContentStyle,
                ),
                const SizedBox(height: UIConstants.spacingS),
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
                                style: UIStyles.dialogContentStyle
                                    .copyWith(fontWeight: FontWeight.bold),
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
                  text: 'Sie sind angemeldet für die Schulung ',
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
                  onPressed: () => Navigator.of(parentContext).pop(),
                  style: UIStyles.dialogCancelButtonStyle,
                  child: Row(
                    mainAxisAlignment: UIConstants.centerAlignment,
                    children: [
                      const Icon(
                        Icons.close,
                        color: UIConstants.closeIcon,
                      ),
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
                  onPressed: () {
                    Navigator.of(parentContext).pop();
                    Future.delayed(Duration.zero, () {
                      _showRegisterAnotherPersonDialog(
                        parentContext,
                        parentContext,
                        schulungsTermin,
                        registeredPersons,
                        bankData,
                      );
                    });
                  },
                  style: UIStyles.dialogAcceptButtonStyle,
                  child: Row(
                    mainAxisAlignment: UIConstants.centerAlignment,
                    children: [
                      const Icon(
                        Icons.check,
                        color: UIConstants.checkIcon,
                      ),
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
  }

  void _showRegisterAnotherPersonDialog(
    BuildContext parentContext,
    BuildContext dialogContext,
    Schulungstermine schulungsTermin,
    List<_RegisteredPerson> registeredPersons,
    BankData bankData,
  ) {
    showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder: (context) {
        final vornameController = TextEditingController();
        final nachnameController = TextEditingController();
        final passnummerController = TextEditingController();
        final emailController = TextEditingController();
        final telefonnummerController = TextEditingController();
        final formKey = GlobalKey<FormState>();
        bool isEmailValid(String email) {
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}');
          return emailRegex.hasMatch(email);
        }

        void submit() async {
          if (!formKey.currentState!.validate()) return;
          Navigator.of(context).pop();
          try {
            final apiService = Provider.of<ApiService>(
              dialogContext,
              listen: false,
            );
            final response = await apiService.registerSchulungenTeilnehmer(
              schulungTerminId: schulungsTermin.schulungsterminId,
              user: widget.userData!.copyWith(
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
              if (!mounted) return;
              final updatedRegisteredPersons =
                  List<_RegisteredPerson>.from(registeredPersons)
                    ..add(
                      _RegisteredPerson(
                        vornameController.text,
                        nachnameController.text,
                        passnummerController.text,
                      ),
                    );
              showDialog(
                context: dialogContext,
                barrierDismissible: false,
                builder: (context) => _buildRegisterAnotherDialog(
                  parentContext,
                  schulungsTermin,
                  updatedRegisteredPersons,
                  bankData,
                ),
              );
            } else {
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
            ScaffoldMessenger.of(parentContext).showSnackBar(
              SnackBar(
                content: Text('Fehler bei der Anmeldung: $e'),
                duration: UIConstants.snackbarDuration,
              ),
            );
          }
        }

        return AlertDialog(
          backgroundColor: UIConstants.backgroundColor,
          title: const Center(
            child: ScaledText(
              'Weitere Person anmelden',
              style: UIStyles.dialogTitleStyle,
            ),
          ),
          content: Form(
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
                const SizedBox(height: UIConstants.spacingM),
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
                const SizedBox(height: UIConstants.spacingM),
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
                const SizedBox(height: UIConstants.spacingM),
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
                const SizedBox(height: UIConstants.spacingM),
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
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'cancelRegisterAnotherFab',
                  mini: true,
                  tooltip: 'Abbrechen',
                  backgroundColor: UIConstants.defaultAppColor,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: UIConstants.spacingS),
                FloatingActionButton(
                  heroTag: 'okRegisterAnotherFab',
                  mini: true,
                  tooltip: 'OK',
                  backgroundColor: UIConstants.defaultAppColor,
                  onPressed: submit,
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Schulungen',
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout,
      body: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScaledText(
              'Schulungen suchen',
              style: UIStyles.headerStyle,
            ),
            const SizedBox(height: UIConstants.spacingM),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: UIStyles.formInputDecoration.copyWith(
                        labelText: 'Datum wählen',
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                      child: ScaledText(
                        _selectedDate == null
                            ? 'Bitte wählen Sie ein Datum'
                            : _formatDate(_selectedDate!),
                        style: UIStyles.bodyStyle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.spacingL),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_errorMessage != null)
              ScaledText(
                _errorMessage!,
                style: UIStyles.errorStyle,
              ),
            if (!_isLoading && _errorMessage == null && _results.isNotEmpty)
              Expanded(
                child: ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: UIConstants.spacingS),
                  itemBuilder: (context, index) {
                    final schulungsTermin = _results[index];
                    String formattedDate =
                        DateFormat('dd.MM.yyyy').format(schulungsTermin.datum);
                    return Container(
                      decoration: BoxDecoration(
                        color: UIConstants.tileColor,
                        borderRadius:
                            BorderRadius.circular(UIConstants.cornerRadius),
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
                                RichText(
                                  text: TextSpan(
                                    style: UIStyles.bodyStyle,
                                    children: [
                                      const TextSpan(
                                        text: 'Datum: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(text: formattedDate),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    style: UIStyles.bodyStyle,
                                    children: [
                                      const TextSpan(
                                        text: 'Gruppe: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: schulungsTermin.webGruppeLabel,
                                      ),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    style: UIStyles.bodyStyle,
                                    children: [
                                      const TextSpan(
                                        text: 'Ort: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(text: schulungsTermin.ort),
                                    ],
                                  ),
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
                            backgroundColor: UIConstants.defaultAppColor,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  final t = schulungsTermin;
                                  final freiePlaetze =
                                      t.maxTeilnehmer - t.angemeldeteTeilnehmer;
                                  return AlertDialog(
                                    backgroundColor:
                                        UIConstants.backgroundColor,
                                    contentPadding: EdgeInsets.zero,
                                    content: Stack(
                                      children: [
                                        SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              // White header and info container
                                              Container(
                                                decoration: const BoxDecoration(
                                                  color: UIConstants.whiteColor,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                      UIConstants.cornerRadius,
                                                    ),
                                                    topRight: Radius.circular(
                                                      UIConstants.cornerRadius,
                                                    ),
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    // Title
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        top: UIConstants
                                                            .spacingM,
                                                        left: UIConstants
                                                            .spacingM,
                                                        right: UIConstants
                                                            .spacingM,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          t.bezeichnung,
                                                          style: UIStyles
                                                              .dialogTitleStyle,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                    // Free places sentence
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        top: UIConstants
                                                            .spacingS,
                                                        left: UIConstants
                                                            .spacingM,
                                                        right: UIConstants
                                                            .spacingM,
                                                        bottom: UIConstants
                                                            .spacingM,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          'Es sind noch $freiePlaetze von ${t.maxTeilnehmer} Plätzen frei',
                                                          style: UIStyles
                                                              .bodyStyle
                                                              .copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                    // Info table
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: UIConstants
                                                            .spacingM,
                                                      ),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // Left column
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    const Text(
                                                                      'Datum: ',
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      DateFormat(
                                                                        'dd.MM.yyyy',
                                                                      ).format(
                                                                        t.datum,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: UIConstants
                                                                      .spacingXS,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    const Text(
                                                                      'Ort: ',
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    Text(t.ort),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: UIConstants
                                                                      .spacingXS,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    const Text(
                                                                      'Kosten: ',
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      '${t.kosten.toStringAsFixed(2)} €',
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: UIConstants
                                                                      .spacingXS,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    const Text(
                                                                      'Gruppe: ',
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      t.webGruppeLabel,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          // Right column (Lehrgang info only)
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    const Text(
                                                                      'Lehrgangsleiter: ',
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    Flexible(
                                                                      child:
                                                                          Text(
                                                                        t.lehrgangsleiter,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: UIConstants
                                                                      .spacingXS,
                                                                ),
                                                                if (t
                                                                    .lehrgangsleiterTel
                                                                    .isNotEmpty)
                                                                  Row(
                                                                    children: [
                                                                      const Text(
                                                                        'Tel.: ',
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,),
                                                                      ),
                                                                      Flexible(
                                                                        child: Text(
                                                                            t.lehrgangsleiterTel,),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                if (t
                                                                    .lehrgangsleiterMail
                                                                    .isNotEmpty)
                                                                  Row(
                                                                    children: [
                                                                      const Text(
                                                                        'E-Mail: ',
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,),
                                                                      ),
                                                                      Flexible(
                                                                        child: Text(
                                                                            t.lehrgangsleiterMail,),
                                                                      ),
                                                                    ],
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height:
                                                          UIConstants.spacingM,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Divider(height: 1),
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  UIConstants.spacingM,
                                                ),
                                                child: t.lehrgangsinhaltHtml
                                                        .isNotEmpty
                                                    ? Html(
                                                        data: t
                                                            .lehrgangsinhaltHtml,
                                                      )
                                                    : t.lehrgangsinhalt
                                                            .isNotEmpty
                                                        ? Text(
                                                            t.lehrgangsinhalt,
                                                          )
                                                        : t.bemerkung.isNotEmpty
                                                            ? Text(t.bemerkung)
                                                            : const Text(
                                                                'Keine Beschreibung verfügbar.',
                                                              ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // FABs at bottom right in a column
                                        Positioned(
                                          bottom: UIConstants.spacingM,
                                          right: UIConstants.spacingM,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              FloatingActionButton(
                                                heroTag:
                                                    'closeSchulungInfoFab$index',
                                                mini: true,
                                                backgroundColor:
                                                    UIConstants.defaultAppColor,
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(
                                                  height: UIConstants.spacingS,),
                                              FloatingActionButton(
                                                heroTag:
                                                    'bookSchulungFab$index',
                                                mini: true,
                                                backgroundColor:
                                                    UIConstants.defaultAppColor,
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  _showBookingDialog(
                                                    t,
                                                    registeredPersons: [],
                                                  );
                                                },
                                                child: const Icon(
                                                  Icons.event_available,
                                                  color: Colors.white,
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
                            },
                            child: const Icon(
                              Icons.description,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            if (!_isLoading &&
                _errorMessage == null &&
                _results.isEmpty &&
                _hasSearched)
              const ScaledText(
                'Keine Schulungen gefunden.',
                style: UIStyles.bodyStyle,
              ),
          ],
        ),
      ),
    );
  }
}

class _RegisteredPerson {
  _RegisteredPerson(this.vorname, this.nachname, this.passnummer);
  final String vorname;
  final String nachname;
  final String passnummer;
}
