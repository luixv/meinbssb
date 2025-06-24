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
                                                    onPressed: () async {
                                                      Navigator.of(context)
                                                          .pop();
                                                      // Show the booking dialog
                                                      final dialogContext =
                                                          context;
                                                      final user =
                                                          widget.userData;
                                                      // Fetch bank data
                                                      final apiService =
                                                          Provider.of<
                                                              ApiService>(
                                                        context,
                                                        listen: false,
                                                      );
                                                      List<BankData>
                                                          bankDataList =
                                                          await apiService
                                                              .fetchBankData(
                                                        user?.webLoginId ?? 0,
                                                      );
                                                      final bankData =
                                                          bankDataList
                                                                  .isNotEmpty
                                                              ? bankDataList
                                                                  .first
                                                              : null;
                                                      if (!mounted) return;
                                                      showDialog(
                                                        context: dialogContext,
                                                        builder: (context) {
                                                          final emailController =
                                                              TextEditingController(
                                                            text: '',
                                                          );
                                                          final telefonController =
                                                              TextEditingController(
                                                            text:
                                                                user?.telefon ??
                                                                    '',
                                                          );
                                                          final kontoinhaberController =
                                                              TextEditingController(
                                                            text: bankData
                                                                    ?.kontoinhaber ??
                                                                '',
                                                          );
                                                          final ibanController =
                                                              TextEditingController(
                                                            text: bankData
                                                                    ?.iban ??
                                                                '',
                                                          );
                                                          final bicController =
                                                              TextEditingController(
                                                            text:
                                                                bankData?.bic ??
                                                                    '',
                                                          );
                                                          return Dialog(
                                                            child: Padding(
                                                              padding: UIConstants
                                                                  .dialogPadding,
                                                              child:
                                                                  SingleChildScrollView(
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .stretch,
                                                                  children: [
                                                                    const Text(
                                                                      'Veranstaltung buchen',
                                                                      style: UIStyles
                                                                          .headerStyle,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                    const SizedBox(
                                                                      height: UIConstants
                                                                          .spacingM,
                                                                    ),
                                                                    Text(
                                                                      _results[
                                                                              currentIndex]
                                                                          .bezeichnung,
                                                                      style: UIStyles
                                                                          .subtitleStyle,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                    const SizedBox(
                                                                      height: UIConstants
                                                                          .spacingM,
                                                                    ),
                                                                    Text(
                                                                      'Es sind noch ${_results[currentIndex].angemeldeteTeilnehmer} von ${_results[currentIndex].maxTeilnehmer} Plätzen frei.',
                                                                      style: UIStyles
                                                                          .bodyStyle,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                    const SizedBox(
                                                                      height: UIConstants
                                                                          .spacingL,
                                                                    ),
                                                                    // Personal Data Block
                                                                    Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: UIConstants
                                                                            .whiteColor,
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              UIConstants.mydarkGreyColor,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(UIConstants.cornerRadius),
                                                                      ),
                                                                      padding:
                                                                          UIConstants
                                                                              .defaultPadding,
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          const Text(
                                                                            'Persönliche Daten',
                                                                            style:
                                                                                UIStyles.sectionTitleStyle,
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                UIConstants.spacingM,
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Expanded(
                                                                                child: TextField(
                                                                                  controller: TextEditingController(text: user?.vorname ?? ''),
                                                                                  decoration: UIStyles.formInputDecoration.copyWith(labelText: 'Vorname'),
                                                                                  readOnly: true,
                                                                                  style: UIStyles.formValueBoldStyle,
                                                                                ),
                                                                              ),
                                                                              const SizedBox(width: UIConstants.spacingM),
                                                                              Expanded(
                                                                                child: TextField(
                                                                                  controller: TextEditingController(text: user?.namen ?? ''),
                                                                                  decoration: UIStyles.formInputDecoration.copyWith(labelText: 'Nachname'),
                                                                                  readOnly: true,
                                                                                  style: UIStyles.formValueBoldStyle,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                UIConstants.spacingM,
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Expanded(
                                                                                child: TextField(
                                                                                  controller: emailController,
                                                                                  decoration: UIStyles.formInputDecoration.copyWith(labelText: 'E-Mail'),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(width: UIConstants.spacingM),
                                                                              Expanded(
                                                                                child: TextField(
                                                                                  controller: telefonController,
                                                                                  decoration: UIStyles.formInputDecoration.copyWith(labelText: 'Telefonnummer'),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: UIConstants
                                                                          .spacingL,
                                                                    ),
                                                                    // Bank Data Block
                                                                    Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: UIConstants
                                                                            .whiteColor,
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              UIConstants.mydarkGreyColor,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(UIConstants.cornerRadius),
                                                                      ),
                                                                      padding:
                                                                          UIConstants
                                                                              .defaultPadding,
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          const Text(
                                                                            'Bankdaten',
                                                                            style:
                                                                                UIStyles.sectionTitleStyle,
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                UIConstants.spacingM,
                                                                          ),
                                                                          TextField(
                                                                            controller:
                                                                                kontoinhaberController,
                                                                            decoration:
                                                                                UIStyles.formInputDecoration.copyWith(labelText: 'Kontoinhaber'),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                UIConstants.spacingM,
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Expanded(
                                                                                child: TextField(
                                                                                  controller: ibanController,
                                                                                  decoration: UIStyles.formInputDecoration.copyWith(labelText: 'IBAN'),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(width: UIConstants.spacingM),
                                                                              Expanded(
                                                                                child: TextField(
                                                                                  controller: bicController,
                                                                                  decoration: UIStyles.formInputDecoration.copyWith(labelText: 'BIC'),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: UIConstants
                                                                          .spacingL,
                                                                    ),
                                                                    Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerRight,
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          FloatingActionButton(
                                                                            heroTag:
                                                                                'buchungCancelFab',
                                                                            mini:
                                                                                true,
                                                                            tooltip:
                                                                                'Schließen',
                                                                            backgroundColor:
                                                                                UIConstants.defaultAppColor,
                                                                            onPressed: () =>
                                                                                Navigator.of(context).pop(),
                                                                            child:
                                                                                const Icon(
                                                                              Icons.close,
                                                                              color: Colors.white,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                UIConstants.spacingS,
                                                                          ),
                                                                          FloatingActionButton(
                                                                            heroTag:
                                                                                'buchungOkFab',
                                                                            mini:
                                                                                true,
                                                                            tooltip:
                                                                                'Bestätigen',
                                                                            backgroundColor:
                                                                                UIConstants.defaultAppColor,
                                                                            onPressed:
                                                                                () {
                                                                              /* TODO: Implement OK logic */
                                                                            },
                                                                            child:
                                                                                const Icon(
                                                                              Icons.how_to_reg,
                                                                              color: Colors.white,
                                                                            ),
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
}
