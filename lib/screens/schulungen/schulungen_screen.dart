import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/models/schulungstermin_data.dart';
import '/models/user_data.dart';
import '/models/bank_data.dart';
import '/helpers/utils.dart';

import '/screens/base_screen_layout.dart';
import '/services/api_service.dart';
import '/widgets/scaled_text.dart';

import 'schulungen_search_screen.dart';
import 'schulungen_register_person_dialog.dart';
import 'schulungen_list_item.dart';
import 'schulungen_details_dialog.dart';

import 'dialogs/login_dialog.dart';
import 'dialogs/booking_data_dialog.dart';
import 'dialogs/register_another_dialog.dart';

class SchulungenScreen extends StatefulWidget {
  const SchulungenScreen(
    this.userData, {
    required this.isLoggedIn,
    required this.onLogout,
    required this.searchDate,
    this.webGruppe,
    this.bezirkId,
    this.ort,
    this.titel,
    this.fuerVerlaengerungen,
    this.fuerVuelVerlaengerungen,
    this.showMenu = true,
    this.showConnectivityIcon = true,
    super.key,
  });

  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;
  final DateTime searchDate;
  final int? webGruppe;
  final int? bezirkId;
  final String? ort;
  final String? titel;
  final bool? fuerVerlaengerungen;
  final bool? fuerVuelVerlaengerungen;
  final bool showMenu;
  final bool showConnectivityIcon;

  @override
  State<SchulungenScreen> createState() => _SchulungenScreenState();
}

class _SchulungenScreenState extends State<SchulungenScreen> {
  bool _isLoading = false;
  List<Schulungstermin> _results = [];
  String? _errorMessage;
  UserData? _userData;

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;
    _search();
  }

  Future<void> _search() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _results = [];
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final abDatum = formatDate(widget.searchDate);
      final webGruppe =
          (widget.webGruppe != null && widget.webGruppe != 0)
              ? widget.webGruppe.toString()
              : '*';
      final bezirk =
          (widget.bezirkId != null && widget.bezirkId != 0)
              ? widget.bezirkId.toString()
              : '*';
      final fuerVerlaengerung =
          (widget.fuerVerlaengerungen == true) ? 'true' : '*';
      final fuerVuelVerlaengerung =
          (widget.fuerVuelVerlaengerungen == true) ? 'true' : '*';

      final result = await apiService.fetchSchulungstermine(
        abDatum,
        webGruppe,
        bezirk,
        fuerVerlaengerung,
        fuerVuelVerlaengerung,
      );

      // Filter out all entries where geloescht == true
      var filteredResults = result.where((s) => s.geloescht != true).toList();

      setState(() {
        if (widget.webGruppe != null && widget.webGruppe != 0) {
          filteredResults =
              filteredResults
                  .where((s) => s.webGruppe == widget.webGruppe)
                  .toList();
        }
        if (widget.bezirkId != null && widget.bezirkId != 0) {
          filteredResults =
              filteredResults
                  .where((s) => s.veranstaltungsBezirk == widget.bezirkId)
                  .toList();
        }
        if (widget.ort != null && widget.ort!.isNotEmpty) {
          filteredResults =
              filteredResults
                  .where(
                    (s) =>
                        s.ort.toLowerCase().contains(widget.ort!.toLowerCase()),
                  )
                  .toList();
        }
        if (widget.titel != null && widget.titel!.isNotEmpty) {
          filteredResults =
              filteredResults
                  .where(
                    (s) => s.bezeichnung.toLowerCase().contains(
                      widget.titel!.toLowerCase(),
                    ),
                  )
                  .toList();
        }
        if (widget.fuerVerlaengerungen == true) {
          filteredResults =
              filteredResults.where((s) => s.fuerVerlaengerungen).toList();
        }
        _results = filteredResults;
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
    Schulungstermin schulungsTermin, {
    required List<RegisteredPersonUi> registeredPersons,
  }) async {
    if (!mounted) return;

    final parentContext = context;
    final user = _userData;

    if (user == null) {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        const SnackBar(
          content: Text('Kein Benutzer für die Buchung verfügbar.'),
          duration: UIConstants.snackbarDuration,
          backgroundColor: UIConstants.errorColor,
        ),
      );
      return;
    }

    final apiService = Provider.of<ApiService>(parentContext, listen: false);

    // Show loading indicator
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              UIConstants.defaultAppColor,
            ),
          ),
        );
      },
    );

    // Fetch bank data and contacts in parallel
    final Future<List<BankData>> bankDataFuture = apiService
        .fetchBankdatenMyBSSB(user.webLoginId);
    final Future<List<Map<String, dynamic>>> contactsFuture = apiService
        .fetchKontakte(user.personId);

    final List<BankData> bankDataList = await bankDataFuture;
    if (!mounted) return;

    final List<Map<String, dynamic>> contacts = await contactsFuture;
    if (!mounted) return;

    final String phoneNumber = extractPhoneNumber(contacts);
    final bankData = bankDataList.isNotEmpty ? bankDataList.first : null;

    if (!mounted) return;
    if (!parentContext.mounted) return;

    // Pop spinner
    Navigator.of(parentContext, rootNavigator: true).pop();

    // Show extracted dialog (moved to separate file)
    await BookingDataDialog.show(
      parentContext,
      schulungsTermin: schulungsTermin,
      user: user,
      registeredPersons: registeredPersons,
      phoneNumber: phoneNumber,
      bankData: bankData,
      onSubmit: ({
        required BankData safeBankData,
        required UserData prefillUser,
        required String prefillEmail,
        required List<RegisteredPersonUi> registeredPersons,
      }) async {
        await registerPersonAndShowDialog(
          schulungsTermin: schulungsTermin,
          registeredPersons: registeredPersons,
          bankData: safeBankData,
          prefillUser: prefillUser,
          prefillEmail: prefillEmail,
        );
      },
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
      leading:
          !widget.showMenu
              ? IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: UIConstants.textColor,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => SchulungenSearchScreen(
                            userData: widget.userData,
                            isLoggedIn: widget.isLoggedIn,
                            onLogout: widget.onLogout,
                            showMenu: widget.showMenu,
                            showConnectivityIcon: widget.showConnectivityIcon,
                          ),
                    ),
                  );
                },
              )
              : null,
      body: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        child:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      UIConstants.defaultAppColor,
                    ),
                  ),
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ScaledText(
                      'Verfügbare Aus- und Weiterbildungen',
                      style: UIStyles.headerStyle,
                    ),
                    const SizedBox(height: UIConstants.spacingM),
                    if (_errorMessage != null)
                      ScaledText(_errorMessage!, style: UIStyles.errorStyle),
                    if (!_isLoading &&
                        _errorMessage == null &&
                        _results.isNotEmpty)
                      Expanded(
                        child: ListView.separated(
                          itemCount: _results.length + 1,
                          separatorBuilder: (context, index) {
                            if (index < _results.length - 1) {
                              return const SizedBox(
                                height: UIConstants.spacingS,
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          itemBuilder: (context, index) {
                            if (index == _results.length) {
                              return const SizedBox(
                                height: UIConstants.helpSpacing,
                              );
                            }
                            final schulungsTermin = _results[index];
                            return SchulungenListItem(
                              schulungsTermin: schulungsTermin,
                              index: index,
                              onDetailsPressed: () async {
                                // Show loading spinner
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => const Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                UIConstants.defaultAppColor,
                                              ),
                                        ),
                                      ),
                                  barrierDismissible: false,
                                );

                                final apiService = Provider.of<ApiService>(
                                  context,
                                  listen: false,
                                );

                                final termin = await apiService
                                    .fetchSchulungstermin(
                                      schulungsTermin.schulungsterminId
                                          .toString(),
                                    );
                                if (!context.mounted) return;

                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();

                                if (termin == null) {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text('Fehler'),
                                          content: const Text(
                                            'Details konnten nicht geladen werden.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () =>
                                                      Navigator.of(
                                                        context,
                                                      ).pop(),
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ),
                                  );
                                  return;
                                }

                                // Fallback for lehrgangsleiterMail and lehrgangsleiterTel
                                final lehrgangsleiterMail =
                                    (termin.lehrgangsleiterMail.isNotEmpty)
                                        ? termin.lehrgangsleiterMail
                                        : schulungsTermin.lehrgangsleiterMail;
                                final lehrgangsleiterTel =
                                    (termin.lehrgangsleiterTel.isNotEmpty)
                                        ? termin.lehrgangsleiterTel
                                        : schulungsTermin.lehrgangsleiterTel;

                                await SchulungenDetailsDialog.show(
                                  context,
                                  termin,
                                  schulungsTermin,
                                  lehrgangsleiterMail: lehrgangsleiterMail,
                                  lehrgangsleiterTel: lehrgangsleiterTel,
                                  isUserLoggedIn: _userData != null,
                                  personId: _userData?.personId,
                                  onBookingPressed: () {
                                    if (_userData == null) {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder:
                                            (dialogContext) => LoginDialog(
                                              onLoginSuccess: (userData) {
                                                setState(() {
                                                  _userData = userData;
                                                });
                                                _showBookingDialog(
                                                  termin,
                                                  registeredPersons: const [],
                                                );
                                              },
                                            ),
                                      );
                                    } else {
                                      _showBookingDialog(
                                        termin,
                                        registeredPersons: const [],
                                      );
                                    }
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    if (!_isLoading &&
                        _errorMessage == null &&
                        _results.isEmpty)
                      const ScaledText(
                        'Keine Schulungen gefunden.',
                        style: UIStyles.bodyStyle,
                      ),
                    const SizedBox(height: UIConstants.helpSpacing),
                  ],
                ),
      ),
    );
  }

  Future<void> registerPersonAndShowDialog({
    required Schulungstermin schulungsTermin,
    required List<RegisteredPersonUi> registeredPersons,
    required BankData bankData,
    UserData? prefillUser,
    String prefillEmail = '',
  }) async {
    final apiService = Provider.of<ApiService>(context, listen: false);

    // Show registration form dialog and wait for result
    final RegisteredPerson? newPerson = await showDialog<RegisteredPerson>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return RegisterPersonFormDialog(
          schulungsTermin: schulungsTermin,
          bankData: bankData,
          loggedInUser: _userData!,
          prefillUser: prefillUser,
          prefillEmail: prefillEmail,
          apiService: apiService,
        );
      },
    );

    if (newPerson == null) return; // User cancelled

    final updatedRegisteredPersons = List<RegisteredPersonUi>.from(
      registeredPersons,
    )..add(
      RegisteredPersonUi(
        newPerson.vorname,
        newPerson.nachname,
        newPerson.passnummer,
      ),
    );

    // After registration, show the 'register another' dialog (moved out)
    final String? registerAnother = await RegisterAnotherDialog.show(
      context,
      schulungsTermin: schulungsTermin,
      registeredPersons: updatedRegisteredPersons,
    );

    if (!mounted) return;

    if (registerAnother == 'registerAnother') {
      await registerPersonAndShowDialog(
        schulungsTermin: schulungsTermin,
        registeredPersons: updatedRegisteredPersons,
        bankData: bankData,
      );
    } else if (registerAnother == 'goHome') {
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',
        (route) => false,
        arguments: {
          'userData': widget.userData,
          'isLoggedIn': widget.isLoggedIn,
          'onLogout': widget.onLogout,
          'showMenu': widget.isLoggedIn,
          'showConnectivityIcon': widget.isLoggedIn,
        },
      );
    }
  }
}
