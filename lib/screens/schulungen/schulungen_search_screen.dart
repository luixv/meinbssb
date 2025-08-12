import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/models/user_data.dart';
import '/screens/schulungen_screen.dart';
import 'package:intl/intl.dart';
import '/services/api/bezirk_service.dart';
import '/models/bezirk.dart';
import 'package:provider/provider.dart';
import '/services/core/http_client.dart';
import '/services/core/cache_service.dart';
import '/services/core/network_service.dart';
import '/screens/base_screen_layout.dart';
import '/widgets/scaled_text.dart';
import '/models/schulungstermin.dart';

class SchulungenSearchScreen extends StatefulWidget {
  const SchulungenSearchScreen(
    this.userData, {
    required this.isLoggedIn,
    required this.onLogout,
    this.showMenu = true,
    this.showConnectivityIcon = true,
    super.key,
  });
  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;
  final bool showMenu;
  final bool showConnectivityIcon;

  @override
  State<SchulungenSearchScreen> createState() => _SchulungenSearchScreenState();
}

class _SchulungenSearchScreenState extends State<SchulungenSearchScreen> {
  DateTime? _selectedDate = DateTime.now();
  int? _selectedWebGruppe = 0;
  int? _selectedBezirkId = 0;
  final TextEditingController _ortController = TextEditingController();
  final TextEditingController _titelController = TextEditingController();
  bool _fuerVerlaengerungen = false;
  List<BezirkSearchTriple> _bezirke = [];
  bool _isLoadingBezirke = true;

  @override
  void initState() {
    super.initState();
    _fetchBezirke();
  }

  Future<void> _fetchBezirke() async {
    final httpClient = Provider.of<HttpClient>(context, listen: false);
    final cacheService = Provider.of<CacheService>(context, listen: false);
    final networkService = Provider.of<NetworkService>(context, listen: false);
    final bezirkService = BezirkService(
      httpClient: httpClient,
      cacheService: cacheService,
      networkService: networkService,
    );
    final bezirke = await bezirkService.fetchBezirkeforSearch();

    // Add "Alle" option
    _bezirke = [
      const BezirkSearchTriple(bezirkId: 0, bezirkNr: 0, bezirkName: 'Alle'),
      ...bezirke,
    ];

    setState(() {
      _isLoadingBezirke = false;
    });
  }

  @override
  void dispose() {
    _ortController.dispose();
    _titelController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      locale: const Locale('de', 'DE'),
      helpText: 'Aus-und Weiterbildungen ab Datum anzeigen',
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
                    vertical: UIConstants.spacingSM,
                  ),
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
                  EdgeInsets.symmetric(
                    horizontal: UIConstants.spacingL,
                    vertical: UIConstants.spacingSM,
                  ),
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _navigateToResults() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte wählen Sie ein Datum.'),
          backgroundColor: UIConstants.errorColor,
        ),
      );
      return;
    }
    final safeDate = _selectedDate ?? DateTime.now();
    final userData = widget.userData;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SchulungenScreen(
          userData,
          isLoggedIn: widget.isLoggedIn,
          onLogout: widget.onLogout,
          searchDate: safeDate,
          webGruppe: _selectedWebGruppe,
          bezirkId: _selectedBezirkId,
          ort: _ortController.text,
          titel: _titelController.text,
          fuerVerlaengerungen: _fuerVerlaengerungen,
          showMenu: widget.showMenu,
          showConnectivityIcon: widget.showConnectivityIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Aus- und Weiterbildung',
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout,
      automaticallyImplyLeading: widget.showMenu,
      showMenu: widget.showMenu,
      showConnectivityIcon: widget.showConnectivityIcon,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'resetFab',
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
                _selectedWebGruppe = 0;
                _selectedBezirkId = 0;
                _ortController.clear();
                _titelController.clear();
                _fuerVerlaengerungen = false;
              });
            },
            backgroundColor: UIConstants.defaultAppColor,
            tooltip: 'Formular zurücksetzen',
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(height: UIConstants.spacingS),
          FloatingActionButton(
            heroTag: 'searchFab',
            onPressed: _navigateToResults,
            backgroundColor: UIConstants.defaultAppColor,
            tooltip: 'Suchen',
            child: const Icon(Icons.search),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScaledText(
              'Suchen',
              style: UIStyles.headerStyle,
            ),
            const SizedBox(height: UIConstants.spacingM),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: UIStyles.formInputDecoration.copyWith(
                  labelText: 'Aus-und Weiterbildungen ab Datum anzeigen',
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                child: ScaledText(
                  _selectedDate == null
                      ? 'Bitte wählen Sie ein Datum'
                      : _formatDate(_selectedDate ?? DateTime.now()),
                  style: UIStyles.bodyStyle,
                ),
              ),
            ),
            const SizedBox(height: UIConstants.spacingM),
            DropdownButtonFormField<int>(
              value: _selectedWebGruppe,
              decoration: UIStyles.formInputDecoration.copyWith(
                labelText: 'Fachbereich',
              ),
              items: Schulungstermin.webGruppeMap.entries.map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedWebGruppe = value;
                });
              },
            ),
            const SizedBox(height: UIConstants.spacingM),
            _isLoadingBezirke
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<int>(
                    value: _selectedBezirkId,
                    decoration: UIStyles.formInputDecoration.copyWith(
                      labelText: 'Regierungsbezirk',
                    ),
                    items: _bezirke
                        .map(
                          (bezirk) => DropdownMenuItem<int>(
                            value: bezirk.bezirkId,
                            child: Text(bezirk.bezirkName),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBezirkId = value;
                      });
                    },
                  ),
            const SizedBox(height: UIConstants.spacingM),
            TextFormField(
              controller: _ortController,
              decoration: UIStyles.formInputDecoration.copyWith(
                labelText: 'Ort',
              ),
            ),
            const SizedBox(height: UIConstants.spacingM),
            TextFormField(
              controller: _titelController,
              decoration: UIStyles.formInputDecoration.copyWith(
                labelText: 'Titel',
              ),
            ),
            const SizedBox(height: UIConstants.spacingM),
            CheckboxListTile(
              title: const Text('Für Lizenzverlängerung'),
              value: _fuerVerlaengerungen,
              onChanged: (bool? value) {
                setState(() {
                  _fuerVerlaengerungen = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: UIConstants.spacingM),
          ],
        ),
      ),
    );
  }
}
