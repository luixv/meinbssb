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
  UserData? _passData;
  List<PassDataZVE> _zveData = [];
  List<Disziplin> _disciplines = [];
  List<FremdeVerband> _fremdeVerbaende = [];
  //PassdatenAkzeptOrAktiv passdatenAkzeptierterOderAktiverPass = null;

  bool _isLoading = false;
  String? _errorMessage;
  late TextEditingController _autocompleteTextController;
  final TextEditingController _searchController = TextEditingController();

  String? disziplin_1_1 = '';
  String? disziplin_1_2 = '';
  String? disziplin_2_2 = '';

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

      // For the first column
      PassDataZVE zveData;
      String? tempDisziplin_1_1 = '';
      if (fetchedZveData.isNotEmpty) {
        zveData = fetchedZveData.first;
        String? disziplinNr = zveData.disziplinNr;
        String? disziplin = zveData.disziplin;

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
        disziplin_1_1 = combined;
        tempDisziplin_1_1 = combined;
      }

      // For the second column
      final PassdatenAkzeptOrAktiv?
          fetchedPassdatenAkzeptierterOderAktiverPassData =
          await apiService.fetchPassdatenAkzeptierterOderAktiverPass(
        personId,
      );

      List<ZVE> zvesData = [];
      String? tempDisziplin_1_2;
      String? tempDisziplin_2_2;
      if (fetchedPassdatenAkzeptierterOderAktiverPassData != null) {
        zvesData = fetchedPassdatenAkzeptierterOderAktiverPassData.zves;
        if (zvesData.isNotEmpty) {
          String? disziplinNr1 = zvesData[0].disziplinNr;
          String? disziplin1 = zvesData[0].disziplin;
          String combined1 = '';
          if (disziplin1 != null && disziplin1.isNotEmpty) {
            combined1 = ((disziplinNr1 ?? '') +
                    (disziplinNr1 != null &&
                            disziplinNr1.isNotEmpty &&
                            disziplin1.isNotEmpty
                        ? ' - '
                        : '') +
                    disziplin1)
                .trim();
          }
          tempDisziplin_1_2 = combined1;
        }
        if (zvesData.length > 1) {
          String? disziplinNr2 = zvesData[1].disziplinNr;
          String? disziplin2 = zvesData[1].disziplin;
          String combined2 = '';
          if (disziplin2 != null && disziplin2.isNotEmpty) {
            combined2 = ((disziplinNr2 ?? '') +
                    (disziplinNr2 != null &&
                            disziplinNr2.isNotEmpty &&
                            disziplin2.isNotEmpty
                        ? ' - '
                        : '') +
                    disziplin2)
                .trim();
          }
          tempDisziplin_2_2 = combined2;
        }
      }

      // final fremdeVerbande = await apiService.fetchFremdeVerbaende(vereinNr);

      if (mounted) {
        setState(() {
          _passData = fetchedPassData;
          _zveData = fetchedZveData;
          _disciplines = fetchedDisciplines;
          disziplin_1_1 = tempDisziplin_1_1;
          disziplin_1_2 = tempDisziplin_1_2;
          disziplin_2_2 = tempDisziplin_2_2;
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: 4.0,
            ),
            child: ScaledText(
              'Schützenausweis',
              style: UIStyles.headerStyle.copyWith(
                color: UIConstants.defaultAppColor,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _zveData.length,
                                itemBuilder: (context, index) {
                                  final zve = _zveData[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: UIConstants.spacingS,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                      style: UIStyles.bodyStyle
                                                          .copyWith(
                                                        fontSize: UIStyles
                                                                .bodyStyle
                                                                .fontSize! *
                                                            fontSizeProvider
                                                                .scaleFactor,
                                                      ),
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                          text: zve.vVereinNr
                                                              .toString(),
                                                          style: UIStyles
                                                              .bodyStyle
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
                                                        TextSpan(
                                                          text: zve.vereinName,
                                                          style: UIStyles
                                                              .bodyStyle
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
                                        if (zve.disziplin != null &&
                                            zve.disziplin!.isNotEmpty) ...[
                                          const SizedBox(
                                            height: UIConstants.spacingS,
                                          ),
                                          ...?zve.disziplin
                                              ?.split(',')
                                              .map((selectedDisziplin) {
                                            return Consumer<FontSizeProvider>(
                                              builder: (
                                                context,
                                                fontSizeProvider,
                                                child,
                                              ) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    bottom:
                                                        UIConstants.spacingXXS,
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      ScaledText(
                                                        '• ',
                                                        style: UIStyles
                                                            .bodyStyle
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
                                                      Expanded(
                                                        child: ScaledText(
                                                          selectedDisziplin,
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
                                                      // Remove button logic can be adapted if needed for string
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          }),
                                        ],
                                      ],
                                    ),
                                  );
                                },
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
                                            if (_zveData.isNotEmpty) {
                                              final updatedZveData =
                                                  List<PassDataZVE>.from(
                                                _zveData,
                                              );
                                              final firstZve =
                                                  updatedZveData[0];
                                              // Convert disziplin string to list
                                              List<String> currentDisciplines =
                                                  firstZve.disziplin
                                                          ?.split(',')
                                                          .map((e) => e.trim())
                                                          .where(
                                                            (e) => e.isNotEmpty,
                                                          )
                                                          .toList() ??
                                                      [];
                                              final newDisziplin =
                                                  selection.disziplin ?? '';
                                              if (!currentDisciplines
                                                  .contains(newDisziplin)) {
                                                currentDisciplines
                                                    .add(newDisziplin);
                                                updatedZveData[0] =
                                                    firstZve.copyWith(
                                                  disziplin: currentDisciplines
                                                      .join(', '),
                                                );
                                                _zveData = updatedZveData;
                                              }
                                            }
                                          });
                                          _autocompleteTextController.clear();
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      ScaledText(
                                        'Disziplin 1.1:',
                                        style: UIStyles.bodyStyle.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      ScaledText(
                                        disziplin_1_1 ?? '',
                                        style: UIStyles.bodyStyle,
                                      ),
                                      const SizedBox(height: 8),
                                      ScaledText(
                                        'Disziplin 1.2:',
                                        style: UIStyles.bodyStyle.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      ScaledText(
                                        disziplin_1_2 ?? '',
                                        style: UIStyles.bodyStyle,
                                      ),
                                      const SizedBox(height: 8),
                                      ScaledText(
                                        'Disziplin 2.2:',
                                        style: UIStyles.bodyStyle.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      ScaledText(
                                        disziplin_2_2 ?? '',
                                        style: UIStyles.bodyStyle,
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
