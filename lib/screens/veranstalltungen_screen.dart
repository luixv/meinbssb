import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/models/schulung.dart';
import '/models/user_data.dart';
import '/screens/base_screen_layout.dart';
import '/services/api_service.dart';
import '/widgets/scaled_text.dart';
import 'package:intl/intl.dart';
import 'package:flutter_html/flutter_html.dart';

class VeranstalltungenScreen extends StatefulWidget {
  const VeranstalltungenScreen(
    this.userData, {
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });
  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  State<VeranstalltungenScreen> createState() => _VeranstalltungenScreenState();
}

class _VeranstalltungenScreenState extends State<VeranstalltungenScreen> {
  DateTime? _selectedDate;
  bool _isLoading = false;
  List<Schulung> _results = [];
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
      title: 'Veranstalltungen',
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
                    final schulung = _results[index];
                    String formattedDate = '';
                    if (schulung.datum.isNotEmpty) {
                      try {
                        final parsed = DateTime.parse(schulung.datum);
                        formattedDate = DateFormat('dd.MM.yyyy').format(parsed);
                      } catch (_) {
                        formattedDate = schulung.datum;
                      }
                    }
                    return Container(
                      decoration: BoxDecoration(
                        color: UIConstants.tileColor,
                        borderRadius:
                            BorderRadius.circular(UIConstants.cornerRadius),
                      ),
                      padding: const EdgeInsets.all(UIConstants.spacingM),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ScaledText(
                                  'Datum: $formattedDate',
                                  style: UIStyles.bodyStyle,
                                ),
                                ScaledText(
                                  'Gruppe: ${schulung.schulungsartId}',
                                  style: UIStyles.bodyStyle,
                                ),
                                ScaledText(
                                  'Ort: ${schulung.ort}',
                                  style: UIStyles.bodyStyle,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: UIConstants.spacingM),
                          Expanded(
                            flex: 1,
                            child: IconButton(
                              icon: const Icon(
                                Icons.description,
                                size: 32,
                                color: UIConstants.defaultAppColor,
                              ),
                              tooltip: 'Inhalt',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog(
                                    child: Stack(
                                      children: [
                                        SizedBox(
                                          width: 400,
                                          height: 400,
                                          child: SingleChildScrollView(
                                            child: Html(
                                              data:
                                                  schulung.lehrgangsinhaltHtml,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 16,
                                          right: 16,
                                          child: FloatingActionButton(
                                            heroTag: 'veranstalltungenCloseFab',
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
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
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
