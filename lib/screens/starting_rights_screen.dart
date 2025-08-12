import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/constants/messages.dart';

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
import 'package:meinbssb/screens/starting_rights_header.dart';
import 'package:meinbssb/screens/starting_rights_zweitverein_table.dart';

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
  bool _digitalerPass = true;
  int get _xx {
    final now = DateTime.now();
    return now.year;
  }

  int get _yy {
    final now = DateTime.now();
    return now.year + 1;
  }

  String get _seasonString {
    final now = DateTime.now();
    int xx, yy;
    // Use September 16 as the deadline
    final deadline = DateTime(now.year, 9, 16);
    if (now.isBefore(deadline)) {
      xx = now.year;
      yy = now.year + 1;
    } else {
      xx = now.year + 1;
      yy = now.year + 2;
    }
    return ' $xx/$yy';
  }

  bool _hasUnsavedChanges = false;

  Future<void> _onSave() async {
    setState(() {
      _isLoading = true;
      _hasUnsavedChanges = false;
    });

    // Compose the full JSON object
    final int? passdatenId = widget.userData?.passdatenId;
    final int? personId = widget.userData?.personId;
    final int? erstVereinId = widget.userData?.erstVereinId;

    final apiService = Provider.of<ApiService>(context, listen: false);
    final bool success = await apiService.postBSSBAppPassantrag(
      secondColumns,
      passdatenId,
      personId,
      erstVereinId,
      _digitalerPass ? 1 : 0,
    );

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Änderungen wurden erfolgreich gespeichert.'
              : 'Fehler beim Speichern der Änderungen.',
        ),
        backgroundColor:
            success ? UIConstants.successColor : UIConstants.errorColor,
      ),
    );
  }

  List<dynamic> _zweitmitgliedschaften = [];
  List<Disziplin> _disciplines = [];
  //List<FremdeVerband> _fremdeVerbaende = [];

  bool _isLoading = false;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  // Map of text controllers for each ZVE's autocomplete
  final Map<int, TextEditingController> _zveTextControllers = {};

  // Data structures for each ZVE
  // combined value -> disziplinId
  Map<int, Map<String, int?>> firstColumns = {};
  // ZVE ID -> second column data
  Map<int, Map<String, int?>> secondColumns = {};
  // ZVE ID -> combined data
  Map<int, Map<String, int?>> pivotDisziplins = {};

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
    // Dispose all ZVE text controllers and clear the map
    for (final controller in _zveTextControllers.values) {
      controller.dispose();
    }
    _zveTextControllers.clear();
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

          // Remove disciplines from fetchedDisciplines that are already in fetchedZveData by ID
          fetchedDisciplines
              .removeWhere((d) => d.disziplinId == zve.disziplinId);

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
          }
        }
      }

      // Ensure every club in localFirstColumns gets a pivot entry
      final allVereinIds = <int>{
        ...localFirstColumns.keys,
        ...localSecondColumns.keys,
      };
      for (final vereinId in allVereinIds) {
        localPivotDisziplins[vereinId] = {
          ...localFirstColumns[vereinId] ?? {},
          ...localSecondColumns[vereinId] ?? {},
        };
      }

      // final fremdeVerbande = await apiService.fetchFremdeVerbaende(vereinNr);

      if (mounted) {
        setState(() {
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
      floatingActionButton: _hasUnsavedChanges
          ? FloatingActionButton(
              heroTag: 'saveFab',
              onPressed: _onSave,
              backgroundColor: UIConstants.defaultAppColor,
              child: _isLoading
                  ? const SizedBox(
                      width: UIConstants.fabIconSize,
                      height: UIConstants.fabIconSize,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          UIConstants.whiteColor,
                        ),
                        strokeWidth: UIConstants.defaultStrokeWidth,
                      ),
                    )
                  : const Icon(Icons.save, color: UIConstants.whiteColor),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StartingRightsHeader(seasonString: _seasonString),
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
                              Messages.clubLabel,
                              style: UIStyles.headerStyle.copyWith(
                                color: UIConstants.defaultAppColor,
                              ),
                            ),
                            const SizedBox(height: UIConstants.spacingS),
                            if (widget.userData != null)
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
                                                    text: widget
                                                        .userData!.vereinName,
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
                                    Messages.noPrimaryClubDataAvailable,
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
                                  top: UIConstants.spacingS,
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
                                return ZweitvereinTable(
                                  xx: _xx,
                                  yy: _yy,
                                  vereinName: vereinName,
                                  firstColumns: firstColumns[vereinId] ?? {},
                                  secondColumns: secondColumns[vereinId] ?? {},
                                  pivot: pivot,
                                  disciplines: _disciplines,
                                  onDelete: (key) {
                                    setState(() {
                                      final updatedSecondColumns =
                                          Map<int, Map<String, int?>>.from(
                                        secondColumns,
                                      );
                                      final updatedPivotDisziplins =
                                          Map<int, Map<String, int?>>.from(
                                        pivotDisziplins,
                                      );
                                      final currentSecond =
                                          Map<String, int?>.from(
                                        updatedSecondColumns[vereinId] ?? {},
                                      );
                                      // Find the DisziplinId for the deleted key
                                      final deletedDisziplinId =
                                          currentSecond[key] ??
                                              firstColumns[vereinId]?[key];
                                      // Remove from table
                                      currentSecond.remove(key);
                                      updatedSecondColumns[vereinId] =
                                          currentSecond;
                                      updatedPivotDisziplins[vereinId] = {
                                        ...firstColumns[vereinId] ?? {},
                                        ...currentSecond,
                                      };
                                      secondColumns = updatedSecondColumns;
                                      pivotDisziplins = updatedPivotDisziplins;
                                      // Reconstruct Disziplin from key and id, add if not present
                                      if (deletedDisziplinId != null) {
                                        // Try to parse disziplinNr and disziplin from key
                                        String? disziplinNr;
                                        String? disziplin;
                                        final parts = key.split(' - ');
                                        if (parts.length == 2) {
                                          disziplinNr = parts[0];
                                          disziplin = parts[1];
                                        } else if (parts.length == 1) {
                                          disziplinNr = null;
                                          disziplin = parts[0];
                                        }
                                        final reconstructed = Disziplin(
                                          disziplinId: deletedDisziplinId,
                                          disziplinNr: disziplinNr,
                                          disziplin: disziplin,
                                        );
                                        if (!_disciplines.any(
                                          (d) =>
                                              d.disziplinId ==
                                              deletedDisziplinId,
                                        )) {
                                          _disciplines =
                                              List<Disziplin>.from(_disciplines)
                                                ..add(reconstructed);
                                        }
                                      }
                                      _hasUnsavedChanges = true;
                                    });
                                  },
                                  onAdd: (selected) {
                                    final combined =
                                        ((selected.disziplinNr ?? '') +
                                                (selected.disziplinNr != null &&
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
                                      final updatedSecondColumns =
                                          Map<int, Map<String, int?>>.from(
                                        secondColumns,
                                      );
                                      final updatedPivotDisziplins =
                                          Map<int, Map<String, int?>>.from(
                                        pivotDisziplins,
                                      );
                                      final currentSecond =
                                          Map<String, int?>.from(
                                        updatedSecondColumns[vereinId] ?? {},
                                      );
                                      currentSecond[combined] =
                                          selected.disziplinId;
                                      updatedSecondColumns[vereinId] =
                                          currentSecond;
                                      updatedPivotDisziplins[vereinId] = {
                                        ...firstColumns[vereinId] ?? {},
                                        ...currentSecond,
                                      };
                                      secondColumns = updatedSecondColumns;
                                      pivotDisziplins = updatedPivotDisziplins;
                                      // Remove from _disciplines if present
                                      _disciplines =
                                          List<Disziplin>.from(_disciplines)
                                            ..removeWhere(
                                              (d) =>
                                                  d.disziplinId ==
                                                  selected.disziplinId,
                                            );
                                      _hasUnsavedChanges = true;
                                    });
                                    if (_zveTextControllers[vereinId] != null) {
                                      _zveTextControllers[vereinId]!.clear();
                                    }
                                  },
                                );
                              }),
                            ],
                            const SizedBox(height: UIConstants.spacingXXXL),
                            // Add checkbox for physikalischer Ausweis
                            Row(
                              children: [
                                Checkbox(
                                  value: _digitalerPass,
                                  onChanged: (val) {
                                    setState(() {
                                      _digitalerPass = val ?? false;
                                      _hasUnsavedChanges = true;
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Row(
                                    children: [
                                      ScaledText(
                                        'zusätzlicher physikalischer Ausweis',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Tooltip(
                                        message: 'Kostenpflichtig',
                                        child: Icon(
                                          Icons.info_outline,
                                          color: UIConstants.defaultAppColor,
                                          size: UIConstants.defaultIconSize,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
