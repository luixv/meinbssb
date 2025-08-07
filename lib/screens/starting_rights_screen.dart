import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/models/user_data.dart';
import 'package:meinbssb/services/api_service.dart';
import 'package:meinbssb/services/core/network_service.dart';
import 'package:meinbssb/models/pass_data_zve.dart';
import 'package:meinbssb/services/core/logger_service.dart';
import 'package:meinbssb/models/disziplin.dart';
import 'package:meinbssb/models/zve.dart';
import 'package:meinbssb/models/fremde_verband.dart';
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
  void _onSave() {
    // TODO: Implement save logic for starting rights
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Änderungen gespeichert.')),
    );
  }

  UserData? _passData;
  List<PassDataZVE> _zveData = [];
  List<Disziplin> _disciplines = [];
  List<FremdeVerband> _fremdeVerbaende = [];

  bool _isLoading = false;
  String? _errorMessage;
  late TextEditingController _autocompleteTextController;
  final TextEditingController _searchController = TextEditingController();

  Map<String, int?> firstColumn = {};
  Map<String, int?> secondColumn = {};
  Map<String, int?> pivotDisziplins = {};

  @override
  void initState() {
    super.initState();
    _autocompleteTextController = TextEditingController();
    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Do NOT dispose _autocompleteTextController, as it's managed by Autocomplete
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

      // For the first column
      Map<String, int?> localFirstColumn = {};
      if (fetchedZveData.isNotEmpty) {
        for (final zveData in fetchedZveData) {
          String? disziplinNr = zveData.disziplinNr;
          String? disziplin = zveData.disziplin;
          int? disziplinId = zveData.disziplinId;
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
            localFirstColumn[combined] = disziplinId;
          }
        }
      }

      // For the second column
      List<ZVE> zvesData = [];
      Map<String, int?> localSecondColumn = {};
      if (fetchedPassdatenAkzeptierterOderAktiverPassData != null) {
        zvesData = fetchedPassdatenAkzeptierterOderAktiverPassData.zves;
        for (final zve in zvesData) {
          String? disziplinNr = zve.disziplinNr;
          String? disziplin = zve.disziplin;
          int? disziplinId = zve.disziplinId;
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
            localSecondColumn[combined] = disziplinId;
          }
        }
      }

      // Create a map of all unique elements from firstColumn and secondColumn
      final Map<String, int?> localPivotDisziplins = {
        ...localFirstColumn,
        ...localSecondColumn,
      };

      // final fremdeVerbande = await apiService.fetchFremdeVerbaende(vereinNr);

      if (mounted) {
        setState(() {
          _passData = fetchedPassData;
          _zveData = fetchedZveData;
          _disciplines = fetchedDisciplines;
          firstColumn = localFirstColumn;
          secondColumn = localSecondColumn;
          pivotDisziplins = localPivotDisziplins;
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
        onPressed: _onSave,
        backgroundColor: UIConstants.defaultAppColor,
        child: const Icon(Icons.save, color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: UIConstants.screenPadding,
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
                            // ...existing code...
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
                                                style:
                                                    UIStyles.bodyStyle.copyWith(
                                                  fontSize: UIStyles
                                                          .bodyStyle.fontSize! *
                                                      fontSizeProvider
                                                          .scaleFactor,
                                                ),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: _passData!.passnummer,
                                                    style: UIStyles.bodyStyle
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: UIStyles
                                                              .bodyStyle
                                                              .fontSize! *
                                                          fontSizeProvider
                                                              .scaleFactor,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: ' - ',
                                                    style: UIStyles.bodyStyle
                                                        .copyWith(
                                                      fontSize: UIStyles
                                                              .bodyStyle
                                                              .fontSize! *
                                                          fontSizeProvider
                                                              .scaleFactor,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: _passData!.vereinName,
                                                    style: UIStyles.bodyStyle
                                                        .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: UIStyles
                                                              .bodyStyle
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
                            ScaledText(
                              'Zweitvereine',
                              style: UIStyles.headerStyle.copyWith(
                                color: UIConstants.defaultAppColor,
                              ),
                            ),
                            const SizedBox(height: UIConstants.spacingS),
                            if (_zveData.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Consumer<FontSizeProvider>(
                                    builder:
                                        (context, fontSizeProvider, child) {
                                      final zve = _zveData[0];
                                      return RichText(
                                        text: TextSpan(
                                          style: UIStyles.bodyStyle.copyWith(
                                            fontSize: UIStyles
                                                    .bodyStyle.fontSize! *
                                                fontSizeProvider.scaleFactor,
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: zve.vVereinNr.toString(),
                                              style:
                                                  UIStyles.bodyStyle.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: UIStyles
                                                        .bodyStyle.fontSize! *
                                                    fontSizeProvider
                                                        .scaleFactor,
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' - ',
                                              style:
                                                  UIStyles.bodyStyle.copyWith(
                                                fontSize: UIStyles
                                                        .bodyStyle.fontSize! *
                                                    fontSizeProvider
                                                        .scaleFactor,
                                              ),
                                            ),
                                            TextSpan(
                                              text: zve.vereinName,
                                              style:
                                                  UIStyles.bodyStyle.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: UIStyles
                                                        .bodyStyle.fontSize! *
                                                    fontSizeProvider
                                                        .scaleFactor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: UIConstants.spacingS),
                                  ..._zveData.map(
                                    (zve) => zve.disziplin != null &&
                                            zve.disziplin!.isNotEmpty
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ...zve.disziplin!.split(',').map(
                                                    (selectedDisziplin) =>
                                                        Consumer<
                                                            FontSizeProvider>(
                                                      builder: (
                                                        context,
                                                        fontSizeProvider,
                                                        child,
                                                      ) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            bottom: UIConstants
                                                                .spacingXXS,
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              ScaledText(
                                                                '• ',
                                                                style: UIStyles
                                                                    .bodyStyle
                                                                    .copyWith(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: UIStyles
                                                                          .bodyStyle
                                                                          .fontSize! *
                                                                      fontSizeProvider
                                                                          .scaleFactor,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    ScaledText(
                                                                  selectedDisziplin
                                                                      .trim(),
                                                                  style: UIStyles
                                                                      .bodyStyle
                                                                      .copyWith(
                                                                    fontSize: UIStyles
                                                                            .bodyStyle
                                                                            .fontSize! *
                                                                        fontSizeProvider
                                                                            .scaleFactor,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                            ],
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ],
                              )
                            else
                              Consumer<FontSizeProvider>(
                                builder: (context, fontSizeProvider, child) {
                                  return ScaledText(
                                    UIConstants.noSecondaryClubsAvailable,
                                    style: UIStyles.bodyStyle.copyWith(
                                      fontSize: UIStyles.bodyStyle.fontSize! *
                                          fontSizeProvider.scaleFactor,
                                    ),
                                  );
                                },
                              ),
                            const SizedBox(height: UIConstants.spacingM),
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: UIConstants.spacingM,
                              ),
                              child: Consumer<FontSizeProvider>(
                                builder: (context, fontSizeProvider, child) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // PivotDisziplins Table
                                      Table(
                                        columnWidths: const <int,
                                            TableColumnWidth>{
                                          0: IntrinsicColumnWidth(),
                                          1: IntrinsicColumnWidth(),
                                          2: FlexColumnWidth(),
                                          3: IntrinsicColumnWidth(),
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
                                                  style: UIStyles.bodyStyle
                                                      .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: ScaledText(
                                                  '2. Spalte',
                                                  style: UIStyles.bodyStyle
                                                      .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: ScaledText(
                                                  'Disziplin',
                                                  style: UIStyles.bodyStyle
                                                      .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 24),
                                            ],
                                          ),
                                          ...pivotDisziplins.entries.map(
                                            (entry) => TableRow(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Center(
                                                    child:
                                                        firstColumn.containsKey(
                                                      entry.key,
                                                    )
                                                            ? const Icon(
                                                                Icons.check,
                                                                color: UIConstants
                                                                    .defaultAppColor,
                                                              )
                                                            : const SizedBox
                                                                .shrink(),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Center(
                                                    child: secondColumn
                                                            .containsKey(
                                                      entry.key,
                                                    )
                                                        ? const Icon(
                                                            Icons.check,
                                                            color: UIConstants
                                                                .defaultAppColor,
                                                          )
                                                        : const SizedBox
                                                            .shrink(),
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
                                                      secondColumn
                                                          .remove(entry.key);
                                                      // Also update pivotDisziplins to reflect the change
                                                      pivotDisziplins = {
                                                        ...firstColumn,
                                                        ...secondColumn,
                                                      };
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Autocomplete<Disziplin>(
                                        optionsBuilder: (
                                          TextEditingValue textEditingValue,
                                        ) {
                                          if (textEditingValue.text.isEmpty) {
                                            return const Iterable<
                                                Disziplin>.empty();
                                          }
                                          return _disciplines
                                              .where((Disziplin option) {
                                            return (option.disziplin
                                                            ?.toLowerCase() ??
                                                        '')
                                                    .contains(
                                                  textEditingValue.text
                                                      .toLowerCase(),
                                                ) ||
                                                (option.disziplinNr
                                                            ?.toLowerCase() ??
                                                        '')
                                                    .contains(
                                                  textEditingValue.text
                                                      .toLowerCase(),
                                                );
                                          }).take(
                                            UIConstants.maxFilteredDisziplinen,
                                          );
                                        },
                                        displayStringForOption: (
                                          Disziplin option,
                                        ) =>
                                            '${option.disziplinNr ?? 'N/A'} - ${option.disziplin ?? 'N/A'}',
                                        fieldViewBuilder: (
                                          BuildContext context,
                                          TextEditingController
                                              textEditingController,
                                          FocusNode focusNode,
                                          VoidCallback onFieldSubmitted,
                                        ) {
                                          _autocompleteTextController =
                                              textEditingController;
                                          return TextField(
                                            controller: textEditingController,
                                            focusNode: focusNode,
                                            style: UIStyles.bodyStyle.copyWith(
                                              fontSize: UIStyles
                                                      .bodyStyle.fontSize! *
                                                  fontSizeProvider.scaleFactor,
                                            ),
                                            decoration: UIStyles
                                                .formInputDecoration
                                                .copyWith(
                                              labelText: 'Disziplin hinzufügen',
                                              labelStyle: UIStyles
                                                  .formLabelStyle
                                                  .copyWith(
                                                fontSize: UIStyles
                                                        .formLabelStyle
                                                        .fontSize! *
                                                    fontSizeProvider
                                                        .scaleFactor,
                                              ),
                                              floatingLabelStyle: UIStyles
                                                  .formLabelStyle
                                                  .copyWith(
                                                fontSize: UIStyles
                                                        .formLabelStyle
                                                        .fontSize! *
                                                    fontSizeProvider
                                                        .scaleFactor,
                                              ),
                                              hintStyle: UIStyles.formLabelStyle
                                                  .copyWith(
                                                fontSize: UIStyles
                                                        .formLabelStyle
                                                        .fontSize! *
                                                    fontSizeProvider
                                                        .scaleFactor,
                                              ),
                                              prefixIcon: Icon(
                                                Icons.search,
                                                size: 24 *
                                                    fontSizeProvider
                                                        .scaleFactor,
                                              ),
                                            ),
                                          );
                                        },
                                        onSelected: (Disziplin selection) {
                                          setState(() {
                                            // Build the combined key as in the rest of the code
                                            final disziplinNr =
                                                selection.disziplinNr;
                                            final disziplin =
                                                selection.disziplin;
                                            String combined = '';
                                            if ((disziplinNr != null &&
                                                    disziplinNr.isNotEmpty) ||
                                                (disziplin != null &&
                                                    disziplin.isNotEmpty)) {
                                              combined = ((disziplinNr ?? '') +
                                                      (disziplinNr != null &&
                                                              disziplinNr
                                                                  .isNotEmpty &&
                                                              disziplin !=
                                                                  null &&
                                                              disziplin
                                                                  .isNotEmpty
                                                          ? ' - '
                                                          : '') +
                                                      (disziplin ?? ''))
                                                  .trim();
                                            }
                                            if (combined.isNotEmpty &&
                                                !secondColumn
                                                    .containsKey(combined)) {
                                              secondColumn[combined] =
                                                  selection.disziplinId;
                                              // Also update pivotDisziplins to reflect the change
                                              pivotDisziplins = {
                                                ...firstColumn,
                                                ...secondColumn,
                                              };
                                            }
                                          });
                                          _autocompleteTextController.clear();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
