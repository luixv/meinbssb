import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/screens/base_screen_layout.dart';
import '/models/user_data.dart';
import '/services/api/user_service.dart';
import '/models/pass_data_zve.dart';
import '/services/core/logger_service.dart';
import '/services/api/training_service.dart';
import '/models/disziplin.dart';
import '/widgets/scaled_text.dart';
import '/providers/font_size_provider.dart';

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
  bool _isLoading = false;
  String? _errorMessage;
  late TextEditingController _autocompleteTextController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _autocompleteTextController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _autocompleteTextController.dispose();
    _searchController.dispose();
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
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final trainingService =
          Provider.of<TrainingService>(context, listen: false);

      final fetchedPassData = await userService.fetchPassdaten(personId);
      final fetchedZveData = await userService.fetchPassdatenZVE(
        passdatenId,
        personId,
      );
      final fetchedDisciplines = await trainingService.fetchDisziplinen();

      if (mounted) {
        setState(() {
          _passData = fetchedPassData;
          _zveData = fetchedZveData;
          _disciplines = fetchedDisciplines;
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
    return Consumer<FontSizeProvider>(
      builder: (context, fontSizeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const ScaledText('Startrechte Ändern'),
            backgroundColor: UIConstants.defaultAppColor,
          ),
          body: FutureBuilder<void>(
            future: _fetchData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: ScaledText(
                    'Fehler beim Laden der Daten: ${snapshot.error}',
                    style: UIStyles.bodyStyle.copyWith(color: Colors.red),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(UIConstants.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScaledText(
                      'Erstverein',
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
                                child: RichText(
                                  text: TextSpan(
                                    style: UIStyles.bodyStyle,
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: _passData!.passnummer,
                                        style: UIStyles.bodyStyle.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const TextSpan(text: ' - '),
                                      TextSpan(
                                        text: _passData!.vereinName,
                                        style: UIStyles.bodyStyle.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    else
                      const ScaledText(
                        'Keine Erstvereinsdaten verfügbar.',
                        style: UIStyles.bodyStyle,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: UIStyles.bodyStyle,
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: '${zve.vVereinNr}',
                                              style: UIStyles.bodyStyle.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const TextSpan(text: ' - '),
                                            TextSpan(
                                              text: zve.vereinName ?? 'N/A',
                                              style: UIStyles.bodyStyle.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (zve.disziplin.isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: UIConstants.spacingS,
                                      ),
                                      ...zve.disziplin
                                          .map((selectedDisziplin) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: UIConstants.spacingXS,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ScaledText(
                                                '• ',
                                                style: UIStyles.bodyStyle.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Expanded(
                                                child: ScaledText(
                                                  selectedDisziplin.disziplin ?? 'N/A',
                                                  style: UIStyles.bodyStyle,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons
                                                      .delete_outline_outlined,
                                                  color: UIConstants
                                                      .defaultAppColor,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    final updatedZveData =
                                                        List<
                                                            PassDataZVE>.from(
                                                          _zveData,
                                                        );
                                                        final index =
                                                            updatedZveData
                                                                .indexOf(zve);
                                                        if (index != -1) {
                                                          final currentDisciplines =
                                                              List<
                                                                  Disziplin>.from(
                                                            zve.disziplin,
                                                          );
                                                          currentDisciplines
                                                              .remove(
                                                            selectedDisziplin,
                                                          );
                                                          updatedZveData[index] =
                                                              zve.copyWith(
                                                            disziplin:
                                                                currentDisciplines,
                                                          );
                                                          _zveData =
                                                              updatedZveData;
                                                        }
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                const SizedBox(height: UIConstants.spacingS),
                                Autocomplete<Disziplin>(
                                  initialValue: const TextEditingValue(
                                    text: '',
                                  ),
                                  optionsBuilder:
                                      (TextEditingValue textEditingValue) {
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
                                    });
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
                                    return Consumer<FontSizeProvider>(
                                      builder: (context, fontSizeProvider, child) {
                                        final scaledStyle = TextStyle(
                                          fontSize: UIConstants.bodyFontSize * fontSizeProvider.scaleFactor,
                                        );
                                        return TextFormField(
                                          controller: textEditingController,
                                          focusNode: focusNode,
                                          decoration: UIStyles.formInputDecoration.copyWith(
                                            labelText: 'Disziplin suchen',
                                            labelStyle: scaledStyle,
                                          ),
                                          style: scaledStyle,
                                        );
                                      },
                                    );
                                  },
                                  onSelected: (Disziplin selection) {
                                    setState(() {
                                      final updatedZveData =
                                          List<PassDataZVE>.from(_zveData);
                                      final index =
                                          updatedZveData.indexOf(zve);
                                      if (index != -1) {
                                        final currentDisciplines =
                                            List<Disziplin>.from(
                                          zve.disziplin,
                                        );
                                        if (!currentDisciplines
                                            .contains(selection)) {
                                          currentDisciplines.add(selection);
                                          updatedZveData[index] =
                                              zve.copyWith(
                                            disziplin: currentDisciplines,
                                          );
                                          _zveData = updatedZveData;
                                        }
                                      }
                                      _autocompleteTextController.clear();
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    else
                      const ScaledText(
                        'Keine Zweitvereinsdaten verfügbar.',
                        style: UIStyles.bodyStyle,
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
