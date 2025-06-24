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
import 'package:flutter_html/flutter_html.dart';
import '/services/core/cache_service.dart';
import '/services/api/bank_service.dart';

class VeranstaltungenScreen extends StatefulWidget {
  const VeranstaltungenScreen(
    this.userData, {
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });
  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  State<VeranstaltungenScreen> createState() => _VeranstaltungenScreenState();
}

class _VeranstaltungenScreenState extends State<VeranstaltungenScreen> {
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
                  EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                textStyle: WidgetStatePropertyAll(UIStyles.buttonStyle),
                minimumSize: WidgetStatePropertyAll(Size(120, 48)),
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
                  EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                textStyle: WidgetStatePropertyAll(UIStyles.buttonStyle),
                minimumSize: WidgetStatePropertyAll(Size(120, 48)),
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
        _errorMessage = 'Fehler beim Laden der Veranstaltungen: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Veranstaltungen',
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout,
      body: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScaledText(
              'Veranstaltungen suchen',
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
                            heroTag: 'veranstaltungenContentFab$index',
                            backgroundColor: UIConstants.defaultAppColor,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  int currentIndex = index;
                                  return StatefulBuilder(
                                    builder: (context, setState) => Dialog(
                                      child: Stack(
                                        children: [
                                          SizedBox(
                                            width: UIConstants.dialogWidth,
                                            height: UIConstants.dialogHeight,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                    UIConstants.spacingM,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        _results[currentIndex]
                                                            .bezeichnung,
                                                        style: UIStyles
                                                            .headerStyle,
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      const SizedBox(
                                                        height: UIConstants
                                                            .spacingS,
                                                      ),
                                                      // BEGIN: Info block
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          vertical: 8.0,
                                                          horizontal: 12.0,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: UIConstants
                                                              .tileColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            UIConstants
                                                                .cornerRadius,
                                                          ),
                                                        ),
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
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  DateFormat(
                                                                    'dd.MM.yyyy',
                                                                  ).format(
                                                                    _results[
                                                                            currentIndex]
                                                                        .datum,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                const Text(
                                                                  'Gruppe: ',
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  _results[
                                                                          currentIndex]
                                                                      .webGruppeLabel,
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                const Text(
                                                                  'Ort: ',
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  _results[
                                                                          currentIndex]
                                                                      .ort,
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                const Text(
                                                                  'Kosten: ',
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  _results[
                                                                          currentIndex]
                                                                      .kosten
                                                                      .toString(),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                const Text(
                                                                  'Max. Teilnehmer: ',
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  _results[
                                                                          currentIndex]
                                                                      .maxTeilnehmer
                                                                      .toString(),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                const Text(
                                                                  'Leiter Tel: ',
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  _results[
                                                                          currentIndex]
                                                                      .lehrgangsleiterTel,
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                const Text(
                                                                  'Leiter Mail: ',
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  _results[
                                                                          currentIndex]
                                                                      .lehrgangsleiterMail,
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      // END: Info block
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: SingleChildScrollView(
                                                    child: Html(
                                                      data: _results[
                                                              currentIndex]
                                                          .lehrgangsinhaltHtml,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Close button
                                          Positioned(
                                            bottom: UIConstants.spacingM,
                                            right: UIConstants.spacingM,
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  FloatingActionButton(
                                                    heroTag: 'buchungCancelFab',
                                                    mini: true,
                                                    tooltip: 'Schließen',
                                                    backgroundColor: UIConstants
                                                        .defaultAppColor,
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                    child: const Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height:
                                                        UIConstants.spacingS,
                                                  ),
                                                  FloatingActionButton(
                                                    heroTag: 'buchungOkFab',
                                                    mini: true,
                                                    tooltip:
                                                        'Veranstaltung buchen',
                                                    backgroundColor: UIConstants
                                                        .defaultAppColor,
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                      _showBookingDialog();
                                                    },
                                                    child: const Icon(
                                                      Icons.how_to_reg,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
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
                'Keine Veranstaltungen gefunden.',
                style: UIStyles.bodyStyle,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showBookingDialog() async {
    if (!mounted) return;

    final user = widget.userData;
    // Fetch bank data
    final apiService = Provider.of<ApiService>(
      context,
      listen: false,
    );
    final cacheService = Provider.of<CacheService>(
      context,
      listen: false,
    );

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

    // Now show the booking dialog with the fetched data
    showDialog(
      context: context,
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

        final formKey = GlobalKey<FormState>();

        return Dialog(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.all(UIConstants.spacingM),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ScaledText(
                        'Veranstaltung buchen',
                        style: UIStyles.headerStyle,
                      ),
                      const SizedBox(height: UIConstants.spacingM),
                      // --- Personal Data Block ---
                      Container(
                        decoration: BoxDecoration(
                          color: UIConstants.whiteColor,
                          border:
                              Border.all(color: UIConstants.mydarkGreyColor),
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
                                  child: TextFormField(
                                    controller: emailController,
                                    decoration: UIStyles.formInputDecoration
                                        .copyWith(labelText: 'E-Mail'),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'E-Mail ist erforderlich';
                                      }
                                      final emailRegex = RegExp(
                                        r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[\w-]{2,4}$',
                                      );
                                      if (!emailRegex.hasMatch(value)) {
                                        return 'Bitte geben Sie eine gültige E-Mail Adresse ein';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: UIConstants.spacingM),
                                Expanded(
                                  child: TextFormField(
                                    controller: telefonController,
                                    decoration: UIStyles.formInputDecoration
                                        .copyWith(labelText: 'Telefon'),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Telefonnummer ist erforderlich';
                                      }
                                      final phoneRegex =
                                          RegExp(r'^[0-9\s\-\+\(\)]+$');
                                      if (!phoneRegex.hasMatch(value)) {
                                        return 'Bitte geben Sie eine gültige Telefonnummer ein (nur Ziffern, +, -, (, ) erlaubt)';
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
                      const SizedBox(height: UIConstants.spacingL),
                      // --- Bank Data Block ---
                      Container(
                        decoration: BoxDecoration(
                          color: UIConstants.whiteColor,
                          border:
                              Border.all(color: UIConstants.mydarkGreyColor),
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
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: UIConstants.spacingS),
                    FloatingActionButton(
                      heroTag: 'buchungOkFab',
                      mini: true,
                      tooltip: 'Veranstaltung buchen',
                      backgroundColor: UIConstants.defaultAppColor,
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showBookingDialog();
                      },
                      child: const Icon(
                        Icons.how_to_reg,
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
  }
}
