import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/services/core/logger_service.dart';
import 'package:meinbssb/models/disziplin.dart';
//import 'package:meinbssb/models/fremde_verband.dart';
import 'package:meinbssb/models/passdaten_akzept_or_aktiv.dart';

import 'package:meinbssb/widgets/scaled_text.dart';
import 'package:meinbssb/services/core/font_size_provider.dart';

class StartingRightsScreen extends StatefulWidget {
  const StartingRightsScreen({
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });

  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  State<StartingRightsScreen> createState() => _StartingRightsScreenState();
}

class _StartingRightsScreenState extends State<StartingRightsScreen> {
  bool _hasUnsavedChanges = false;

  void _onSave() {
    // TODO: Implement save logic for starting rights
    setState(() {
      _hasUnsavedChanges = false;
    });

    // SAVE CHANGES LOGIC HERE

    final List<Map<String, dynamic>> zveList = [];
    secondColumns.forEach((vereinId, secondColumn) {
      secondColumn.forEach((key, value) {
        LoggerService.logInfo(
          'Saving ZVE: Verein ID: $vereinId, Key: $key, Value: $value',
        );
        if (value != null) {
          zveList.add({
            'VEREINID': vereinId,
            'DISZIPLINID': value,
          });
        }
      });
    });

    // Compose the full JSON object
    final int? passdatenId = widget.userData?.passdatenId;
    final int? personId = widget.userData?.personId;
    final int? erstvereinId = widget.userData?.erstVereinId;
    final Map<String, dynamic> fullJson = {
      'PASSDATENID': passdatenId,
      'ANTRAGSTYP': 3,
      'PERSONID': personId,
      'ERSTVEREINID': erstvereinId,
      'DIGITALERPASS': 1,
      'ZVEs': zveList,
    };

    LoggerService.logInfo('Full JSON: $fullJson');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Änderungen sind noch nicht gespeichert.')),
    );
  }

  UserData? _passData;
  List<dynamic> _zweitmitgliedschaften = [];
  List<Disziplin> _disciplines = [];
  //List<FremdeVerband> _fremdeVerbaende = [];

  bool _isLoading = false;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  // Map of text controllers for each ZVE's autocomplete
  final Map<int, TextEditingController> _zveTextControllers = {};

  // Data structures for each ZVE
  Map<int, Map<String, int?>> firstColumns =
      {}; // combined value -> disziplinId
  Map<int, Map<String, int?>> secondColumns =
      {}; // ZVE ID -> second column data
  Map<int, Map<String, int?>> pivotDisziplins = {}; // ZVE ID -> combined data

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Dispose all ZVE text controllers
    for (final controller in _zveTextControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchData() async {
    final int? personId = widget.userData?.personId;
    final int? passdatenId = widget.userData?.passdatenId;

    if (personId == null || passdatenId == null) {
      LoggerService.logError(
        'Person ID or Passdaten ID is null. Cannot fetch starting rights data.',
      );
      if (mounted) {
        setState(() {
          _errorMessage =
              'Benutzerdaten nicht verfügbar. Bitte erneut anmelden.';
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _errorMessage = null;
      });
    }

    try {
      // Get providers before any await
      final networkService =
          Provider.of<NetworkService>(context, listen: false);
      final apiService = Provider.of<ApiService>(context, listen: false);

      // Check offline status before fetching
      final isOffline = !(await networkService.hasInternet());
      if (isOffline) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Startrechte sind offline nicht verfügbar';
            _isLoading = false;
          });
        }
        return;
      }

      final fetchedDisciplines = await apiService.fetchDisziplinen();
      final fetchedPassData = await apiService.fetchPassdaten(personId);

      final fetchedZveData = await apiService.fetchPassdatenZVE(
        passdatenId,
        personId,
      );
      final PassdatenAkzeptOrAktiv?
          fetchedPassdatenAkzeptierterOderAktiverPassData =
          await apiService.fetchPassdatenAkzeptierterOderAktiverPass(
        personId,
      );

      final fetchedZweitmitgliedschaften =
          await apiService.fetchZweitmitgliedschaften(
        personId,
      );

      // Initialize data structures for each ZVE
      Map<int, Map<String, int?>> localFirstColumns = {};

      // Fill the first column for each ZVE
      if (fetchedZveData.isNotEmpty) {
        for (final zveData in fetchedZveData) {
          int zvVereinId = zveData.zvVereinId;
          String? disziplinNr = zveData.disziplinNr;
          String? disziplin = zveData.disziplin;
          int? disziplinId = zveData.disziplinId;
          String combined = '';
          if (disziplin != null && disziplin.isNotEmpty) {
            // combined : disziplinNr - disziplin
            combined = ((disziplinNr ?? '') +
                    (disziplinNr != null &&
                            disziplinNr.isNotEmpty &&
                            disziplin.isNotEmpty
                        ? ' - '
                        : '') +
                    disziplin)
                .trim();
          }
          if (combined.isNotEmpty) {
            localFirstColumns[zvVereinId] ??= {};
            localFirstColumns[zvVereinId]![combined] = disziplinId;
          }
        }
      }

      // Fill the seconds column for each ZVE
      Map<int, Map<String, int?>> localSecondColumns = {};
      Map<int, Map<String, int?>> localPivotDisziplins = {};

      if (fetchedPassdatenAkzeptierterOderAktiverPassData != null) {
        for (final zve
            in fetchedPassdatenAkzeptierterOderAktiverPassData.zves) {
          final int vereinId = zve.vereinId;
          final String? disziplinNr = zve.disziplinNr;
          final String? disziplin = zve.disziplin;
          final int disziplinId = zve.disziplinId;
          String combined = '';
          if (disziplin != null && disziplin.isNotEmpty) {
            combined = ((disziplinNr ?? '') +
                    (disziplinNr != null &&
                            disziplinNr.isNotEmpty &&
                            disziplin.isNotEmpty
                        ? ' - '
                        : '') +
                    disziplin)
                .trim();
          }
          if (combined.isNotEmpty) {
            localSecondColumns[vereinId] ??= {};
            localSecondColumns[vereinId]![combined] = disziplinId;
            // Calculate localPivotDisziplins as the set union of localFirstColumns and localSecondColumns[vereinId]
            localPivotDisziplins[vereinId] = {
              ...localFirstColumns[vereinId] ?? {},
              ...localSecondColumns[vereinId]!,
            };
          }
        }
      }

      // final fremdeVerbande = await apiService.fetchFremdeVerbaende(vereinNr);

      if (mounted) {
        setState(() {
          _passData = fetchedPassData;
          _disciplines = fetchedDisciplines;
          _zweitmitgliedschaften = fetchedZweitmitgliedschaften;
          firstColumns = Map<int, Map<String, int?>>.from(localFirstColumns);
          secondColumns = Map<int, Map<String, int?>>.from(localSecondColumns);
          pivotDisziplins =
              Map<int, Map<String, int?>>.from(localPivotDisziplins);
        });
      }
    } catch (e) {
      LoggerService.logError('Error fetching starting rights data: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Fehler beim Laden der Startrechte: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Startrechte',
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout,
      floatingActionButton: FloatingActionButton(
        heroTag: 'saveFab',
        onPressed: _hasUnsavedChanges ? _onSave : null,
        backgroundColor: _hasUnsavedChanges
            ? UIConstants.defaultAppColor
            : UIConstants.disabledBackgroundColor,
        child: const Icon(Icons.save, color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                UIConstants.screenPadding.copyWith(top: UIConstants.spacingS),
            child: ScaledText(
              'Schützenausweis',
              style: UIStyles.headerStyle.copyWith(
                color: UIConstants.defaultAppColor,
              ),
            ),
          ),
          Padding(
            padding: UIConstants.defaultHorizontalPadding,
            child: ScaledText(
              'Startrechte ändern für das Sportjahr\n XX/YY',
              style: UIStyles.bodyStyle.copyWith(
                color: UIConstants.greySubtitleTextColor,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: _errorMessage ==
                                'Startrechte sind offline nicht verfügbar'
                            ? Padding(
                                padding: UIConstants.screenPadding,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.wifi_off,
                                      size: UIConstants.wifiOffIconSize,
                                      color: UIConstants.noConnectivityIcon,
                                    ),
                                    const SizedBox(
                                      height: UIConstants.spacingM,
                                    ),
                                    ScaledText(
                                      _errorMessage!,
                                      style: UIStyles.headerStyle.copyWith(
                                        color: UIConstants.textColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(
                                      height: UIConstants.spacingS,
                                    ),
                                    ScaledText(
                                      'Bitte stellen Sie sicher, dass Sie mit dem Internet verbunden sind, um auf Ihre Startrechte zuzugreifen.',
                                      style: UIStyles.bodyStyle.copyWith(
                                        color:
                                            UIConstants.greySubtitleTextColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : ScaledText(
                                _errorMessage!,
                                style: UIStyles.bodyStyle
                                    .copyWith(color: UIConstants.errorColor),
                              ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(UIConstants.spacingM),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ScaledText(
                              UIConstants.clubLabel,
                              style: UIStyles.headerStyle.copyWith(
                                color: UIConstants.defaultAppColor,
                              ),
                            ),
                            const SizedBox(height: UIConstants.spacingS),
                            if (_passData != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Consumer<FontSizeProvider>(
                                          builder: (
                                            context,
                                            fontSizeProvider,
                                            child,
                                          ) {
                                            return RichText(
                                              text: TextSpan(
                                                style: UIStyles.subtitleStyle
                                                    .copyWith(
                                                  fontSize: UIStyles
                                                          .subtitleStyle
                                                          .fontSize! *
                                                      fontSizeProvider
                                                          .scaleFactor,
                                                ),
                                                children: <TextSpan>[
                                                  /*
                                                  TextSpan(
                                                    text: _passData!.passnummer,
                                                    style: UIStyles
                                                        .subtitleStyle
                                                        .copyWith(
                                                      fontSize: UIStyles
                                                              .subtitleStyle
                                                              .fontSize! *
                                                          fontSizeProvider
                                                              .scaleFactor,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: ' - ',
                                                    style: UIStyles.titleStyle
                                                        .copyWith(
                                                      fontSize: UIStyles
                                                              .subtitleStyle
                                                              .fontSize! *
                                                          fontSizeProvider
                                                              .scaleFactor,
                                                    ),
                                                  ),
                                                  */
                                                  TextSpan(
                                                    text: '• ',
                                                    style: UIStyles
                                                        .subtitleStyle
                                                        .copyWith(
                                                      fontSize: (UIStyles
                                                              .subtitleStyle
                                                              .fontSize! *
                                                          fontSizeProvider
                                                              .scaleFactor *
                                                          1.5),
                                                      height: 1.0,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: _passData!.vereinName,
                                                    style: UIStyles
                                                        .subtitleStyle
                                                        .copyWith(
                                                      fontSize: UIStyles
                                                              .subtitleStyle
                                                              .fontSize! *
                                                          fontSizeProvider
                                                              .scaleFactor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            else
                              Consumer<FontSizeProvider>(
                                builder: (context, fontSizeProvider, child) {
                                  return ScaledText(
                                    UIConstants.noPrimaryClubDataAvailable,
                                    style: UIStyles.bodyStyle.copyWith(
                                      fontSize: UIStyles.bodyStyle.fontSize! *
                                          fontSizeProvider.scaleFactor,
                                    ),
                                  );
                                },
                              ),
                            const SizedBox(height: UIConstants.spacingM),
                            // Show Zweitmitgliedschaften tables
                            if (_zweitmitgliedschaften.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: UIConstants.spacingM,
                                  bottom: UIConstants.spacingS,
                                ),
                                child: ScaledText(
                                  'Zweitvereine',
                                  style: UIStyles.headerStyle.copyWith(
                                    color: UIConstants.defaultAppColor,
                                  ),
                                ),
                              ),
                              ...List.generate(_zweitmitgliedschaften.length,
                                  (index) {
                                final fzm = _zweitmitgliedschaften[index];
                                final vereinId = fzm.vereinId;
                                final vereinName = fzm.vereinName;
                                final pivot = pivotDisziplins[vereinId] ?? {};
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: UIConstants.spacingM,
                                        bottom: UIConstants.spacingS,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Consumer<FontSizeProvider>(
                                              builder: (
                                                context,
                                                fontSizeProvider,
                                                child,
                                              ) {
                                                return RichText(
                                                  text: TextSpan(
                                                    style: UIStyles
                                                        .subtitleStyle
                                                        .copyWith(
                                                      fontSize: UIStyles
                                                              .subtitleStyle
                                                              .fontSize! *
                                                          fontSizeProvider
                                                              .scaleFactor,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text: '• ',
                                                        style: UIStyles
                                                            .subtitleStyle
                                                            .copyWith(
                                                          fontSize: (UIStyles
                                                                  .subtitleStyle
                                                                  .fontSize! *
                                                              fontSizeProvider
                                                                  .scaleFactor *
                                                              1.5),
                                                          height: 1.0,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: vereinName,
                                                        style: UIStyles
                                                            .subtitleStyle
                                                            .copyWith(
                                                          fontSize: UIStyles
                                                                  .subtitleStyle
                                                                  .fontSize! *
                                                              fontSizeProvider
                                                                  .scaleFactor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Table(
                                      columnWidths: const <int,
                                          TableColumnWidth>{
                                        0: IntrinsicColumnWidth(),
                                        1: IntrinsicColumnWidth(),
                                        2: FlexColumnWidth(),
                                      },
                                      border: TableBorder.all(
                                        color: Colors.transparent,
                                      ),
                                      children: [
                                        TableRow(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: ScaledText(
                                                '1. Spalte',
                                                style:
                                                    UIStyles.bodyStyle.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: ScaledText(
                                                '2. Spalte',
                                                style:
                                                    UIStyles.bodyStyle.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: ScaledText(
                                                'Disziplin',
                                                style:
                                                    UIStyles.bodyStyle.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox
                                                .shrink(), // For delete icon column
                                          ],
                                        ),
                                        ...pivot.entries.map(
                                          (entry) => TableRow(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Center(
                                                  child: firstColumns[vereinId]
                                                              ?.containsKey(
                                                            entry.key,
                                                          ) ==
                                                          true
                                                      ? const Icon(
                                                          Icons.check,
                                                          color: UIConstants
                                                              .defaultAppColor,
                                                        )
                                                      : const SizedBox.shrink(),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Center(
                                                  child: secondColumns[vereinId]
                                                              ?.containsKey(
                                                            entry.key,
                                                          ) ==
                                                          true
                                                      ? const Icon(
                                                          Icons.check,
                                                          color: UIConstants
                                                              .defaultAppColor,
                                                        )
                                                      : const SizedBox.shrink(),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: ScaledText(
                                                  entry.key,
                                                  style: UIStyles.bodyStyle,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: UIConstants
                                                      .defaultAppColor,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    // Remove from secondColumns for this vereinId
                                                    final updatedSecondColumns =
                                                        Map<
                                                            int,
                                                            Map<String,
                                                                int?>>.from(
                                                      secondColumns,
                                                    );
                                                    final updatedPivotDisziplins =
                                                        Map<
                                                            int,
                                                            Map<String,
                                                                int?>>.from(
                                                      pivotDisziplins,
                                                    );
                                                    final currentSecond =
                                                        Map<String, int?>.from(
                                                      updatedSecondColumns[
                                                              vereinId] ??
                                                          {},
                                                    );
                                                    currentSecond
                                                        .remove(entry.key);
                                                    updatedSecondColumns[
                                                            vereinId] =
                                                        currentSecond;
                                                    // Rebuild pivotDisziplins for this vereinId
                                                    updatedPivotDisziplins[
                                                        vereinId] = {
                                                      ...firstColumns[
                                                              vereinId] ??
                                                          {},
                                                      ...currentSecond,
                                                    };
                                                    secondColumns =
                                                        updatedSecondColumns;
                                                    pivotDisziplins =
                                                        updatedPivotDisziplins;
                                                    _hasUnsavedChanges = true;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Autocomplete dropdown for adding new discipline
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Autocomplete<Disziplin>(
                                        optionsBuilder: (
                                          TextEditingValue textEditingValue,
                                        ) {
                                          if (textEditingValue.text == '') {
                                            return const Iterable<
                                                Disziplin>.empty();
                                          }
                                          return _disciplines
                                              .where((Disziplin d) {
                                            return (d.disziplin
                                                            ?.toLowerCase() ??
                                                        '')
                                                    .contains(
                                                  textEditingValue.text
                                                      .toLowerCase(),
                                                ) ||
                                                (d.disziplinNr?.toLowerCase() ??
                                                        '')
                                                    .contains(
                                                  textEditingValue.text
                                                      .toLowerCase(),
                                                );
                                          });
                                        },
                                        displayStringForOption: (Disziplin d) =>
                                            ((d.disziplinNr != null &&
                                                    d.disziplinNr!.isNotEmpty)
                                                ? '${d.disziplinNr} - '
                                                : '') +
                                            (d.disziplin ?? ''),
                                        fieldViewBuilder: (
                                          context,
                                          controller,
                                          focusNode,
                                          onFieldSubmitted,
                                        ) {
                                          // Store the controller for this vereinId
                                          _zveTextControllers[vereinId] =
                                              controller;
                                          return TextField(
                                            controller: controller,
                                            focusNode: focusNode,
                                            decoration: const InputDecoration(
                                              labelText: 'Disziplin hinzufügen',
                                              border: OutlineInputBorder(),
                                            ),
                                          );
                                        },
                                        onSelected: (Disziplin selected) {
                                          final combined = ((selected.disziplinNr ??
                                                      '') +
                                                  (selected.disziplinNr !=
                                                              null &&
                                                          selected.disziplinNr!
                                                              .isNotEmpty &&
                                                          (selected.disziplin
                                                                  ?.isNotEmpty ??
                                                              false)
                                                      ? ' - '
                                                      : '') +
                                                  (selected.disziplin ?? ''))
                                              .trim();
                                          setState(() {
                                            // Add to secondColumns for this vereinId
                                            final updatedSecondColumns = Map<
                                                int, Map<String, int?>>.from(
                                              secondColumns,
                                            );
                                            final updatedPivotDisziplins = Map<
                                                int, Map<String, int?>>.from(
                                              pivotDisziplins,
                                            );
                                            final currentSecond =
                                                Map<String, int?>.from(
                                              updatedSecondColumns[vereinId] ??
                                                  {},
                                            );
                                            currentSecond[combined] =
                                                selected.disziplinId;
                                            updatedSecondColumns[vereinId] =
                                                currentSecond;
                                            // Rebuild pivotDisziplins for this vereinId
                                            updatedPivotDisziplins[vereinId] = {
                                              ...firstColumns[vereinId] ?? {},
                                              ...currentSecond,
                                            };
                                            secondColumns =
                                                updatedSecondColumns;
                                            pivotDisziplins =
                                                updatedPivotDisziplins;
                                            _hasUnsavedChanges = true;
                                          });
                                          // Clear the field after selection
                                          if (_zveTextControllers[vereinId] !=
                                              null) {
                                            _zveTextControllers[vereinId]!
                                                .clear();
                                          }
                                        },
                                      ),
                                    ),
                                    if (index <
                                        _zweitmitgliedschaften.length - 1)
                                      const Padding(
                                        padding: EdgeInsets.only(
                                          top: 24.0, // more space above
                                          bottom: 4.0, // less space below
                                        ),
                                        child: Divider(),
                                      ),
                                  ],
                                );
                              }),
                            ],
                            // ...bottom part with dropdown menus removed...
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
